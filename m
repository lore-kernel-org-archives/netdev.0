From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 10:31:01 -0400
Message-ID: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:45773 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab3AWObL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:31:11 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so935741ghb.5
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 06:31:10 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to use ndo_get_stats64 to get 64bit statistics.

Signed-off-by: Jamie Gloudon <jamie.gloudon@gmail.com>
---
 drivers/net/ethernet/via/via-rhine.c | 64 +++++++++++++++++++++++++++++++-----
 1 file changed, 56 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index eab63e1..aabc904 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -417,6 +417,12 @@ enum chip_cmd_bits {
 	Cmd1NoTxPoll=0x08, Cmd1Reset=0x80,
 };
 
+struct rhine_stats {
+	u64		packets;
+	u64		bytes;
+	struct u64_stats_sync syncp;
+};
+
 struct rhine_private {
 	/* Bit mask for configured VLAN ids */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
@@ -458,6 +464,8 @@ struct rhine_private {
 	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
 	unsigned int cur_tx, dirty_tx;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
+	struct rhine_stats rx_stats;
+	struct rhine_stats tx_stats;
 	u8 wolopts;
 
 	u8 tx_thresh, rx_thresh;
@@ -495,7 +503,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
 static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
 static void rhine_set_rx_mode(struct net_device *dev);
-static struct net_device_stats *rhine_get_stats(struct net_device *dev);
+static struct rtnl_link_stats64 *rhine_get_stats64(struct net_device *dev,
+	       struct rtnl_link_stats64 *stats);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
@@ -842,7 +851,7 @@ static const struct net_device_ops rhine_netdev_ops = {
 	.ndo_open		 = rhine_open,
 	.ndo_stop		 = rhine_close,
 	.ndo_start_xmit		 = rhine_start_tx,
-	.ndo_get_stats		 = rhine_get_stats,
+	.ndo_get_stats64	 = rhine_get_stats64,
 	.ndo_set_rx_mode	 = rhine_set_rx_mode,
 	.ndo_change_mtu		 = eth_change_mtu,
 	.ndo_validate_addr	 = eth_validate_addr,
@@ -1790,8 +1799,11 @@ static void rhine_tx(struct net_device *dev)
 				dev->stats.collisions += txstatus & 0x0F;
 			netif_dbg(rp, tx_done, dev, "collisions: %1.1x:%1.1x\n",
 				  (txstatus >> 3) & 0xF, txstatus & 0xF);
-			dev->stats.tx_bytes += rp->tx_skbuff[entry]->len;
-			dev->stats.tx_packets++;
+
+			u64_stats_update_begin(&rp->tx_stats.syncp);
+			rp->tx_stats.bytes += rp->tx_skbuff[entry]->len;
+			rp->tx_stats.packets++;
+			u64_stats_update_end(&rp->tx_stats.syncp);
 		}
 		/* Free the original skb. */
 		if (rp->tx_skbuff_dma[entry]) {
@@ -1857,6 +1869,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 					    "Oversized Ethernet frame %p vs %p\n",
 					    rp->rx_head_desc,
 					    &rp->rx_ring[entry]);
+				dev->stats.rx_dropped++;
 				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
 				/* There was a error. */
@@ -1923,8 +1936,11 @@ static int rhine_rx(struct net_device *dev, int limit)
 			if (unlikely(desc_length & DescTag))
 				__vlan_hwaccel_put_tag(skb, vlan_tci);
 			netif_receive_skb(skb);
-			dev->stats.rx_bytes += pkt_len;
-			dev->stats.rx_packets++;
+
+			u64_stats_update_begin(&rp->rx_stats.syncp);
+			rp->rx_stats.bytes += pkt_len;
+			rp->rx_stats.packets++;
+			u64_stats_update_end(&rp->rx_stats.syncp);
 		}
 		entry = (++rp->cur_rx) % RX_RING_SIZE;
 		rp->rx_head_desc = &rp->rx_ring[entry];
@@ -2019,15 +2035,47 @@ out_unlock:
 	mutex_unlock(&rp->task_lock);
 }
 
-static struct net_device_stats *rhine_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *
+rhine_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	unsigned int start;
 
 	spin_lock_bh(&rp->lock);
 	rhine_update_rx_crc_and_missed_errord(rp);
 	spin_unlock_bh(&rp->lock);
 
-	return &dev->stats;
+	do {
+		start = u64_stats_fetch_begin_bh(&rp->rx_stats.syncp);
+		stats->rx_packets = rp->rx_stats.packets;
+		stats->rx_bytes = rp->rx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&rp->rx_stats.syncp, start));
+
+	do {
+		start = u64_stats_fetch_begin_bh(&rp->tx_stats.syncp);
+		stats->tx_packets = rp->tx_stats.packets;
+		stats->tx_bytes = rp->tx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&rp->tx_stats.syncp, start));
+
+	stats->rx_errors = dev->stats.rx_errors;
+	stats->tx_errors = dev->stats.tx_errors;
+	stats->rx_dropped = dev->stats.rx_dropped;
+	stats->tx_dropped = dev->stats.tx_dropped;
+	stats->collisions = dev->stats.collisions;
+
+	stats->rx_length_errors = dev->stats.rx_length_errors;
+	stats->rx_crc_errors = dev->stats.rx_crc_errors;
+	stats->rx_frame_errors = dev->stats.rx_frame_errors;
+	stats->rx_fifo_errors = dev->stats.rx_fifo_errors;
+	stats->rx_missed_errors = dev->stats.rx_missed_errors;
+
+	stats->tx_aborted_errors = dev->stats.tx_aborted_errors;
+	stats->tx_carrier_errors = dev->stats.tx_carrier_errors;
+	stats->tx_fifo_errors = dev->stats.tx_fifo_errors;
+	stats->tx_heartbeat_errors = dev->stats.tx_heartbeat_errors;
+	stats->tx_window_errors = dev->stats.tx_window_errors;
+
+	return stats;
 }
 
 static void rhine_set_rx_mode(struct net_device *dev)
-- 
1.7.12
