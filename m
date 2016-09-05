From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/29] Netfilter updates for net-next
Date: Mon,  5 Sep 2016 12:58:15 +0200
Message-ID: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35060 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932217AbcIEK6z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:58:55 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 21A5E2EFEB9
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0EB671150C7
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9339114D61
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree.  Most relevant updates are the removal of per-conntrack timers to
use a workqueue/garbage collection approach instead from Florian
Westphal, the hash and numgen expression for nf_tables from Laura
Garcia, updates on nf_tables hash set to honor the NLM_F_EXCL flag,
removal of ip_conntrack sysctl and many other incremental updates on our
Netfilter codebase.

More specifically, they are:

1) Retrieve only 4 bytes to fetch ports in case of non-linear skb
   transport area in dccp, sctp, tcp, udp and udplite protocol
   conntrackers, from Gao Feng.

2) Missing whitespace on error message in physdev match, from Hangbin Liu.

3) Skip redundant IPv4 checksum calculation in nf_dup_ipv4, from Liping Zhang.

4) Add nf_ct_expires() helper function and use it, from Florian Westphal.

5) Replace opencoded nf_ct_kill() call in IPVS conntrack support, also
   from Florian.

6) Rename nf_tables set implementation to nft_set_{name}.c

7) Introduce the hash expression to allow arbitrary hashing of selector
   concatenations, from Laura Garcia Liebana.

8) Remove ip_conntrack sysctl backward compatibility code, this code has
   been around for long time already, and we have two interfaces to do
   this already: nf_conntrack sysctl and ctnetlink.

9) Use nf_conntrack_get_ht() helper function whenever possible, instead
   of opencoding fetch of hashtable pointer and size, patch from Liping Zhang.

10) Add quota expression for nf_tables.

11) Add number generator expression for nf_tables, this supports
    incremental and random generators that can be combined with maps,
    very useful for load balancing purpose, again from Laura Garcia Liebana.

12) Fix a typo in a debug message in FTP conntrack helper, from Colin Ian King.

13) Introduce a nft_chain_parse_hook() helper function to parse chain hook
    configuration, this is used by a follow up patch to perform better chain
    update validation.

14) Add rhashtable_lookup_get_insert_key() to rhashtable and use it from the
    nft_set_hash implementation to honor the NLM_F_EXCL flag.

15) Missing nulls check in nf_conntrack from nf_conntrack_tuple_taken(),
    patch from Florian Westphal.

16) Don't use the DYING bit to know if the conntrack event has been already
    delivered, instead a state variable to track event re-delivery
    states, also from Florian.

17) Remove the per-conntrack timer, use the workqueue approach that was
    discussed during the NFWS, from Florian Westphal.

18) Use the netlink conntrack table dump path to kill stale entries,
    again from Florian.

19) Add a garbage collector to get rid of stale conntracks, from
    Florian.

20) Reschedule garbage collector if eviction rate is high.

21) Get rid of the __nf_ct_kill_acct() helper.

22) Use ARPHRD_ETHER instead of hardcoded 1 from ARP logger.

