From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK 00/04]: Consistent dump callback locking
Date: Mon, 16 Apr 2007 09:51:51 +0200 (MEST)
Message-ID: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396AbXDPHvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:51:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches change netlink to provide consistent locking in dump callbacks.
Currently the first invocation of the callbacks happens under the queue
processing mutex and ->cb_lock of the dumping socket, further invocations only
under cb_lock. The first patch replaces the cb_lock spinlock by a mutex and
allows netlink_kernel_create users to override it with a subsystem specific
mutex, the second patch makes use of this for rtnetlink. The third and fourth
patches remove some locking that is not needed anymore.

Please apply, thanks.


 drivers/connector/connector.c       |    2 -
 drivers/scsi/scsi_netlink.c         |    3 +-
 drivers/scsi/scsi_transport_iscsi.c |    2 -
 fs/ecryptfs/netlink.c               |    2 -
 include/linux/netlink.h             |    5 +++-
 include/net/pkt_sched.h             |    2 -
 kernel/audit.c                      |    2 -
 lib/kobject_uevent.c                |    2 -
 net/bridge/br_netlink.c             |    2 -
 net/bridge/netfilter/ebt_ulog.c     |    2 -
 net/core/fib_rules.c                |    4 ---
 net/core/rtnetlink.c                |   12 ++++++-----
 net/decnet/dn_dev.c                 |    3 --
 net/decnet/netfilter/dn_rtmsg.c     |    2 -
 net/ipv4/devinet.c                  |   12 +----------
 net/ipv4/fib_frontend.c             |    3 +-
 net/ipv4/inet_diag.c                |    2 -
 net/ipv4/netfilter/ip_queue.c       |    2 -
 net/ipv4/netfilter/ipt_ULOG.c       |    2 -
 net/ipv6/addrconf.c                 |    2 -
 net/ipv6/netfilter/ip6_queue.c      |    2 -
 net/netfilter/nfnetlink.c           |    2 -
 net/netlink/af_netlink.c            |   38 +++++++++++++++++++++---------------
 net/netlink/genetlink.c             |    2 -
 net/sched/cls_api.c                 |    2 -
 net/sched/sch_api.c                 |   22 ++------------------
 net/sched/sch_generic.c             |   29 ++++++---------------------
 net/xfrm/xfrm_user.c                |    2 -
 security/selinux/netlink.c          |    2 -
 29 files changed, 66 insertions(+), 103 deletions(-)

Patrick McHardy (4):
      [NETLINK]: Switch cb_lock spinlock to mutex and allow to override it
      [RTNETLINK]: Hold rtnl_mutex during netlink dump callbacks
      [RTNETLINK]: Remove unnecessary locking in dump callbacks
      [NET_SCHED]: Eliminate qdisc_tree_lock
