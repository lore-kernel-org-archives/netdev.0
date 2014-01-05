From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] netfilter updates for net-next
Date: Mon,  6 Jan 2014 00:12:54 +0100
Message-ID: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ forgot to attach the pull request to this email and cc netdev, resending ]

Hi David,

The following patchset contains Netfilter updates for your net-next tree,
they are:

* Add full port randomization support. Some crazy researchers found a way
  to reconstruct the secure ephemeral ports that are allocated in random mode
  by sending off-path bursts of UDP packets to overrun the socket buffer of
  the DNS resolver to trigger retransmissions, then if the timing for the
  DNS resolution done by a client is larger than usual, then they conclude
  that the port that received the burst of UDP packets is the one that was
  opened. It seems a bit aggressive method to me but it seems to work for
  them. As a result, Daniel Borkmann and Hannes Frederic Sowa came up with a
  new NAT mode to fully randomize ports using prandom.

* Add a new classifier to x_tables based on the socket net_cls set via
  cgroups. These includes two patches to prepare the field as requested by
  Zefan Li. Also from Daniel Borkmann.

* Use prandom instead of get_random_bytes in several locations of the
  netfilter code, from Florian Westphal.

* Allow to use the CTA_MARK_MASK in ctnetlink when mangling the conntrack
  mark, also from Florian Westphal.

* Fix compilation warning due to unused variable in IPVS, from Geert
  Uytterhoeven.

* Add support for UID/GID via nfnetlink_queue, from Valentina Giusti.

* Add IPComp extension to x_tables, from Fan Du.

* Several patches to remove dead code, by Stephen Hemminger.

* Reorder netns structure for conntrack, based on original patch from Eric
  Dumazet, from Jesper D. Brouer.

You can pull these changes from:

 git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 68536053600425c24aba031c45f053d447eedd9c:

  ipv6: fix incorrect type in declaration (2013-12-12 16:14:09 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 82a37132f300ea53bdcd812917af5a6329ec80c3:

  netfilter: x_tables: lightweight process control group matching (2014-01-03 23:41:44 +0100)

----------------------------------------------------------------
Daniel Borkmann (4):
      netfilter: nf_nat: add full port randomization support
      net: net_cls: move cgroupfs classid handling into core
      net: netprio: rename config to be more consistent with cgroup configs
      netfilter: x_tables: lightweight process control group matching

Eric Leblond (1):
      netfilter: xt_CT: fix error value in xt_ct_tg_check()

Florian Westphal (2):
      netfilter: avoid get_random_bytes calls
      netfilter: ctnetlink: honor CTA_MARK_MASK when setting ctmark

Geert Uytterhoeven (1):
      ipvs: Remove unused variable ret from sync_thread_master()

Jesper Dangaard Brouer (1):
      net: reorder struct netns_ct for better cache-line usage

Valentina Giusti (1):
      netfilter: nfnetlink_queue: enable UID/GID socket info retrieval

fan.du (1):
      netfilter: add IPv4/6 IPComp extension match support

stephen hemminger (2):
      netfilter: ipset: remove unused code
      netfilter: nf_conntrack: remove dead code

 Documentation/cgroups/net_cls.txt              |    5 +
 include/linux/cgroup_subsys.h                  |    4 +-
 include/linux/netdevice.h                      |    2 +-
 include/linux/netfilter/ipset/ip_set.h         |    1 -
 include/net/cls_cgroup.h                       |   40 +++-----
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |    2 -
 include/net/netfilter/nf_conntrack_l3proto.h   |    1 -
 include/net/netns/conntrack.h                  |   33 +++----
 include/net/netprio_cgroup.h                   |   18 ++--
 include/net/sock.h                             |    2 +-
 include/uapi/linux/netfilter/Kbuild            |    2 +
 include/uapi/linux/netfilter/nf_nat.h          |   12 ++-
 include/uapi/linux/netfilter/nfnetlink_queue.h |    5 +-
 include/uapi/linux/netfilter/xt_cgroup.h       |   11 +++
 include/uapi/linux/netfilter/xt_ipcomp.h       |   16 ++++
 net/Kconfig                                    |   11 ++-
 net/core/Makefile                              |    3 +-
 net/core/dev.c                                 |    2 +-
 net/core/netclassid_cgroup.c                   |  120 ++++++++++++++++++++++++
 net/core/sock.c                                |   14 +--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 --
 net/netfilter/Kconfig                          |   19 ++++
 net/netfilter/Makefile                         |    2 +
 net/netfilter/ipset/ip_set_core.c              |   28 ------
 net/netfilter/ipvs/ip_vs_sync.c                |    5 +-
 net/netfilter/nf_conntrack_core.c              |   15 ---
 net/netfilter/nf_conntrack_netlink.c           |   12 ++-
 net/netfilter/nf_conntrack_proto.c             |    6 --
 net/netfilter/nf_nat_core.c                    |    4 +-
 net/netfilter/nf_nat_proto_common.c            |   10 +-
 net/netfilter/nfnetlink_log.c                  |    8 --
 net/netfilter/nfnetlink_queue_core.c           |   34 +++++++
 net/netfilter/nft_hash.c                       |    2 +-
 net/netfilter/xt_CT.c                          |    4 +-
 net/netfilter/xt_RATEEST.c                     |    2 +-
 net/netfilter/xt_cgroup.c                      |   71 ++++++++++++++
 net/netfilter/xt_connlimit.c                   |    2 +-
 net/netfilter/xt_hashlimit.c                   |    2 +-
 net/netfilter/xt_ipcomp.c                      |  111 ++++++++++++++++++++++
 net/netfilter/xt_recent.c                      |    2 +-
 net/sched/Kconfig                              |    1 +
 net/sched/cls_cgroup.c                         |  111 +---------------------
 42 files changed, 487 insertions(+), 274 deletions(-)
 create mode 100644 include/uapi/linux/netfilter/xt_cgroup.h
 create mode 100644 include/uapi/linux/netfilter/xt_ipcomp.h
 create mode 100644 net/core/netclassid_cgroup.c
 create mode 100644 net/netfilter/xt_cgroup.c
 create mode 100644 net/netfilter/xt_ipcomp.c
