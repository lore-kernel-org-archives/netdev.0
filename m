From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/47] Netfilter updates for net-next
Date: Mon,  4 Sep 2017 00:25:42 +0200
Message-ID: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next
tree. Basically, updates to the conntrack core, enhancements for
nf_tables, conversion of netfilter hooks from linked list to array to
improve memory locality and asorted improvements for the Netfilter
codebase. More specifically, they are:

1) Add expection to hashes after timer initialization to prevent
   access from another CPU that walks on the hashes and calls
   del_timer(), from Florian Westphal.

2) Don't update nf_tables chain counters from hot path, this is only
   used by the x_tables compatibility layer.

3) Get rid of nested rcu_read_lock() calls from netfilter hook path.
   Hooks are always guaranteed to run from rcu read side, so remove
   nested rcu_read_lock() where possible. Patch from Taehee Yoo.

4) nf_tables new ruleset generation notifications include PID and name
   of the process that has updated the ruleset, from Phil Sutter.

5) Use skb_header_pointer() from nft_fib, so we can reuse this code from
   the nf_family netdev family. Patch from Pablo M. Bermudo.

6) Add support for nft_fib in nf_tables netdev family, also from Pablo.

7) Use deferrable workqueue for conntrack garbage collection, to reduce
   power consumption, from Patch from Subash Abhinov Kasiviswanathan.

8) Add nf_ct_expect_iterate_net() helper and use it. From Florian
   Westphal.

9) Call nf_ct_unconfirmed_destroy only from cttimeout, from Florian.

10) Drop references on conntrack removal path when skbuffs has escaped via
    nfqueue, from Florian.

11) Don't queue packets to nfqueue with dying conntrack, from Florian.

12) Constify nf_hook_ops structure, from Florian.

13) Remove neededlessly branch in nf_tables trace code, from Phil Sutter.

14) Add nla_strdup(), from Phil Sutter.

15) Rise nf_tables objects name size up to 255 chars, people want to use
    DNS names, so increase this according to what RFC 1035 specifies.
    Patch series from Phil Sutter.

16) Kill nf_conntrack_default_on, it's broken. Default on conntrack hook
    registration on demand, suggested by Eric Dumazet, patch from Florian.

17) Remove unused variables in compat_copy_entry_from_user both in
    ip_tables and arp_tables code. Patch from Taehee Yoo.

18) Constify struct nf_conntrack_l4proto, from Julia Lawall.

19) Constify nf_loginfo structure, also from Julia.

20) Use a single rb root in connlimit, from Taehee Yoo.

21) Remove unused netfilter_queue_init() prototype, from Taehee Yoo.

22) Use audit_log() instead of open-coding it, from Geliang Tang.

23) Allow to mangle tcp options via nft_exthdr, from Florian.

24) Allow to fetch TCP MSS from nft_rt, from Florian. This includes
    a fix for a miscalculation of the minimal length.

25) Simplify branch logic in h323 helper, from Nick Desaulniers.

26) Calculate netlink attribute size for conntrack tuple at compile
    time, from Florian.

27) Remove protocol name field from nf_conntrack_{l3,l4}proto structure.
    From Florian.

28) Remove holes in nf_conntrack_l4proto structure, so it becomes
    smaller. From Florian.

29) Get rid of print_tuple() indirection for /proc conntrack listing.
    Place all the code in net/netfilter/nf_conntrack_standalone.c.
    Patch from Florian.

30) Do not built in print_conntrack() if CONFIG_NF_CONNTRACK_PROCFS is
    off. From Florian.

31) Constify most nf_conntrack_{l3,l4}proto helper functions, from
    Florian.

32) Fix broken indentation in ebtables extensions, from Colin Ian King.

33) Fix several harmless sparse warning, from Florian.

34) Convert netfilter hook infrastructure to use array for better memory
    locality, joint work done by Florian and Aaron Conole. Moreover, add
    some instrumentation to debug this.

35) Batch nf_unregister_net_hooks() calls, to call synchronize_net once
    per batch, from Florian.

36) Get rid of noisy logging in ICMPv6 conntrack helper, from Florian.

37) Get rid of obsolete NFDEBUG() instrumentation, from Varsha Rao.

38) Remove unused code in the generic protocol tracker, from Davide
    Caratti.

I think I will have material for a second Netfilter batch in my queue if
time allow to make it fit in this merge window.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 7a68ada6ec7d88c68057d3a4c2a517eb94289976:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-21 03:38:43 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 1aff64715edb8565e99337b842d814d636641b50:

  netfilter: rt: account for tcp header size too (2017-08-28 18:14:30 +0200)

----------------------------------------------------------------
Aaron Conole (1):
      netfilter: convert hook list to an array

Colin Ian King (1):
      netfilter: ebtables: fix indent on if statements

