" engspchk.vim: Vim syntax file
" Language:    English
" Author:      Dr. Charles E. Campbell, Jr. <NdrOchip@ScampbellPfamilyA.Mbiz> - NOSPAM
" Last Change: May 11, 2004
" Version:     50
" License:     GPL (Gnu Public License)
"
" Help: {{{1
" Environment Variables: {{{2
"
"  $CVIMSYN         : points to a directory holding the engspchk dictionaries
"                     ie., <engspchk.dict>, <engspchk.usr>, <engspchk.rare>
"
"  g:cvimsyn        : Vim variable, settable in your <.vimrc>, that points to
"                     a directory holding the user word database.
"
"  g:spchklang      : override name-of-file prefix with desired language
"                     prefix/filename (ie. gerspchk.vim ger frspchk.vim fr etc)
"
"  g:spchkautonext  : if this variable exists, then \es and \et will also
"                     automatically jump to the next spelling error (\en).
"                     \ea, if a word is selected, will also do a \en.
"
"  g:spchkdialect   : pick a dialect (no effect if spchklang not "eng")
"                     = "usa" : pick United States dialect
"                     = "uk"  : pick United Kingdom dialect
"                     = "can" : pick Canadian dialect
"
"  g:spchknonhl     : apply engspchk'ing to all non-syntax-highlighted text
"                     (done if variable exists)
"
"  g:spchkpunc =0   : default, no new behavior
"              =1   : check for some simple English punctuation problems
"                     non-capitalized word after ellipse (... a)
"                     non-capitalized word after sentence ending character
"                     ([.?!])
"  g:spchksilent= 0 : default
"               = 1 : usual Sourcing... and Loading messages suppressed
"
"  If you make a Dialect highlighting group, it will be used instead
"
" Finding Dictionaries: {{{2
"      If        g:cvimsyn exists, it is tried
"      Otherwise $CVIMSYN is tried
"      Otherwise each path on the runtimepath is tried
"      Otherwise quit with an error message
"
"      "Trying" involves checking if the spelling dictionary is
"      filereadable(); if not, then if filereadable(expand())
"      works.  If a combination works, that path is set into
"      g:cvimsyn.
"
"      Note that the "eng" prefix can be changed via setting
"      g:spchklang or renaming <engspchk.vim>.  Then engspchk
"      will load:  (elide the [])
"
"         [eng]spchk.dict  Main word dictionary
"         [eng]spchk.usr   User's personal word dictionary
"         [eng]spchk.rare  English only -- Webster's 1913 dictionary extra words
"                          and unusual words culled from previous
"                          <engspchk.dict> wordlists.
"
" Included Maps:  maps use <mapleader>, which by default is \ {{{2
"  \ec : load engspchk
"  \et : add  word under cursor into database (temporarily - ie. just this file)
"  \es : save word under cursor into database (permanently)  (requires $CVIMSYN)
"  \en : move cursor to the next     spelling error
"  \ep : move cursor to the previous spelling error
"  \ea : look for alternative spellings of word under cursor
"  \ed : toggle Dialect highlighting (Warning/Error)
"  \ee : end engspchk
"  \eT : make word under cursor a BadWord (temporarily)
"        (opposite of \et)
"  \eS : make word under cursor a BadWord (permanently)  (requires $CVIMSYN)
"        (opposite of \es)
"        --removes words from user dictionary, not <*.dict>--
"
" Maps for Alternatives Window Only:
"  <cr> : on alternatives line, will put word under cursor in
"         searchword's stead
"  <tab>: like <cr>, but does a global substitute changing all such
"         mispelled words to the selected alternate word.
"  q    : will quit the alternate-word window
"  :q   : will quit the alternate-word window
"
" Usage: {{{2
"  Simply source the file in.  It does *not* do a "syntax clear", so that means
"  that you can usually just source it in on top of other highlighting.
"  NOTE: not all alphas of 6.0 support plugins, <silent>, etc.
"        engspchk can't check for them; all their versions are 600.
"        Besides, 6.1 is out nowadays.
"
" Non English Languages: {{{2
"  There are versions of this script for languages other than English.
"  I've tried to make this script work for non-English languages by
"
"    (a) allowing one to rename the script with a different prefix
"    (b) using that prefix to load the non-English language dictionary
"
"  If you come up with a version for another language, please let me
"  know where on the web it is so that I can help make it known.
"
"    Dutch     : http://www.thomer.com/thomer/vi/nlspchk.vim.gz
"    German    : http://jeanluc-picard.de/vim/gerspchk/gerspchk.vim.gz
"    Hungarian : http://vim.sourceforge.net/scripts/script.php?script_id=22
"    Polish    : http://strony.wp.pl/wp/kostoo/download.htm#vim
"    Yiddish   : http://www.cs.uky.edu/~raphael/yiddish/vim.tar.gz

"------------------------------------------------------------------------------

" Determining current language (based on name of this file) {{{2
"                    -or- if it previously exists
"   ie. engspchk gerspchk nlspchk hngspchk yidspchk etc
"       eng      ger      nl      hng      yid
"
"  b:spchklang: dictionary language prefix
"  b:spchkfile: prefix based on name of this file
if exists("g:spchklang")
 let b:spchklang= substitute(g:spchklang,'spchk\.vim',"","e")
 let b:spchkfile= substitute(expand("<sfile>:t"),'spchk\.vim',"","e")
else
 let b:spchklang= substitute(expand("<sfile>:t"),'spchk\.vim',"","e")
 let b:spchkfile= b:spchklang
endif
let s:spchkfile= b:spchkfile
let b:Spchklang=substitute(b:spchklang,'\(.\)\(.*\)$','\u\1\2','')

if exists("mapleader") && mapleader != ""
 let s:usermaplead= mapleader
else
 let s:usermaplead= '\'
endif
let s:mapleadstring= escape(s:usermaplead,'\ ')

" Quick load:
if !exists("s:loaded_".s:spchkfile."spchk")
 let s:loaded_{b:spchkfile}spchk=  1
 let s:spchkversion             = 50
 let s:engspchk_loadcnt         =  0

 " ---------------------------------------------------------------------
 " Pre-Loading Interface: {{{1
 "       \ec invokes <Plug>LoadSpchk which invokes <SID>LoadSpchk()
 if !hasmapto('<Plug>LoadSpchk')
  nmap <unique> <Leader>ec <Plug>LoadSpchk
 endif

 " Global Maps
 nmap <silent> <script> <Plug>LoadSpchk :call <SID>LoadSpchk()<CR>

" ---------------------------------------------------------------------
 " LoadSpchk: set up and actually load <engspchk.vim>
 silent! fun! <SID>LoadSpchk()
"   call Dfunc("LoadSpchk()")
   " prevent unnecessary re-loading of engspchk
   if exists("b:engspchk_loaded")
"   	call Dret("LoadSpchk : preventing unnecessary re-load of engspchk (b:engspchk_loaded=".b:engspchk_loaded.")")
    return
   endif
   let b:engspchk_loaded  = 1
   let s:engspchk_loadcnt = s:engspchk_loadcnt + 1
   let b:hidden           = &hidden
   set hidden
"   call Decho("b:engspchk_loaded=".b:engspchk_loaded." s:engspchk_loadcnt=".s:engspchk_loadcnt)

   let b:ch_keep = &ch
   let s:errid     = synIDtrans(hlID("Error"))
"   call Decho("setting spchkfile=".b:spchkfile)
"   call Decho("setting spchklang=".b:spchklang)
"   call Decho("setting Spchklang=".b:Spchklang)
"   call Decho("setting errid=".s:errid)

   set ch=8
   exe 'runtime plugin/'.b:spchkfile.'spchk.vim'
   let &ch  = b:ch_keep
   unlet b:ch_keep
