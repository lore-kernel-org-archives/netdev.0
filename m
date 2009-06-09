From: Patrick McHardy <kaber@trash.net>
Subject: [RFC net 00/03]: dev_queue_xmit error propagation
Date: Tue,  9 Jun 2009 18:16:59 +0200 (MEST)
Message-ID: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33716 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbZFIQQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:16:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the ->ndo_hard_start_xmit() callbacks are only permitted to return
one of the NETDEV_TX codes. This prevents any kind of error propagation for
virtual devices, like queue congestion of the underlying device in case of
layered devices, or unreachability in case of tunnels.

These patches change the return conventions so hard_start_xmit() can return
a NETDEV_TX code, an errno code or a NET_XMIT code. This means it can
additionally to the NETDEV_TX codes simply return the value of dev_queue_xmit().

When queueing is used, errors can't be propagated back since transmission is
asynchronously and all non-NETDEV codes are mapped to NETDEV_TX_OK, reflecting
the fact that the skb is consumed unconditionally.

In case of virtual devices not using queueing, the NETDEV_TX codes are consumed
by dev_queue_xmit(), everything else is returned to the higher layers.

The end result is that virtual network devices can propagate queue congestion
state of the underlying device, or other errors, back to the socket layer.
One immediately useful effect is that TCP can make use of this information
as is currently done with non-virtual devices. But it also seems useful in case
of tunnels, which can return more meaningful errors, or for statistics.

Comments welcome. A review of my changes in dev_hard_start_xmit() would be
especially appreciated :)


 include/linux/netdevice.h |   39 +++++++++++++++++++++++++++++----------
 net/8021q/vlan_dev.c      |   29 ++++++++++++++++++++++-------
 net/core/dev.c            |    7 +++++--
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_generic.c   |   10 +++++++++-
 net/sched/sch_sfq.c       |    2 +-
 net/sched/sch_tbf.c       |    4 ++--
 net/sched/sch_teql.c      |    2 +-
 8 files changed, 71 insertions(+), 26 deletions(-)

Patrick McHardy (3):
      net-sched: use symbolic NET_XMIT constants in qdiscs
      net: allow to propagate errors through ->ndo_hard_start_xmit()
      vlan: propagate transmission state
