From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2: Refine statistics code.
Date: Sun, 17 Jan 2010 09:30:43 -0800
Message-ID: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1518 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab0AQRW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 12:22:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refine the statistics macros by passing in just the name of the
counter field.  This makes it a lot easier and cleaner to add
counters saved before the last reset in the next patch.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   62 ++++++++++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b1c20e5..47fb508 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6542,92 +6542,94 @@ bnx2_close(struct net_device *dev)
 	return 0;
 }
 
-#define GET_NET_STATS64(ctr)					\
+#define GET_64BIT_NET_STATS64(ctr)				\
 	(unsigned long) ((unsigned long) (ctr##_hi) << 32) +	\
 	(unsigned long) (ctr##_lo)
 
-#define GET_NET_STATS32(ctr)		\
+#define GET_64BIT_NET_STATS32(ctr)				\
 	(ctr##_lo)
 
 #if (BITS_PER_LONG == 64)
-#define GET_NET_STATS	GET_NET_STATS64
+#define GET_64BIT_NET_STATS(ctr)				\
+	GET_64BIT_NET_STATS64(bp->stats_blk->ctr)
 #else
-#define GET_NET_STATS	GET_NET_STATS32
+#define GET_64BIT_NET_STATS(ctr)				\
+	GET_64BIT_NET_STATS32(bp->stats_blk->ctr)
 #endif
 
+#define GET_32BIT_NET_STATS(ctr)				\
+	(unsigned long) (bp->stats_blk->ctr)
+
 static struct net_device_stats *
 bnx2_get_stats(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
-	struct statistics_block *stats_blk = bp->stats_blk;
 	struct net_device_stats *net_stats = &dev->stats;
 
 	if (bp->stats_blk == NULL) {
 		return net_stats;
 	}
 	net_stats->rx_packets =
-		GET_NET_STATS(stats_blk->stat_IfHCInUcastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCInMulticastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCInBroadcastPkts);
+		GET_64BIT_NET_STATS(stat_IfHCInUcastPkts) +
+		GET_64BIT_NET_STATS(stat_IfHCInMulticastPkts) +
+		GET_64BIT_NET_STATS(stat_IfHCInBroadcastPkts);
 
 	net_stats->tx_packets =
-		GET_NET_STATS(stats_blk->stat_IfHCOutUcastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCOutBroadcastPkts);
+		GET_64BIT_NET_STATS(stat_IfHCOutUcastPkts) +
+		GET_64BIT_NET_STATS(stat_IfHCOutMulticastPkts) +
+		GET_64BIT_NET_STATS(stat_IfHCOutBroadcastPkts);
 
 	net_stats->rx_bytes =
-		GET_NET_STATS(stats_blk->stat_IfHCInOctets);
+		GET_64BIT_NET_STATS(stat_IfHCInOctets);
 
 	net_stats->tx_bytes =
-		GET_NET_STATS(stats_blk->stat_IfHCOutOctets);
+		GET_64BIT_NET_STATS(stat_IfHCOutOctets);
 
 	net_stats->multicast =
-		GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts);
+		GET_64BIT_NET_STATS(stat_IfHCOutMulticastPkts);
 
 	net_stats->collisions =
-		(unsigned long) stats_blk->stat_EtherStatsCollisions;
+		GET_32BIT_NET_STATS(stat_EtherStatsCollisions);
 
 	net_stats->rx_length_errors =
-		(unsigned long) (stats_blk->stat_EtherStatsUndersizePkts +
-		stats_blk->stat_EtherStatsOverrsizePkts);
+		GET_32BIT_NET_STATS(stat_EtherStatsUndersizePkts) +
+		GET_32BIT_NET_STATS(stat_EtherStatsOverrsizePkts);
 
 	net_stats->rx_over_errors =
-		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
-		stats_blk->stat_IfInMBUFDiscards);
+		GET_32BIT_NET_STATS(stat_IfInFTQDiscards) +
+		GET_32BIT_NET_STATS(stat_IfInMBUFDiscards);
 
 	net_stats->rx_frame_errors =
-		(unsigned long) stats_blk->stat_Dot3StatsAlignmentErrors;
+		GET_32BIT_NET_STATS(stat_Dot3StatsAlignmentErrors);
 
 	net_stats->rx_crc_errors =
-		(unsigned long) stats_blk->stat_Dot3StatsFCSErrors;
+		GET_32BIT_NET_STATS(stat_Dot3StatsFCSErrors);
 
 	net_stats->rx_errors = net_stats->rx_length_errors +
 		net_stats->rx_over_errors + net_stats->rx_frame_errors +
 		net_stats->rx_crc_errors;
 
 	net_stats->tx_aborted_errors =
-    		(unsigned long) (stats_blk->stat_Dot3StatsExcessiveCollisions +
-		stats_blk->stat_Dot3StatsLateCollisions);
+		GET_32BIT_NET_STATS(stat_Dot3StatsExcessiveCollisions) +
+		GET_32BIT_NET_STATS(stat_Dot3StatsLateCollisions);
 
 	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_A0))
 		net_stats->tx_carrier_errors = 0;
 	else {
 		net_stats->tx_carrier_errors =
-			(unsigned long)
-			stats_blk->stat_Dot3StatsCarrierSenseErrors;
+			GET_32BIT_NET_STATS(stat_Dot3StatsCarrierSenseErrors);
 	}
 
 	net_stats->tx_errors =
-    		(unsigned long)
-		stats_blk->stat_emac_tx_stat_dot3statsinternalmactransmiterrors
-		+
+		GET_32BIT_NET_STATS(stat_emac_tx_stat_dot3statsinternalmactransmiterrors) +
 		net_stats->tx_aborted_errors +
 		net_stats->tx_carrier_errors;
 
 	net_stats->rx_missed_errors =
-		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
-		stats_blk->stat_IfInMBUFDiscards + stats_blk->stat_FwRxDrop);
+		GET_32BIT_NET_STATS(stat_IfInFTQDiscards) +
+		GET_32BIT_NET_STATS(stat_IfInMBUFDiscards) +
+		GET_32BIT_NET_STATS(stat_FwRxDrop);
 
 	return net_stats;
 }
-- 
1.6.4.GIT