"   call Dret("LoadSpchk")
 endfun

" ---------------------------------------------------------------------

 " Pre-Loading DrChip menu support:

  " set up b:spchklang and b:Spchklang {{{2
  if exists("g:spchklang")
   let b:spchklang= substitute(g:spchklang,'spchk\.vim',"","e")
   let b:spchkfile= s:spchkfile
  else
   let b:spchklang= s:spchkfile
   let b:spchkfile= s:spchkfile
  endif
  let b:Spchklang = substitute(b:spchklang,'\(.\)\(.*\)$','\u\1\2','')

  " ---------------------------------------------------------------------
  " AltLangMenus: read cvimsyn directory for alternate languages {{{2
  "    domenu=1 : make menu entries
  "          =0 : unmenu the entries
  fun! s:AltLangMenus(domenu)
"    call Dfunc("AltLangMenus(domenu=".a:domenu.")")

  	if a:domenu == 1
     let b:cvimsyn= exists("g:cvimsyn")? g:cvimsyn : $CVIMSYN
"	 call Decho("b:cvimsyn set to <".b:cvimsyn.">")
     if b:cvimsyn != ""
      let dictfiles= glob(b:cvimsyn."/*spchk.dict")
      let dictfile = ""
"      call Decho("dictfiles<".dictfiles.">")
      while dictfiles != dictfile
       let pat      = '^\(.\{-}\)\n\(.*$\)'
       let dictfile = substitute(dictfiles,pat,'\1','e')
       let dictfiles= substitute(dictfiles,pat,'\2','e')
       let lang     = substitute(dictfile,'^.*[/\\]\(.*\)spchk.dict','\1','e')
"       call Decho("lang<".lang."> dictfile<".dictfile."> dictfiles<".dictfiles.">")
       if lang != b:spchklang
       	let Lang   = substitute(lang,'\(.\)\(.*\)','\u\1\2','e')
        exe 'menu '.g:DrChipTopLvlMenu.'Load\ AltLang\ Spelling\ Checker.Load\ As\ '.Lang.'spchk :call <SID>SpchkAltLang("'.lang.'")'."<cr>"
       endif
      endwhile
     endif
	else
	 exe 'unmenu '.g:DrChipTopLvlMenu.'Load\ AltLang\ Spelling\ Checker'
	endif

"    call Dret("AltLangMenus")
  endfun

  " ---------------------------------------------------------------------
  " SpchkAltLang: initial loading of an alternate dictionary
  fun! s:SpchkAltLang(lang)
