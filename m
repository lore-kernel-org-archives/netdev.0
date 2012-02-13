From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: preserve net device stats across reload
Date: Mon, 13 Feb 2012 18:41:38 +0100
Message-ID: <1329154898-17188-1-git-send-email-mschmidt@redhat.com>
Cc: eilong@broadcom.com, yanivr@broadcom.com, dmitry@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578Ab2BMRlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 12:41:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network device statistics were reset to zero when the bnx2x driver
reloaded the NIC, such as when changing the MTU.

To preserve the statistics across reloads, save the current values when
unloading. Add the saved values to the values read currently from the
hardware when updating the stats. Forget the saved values if the reason
for unloading is that the device is going down.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |   69 ++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h |   21 ++++++
 4 files changed, 80 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7d184fb..14e8282 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1557,6 +1557,9 @@ struct bnx2x {
 
 	/* priority to cos mapping */
 	u8					prio_to_cos[8];
+
+	/* to preserve net device stats across unload/load */
+	struct bnx2x_nstats_base		nstats_base;
 };
 
 /* Tx queues may be less or equal to Rx queues */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 518ec5c..959b785 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2084,6 +2084,10 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_drv_pulse(bp);
 
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+	if (unload_mode == UNLOAD_CLOSE)
+		bnx2x_stats_reset(bp);
+	else
+		bnx2x_stats_save(bp);
 
 	/* Cleanup the chip if needed */
 	if (unload_mode != UNLOAD_RECOVERY)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 7b9b304..d551814 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1122,47 +1122,52 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 static void bnx2x_net_stats_update(struct bnx2x *bp)
 {
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
+	struct bnx2x_nstats_base *base = &bp->nstats_base;
 	struct net_device_stats *nstats = &bp->dev->stats;
-	unsigned long tmp;
+	unsigned long tmp, tx_aborted_errors, tx_carrier_errors;
 	int i;
 
-	nstats->rx_packets =
+	nstats->rx_packets = base->rx_packets +
 		bnx2x_hilo(&estats->total_unicast_packets_received_hi) +
 		bnx2x_hilo(&estats->total_multicast_packets_received_hi) +
 		bnx2x_hilo(&estats->total_broadcast_packets_received_hi);
 
-	nstats->tx_packets =
+	nstats->tx_packets = base->tx_packets +
 		bnx2x_hilo(&estats->total_unicast_packets_transmitted_hi) +
 		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi) +
 		bnx2x_hilo(&estats->total_broadcast_packets_transmitted_hi);
 
-	nstats->rx_bytes = bnx2x_hilo(&estats->total_bytes_received_hi);
+	nstats->rx_bytes = base->rx_bytes +
+		bnx2x_hilo(&estats->total_bytes_received_hi);
 
-	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
+	nstats->tx_bytes = base->tx_bytes +
+		bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
 	tmp = estats->mac_discard;
 	for_each_rx_queue(bp, i)
 		tmp += le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
-	nstats->rx_dropped = tmp;
+	nstats->rx_dropped = base->rx_dropped + tmp;
 
 	nstats->tx_dropped = 0;
 
-	nstats->multicast =
+	nstats->multicast = base->multicast +
 		bnx2x_hilo(&estats->total_multicast_packets_received_hi);
 
-	nstats->collisions =
+	nstats->collisions = base->collisions +
 		bnx2x_hilo(&estats->tx_stat_etherstatscollisions_hi);
 
-	nstats->rx_length_errors =
+	nstats->rx_length_errors = base->rx_length_errors +
 		bnx2x_hilo(&estats->rx_stat_etherstatsundersizepkts_hi) +
 		bnx2x_hilo(&estats->etherstatsoverrsizepkts_hi);
-	nstats->rx_over_errors = bnx2x_hilo(&estats->brb_drop_hi) +
+	nstats->rx_over_errors = base->rx_over_errors +
+				 bnx2x_hilo(&estats->brb_drop_hi) +
 				 bnx2x_hilo(&estats->brb_truncate_hi);
-	nstats->rx_crc_errors =
+	nstats->rx_crc_errors = base->rx_crc_errors +
 		bnx2x_hilo(&estats->rx_stat_dot3statsfcserrors_hi);
-	nstats->rx_frame_errors =
+	nstats->rx_frame_errors = base->rx_frame_errors +
 		bnx2x_hilo(&estats->rx_stat_dot3statsalignmenterrors_hi);