Davide Caratti (1):
      netfilter: conntrack: remove unused code in nf_conntrack_proto_generic.c

Florian Westphal (24):
      netfilter: expect: add to hash table after expect init
      netfilter: expect: add and use nf_ct_expect_iterate helpers
      netfilter: add and use nf_ct_unconfirmed_destroy
      netfilter: conntrack: destroy functions need to free queued packets
      netfilter: nfnetlink_queue: don't queue dying conntracks to userspace
      netfilter: nf_hook_ops structs can be const
      netfilter: nft_set_rbtree: use seqcount to avoid lock in most cases
      netfilter: conntrack: do not enable connection tracking unless needed
      netfilter: exthdr: factor out tcp option access
      netfilter: exthdr: split netlink dump function
      netfilter: exthdr: tcp option set support
      netfilter: rt: add support to fetch path mss
      netfilter: conntrack: compute l3proto nla size at compile time
      netfilter: conntrack: remove protocol name from l3proto struct
      netfilter: conntrack: remove protocol name from l4proto struct
      netfilter: conntrack: reduce size of l4protocol trackers
      netfilter: conntrack: place print_tuple in procfs part
      netfilter: conntrack: print_conntrack only needed if CONFIG_NF_CONNTRACK_PROCFS
      netfilter: conntrack: make protocol tracker pointers const
      netfilter: fix a few (harmless) sparse warnings
      netfilter: debug: check for sorted array
      netfilter: core: batch nf_unregister_net_hooks synchronize_net calls
      netfilter: conntrack: don't log "invalid" icmpv6 connections
      netfilter: rt: account for tcp header size too

Geliang Tang (1):
      netfilter: use audit_log()

Julia Lawall (2):
      netfilter: constify nf_conntrack_l3/4proto parameters
      netfilter: constify nf_loginfo structures

Nick Desaulniers (1):
      netfilter: nf_nat_h323: fix logical-not-parentheses warning

Pablo M. Bermudo Garay (2):
      netfilter: nf_tables: fib: use skb_header_pointer
      netfilter: nf_tables: add fib expression to the netdev family

Pablo Neira Ayuso (1):
      netfilter: nf_tables: keep chain counters away from hot path

Phil Sutter (7):
      netfilter: nf_tables: Attach process info to NFT_MSG_NEWGEN notifications
      netfilter: nf_tables: No need to check chain existence when tracing
      netlink: Introduce nla_strdup()
      netfilter: nf_tables: Allow table names of up to 255 chars
      netfilter: nf_tables: Allow chain name of up to 255 chars
      netfilter: nf_tables: Allow set names of up to 255 chars
      netfilter: nf_tables: Allow object names of up to 255 chars

Subash Abhinov Kasiviswanathan (1):
      netfilter: conntrack: Change to deferable work queue

Taehee Yoo (4):
      netfilter: Remove duplicated rcu_read_lock.
      netfilter: xtables: Remove unused variable in compat_copy_entry_from_user()
      netfilter: connlimit: merge root4 and root6.
      netfilter: remove prototype of netfilter_queue_init