"  	call Dfunc("SpchkAltLang(lang<".a:lang.">")

  	let g:spchklang= a:lang
  	let g:Spchklang= substitute(a:lang,'^\(.\)\(.*\)$','\u\1\2','e')
	call s:LoadSpchk()
	call s:AltLangMenus(0)

"	call Dret("SpchkAltLang")
  endfun

  " ---------------------------------------------------------------------
  " set up DrChipTopLevelMenu {{{2
 if exists("did_install_default_menus") && has("menu")
  if !exists("g:DrChipTopLvlMenu") || g:DrChipTopLvlMenu == ""
   let g:DrChipTopLvlMenu= "DrChip."
  endif
  exe 'menu '.g:DrChipTopLvlMenu.'Load\ Spelling\ Checker<tab>'.s:mapleadstring.'ec	<Leader>ec'
  call s:AltLangMenus(1)
 endif

 finish  " end pre-load
endif

" ================================
" Begin Main Loading of Engspchk {{{1
" ================================

" ---------------------------------------------------------------------
"  SpchkModeline: analyzes current line for a spchk: modeline {{{2
fun! s:SpchkModeline()
  let curline= getline(".")
"  call Dfunc("SpchkModeline() <".curline.">")
  let curline = substitute(curline,'^.*spchk:\s*','','')
  while curline != ""
"   call Decho("curline<".curline.">")
   let curopt  = "b:spchk".substitute(curline,'^\([bg]:\)\=\(spchk\)\=\(\a\+\)=.*$','\3','e')
   let curval  = substitute(curline,'^\a\+=\(\S*\).*$','\1','')
   exe "let ".curopt.'="'.curval.'"'
"   call Decho("setting ".curopt.'="'.curval.'"')
   let curline= substitute(curline,'^[^: \t]\+:\=\s*\(.*\)$','\1','e')
  endwhile
"  call Dret("SpchkModeline")
endfun

" ---------------------------------------------------------------------
" SpchkSavePosn: save current cursor position {{{2
fun! s:SpchkSavePosn()
"  call Dfunc("SpchkSavePosn()")
  let swline    = line(".")
  let swcol     = col(".")
  let swwline   = winline() - 1
  let swwcol    = virtcol(".") - wincol()
  let b:spchksaveposn = "silent! ".swline
  let b:spchksaveposn = b:spchksaveposn."|silent norm! z\<cr>"
  let b:spchksaveposn = b:spchksaveposn.":silent! norm! zO\<cr>"
  if swwline > 0
   let b:spchksaveposn= b:spchksaveposn.":silent norm! ".swwline."\<c-y>\<cr>"
  endif
  let b:spchksaveposn = b:spchksaveposn.":silent call cursor(".swline.",".swcol.")\<cr>"
  if swwcol > 0
   let b:spchksaveposn= b:spchksaveposn.":silent norm! ".swwcol."zl\<cr>"
  endif
"  call Decho("SpchkSavePosn: swline=".swline." swcol=".swcol." swwline=".swwline." swwcol=".swwcol)
"  call Dret("SpchkSavePosn : saveposn<".b:spchksaveposn.">")
endfun

" ---------------------------------------------------------------------
" SpchkRestorePosn: restore cursor position {{{2
fun! s:SpchkRestorePosn()
"  call Dfunc("SpchkRestorePosn() restoring cursor position")
  if exists("b:spchksaveposn")
"   call Decho("spchksaveposn<".b:spchksaveposn.">")
   exe b:spchksaveposn
   " seems to be something odd: vertical motions after RWP
   " cause jump to first column.  Following fixes that
   if wincol() > 1
    silent norm! hl
   elseif virtcol(".") < virtcol("$")
    silent norm! lh
   endif
  endif
"  call Dret("SpchkRestorePosn")
endfun

" ---------------------------------------------------------------------
" Process modelines from top and bottom of file, if any {{{2
if &mls > 0
 call s:SpchkSavePosn()
 let lastline    = line("$")
 let lastlinemls = (lastline < &mls)? lastline : &mls

 " look for spchk: lines at top-of-file
 exe "silent 1,".lastlinemls.'g/\<spchk:/call s:SpchkModeline()'

 let lastlinemls = lastline - &mls
 let lastlinemls = (lastlinemls < &mls)?     &mls + 1 : lastlinemls
 let lastlinemls = (lastlinemls > lastline)? lastline : lastlinemls

 " look for spchk: lines at bottom-of-file
 exe "silent ".lastlinemls.",".lastline.'g/\<spchk:/call s:SpchkModeline()'
 call s:SpchkRestorePosn()
endif

" ---------------------------------------------------------------------
" default values for global engspchk option variables: {{{2
if g:cvimsyn == ""
 if expand('$HOME') == ""
  if has("win32") || has("win64") || has("win95")
   let g:cvimsyn= 'c:\.vim\CVIMSYN'
  endif
 else
  let g:cvimsyn= expand('$HOME')."/.vim/CVIMSYN"
 endif
endif

" ---------------------------------------------------------------------
" Convert global to local variables {{{2
let b:spchkaltright    = exists("g:spchkaltright")?    g:spchkaltright    : 0
let b:spchkacronym     = exists("g:spchkacronym")?     g:spchkacronym     : 0
let b:cvimsyn          = exists("g:cvimsyn")?          g:cvimsyn          : $CVIMSYN
let b:DrChipTopLvlMenu = exists("g:DrChipTopLvlMenu")? g:DrChipTopLvlMenu : ""
let b:spchkautonext    = exists("g:spchkautonext")?    g:spchkautonext    : 0
let b:spchkdialect     = exists("g:spchkdialect")?     g:spchkdialect     : "usa"
let b:spchknonhl       = exists("g:spchknonhl")?       g:spchknonhl       : 0
let b:spchkmouse       = exists("g:spchkmouse")?       g:spchkmouse       : 0
let b:spchkpunc        = exists("g:spchkpunc")?        g:spchkpunc        : 0
let b:spchksilent      = exists("g:spchksilent")?      g:spchksilent      : 0
let b:spchkproj        = exists("g:spchkproj")?        g:spchkproj        : ""

" ---------------------------------------------------------------------

" report on sourcing of (which language)spchk.vim: {{{2
if !b:spchksilent
 echomsg "Sourcing <".b:spchklang."spchk.vim>  (version ".s:spchkversion.")"
endif

" remove "Load Spelling Checker" from menu {{{2
if exists("did_install_default_menus") && has("menu")
 " remove \ec from DrChip menu
 silent! exe 'unmenu '.b:DrChipTopLvlMenu.'Load\ Spelling\ Checker'
endif

" check if syntax highlighting is on and, if it isn't, enable it {{{2
if !exists("syntax_on")
 if !has("syntax")
  echomsg "Your version of vim doesn't have syntax highlighting support"
  finish
 endif
 echomsg "Enabling syntax highlighting"
 syn enable
endif

" ---------------------------------------------------------------------

" HLTEST: tests if a highlighting group has been set up {{{2
fun! s:HLTEST(hlname)
  let id_hlname= hlID(a:hlname)
  let fg_hlname= synIDattr(synIDtrans(hlID(a:hlname)),"fg")
  if id_hlname == 0 || fg_hlname == 0 || fg_hlname == -1
   return 0
  endif
  return 1
endfun

" ---------------------------------------------------------------------

" check if user has specified a Dialect highlighting group.
" If not, this script will highlight-link it to a Warning highlight group.
" If that hasn't been defined, then this script will define it.
if !s:HLTEST("Dialect")
 if !s:HLTEST("Warning")
  hi Warning term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=yellow guifg=black guibg=yellow
 endif
 hi link Dialect Warning
endif

" check if user has specified a RareWord highlighting group
" If not, this script will highlight-link it to a Warning highlight group.
" If that hasn't been defined, then this script will define it.
if  !<SID>HLTEST("RareWord")
 if !<SID>HLTEST("Warning")
  hi Notice term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=cyan guifg=black guibg=cyan
 endif
 hi link RareWord Notice
endif

" ---------------------------------------------------------------------

" SaveMap: this function sets up a buffer-variable (b:spchk_restoremap) {{{1
"          which will be used by StopDrawIt to restore user maps
"          mapchx: either <something>  which is handled as one map item
"                  or a string of single letters which are multiple maps
"                  ex.  mapchx="abc" and maplead='\': \a \b and \c are saved
fun! <SID>SaveMap(mapmode,maplead,mapchx)
  " save <Leader>map
  if maparg(a:maplead.a:mapchx,a:mapmode) != ""
    let b:spchk_restoremap= a:mapmode."map ".a:maplead.a:mapchx." ".maparg(a:maplead.a:mapchx,a:mapmode)."|".b:spchk_restoremap
    exe a:mapmode."unmap ".a:maplead.a:mapchx
   endif
endfunction

" ---------------------------------------------------------------------
"  User Interface: {{{1
let b:spchk_restoremap= ""
call <SID>SaveMap("n",s:usermaplead,"ea")
call <SID>SaveMap("n",s:usermaplead,"ed")
call <SID>SaveMap("n",s:usermaplead,"ee")
call <SID>SaveMap("n",s:usermaplead,"en")
call <SID>SaveMap("n",s:usermaplead,"ep")
call <SID>SaveMap("n",s:usermaplead,"et")
call <SID>SaveMap("n",s:usermaplead,"eT")
call <SID>SaveMap("n",s:usermaplead,"es")
call <SID>SaveMap("n",s:usermaplead,"eS")

" Maps to facilitate entry of new words {{{2
"  use  temporarily (\et)   remove temporarily (\eT)
"  save permanently (\es)   remove permanently (\eS)
nmap <silent> <Leader>et :syn case ignore<CR>:exe "syn keyword GoodWord transparent	" . expand("<cword>")<CR>:syn case match<CR>:if b:spchkautonext<BAR>call <SID>SpchkNxt(1)<BAR>endif<CR>
nmap <silent> <Leader>eT :syn case ignore<CR>:exe "syn keyword BadWord "	  . expand("<cword>")<CR>:syn case match<CR>

" \es: saves a new word to a user dictionary (b:cvimsyn/engspchk.usr). {{{2
"      Uses vim-only functions to do save, thereby avoiding external programs
nmap <silent> <Leader>es    :call <SID>SpchkSave(expand("<cword>"))<CR>
nmap <silent> <Leader>eS    :call <SID>SpchkRemove(expand("<cword>"))<CR>

" \ed: toggle between Dialect->Warning/Error {{{2
" \ee: end engspchk
nmap <silent> <Leader>ed	:call <SID>SpchkToggleDialect()<CR>
nmap <silent> <Leader>er	:call <SID>SpchkToggleRareWord()<CR>
nmap <silent> <Leader>ee	:call <SID>SpchkEnd()<CR><bar>:redraw!<CR>

" mouse stuff: {{{2
if b:spchkmouse > 0
 if &mouse !~ '[na]'
  " insure that the mouse will work with Click-N-Fix
  set mouse+=n
 endif
 call <SID>SaveMap("n","","<leftmouse>")
 call <SID>SaveMap("n","","<rightmouse>")
 nnoremap <silent> <leftmouse>    <leftmouse>:call <SID>SpchkMouse(0)<CR>
 nnoremap <silent> <middlemouse>  <leftmouse>:call <SID>SpchkMouse(1)<CR>
 nnoremap <silent> <rightmouse>   <leftmouse>:call <SID>SpchkRightMouse()<CR>
 " insure that the paste buffer has nothing in it
 let @*=""
endif

" ---------------------------------------------------------------------
" DrChip Menu {{{2
if exists("did_install_default_menus") && has("menu")
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Alternative\ spellings<tab>'.s:mapleadstring.'ea		'.s:usermaplead.'ea'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ next\ spelling\ error<tab>'.s:mapleadstring.'en	'.s:usermaplead.'en'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ previous\ spelling\ error<tab>'.s:mapleadstring.'ep	'.s:usermaplead.'ep'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'et	'.s:usermaplead.'et'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'es	'.s:usermaplead.'es'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'eT	'.s:usermaplead.'eT'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'eS	'.s:usermaplead.'eS'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Dialect:\ toggle\ Warning/Error\ highlighting<tab>'.s:mapleadstring.'ed	'.s:usermaplead.'ed'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.RareWord:\ toggle\ Warning/Error\ highlighting<tab>'.s:mapleadstring.'er	'.s:usermaplead.'er'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Load\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ec		'.s:usermaplead.'ec'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.End\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ee		'.s:usermaplead.'ee'
 exe 'menu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Help<tab>\ 		:help engspchk<cr>'
endif

" ---------------------------------------------------------------------

" IGNORE CASE
syn case ignore

" Language Specials {{{2
" Ignore upper/lower case
" For non-English, allow accented (8-bit) characters as keywords
if b:spchklang !=? "^eng"
 setlocal isk=45,48-57,_,65-90,_,97-122,128-255

elseif b:spchkpunc != 0
 " These patterns are thanks to Steve Hall
 " Flag as error a non-capitalized word after ellipses
 syn match GoodWord	"\.\.\. \{0,2}\l\@="
 " but not non-capitalized word after ellipses plus period
 syn match BadWord "\.\.\.\. \{0,2}\l"

 " non-lowercased end-of-word problems
 " required: period/question-mark/exclamation-mark
 " optional: double/single quote
 " required: return/return-linefeed/space/two spaces
 " required: lowercase letter
 syn match BadWord "[.?!][\"']\=[\r\n\t ]\+\l"
endif

" ---------------------------------------------------------------------
" Find Dictionary Path: {{{2

if b:cvimsyn == ""
 echoerr 'Please set either g:cvimsyn (vim) or $CVIMSYN (environment)'
 exit
endif

"call Decho("attempt to find dictionaries: spchklang<".b:spchklang.">")
"call Decho("trying <".b:cvimsyn."/".b:spchklang."spchk.dict>")
if !filereadable(b:cvimsyn."/".b:spchklang."spchk.dict")
 let b:cvimsyn= expand(b:cvimsyn)

" call Decho("trying <".b:cvimsyn."/".b:spchklang."spchk.dict>")
 if !filereadable(b:cvimsyn."/".b:spchklang."spchk.dict")
  let rtp= &rtp

  " search runtimepath
  while rtp != ""
   " get leftmost path from rtp
   let b:cvimsyn= substitute(rtp,',.*$','','')."/CVIMSYN"
"   call Decho("setting b:cvimsyn<".b:cvimsyn.">")

   " remove leftmost path from rtp
   if stridx(rtp,',') == -1
    let rtp= ""
   else
    let rtp= substitute(rtp,'.\{-},','','e')
   endif

   " see if dictionary is readable
"   call Decho("trying <".b:cvimsyn."/".b:spchklang."spchk.dict>")
   if filereadable(b:cvimsyn."/".b:spchklang."spchk.dict")
    break
   else
    " attempt to expand and see if dictionary is readable then
    let b:cvimsyn= expand(b:cvimsyn)
"    call Decho("trying <".b:cvimsyn."/".b:spchklang."spchk.dict>")
    if filereadable(b:cvimsyn."/".b:spchklang."spchk.dict")
     break
	else
	 let b:cvimsyn= ""
    endif
   endif
  endwhile
 endif

 " sanity check
 if !exists("b:cvimsyn") || b:cvimsyn == ""
  echoerr 'engspchk unable to find dictionaries (see g:cvimsyn or $CVIMSYN)'
  finish
 endif
endif
"call Decho("final b:cvimsyn<".b:cvimsyn.">")

" ---------------------------------------------------------------------

" Detect whether BadWords should be detected/highlighted inside comments. {{{1
" This can be done only for those syntax files' comment blocks that
" contains=@cluster.  The code below adds GoodWord and BadWord to various
" clusters.  If your favorite syntax comments are not included, send a note
let s:incomment= 0
if     &ft == "amiga"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "bib"
  syn cluster bibVarContents     	contains=GoodWord,BadWord
  syn cluster bibCommentContents 	contains=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "c" || &ft == "cpp"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "csh"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "dcl"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "fortran"
  syn cluster fortranCommentGroup	add=GoodWord,BadWord
  syn match   fortranGoodWord contained	"^[Cc]\>"
  syn cluster fortranCommentGroup	add=fortranGoodWord
  hi link fortranGoodWord fortranComment
  let s:incomment=1
elseif &ft == "sh" || &ft == "ksh" || &ft == "bash"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "tex"
  syn cluster Spell		add=GoodWord,BadWord
  syn cluster texMatchGroup		add=GoodWord,BadWord
  let s:incomment=2
elseif &ft == "vim"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
endif
"call Decho("s:incomment=".s:incomment." ft=".&ft)

" attempt to infer spellcheck use - is the Spell cluster included somewhere?
if s:incomment == 0
 fun! <SID>ChkForCluster(cname)
"  call Dfunc("ChkForCluster(cname<".a:cname.">)")
  let keep_rega= @a
  redir @a
  exe "syn list @".a:cname
  redir END
  if match(@a,"E392") != -1
   let has_cluster= 0
  elseif match(@a,"No Syntax items defined") != -1
   let has_cluster= 0
  else
   let has_cluster= 1
  endif
  let @a= keep_rega
"  call Dret("ChkForCluster has_cluster<".a:cname.">=".has_cluster)
  return has_cluster
 endfun

 silent! let has_cluster= s:ChkForCluster("Spell")
 if has_cluster
"  call Decho("inferred @Spell: add GoodWord,BadWord to Spell cluster")
  syn cluster Spell				add=GoodWord,BadWord
  let s:incomment=1
 else
"  call Decho("@Spell not used")
 endif
 silent! has_cluster= ChkForCluster("texMatchGroup")
 if has_cluster
  syn cluster texMatchGroup		add=GoodWord,BadWord
 endif
 unlet has_cluster
 delfun <SID>ChkForCluster
endif

" ========================
" Loading The Dictionaries {{{1
" ========================

" ---------------------------------------------------------------------
" SpchkLoadDictionary: this function loads the specified dictionary {{{2
"     reqd=0          not required      (no error message if not present)
"         =1          check if writable (not required)
"         =2          required          (merely gives error message)
"     lang="eng" etc  language of dictionary
"     dict="dict"     main dictionary
"         ="rare"     rarewords dictionary
"         ="dialect"  dialect dictionary
"         ="usr"      user's personal dictionary
"         ="proj"     project-specific dictionary
"
"         This function will first set "syn case ignore".  However,
"         the dictionary file itself may override this with a
"         leading "syn case match".
fun! s:SpchkLoadDictionary(reqd,lang,dict)
"  call Dfunc("SpchkLoadDictionary(reqd=".a:reqd." lang<".a:lang."> dict<".a:dict.">")
"  let loadtime= localtime()		" Decho

  " set up short and long names
  let shortname= a:lang."spchk.".a:dict
  let fullname = b:cvimsyn."/".shortname
"  call Decho("shortname<".shortname.">")
"  call Decho("fullname <".fullname.">")

  " preferentially load from current directory
  if filereadable(shortname)
   let fullname= shortname
"   call Decho("will load <".fullname."> from current directory")
  endif

  " check if dictionary is readable
  if filereadable(fullname) > 0
   if !b:spchksilent
    echomsg "Loading  <".shortname.">"
   endif
   syn case ignore
   exe "so ".fullname
   if a:reqd == 1
   	" check if writable
    if !filewritable(fullname)
     echomsg "***warning*** ".fullname." isn't writable"
    endif
   endif

  elseif a:reqd == 2
   if !filereadable(b:cvimsyn)
    echomsg "***warning*** ".b:cvimsyn."/ directory is not readable"
   else
    echomsg "***warning*** cannot read <".fullname.">"
   endif
  endif

"  let difftime= localtime() - loadtime	" Decho
"  call Dret("SpchkLoadDictionary ".shortname." : took ".difftime." seconds")
endfun

" ---------------------------------------------------------------------

" Load dictionaries {{{2
"  in reverse order of priority
call s:SpchkLoadDictionary(0,b:spchklang,"proper")
call s:SpchkLoadDictionary(0,b:spchklang,"rare")
call s:SpchkLoadDictionary(0,b:spchklang,"dialect")
call s:SpchkLoadDictionary(0,b:spchklang,"proj")
call s:SpchkLoadDictionary(1,b:spchklang,"usr")
call s:SpchkLoadDictionary(2,b:spchklang,"dict")

" Resume Case Sensitivity
syn case match

" ---------------------------------------------------------------------

" The Raison D'Etre! Highlight the BadWords {{{2
" I've allowed '`- in non-English words
"
"    s:incomment
"        0       BadWords matched outside normally highlighted sections
"        1       BadWords matched inside @Spell, etc highlighting clusters
"        2       both #0 and #1
if s:incomment == 0 || s:incomment == 2 || b:spchknonhl
 if b:spchklang == "eng"
  syn match BadWord	"\<[^[:punct:][:space:][:digit:]]\{2,}\>"	 contains=RareWord,Dialect
 else
  syn match BadWord	"\<[^[!@#$%^&*()_+=[\]{};:",<>./?\\|[:space:][:digit:]]\{2,}\>" contains=RareWord,Dialect
 endif
endif
if s:incomment == 1 || s:incomment == 2
 if b:spchklang == "eng"
  syn match BadWord contained	"\<[^[:punct:][:space:][:digit:]]\{2,}\>"	 contains=RareWord,Dialect
  syn cluster Spell add=Dialect,RareWord
 else
  syn match BadWord contained	"\<[^[!@#$%^&*()_+=[\]{};:",<>./?\\|[:space:][:digit:]]\{2,}\>" contains=RareWord,Dialect
 endif
