From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next]  benet: convert to 64 bit stats
Date: Mon, 27 Jun 2011 11:43:13 -0700
Message-ID: <20110627114313.1d1b9680@nehalam.ftrdhcpuser.net>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
	<20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sathya Perla <sathya.perla@emulex.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55196 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab1F0SnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 14:43:18 -0400
In-Reply-To: <20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes how the benet driver does statistics:
  * use 64 bit statistics interface (old api was only 32 bit on 32 bit platform)
  * use u64_stats_sync to ensure atomic 64 bit on 32 bit SMP
  * only update statistics when needed

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---

 drivers/net/benet/be.h      |    4 -
 drivers/net/benet/be_cmds.c |    1 
 drivers/net/benet/be_main.c |  161 ++++++++++++++++++++++++--------------------
 3 files changed, 93 insertions(+), 73 deletions(-)

--- a/drivers/net/benet/be.h	2011-06-27 10:37:01.519999268 -0700
+++ b/drivers/net/benet/be.h	2011-06-27 11:00:02.691999144 -0700
@@ -29,6 +29,7 @@
 #include <linux/interrupt.h>
 #include <linux/firmware.h>
 #include <linux/slab.h>
+#include <linux/u64_stats_sync.h>
 
 #include "be_hw.h"
 
@@ -176,6 +177,7 @@ struct be_tx_stats {
 	u64 be_tx_bytes_prev;
 	u64 be_tx_pkts;
 	u32 be_tx_rate;
+	struct u64_stats_sync syncp;
 };
 
 struct be_tx_obj {
@@ -210,6 +212,7 @@ struct be_rx_stats {
 	u32 rx_frags;
 	u32 prev_rx_frags;
 	u32 rx_fps;		/* Rx frags per second */
+	struct u64_stats_sync syncp;
 };
 
 struct be_rx_compl_info {
@@ -526,7 +529,6 @@ static inline bool be_multi_rxq(const st
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
-extern void netdev_stats_update(struct be_adapter *adapter);
 extern void be_parse_stats(struct be_adapter *adapter);
 extern int be_load_fw(struct be_adapter *adapter, u8 *func);
 #endif				/* BE_H */
--- a/drivers/net/benet/be_main.c	2011-06-27 10:26:59.635999322 -0700
+++ b/drivers/net/benet/be_main.c	2011-06-27 10:59:37.923999145 -0700
@@ -418,77 +418,6 @@ void be_parse_stats(struct be_adapter *a
 	}
 }
 
-void netdev_stats_update(struct be_adapter *adapter)
-{
-	struct be_drv_stats *drvs = &adapter->drv_stats;
-	struct net_device_stats *dev_stats = &adapter->netdev->stats;
-	struct be_rx_obj *rxo;
-	struct be_tx_obj *txo;
-	unsigned long pkts = 0, bytes = 0, mcast = 0, drops = 0;
-	int i;
-
-	for_all_rx_queues(adapter, rxo, i) {
-		pkts += rx_stats(rxo)->rx_pkts;
-		bytes += rx_stats(rxo)->rx_bytes;
-		mcast += rx_stats(rxo)->rx_mcast_pkts;
-		/*  no space in linux buffers: best possible approximation */
-		if (adapter->generation == BE_GEN3) {
-			if (!(lancer_chip(adapter))) {
-				struct be_erx_stats_v1 *erx =
-					be_erx_stats_from_cmd(adapter);
-				drops += erx->rx_drops_no_fragments[rxo->q.id];
-			}
-		} else {
-			struct be_erx_stats_v0 *erx =
-					be_erx_stats_from_cmd(adapter);
-			drops += erx->rx_drops_no_fragments[rxo->q.id];
-		}
-	}
-	dev_stats->rx_packets = pkts;
-	dev_stats->rx_bytes = bytes;
-	dev_stats->multicast = mcast;
-	dev_stats->rx_dropped = drops;
-
-	pkts = bytes = 0;
-	for_all_tx_queues(adapter, txo, i) {
-		pkts += tx_stats(txo)->be_tx_pkts;
-		bytes += tx_stats(txo)->be_tx_bytes;
-	}
-	dev_stats->tx_packets = pkts;
-	dev_stats->tx_bytes = bytes;
-
-	/* bad pkts received */
-	dev_stats->rx_errors = drvs->rx_crc_errors +
-		drvs->rx_alignment_symbol_errors +
-		drvs->rx_in_range_errors +
-		drvs->rx_out_range_errors +
-		drvs->rx_frame_too_long +
-		drvs->rx_dropped_too_small +
-		drvs->rx_dropped_too_short +
-		drvs->rx_dropped_header_too_small +
-		drvs->rx_dropped_tcp_length +
-		drvs->rx_dropped_runt +
-		drvs->rx_tcp_checksum_errs +
-		drvs->rx_ip_checksum_errs +
-		drvs->rx_udp_checksum_errs;
-
-	/* detailed rx errors */
-	dev_stats->rx_length_errors = drvs->rx_in_range_errors +
-		drvs->rx_out_range_errors +
-		drvs->rx_frame_too_long;
-
-	dev_stats->rx_crc_errors = drvs->rx_crc_errors;
-
-	/* frame alignment errors */
-	dev_stats->rx_frame_errors = drvs->rx_alignment_symbol_errors;
-
-	/* receiver fifo overrun */
-	/* drops_no_pbuf is no per i/f, it's per BE card */
-	dev_stats->rx_fifo_errors = drvs->rxpp_fifo_overflow_drop +
-				drvs->rx_input_fifo_overflow_drop +
-				drvs->rx_drops_no_pbuf;
-}
-
 void be_link_status_update(struct be_adapter *adapter, bool link_up)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -586,8 +515,10 @@ static void be_tx_stats_update(struct be
 
 	stats->be_tx_reqs++;
 	stats->be_tx_wrbs += wrb_cnt;
+	u64_stats_update_begin(&stats->syncp);
 	stats->be_tx_bytes += copied;
 	stats->be_tx_pkts += (gso_segs ? gso_segs : 1);
+	u64_stats_update_end(&stats->syncp);
 	if (stopped)
 		stats->be_tx_stops++;
 }
@@ -793,6 +724,89 @@ static netdev_tx_t be_xmit(struct sk_buf
 	return NETDEV_TX_OK;
 }
 
+static struct rtnl_link_stats64 *be_get_stats(struct net_device *netdev,
+					      struct rtnl_link_stats64 *stats)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_drv_stats *drvs = &adapter->drv_stats;
+	const struct be_rx_obj *rxo;
+	const struct be_tx_obj *txo;
+	u64 pkts, bytes;
+	unsigned int start;
+	int i;
+
+	for_all_rx_queues(adapter, rxo, i) {
+		const struct be_rx_stats *rx_stats = rx_stats(rxo);
+		do {
+			start = u64_stats_fetch_begin(&rx_stats->syncp);
+			pkts = rx_stats->rx_pkts;
+			bytes = rx_stats->rx_bytes;
+		} while (u64_stats_fetch_retry(&rx_stats->syncp, start));
+
+		stats->rx_packets += pkts;
+		stats->rx_bytes += bytes;
+		stats->multicast += rx_stats->rx_mcast_pkts;
+
+		/*  no space in linux buffers: best possible approximation */
+		if (adapter->generation == BE_GEN3) {
+			if (!(lancer_chip(adapter))) {
+				const struct be_erx_stats_v1 *erx =
+					be_erx_stats_from_cmd(adapter);
+				stats->rx_dropped += erx->rx_drops_no_fragments[rxo->q.id];
+			}
+		} else {
+			const struct be_erx_stats_v0 *erx =
+				be_erx_stats_from_cmd(adapter);
+			stats->rx_dropped += erx->rx_drops_no_fragments[rxo->q.id];
+		}
+	}
+
+	for_all_tx_queues(adapter, txo, i) {
+		const struct be_tx_stats *tx_stats = tx_stats(txo);
+		do {
+			start = u64_stats_fetch_begin(&tx_stats->syncp);
+			pkts = tx_stats->be_tx_pkts;
+			bytes = tx_stats->be_tx_bytes;
+		} while (u64_stats_fetch_retry(&tx_stats->syncp, start));
+
+		stats->tx_packets += pkts;
+		stats->tx_bytes += bytes;
+	}
+
+	/* bad pkts received */
+	stats->rx_errors = drvs->rx_crc_errors +
+		drvs->rx_alignment_symbol_errors +
+		drvs->rx_in_range_errors +
+		drvs->rx_out_range_errors +
+		drvs->rx_frame_too_long +
+		drvs->rx_dropped_too_small +
+		drvs->rx_dropped_too_short +
+		drvs->rx_dropped_header_too_small +
+		drvs->rx_dropped_tcp_length +
+		drvs->rx_dropped_runt +
+		drvs->rx_tcp_checksum_errs +
+		drvs->rx_ip_checksum_errs +
+		drvs->rx_udp_checksum_errs;
+
+	/* detailed rx errors */
+	stats->rx_length_errors = drvs->rx_in_range_errors +
+		drvs->rx_out_range_errors +
+		drvs->rx_frame_too_long;
+
+	stats->rx_crc_errors = drvs->rx_crc_errors;
+
+	/* frame alignment errors */
+	stats->rx_frame_errors = drvs->rx_alignment_symbol_errors;
+
+	/* receiver fifo overrun */
+	/* drops_no_pbuf is no per i/f, it's per BE card */
+	stats->rx_fifo_errors = drvs->rxpp_fifo_overflow_drop +
+		drvs->rx_input_fifo_overflow_drop +
+		drvs->rx_drops_no_pbuf;
+
+	return stats;
+}
+
 static int be_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1040,8 +1054,12 @@ static void be_rx_stats_update(struct be
 
 	stats->rx_compl++;
 	stats->rx_frags += rxcp->num_rcvd;
+
+	u64_stats_update_begin(&stats->syncp);
 	stats->rx_bytes += rxcp->pkt_size;
 	stats->rx_pkts++;
+	u64_stats_update_end(&stats->syncp);
+
 	if (rxcp->pkt_type == BE_MULTICAST_PACKET)
 		stats->rx_mcast_pkts++;
 	if (rxcp->err)
@@ -2918,6 +2936,7 @@ static struct net_device_ops be_netdev_o
 	.ndo_set_rx_mode	= be_set_multicast_list,
 	.ndo_set_mac_address	= be_mac_addr_set,
 	.ndo_change_mtu		= be_change_mtu,
+	.ndo_get_stats64	= be_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
--- a/drivers/net/benet/be_cmds.c	2011-06-27 10:59:50.935999145 -0700
+++ b/drivers/net/benet/be_cmds.c	2011-06-27 10:59:54.643999144 -0700
@@ -103,7 +103,6 @@ static int be_mcc_compl_process(struct b
 							sizeof(resp->hw_stats));
 			}
 			be_parse_stats(adapter);
-			netdev_stats_update(adapter);
 			adapter->stats_cmd_sent = false;
 		}
 	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
