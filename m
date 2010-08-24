From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bna: fix stats handling
Date: Tue, 24 Aug 2010 07:31:41 +0200
Message-ID: <1282627901.2378.1451.camel@edumazet-laptop>
References: <201008232123.o7NLNOpc032761@blc-10-10.brocade.com>
	 <20100823.203552.63040549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org, amathur@brocade.com,
	ddutt@brocade.com, huangj@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60326 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab0HXFjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 01:39:21 -0400
Received: by wyb35 with SMTP id 35so26310wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 22:39:20 -0700 (PDT)
In-Reply-To: <20100823.203552.63040549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brocade guys, could you please test the following patch on your
hardware ?

Thanks

[PATCH net-next-2.6] bna: fix stats handling

get_stats() method incorrectly clears a global array before folding
various stats. This can break SNMP applications.

Switch to 64 bit flavor to work on a user supplied buffer, and provide
64bit counters even on 32bit arches.

Fix a bug in bnad_netdev_hwstats_fill(), for rx_fifo_errors, missing a
folding (only the last counter was taken into account)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bna/bnad.c         |   52 ++++++++++++++-----------------
 drivers/net/bna/bnad.h         |    5 +-
 drivers/net/bna/bnad_ethtool.c |   17 ++++------
 3 files changed, 33 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 491d148..a935b96 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1964,25 +1964,24 @@ bnad_enable_default_bcast(struct bnad *bnad)
 
 /* Statistics utilities */
 void
