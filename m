From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/5] niu: fix 64 bit statistics on 32 bit platform
Date: Mon, 20 Jun 2011 13:35:08 -0700
Message-ID: <20110620203602.739916889@vyatta.com>
References: <20110620203506.363818794@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40986 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1FTUpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 16:45:30 -0400
Content-Disposition: inline; filename=niu-stats-sync.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This resolves issues with NIU driver statistics wrapping on 32 bit SMP.
Use stats_sync wrapper for bytes and packets, and change error counters
to natural word size (unsigned long).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/niu.c	2011-06-20 12:27:58.015994716 -0700
+++ b/drivers/net/niu.c	2011-06-20 12:40:21.239994298 -0700
@@ -3512,8 +3512,10 @@ static int niu_process_rx_pkt(struct nap
 			       (u32)rh->hashval1_2 << 0);
 	skb_pull(skb, sizeof(*rh));
 
+	u64_stats_update_begin(&rp->syncp);
 	rp->rx_packets++;
 	rp->rx_bytes += skb->len;
+	u64_stats_update_end(&rp->syncp);
 
 	skb->protocol = eth_type_trans(skb, np->dev);
 	skb_record_rx_queue(skb, rp->rx_channel);
@@ -6252,59 +6254,59 @@ static void niu_sync_mac_stats(struct ni
 static void niu_get_rx_stats(struct niu *np,
 			     struct rtnl_link_stats64 *stats)
 {
-	u64 pkts, dropped, errors, bytes;
 	struct rx_ring_info *rx_rings;
 	int i;
 
-	pkts = dropped = errors = bytes = 0;
-
 	rx_rings = ACCESS_ONCE(np->rx_rings);
 	if (!rx_rings)
-		goto no_rings;
+		return;
 
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &rx_rings[i];
+		unsigned int start;
+		u64 pkts, bytes;
 
 		niu_sync_rx_discard_stats(np, rp, 0);
 
-		pkts += rp->rx_packets;
-		bytes += rp->rx_bytes;
-		dropped += rp->rx_dropped;
-		errors += rp->rx_errors;
-	}
+		do {
+			start = u64_stats_fetch_begin(&rp->syncp);
 
-no_rings:
-	stats->rx_packets = pkts;
-	stats->rx_bytes = bytes;
-	stats->rx_dropped = dropped;
-	stats->rx_errors = errors;
+			pkts    = rp->rx_packets;
+			bytes   = rp->rx_bytes;
+		} while (u64_stats_fetch_retry(&rp->syncp, start));
+
+		stats->rx_packets += pkts;
+		stats->rx_bytes   += bytes;
+		stats->rx_dropped += rp->rx_dropped;
+		stats->rx_errors  += rp->rx_errors;
+	}
 }
 
 static void niu_get_tx_stats(struct niu *np,
 			     struct rtnl_link_stats64 *stats)
 {
-	u64 pkts, errors, bytes;
 	struct tx_ring_info *tx_rings;
 	int i;
 
-	pkts = errors = bytes = 0;
-
 	tx_rings = ACCESS_ONCE(np->tx_rings);
 	if (!tx_rings)
-		goto no_rings;
+		return;
 
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &tx_rings[i];
+		unsigned int start;
+		u64 pkts, bytes;
 
-		pkts += rp->tx_packets;
-		bytes += rp->tx_bytes;
-		errors += rp->tx_errors;
+		do {
+			start = u64_stats_fetch_begin(&rp->syncp);
+			pkts   = rp->tx_packets;
+			bytes  = rp->tx_bytes;
+		} while (u64_stats_fetch_retry(&rp->syncp, start));
+
+		stats->tx_packets += pkts;
+		stats->tx_bytes   += bytes;
+		stats->tx_errors  += rp->tx_errors;
 	}
-
-no_rings:
-	stats->tx_packets = pkts;
-	stats->tx_bytes = bytes;
-	stats->tx_errors = errors;
 }
 
 static struct rtnl_link_stats64 *niu_get_stats(struct net_device *dev,
@@ -7818,6 +7820,7 @@ static void niu_get_ethtool_stats(struct
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct niu *np = netdev_priv(dev);
+	unsigned int start;
 	int i;
 
 	niu_sync_mac_stats(np);
@@ -7836,8 +7839,13 @@ static void niu_get_ethtool_stats(struct
 		niu_sync_rx_discard_stats(np, rp, 0);
 
 		data[0] = rp->rx_channel;
-		data[1] = rp->rx_packets;
-		data[2] = rp->rx_bytes;
+		do {
+			start = u64_stats_fetch_begin(&rp->syncp);
+
+			data[1] = rp->rx_packets;
+			data[2] = rp->rx_bytes;
+		} while (u64_stats_fetch_retry(&rp->syncp, start));
+
 		data[3] = rp->rx_dropped;
 		data[4] = rp->rx_errors;
 		data += 5;
@@ -7846,8 +7854,11 @@ static void niu_get_ethtool_stats(struct
 		struct tx_ring_info *rp = &np->tx_rings[i];
 
 		data[0] = rp->tx_channel;
-		data[1] = rp->tx_packets;
-		data[2] = rp->tx_bytes;
+		do {
+			start = u64_stats_fetch_begin(&rp->syncp);
+			data[1] = rp->tx_packets;
+			data[2] = rp->tx_bytes;
+		} while (u64_stats_fetch_retry(&rp->syncp, start));
 		data[3] = rp->tx_errors;
 		data += 4;
 	}
--- a/drivers/net/niu.h	2011-06-20 12:27:57.043994716 -0700
+++ b/drivers/net/niu.h	2011-06-20 12:35:41.343994455 -0700
@@ -2866,9 +2866,10 @@ struct tx_ring_info {
 	struct txdma_mailbox	*mbox;
 	__le64			*descr;
 
+	struct u64_stats_sync	syncp;
 	u64			tx_packets;
 	u64			tx_bytes;
-	u64			tx_errors;
+	unsigned long		tx_errors;
 
 	u64			mbox_dma;
 	u64			descr_dma;
@@ -2922,10 +2923,11 @@ struct rx_ring_info {
 	__le32			*rbr;
 #define RBR_DESCR_ADDR_SHIFT	12
 
+	struct u64_stats_sync	syncp;
 	u64			rx_packets;
 	u64			rx_bytes;
-	u64			rx_dropped;
-	u64			rx_errors;
+	unsigned long		rx_dropped;
+	unsigned long		rx_errors;
 
 	u64			mbox_dma;
 	u64			rcr_dma;