endif

" English-only exceptions: contractions and other language special handling {{{2
if b:spchklang ==? "eng"
" call Decho("handle contractions, etc for ".b:spchklang)
 " Note: *matches* need to follow the BadWord so that they take priority!
 " Abbreviations, Possessives, Etc.  For these to be recognized properly,
 " these contractions' word prior to the "'" has been removed from the
 " keyword dictionaries above and moved here.
 syn case ignore
 syn match GoodWord "\<\(you\|he\|it\|ne\|we\|a\|i\|o\)\>"
 syn match GoodWord "\<\(e'er\|he'd\|howe\|i'll\|i've\|must\|need\|o'er\|shan\|they\|what\|are\|can\|cap\|don\|i'm\|may\|she\|who\|won\)\>"
 syn match GoodWord "\<\(could\|don't\|haven\|isn't\|might\|ne'er\|ought\|shall\|there\|we'll\|we're\|we've\|where\|won't\|would\|you'd\)\>"
 syn match GoodWord "\<\(ch'ing\|didn't\|hasn't\|i'd\('ve\)\=\|may've\|should\|wasn't\|who've\|you'll\|you're\|you've\|ain't\|cap'n\)\>"
 syn match GoodWord "\<\(it'd've\|must've\|there'd\|they'll\|they're\|they've\|we'd\('ve\)\=\|weren't\|what'll\|what've\|aren't\)\>"
 syn match GoodWord "\<\(there'll\|there've\|where've\|won't've\|would've\|you'd've\|daren't\|doesn't\|haven't\|he'd've\|howe'er\)\>"
 syn match GoodWord "\<\(can't\('ve\)\=\|could've\|s\=he'll\('ve\)\=\|might've\|ought've\|oughtn't\|shall've\|she'd\('ve\)\=\)\>"
 syn match GoodWord "\<\(needn't\('ve\)\=\|hadn't\('ve\)\=\|mayn't\('ve\)\=\|shan't\('ve\)\=\|should've\|they'd\('ve\)\=\)\>"
 syn match GoodWord	"\<\(shouldn't\('ve\)\=\|couldn't\('ve\)\=\|mightn't\('ve\)\=\|wouldn't\('ve\)\=\|mustn't\('ve\)\=\)\>"
 syn match GoodWord	"\(et al\|ph\.d\|e\.g\|i\.e\|mrs\|dr\|ex\|jr\|mr\|ms\|mba\|pm\)\."
 syn match GoodWord	"ex-"
 syn match GoodWord	"'s\>"
 let b:spchkacronym= 1

 " These are proper English words but vim has assigned special meaning to them,
 " so they may not be used in keyword lists
 syn match GoodWord	"\<\(transparent\|contained\|contains\|conceal\|display\|extend\|fold\|skip\)\>"
 syn case match
