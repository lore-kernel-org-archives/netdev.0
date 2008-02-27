From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 5/12][BNX2X]: correct statistics
Date: Wed, 27 Feb 2008 14:24:33 +0200
Message-ID: <1204115073.8232.359.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4635 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754706AbYB0Mbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:31:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: correct statistics

Errors were summed improperly, some stats were missing.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  164 +++++++++++++++++++++++++--------------------------
 drivers/net/bnx2x.h |    4 +-
 2 files changed, 83 insertions(+), 85 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 103d3e0..a35feee 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -4972,39 +4972,37 @@ static void bnx2x_update_net_stats(struct bnx2x *bp)
 
 	nstats->rx_bytes = bnx2x_hilo(&estats->total_bytes_received_hi);
 
-	nstats->tx_bytes =
-		bnx2x_hilo(&estats->total_bytes_transmitted_hi);
+	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
-	nstats->rx_dropped = estats->checksum_discard +
-				   estats->mac_discard;
+	nstats->rx_dropped = estats->checksum_discard + estats->mac_discard;
 	nstats->tx_dropped = 0;
 
 	nstats->multicast =
 		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi);
 
-	nstats->collisions =
-		estats->single_collision_transmit_frames +
-		estats->multiple_collision_transmit_frames +
-		estats->late_collision_frames +
-		estats->excessive_collision_frames;
+	nstats->collisions = estats->single_collision_transmit_frames +
+			     estats->multiple_collision_transmit_frames +
+			     estats->late_collision_frames +
+			     estats->excessive_collision_frames;
 
 	nstats->rx_length_errors = estats->runt_packets_received +
 				   estats->jabber_packets_received;
-	nstats->rx_over_errors = estats->no_buff_discard;
+	nstats->rx_over_errors = estats->brb_discard +
+				 estats->brb_truncate_discard;
 	nstats->rx_crc_errors = estats->crc_receive_errors;
 	nstats->rx_frame_errors = estats->alignment_errors;
-	nstats->rx_fifo_errors = estats->brb_discard +
-				       estats->brb_truncate_discard;
+	nstats->rx_fifo_errors = estats->no_buff_discard;
 	nstats->rx_missed_errors = estats->xxoverflow_discard;
 
 	nstats->rx_errors = nstats->rx_length_errors +
 			    nstats->rx_over_errors +
 			    nstats->rx_crc_errors +
 			    nstats->rx_frame_errors +
-			    nstats->rx_fifo_errors;
+			    nstats->rx_fifo_errors +
+			    nstats->rx_missed_errors;
 
 	nstats->tx_aborted_errors = estats->late_collision_frames +
-					  estats->excessive_collision_frames;
+				    estats->excessive_collision_frames;
 	nstats->tx_carrier_errors = estats->false_carrier_detections;
 	nstats->tx_fifo_errors = 0;
 	nstats->tx_heartbeat_errors = 0;
