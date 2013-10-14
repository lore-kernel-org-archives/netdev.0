From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/17] netfilter updates: nf_tables pull request
Date: Mon, 14 Oct 2013 18:38:41 +0200
Message-ID: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34728 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757232Ab3JNQjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@soleta.eu>

Hi David,

The following patchset contains the current original nf_tables tree
condensed in 17 patches. I have organized them by chronogical order
since the original nf_tables code was released in 2009 and by
dependencies between the different patches.

The patches are:

1) Adapt all existing hooks in the tree to pass hook ops to the
   hook callback function, required by nf_tables, from Patrick McHardy.

2) Move alloc_null_binding to nf_nat_core, as it is now also needed by
   nf_tables and ip_tables, original patch from Patrick McHardy but
   required major changes to adapt it to the current tree that I made.

3) Add nf_tables core, including the netlink API, the packet filtering
   engine, expressions and built-in tables, from Patrick McHardy. This
   patch includes accumulated fixes since 2009 and minor enhancements.
   The patch description contains a list of references to the original
   patches for the record. For those that are not familiar to the
   original work, see [1], [2] and [3].

4) Add netlink set API, this replaces the original set infrastructure
   to introduce a netlink API to add/delete sets and to add/delete
   set elements. This includes two set types: the hash and the rb-tree
   sets (used for interval based matching). The main difference with
   ipset is that this infrastructure is data type agnostic. Patch from
   Patrick McHardy.

5) Allow expression operation overload, this API change allows us to
   provide define expression subtypes depending on the configuration
   that is received from user-space via Netlink. It is used by follow
   up patches to provide optimized versions of the payload and cmp
   expressions and the x_tables compatibility layer, from Patrick
   McHardy.

6) Add optimized data comparison operation, it requires the previous
   patch, from Patrick McHardy.

7) Add optimized payload implementation, it requires patch 5, from
   Patrick McHardy.

8) Convert built-in tables to chain types. Each chain type have special
   semantics (filter, route and nat) that are used by userspace to
   configure the chain behaviour. The main chain regarding iptables
   is that tables become containers of chain, with no specific semantics.
   However, you may still configure your tables and chains to retain
   iptables like semantics, patch from me.

9) Add compatibility layer for x_tables. This patch adds support to
   use all existing x_tables extensions from nf_tables, this is used
   to provide a userspace utility that accepts iptables syntax but
   used internally the nf_tables kernel core. This patch includes
   missing features in the nf_tables core such as the per-chain
   stats, default chain policy and number of chain references, which
   are required by the iptables compatibility userspace tool. Patch
   from me.

10) Fix transport protocol matching, this fix is a side effect of the
    x_tables compatibility layer, which now provides a pointer to the
    transport header, from me.

11) Add support for dormant tables, this feature allows you to disable
    all chains and rules that are contained in one table, from me.

12) Add IPv6 NAT support. At the time nf_tables was made, there was no
    NAT IPv6 support yet, from Tomasz Bursztyka.

13) Complete net namespace support. This patch register the protocol
    family per net namespace, so tables (thus, other objects contained
    in tables such as sets, chains and rules) are only visible from the
    corresponding net namespace, from me.

14) Add the insert operation to the nf_tables netlink API, this requires
    adding a new position attribute that allow us to locate where in the
    ruleset a rule needs to be inserted, from Eric Leblond.

15) Add rule batching support, including atomic rule-set updates by
    using rule-set generations. This patch includes a change to nfnetlink
    to include two new control messages to indicate the beginning and
    the end of a batch. The end message is interpreted as the commit
    message, if it's missing, then the rule-set updates contained in the
    batch are aborted, from me.

16) Add trace support to the nf_tables packet filtering core, from me.

17) Add ARP filtering support, original patch from Patrick McHardy, but
    adapted to fit into the chain type infrastructure. This was recovered
    to be used by nft userspace tool and our compatibility arptables
    userspace tool.

There is still work to do to fully replace x_tables [4] [5] but that can
be done incrementally by extending our netlink API. Moreover, looking at
netfilter-devel and the amount of contributions to nf_tables we've been
getting, I think it would be good to have it mainstream to avoid accumulating
large patchsets skip continuous rebases.

I tried to provide a reasonable patchset, we have more than 100 accumulated
patches in the original nf_tables tree, so I collapsed many of the small
fixes to the main patch we had since 2009 and provide a small batch for
review to netdev, while trying to retain part of the history.

For those who didn't give a try to nf_tables yet, there's a quick howto
available from Eric Leblond that describes how to get things working [6].