endif

" Acronymns {{{2
if b:spchkacronym
 " Pan Shizhu suggested that two or more capitalized letters
 " should be treated as an abbreviation and accepted
 syn match GoodWord	"\<\u\{2,}\>"
endif

" Allows <engspchk.vim> to work better with LaTeX {{{2
if &ft == "tex"
"  call Decho("ft==tex: more GoodWords")
  syn match GoodWord	"{[a-zA-Z|@]\+}"lc=1,me=e-1
  syn match GoodWord	"\[[a-zA-Z]\+]"lc=1,me=e-1
  syn match texGoodWord	"\\[a-zA-Z]\+"lc=1,me=e-1	contained
  hi link texGoodWord texComment
  syn cluster texCommentGroup	add=texGoodWord
endif

" Ignore web addresses and \n for newlines {{{2
syn match GoodWord transparent	"\<http://www\.\S\+"
syn match GoodWord transparent	"\\n"

" BadWords are highlighted with Error highlighting (by default) {{{2
"   Colorschemes, such as navajo-night, may define BadWord to
"   be something other than Error.  Hence engspchk will clear
"   that setting first.
hi clear BadWord
hi link BadWord Error

" ==================================================
" Support Functions: {{{1
" ==================================================

" SpchkSave: {{{2
fun! <SID>SpchkSave(newword)
"  call Dfunc("SpchkSave(newword<".a:newword.">)")
  silent 1sp
  exe "silent e ".b:cvimsyn."/".b:spchklang."spchk.usr"
  $put='syn keyword GoodWord transparent	'.a:newword
  let un= bufnr(".")
  silent wq
  if bufexists(un)
   exe "silent bw ".un
  endif
  syn case ignore
  exe "syn keyword GoodWord transparent ".a:newword
  syn case match
  if b:spchkautonext
   call s:SpchkNxt(0)
  endif
"  call Dret("SpchkSave")
endfun

" ---------------------------------------------------------------------

" SpchkRemove: implements \eS : depends on SpchkSave's putting one {{{2
"              user word per line in <*spchk.usr>.  This function
"              actually will delete the entire line containing the
"              new BadWord.
fun! <SID>SpchkRemove(killword)
  silent 1sp
  exe "silent e ".b:cvimsyn."/".b:spchklang."spchk.usr"
  exe "silent g/".a:killword."/d"
  silent wq
  syn case ignore
  exe "syn keyword BadWord ".a:killword
  syn case match
endfun
nmap <silent> <Leader>en	:call <SID>SpchkNxt(1)<CR>
nmap <silent> <Leader>ep	:call <SID>SpchkPrv(1)<CR>

" ignores people's middle-name initials
syn match   GoodWord	"\<[A-Z]\."

" -------------------------------------------------------------------
" SpchkNxt: calls this function to search for next spelling error (\en) {{{2
fun! <SID>SpchkNxt(autofix)
"  call Dfunc("SpchkNxt(autofix=".a:autofix.")")
  if a:autofix == 1 && exists("b:spchksaveposn")
   unlet b:spchksaveposn
  endif