@@ -8755,81 +8753,87 @@ static void bnx2x_self_test(struct net_device *dev,
 static struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_stats_str_arr[BNX2X_NUM_STATS] = {
-	{ "rx_bytes"},  			 /*  0 */
-	{ "rx_error_bytes"},    		 /*  1 */
-	{ "tx_bytes"},  			 /*  2 */
-	{ "tx_error_bytes"},    		 /*  3 */
-	{ "rx_ucast_packets"},  		 /*  4 */
-	{ "rx_mcast_packets"},  		 /*  5 */
-	{ "rx_bcast_packets"},  		 /*  6 */
-	{ "tx_ucast_packets"},  		 /*  7 */
-	{ "tx_mcast_packets"},  		 /*  8 */
-	{ "tx_bcast_packets"},  		 /*  9 */
-	{ "tx_mac_errors"},     		 /* 10 */
-	{ "tx_carrier_errors"}, 		 /* 11 */
-	{ "rx_crc_errors"},     		 /* 12 */
-	{ "rx_align_errors"},   		 /* 13 */
-	{ "tx_single_collisions"},      	 /* 14 */
-	{ "tx_multi_collisions"},       	 /* 15 */
-	{ "tx_deferred"},       		 /* 16 */
-	{ "tx_excess_collisions"},      	 /* 17 */
-	{ "tx_late_collisions"},		 /* 18 */
-	{ "tx_total_collisions"},       	 /* 19 */
-	{ "rx_fragments"},      		 /* 20 */
-	{ "rx_jabbers"},			 /* 21 */
-	{ "rx_undersize_packets"},      	 /* 22 */
-	{ "rx_oversize_packets"},       	 /* 23 */
-	{ "rx_xon_frames"},     		 /* 24 */
-	{ "rx_xoff_frames"},    		 /* 25 */
-	{ "tx_xon_frames"},     		 /* 26 */
-	{ "tx_xoff_frames"},    		 /* 27 */
-	{ "rx_mac_ctrl_frames"},		 /* 28 */
-	{ "rx_filtered_packets"},       	 /* 29 */
-	{ "rx_discards"},       		 /* 30 */
+	{ "rx_bytes"},
+	{ "rx_error_bytes"},
+	{ "tx_bytes"},
+	{ "tx_error_bytes"},
+	{ "rx_ucast_packets"},
+	{ "rx_mcast_packets"},
+	{ "rx_bcast_packets"},
+	{ "tx_ucast_packets"},
+	{ "tx_mcast_packets"},
+	{ "tx_bcast_packets"},
+	{ "tx_mac_errors"},	/* 10 */
+	{ "tx_carrier_errors"},
+	{ "rx_crc_errors"},
+	{ "rx_align_errors"},
+	{ "tx_single_collisions"},
+	{ "tx_multi_collisions"},
+	{ "tx_deferred"},
+	{ "tx_excess_collisions"},
+	{ "tx_late_collisions"},
+	{ "tx_total_collisions"},
+	{ "rx_fragments"},	/* 20 */
+	{ "rx_jabbers"},
+	{ "rx_undersize_packets"},
+	{ "rx_oversize_packets"},
+	{ "rx_xon_frames"},
+	{ "rx_xoff_frames"},
+	{ "tx_xon_frames"},
+	{ "tx_xoff_frames"},
+	{ "rx_mac_ctrl_frames"},
+	{ "rx_filtered_packets"},
+	{ "rx_discards"},	/* 30 */
+	{ "brb_discard"},
+	{ "brb_truncate"},
+	{ "xxoverflow"}
 };
 
 #define STATS_OFFSET32(offset_name) \
 	(offsetof(struct bnx2x_eth_stats, offset_name) / 4)
 
 static unsigned long bnx2x_stats_offset_arr[BNX2X_NUM_STATS] = {
-	STATS_OFFSET32(total_bytes_received_hi),		     /*  0 */
-	STATS_OFFSET32(stat_IfHCInBadOctets_hi),		     /*  1 */
-	STATS_OFFSET32(total_bytes_transmitted_hi),     	     /*  2 */
-	STATS_OFFSET32(stat_IfHCOutBadOctets_hi),       	     /*  3 */
-	STATS_OFFSET32(total_unicast_packets_received_hi),           /*  4 */
-	STATS_OFFSET32(total_multicast_packets_received_hi),         /*  5 */
-	STATS_OFFSET32(total_broadcast_packets_received_hi),         /*  6 */
-	STATS_OFFSET32(total_unicast_packets_transmitted_hi),        /*  7 */
-	STATS_OFFSET32(total_multicast_packets_transmitted_hi),      /*  8 */
-	STATS_OFFSET32(total_broadcast_packets_transmitted_hi),      /*  9 */
-	STATS_OFFSET32(stat_Dot3statsInternalMacTransmitErrors),     /* 10 */
-	STATS_OFFSET32(stat_Dot3StatsCarrierSenseErrors),            /* 11 */
-	STATS_OFFSET32(crc_receive_errors),     		     /* 12 */
-	STATS_OFFSET32(alignment_errors),       		     /* 13 */
-	STATS_OFFSET32(single_collision_transmit_frames),            /* 14 */
-	STATS_OFFSET32(multiple_collision_transmit_frames),          /* 15 */
-	STATS_OFFSET32(stat_Dot3StatsDeferredTransmissions),         /* 16 */
-	STATS_OFFSET32(excessive_collision_frames),     	     /* 17 */
-	STATS_OFFSET32(late_collision_frames),  		     /* 18 */
-	STATS_OFFSET32(number_of_bugs_found_in_stats_spec),          /* 19 */
-	STATS_OFFSET32(runt_packets_received),  		     /* 20 */
-	STATS_OFFSET32(jabber_packets_received),		     /* 21 */
-	STATS_OFFSET32(error_runt_packets_received),    	     /* 22 */
-	STATS_OFFSET32(error_jabber_packets_received),  	     /* 23 */
-	STATS_OFFSET32(pause_xon_frames_received),      	     /* 24 */
-	STATS_OFFSET32(pause_xoff_frames_received),     	     /* 25 */
-	STATS_OFFSET32(pause_xon_frames_transmitted),   	     /* 26 */
-	STATS_OFFSET32(pause_xoff_frames_transmitted),  	     /* 27 */
-	STATS_OFFSET32(control_frames_received),		     /* 28 */
-	STATS_OFFSET32(mac_filter_discard),     		     /* 29 */
-	STATS_OFFSET32(no_buff_discard),			     /* 30 */
+	STATS_OFFSET32(total_bytes_received_hi),
+	STATS_OFFSET32(stat_IfHCInBadOctets_hi),
+	STATS_OFFSET32(total_bytes_transmitted_hi),
+	STATS_OFFSET32(stat_IfHCOutBadOctets_hi),
+	STATS_OFFSET32(total_unicast_packets_received_hi),
+	STATS_OFFSET32(total_multicast_packets_received_hi),
+	STATS_OFFSET32(total_broadcast_packets_received_hi),
+	STATS_OFFSET32(total_unicast_packets_transmitted_hi),
+	STATS_OFFSET32(total_multicast_packets_transmitted_hi),
+	STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
+	STATS_OFFSET32(stat_Dot3statsInternalMacTransmitErrors), /* 10 */
+	STATS_OFFSET32(stat_Dot3StatsCarrierSenseErrors),
+	STATS_OFFSET32(crc_receive_errors),
+	STATS_OFFSET32(alignment_errors),
+	STATS_OFFSET32(single_collision_transmit_frames),
+	STATS_OFFSET32(multiple_collision_transmit_frames),
+	STATS_OFFSET32(stat_Dot3StatsDeferredTransmissions),
+	STATS_OFFSET32(excessive_collision_frames),
+	STATS_OFFSET32(late_collision_frames),
+	STATS_OFFSET32(number_of_bugs_found_in_stats_spec),
+	STATS_OFFSET32(runt_packets_received),			/* 20 */
+	STATS_OFFSET32(jabber_packets_received),
+	STATS_OFFSET32(error_runt_packets_received),
+	STATS_OFFSET32(error_jabber_packets_received),
+	STATS_OFFSET32(pause_xon_frames_received),
+	STATS_OFFSET32(pause_xoff_frames_received),
+	STATS_OFFSET32(pause_xon_frames_transmitted),
+	STATS_OFFSET32(pause_xoff_frames_transmitted),
+	STATS_OFFSET32(control_frames_received),
+	STATS_OFFSET32(mac_filter_discard),
+	STATS_OFFSET32(no_buff_discard),			/* 30 */
+	STATS_OFFSET32(brb_discard),
+	STATS_OFFSET32(brb_truncate_discard),
+	STATS_OFFSET32(xxoverflow_discard)
 };
 
 static u8 bnx2x_stats_len_arr[BNX2X_NUM_STATS] = {
 	8, 0, 8, 0, 8, 8, 8, 8, 8, 8,
 	4, 0, 4, 4, 4, 4, 4, 4, 4, 4,
 	4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
-	4,
+	4, 4, 4, 4
 };
 
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
@@ -9372,11 +9376,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *bnx2x_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 /* Called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
 {
@@ -9784,7 +9783,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	dev->hard_start_xmit = bnx2x_start_xmit;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->get_stats = bnx2x_get_stats;
 	dev->ethtool_ops = &bnx2x_ethtool_ops;
 	dev->open = bnx2x_open;
 	dev->stop = bnx2x_close;
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index d0e5ab1..e2a36e8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -854,8 +854,8 @@ struct bnx2x {
 #define MAX_SPQ_PENDING 		8
 
 
-#define BNX2X_NUM_STATS 		31
-#define BNX2X_NUM_TESTS 		2
+#define BNX2X_NUM_STATS			34
+#define BNX2X_NUM_TESTS			1
 
 
 #define DPM_TRIGER_TYPE 		0x40
-- 
1.5.3.2