Comments/reviews welcome.

Thanks!

[1] http://lwn.net/Articles/324251/
[2] http://workshop.netfilter.org/2013/wiki/images/e/ee/Nftables-osd-2013-developer.pdf
[3] http://lwn.net/Articles/564095/
[4] http://people.netfilter.org/pablo/map-pending-work.txt
[4] http://people.netfilter.org/pablo/nftables-todo.txt
[5] https://home.regit.org/netfilter-en/nftables-quick-howto/

----------------------------------------------------------------

The following changes since commit ccdbb6e96beca362db876d820ac1e560ff6d9579:

  tcp: tcp_transmit_skb() optimizations (2013-10-11 17:48:18 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git net-next

for you to fetch changes up to ed683f138b3dbc8a5e878e24a0bfa0bb61043a09:

  netfilter: nf_tables: add ARP filtering support (2013-10-14 18:01:03 +0200)

----------------------------------------------------------------
Eric Leblond (1):
      netfilter: nf_tables: add insert operation

Pablo Neira Ayuso (9):
      netfilter: nf_nat: move alloc_null_binding to nf_nat_core.c
      netfilter: nf_tables: convert built-in tables/chains to chain types
      netfilter: nf_tables: add compatibility layer for x_tables
      netfilter: nf_tables: nft_payload: fix transport header base
      netfilter: nf_tables: add support for dormant tables
      netfilter: nf_tables: complete net namespace support
      netfilter: nfnetlink: add batch support and use it from nf_tables
      netfilter: nf_tables: add trace support
      netfilter: nf_tables: add ARP filtering support

Patrick McHardy (6):
      netfilter: pass hook ops to hookfn
      netfilter: add nftables
      netfilter: nf_tables: add netlink set API
      netfilter: nf_tables: expression ops overloading
      netfilter: nf_tables: add optimized data comparison for small values
      netfilter: nft_payload: add optimized payload implementation for small loads

Tomasz Bursztyka (1):
      netfilter: nf_tables: Add support for IPv6 NAT

 include/linux/netfilter.h                          |   14 +-
 include/linux/netfilter/nfnetlink.h                |    5 +
 include/net/net_namespace.h                        |    4 +
 include/net/netfilter/nf_nat.h                     |    3 +
 include/net/netfilter/nf_tables.h                  |  522 ++++
 include/net/netfilter/nf_tables_core.h             |   42 +
 include/net/netfilter/nf_tables_ipv4.h             |   23 +
 include/net/netfilter/nf_tables_ipv6.h             |   30 +
 include/net/netns/nftables.h                       |   19 +
 include/uapi/linux/netfilter/Kbuild                |    2 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |    4 +
 include/uapi/linux/netfilter/nf_tables.h           |  718 +++++
 include/uapi/linux/netfilter/nf_tables_compat.h    |   38 +
 include/uapi/linux/netfilter/nfnetlink.h           |   10 +-
 net/bridge/br_netfilter.c                          |   22 +-
 net/bridge/netfilter/Kconfig                       |    3 +
 net/bridge/netfilter/Makefile                      |    2 +
 net/bridge/netfilter/ebtable_filter.c              |   16 +-
 net/bridge/netfilter/ebtable_nat.c                 |   16 +-
 net/bridge/netfilter/nf_tables_bridge.c            |   65 +
 net/decnet/netfilter/dn_rtmsg.c                    |    2 +-
 net/ipv4/netfilter/Kconfig                         |   21 +
 net/ipv4/netfilter/Makefile                        |    6 +
 net/ipv4/netfilter/arptable_filter.c               |    5 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |    2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |    2 +-
 net/ipv4/netfilter/iptable_filter.c                |    7 +-
 net/ipv4/netfilter/iptable_mangle.c                |   10 +-
 net/ipv4/netfilter/iptable_nat.c                   |   26 +-
 net/ipv4/netfilter/iptable_raw.c                   |    6 +-
 net/ipv4/netfilter/iptable_security.c              |    7 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   12 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                |    6 +-
 net/ipv4/netfilter/nf_tables_arp.c                 |  102 +
 net/ipv4/netfilter/nf_tables_ipv4.c                |  128 +
 net/ipv4/netfilter/nft_chain_nat_ipv4.c            |  205 ++
 net/ipv4/netfilter/nft_chain_route_ipv4.c          |   90 +
 net/ipv4/netfilter/nft_reject_ipv4.c               |  123 +
 net/ipv6/netfilter/Kconfig                         |   13 +
 net/ipv6/netfilter/Makefile                        |    5 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |    2 +-
 net/ipv6/netfilter/ip6table_filter.c               |    5 +-
 net/ipv6/netfilter/ip6table_mangle.c               |   10 +-
 net/ipv6/netfilter/ip6table_nat.c                  |   27 +-
 net/ipv6/netfilter/ip6table_raw.c                  |    5 +-
 net/ipv6/netfilter/ip6table_security.c             |    5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   14 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |    6 +-
 net/ipv6/netfilter/nf_tables_ipv6.c                |  127 +
 net/ipv6/netfilter/nft_chain_nat_ipv6.c            |  211 ++
 net/ipv6/netfilter/nft_chain_route_ipv6.c          |   88 +
 net/netfilter/Kconfig                              |   52 +
 net/netfilter/Makefile                             |   18 +
 net/netfilter/core.c                               |    2 +-
 net/netfilter/ipvs/ip_vs_core.c                    |   42 +-
 net/netfilter/nf_nat_core.c                        |   20 +
 net/netfilter/nf_tables_api.c                      | 3275 ++++++++++++++++++++
 net/netfilter/nf_tables_core.c                     |  270 ++
 net/netfilter/nfnetlink.c                          |  175 +-
 net/netfilter/nft_bitwise.c                        |  146 +
 net/netfilter/nft_byteorder.c                      |  173 ++
 net/netfilter/nft_cmp.c                            |  223 ++
 net/netfilter/nft_compat.c                         |  768 +++++
 net/netfilter/nft_counter.c                        |  113 +
 net/netfilter/nft_ct.c                             |  258 ++
 net/netfilter/nft_expr_template.c                  |   94 +
 net/netfilter/nft_exthdr.c                         |  133 +
 net/netfilter/nft_hash.c                           |  231 ++
 net/netfilter/nft_immediate.c                      |  132 +
 net/netfilter/nft_limit.c                          |  119 +
 net/netfilter/nft_log.c                            |  146 +
 net/netfilter/nft_lookup.c                         |  141 +
 net/netfilter/nft_meta.c                           |  228 ++
 net/netfilter/nft_meta_target.c                    |  117 +
 net/netfilter/nft_nat.c                            |  220 ++
 net/netfilter/nft_payload.c                        |  160 +
 net/netfilter/nft_rbtree.c                         |  247 ++
 security/selinux/hooks.c                           |   10 +-
 78 files changed, 10217 insertions(+), 132 deletions(-)
 create mode 100644 include/net/netfilter/nf_tables.h
 create mode 100644 include/net/netfilter/nf_tables_core.h
 create mode 100644 include/net/netfilter/nf_tables_ipv4.h
 create mode 100644 include/net/netfilter/nf_tables_ipv6.h
 create mode 100644 include/net/netns/nftables.h
 create mode 100644 include/uapi/linux/netfilter/nf_tables.h
 create mode 100644 include/uapi/linux/netfilter/nf_tables_compat.h
 create mode 100644 net/bridge/netfilter/nf_tables_bridge.c
 create mode 100644 net/ipv4/netfilter/nf_tables_arp.c
 create mode 100644 net/ipv4/netfilter/nf_tables_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_chain_nat_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_chain_route_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_reject_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_tables_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_chain_nat_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_chain_route_ipv6.c
 create mode 100644 net/netfilter/nf_tables_api.c
 create mode 100644 net/netfilter/nf_tables_core.c
 create mode 100644 net/netfilter/nft_bitwise.c
 create mode 100644 net/netfilter/nft_byteorder.c
 create mode 100644 net/netfilter/nft_cmp.c
 create mode 100644 net/netfilter/nft_compat.c
 create mode 100644 net/netfilter/nft_counter.c
 create mode 100644 net/netfilter/nft_ct.c
 create mode 100644 net/netfilter/nft_expr_template.c
 create mode 100644 net/netfilter/nft_exthdr.c
 create mode 100644 net/netfilter/nft_hash.c
 create mode 100644 net/netfilter/nft_immediate.c
 create mode 100644 net/netfilter/nft_limit.c
 create mode 100644 net/netfilter/nft_log.c
 create mode 100644 net/netfilter/nft_lookup.c
 create mode 100644 net/netfilter/nft_meta.c
 create mode 100644 net/netfilter/nft_meta_target.c
 create mode 100644 net/netfilter/nft_nat.c
 create mode 100644 net/netfilter/nft_payload.c
 create mode 100644 net/netfilter/nft_rbtree.c