-bnad_netdev_qstats_fill(struct bnad *bnad)
+bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 {
-	struct net_device_stats *net_stats = &bnad->net_stats;
 	int i, j;
 
 	for (i = 0; i < bnad->num_rx; i++) {
 		for (j = 0; j < bnad->num_rxp_per_rx; j++) {
 			if (bnad->rx_info[i].rx_ctrl[j].ccb) {
-				net_stats->rx_packets += bnad->rx_info[i].
+				stats->rx_packets += bnad->rx_info[i].
 				rx_ctrl[j].ccb->rcb[0]->rxq->rx_packets;
-				net_stats->rx_bytes += bnad->rx_info[i].
+				stats->rx_bytes += bnad->rx_info[i].
 					rx_ctrl[j].ccb->rcb[0]->rxq->rx_bytes;
 				if (bnad->rx_info[i].rx_ctrl[j].ccb->rcb[1] &&
 					bnad->rx_info[i].rx_ctrl[j].ccb->
 					rcb[1]->rxq) {
-					net_stats->rx_packets +=
+					stats->rx_packets +=
 						bnad->rx_info[i].rx_ctrl[j].
 						ccb->rcb[1]->rxq->rx_packets;
-					net_stats->rx_bytes +=
+					stats->rx_bytes +=
 						bnad->rx_info[i].rx_ctrl[j].
 						ccb->rcb[1]->rxq->rx_bytes;
 				}
@@ -1992,9 +1991,9 @@ bnad_netdev_qstats_fill(struct bnad *bnad)
 	for (i = 0; i < bnad->num_tx; i++) {
 		for (j = 0; j < bnad->num_txq_per_tx; j++) {
 			if (bnad->tx_info[i].tcb[j]) {
-				net_stats->tx_packets +=
+				stats->tx_packets +=
 				bnad->tx_info[i].tcb[j]->txq->tx_packets;
-				net_stats->tx_bytes +=
+				stats->tx_bytes +=
 					bnad->tx_info[i].tcb[j]->txq->tx_bytes;
 			}
 		}
@@ -2005,37 +2004,36 @@ bnad_netdev_qstats_fill(struct bnad *bnad)
  * Must be called with the bna_lock held.
  */
 void
-bnad_netdev_hwstats_fill(struct bnad *bnad)
+bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 {
 	struct bfi_ll_stats_mac *mac_stats;
-	struct net_device_stats *net_stats = &bnad->net_stats;
 	u64 bmap;
 	int i;
 
 	mac_stats = &bnad->stats.bna_stats->hw_stats->mac_stats;
-	net_stats->rx_errors =
+	stats->rx_errors =
 		mac_stats->rx_fcs_error + mac_stats->rx_alignment_error +
 		mac_stats->rx_frame_length_error + mac_stats->rx_code_error +
 		mac_stats->rx_undersize;
-	net_stats->tx_errors = mac_stats->tx_fcs_error +
+	stats->tx_errors = mac_stats->tx_fcs_error +
 					mac_stats->tx_undersize;
-	net_stats->rx_dropped = mac_stats->rx_drop;
-	net_stats->tx_dropped = mac_stats->tx_drop;
-	net_stats->multicast = mac_stats->rx_multicast;
-	net_stats->collisions = mac_stats->tx_total_collision;
+	stats->rx_dropped = mac_stats->rx_drop;
+	stats->tx_dropped = mac_stats->tx_drop;
+	stats->multicast = mac_stats->rx_multicast;
+	stats->collisions = mac_stats->tx_total_collision;
 
-	net_stats->rx_length_errors = mac_stats->rx_frame_length_error;
+	stats->rx_length_errors = mac_stats->rx_frame_length_error;
 
 	/* receive ring buffer overflow  ?? */
 
-	net_stats->rx_crc_errors = mac_stats->rx_fcs_error;
-	net_stats->rx_frame_errors = mac_stats->rx_alignment_error;
+	stats->rx_crc_errors = mac_stats->rx_fcs_error;
+	stats->rx_frame_errors = mac_stats->rx_alignment_error;
 	/* recv'r fifo overrun */
 	bmap = (u64)bnad->stats.bna_stats->rxf_bmap[0] |
 		((u64)bnad->stats.bna_stats->rxf_bmap[1] << 32);
 	for (i = 0; bmap && (i < BFI_LL_RXF_ID_MAX); i++) {
 		if (bmap & 1) {
-			net_stats->rx_fifo_errors =
+			stats->rx_fifo_errors +=
 				bnad->stats.bna_stats->
 					hw_stats->rxf_stats[i].frame_drops;
 			break;
@@ -2638,22 +2636,20 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
  * Used spin_lock to synchronize reading of stats structures, which
  * is written by BNA under the same lock.
  */
-static struct net_device_stats *
-bnad_get_netdev_stats(struct net_device *netdev)
+static struct rtnl_link_stats64 *
+bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 
-	memset(&bnad->net_stats, 0, sizeof(struct net_device_stats));
-
-	bnad_netdev_qstats_fill(bnad);
-	bnad_netdev_hwstats_fill(bnad);
+	bnad_netdev_qstats_fill(bnad, stats);
+	bnad_netdev_hwstats_fill(bnad, stats);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	return &bnad->net_stats;
+	return stats;
 }
 
 static void
@@ -2858,7 +2854,7 @@ static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_open		= bnad_open,
 	.ndo_stop		= bnad_stop,
 	.ndo_start_xmit		= bnad_start_xmit,
-	.ndo_get_stats		= bnad_get_netdev_stats,
+	.ndo_get_stats64	= bnad_get_stats64,
 	.ndo_set_rx_mode	= bnad_set_rx_mode,
 	.ndo_set_multicast_list = bnad_set_rx_mode,
 	.ndo_validate_addr      = eth_validate_addr,
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 3261401..ee37788 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -273,7 +273,6 @@ struct bnad {
 
 	/* Statistics */
 	struct bnad_stats stats;
-	struct net_device_stats net_stats;
 
 	struct bnad_diag *diag;
 
@@ -308,8 +307,8 @@ extern void bnad_cleanup_rx(struct bnad *bnad, uint rx_id);
 extern void bnad_dim_timer_start(struct bnad *bnad);
 
 /* Statistics */
-extern void bnad_netdev_qstats_fill(struct bnad *bnad);
-extern void bnad_netdev_hwstats_fill(struct bnad *bnad);
+extern void bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats);
+extern void bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats);
 
 /**
  * MACROS
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index 7e630f5..1f0c124 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -34,7 +34,7 @@
 #define BNAD_NUM_TXQ_COUNTERS 5
 
 #define BNAD_ETHTOOL_STATS_NUM						\
-	(sizeof(struct net_device_stats) / sizeof(unsigned long) +	\
+	(sizeof(struct rtnl_link_stats64) / sizeof(u64) +	\
 	sizeof(struct bnad_drv_stats) / sizeof(u64) +		\
 	offsetof(struct bfi_ll_stats, rxf_stats[0]) / sizeof(u64))
 
@@ -1159,7 +1159,8 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int i, j, bi;
-	unsigned long *net_stats, flags;
+	unsigned long flags;
+	struct rtnl_link_stats64 *net_stats64;
 	u64 *stats64;
 	u64 bmap;
 
@@ -1176,16 +1177,12 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bi = 0;
 	memset(buf, 0, stats->n_stats * sizeof(u64));
-	memset(&bnad->net_stats, 0, sizeof(struct net_device_stats));
 
-	bnad_netdev_qstats_fill(bnad);
-	bnad_netdev_hwstats_fill(bnad);
+	net_stats64 = (struct rtnl_link_stats64 *)buf;
+	bnad_netdev_qstats_fill(bnad, net_stats64);
+	bnad_netdev_hwstats_fill(bnad, net_stats64);
 
-	/* Fill net_stats into ethtool buffers */
-	net_stats = (unsigned long *)&bnad->net_stats;
-	for (i = 0; i < sizeof(struct net_device_stats) / sizeof(unsigned long);
-	     i++)
-		buf[bi++] = net_stats[i];
+	bi = sizeof(*net_stats64) / sizeof(u64);
 
 	/* Fill driver stats into ethtool buffers */
 	stats64 = (u64 *)&bnad->stats.drv_stats;