"  call Decho("SpchkNxt(".a:autofix.")")
  let lastline = line("$")
  let curcol   = 0
  let fenkeep  = &fen
  set nofen
  silent! norm! w

  " skip words until we find next error
  while synIDtrans(synID(line("."),col("."),1)) != s:errid
    silent! norm! w
    if line(".") == lastline
      let prvcol = curcol
      let curcol = col(".")
      if curcol == prvcol
	   echo "at end-of-file"
"	   call Decho("at end-of-file")
       break
      endif
    endif
  endwhile

  " cleanup
  let &fen= fenkeep
  if foldlevel(".") > 0
   norm! zO
  endif
  unlet curcol
  unlet lastline
  if exists("prvcol")
    unlet prvcol
  endif
"  call Dret("SpchkNxt : <".expand("<cword>").">")
endfunction

" -------------------------------------------------------------------
" SpchkPrv: calls this function to search for previous spelling error (\ep) {{{2
fun! <SID>SpchkPrv(autofix)
"  call Dfunc("SpchkPrv(autofix=".a:autofix.")")
  if a:autofix == 1 && exists("b:spchksaveposn")
   unlet b:spchksaveposn
  endif
  let curcol  = 0
  let fenkeep = &fen
  set nofen

  silent! norm! ge

  " skip words until we find previous error
  while synIDtrans(synID(line("."),col("."),1)) != s:errid
"call Decho("SpchkPrv: word<".expand("<cword>")."> hl=".synIDtrans(synID(line("."),col("."),1))." errid=".s:errid)
    norm! b
    if line(".") == 1
      let prvcol = curcol
      let curcol = col(".")
      if curcol == prvcol
	   echo "at beginning-of-file"
       break
      endif
    endif
  endwhile
"call Decho("SpchkPrv: word<".expand("<cword>")."> hl=".synIDtrans(synID(line("."),col("."),1))." errid=".s:errid)

  " cleanup
  let &fen= fenkeep
  if foldlevel(".") > 0
   norm! zO
  endif
  unlet curcol
  if exists("prvcol")
    unlet prvcol
  endif
"  call Dret("SpchkPrv : <".expand("<cword>").">")
endfunction

map <silent> <Leader>ea :call <SID>SpchkAlternate(expand("<cword>"))<CR>

" -----------------------------------------------------------------

" Prevent error highlighting while one is typing {{{2
" Chase Tingley implemented \%# which is used to forestall
" Error highlighting of words while one is typing them.
syn match GoodWord "\<\k\+\%#\>"
syn match GoodWord "\<\k\+'\%#"

" -----------------------------------------------------------------

" BuildWordlist: Build the <engspchk.wordlist>
fun! s:BuildWordlist(cvimsyn,lang,dict)
" call Dfunc("BuildWordlist(lang<".a:lang."> dict<".a:dict.">")

  " set up short and long names
  let shortname= a:lang."spchk.".a:dict
  let fullname = a:cvimsyn."/".shortname

  " preferentially load from current directory
  if filereadable(shortname)
   let fullname= shortname
"  call Decho("will build wordlist with <".fullname.">")
  endif
  if filereadable(fullname)
   exe "silent 0r ".fullname
  endif
" call Dret("BuildWordlist")
endfun

" ---------------------------------------------------------------------
" SpchkAlternate: handle words that are close in spelling {{{2
fun! <SID>SpchkAlternate(wrd)
"  call Dfunc("SpchkAlternate(wrd<".a:wrd.">)")

  " can't provide alternative spellings without agrep
  if !executable("agrep")
   echoerr "engspchk: needs agrep for alternative spellings support"
"   call Dret("SpchkAlternate : needs agrep")
   return
  endif
"  call Decho("agrep is executable")

  " because SpchkAlternate switches buffers to an "alternate spellings"
  " window, the various b:... variables will no longer be available, but
  " they're still needed!
  let spchklang     = b:spchklang
  let cvimsyn       = b:cvimsyn
  let spchkaltright = b:spchkaltright
  let spchkdialect  = b:spchkdialect
  let s:iskkeep     = &isk
"  call Decho("options: lang<".spchklang."> cvimsyn<".cvimsyn."> altright=".spchkaltright." dialect<".spchkdialect.">")

  silent! set isk-=#
  if exists("g:spchkwholeword")
"   call Decho("using g:spchkwholeword=".g:spchkwholeword)
   exe "match PreProc '\\%".line(".")."l\\%".col('.')."c\\k\\+'"
  else
"   call Decho("not using g:spchkwholeword=".g:spchkwholeword)
   exe "match PreProc '\\%".line(".")."l\\%".col('.')."c'"
  endif

  if exists("s:spchkaltwin")
"	call Decho("| re-use wordlist in alternate window")
    let s:winnr= winnr()
    " re-use wordlist in bottom window
	if spchkaltright > 0
     exe "norm! \<c-w>bG"
	 %d
	 put! ='Alternates for'
	 2d
	 put =' <'.a:wrd.'>'
	else
     exe "norm! \<c-w>bG0DAAlternate<".a:wrd.">: \<Esc>"
	endif

  elseif filereadable(cvimsyn."/".spchklang."spchk.wordlist")
    " utilize previously generated <engspchk.wordlist>
"	call Decho("| utilize previously generated ".spchklang."spchk.wordlist")

    " Create a one line window to hold dictionaries during conversion
    let s:winnr= winnr()
	if spchkaltright > 0
     exe "vertical bo ".spchkaltright."new"
	else
     bo 1new
    endif
    let s:spchkaltwin= bufnr("%")
    setlocal lz bt=nofile nobl noro noswapfile
	if spchkaltright > 0
	 wincmd b
	 %d
	 put! ='Alternates for'
	 2d
	 put =' <'.a:wrd.'>'
	else
	 setlocal winheight=1
     exe "norm! \<c-w>bG0DAAlternate<".a:wrd.">: \<Esc>"
	endif

  else
    " generate <engspchk.wordlist> from dictionaries
"	call Decho("| build wordlist")
    echo "Building <".spchklang."spchk.wordlist>"
    echo "This may take awhile, but it is a one-time only operation."
    echo "Please be patient..."

    " following avoids a problem on Macs with ffs="mac,unix,dos"
    let ffskeep= &ffs
    set ffs="unix,dos"

    " Create a one line window to hold dictionaries during conversion
    let s:winnr= winnr()
	if spchkaltright > 0
"	 call Decho("creating ".spchkaltright."-column window on right")
     exe "vertical bo ".spchkaltright."new"
	else
"	 call Decho("creating one-line alternate-spelling window on bttm")
     bo 1new
	 setlocal winheight=1
    endif
    let s:spchkaltwin= bufnr("%")
    setlocal lz bt=nofile noswapfile nobl noro

    " for quicker operation
    "   turn off undo
    "   turn on lazy-update
    "   make a temporary one-line window
    let ulkeep= &ul
    let gdkeep= &gd
    set ul=-1 nogd

	call s:BuildWordlist(cvimsyn,spchklang,"dict")
	call s:BuildWordlist(cvimsyn,spchklang,"usr")
	call s:BuildWordlist(cvimsyn,spchklang,"proj")
	let firstline= line("$")
	call s:BuildWordlist(cvimsyn,spchklang,"dialect")
	put =
	let lastline = line("$")
	call s:BuildWordlist(cvimsyn,spchklang,"rare")
	call s:BuildWordlist(cvimsyn,spchklang,"proper")

	" remove non-selected dialect
"	call Decho("remove non-selected dialect")
	exe firstline.';/? "'.spchkdialect.'"/d'
	/^\(elseif\|endif\)/
	exe '.,'.lastline."d"

    " Remove non-dictionary lines and make it one word per line
	"   Keep RareWords
	"   Remove Dialect, comments, etc
"	call Decho("remove non-dictionary lines")
    echo "Doing conversion..."
	silent! %s/^syn\s*keyword\s*\zsRareWord/GoodWord/
    silent v/^syn keyword GoodWord \(transparent\|contained\)/d
    %s/^syn keyword GoodWord \(transparent\|contained\)\s\+//
"	call Decho("make it one word per line")
    silent! exe '%s/\s\+/\r/g'
	if executable("sort") && has("unix")
	 " if sort is available, run wordlist through it as a filter
	 echo "Sorting wordlist"
	 exe '%!sort'
	endif
    echo "Writing ".cvimsyn."/".spchklang."spchk.wordlist"
    exe "w! ".cvimsyn."/".spchklang."spchk.wordlist"
    silent %d
	" re-use same buffer for Alternate spellings
    silent exe "norm! $oAlternate<".a:wrd.">: \<Esc>"
	norm! 0
    let &ul = ulkeep
    let &ffs= ffskeep
    let &gd = gdkeep
  endif

  " set up local-to-alternate-window-only maps for <CR> and <tab> to invoke SpchkChgWord
  nnoremap <buffer> <silent> <CR>  :call <SID>SpchkChgWord(0)<CR>
  nnoremap <buffer> <silent> <tab> :call <SID>SpchkChgWord(1)<CR>

  " keep initial settings
  let s:keep_mod = &mod
  let s:keep_wrap= &wrap
  let s:keep_ic  = &ic
  let s:keep_lz  = &lz
  cnoremap  <silent> <buffer> q      :call <SID>SpchkExitChgWord()<CR>
  nnoremap  <silent> <buffer> q      :call <SID>SpchkExitChgWord()<CR>
  nnoremap  <silent> <buffer> :      :call <SID>SpchkExitChgWord()<CR>
  nnoremap  <silent> <buffer> <c-w>c :call <SID>SpchkExitChgWord()<CR>
  setlocal nomod nowrap ic nolz

  " let's add a wee bit of color...
  set lz
  syn match altLeader	"^Alternates\="
  syn match altAngle	"[<>]"
  hi def link altLeader	Statement
  hi def link altAngle	Delimiter

  " set up path+wordlist
  let wordlist= cvimsyn."/".spchklang."spchk.wordlist"
  if &term == "win32" && !filereadable(wordlist)
   let wordlist= substitute(wordlist,'/','\\','g')
  else
   let wordlist= substitute(wordlist,'\\','/','g')
  endif

  " Build patterns based on permutations of up to 3 letters
  exe "silent norm! \<c-w>b"
  if (spchklang ==? "eng" || spchklang==? "ger") && strlen(a:wrd) > 2
   let agrep_opt= "-S2 "
  else
   let agrep_opt= " "
  endif
  if &term == "win32"
   let agrep_opt= agrep_opt."-V0 "
  else
   let agrep_opt= agrep_opt." "
  endif
  " if German and first char is capitalized: case sensitive search
  if spchklang !=? "ger" || match(a:wrd, '\u') == -1
   let agrep_opt= agrep_opt." -i "
  endif
  if strlen(a:wrd) > 2
   " agrep options:  -2  max qty of errors permitted in finding approx match
   "                 -i  case insensitive search enabled
   "                 -w  search for pattern as a word (surrounded by non-alpha)
   "                 -S2 set cost of a substitution to 2
"    call Decho("running: agrep -2 -i -w ".agrep_opt."\"".a:wrd."\" \"".wordlist."\"")
    exe  "silent r! agrep -2 -i -w ".agrep_opt."\"".a:wrd."\" \"".wordlist."\""
  else
   " handle two-letter words
