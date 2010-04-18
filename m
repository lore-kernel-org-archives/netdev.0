From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 6/13] bnx2x: Added total_mcast/bcast_pkts_tr statistics
Date: Sun, 18 Apr 2010 17:49:17 +0300
Message-ID: <1271602157.27235.191.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>, dmitry@broadcom.com,
	eilong@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4049 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755128Ab0DROtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added total_mcast/bcast_pkts_transmitted statistics.

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    4 +-
 drivers/net/bnx2x_main.c |  118 +++++++++++++++++++++++++++++-----------------
 2 files changed, 76 insertions(+), 46 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 236235f..a9130f6 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -269,7 +269,7 @@ struct bnx2x_eth_q_stats {
 	u32 hw_csum_err;
 };
 
-#define BNX2X_NUM_Q_STATS		11
+#define BNX2X_NUM_Q_STATS		13
 #define Q_STATS_OFFSET32(stat_name) \
 			(offsetof(struct bnx2x_eth_q_stats, stat_name) / 4)
 
@@ -775,7 +775,7 @@ struct bnx2x_eth_stats {
 	u32 nig_timer_max;
 };
 
-#define BNX2X_NUM_STATS			41
+#define BNX2X_NUM_STATS			43
 #define STATS_OFFSET32(stat_name) \
 			(offsetof(struct bnx2x_eth_stats, stat_name) / 4)
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a3b851f..25a8bbf 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -3568,7 +3568,6 @@ static void bnx2x_sp_task(struct work_struct *work)
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task.work);
 	u16 status;
 
-
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
 		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
@@ -4425,6 +4424,21 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 		       qstats->total_bytes_received_lo,
 		       le32_to_cpu(tclient->rcv_unicast_bytes.lo));
 
+		SUB_64(qstats->total_bytes_received_hi,
+		       le32_to_cpu(uclient->bcast_no_buff_bytes.hi),
+		       qstats->total_bytes_received_lo,
+		       le32_to_cpu(uclient->bcast_no_buff_bytes.lo));
+
+		SUB_64(qstats->total_bytes_received_hi,
+		       le32_to_cpu(uclient->mcast_no_buff_bytes.hi),
+		       qstats->total_bytes_received_lo,
+		       le32_to_cpu(uclient->mcast_no_buff_bytes.lo));
+
+		SUB_64(qstats->total_bytes_received_hi,
+		       le32_to_cpu(uclient->ucast_no_buff_bytes.hi),
+		       qstats->total_bytes_received_lo,
+		       le32_to_cpu(uclient->ucast_no_buff_bytes.lo));
+
 		qstats->valid_bytes_received_hi =
 					qstats->total_bytes_received_hi;
 		qstats->valid_bytes_received_lo =
@@ -4673,47 +4687,43 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 	bnx2x_drv_stats_update(bp);
 
 	if (netif_msg_timer(bp)) {
-		struct bnx2x_fastpath *fp0_rx = bp->fp;
-		struct bnx2x_fastpath *fp0_tx = bp->fp;
-		struct tstorm_per_client_stats *old_tclient =
-							&bp->fp->old_tclient;
-		struct bnx2x_eth_q_stats *qstats = &bp->fp->eth_q_stats;
 		struct bnx2x_eth_stats *estats = &bp->eth_stats;
-		struct net_device_stats *nstats = &bp->dev->stats;
 		int i;
 
-		netdev_printk(KERN_DEBUG, bp->dev, "\n");
-		printk(KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
-				  "  tx pkt (%lx)\n",
-		       bnx2x_tx_avail(fp0_tx),
-		       le16_to_cpu(*fp0_tx->tx_cons_sb), nstats->tx_packets);
-		printk(KERN_DEBUG "  rx usage (%4x)  rx hc idx (%x)"
-				  "  rx pkt (%lx)\n",
-		       (u16)(le16_to_cpu(*fp0_rx->rx_cons_sb) -
-			     fp0_rx->rx_comp_cons),
-		       le16_to_cpu(*fp0_rx->rx_cons_sb), nstats->rx_packets);
-		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u  "
-				  "brb truncate %u\n",
-		       (netif_queue_stopped(bp->dev) ? "Xoff" : "Xon"),
-		       qstats->driver_xoff,
+		printk(KERN_DEBUG "%s: brb drops %u  brb truncate %u\n",
+		       bp->dev->name,
 		       estats->brb_drop_lo, estats->brb_truncate_lo);
-		printk(KERN_DEBUG "tstats: checksum_discard %u  "
-			"packets_too_big_discard %lu  no_buff_discard %lu  "
-			"mac_discard %u  mac_filter_discard %u  "
-			"xxovrflow_discard %u  brb_truncate_discard %u  "
-			"ttl0_discard %u\n",
-		       le32_to_cpu(old_tclient->checksum_discard),
-		       bnx2x_hilo(&qstats->etherstatsoverrsizepkts_hi),
-		       bnx2x_hilo(&qstats->no_buff_discard_hi),
-		       estats->mac_discard, estats->mac_filter_discard,
-		       estats->xxoverflow_discard, estats->brb_truncate_discard,
-		       le32_to_cpu(old_tclient->ttl0_discard));
 
 		for_each_queue(bp, i) {
-			printk(KERN_DEBUG "[%d]: %lu\t%lu\t%lu\n", i,
-			       bnx2x_fp(bp, i, tx_pkt),
-			       bnx2x_fp(bp, i, rx_pkt),
-			       bnx2x_fp(bp, i, rx_calls));
+			struct bnx2x_fastpath *fp = &bp->fp[i];
+			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
+
+			printk(KERN_DEBUG "%s: rx usage(%4u)  *rx_cons_sb(%u)"
+					  "  rx pkt(%lu)  rx calls(%lu %lu)\n",
+			       fp->name, (le16_to_cpu(*fp->rx_cons_sb) -
+			       fp->rx_comp_cons),
+			       le16_to_cpu(*fp->rx_cons_sb),
+			       bnx2x_hilo(&qstats->
+					  total_unicast_packets_received_hi),
+			       fp->rx_calls, fp->rx_pkt);
+		}
+
+		for_each_queue(bp, i) {
+			struct bnx2x_fastpath *fp = &bp->fp[i];
+			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
+			struct netdev_queue *txq =
+				netdev_get_tx_queue(bp->dev, i);
+
+			printk(KERN_DEBUG "%s: tx avail(%4u)  *tx_cons_sb(%u)"
+					  "  tx pkt(%lu) tx calls (%lu)"
+					  "  %s (Xoff events %u)\n",
+			       fp->name, bnx2x_tx_avail(fp),
+			       le16_to_cpu(*fp->tx_cons_sb),
+			       bnx2x_hilo(&qstats->
+					  total_unicast_packets_transmitted_hi),
+			       fp->tx_pkt,
+			       (netif_tx_queue_stopped(txq) ? "Xoff" : "Xon"),
+			       qstats->driver_xoff);
 		}
 	}
 
