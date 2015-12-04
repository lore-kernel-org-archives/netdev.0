From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 3/3] bnx2x: simplify distinction between port and func stats
Date: Fri,  4 Dec 2015 17:22:36 +0100
Message-ID: <1449246156-13796-4-git-send-email-mschmidt@redhat.com>
References: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084AbbLDQWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:22:42 -0500
In-Reply-To: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'flags' field in bnx2x_stats_arr[] serves only one purpose - to tell
us if the statistic is a per-port stat and thus should not be shown for
virtual functions. It's strange that the field can have three different
values. A boolean will do just fine.

Also remove IS_FUNC_STAT(). It was used only once and it's in fact just
a negation of IS_PORT_STAT().

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 117 ++++++++++-----------
 1 file changed, 56 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index a3ce9f2a23..820b7e04bb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -74,118 +74,115 @@ static const struct {
 static const struct {
 	long offset;
 	int size;
-	u32 flags;
-#define STATS_FLAGS_PORT		1
-#define STATS_FLAGS_FUNC		2
-#define STATS_FLAGS_BOTH		(STATS_FLAGS_FUNC | STATS_FLAGS_PORT)
+	bool is_port_stat;
 	char string[ETH_GSTRING_LEN];
 } bnx2x_stats_arr[] = {
 /* 1 */	{ STATS_OFFSET32(total_bytes_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_bytes" },
+				8, false, "rx_bytes" },
 	{ STATS_OFFSET32(error_bytes_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_error_bytes" },
+				8, false, "rx_error_bytes" },
 	{ STATS_OFFSET32(total_unicast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_ucast_packets" },
+				8, false, "rx_ucast_packets" },
 	{ STATS_OFFSET32(total_multicast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_mcast_packets" },
+				8, false, "rx_mcast_packets" },
 	{ STATS_OFFSET32(total_broadcast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_bcast_packets" },
+				8, false, "rx_bcast_packets" },
 	{ STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
-				8, STATS_FLAGS_PORT, "rx_crc_errors" },
+				8, true, "rx_crc_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
-				8, STATS_FLAGS_PORT, "rx_align_errors" },
+				8, true, "rx_align_errors" },
 	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
-				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
+				8, true, "rx_undersize_packets" },
 	{ STATS_OFFSET32(etherstatsoverrsizepkts_hi),
-				8, STATS_FLAGS_PORT, "rx_oversize_packets" },
+				8, true, "rx_oversize_packets" },
 /* 10 */{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
-				8, STATS_FLAGS_PORT, "rx_fragments" },
+				8, true, "rx_fragments" },
 	{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
-				8, STATS_FLAGS_PORT, "rx_jabbers" },
+				8, true, "rx_jabbers" },
 	{ STATS_OFFSET32(no_buff_discard_hi),
-				8, STATS_FLAGS_BOTH, "rx_discards" },
+				8, false, "rx_discards" },
 	{ STATS_OFFSET32(mac_filter_discard),
-				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
+				4, true, "rx_filtered_packets" },
 	{ STATS_OFFSET32(mf_tag_discard),
-				4, STATS_FLAGS_PORT, "rx_mf_tag_discard" },
+				4, true, "rx_mf_tag_discard" },
 	{ STATS_OFFSET32(pfc_frames_received_hi),
-				8, STATS_FLAGS_PORT, "pfc_frames_received" },
+				8, true, "pfc_frames_received" },
 	{ STATS_OFFSET32(pfc_frames_sent_hi),
-				8, STATS_FLAGS_PORT, "pfc_frames_sent" },
+				8, true, "pfc_frames_sent" },
 	{ STATS_OFFSET32(brb_drop_hi),
-				8, STATS_FLAGS_PORT, "rx_brb_discard" },
+				8, true, "rx_brb_discard" },
 	{ STATS_OFFSET32(brb_truncate_hi),
-				8, STATS_FLAGS_PORT, "rx_brb_truncate" },
+				8, true, "rx_brb_truncate" },
 	{ STATS_OFFSET32(pause_frames_received_hi),
-				8, STATS_FLAGS_PORT, "rx_pause_frames" },
+				8, true, "rx_pause_frames" },
 	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
-				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
+				8, true, "rx_mac_ctrl_frames" },
 	{ STATS_OFFSET32(nig_timer_max),
-			4, STATS_FLAGS_PORT, "rx_constant_pause_events" },
+				4, true, "rx_constant_pause_events" },
 /* 20 */{ STATS_OFFSET32(rx_err_discard_pkt),
-				4, STATS_FLAGS_BOTH, "rx_phy_ip_err_discards"},
+				4, false, "rx_phy_ip_err_discards"},
 	{ STATS_OFFSET32(rx_skb_alloc_failed),
-				4, STATS_FLAGS_BOTH, "rx_skb_alloc_discard" },
+				4, false, "rx_skb_alloc_discard" },
 	{ STATS_OFFSET32(hw_csum_err),
-				4, STATS_FLAGS_BOTH, "rx_csum_offload_errors" },
+				4, false, "rx_csum_offload_errors" },
 	{ STATS_OFFSET32(driver_xoff),
-				4, STATS_FLAGS_BOTH, "tx_exhaustion_events" },
+				4, false, "tx_exhaustion_events" },
 	{ STATS_OFFSET32(total_bytes_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_bytes" },
+				8, false, "tx_bytes" },
 	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
-				8, STATS_FLAGS_PORT, "tx_error_bytes" },
+				8, true, "tx_error_bytes" },
 	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_ucast_packets" },
