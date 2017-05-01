From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/53] Netfilter/IPVS updates for net-next
Date: Mon,  1 May 2017 12:46:27 +0200
Message-ID: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next
tree. A large bunch of code cleanups, XXX they are:

1) Check for ct->status bit instead of using nfct_nat() from IPVS and
   Netfilter codebase, patch from Florian Westphal.

2) Use kcalloc() wherever possible in the IPVS code, from Varsha Rao.

3) Simplify FTP IPVS helper module registration path, from Arushi Singhal.

4) Introduce nft_is_base_chain() helper function.

5) Enforce expectation limit from userspace conntrack helper,
   from Gao Feng.

6) Add nf_ct_remove_expect() helper function, from Gao Feng.

7) NAT mangle helper function return boolean, from Gao Feng.

8) ctnetlink_alloc_expect() should only work for conntrack with
   helpers, from Gao Feng.

9) Add nfnl_msg_type() helper function to nfnetlink to build the
   netlink message type.

10) Get rid of unnecessary cast on void, from simran singhal.

11) Use seq_puts()/seq_putc() instead of seq_printf() where possible,
    also from simran singhal.

12) Use list_prev_entry() from nf_tables, from simran signhal.

13) Remove unnecessary & on pointer function in the Netfilter and IPVS
    code.

14) Remove obsolete comment on set of rules per CPU in ip6_tables,
    no longer true. From Arushi Singhal.

15) Remove duplicated nf_conntrack_l4proto_udplite4, from Gao Feng.

16) Remove unnecessary nested rcu_read_lock() in
    __nf_nat_decode_session(). Code running from hooks are already
    guaranteed to run under RCU read side.

17) Remove deadcode in nf_tables_getobj(), from Aaron Conole.

18) Remove double assignment in nf_ct_l4proto_pernet_unregister_one(),
    also from Aaron.

19) Get rid of unsed __ip_set_get_netlink(), from Aaron Conole.

20) Don't propagate NF_DROP error to userspace via ctnetlink in
    __nf_nat_alloc_null_binding() function, from Gao Feng.

21) Revisit nf_ct_deliver_cached_events() to remove unnecessary checks,
    from Gao Feng.

22) Kill the fake untracked conntrack objects, use ctinfo instead to
    annotate a conntrack object is untracked, from Florian Westphal.

23) Remove nf_ct_is_untracked(), now obsolete since we have no
    conntrack template anymore, from Florian.

24) Add event mask support to nft_ct, also from Florian.

25) Move nf_conn_help structure to
    include/net/netfilter/nf_conntrack_helper.h.

26) Add a fixed 32 bytes scratchpad area for conntrack helpers.
    Thus, we don't deal with variable conntrack extensions anymore.
    Make sure userspace conntrack helper doesn't go over that size.
    Remove variable size ct extension infrastructure now this code
    got no more clients. From Florian Westphal.

27) Restore offset and length of nf_ct_ext structure to 8 bytes now
    that wraparound is not possible any longer, also from Florian.

28) Allow to get rid of unassured flows under stress in conntrack,
    this applies to DCCP, SCTP and TCP protocols, from Florian.

29) Shrink size of nf_conntrack_ecache structure, from Florian.

30) Use TCP_MAX_WSCALE instead of hardcoded 14 in TCP tracker,
    from Gao Feng.

31) Register SYNPROXY hooks on demand, from Florian Westphal.

32) Use pernet hook whenever possible, instead of global hook
    registration, from Florian Westphal.

33) Pass hook structure to ebt_register_table() to consolidate some
    infrastructure code, from Florian Westphal.

34) Use consume_skb() and return NF_STOLEN, instead of NF_DROP in the
    SYNPROXY code, to make sure device stats are not fooled, patch
    from Gao Feng.

35) Remove NF_CT_EXT_F_PREALLOC this kills quite some code that we
    don't need anymore if we just select a fixed size instead of
    expensive runtime time calculation of this. From Florian.

36) Constify nf_ct_extend_register() and nf_ct_extend_unregister(),
    from Florian.

37) Simplify nf_ct_ext_add(), this kills nf_ct_ext_create(), from
    Florian.