@@ -11640,7 +11650,11 @@ static const struct {
 
 /* 10 */{ Q_STATS_OFFSET32(total_bytes_transmitted_hi),	8, "[%d]: tx_bytes" },
 	{ Q_STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-							8, "[%d]: tx_packets" }
+						8, "[%d]: tx_ucast_packets" },
+	{ Q_STATS_OFFSET32(total_multicast_packets_transmitted_hi),
+						8, "[%d]: tx_mcast_packets" },
+	{ Q_STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
+						8, "[%d]: tx_bcast_packets" }
 };
 
 static const struct {
@@ -11702,16 +11716,20 @@ static const struct {
 	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
 				8, STATS_FLAGS_PORT, "tx_error_bytes" },
 	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_packets" },
+				8, STATS_FLAGS_BOTH, "tx_ucast_packets" },
+	{ STATS_OFFSET32(total_multicast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_mcast_packets" },
+	{ STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_bcast_packets" },
 	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
 				8, STATS_FLAGS_PORT, "tx_mac_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
 				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
-	{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
+/* 30 */{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
 				8, STATS_FLAGS_PORT, "tx_single_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
 				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
-/* 30 */{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
+	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
 				8, STATS_FLAGS_PORT, "tx_deferred" },
 	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
 				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
@@ -11727,11 +11745,11 @@ static const struct {
 			8, STATS_FLAGS_PORT, "tx_128_to_255_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
 			8, STATS_FLAGS_PORT, "tx_256_to_511_byte_packets" },
-	{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
+/* 40 */{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
 			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
 	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
 			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
-/* 40 */{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
+	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
 			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
 	{ STATS_OFFSET32(pause_frames_sent_hi),
 				8, STATS_FLAGS_PORT, "tx_pause_frames" }
@@ -12266,6 +12284,8 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i;
 	u8 hlen = 0;
 	__le16 pkt_size = 0;
+	struct ethhdr *eth;
+	u8 mac_type = UNICAST_ADDRESS;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -12289,6 +12309,16 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
 	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
 
+	eth = (struct ethhdr *)skb->data;
+
+	/* set flag according to packet type (UNICAST_ADDRESS is default)*/
+	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
+		if (is_broadcast_ether_addr(eth->h_dest))
+			mac_type = BROADCAST_ADDRESS;
+		else
+			mac_type = MULTICAST_ADDRESS;
+	}
+
 #if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
 	/* First, check if we need to linearize the skb (due to FW
 	   restrictions). No need to check fragmentation if page size > 8K
@@ -12322,8 +12352,8 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
 
 	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	tx_start_bd->general_data = (UNICAST_ADDRESS <<
-				     ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
+	tx_start_bd->general_data =  (mac_type <<
+					ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
 	/* header nbd */
 	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
 
-- 
1.6.3.3