"   call Decho("running: agrep -1 -i -w ".agrep_opt."\"".a:wrd."\" \"".wordlist."\"")
   exe "silent r! agrep -1 -i -w ".agrep_opt."\"".a:wrd."\" \"".wordlist."\""
  endif
  if spchkaltright > 0
   3
  else
   silent %j
   silent norm! 04w
  endif
  setlocal nomod
  set nolz
"  call Dret("SpchkAlternate")
endfun

" ---------------------------------------------------------------------

" SpchkChgWord: {{{2
fun! <SID>SpchkChgWord(allfix)
"  call Dfunc("SpchkChgWord(allfix=".a:allfix.")")
  let reg0keep= @0
  norm! yiw
  let goodword= @0
"  call Decho("| goodword<".goodword.">")
  exe s:winnr."wincmd w"
  norm! yiw
  let badword=@0
  if col(".") == 1
   exe "norm! ea#\<Esc>b"
  else
   exe "norm! hea#\<Esc>b"
  endif
  norm! yl
  if match(@@,'\u') == -1
   " first letter not capitalized
   exe "norm! de\<c-w>blbye".s:winnr."\<c-w>wPlxb"
  else
   " first letter *is* capitalized
   exe "norm! de\<c-w>blbye".s:winnr."\<c-w>wPlxb~h"
  endif
  exe "silent norm! \<c-w>b:silent q!\<cr>"
  exe "silent! ".s:winnr."winc w"
  if a:allfix == 1
   let gdkeep= &gd
   set nogd
   let g:keep="bad<".badword."> good<".goodword.">"
   exe "silent! %s/".badword."/".goodword."/ge"
   norm! ``
   let &gd= gdkeep
  endif
  unlet s:spchkaltwin
  let &wrap = s:keep_wrap
  let &ic   = s:keep_ic
  let &lz   = s:keep_lz
  let @0    = reg0keep
  let &isk  = s:iskkeep
  unlet s:keep_mod s:keep_wrap s:keep_ic s:keep_lz s:iskkeep
  if b:spchkautonext
   call s:SpchkNxt(0)
  endif
  match
"  call Dret("SpchkChgWord")
endfun

" ---------------------------------------------------------------------

" SpchkExitChgWord: restore options and exit from change-word window {{{2
fun! <SID>SpchkExitChgWord()
"  call Dfunc("SpchkExitChgWord()")
  unlet s:spchkaltwin
  let &mod  = s:keep_mod
  let &wrap = s:keep_wrap
  let &ic   = s:keep_ic
  let &lz   = s:keep_lz
  unlet s:keep_mod s:keep_wrap s:keep_ic s:keep_lz
  q!
  let &isk  = s:iskkeep
  unlet s:iskkeep
  match
  redraw!
"  call Dret("SpchkExitChgWord")
endfun

" ---------------------------------------------------------------------
" SpchkMouse: {{{2
fun! <SID>SpchkMouse(mode)
"  call Dfunc("SpchkMouse(mode=".a:mode.")")

  if exists("s:spchkaltwin") && bufnr("%") == s:spchkaltwin
   " leftmouse and alternate window exists: (cursor must be in alternate-words window)
   "              change word and open alternate-spelling window on new word
"   call Decho("SpchkMouse(mode=".a:mode.") in alternate-words window")
   call s:SpchkChgWord(0)
   if synIDtrans(synID(line("."),col("."),1)) == s:errid
    call s:SpchkAlternate(expand("<cword>"))
   endif

  else " cursor in non-alternate-words window
"   call Decho("SpchkMouse(mode=".a:mode.") in normal window")
   if exists("s:spchkaltwin")
"   	call Decho("but s:spchkaltwin exists")
	" move cursor to bottom/right window (ie. the change window)
   	wincmd b
    call s:SpchkExitChgWord()
   endif

   if     a:mode == 0
   	" leftmouse : go to next spelling error in sequence, irregardless of
	"             mouse-specified cursor position
