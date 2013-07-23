From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 01/13] tile: handle 64-bit statistics in tilepro network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <40362053a9f02d56a4f0c07a9982d96203723ec8.1374609948.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c | 42 ++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 3643549..0237031 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -156,10 +156,14 @@ struct tile_netio_queue {
  * Statistics counters for a specific cpu and device.
  */
 struct tile_net_stats_t {
-	u32 rx_packets;
-	u32 rx_bytes;
-	u32 tx_packets;
-	u32 tx_bytes;
+	u64 rx_packets;		/* total packets received	*/
+	u64 tx_packets;		/* total packets transmitted	*/
+	u64 rx_bytes;		/* total bytes received 	*/
+	u64 tx_bytes;		/* total bytes transmitted	*/
+	u64 rx_errors;		/* packets truncated or marked bad by hw */
+	u64 tx_errors;		/* (not currently used)		*/
+	u64 rx_dropped;		/* packets not for us or intf not up */
+	u64 tx_dropped;		/* (not currently used)		*/
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
@@ -2127,30 +2129,26 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
 	int i;
 
 	for_each_online_cpu(i) {
 		if (priv->cpu[i]) {
-			rx_packets += priv->cpu[i]->stats.rx_packets;
-			rx_bytes += priv->cpu[i]->stats.rx_bytes;
-			tx_packets += priv->cpu[i]->stats.tx_packets;
-			tx_bytes += priv->cpu[i]->stats.tx_bytes;
+			stats->rx_packets += priv->cpu[i]->stats.rx_packets;
+			stats->tx_packets += priv->cpu[i]->stats.tx_packets;
+			stats->rx_bytes += priv->cpu[i]->stats.rx_bytes;
+			stats->tx_bytes += priv->cpu[i]->stats.tx_bytes;
+			stats->rx_errors += priv->cpu[i]->stats.rx_errors;
+			stats->tx_errors += priv->cpu[i]->stats.tx_errors;
+			stats->rx_dropped += priv->cpu[i]->stats.rx_dropped;
+			stats->tx_dropped += priv->cpu[i]->stats.tx_dropped;
 		}
 	}
 
-	priv->stats.rx_packets = rx_packets;
-	priv->stats.rx_bytes = rx_bytes;
-	priv->stats.tx_packets = tx_packets;
-	priv->stats.tx_bytes = tx_bytes;
-
-	return &priv->stats;
+	return stats;
 }
 
 
@@ -2287,7 +2285,7 @@ static const struct net_device_ops tile_net_ops = {
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