-	nstats->rx_fifo_errors = bnx2x_hilo(&estats->no_buff_discard_hi);
+	nstats->rx_fifo_errors = base->rx_fifo_errors +
+		bnx2x_hilo(&estats->no_buff_discard_hi);
 	nstats->rx_missed_errors = 0;
 
 	nstats->rx_errors = nstats->rx_length_errors +
@@ -1172,17 +1177,20 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 			    nstats->rx_fifo_errors +
 			    nstats->rx_missed_errors;
 
-	nstats->tx_aborted_errors =
+	tx_aborted_errors =
 		bnx2x_hilo(&estats->tx_stat_dot3statslatecollisions_hi) +
 		bnx2x_hilo(&estats->tx_stat_dot3statsexcessivecollisions_hi);
-	nstats->tx_carrier_errors =
+	tx_carrier_errors =
 		bnx2x_hilo(&estats->rx_stat_dot3statscarriersenseerrors_hi);
+
+	nstats->tx_aborted_errors = base->tx_aborted_errors + tx_aborted_errors;
+	nstats->tx_carrier_errors = base->tx_carrier_errors + tx_carrier_errors;
 	nstats->tx_fifo_errors = 0;
 	nstats->tx_heartbeat_errors = 0;
 	nstats->tx_window_errors = 0;
 
-	nstats->tx_errors = nstats->tx_aborted_errors +
-			    nstats->tx_carrier_errors +
+	nstats->tx_errors = base->tx_errors +
+	    tx_aborted_errors + tx_carrier_errors +
 	    bnx2x_hilo(&estats->tx_stat_dot3statsinternalmactransmiterrors_hi);
 }
 
@@ -1695,3 +1703,30 @@ void bnx2x_stats_init(struct bnx2x *bp)
 	} else if (bp->func_stx)
 		bnx2x_func_stats_base_update(bp);
 }
+
+void bnx2x_stats_save(struct bnx2x *bp)
+{
+	struct net_device_stats *nstats = &bp->dev->stats;
+	struct bnx2x_nstats_base *base = &bp->nstats_base;
+
+	base->rx_packets        = nstats->rx_packets;
+	base->tx_packets        = nstats->tx_packets;
+	base->rx_bytes          = nstats->rx_bytes;
+	base->tx_bytes          = nstats->tx_bytes;
+	base->rx_dropped        = nstats->rx_dropped;
+	base->multicast         = nstats->multicast;
+	base->collisions        = nstats->collisions;
+	base->rx_length_errors  = nstats->rx_length_errors;
+	base->rx_over_errors    = nstats->rx_over_errors;
+	base->rx_crc_errors     = nstats->rx_crc_errors;
+	base->rx_frame_errors   = nstats->rx_frame_errors;
+	base->rx_fifo_errors    = nstats->rx_fifo_errors;
+	base->tx_aborted_errors = nstats->tx_aborted_errors;
+	base->tx_carrier_errors = nstats->tx_carrier_errors;
+	base->tx_errors         = nstats->tx_errors;
+}
+
+void bnx2x_stats_reset(struct bnx2x *bp)
+{
+	memset(&bp->nstats_base, 0, sizeof(bp->nstats_base));
+}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 7e97968..1d8bbaa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -264,6 +264,24 @@ struct bnx2x_eth_q_stats {
 	u32 total_tpa_bytes_lo;
 };
 
+struct bnx2x_nstats_base {
+	unsigned long rx_packets;
+	unsigned long tx_packets;
+	unsigned long rx_bytes;
+	unsigned long tx_bytes;
+	unsigned long rx_dropped;
+	unsigned long multicast;
+	unsigned long collisions;
+	unsigned long rx_length_errors;
+	unsigned long rx_over_errors;
+	unsigned long rx_crc_errors;
+	unsigned long rx_frame_errors;
+	unsigned long rx_fifo_errors;
+	unsigned long tx_aborted_errors;
+	unsigned long tx_carrier_errors;
+	unsigned long tx_errors;
+};
+
 /****************************************************************************
 * Macros
 ****************************************************************************/
@@ -388,4 +406,7 @@ void bnx2x_stats_init(struct bnx2x *bp);
 
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
+void bnx2x_stats_save(struct bnx2x *bp);
+void bnx2x_stats_reset(struct bnx2x *bp);
+
 #endif /* BNX2X_STATS_H */
-- 
1.7.7.6
