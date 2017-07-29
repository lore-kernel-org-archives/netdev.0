From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/1] constify nf_conntrack_l3/4proto parameters
Date: Sat, 29 Jul 2017 21:23:16 +0200
Message-ID: <1501356197-26490-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a nf_conntrack_l3/4proto parameter is not on the left hand side
of an assignment, its address is not taken, and it is not passed to a
function that may modify its fields, then it can be declared as const.

This change is useful from a documentation point of view, and can
possibly facilitate making some nf_conntrack_l4proto structures const
subsequently.

Done with the help of Coccinelle.  The following semantic patch shows
the nf_conntrack_l4proto case.

// <smpl>
virtual update_results
virtual after_start

@initialize:ocaml@
@@

let unsafe = Hashtbl.create 101

let is_unsafe f = Hashtbl.mem unsafe f

let changed = ref false


(* The next three rules relate to the fact that we do not know the type of
void * variables.  Fortunately this is only needed on the first iteration,
but it still means that the whole kernel will end up being considered. *)

@has depends on !after_start@
identifier f,l4proto;
position p;
@@

f(...,struct nf_conntrack_l4proto *l4proto,...) { ... }

@others depends on !after_start@
position p != has.p;
identifier f,x;
@@

f(...,void *x,...) { ... }

@script:ocaml@
f << others.f;
@@

changed := true;
Hashtbl.add unsafe f ()


@fpb depends on !update_results disable optional_qualifier exists@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier l4proto,fld;
identifier bad : script:ocaml() { is_unsafe(bad) };
assignment operator aop;
expression e;
local idexpression fp;
@@

f(...,struct nf_conntrack_l4proto *l4proto,...)
{
<+...
(
  (<+...l4proto...+>) aop e
|
  &(<+...l4proto...+>)
|
  bad(...,l4proto,...)
|
  fp(...,l4proto,...)
|
  (<+...e->fld...+>)(...,l4proto,...)
)
...+> }

@script:ocaml@
f << fpb.f;
@@

changed := true;
Hashtbl.add unsafe f ()

@finalize:ocaml depends on !update_results@
tbls << merge.unsafe;
c << merge.changed;
@@

List.iter
    (fun t ->
      Hashtbl.iter
	(fun k v ->
	  if not (Hashtbl.mem unsafe k) then Hashtbl.add unsafe k ()) t)
    tbls;
let changed = List.exists (fun x -> !x) c in
let it = new iteration() in
it#add_virtual_rule After_start;
(if not changed
then it#add_virtual_rule Update_results);
it#register()

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier l4proto;
@@

f(...,
+ const
  struct nf_conntrack_l4proto *l4proto,...) { ... }

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier l4proto;
type T;
@@

T f(...,
+ const
  struct nf_conntrack_l4proto *l4proto,...);

// </smpl>

---

 include/net/netfilter/nf_conntrack_l3proto.h |    6 +++---
 include/net/netfilter/nf_conntrack_l4proto.h |    8 ++++----
 include/net/netfilter/nf_conntrack_timeout.h |    2 +-
 net/netfilter/nf_conntrack_core.c            |    8 ++++----
 net/netfilter/nf_conntrack_netlink.c         |    6 +++---
 net/netfilter/nf_conntrack_proto.c           |   20 ++++++++++----------
 net/netfilter/nfnetlink_cttimeout.c          |    2 +-
 7 files changed, 26 insertions(+), 26 deletions(-)