38) Attach NAT extension on-demand from masquerade and pptp helper
    path, from Florian.

39) Get rid of useless ip_vs_set_state_timeout(), from Aaron Conole.

40) Speed up netns by selective calls of synchronize_net(), from
    Florian Westphal.

41) Silence stack size warning gcc in 32-bit arch in snmp helper,
    from Florian.

42) Inconditionally call nf_ct_ext_destroy(), even if we have no
    extensions, to deal with the NF_NAT_MANIP_SRC case. Patch from
    Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6f14f443d3e773439fb9cc6f2685ba90d5d026c5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-04-06 08:24:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 8eeef2350453aa012d846457eb6ecd012a35d99b:

  netfilter: nf_ct_ext: invoke destroy even when ext is not attached (2017-05-01 11:48:49 +0200)

----------------------------------------------------------------
Aaron Conole (5):
      netfilter: nf_tables: remove double return statement
      netfilter: nf_conntrack: remove double assignment
      ipset: remove unused function __ip_set_get_netlink
      ipvs: remove unused function ip_vs_set_state_timeout
      ipvs: change comparison on sync_refresh_period

Arushi Singhal (3):
      ipvs: remove unused variable
      netfilter: Remove exceptional & on function name
      netfilter: ip6_tables: Remove unneccessary comments

Florian Westphal (28):
      netfilter: ipvs: don't check for presence of nat extension
      netfilter: nat: avoid use of nf_conn_nat extension
      netfilter: kill the fake untracked conntrack objects
      netfilter: remove nf_ct_is_untracked
      netfilter: nft_ct: allow to set ctnetlink event types of a connection
      netfilter: conntrack: move helper struct to nf_conntrack_helper.h
      netfilter: helper: add build-time asserts for helper data size
      netfilter: nfnetlink_cthelper: reject too large userspace allocation requests
      netfilter: helpers: remove data_len usage for inkernel helpers
      netfilter: remove last traces of variable-sized extensions
      netfilter: conntrack: use u8 for extension sizes again
      netfilter: allow early drop of assured conntracks
      nefilter: eache: reduce struct size from 32 to 24 byte
      netfilter: ipvs: fix incorrect conflict resolution
      netfilter: synproxy: only register hooks when needed
      ipvs: convert to use pernet nf_hook api
      netfilter: decnet: only register hooks in init namespace
      ebtables: remove nf_hook_register usage
      netfilter: conntrack: remove prealloc support
      netfilter: conntrack: mark extension structs as const
      netfilter: conntrack: handle initial extension alloc via krealloc
      netfilter: masquerade: attach nat extension if not present
      netfilter: pptp: attach nat extension when needed
      netfilter: don't attach a nat extension by default
      netfilter: batch synchronize_net calls during hook unregister
      netfilter: nf_log: don't call synchronize_rcu in nf_log_unset
      netfilter: nf_queue: only call synchronize_net twice if nf_queue is active
      netfilter: snmp: avoid stack size warning

Gao Feng (9):
      netfilter: expect: Make sure the max_expected limit is effective
      netfilter: nf_ct_expect: Add nf_ct_remove_expect()
      netfilter: nat: nf_nat_mangle_{udp,tcp}_packet returns boolean
      netfilter: ctnetlink: Expectations must have a conntrack helper area
      netfilter: udplite: Remove duplicated udplite4/6 declaration
      netfilter: nf_nat: Fix return NF_DROP in nfnetlink_parse_nat_setup
      netfilter: ecache: Refine the nf_ct_deliver_cached_events
      netfilter: tcp: Use TCP_MAX_WSCALE instead of literal 14
      netfilter: SYNPROXY: Return NF_STOLEN instead of NF_DROP during handshaking

Liping Zhang (1):
      netfilter: nf_ct_ext: invoke destroy even when ext is not attached

Pablo Neira Ayuso (4):
      netfilter: nf_tables: add nft_is_base_chain() helper
      netfilter: Add nfnl_msg_type() helper function
      Merge tag 'ipvs2-for-v4.12' of https://git.kernel.org/.../horms/ipvs-next
      Merge tag 'ipvs3-for-v4.12' of http://git.kernel.org/.../horms/ipvs-next