"    call Decho("a:mode=".a:mode.": leftmouse")
    call s:SpchkRestorePosn()
	if exists("b:spchksaveposn")
     norm! w
	endif
	" following sequence safely puts cursor at beginning of word
	norm! "_yiw
    if synIDtrans(synID(line("."),col("."),1)) != s:errid
"	 call Decho("currently not on Error, use SpchkNxt(0)")
     call s:SpchkNxt(0)
    endif

   elseif a:mode == 1
   	" middlemouse : go to next spelling error from current cursor position
	"               as specified by the mouseclick
"    call Decho("a:mode=".a:mode.": middlemouse")
	norm! "_yiw
    if synIDtrans(synID(line("."),col("."),1)) != s:errid
"	 call Decho("currently not on Error, use SpchkNxt(0)")
     call s:SpchkNxt(0)
    endif

   elseif a:mode == 2
   	" rightmouse : go to previous spelling error
"    call Decho("a:mode=".a:mode.": rightmouse")
    call s:SpchkRestorePosn()
	norm! "_yiw
    call s:SpchkPrv(0)

   endif

   " save position, call SpchkAlternate() if already on Error word
   call s:SpchkSavePosn()
   if synIDtrans(synID(line("."),col("."),1)) == s:errid
    call s:SpchkAlternate(expand("<cword>"))
   endif
  endif

"  call Dret("SpchkMouse")
endfun

" ---------------------------------------------------------------------

" SpchkRightMouse: click with rightmouse while in the alternate-words window {{{2
"                  and all similarly misspelled words will be replaced with
"                  the selected alternate word
fun! <SID>SpchkRightMouse()
"  call Dfunc("SpchkRightMouse()")
  if exists("s:spchkaltwin") && bufnr("%") == s:spchkaltwin
   " rightmouse - cursor in alternate-words window, so change
   "              all words with current spelling error and
   "              alternate word
   call s:SpchkChgWord(1)
   if b:spchkautonext && synIDtrans(synID(line("."),col("."),1)) == s:errid
    call s:SpchkAlternate(expand("<cword>"))
   endif
  else
   call s:SpchkMouse(2)
  endif
"  call Dret("SpchkRightMouse")
endfun

" ---------------------------------------------------------------------

" SpchkToggleDialect: toggles Dialect being mapped to Warning/Error {{{2
fun! <SID>SpchkToggleDialect()
"  call Dfunc("SpchkToggleDialect()")
  let dialectid= synIDtrans(hlID("Dialect"))
  let warningid= synIDtrans(hlID("Warning"))

  if dialectid == warningid
   hi link Dialect Error
  elseif dialectid == s:errid
   hi link Dialect NONE
  else
   hi link Dialect Warning
  endif
"  call Dret("SpchkToggleDialect")
endfun

" ---------------------------------------------------------------------

" SpchkToggleRareWord: toggles RareWord being mapped to Warning/Error {{{2
fun! <SID>SpchkToggleRareWord()
"  call Dfunc("SpchkToggleRareWord()")
  let rarewordid = synIDtrans(hlID("RareWord"))
  let noticeid   = synIDtrans(hlID("Notice"))

  if rarewordid == noticeid
   hi link RareWord Error
"   call Decho("RareWord switching to Error-highlighting")
  elseif rarewordid == s:errid
   hi link RareWord NONE
"   call Decho("RareWord switching to no-highlighting")
  else
   hi link RareWord Notice
"   call Decho("RareWord switching to Notice-highlighting")
  endif
"  call Dret("SpchkToggleRareWord")
endfun

" ---------------------------------------------------------------------

" SpchkEnd: end engspchk highlighting for the current buffer {{{2
fun! <SID>SpchkEnd()
"  call Dfunc("SpchkEnd()")

  " prevent \ee from "unloading" a buffer where \ec wasn't run
  if !exists("b:engspchk_loaded")
"   call Dret("SpchkEnd")
   return
  endif

  " restore normal highlighting for the current buffer
  " Thanks to Gary Johnson: filetype detect occurs prior
  " to "unlet'ing" b:engspchk_loaded so that any filetype
  " plugins that attempt to load engspchk see that it
  " is still loaded at this point.
  syn clear
  filetype detect

  let &hidden            = b:hidden
  let s:engspchk_loadcnt = s:engspchk_loadcnt - 1
  unlet b:engspchk_loaded b:hidden

  " remove engspchk maps
  if s:engspchk_loadcnt <= 0
   let s:engspchk_loadcnt= 0

   nunmap <Leader>ee
   nunmap <Leader>et
   nunmap <Leader>eT
   nunmap <Leader>es
   nunmap <Leader>eS

   " restore user map(s), if any
   if b:spchk_restoremap != ""
    exe b:spchk_restoremap
    unlet b:spchk_restoremap
   endif

   " remove menu entries
   if has("gui_running") && has("menu")
"   	call Decho("remove menu entries")
    exe 'menu '.b:DrChipTopLvlMenu.'Load\ Spelling\ Checker<tab>'.s:mapleadstring.'ec	<Leader>ec'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Alternative\ spellings<tab>'.s:mapleadstring.'ea'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ next\ spelling\ error<tab>'.s:mapleadstring.'en'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ previous\ spelling\ error<tab>'.s:mapleadstring.'ep'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'et'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'es'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'eT'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'eS'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Dialect:\ toggle\ Warning/Error\ highlighting<tab>\ed'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.RareWord:\ toggle\ Warning/Error\ highlighting<tab>'.s:mapleadstring.'er'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Load\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ec'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.End\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ee'
    exe 'unmenu '.b:DrChipTopLvlMenu.b:Spchklang.'spchk.Help<tab>\ '
	call s:AltLangMenus(1)
   endif

   " enable subsequent re-loading of engspchk
   let s:loaded_{b:spchkfile}spchk= 1
  endif
"  call Dret("SpchkEnd")
endfun

" ---------------------------------------------------------------------

if !exists("s:spchklangfunc")
 " SpchkLang: implements changing language {{{2
 fun! <SID>SpchkLang(newlang)
   call s:SpchkEnd()
   let b:spchklang= substitute(a:newlang,"spchk.*$","","e")
   call s:LoadSpchk()
 endfun
 let s:spchklangfunc= 1
 com! -nargs=1 SpchkLang call <SID>SpchkLang(<f-args>)
endif

" ---------------------------------------------------------------------

" Modeline highlighting - ignore spchk: lines {{{1
syn match spchkModeline 	"^.*\<spchk:.*$"	contains=spchkML,spchkMLop
syn match spchkML			"\<spchk\>"			contained
syn match spchkMLop			"[:=]"				contained skipwhite nextgroup=spchkMLsetting
syn match spchkMLsetting	"\k\+"				contained contains=spchkMLoption
syn keyword spchkMLoption contained cvimsyn               acronym       autonext      mouse      punc        lang
syn keyword spchkMLoption contained DrChipTopLvlMenu      altright      dialect       nonhl      silent      proj
syn keyword spchkMLoption contained spchkcvimsyn          spchkacronym  spchkautonext spchkmouse spchkpunc   spchklang
syn keyword spchkMLoption contained spchkDrChipTopLvlMenu spchkaltright spchkdialect  spchknonhl spchksilent spchkproj
hi link spchkML			PreProc
hi link spchkMLop		Operator
hi link spchkMLoption	Identifier
hi link spchkModeline	Comment

"  Done Loading Message:   {{{1
if !b:spchksilent
" call Decho("Done Loading <".b:spchklang."spchk.vim>")
 echo "Done Loading <".b:spchklang."spchk.vim>"
endif

" vim: ts=4 fdm=marker
