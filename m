From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/9] use correct structure type name in sizeof
Date: Tue, 29 Jul 2014 17:16:42 +0200
Message-ID: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-ia64@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 toralf.foerster@gmx.de, linux-usb@vger.kernel.org,
 kernel-janitors@vger.kernel.org, reiserfs-devel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-gpio@vger.kernel.org, hmh@hmh.eng.br,
 netdev@vger.kernel.org, ceph-devel@vger.kernel.org,
 linux-media@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

These patches fix typos in the name of a type referenced in a sizeof
command.  These problems are not caught by the compiler, because they have
no impact on execution - the size of a pointer is independent of the size
of the pointed value.

The semantic patch that finds these problems is shown below
(http://coccinelle.lip6.fr/).  This semantic patch distinguishes between
structures that are defined in C files, and thus are expected to be visible
in only that file, and structures that are defined in header files, which
could potential be visible everywhere.  This distinction seems to be
unnecessary in practice, though.

<smpl>
virtual after_start

@initialize:ocaml@
@@

type fl = C of string | H

let structures = Hashtbl.create 101
let restarted = ref false

let add_if_not_present _ =
  if not !restarted
  then
    begin
      restarted := true;
      let it = new iteration() in
      it#add_virtual_rule After_start;
      it#register()
    end

let hashadd str file =
  let cell =
    try Hashtbl.find structures str
    with Not_found ->
      let cell = ref [] in
      Hashtbl.add structures str cell;
      cell in
  if not (List.mem file !cell) then cell := file :: !cell

let get_file fl =
  if Filename.check_suffix fl ".c"
  then C fl
  else H

@script:ocaml depends on !after_start@
@@
add_if_not_present()

@r depends on !after_start@
identifier nm;
position p;
@@

struct nm@p { ... };

@script:ocaml@
nm << r.nm;
p << r.p;
@@

hashadd nm (get_file (List.hd p).file)

// -------------------------------------------------------------------------

@sz depends on after_start@
identifier nm;
position p;
@@

sizeof(struct nm@p *)

@script:ocaml@
nm << sz.nm;
p << sz.p;
@@

try
  let allowed = !(Hashtbl.find structures nm) in
  if List.mem H allowed or List.mem (get_file (List.hd p).file) allowed
  then ()
  else print_main nm p
with Not_found -> print_main nm p
</smpl>