Taehee Yoo (1):
      netfilter: nat: remove rcu_read_lock in __nf_nat_decode_session.

Varsha Rao (1):
      netfilter: ipvs: Replace kzalloc with kcalloc.

simran singhal (3):
      netfilter: Remove unnecessary cast on void pointer
      netfilter: Use seq_puts()/seq_putc() where possible
      net: netfilter: Use list_{next/prev}_entry instead of list_entry

 include/linux/netfilter/nfnetlink.h                |   5 +
 include/linux/netfilter_bridge/ebtables.h          |   6 +-
 include/net/ip_vs.h                                |  12 +-
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h     |   1 -
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h     |   1 -
 include/net/netfilter/nf_conntrack.h               |  32 ------
 include/net/netfilter/nf_conntrack_core.h          |   2 +-
 include/net/netfilter/nf_conntrack_ecache.h        |   4 +-
 include/net/netfilter/nf_conntrack_expect.h        |   2 +
 include/net/netfilter/nf_conntrack_extend.h        |  29 +----
 include/net/netfilter/nf_conntrack_helper.h        |  31 ++++-
 include/net/netfilter/nf_conntrack_l4proto.h       |   3 +
 include/net/netfilter/nf_conntrack_synproxy.h      |   2 +
 include/net/netfilter/nf_nat.h                     |   2 +-
 include/net/netfilter/nf_nat_helper.h              |  36 +++---
 include/net/netfilter/nf_queue.h                   |   3 +-
 include/net/netfilter/nf_tables.h                  |   5 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |   9 +-
 include/uapi/linux/netfilter/nf_tables.h           |   2 +
 net/bridge/netfilter/ebtable_broute.c              |   4 +-
 net/bridge/netfilter/ebtable_filter.c              |  15 +--
 net/bridge/netfilter/ebtable_nat.c                 |  15 +--
 net/bridge/netfilter/ebtables.c                    |  63 +++++++----
 net/bridge/netfilter/nft_meta_bridge.c             |   2 +-
 net/decnet/netfilter/dn_rtmsg.c                    |   4 +-
 net/ipv4/netfilter/arp_tables.c                    |  21 ++--
 net/ipv4/netfilter/ip_tables.c                     |  20 ++--
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |  94 ++++++++-------
 net/ipv4/netfilter/nf_dup_ipv4.c                   |   3 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |   8 +-
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c        |   5 +-
 net/ipv4/netfilter/nf_nat_pptp.c                   |  45 +++++---
 net/ipv4/netfilter/nf_nat_snmp_basic.c             |  12 +-
 net/ipv4/netfilter/nf_socket_ipv4.c                |   2 +-
 net/ipv4/netfilter/nft_fib_ipv4.c                  |   2 +-
 net/ipv6/netfilter/ip6_tables.c                    |  29 ++---
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |  93 ++++++++-------
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |   3 +-
 net/ipv6/netfilter/nf_dup_ipv6.c                   |   3 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |   8 +-
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c        |   5 +-
 net/ipv6/netfilter/nft_fib_ipv6.c                  |   2 +-
 net/netfilter/core.c                               |  53 +++++++--
 net/netfilter/ipset/ip_set_bitmap_gen.h            |   5 +-
 net/netfilter/ipset/ip_set_core.c                  |  14 +--
 net/netfilter/ipvs/ip_vs_core.c                    |  19 ++--
 net/netfilter/ipvs/ip_vs_ctl.c                     |  12 +-
 net/netfilter/ipvs/ip_vs_ftp.c                     |  20 ++--
 net/netfilter/ipvs/ip_vs_nfct.c                    |   4 +-
 net/netfilter/ipvs/ip_vs_proto.c                   |  22 ----
 net/netfilter/ipvs/ip_vs_sync.c                    |   6 +-
 net/netfilter/ipvs/ip_vs_xmit.c                    |   8 +-
 net/netfilter/nf_conntrack_acct.c                  |   2 +-
 net/netfilter/nf_conntrack_amanda.c                |   2 +
 net/netfilter/nf_conntrack_core.c                  | 126 ++++++++++++++-------
 net/netfilter/nf_conntrack_ecache.c                |   9 +-
 net/netfilter/nf_conntrack_expect.c                |  36 +++---
 net/netfilter/nf_conntrack_extend.c                | 114 ++++---------------
 net/netfilter/nf_conntrack_ftp.c                   |   8 +-
 net/netfilter/nf_conntrack_h323_main.c             |   6 +-
 net/netfilter/nf_conntrack_helper.c                |  18 ++-
 net/netfilter/nf_conntrack_irc.c                   |   8 +-
 net/netfilter/nf_conntrack_labels.c                |   2 +-
 net/netfilter/nf_conntrack_netbios_ns.c            |   2 +
 net/netfilter/nf_conntrack_netlink.c               |  55 +++------
 net/netfilter/nf_conntrack_pptp.c                  |  15 ++-
 net/netfilter/nf_conntrack_proto.c                 |   5 +-
 net/netfilter/nf_conntrack_proto_dccp.c            |  16 +++
 net/netfilter/nf_conntrack_proto_sctp.c            |  16 +++
 net/netfilter/nf_conntrack_proto_tcp.c             |  25 +++-
 net/netfilter/nf_conntrack_sane.c                  |   8 +-
 net/netfilter/nf_conntrack_seqadj.c                |   2 +-
 net/netfilter/nf_conntrack_sip.c                   |  18 ++-
 net/netfilter/nf_conntrack_standalone.c            |   6 +-
 net/netfilter/nf_conntrack_tftp.c                  |   6 +-
 net/netfilter/nf_conntrack_timeout.c               |   2 +-
 net/netfilter/nf_conntrack_timestamp.c             |   2 +-
 net/netfilter/nf_internals.h                       |   2 +-
 net/netfilter/nf_log.c                             |   5 +-
 net/netfilter/nf_nat_amanda.c                      |  11 +-
 net/netfilter/nf_nat_core.c                        |  37 ++----
 net/netfilter/nf_nat_helper.c                      |  40 +++----
 net/netfilter/nf_nat_irc.c                         |   9 +-
 net/netfilter/nf_queue.c                           |   7 +-
 net/netfilter/nf_synproxy_core.c                   |  10 +-
 net/netfilter/nf_tables_api.c                      |  54 ++++-----
 net/netfilter/nf_tables_netdev.c                   |   2 +-
 net/netfilter/nf_tables_trace.c                    |   3 +-
 net/netfilter/nfnetlink.c                          |   2 +-
 net/netfilter/nfnetlink_acct.c                     |   2 +-
 net/netfilter/nfnetlink_cthelper.c                 |  18 ++-
 net/netfilter/nfnetlink_cttimeout.c                |   4 +-
 net/netfilter/nfnetlink_log.c                      |   6 +-
 net/netfilter/nfnetlink_queue.c                    |  24 ++--
 net/netfilter/nft_compat.c                         |  13 ++-
 net/netfilter/nft_ct.c                             |  41 +++++--
 net/netfilter/nft_exthdr.c                         |   2 +-
 net/netfilter/nft_hash.c                           |   2 +-
 net/netfilter/nft_meta.c                           |   2 +-
 net/netfilter/nft_numgen.c                         |   2 +-
 net/netfilter/nft_queue.c                          |   2 +-
 net/netfilter/nft_set_hash.c                       |   2 +-
 net/netfilter/xt_CT.c                              |  16 +--
 net/netfilter/xt_HMARK.c                           |   2 +-
 net/netfilter/xt_cluster.c                         |   3 -
 net/netfilter/xt_connlabel.c                       |   2 +-
 net/netfilter/xt_connmark.c                        |   4 +-
 net/netfilter/xt_conntrack.c                       |  11 +-
 net/netfilter/xt_hashlimit.c                       |  10 +-
 net/netfilter/xt_ipvs.c                            |   2 +-
 net/netfilter/xt_recent.c                          |   2 +-
 net/netfilter/xt_state.c                           |  13 +--
 net/openvswitch/conntrack.c                        |   5 -
 113 files changed, 853 insertions(+), 836 deletions(-)
