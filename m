From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/20] fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:42 +0100
Message-ID: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, kernel-janitors@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org,
 linux@rasmusvillemoes.dk, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
 linux-mtd@lists.infradead.org, linux-pci@vger.kernel.org, joe@perches.com,
 linux-arm-kernel@lists.infradead.org
To: linux-wireless@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

These patches replace what appears to be a reference to the name of the
current function but is misspelled in some way by either the name of the
function itself, or by %s and then __func__ in an argument list.

// <smpl>
// sudo apt-get install python-pip
// sudo pip install python-Levenshtein
// spatch requires the argument --in-place

virtual after_start

@initialize:ocaml@
@@

let extensible_functions = ref ([] : string list)
let restarted = ref false

let restart _ =
  restarted := true;
  let it = new iteration() in
  it#add_virtual_rule After_start;
  Printf.eprintf "restarting\n";
  it#register()

@initialize:python@
@@
import re
from Levenshtein import distance
mindist = 1 // 1 to find only misspellings
maxdist = 2
ignore_leading = True

// ---------------------------------------------------------------------

@r0@
constant char [] c;
identifier f;
@@

f(...,c,...)

@script:ocaml@
c << r0.c;
f << r0.f;
@@

(if not !restarted then restart());
match Str.split_delim (Str.regexp "%") c with
  _::_::_ ->
    if not (List.mem f !extensible_functions)
    then extensible_functions := f :: !extensible_functions
| _ -> ()

// ---------------------------------------------------------------------

@r depends on after_start@
constant char [] c;
position p;
identifier f;
@@

f(...,c@p,...)

@script:python flt@
c << r.c;
p << r.p;
matched;
@@

func = p[0].current_element
wpattern = "[a-zA-Z_][a-zA-Z0-9_]*"
if ignore_leading:
   func = func.strip("_")
   wpattern = "[a-zA-Z][a-zA-Z0-9_]*"
lf = len(func)
cocci.include_match(False)
// ignore extremely short function names
if lf > 3:
   words = [w for w in re.findall(wpattern, c) if abs(len(w) - lf) <= maxdist]
   for w in words:
       d = distance(w, func) 
       if mindist <= d and d <= maxdist:
          coccinelle.matched = w
          cocci.include_match(True)
     	  //print "%s:%d:%s():%d: %s" % (p[0].file, int(p[0].line), func, d, c)
	  break

@script:ocaml r2@
c << r.c;
f << r.f;
matched << flt.matched;
fixed;
@@

let pieces = Str.split_delim (Str.regexp_string matched) c in
match pieces with
  [before;after] ->
    let preceeding =
      List.length(Str.split (Str.regexp_string "%") before) > 1 in
    if preceeding
    then Coccilib.include_match false
    else
      if List.mem f !extensible_functions
      then fixed := before ^ "%s" ^ after
      else Coccilib.include_match false
| _ -> Coccilib.include_match false

@changed1@
constant char [] r.c;
identifier r2.fixed;
position r.p;
identifier r.f;
@@

f(...,
-c@p
+fixed,__func__
 ,...)

// -------------------------------------------------------------------

@s depends on after_start@
constant char [] c;
position p;
identifier f;
@@

f(...,c@p,...)

@script:python flt2@
c << s.c;
p << s.p;
matched;
@@

func = p[0].current_element
wpattern = "[a-zA-Z_][a-zA-Z0-9_]*"
if ignore_leading:
   func = func.strip("_")
   wpattern = "[a-zA-Z][a-zA-Z0-9_]*"
lf = len(func)
cocci.include_match(False)
// ignore extremely short function names
if lf > 3:
   words = [w for w in re.findall(wpattern, c) if abs(len(w) - lf) <= maxdist]
   for w in words:
       d = distance(w, func) 
       if mindist <= d and d <= maxdist:
          coccinelle.matched = w
          cocci.include_match(True)
     	  //print "%s:%d:%s():%d: %s" % (p[0].file, int(p[0].line), func, d, c)
	  break

@script:ocaml s2@
c << s.c;
f << s.f;
p << s.p;
matched << flt2.matched;
fixed;
@@

let ce = (List.hd p).current_element in
let pieces = Str.split_delim (Str.regexp_string matched) c in
match pieces with
  [before;after] ->
    let preceeding =
      List.length(Str.split (Str.regexp_string "%") before) > 1 in
    if preceeding
    then Coccilib.include_match false
    else
      if List.mem f !extensible_functions
      then Coccilib.include_match false
      else fixed := before ^ ce ^ after
| _ -> Coccilib.include_match false

@changed2@
constant char [] s.c;
identifier s2.fixed;
position s.p;
identifier s.f;
@@

f(...,
-c@p
+fixed
 ,...)
// </smpl>
