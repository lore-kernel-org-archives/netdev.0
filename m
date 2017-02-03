From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/27] Netfilter updates for net-next
Date: Fri,  3 Feb 2017 13:25:11 +0100
Message-ID: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next
tree, they are:

1) Stash ctinfo 3-bit field into pointer to nf_conntrack object from
   sk_buff so we only access one single cacheline in the conntrack
   hotpath. Patchset from Florian Westphal.

2) Don't leak pointer to internal structures when exporting x_tables
   ruleset back to userspace, from Willem DeBruijn. This includes new
   helper functions to copy data to userspace such as xt_data_to_user()
   as well as conversions of our ip_tables, ip6_tables and arp_tables
   clients to use it. Not surprinsingly, ebtables requires an ad-hoc
   update. There is also a new field in x_tables extensions to indicate
   the amount of bytes that we copy to userspace.

3) Add nf_log_all_netns sysctl: This new knob allows you to enable
   logging via nf_log infrastructure for all existing netnamespaces.
   Given the effort to provide pernet syslog has been discontinued,
   let's provide a way to restore logging using netfilter kernel logging
   facilities in trusted environments. Patch from Michal Kubecek.

4) Validate SCTP checksum from conntrack helper, from Davide Caratti.

5) Merge UDPlite conntrack and NAT helpers into UDP, this was mostly
   a copy&paste from the original helper, from Florian Westphal.

6) Reset netfilter state when duplicating packets, also from Florian.

7) Remove unnecessary check for broadcast in IPv6 in pkttype match and
   nft_meta, from Liping Zhang.

8) Add missing code to deal with loopback packets from nft_meta when
   used by the netdev family, also from Liping.

9) Several cleanups on nf_tables, one to remove unnecessary check from
   the netlink control plane path to add table, set and stateful objects
   and code consolidation when unregister chain hooks, from Gao Feng.

10) Fix harmless reference counter underflow in IPVS that, however,
    results in problems with the introduction of the new refcount_t
    type, from David Windsor.

11) Enable LIBCRC32C from nf_ct_sctp instead of nf_nat_sctp,
    from Davide Caratti.

12) Missing documentation on nf_tables uapi header, from Liping Zhang.

