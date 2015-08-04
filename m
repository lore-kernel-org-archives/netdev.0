From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] Netfilter updates for net-next
Date: Tue,  4 Aug 2015 12:02:30 +0200
Message-ID: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for net-next, they ar=
e:

1) A couple of cleanups for the netfilter core hook from Eric Biederman=
=2E

2) Net namespace hook registration, also from Eric. This adds a depende=
ncy with
   the rtnl_lock. This should be fine by now but we have to keep an eye=
 on this
   because if we ever get the per-subsys nfnl_lock before rtnl we have =
may
   problems in the future. But we have room to remove this in the futur=
e by
   propagating the complexity to the clients, by registering hooks for =
the init
   netns functions.

3) Update nf_tables to use the new net namespace hook infrastructure, a=
lso from
   Eric.

4) Three patches to refine and to address problems from the new net nam=
espace
   hook infrastructure.

5) Switch to alternate jumpstack in xtables iff the packet is reenterin=
g. This
   only applies to a very special case, the TEE target, but Eric Dumaze=
t
   reports that this is slowing down things for everyone else. So let's=
 only
   switch to the alternate jumpstack if the tee target is in used throu=
gh a
   static key. This batch also comes with offline precalculation of the
   jumpstack based on the callchain depth. From Florian Westphal.

6) Minimal SCTP multihoming support for our conntrack helper, from Mich=
al
   Kubecek.

7) Reduce nf_bridge_info per skbuff scratchpad area to 32 bytes, from F=
lorian
   Westphal.

8) Fix several checkpatch errors in bridge netfilter, from Bernhard Tha=
ler.

9) Get rid of useless debug message in ip6t_REJECT, from Subash Abhinov=
=2E

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 0d6ef0688d8744454646298b85336407be05=
e309:

  ipvs: Delete an unnecessary check before the function call "module_pu=
t" (2015-07-15 17:51:22 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git maste=
r

for you to fetch changes up to a6cd379b4d68867295ea35a719008e86d7a2ee9f=
:

  netfilter: ip6t_REJECT: Remove debug messages from reject_tg6() (2015=
-08-04 11:12:51 +0200)

----------------------------------------------------------------
Bernhard Thaler (1):
      netfilter: bridge: do not initialize statics to 0 or NULL

Eric W. Biederman (6):
      netfilter: kill nf_hooks_active
      netfilter: Simply the tests for enabling and disabling the ingres=
s queue hook
      netfilter: Factor out the hook list selection from nf_register_ho=
ok
      netfilter: Per network namespace netfilter hooks.
      netfilter: nftables: Only run the nftables chains in the proper n=
etns
      netfilter: Fix memory leak in nf_register_net_hook

=46lorian Westphal (6):
      netfilter: xtables: compute exact size needed for jumpstack
      netfilter: move tee_active to core
      netfilter: xtables: don't save/restore jumpstack offset
      netfilter: add and use jump label for xt_tee
      netfilter: xtables: remove __pure annotation
      netfilter: bridge: reduce nf_bridge_info to 32 bytes again

Michal Kube=C4=8Dek (1):
      netfilter: nf_ct_sctp: minimal multihoming support

Pablo Neira Ayuso (3):
      netfilter: nf_queue: fix nf_queue_nf_hook_drop()
      netfilter: fix possible removal of wrong hook
      netfilter: rename local nf_hook_list to hook_list

Subash Abhinov Kasiviswanathan (1):
      netfilter: ip6t_REJECT: Remove debug messages from reject_tg6()

 include/linux/netfilter.h                          |   42 ++--
 include/linux/netfilter/x_tables.h                 |    8 +-
 include/linux/netfilter_bridge.h                   |   12 +-
 include/linux/skbuff.h                             |   19 +-
 include/net/netns/netfilter.h                      |    1 +
 include/uapi/linux/netfilter/nf_conntrack_sctp.h   |    2 +
 include/uapi/linux/netfilter/nfnetlink_cttimeout.h |    2 +
 net/bridge/br_netfilter_hooks.c                    |   20 +-
 net/bridge/br_netfilter_ipv6.c                     |    2 +-
 net/ipv4/netfilter/arp_tables.c                    |   32 +--
 net/ipv4/netfilter/ip_tables.c                     |   68 +++---
 net/ipv4/netfilter/nf_defrag_ipv4.c                |    7 +-
 net/ipv6/netfilter/ip6_tables.c                    |   52 +++--
 net/ipv6/netfilter/ip6t_REJECT.c                   |    5 -
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |    7 +-
 net/netfilter/core.c                               |  225 ++++++++++++=
++++----
 net/netfilter/nf_conntrack_proto_sctp.c            |  101 ++++++---
 net/netfilter/nf_internals.h                       |    2 +-
 net/netfilter/nf_queue.c                           |   12 +-
 net/netfilter/nf_tables_api.c                      |    8 +-
 net/netfilter/nf_tables_core.c                     |    5 -
 net/netfilter/x_tables.c                           |   29 ++-
 net/netfilter/xt_TEE.c                             |   15 +-
 23 files changed, 460 insertions(+), 216 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
