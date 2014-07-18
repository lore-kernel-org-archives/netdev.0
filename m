From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] Netfilter updates for net-next
Date: Fri, 18 Jul 2014 13:00:54 +0200
Message-ID: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains updates for your net-next tree,
they are:

1) Use kvfree() helper function from x_tables, from Eric Dumazet.

2) Remove extra timer from the conntrack ecache extension, use a
   workqueue instead to redeliver lost events to userspace instead,
   from Florian Westphal.

3) Removal of the ulog targets for ebtables and iptables. The nflog
   infrastructure superseded this almost 9 years ago, time to get rid
   of this code.

4) Replace the list of loggers by an array now that we can only have
   two possible non-overlapping logger flavours, ie. kernel ring buffer
   and netlink logging.

5) Move Eric Dumazet's log buffer code to nf_log to reuse it from
   all of the supported per-family loggers.

6) Consolidate nf_log_packet() as an unified interface for packet logging.
   After this patch, if the struct nf_loginfo is available, it explicitly
   selects the logger that is used.

7) Move ip and ip6 logging code from xt_LOG to the corresponding
   per-family loggers. Thus, x_tables and nf_tables share the same code
   for packet logging.

8) Add generic ARP packet logger, which is used by nf_tables. The
   format aims to be consistent with the output of xt_LOG.

9) Add generic bridge packet logger. Again, this is used by nf_tables
   and it routes the packets to the real family loggers. As a result,
   we get consistent logging format for the bridge family. The ebt_log
   logging code has been intentionally left in place not to break
   backward compatibility since the logging output differs from xt_LOG.

10) Update nft_log to explicitly request the required family logger when
    needed.

11) Finish nft_log so it supports arp, ip, ip6, bridge and inet families.
    Allowing selection between netlink and kernel buffer ring logging.

12) Several fixes coming after the netfilter core logging changes spotted
    by robots.

13) Use IS_ENABLED() macros whenever possible in the netfilter tree,
    from Duan Jiong.

14) Removal of a couple of unnecessary branch before kfree, from Fabian
    Frederick.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

BTW, I would need that you pull net into net-next after this batch, most
likely we'll have another round of nf_tables updates for net-next
that depend on changes that are available in your net tree.

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 5433ba365f6dd9f30899188755eb4b093314732c:

  cxgb4: Fix endian bug introduced in cxgb4 dcb patchset (2014-06-24 12:54:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 16ea4c6b9dde2ff44b2bd8bb459daa283cf3a46e:

  ipvs: Remove dead debug code (2014-07-16 10:07:11 +0900)

----------------------------------------------------------------
Duan Jiong (1):
      netfilter: use IS_ENABLED() macro

Eric Dumazet (1):
      netfilter: x_tables: xt_free_table_info() cleanup

Fabian Frederick (2):
      netfilter: ctnetlink: remove null test before kfree
      ipvs: remove null test before kfree

Fengguang Wu (1):
      netfilter: nft_log: fix coccinelle warnings

Florian Westphal (1):
      netfilter: conntrack: remove timer from ecache extension

Pablo Neira Ayuso (11):
      netfilter: kill ulog targets
      netfilter: nf_log: use an array of loggers instead of list
      netfilter: nf_log: move log buffering to core logging
      netfilter: log: split family specific code to nf_log_{ip,ip6,common}.c files
      netfilter: log: nf_log_packet() as real unified interface
      netfilter: add generic ARP packet logger
      netfilter: bridge: add generic packet logger
      netfilter: nft_log: request explicit logger when loading rules
      netfilter: nft_log: complete logging support
      netfilter: fix several Kconfig problems in NF_LOG_*
      netfilter: xt_LOG: add missing string format in nf_log_packet()

Yannick Brosseau (1):
      ipvs: Remove dead debug code

 include/net/netfilter/nf_conntrack_ecache.h    |   26 +-
 include/net/netfilter/nf_log.h                 |   42 +-
 include/net/netfilter/xt_log.h                 |   54 --
 include/net/netns/conntrack.h                  |    6 +-
 include/uapi/linux/netfilter/nf_tables.h       |    4 +
 include/uapi/linux/netfilter_bridge/Kbuild     |    1 -
 include/uapi/linux/netfilter_bridge/ebt_ulog.h |   38 -
 include/uapi/linux/netfilter_ipv4/Kbuild       |    1 -
 include/uapi/linux/netfilter_ipv4/ipt_ULOG.h   |   49 --
 net/bridge/netfilter/Kconfig                   |   19 +-
 net/bridge/netfilter/Makefile                  |    3 +
 net/bridge/netfilter/ebt_log.c                 |   47 +-
 net/bridge/netfilter/ebt_ulog.c                |  393 -----------
 net/bridge/netfilter/nf_log_bridge.c           |   96 +++
 net/ipv4/netfilter/Kconfig                     |   29 +-
 net/ipv4/netfilter/Makefile                    |    4 +
 net/ipv4/netfilter/ipt_ULOG.c                  |  498 -------------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    4 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |    8 +-
 net/ipv4/netfilter/nf_log_arp.c                |  149 ++++
 net/ipv4/netfilter/nf_log_ipv4.c               |  385 +++++++++++
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |    4 +
 net/ipv4/netfilter/nf_nat_proto_gre.c          |    2 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c         |    2 +-
 net/ipv6/netfilter/Kconfig                     |    5 +
 net/ipv6/netfilter/Makefile                    |    3 +
 net/ipv6/netfilter/nf_log_ipv6.c               |  417 +++++++++++
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |    4 +
 net/netfilter/Kconfig                          |    4 +
 net/netfilter/Makefile                         |    3 +
 net/netfilter/ipvs/ip_vs_ctl.c                 |   86 ---
 net/netfilter/ipvs/ip_vs_sync.c                |    3 +-
 net/netfilter/nf_conntrack_core.c              |   68 +-
 net/netfilter/nf_conntrack_ecache.c            |   96 ++-
 net/netfilter/nf_conntrack_netlink.c           |    3 +-
 net/netfilter/nf_log.c                         |  155 ++++-
 net/netfilter/nf_log_common.c                  |  187 +++++
 net/netfilter/nf_nat_core.c                    |    2 +-
 net/netfilter/nf_nat_proto_common.c            |    2 +-
 net/netfilter/nf_nat_proto_dccp.c              |    2 +-
 net/netfilter/nf_nat_proto_sctp.c              |    2 +-
 net/netfilter/nf_nat_proto_tcp.c               |    2 +-
 net/netfilter/nf_nat_proto_udp.c               |    2 +-
 net/netfilter/nf_nat_proto_udplite.c           |    2 +-
 net/netfilter/nfnetlink_log.c                  |    4 +
 net/netfilter/nft_log.c                        |   98 ++-
 net/netfilter/x_tables.c                       |   23 +-
 net/netfilter/xt_LOG.c                         |  884 +-----------------------
 49 files changed, 1694 insertions(+), 2231 deletions(-)
 delete mode 100644 include/net/netfilter/xt_log.h
 delete mode 100644 include/uapi/linux/netfilter_bridge/ebt_ulog.h
 delete mode 100644 include/uapi/linux/netfilter_ipv4/ipt_ULOG.h
 delete mode 100644 net/bridge/netfilter/ebt_ulog.c
 create mode 100644 net/bridge/netfilter/nf_log_bridge.c
 delete mode 100644 net/ipv4/netfilter/ipt_ULOG.c
 create mode 100644 net/ipv4/netfilter/nf_log_arp.c
 create mode 100644 net/ipv4/netfilter/nf_log_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_log_ipv6.c
 create mode 100644 net/netfilter/nf_log_common.c
