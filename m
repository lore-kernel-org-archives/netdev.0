From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/5] add __init attribute
Date: Mon, 18 Apr 2016 16:55:33 +0200
Message-ID: <1460991338-9845-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-ide@vger.kernel.org,
	Josh Triplett <josh@joshtriplett.org>,
	"Luis R . Rodriguez" <mcgrof@kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add __init attribute on a function that is only called from other __init
functions and that is not inlined.

The complete semantic patch used to detect the need for this change is
below (http://coccinelle.lip6.fr/).  This semantic patch checks for local
static non-init functions that are called from an __init function and are
not called from any other function.

<smpl>
@initialize:ocaml@
@@

let itbl = Hashtbl.create 101
let ltbl = Hashtbl.create 101
let thefile = ref ""

let hashadd t k =
  let cell =
    try Hashtbl.find t k
    with Not_found ->
      let cell = ref 0 in
      Hashtbl.add t k cell;
      cell in
  cell := !cell + 1

let hashget t k = try !(Hashtbl.find t k) with Not_found -> 0

let seen  = ref []

@script:ocaml@
@@

(let file = List.hd (Coccilib.files()) in
thefile := file;
let file =
    try List.hd(List.tl (Str.split (Str.regexp "/linux-next/") file))
    with _ -> file in
let ofile = "/var/julia/linux-next/" ^
      (Filename.chop_extension file) ^ ".o" in
if not(Sys.file_exists ofile)
then Coccilib.exit());

Hashtbl.clear itbl;
Hashtbl.clear ltbl;
seen := []

@r@
identifier f;
@@

__init f(...) { ... }

@script:ocaml@
f << r.f;
@@

Hashtbl.add itbl f ()

@s disable optional_attributes@
identifier f;
@@

static f(...) { ... }

@script:ocaml@
f << s.f;
@@

Hashtbl.add ltbl f ()

@t exists@
identifier f,g;
position p;
@@

__init f(...) { ... when any
   g@p(...)
   ... when any
 }

@script:ocaml@
g << t.g;
_p << t.p;
@@

if not (Hashtbl.mem ltbl g) || Hashtbl.mem itbl g
then Coccilib.include_match false

@ok1 disable optional_attributes exists@
identifier f,t.g;
@@

f(...) { ... when any
   g
   ... when any
 }

@ok2 disable optional_attributes exists@
identifier i,j,fld,t.g;
@@

struct i j = { .fld = g, };

@ok3 disable optional_attributes exists@
identifier t.g;
declarer d;
@@

d(...,g,...);

@ok4 disable optional_attributes exists@
identifier t.g;
expression e;
@@

(
e(...,g,...)
|
e(...,&g,...)
|
e = &g
|
e = g
)

@script:ocaml depends on !ok1 && !ok2 && !ok3 && !ok4@
g << t.g;
@@

let file = !thefile in
let file =
    try List.hd(List.tl (Str.split (Str.regexp "/linux-next/") file))
    with _ -> file in
if not(List.mem (g,file) !seen)
then
  begin
    seen := (g,file) :: !seen;
    let ofile = "/var/julia/linux-next/" ^
      (Filename.chop_extension file) ^ ".o" in
    if Sys.file_exists ofile
    then
      let l =
	Common.cmd_to_list
	  (Printf.sprintf
	     "objdump -x %s | grep -w %s | grep -w F | grep .text.unlikely"
	     ofile g) in
      match l with
	[] -> Coccilib.include_match false
      | _ ->
	  Printf.printf "Info for %s %s\n" file g;
	  List.iter
	    (function l -> Printf.printf "%s\n" l)
	    l;
	  Printf.printf "\n"; flush stdout
    else Coccilib.include_match false
  end
else Coccilib.include_match false

@depends on !ok1 && !ok2 && !ok3 && !ok4@
identifier t.g;
@@

- g
+__init g
 (...) { ... }
</smpl>

---

 drivers/clk/clk-qoriq.c         |    3 ++-
 drivers/clocksource/mtk_timer.c |    2 +-
 drivers/ide/cmd640.c            |    2 +-
 drivers/net/arcnet/com90xx.c    |    2 +-
 drivers/tty/rocket.c            |    3 ++-
 5 files changed, 7 insertions(+), 5 deletions(-)
