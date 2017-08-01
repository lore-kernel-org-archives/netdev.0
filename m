From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/1 v3 nf-next] constify nf_conntrack_l3/4proto parameters
Date: Tue,  1 Aug 2017 12:25:00 +0200
Message-ID: <1501583101-14188-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
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
the nf_conntrack_l3proto case.

// <smpl>
virtual update_results
virtual after_start

@initialize:ocaml@
@@

let unsafe = Hashtbl.create 101

let is_unsafe f = Hashtbl.mem unsafe f

let changed = ref false


(* The next three rules relate to the fact that we do not know the type of
void * variables.  Fortunately this is only neede on the first iteration,
but it still means that the whole kernel will end up being considered. *)

@has depends on !after_start && !update_results@
identifier f,x;
position p;
@@

f@p(...,struct nf_conntrack_l3proto *x,...) { ... }

@hasa depends on !after_start@
identifier f,x;
position p;
@@

f@p(...,struct nf_conntrack_l3proto *x[],...) { ... }

@others depends on !after_start && !update_results@
position p != {has.p,hasa.p};
identifier f,x;
@@

f@p(...,void *x,...) { ... }

@script:ocaml@
f << others.f;
@@

changed := true;
Hashtbl.add unsafe f ()


@fpb depends on !update_results disable optional_qualifier, drop_cast exists@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x,fld;
identifier bad : script:ocaml() { is_unsafe(bad) };
assignment operator aop;
expression e;
local idexpression fp;
type T;
@@

f(...,struct nf_conntrack_l3proto *x,...)
{
...
(
  return x;
|
  (<+...x...+>) aop e
|
  e aop x
|
  (T)x
|
  &(<+...x...+>)
|
  bad(...,x,...)
|
  fp(...,x,...)
|
  (<+...e->fld...+>)(...,x,...)
)
...when any
 }

@script:ocaml@
f << fpb.f;
@@

changed := true;
Printf.eprintf "%s is unsafe\n" f;
Hashtbl.add unsafe f ()

@fpba depends on !update_results disable optional_qualifier, drop_cast exists@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x,fld;
identifier bad : script:ocaml() { is_unsafe(bad) };
assignment operator aop;
expression e;
local idexpression fp;
type T;
@@

f(...,struct nf_conntrack_l3proto *x[],...)
{
...
(
  return \(x\|x[...]\);
|
  (<+...x...+>) aop e
|
  e aop \(x\|x[...]\)
|
  (T)\(x\|x[...]\)
|
  &(<+...x...+>)
|
  bad(...,\(x\|x[...]\),...)
|
  fp(...,\(x\|x[...]\),...)
|
  (<+...e->fld...+>)(...,\(x\|x[...]\),...)
)
... when any
 }

@script:ocaml@
f << fpba.f;
@@

changed := true;
Printf.eprintf "%s is unsafe\n" f;
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
changed := false;
let changed = List.exists (fun x -> !x) c in
let it = new iteration() in
it#add_virtual_rule After_start;
(if not changed
then it#add_virtual_rule Update_results);
it#register()

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x;
@@

f(...,
+ const
  struct nf_conntrack_l3proto *x,...) { ... }

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x;
type T;
@@

T f(...,
+ const
  struct nf_conntrack_l3proto *x,...);

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x;
@@

f(...,
  struct nf_conntrack_l3proto *
+ const
  x[],...) { ... }

@depends on update_results disable optional_qualifier@
identifier f : script:ocaml() { not(is_unsafe(f)) };
identifier x;
type T;
@@

T f(...,
  struct nf_conntrack_l3proto *
+ const
  x[],...);
// </smpl>

---

v3:

Rebased	against	nf-next.  Some functions, such as
nf_ct_l3proto_pernet_register, are no longer defined, so they are no longer
updated.

 include/net/netfilter/nf_conntrack_l4proto.h |   14 +++++++-------
 include/net/netfilter/nf_conntrack_timeout.h |    2 +-
 net/netfilter/nf_conntrack_core.c            |    8 ++++----
 net/netfilter/nf_conntrack_netlink.c         |    6 +++---
 net/netfilter/nf_conntrack_proto.c           |   24 ++++++++++++------------
 net/netfilter/nfnetlink_cttimeout.c          |    5 +++--
 6 files changed, 30 insertions(+), 29 deletions(-)