Varsha Rao (1):
      netfilter: Remove NFDEBUG()

 Documentation/networking/nf_conntrack-sysctl.txt |  11 -
 drivers/net/ipvlan/ipvlan_main.c                 |   2 +-
 include/linux/netdevice.h                        |   2 +-
 include/linux/netfilter.h                        |  45 +--
 include/linux/netfilter_ingress.h                |   4 +-
 include/net/netfilter/nf_conntrack.h             |   3 +
 include/net/netfilter/nf_conntrack_expect.h      |   5 +
 include/net/netfilter/nf_conntrack_l3proto.h     |  45 +--
 include/net/netfilter/nf_conntrack_l4proto.h     |  36 +--
 include/net/netfilter/nf_conntrack_timeout.h     |   4 +-
 include/net/netfilter/nf_queue.h                 |   2 +-
 include/net/netfilter/nf_tables.h                |  10 +-
 include/net/netfilter/nf_tables_core.h           |   2 +
 include/net/netlink.h                            |   1 +
 include/net/netns/netfilter.h                    |   2 +-
 include/uapi/linux/netfilter/nf_tables.h         |  17 +-
 lib/nlattr.c                                     |  24 ++
 net/bridge/br_netfilter_hooks.c                  |  21 +-
 net/bridge/netfilter/ebt_ip.c                    |   4 +-
 net/bridge/netfilter/ebt_ip6.c                   |   2 +-
 net/bridge/netfilter/ebtable_filter.c            |   2 +-
 net/bridge/netfilter/ebtable_nat.c               |   2 +-
 net/bridge/netfilter/ebtables.c                  |  13 +-
 net/decnet/netfilter/dn_rtmsg.c                  |   2 +-
 net/ipv4/netfilter/arp_tables.c                  |   2 -
 net/ipv4/netfilter/ip_tables.c                   |   4 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c               |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                |   2 +-
 net/ipv4/netfilter/iptable_nat.c                 |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c   |  40 +--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c     |  12 -
 net/ipv4/netfilter/nf_defrag_ipv4.c              |   2 +-
 net/ipv4/netfilter/nf_log_arp.c                  |   2 +-
 net/ipv4/netfilter/nf_log_ipv4.c                 |   2 +-
 net/ipv4/netfilter/nf_nat_h323.c                 |  57 ++--
 net/ipv4/netfilter/nft_fib_ipv4.c                |  20 +-
 net/ipv6/ila/ila_xlat.c                          |   2 +-
 net/ipv6/netfilter/ip6_tables.c                  |   2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c               |   2 +-
 net/ipv6/netfilter/ip6table_nat.c                |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c   |  42 +--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c   |  17 --
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c        |   2 +-
 net/ipv6/netfilter/nf_log_ipv6.c                 |   2 +-
 net/ipv6/netfilter/nft_fib_ipv6.c                |  29 +-
 net/netfilter/Kconfig                            |   9 +
 net/netfilter/Makefile                           |   1 +
 net/netfilter/core.c                             | 351 +++++++++++++++++++----
 net/netfilter/ipvs/ip_vs_core.c                  |  10 +-
 net/netfilter/ipvs/ip_vs_ctl.c                   |   3 -
 net/netfilter/ipvs/ip_vs_ftp.c                   |   2 -
 net/netfilter/ipvs/ip_vs_proto_sctp.c            |  11 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c             |  10 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c             |  10 +-
 net/netfilter/ipvs/ip_vs_xmit.c                  |  46 +--
 net/netfilter/nf_conntrack_broadcast.c           |   2 -
 net/netfilter/nf_conntrack_core.c                |  44 +--
 net/netfilter/nf_conntrack_expect.c              |  66 ++++-
 net/netfilter/nf_conntrack_helper.c              |  34 +--
 net/netfilter/nf_conntrack_l3proto_generic.c     |   7 -
 net/netfilter/nf_conntrack_netlink.c             | 106 +++----
 net/netfilter/nf_conntrack_pptp.c                |   2 -
 net/netfilter/nf_conntrack_proto.c               |  90 ++----
 net/netfilter/nf_conntrack_proto_dccp.c          |  18 +-
 net/netfilter/nf_conntrack_proto_generic.c       |  20 --
 net/netfilter/nf_conntrack_proto_gre.c           |  15 +-
 net/netfilter/nf_conntrack_proto_sctp.c          |  19 +-
 net/netfilter/nf_conntrack_proto_tcp.c           |  19 +-
 net/netfilter/nf_conntrack_proto_udp.c           |  17 --
 net/netfilter/nf_conntrack_sip.c                 |   6 +-
 net/netfilter/nf_conntrack_standalone.c          |  97 ++++++-
 net/netfilter/nf_internals.h                     |  10 +-
 net/netfilter/nf_queue.c                         |  68 +++--
 net/netfilter/nf_sockopt.c                       |   2 +-
 net/netfilter/nf_tables_api.c                    | 128 ++++++---
 net/netfilter/nf_tables_core.c                   |  28 +-
 net/netfilter/nf_tables_trace.c                  |  42 ++-
 net/netfilter/nfnetlink_cttimeout.c              |  22 +-
 net/netfilter/nfnetlink_log.c                    |   2 +-
 net/netfilter/nfnetlink_queue.c                  |  21 +-
 net/netfilter/nft_exthdr.c                       | 213 ++++++++++++--
 net/netfilter/nft_fib_netdev.c                   |  87 ++++++
 net/netfilter/nft_payload.c                      |   2 +-
 net/netfilter/nft_rt.c                           |  73 ++++-
 net/netfilter/nft_set_rbtree.c                   |  49 +++-
 net/netfilter/x_tables.c                         |  14 +-
 net/netfilter/xt_CT.c                            |   2 +-
 net/netfilter/xt_TCPMSS.c                        |   2 -
 net/netfilter/xt_TPROXY.c                        |   4 -
 net/netfilter/xt_addrtype.c                      |   3 -
 net/netfilter/xt_connlimit.c                     |  26 +-
 net/netfilter/xt_hashlimit.c                     |   8 +-
 net/netfilter/xt_osf.c                           |   2 -
 net/openvswitch/conntrack.c                      |   4 +-
 security/selinux/hooks.c                         |   2 +-
 security/smack/smack_netfilter.c                 |   2 +-
 96 files changed, 1443 insertions(+), 896 deletions(-)
 create mode 100644 net/netfilter/nft_fib_netdev.c