+				8, false, "tx_ucast_packets" },
 	{ STATS_OFFSET32(total_multicast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_mcast_packets" },
+				8, false, "tx_mcast_packets" },
 	{ STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_bcast_packets" },
+				8, false, "tx_bcast_packets" },
 	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
-				8, STATS_FLAGS_PORT, "tx_mac_errors" },
+				8, true, "tx_mac_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
-				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
+				8, true, "tx_carrier_errors" },
 /* 30 */{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
-				8, STATS_FLAGS_PORT, "tx_single_collisions" },
+				8, true, "tx_single_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
-				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
+				8, true, "tx_multi_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
-				8, STATS_FLAGS_PORT, "tx_deferred" },
+				8, true, "tx_deferred" },
 	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
+				8, true, "tx_excess_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statslatecollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_late_collisions" },
+				8, true, "tx_late_collisions" },
 	{ STATS_OFFSET32(tx_stat_etherstatscollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_total_collisions" },
+				8, true, "tx_total_collisions" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
-				8, STATS_FLAGS_PORT, "tx_64_byte_packets" },
+				8, true, "tx_64_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
-			8, STATS_FLAGS_PORT, "tx_65_to_127_byte_packets" },
+				8, true, "tx_65_to_127_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts128octetsto255octets_hi),
-			8, STATS_FLAGS_PORT, "tx_128_to_255_byte_packets" },
+				8, true, "tx_128_to_255_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
-			8, STATS_FLAGS_PORT, "tx_256_to_511_byte_packets" },
+				8, true, "tx_256_to_511_byte_packets" },
 /* 40 */{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
-			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
+				8, true, "tx_512_to_1023_byte_packets" },
 	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
-			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
+				8, true, "tx_1024_to_1522_byte_packets" },
 	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
-			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
+				8, true, "tx_1523_to_9022_byte_packets" },
 	{ STATS_OFFSET32(pause_frames_sent_hi),
-				8, STATS_FLAGS_PORT, "tx_pause_frames" },
+				8, true, "tx_pause_frames" },
 	{ STATS_OFFSET32(total_tpa_aggregations_hi),
-			8, STATS_FLAGS_FUNC, "tpa_aggregations" },
+				8, false, "tpa_aggregations" },
 	{ STATS_OFFSET32(total_tpa_aggregated_frames_hi),
-			8, STATS_FLAGS_FUNC, "tpa_aggregated_frames"},
+				8, false, "tpa_aggregated_frames"},
 	{ STATS_OFFSET32(total_tpa_bytes_hi),
-			8, STATS_FLAGS_FUNC, "tpa_bytes"},
+				8, false, "tpa_bytes"},
 	{ STATS_OFFSET32(recoverable_error),
-			4, STATS_FLAGS_FUNC, "recoverable_errors" },
+				4, false, "recoverable_errors" },
 	{ STATS_OFFSET32(unrecoverable_error),
-			4, STATS_FLAGS_FUNC, "unrecoverable_errors" },
+				4, false, "unrecoverable_errors" },
 	{ STATS_OFFSET32(driver_filtered_tx_pkt),
-			4, STATS_FLAGS_FUNC, "driver_filtered_tx_pkt" },
+				4, false, "driver_filtered_tx_pkt" },
 	{ STATS_OFFSET32(eee_tx_lpi),
-			4, STATS_FLAGS_PORT, "Tx LPI entry count"}
+				4, true, "Tx LPI entry count"}
 };
 
 #define BNX2X_NUM_STATS		ARRAY_SIZE(bnx2x_stats_arr)
@@ -3066,9 +3063,7 @@ static void bnx2x_self_test(struct net_device *dev,
 	}
 }
 
-#define IS_PORT_STAT(i) \
-	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
-#define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
+#define IS_PORT_STAT(i)		(bnx2x_stats_arr[i].is_port_stat)
 #define HIDE_PORT_STAT(bp)	IS_VF(bp)
 
 /* ethtool statistics are displayed for all regular ethernet queues and the
@@ -3093,7 +3088,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 			num_strings = 0;
 		if (HIDE_PORT_STAT(bp)) {
 			for (i = 0; i < BNX2X_NUM_STATS; i++)
-				if (IS_FUNC_STAT(i))
+				if (!IS_PORT_STAT(i))
 					num_strings++;
 		} else
 			num_strings += BNX2X_NUM_STATS;
-- 
2.5.0
