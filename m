From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Wed, 24 Mar 2010 22:26:24 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr>
References: <12c511ca1003181112t6098eeafm30e384e755a42185@mail.gmail.com> <alpine.LSU.2.01.1003192310450.10055@obet.zrqbmnf.qr> <20100324.102759.107122703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tony.luck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33415 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100Ab0CXV0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 17:26:25 -0400
In-Reply-To: <20100324.102759.107122703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Tony Luck observes that the original IFLA_STATS64 submission causes
unaligned accesses. This is because nla_data() returns a pointer to a
memory region that is only aligned to 32 bits.

Using a temporary and memcpying it off would normally fix this,
as in the patch below. During testing however, I still get
unaligned messages even with the patch - and I would not know
what causes this. In fact, adding a printks magically fixes
it. (Bug in gcc-4.4-sparc compiler?)

 	memcpy(v, &a, sizeof(a));
+       printk(KERN_INFO "v=%p a=%p\n", v, &a);


origin git://dev.medozas.de/linux net
mode cherry-pick
parent 1c01fe14a87332cc88266fbd6e598319322eb96f (v2.6.34-rc1-1069-g1c01fe1)
commit 5480c9bb1b418bb09748340257dea1e57efeb18f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Mar 24 19:52:43 2010 +0100

net: fix unaligned access in IFLA_STATS64

Tony Luck observes that the original IFLA_STATS64 submission causes
unaligned accesses. This is because nla_data() returns a pointer to a
memory region that is only aligned to 32 bits. Do some memcpying to
workaround this.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/core/rtnetlink.c |   53 +++++++++++++++++++++--------------------
 1 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e1121f0..473d4b1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -602,36 +602,39 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 }
 
-static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
+static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *v,
 				   const struct net_device_stats *b)
 {
-	a->rx_packets = b->rx_packets;
-	a->tx_packets = b->tx_packets;
-	a->rx_bytes = b->rx_bytes;
-	a->tx_bytes = b->tx_bytes;
-	a->rx_errors = b->rx_errors;
-	a->tx_errors = b->tx_errors;
-	a->rx_dropped = b->rx_dropped;
-	a->tx_dropped = b->tx_dropped;
-
-	a->multicast = b->multicast;
-	a->collisions = b->collisions;
-
-	a->rx_length_errors = b->rx_length_errors;
-	a->rx_over_errors = b->rx_over_errors;
-	a->rx_crc_errors = b->rx_crc_errors;
-	a->rx_frame_errors = b->rx_frame_errors;
-	a->rx_fifo_errors = b->rx_fifo_errors;
-	a->rx_missed_errors = b->rx_missed_errors;
-
-	a->tx_aborted_errors = b->tx_aborted_errors;
-	a->tx_carrier_errors = b->tx_carrier_errors;
-	a->tx_fifo_errors = b->tx_fifo_errors;
-	a->tx_heartbeat_errors = b->tx_heartbeat_errors;
-	a->tx_window_errors = b->tx_window_errors;
-
-	a->rx_compressed = b->rx_compressed;
-	a->tx_compressed = b->tx_compressed;
+	struct rtnl_link_stats64 a;
+
+	a.rx_packets = b->rx_packets;
+	a.tx_packets = b->tx_packets;
+	a.rx_bytes = b->rx_bytes;
+	a.tx_bytes = b->tx_bytes;
+	a.rx_errors = b->rx_errors;
+	a.tx_errors = b->tx_errors;
+	a.rx_dropped = b->rx_dropped;
+	a.tx_dropped = b->tx_dropped;
+
+	a.multicast = b->multicast;
+	a.collisions = b->collisions;
+
+	a.rx_length_errors = b->rx_length_errors;
+	a.rx_over_errors = b->rx_over_errors;
+	a.rx_crc_errors = b->rx_crc_errors;
+	a.rx_frame_errors = b->rx_frame_errors;
+	a.rx_fifo_errors = b->rx_fifo_errors;
+	a.rx_missed_errors = b->rx_missed_errors;
+
+	a.tx_aborted_errors = b->tx_aborted_errors;
+	a.tx_carrier_errors = b->tx_carrier_errors;
+	a.tx_fifo_errors = b->tx_fifo_errors;
+	a.tx_heartbeat_errors = b->tx_heartbeat_errors;
+	a.tx_window_errors = b->tx_window_errors;
+
+	a.rx_compressed = b->rx_compressed;
+	a.tx_compressed = b->tx_compressed;
+	memcpy(v, &a, sizeof(a));
 }
 
 static inline int rtnl_vfinfo_size(const struct net_device *dev)
@@ -734,8 +737,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			sizeof(struct rtnl_link_stats64));
 	if (attr == NULL)
 		goto nla_put_failure;
-
-	stats = dev_get_stats(dev);
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
-- 
# Created with git-export-patch