13) Use rb_entry() helper in xt_connlimit, from Geliang Tang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 0a0a8d6b0e88d947d7ab3198b325e31f677bebc2:

  net: fealnx: use new api ethtool_{get|set}_link_ksettings (2017-01-02 16:59:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 2851940ffee313e0ff12540a8e11a8c54dea9c65:

  netfilter: allow logging from non-init namespaces (2017-02-02 14:31:58 +0100)

----------------------------------------------------------------
David Windsor (1):
      ipvs: free ip_vs_dest structs when refcnt=0

Davide Caratti (2):
      netfilter: select LIBCRC32C together with SCTP conntrack
      netfilter: conntrack: validate SCTP crc32c in PREROUTING

Feng (1):
      netfilter: nf_tables: Eliminate duplicated code in nf_tables_table_enable()

Florian Westphal (9):
      netfilter: merge udp and udplite conntrack helpers
      netfilter: nat: merge udp and udplite helpers
      netfilter: conntrack: no need to pass ctinfo to error handler
      netfilter: reset netfilter state when duplicating packet
      netfilter: reduce direct skb->nfct usage
      skbuff: add and use skb_nfct helper
      netfilter: add and use nf_ct_set helper
      netfilter: guarantee 8 byte minalign for template addresses
      netfilter: merge ctinfo into nfct pointer storage area

Gao Feng (1):
      netfilter: nf_tables: eliminate useless condition checks

Geliang Tang (1):
      netfilter: xt_connlimit: use rb_entry()

Liping Zhang (4):
      netfilter: nf_tables: add missing descriptions in nft_ct_keys
      netfilter: nft_ct: add average bytes per packet support
      netfilter: pkttype: unnecessary to check ipv6 multicast address
      netfilter: nft_meta: deal with PACKET_LOOPBACK in netdev family

Michal Kubeček (1):
      netfilter: allow logging from non-init namespaces

Willem de Bruijn (7):
      xtables: add xt_match, xt_target and data copy_to_user functions
      iptables: use match, target and data copy_to_user helpers
      ip6tables: use match, target and data copy_to_user helpers
      arptables: use match, target and data copy_to_user helpers
      ebtables: use match, target and data copy_to_user helpers
      xtables: use match, target and data copy_to_user helpers in compat
      xtables: extend matches and targets with .usersize

 Documentation/networking/netfilter-sysctl.txt  |  10 +
 include/linux/netfilter/x_tables.h             |   9 +
 include/linux/skbuff.h                         |  32 +--
 include/net/ip_vs.h                            |  12 +-
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |   1 +
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |   1 +
 include/net/netfilter/nf_conntrack.h           |  17 +-
 include/net/netfilter/nf_conntrack_core.h      |   2 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   2 +-
 include/net/netfilter/nf_log.h                 |   3 +
 include/net/netns/conntrack.h                  |  16 --
 include/uapi/linux/netfilter/nf_tables.h       |   5 +
 net/bridge/netfilter/ebt_limit.c               |   1 +
 net/bridge/netfilter/ebt_log.c                 |   2 +-
 net/bridge/netfilter/ebtables.c                |  78 +++---
 net/core/skbuff.c                              |   2 +-
 net/ipv4/netfilter/arp_tables.c                |  15 +-
 net/ipv4/netfilter/ip_tables.c                 |  21 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   1 +
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  11 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  15 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   4 +-
 net/ipv4/netfilter/nf_dup_ipv4.c               |   7 +-
 net/ipv4/netfilter/nf_log_arp.c                |   2 +-
 net/ipv4/netfilter/nf_log_ipv4.c               |   2 +-
 net/ipv6/netfilter/ip6_tables.c                |  21 +-
 net/ipv6/netfilter/ip6t_NPT.c                  |   2 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  11 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  20 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |   4 +-
 net/ipv6/netfilter/nf_dup_ipv6.c               |   7 +-
 net/ipv6/netfilter/nf_log_ipv6.c               |   2 +-
 net/netfilter/Kconfig                          |   2 +-
 net/netfilter/Makefile                         |   2 -
 net/netfilter/core.c                           |   2 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |   8 +-
 net/netfilter/nf_conntrack_core.c              |  73 +++---
 net/netfilter/nf_conntrack_proto_dccp.c        |   1 -
 net/netfilter/nf_conntrack_proto_sctp.c        |  32 +++
 net/netfilter/nf_conntrack_proto_tcp.c         |   1 -
 net/netfilter/nf_conntrack_proto_udp.c         | 124 +++++++++-
 net/netfilter/nf_conntrack_proto_udplite.c     | 324 -------------------------
 net/netfilter/nf_conntrack_standalone.c        |   3 +
 net/netfilter/nf_log.c                         |  24 ++
 net/netfilter/nf_nat_helper.c                  |   2 +-
 net/netfilter/nf_nat_proto_udp.c               |  78 +++++-
 net/netfilter/nf_nat_proto_udplite.c           |  73 ------
 net/netfilter/nf_tables_api.c                  |  63 +++--
 net/netfilter/nft_ct.c                         |  25 +-
 net/netfilter/nft_meta.c                       |  31 ++-
 net/netfilter/x_tables.c                       |  68 +++++-
 net/netfilter/xt_CT.c                          |  15 +-
 net/netfilter/xt_RATEEST.c                     |   1 +
 net/netfilter/xt_TEE.c                         |   2 +
 net/netfilter/xt_bpf.c                         |   2 +
 net/netfilter/xt_cgroup.c                      |   1 +
 net/netfilter/xt_connlimit.c                   |   5 +-
 net/netfilter/xt_hashlimit.c                   |   4 +
 net/netfilter/xt_limit.c                       |   2 +
 net/netfilter/xt_pkttype.c                     |   3 +-
 net/netfilter/xt_quota.c                       |   1 +
 net/netfilter/xt_rateest.c                     |   1 +
 net/netfilter/xt_string.c                      |   1 +
 net/openvswitch/conntrack.c                    |  12 +-
 net/sched/cls_flow.c                           |   2 +-
 65 files changed, 646 insertions(+), 680 deletions(-)
 create mode 100644 Documentation/networking/netfilter-sysctl.txt
 delete mode 100644 net/netfilter/nf_conntrack_proto_udplite.c
 delete mode 100644 net/netfilter/nf_nat_proto_udplite.c
