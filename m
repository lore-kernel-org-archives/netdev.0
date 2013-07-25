From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2] tile: handle 64-bit statistics in tilepro network driver
Date: Thu, 25 Jul 2013 12:41:15 -0400
Message-ID: <201307251642.r6PGgHx2002404@farm-0012.internal.tilera.com>
References: <20130724.023126.792508581970927723.davem@davemloft.net>
	<cover.1374609948.git.cmetcalf@tilera.com>
	<40362053a9f02d56a4f0c07a9982d96203723ec8.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:32022 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab3GYQmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 12:42:19 -0400
In-Reply-To: <20130724.023126.792508581970927723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v2: use <linux/u64_stats_sync.h> primitives

 drivers/net/ethernet/tile/tilepro.c | 77 ++++++++++++++++++++++++++-----------
 1 file changed, 54 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 3643549..f66ac20 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -31,6 +31,7 @@
 #include <linux/in6.h>
 #include <linux/timer.h>
 #include <linux/io.h>
+#include <linux/u64_stats_sync.h>
 #include <asm/checksum.h>
 #include <asm/homecache.h>
 
@@ -156,10 +157,13 @@ struct tile_netio_queue {
  * Statistics counters for a specific cpu and device.
  */
 struct tile_net_stats_t {
-	u32 rx_packets;
-	u32 rx_bytes;
-	u32 tx_packets;
-	u32 tx_bytes;
+	struct u64_stats_sync syncp;
+	u64 rx_packets;		/* total packets received	*/
+	u64 tx_packets;		/* total packets transmitted	*/
+	u64 rx_bytes;		/* total bytes received 	*/
+	u64 tx_bytes;		/* total bytes transmitted	*/
+	u64 rx_errors;		/* packets truncated or marked bad by hw */
+	u64 rx_dropped;		/* packets not for us or intf not up */
 };
 
 
@@ -218,8 +222,6 @@ struct tile_net_priv {
 	int network_cpus_count;
 	/* Credits per network cpu. */
 	int network_cpus_credits;
-	/* Network stats. */
-	struct net_device_stats stats;
 	/* For NetIO bringup retries. */
 	struct delayed_work retry_work;
 	/* Quick access to per cpu data. */
@@ -847,6 +849,8 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		}
 	}
 
+	u64_stats_update_begin(&stats->syncp);
+
 	if (filter) {
 
 		/* ISSUE: Update "drop" statistics? */
@@ -881,6 +885,8 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		stats->rx_bytes += len;
 	}
 
+	u64_stats_update_end(&stats->syncp);
+
 	/* ISSUE: It would be nice to defer this until the packet has */
 	/* actually been processed. */
 	tile_net_return_credit(info);
@@ -1907,8 +1913,10 @@ busy:
 		kfree_skb(olds[i]);
 
 	/* Update stats. */
+	u64_stats_update_begin(&stats->syncp);
 	stats->tx_packets += num_segs;
 	stats->tx_bytes += (num_segs * sh_len) + d_len;
+	u64_stats_update_end(&stats->syncp);
 
 	/* Make sure the egress timer is scheduled. */
 	tile_net_schedule_egress_timer(info);
@@ -2089,8 +2097,10 @@ busy:
 		kfree_skb(olds[i]);
 
 	/* HACK: Track "expanded" size for short packets (e.g. 42 < 60). */
+	u64_stats_update_begin(&stats->syncp);
 	stats->tx_packets++;
 	stats->tx_bytes += ((len >= ETH_ZLEN) ? len : ETH_ZLEN);
+	u64_stats_update_end(&stats->syncp);
 
 	/* Make sure the egress timer is scheduled. */
 	tile_net_schedule_egress_timer(info);
@@ -2127,30 +2137,51 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  *
  * Returns the address of the device statistics structure.
  */
-static struct net_device_stats *tile_net_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *tile_net_get_stats64(struct net_device *dev,
+		struct rtnl_link_stats64 *stats)
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
-	u32 rx_packets = 0;
-	u32 tx_packets = 0;
-	u32 rx_bytes = 0;
-	u32 tx_bytes = 0;
+	u64 rx_packets = 0, tx_packets = 0;
+	u64 rx_bytes = 0, tx_bytes = 0;
+	u64 rx_errors = 0, rx_dropped = 0;
 	int i;
 
 	for_each_online_cpu(i) {
-		if (priv->cpu[i]) {
-			rx_packets += priv->cpu[i]->stats.rx_packets;
-			rx_bytes += priv->cpu[i]->stats.rx_bytes;
-			tx_packets += priv->cpu[i]->stats.tx_packets;
-			tx_bytes += priv->cpu[i]->stats.tx_bytes;
-		}
+		struct tile_net_stats_t *cpu_stats;
+		u64 trx_packets, ttx_packets, trx_bytes, ttx_bytes;
+		u64 trx_errors, trx_dropped;
+		unsigned int start;
+
+		if (priv->cpu[i] == NULL)
+			continue;
+		cpu_stats = &priv->cpu[i]->stats;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&cpu_stats->syncp);
+			trx_packets = cpu_stats->rx_packets;
+			ttx_packets = cpu_stats->tx_packets;
+			trx_bytes   = cpu_stats->rx_bytes;
+			ttx_bytes   = cpu_stats->tx_bytes;
+			trx_errors  = cpu_stats->rx_errors;
+			trx_dropped = cpu_stats->rx_dropped;
+		} while (u64_stats_fetch_retry_bh(&cpu_stats->syncp, start));
+
+		rx_packets += trx_packets;
+		tx_packets += ttx_packets;
+		rx_bytes   += trx_bytes;
+		tx_bytes   += ttx_bytes;
+		rx_errors  += trx_errors;
+		rx_dropped += trx_dropped;
 	}
 
-	priv->stats.rx_packets = rx_packets;
-	priv->stats.rx_bytes = rx_bytes;
-	priv->stats.tx_packets = tx_packets;
-	priv->stats.tx_bytes = tx_bytes;
+	stats->rx_packets = rx_packets;
+	stats->tx_packets = tx_packets;
+	stats->rx_bytes   = rx_bytes;
+	stats->tx_bytes   = tx_bytes;
+	stats->rx_errors  = rx_errors;
+	stats->rx_dropped = rx_dropped;
 
-	return &priv->stats;
+	return stats;
 }
 
 
@@ -2287,7 +2318,7 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_stop = tile_net_stop,
 	.ndo_start_xmit = tile_net_tx,
 	.ndo_do_ioctl = tile_net_ioctl,
-	.ndo_get_stats = tile_net_get_stats,
+	.ndo_get_stats64 = tile_net_get_stats64,
 	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
 	.ndo_set_mac_address = tile_net_set_mac_address,
-- 
1.8.3.1
