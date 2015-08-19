From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/15] Netfilter updates for net-next
Date: Wed, 19 Aug 2015 21:18:16 +0200
Message-ID: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next tree, they
are:

1) Rework the existing nf_tables counter expression to make it per-cpu.

2) Prepare and factor out common packet duplication code from the TEE target so
   it can be reused from the new dup expression.

3) Add the new dup expression for the nf_tables IPv4 and IPv6 families.

4) Convert the nf_tables limit expression to use a token-based approach with
   64-bits precision.

5) Enhance the nf_tables limit expression to support limiting at packet byte.
   This comes after several preparation patches.

6) Add a burst parameter to indicate the amount of packets or bytes that can
   exceed the limiting.

7) Add netns support to nfacct, from Andreas Schultz.

8) Pass the nf_conn_zone structure instead of the zone ID in nf_tables to allow
   accessing more zone specific information, from Daniel Borkmann.

9) Allow to define zone per-direction to support netns containers with
   overlapping network addressing, also from Daniel.

10) Extend the CT target to allow setting the zone based on the skb->mark as a
   way to support simple mappings from iptables, also from Daniel.

11) Make the nf_tables payload expression aware of the fact that VLAN offload
    may have removed a vlan header, from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit d92cff89a0c80e7e49796366e441d97f07b5d321:

  net_dbg_ratelimited: turn into no-op when !DEBUG (2015-08-06 23:51:30 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 8cfd23e6740158817d2045915f6ea5a2daf11bce:

  netfilter: nft_payload: work around vlan header stripping (2015-08-19 08:39:53 +0200)

----------------------------------------------------------------
Andreas Schultz (1):
      netfilter: nfacct: per network namespace support

Daniel Borkmann (3):
      netfilter: nf_conntrack: push zone object into functions
      netfilter: nf_conntrack: add direction support for zones
      netfilter: nf_conntrack: add efficient mark to zone mapping

Florian Westphal (1):
      netfilter: nft_payload: work around vlan header stripping

Pablo Neira Ayuso (10):
      netfilter: nft_counter: convert it to use per-cpu counters
      netfilter: xt_TEE: get rid of WITH_CONNTRACK definition
      netfilter: factor out packet duplication for IPv4/IPv6
      netfilter: nf_tables: add nft_dup expression
      netfilter: nft_limit: rename to nft_limit_pkts
      netfilter: nft_limit: convert to token-based limiting at nanosecond granularity
      netfilter: nft_limit: factor out shared code with per-byte limiting
      netfilter: nft_limit: add burst parameter
      netfilter: nft_limit: constant token cost per packet
      netfilter: nft_limit: add per-byte limiting

 include/linux/netfilter/nfnetlink_acct.h           |    3 +-
 include/net/net_namespace.h                        |    3 +
 include/net/netfilter/ipv4/nf_dup_ipv4.h           |    7 +
 include/net/netfilter/ipv6/nf_dup_ipv6.h           |    7 +
 include/net/netfilter/nf_conntrack.h               |   10 +-
 include/net/netfilter/nf_conntrack_core.h          |    3 +-
 include/net/netfilter/nf_conntrack_expect.h        |   11 +-
 include/net/netfilter/nf_conntrack_zones.h         |   99 ++++++++-
 include/net/netfilter/nft_dup.h                    |    9 +
 include/uapi/linux/netfilter/nf_tables.h           |   23 ++
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/uapi/linux/netfilter/xt_CT.h               |    8 +-
 net/ipv4/netfilter/Kconfig                         |   12 ++
 net/ipv4/netfilter/Makefile                        |    3 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |    4 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                |   17 +-
 net/ipv4/netfilter/nf_dup_ipv4.c                   |  120 +++++++++++
 net/ipv4/netfilter/nft_dup_ipv4.c                  |  110 ++++++++++
 net/ipv6/netfilter/Kconfig                         |   12 ++
 net/ipv6/netfilter/Makefile                        |    3 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |    5 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |   18 +-
 net/ipv6/netfilter/nf_dup_ipv6.c                   |   96 +++++++++
 net/ipv6/netfilter/nft_dup_ipv6.c                  |  108 ++++++++++
 net/netfilter/Kconfig                              |    2 +
 net/netfilter/ipvs/ip_vs_nfct.c                    |    2 +-
 net/netfilter/nf_conntrack_core.c                  |  134 ++++++------
 net/netfilter/nf_conntrack_expect.c                |   21 +-
 net/netfilter/nf_conntrack_netlink.c               |  228 ++++++++++++++------
 net/netfilter/nf_conntrack_pptp.c                  |    3 +-
 net/netfilter/nf_conntrack_standalone.c            |   39 +++-
 net/netfilter/nf_nat_core.c                        |   24 ++-
 net/netfilter/nf_synproxy_core.c                   |    4 +-
 net/netfilter/nfnetlink_acct.c                     |   71 ++++--
 net/netfilter/nft_counter.c                        |   97 ++++++---
 net/netfilter/nft_limit.c                          |  188 ++++++++++++----
 net/netfilter/nft_payload.c                        |   57 ++++-
 net/netfilter/xt_CT.c                              |   26 ++-
 net/netfilter/xt_TEE.c                             |  160 +-------------
 net/netfilter/xt_connlimit.c                       |    9 +-
 net/netfilter/xt_nfacct.c                          |    2 +-
 net/sched/act_connmark.c                           |    6 +-
 44 files changed, 1319 insertions(+), 450 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_dup_ipv4.h
 create mode 100644 include/net/netfilter/ipv6/nf_dup_ipv6.h
 create mode 100644 include/net/netfilter/nft_dup.h
 create mode 100644 net/ipv4/netfilter/nf_dup_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_dup_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_dup_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_dup_ipv6.c
