From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] veth: fix 64bit stats on 32bit arches
Date: Mon, 20 Jun 2011 07:46:12 +0200
Message-ID: <1308548772.3539.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:33225 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab1FTFqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 01:46:22 -0400
Received: by wwg11 with SMTP id 11so1880603wwg.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 22:46:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 64bit stats on 32bit arches must use a synchronization or readers
can get transient values.

Fixes bug introduced in commit 6311cc44a2 (veth: convert to 64 bit
statistics)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/veth.c |   55 ++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 18 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8730d64..8acb3af 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
+#include <linux/u64_stats_sync.h>
 
 #include <net/dst.h>
 #include <net/xfrm.h>
@@ -24,12 +25,13 @@
 #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
 
 struct veth_net_stats {
-	u64	rx_packets;
-	u64	tx_packets;
-	u64	rx_bytes;
-	u64	tx_bytes;
-	u64	tx_dropped;
-	u64	rx_dropped;
+	u64			rx_packets;
+	u64			tx_packets;
+	u64			rx_bytes;
+	u64			tx_bytes;
+	u64			rx_dropped;
+	u64			tx_dropped;
+	struct u64_stats_sync	syncp;
 };
 
 struct veth_priv {
@@ -137,21 +139,29 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dev_forward_skb(rcv, skb) != NET_RX_SUCCESS)
 		goto rx_drop;
 
+	u64_stats_update_begin(&stats->syncp);
 	stats->tx_bytes += length;
 	stats->tx_packets++;
+	u64_stats_update_end(&stats->syncp);
 
+	u64_stats_update_begin(&rcv_stats->syncp);
 	rcv_stats->rx_bytes += length;
 	rcv_stats->rx_packets++;
+	u64_stats_update_end(&rcv_stats->syncp);
 
 	return NETDEV_TX_OK;
 
 tx_drop:
 	kfree_skb(skb);
+	u64_stats_update_begin(&stats->syncp);
 	stats->tx_dropped++;
+	u64_stats_update_end(&stats->syncp);
 	return NETDEV_TX_OK;
 
 rx_drop:
+	u64_stats_update_begin(&rcv_stats->syncp);
 	rcv_stats->rx_dropped++;
+	u64_stats_update_end(&rcv_stats->syncp);
 	return NETDEV_TX_OK;
 }
 
@@ -162,21 +172,30 @@ rx_drop:
 static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
-	struct veth_priv *priv;
+	struct veth_priv *priv = netdev_priv(dev);
 	int cpu;
-	struct veth_net_stats *stats;
-
-	priv = netdev_priv(dev);
 
 	for_each_possible_cpu(cpu) {
-		stats = per_cpu_ptr(priv->stats, cpu);
-
-		tot->rx_packets += stats->rx_packets;
-		tot->tx_packets += stats->tx_packets;
-		tot->rx_bytes   += stats->rx_bytes;
-		tot->tx_bytes   += stats->tx_bytes;
-		tot->tx_dropped += stats->tx_dropped;
-		tot->rx_dropped += stats->rx_dropped;
+		struct veth_net_stats *stats = per_cpu_ptr(priv->stats, cpu);
+		u64 rx_packets, rx_bytes, rx_dropped;
+		u64 tx_packets, tx_bytes, tx_dropped;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			rx_packets = stats->rx_packets;
+			tx_packets = stats->tx_packets;
+			rx_bytes = stats->rx_bytes;
+			tx_bytes = stats->tx_bytes;
+			rx_dropped = stats->rx_dropped;
+			tx_dropped = stats->tx_dropped;
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+		tot->rx_dropped += rx_dropped;
+		tot->tx_dropped += tx_dropped;
 	}
 
 	return tot;


