From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] veth: convert to 64 bit statistics
Date: Wed, 08 Jun 2011 17:53:59 -0700
Message-ID: <20110609005417.449670103@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285Ab1FIBQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:30 -0400
Content-Disposition: inline; filename=veth-stats64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not much change, device was already keeping per cpu statistics.
Use recent 64 statistics interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/veth.c	2011-06-07 20:04:42.221679879 +0900
+++ b/drivers/net/veth.c	2011-06-07 20:10:04.259276778 +0900
@@ -24,12 +24,12 @@
 #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
 
 struct veth_net_stats {
-	unsigned long	rx_packets;
-	unsigned long	tx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_bytes;
-	unsigned long	tx_dropped;
-	unsigned long	rx_dropped;
+	u64	rx_packets;
+	u64	tx_packets;
+	u64	rx_bytes;
+	u64	tx_bytes;
+	u64	tx_dropped;
+	u64	rx_dropped;
 };
 
 struct veth_priv {
@@ -159,32 +159,27 @@ rx_drop:
  * general routines
  */
 
-static struct net_device_stats *veth_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
+						  struct rtnl_link_stats64 *tot)
 {
 	struct veth_priv *priv;
 	int cpu;
-	struct veth_net_stats *stats, total = {0};
+	struct veth_net_stats *stats;
 
 	priv = netdev_priv(dev);
 
 	for_each_possible_cpu(cpu) {
 		stats = per_cpu_ptr(priv->stats, cpu);
 
-		total.rx_packets += stats->rx_packets;
-		total.tx_packets += stats->tx_packets;
-		total.rx_bytes   += stats->rx_bytes;
-		total.tx_bytes   += stats->tx_bytes;
-		total.tx_dropped += stats->tx_dropped;
-		total.rx_dropped += stats->rx_dropped;
+		tot->rx_packets += stats->rx_packets;
+		tot->tx_packets += stats->tx_packets;
+		tot->rx_bytes   += stats->rx_bytes;
+		tot->tx_bytes   += stats->tx_bytes;
+		tot->tx_dropped += stats->tx_dropped;
+		tot->rx_dropped += stats->rx_dropped;
 	}
-	dev->stats.rx_packets = total.rx_packets;
-	dev->stats.tx_packets = total.tx_packets;
-	dev->stats.rx_bytes   = total.rx_bytes;
-	dev->stats.tx_bytes   = total.tx_bytes;
-	dev->stats.tx_dropped = total.tx_dropped;
-	dev->stats.rx_dropped = total.rx_dropped;
 
-	return &dev->stats;
+	return tot;
 }
 
 static int veth_open(struct net_device *dev)
@@ -254,7 +249,7 @@ static const struct net_device_ops veth_
 	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
 	.ndo_change_mtu      = veth_change_mtu,
-	.ndo_get_stats       = veth_get_stats,
+	.ndo_get_stats64     = veth_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
 };
 


