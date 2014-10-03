From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter/IPVS updates for net-next
Date: Fri,  3 Oct 2014 19:20:15 +0200
Message-ID: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains another batch with Netfilter/IPVS updates
for net-next, they are:

1) Add abstracted ICMP codes to the nf_tables reject expression. We
   introduce four reasons to reject using ICMP that overlap in IPv4
   and IPv6 from the semantic point of view. This should simplify the
   maintainance of dual stack rule-sets through the inet table.

2) Move nf_send_reset() functions from header files to per-family
   nf_reject modules, suggested by Patrick McHardy.

3) We have to use IS_ENABLED(CONFIG_BRIDGE_NETFILTER) everywhere in the
   code now that br_netfilter can be modularized. Convert remaining spots
   in the network stack code.

4) Use rcu_barrier() in the nf_tables module removal path to ensure that
   we don't leave object that are still pending to be released via
   call_rcu (that may likely result in a crash).

5) Remove incomplete arch 32/64 compat from nft_compat. The original (bad)
   idea was to probe the word size based on the xtables match/target info
   size, but this assumption is wrong when you have to dump the information
   back to userspace.

6) Allow to filter from prerouting and postrouting in the nf_tables bridge.
   In order to emulate the ebtables NAT chains (which are actually simple
   filter chains with no special semantics), we have support filtering from
   this hooks too.

7) Add explicit module dependency between xt_physdev and br_netfilter.
   This provides a way to detect if the user needs br_netfilter from
   the configuration path. This should reduce the breakage of the
   br_netfilter modularization.

8) Cleanup coding style in ip_vs.h, from Simon Horman.

9) Fix crash in the recently added nf_tables masq expression. We have
   to register/unregister the notifiers to clean up the conntrack table
   entries from the module init/exit path, not from the rule addition /
   deletion path. From Arturo Borrero.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2c804d0f8fc7799981d9fdd8c88653541b28c1a7:

  ipv4: mentions skb_gro_postpull_rcsum() in inet_gro_receive() (2014-10-01 13:44:05 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 8da4cc1b10c1aeba090d1d862b17174e4dbd50a4:

  netfilter: nft_masq: register/unregister notifiers on module init/exit (2014-10-03 14:24:35 +0200)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nft_masq: register/unregister notifiers on module init/exit

Pablo Neira Ayuso (7):
      netfilter: nft_reject: introduce icmp code abstraction for inet and bridge
      netfilter: move nf_send_resetX() code to nf_reject_ipvX modules
      netfilter: use IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
      netfilter: nf_tables: wait for call_rcu completion on module removal
      netfilter: nft_compat: remove incomplete 32/64 bits arch compat code
      netfilter: nf_tables: allow to filter from prerouting and postrouting
      netfilter: explicit module dependency between br_netfilter and physdev

Simon Horman (1):
      ipvs: Clean up comment style in ip_vs.h

 include/net/ip_vs.h                        |  214 ++++++++++------------------
 include/net/netfilter/br_netfilter.h       |    6 +
 include/net/netfilter/ipv4/nf_reject.h     |  119 +---------------
 include/net/netfilter/nft_reject.h         |    9 +-
 include/uapi/linux/netfilter/nf_tables.h   |   21 +++
 net/bridge/br_netfilter.c                  |    5 +
 net/bridge/netfilter/nf_tables_bridge.c    |    2 +
 net/bridge/netfilter/nft_reject_bridge.c   |   95 +++++++++++-
 net/core/skbuff.c                          |    2 +-
 net/ipv4/ip_output.c                       |    2 +-
 net/ipv4/netfilter/Kconfig                 |    6 +
 net/ipv4/netfilter/Makefile                |    3 +
 net/ipv4/netfilter/ipt_REJECT.c            |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c        |    2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c        |  127 +++++++++++++++++
 net/ipv4/netfilter/nft_masq_ipv4.c         |   34 ++---
 net/ipv4/netfilter/nft_reject_ipv4.c       |    1 -
 net/ipv6/netfilter/Kconfig                 |    6 +
 net/ipv6/netfilter/Makefile                |    3 +
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c  |    2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c        |  163 +++++++++++++++++++++
 net/ipv6/netfilter/nft_masq_ipv6.c         |   34 ++---
 net/netfilter/ipset/ip_set_hash_netiface.c |    4 +-
 net/netfilter/nf_log_common.c              |    2 +-
 net/netfilter/nf_queue.c                   |    4 +-
 net/netfilter/nf_tables_api.c              |    1 +
 net/netfilter/nfnetlink_log.c              |    8 +-
 net/netfilter/nfnetlink_queue_core.c       |   12 +-
 net/netfilter/nft_compat.c                 |  116 ++-------------
 net/netfilter/nft_reject.c                 |   37 +++++
 net/netfilter/nft_reject_inet.c            |   94 +++++++++++-
 net/netfilter/xt_physdev.c                 |    3 +
 32 files changed, 699 insertions(+), 440 deletions(-)
 create mode 100644 include/net/netfilter/br_netfilter.h
 create mode 100644 net/ipv4/netfilter/nf_reject_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_reject_ipv6.c
