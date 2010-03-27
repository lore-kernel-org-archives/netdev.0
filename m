From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Sat, 27 Mar 2010 13:14:46 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003271313230.2740@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr> <m2vdcl5ocj.fsf@igel.home> <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr> <20100324.203249.97351120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: schwab@linux-m68k.org, tony.luck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:49090 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910Ab0C0MOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 08:14:47 -0400
In-Reply-To: <20100324.203249.97351120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-03-25 04:32, David Miller wrote:
>From: Jan Engelhardt
>Date: Thu, 25 Mar 2010 00:17:01 +0100 (CET)
>
>> No more unaligned messages - but is this [using void*]
>> an acceptable solution?
>
>We already rely on this elsewhere, particularly in the
>xfrm_user code.

Ok, here's it. (We're also getting rid of the double-obtain statistics
that was mentioned in the initial submission.)


Please apply this one, or pull, or cherry-pick from
	git://dev.medozas.de/linux net

parent b79d1d54cf0672f764402fe4711ef5306f917bd3 (v2.6.34-rc1-1275-gb79d1d5)
commit c5c57d7c7837858aa499610a3ee760b39f1de937
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Mar 24 19:52:43 2010 +0100

net: fix unaligned access in IFLA_STATS64

Tony Luck observes that the original IFLA_STATS64 submission causes
unaligned accesses. This is because nla_data() returns a pointer to a
memory region that is only aligned to 32 bits. Do some memcpying to
workaround this.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/core/rtnetlink.c |   54 +++++++++++++++++++++---------------------
 1 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ffc6cf3..ed0766f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -602,36 +602,38 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 }
 
-static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
-				   const struct net_device_stats *b)
+static void copy_rtnl_link_stats64(void *v, const struct net_device_stats *b)
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
@@ -734,8 +736,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			sizeof(struct rtnl_link_stats64));
 	if (attr == NULL)
 		goto nla_put_failure;
-
-	stats = dev_get_stats(dev);
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
-- 
# Created with git-export-patch