23) Make nf_log_set() interface assertive on unsupported families.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit f08aff444ae0004c9ae6df3241fc313a5024d375:

  net: ethernet: renesas: sh_eth: use new api ethtool_{get|set}_link_ksettings (2016-08-10 23:14:53 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 779994fa3636d46848edb402fe7517968e036e6f:

  netfilter: log: Check param to avoid overflow in nf_log_set (2016-08-30 11:52:32 +0200)

----------------------------------------------------------------
Colin Ian King (1):
      netfilter: fix spelling mistake: "delimitter" -> "delimiter"

Florian Westphal (9):
      netfilter: use_nf_conn_expires helper in more places
      ipvs: use nf_ct_kill helper
      netfilter: restart search if moved to other chain
      netfilter: don't rely on DYING bit to detect when destroy event was sent
      netfilter: conntrack: get rid of conntrack timer
      netfilter: evict stale entries on netlink dumps
      netfilter: conntrack: add gc worker to remove timed-out entries
      netfilter: conntrack: resched gc again if eviction rate is high
      netfilter: remove __nf_ct_kill_acct helper

Gao Feng (3):
      netfilter: conntrack: Only need first 4 bytes to get l4proto ports
      netfilter: log_arp: Use ARPHRD_ETHER instead of literal '1'
      netfilter: log: Check param to avoid overflow in nf_log_set

Hangbin Liu (1):
      netfilter: physdev: add missed blank

Laura Garcia Liebana (2):
      netfilter: nf_tables: add hash expression
      netfilter: nf_tables: add number generator expression

Liping Zhang (2):
      netfilter: nf_dup4: remove redundant checksum recalculation
      netfilter: conntrack: simplify the code by using nf_conntrack_get_ht

Pablo Neira (1):
      netfilter: nf_tables: typo in trace attribute definition

Pablo Neira Ayuso (9):
      netfilter: nf_tables: rename set implementations
      netfilter: remove ip_conntrack* sysctl compat code
      netfilter: nf_conntrack: restore nf_conntrack_htable_size as exported symbol
      netfilter: nf_tables: add quota expression
      netfilter: nf_tables: introduce nft_chain_parse_hook()
      netfilter: nf_tables: reject hook configuration updates on existing chains
      rhashtable: add rhashtable_lookup_get_insert_key()
      netfilter: nf_tables: honor NLM_F_EXCL flag in set element insertion
      netfilter: nf_tables: Use nla_put_be32() to dump immediate parameters

Wei Yongjun (1):
      netfilter: nft_hash: fix non static symbol warning

 include/linux/rhashtable.h                         |  70 ++-
 include/net/netfilter/nf_conntrack.h               |  56 ++-
 include/net/netfilter/nf_conntrack_core.h          |   3 -
 include/net/netfilter/nf_conntrack_ecache.h        |  17 +-
 include/net/netfilter/nf_conntrack_l4proto.h       |   8 -
 include/net/netfilter/nf_log.h                     |   3 +-
 include/net/netfilter/nf_tables.h                  |   3 +-
 include/net/netns/conntrack.h                      |   8 -
 include/uapi/linux/netfilter/nf_tables.h           |  65 ++-
 lib/rhashtable.c                                   |  10 +-
 net/bridge/netfilter/nf_log_bridge.c               |   3 +-
 net/ipv4/netfilter/Kconfig                         |  11 -
 net/ipv4/netfilter/Makefile                        |   5 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |  70 ---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 492 ---------------------
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |  39 +-
 net/ipv4/netfilter/nf_dup_ipv4.c                   |  10 +-
 net/ipv4/netfilter/nf_log_arp.c                    |   5 +-
 net/ipv4/netfilter/nf_log_ipv4.c                   |   3 +-
 net/ipv6/netfilter/nf_log_ipv6.c                   |   3 +-
 net/netfilter/Kconfig                              |  22 +-
 net/netfilter/Makefile                             |   7 +-
 net/netfilter/ipvs/ip_vs_nfct.c                    |   7 +-
 net/netfilter/nf_conntrack_core.c                  | 229 ++++++----
 net/netfilter/nf_conntrack_ecache.c                |  22 +-
 net/netfilter/nf_conntrack_ftp.c                   |   2 +-
 net/netfilter/nf_conntrack_netlink.c               |  44 +-
 net/netfilter/nf_conntrack_pptp.c                  |   3 +-
 net/netfilter/nf_conntrack_proto.c                 |  81 +---
 net/netfilter/nf_conntrack_proto_dccp.c            |   3 +-
 net/netfilter/nf_conntrack_proto_generic.c         |  39 +-
 net/netfilter/nf_conntrack_proto_sctp.c            |  89 +---
 net/netfilter/nf_conntrack_proto_tcp.c             | 131 +-----
 net/netfilter/nf_conntrack_proto_udp.c             |  53 +--
 net/netfilter/nf_conntrack_proto_udplite.c         |   3 +-
 net/netfilter/nf_conntrack_standalone.c            |   3 +-
 net/netfilter/nf_log.c                             |   8 +-
 net/netfilter/nf_nat_core.c                        |   6 -
 net/netfilter/nf_tables_api.c                      | 203 ++++++---
 net/netfilter/nft_hash.c                           | 417 ++++-------------
 net/netfilter/nft_numgen.c                         | 192 ++++++++
 net/netfilter/nft_quota.c                          | 121 +++++
 net/netfilter/nft_set_hash.c                       | 404 +++++++++++++++++
 net/netfilter/{nft_rbtree.c => nft_set_rbtree.c}   |  12 +-
 net/netfilter/xt_conntrack.c                       |   4 +-
 net/netfilter/xt_physdev.c                         |   4 +-
 46 files changed, 1380 insertions(+), 1613 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
 create mode 100644 net/netfilter/nft_numgen.c
 create mode 100644 net/netfilter/nft_quota.c
 create mode 100644 net/netfilter/nft_set_hash.c
 rename net/netfilter/{nft_rbtree.c => nft_set_rbtree.c} (97%)
