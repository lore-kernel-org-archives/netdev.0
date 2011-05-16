From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 2/3] be2net: Stats for Lancer
Date: Mon, 16 May 2011 23:06:35 +0530
Message-ID: <ff5e7864-8c7b-453e-96ed-d7ee20c6dae6@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Selvin Xavier <selvin.xavier@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37884 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753870Ab1EPRhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:37:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Selvin Xavier <selvin.xavier@emulex.com>

Added Lancer stats implementation.

Signed-off-by: Selvin Xavier <selvin.xavier@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be.h      |   74 ++++++++--------
 drivers/net/benet/be_cmds.c |   55 ++++++++++++-
 drivers/net/benet/be_cmds.h |  197 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_main.c |   91 +++++++++++++++++---
 4 files changed, 367 insertions(+), 50 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 0da0384..0b73dcf 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -244,43 +244,43 @@ struct be_rx_obj {
 
 struct be_drv_stats {
 	u8 be_on_die_temperature;
-	u32 be_tx_events;
-	u32 eth_red_drops;
-	u32 rx_drops_no_pbuf;
-	u32 rx_drops_no_txpb;
-	u32 rx_drops_no_erx_descr;
-	u32 rx_drops_no_tpre_descr;
-	u32 rx_drops_too_many_frags;
-	u32 rx_drops_invalid_ring;
-	u32 forwarded_packets;
-	u32 rx_drops_mtu;
-	u32 rx_crc_errors;
-	u32 rx_alignment_symbol_errors;
-	u32 rx_pause_frames;
-	u32 rx_priority_pause_frames;
-	u32 rx_control_frames;
-	u32 rx_in_range_errors;
-	u32 rx_out_range_errors;
-	u32 rx_frame_too_long;
-	u32 rx_address_match_errors;
-	u32 rx_dropped_too_small;
-	u32 rx_dropped_too_short;
-	u32 rx_dropped_header_too_small;
-	u32 rx_dropped_tcp_length;
-	u32 rx_dropped_runt;
-	u32 rx_ip_checksum_errs;
-	u32 rx_tcp_checksum_errs;
-	u32 rx_udp_checksum_errs;
-	u32 rx_switched_unicast_packets;
-	u32 rx_switched_multicast_packets;
-	u32 rx_switched_broadcast_packets;
-	u32 tx_pauseframes;
-	u32 tx_priority_pauseframes;
-	u32 tx_controlframes;
-	u32 rxpp_fifo_overflow_drop;
-	u32 rx_input_fifo_overflow_drop;
-	u32 pmem_fifo_overflow_drop;
-	u32 jabber_events;
+	u64 be_tx_events;
+	u64 eth_red_drops;
+	u64 rx_drops_no_pbuf;
+	u64 rx_drops_no_txpb;
+	u64 rx_drops_no_erx_descr;
+	u64 rx_drops_no_tpre_descr;
+	u64 rx_drops_too_many_frags;
+	u64 rx_drops_invalid_ring;
+	u64 forwarded_packets;
+	u64 rx_drops_mtu;
+	u64 rx_crc_errors;
+	u64 rx_alignment_symbol_errors;
+	u64 rx_pause_frames;
+	u64 rx_priority_pause_frames;
+	u64 rx_control_frames;
+	u64 rx_in_range_errors;
+	u64 rx_out_range_errors;
+	u64 rx_frame_too_long;
+	u64 rx_address_match_errors;
+	u64 rx_dropped_too_small;
+	u64 rx_dropped_too_short;
+	u64 rx_dropped_header_too_small;
+	u64 rx_dropped_tcp_length;
+	u64 rx_dropped_runt;
+	u64 rx_ip_checksum_errs;
+	u64 rx_tcp_checksum_errs;
+	u64 rx_udp_checksum_errs;
+	u64 rx_switched_unicast_packets;
+	u64 rx_switched_multicast_packets;
+	u64 rx_switched_broadcast_packets;
+	u64 tx_pauseframes;
+	u64 tx_priority_pauseframes;
+	u64 tx_controlframes;
+	u64 rxpp_fifo_overflow_drop;
+	u64 rx_input_fifo_overflow_drop;
+	u64 pmem_fifo_overflow_drop;
+	u64 jabber_events;
 };
 
 struct be_vf_cfg {
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 08e0938..aaef0c7 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -78,14 +78,22 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	}
 
 	if (compl_status == MCC_STATUS_SUCCESS) {
-		if ((compl->tag0 == OPCODE_ETH_GET_STATISTICS) &&
+		if (((compl->tag0 == OPCODE_ETH_GET_STATISTICS) ||
+			 (compl->tag0 == OPCODE_ETH_GET_PPORT_STATS)) &&
 			(compl->tag1 == CMD_SUBSYSTEM_ETH)) {
 			if (adapter->generation == BE_GEN3) {
-				struct be_cmd_resp_get_stats_v1 *resp =
+				if (lancer_chip(adapter)) {
+					struct lancer_cmd_resp_pport_stats
+						*resp = adapter->stats_cmd.va;
+					be_dws_le_to_cpu(&resp->pport_stats,
+						sizeof(resp->pport_stats));
+				} else {
+					struct be_cmd_resp_get_stats_v1 *resp =
 							adapter->stats_cmd.va;
 
 				be_dws_le_to_cpu(&resp->hw_stats,
 							sizeof(resp->hw_stats));
+				}
 			} else {
 				struct be_cmd_resp_get_stats_v0 *resp =
 							adapter->stats_cmd.va;
@@ -1124,6 +1132,49 @@ err:
 	return status;
 }
 
+/* Lancer Stats */
+int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
+				struct be_dma_mem *nonemb_cmd)
+{
+
+	struct be_mcc_wrb *wrb;
+	struct lancer_cmd_req_pport_stats *req;
+	struct be_sge *sge;
+	int status = 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = nonemb_cmd->va;
+	sge = nonembedded_sgl(wrb);
+
+	be_wrb_hdr_prepare(wrb, nonemb_cmd->size, false, 1,
+			OPCODE_ETH_GET_PPORT_STATS);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+			OPCODE_ETH_GET_PPORT_STATS, nonemb_cmd->size);
+
+
+	req->cmd_params.params.pport_num = cpu_to_le16(adapter->port_num);
+	req->cmd_params.params.reset_stats = 0;
+
+	wrb->tag1 = CMD_SUBSYSTEM_ETH;
+	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
+	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(nonemb_cmd->size);
+
+	be_mcc_notify(adapter);
+	adapter->stats_cmd_sent = true;
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 /* Uses synchronous mcc */
 int be_cmd_link_status_query(struct be_adapter *adapter,
 			bool *link_up, u8 *mac_speed, u16 *link_speed, u32 dom)
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index bcf816d..9cff226 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -203,6 +203,7 @@ struct be_mcc_mailbox {
 #define OPCODE_ETH_TX_DESTROY           		9
 #define OPCODE_ETH_RX_DESTROY           		10
 #define OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG		12
+#define OPCODE_ETH_GET_PPORT_STATS			18
 
 #define OPCODE_LOWLEVEL_HOST_DDR_DMA                    17
 #define OPCODE_LOWLEVEL_LOOPBACK_TEST                   18
@@ -688,6 +689,200 @@ struct be_cmd_resp_get_stats_v0 {
 	struct be_hw_stats_v0 hw_stats;
 };
 
+#define make_64bit_val(hi_32, lo_32)	(((u64)hi_32<<32) | lo_32)
+struct lancer_cmd_pport_stats {
+	u32 tx_packets_lo;
+	u32 tx_packets_hi;
+	u32 tx_unicast_packets_lo;
+	u32 tx_unicast_packets_hi;
+	u32 tx_multicast_packets_lo;
+	u32 tx_multicast_packets_hi;
+	u32 tx_broadcast_packets_lo;
+	u32 tx_broadcast_packets_hi;
+	u32 tx_bytes_lo;
+	u32 tx_bytes_hi;
+	u32 tx_unicast_bytes_lo;
+	u32 tx_unicast_bytes_hi;
+	u32 tx_multicast_bytes_lo;
+	u32 tx_multicast_bytes_hi;
+	u32 tx_broadcast_bytes_lo;
+	u32 tx_broadcast_bytes_hi;
+	u32 tx_discards_lo;
+	u32 tx_discards_hi;
+	u32 tx_errors_lo;
+	u32 tx_errors_hi;
+	u32 tx_pause_frames_lo;
+	u32 tx_pause_frames_hi;
+	u32 tx_pause_on_frames_lo;
+	u32 tx_pause_on_frames_hi;
+	u32 tx_pause_off_frames_lo;
+	u32 tx_pause_off_frames_hi;
+	u32 tx_internal_mac_errors_lo;
+	u32 tx_internal_mac_errors_hi;
+	u32 tx_control_frames_lo;
+	u32 tx_control_frames_hi;
+	u32 tx_packets_64_bytes_lo;
+	u32 tx_packets_64_bytes_hi;
+	u32 tx_packets_65_to_127_bytes_lo;
+	u32 tx_packets_65_to_127_bytes_hi;
+	u32 tx_packets_128_to_255_bytes_lo;
+	u32 tx_packets_128_to_255_bytes_hi;
+	u32 tx_packets_256_to_511_bytes_lo;
+	u32 tx_packets_256_to_511_bytes_hi;
+	u32 tx_packets_512_to_1023_bytes_lo;
+	u32 tx_packets_512_to_1023_bytes_hi;
+	u32 tx_packets_1024_to_1518_bytes_lo;
+	u32 tx_packets_1024_to_1518_bytes_hi;
+	u32 tx_packets_1519_to_2047_bytes_lo;
+	u32 tx_packets_1519_to_2047_bytes_hi;
+	u32 tx_packets_2048_to_4095_bytes_lo;
+	u32 tx_packets_2048_to_4095_bytes_hi;
+	u32 tx_packets_4096_to_8191_bytes_lo;
+	u32 tx_packets_4096_to_8191_bytes_hi;
+	u32 tx_packets_8192_to_9216_bytes_lo;
+	u32 tx_packets_8192_to_9216_bytes_hi;
+	u32 tx_lso_packets_lo;
+	u32 tx_lso_packets_hi;
+	u32 rx_packets_lo;
+	u32 rx_packets_hi;
+	u32 rx_unicast_packets_lo;
+	u32 rx_unicast_packets_hi;
+	u32 rx_multicast_packets_lo;
+	u32 rx_multicast_packets_hi;
+	u32 rx_broadcast_packets_lo;
+	u32 rx_broadcast_packets_hi;
+	u32 rx_bytes_lo;
+	u32 rx_bytes_hi;
+	u32 rx_unicast_bytes_lo;
+	u32 rx_unicast_bytes_hi;
+	u32 rx_multicast_bytes_lo;
+	u32 rx_multicast_bytes_hi;
+	u32 rx_broadcast_bytes_lo;
+	u32 rx_broadcast_bytes_hi;
+	u32 rx_unknown_protos;
+	u32 rsvd_69; /* Word 69 is reserved */
+	u32 rx_discards_lo;
+	u32 rx_discards_hi;
+	u32 rx_errors_lo;
+	u32 rx_errors_hi;
+	u32 rx_crc_errors_lo;
+	u32 rx_crc_errors_hi;
+	u32 rx_alignment_errors_lo;
+	u32 rx_alignment_errors_hi;
+	u32 rx_symbol_errors_lo;
+	u32 rx_symbol_errors_hi;
+	u32 rx_pause_frames_lo;
+	u32 rx_pause_frames_hi;
+	u32 rx_pause_on_frames_lo;
+	u32 rx_pause_on_frames_hi;
+	u32 rx_pause_off_frames_lo;
+	u32 rx_pause_off_frames_hi;
+	u32 rx_frames_too_long_lo;
+	u32 rx_frames_too_long_hi;
+	u32 rx_internal_mac_errors_lo;
+	u32 rx_internal_mac_errors_hi;
+	u32 rx_undersize_packets;
+	u32 rx_oversize_packets;
+	u32 rx_fragment_packets;
+	u32 rx_jabbers;
+	u32 rx_control_frames_lo;
+	u32 rx_control_frames_hi;
+	u32 rx_control_frames_unknown_opcode_lo;
+	u32 rx_control_frames_unknown_opcode_hi;
+	u32 rx_in_range_errors;
+	u32 rx_out_of_range_errors;
+	u32 rx_address_match_errors;
+	u32 rx_vlan_mismatch_errors;
+	u32 rx_dropped_too_small;
+	u32 rx_dropped_too_short;
+	u32 rx_dropped_header_too_small;
+	u32 rx_dropped_invalid_tcp_length;
+	u32 rx_dropped_runt;
+	u32 rx_ip_checksum_errors;
+	u32 rx_tcp_checksum_errors;
+	u32 rx_udp_checksum_errors;
+	u32 rx_non_rss_packets;
+	u32 rsvd_111;
+	u32 rx_ipv4_packets_lo;
+	u32 rx_ipv4_packets_hi;
+	u32 rx_ipv6_packets_lo;
+	u32 rx_ipv6_packets_hi;
+	u32 rx_ipv4_bytes_lo;
+	u32 rx_ipv4_bytes_hi;
+	u32 rx_ipv6_bytes_lo;
+	u32 rx_ipv6_bytes_hi;
+	u32 rx_nic_packets_lo;
+	u32 rx_nic_packets_hi;
+	u32 rx_tcp_packets_lo;
+	u32 rx_tcp_packets_hi;
+	u32 rx_iscsi_packets_lo;
+	u32 rx_iscsi_packets_hi;
+	u32 rx_management_packets_lo;
+	u32 rx_management_packets_hi;
+	u32 rx_switched_unicast_packets_lo;
+	u32 rx_switched_unicast_packets_hi;
+	u32 rx_switched_multicast_packets_lo;
+	u32 rx_switched_multicast_packets_hi;
+	u32 rx_switched_broadcast_packets_lo;
+	u32 rx_switched_broadcast_packets_hi;
+	u32 num_forwards_lo;
+	u32 num_forwards_hi;
+	u32 rx_fifo_overflow;
+	u32 rx_input_fifo_overflow;
+	u32 rx_drops_too_many_frags_lo;
+	u32 rx_drops_too_many_frags_hi;
+	u32 rx_drops_invalid_queue;
+	u32 rsvd_141;
+	u32 rx_drops_mtu_lo;
+	u32 rx_drops_mtu_hi;
+	u32 rx_packets_64_bytes_lo;
+	u32 rx_packets_64_bytes_hi;
+	u32 rx_packets_65_to_127_bytes_lo;
+	u32 rx_packets_65_to_127_bytes_hi;
+	u32 rx_packets_128_to_255_bytes_lo;
+	u32 rx_packets_128_to_255_bytes_hi;
+	u32 rx_packets_256_to_511_bytes_lo;
+	u32 rx_packets_256_to_511_bytes_hi;
+	u32 rx_packets_512_to_1023_bytes_lo;
+	u32 rx_packets_512_to_1023_bytes_hi;
+	u32 rx_packets_1024_to_1518_bytes_lo;
+	u32 rx_packets_1024_to_1518_bytes_hi;
+	u32 rx_packets_1519_to_2047_bytes_lo;
+	u32 rx_packets_1519_to_2047_bytes_hi;
+	u32 rx_packets_2048_to_4095_bytes_lo;
+	u32 rx_packets_2048_to_4095_bytes_hi;
+	u32 rx_packets_4096_to_8191_bytes_lo;
+	u32 rx_packets_4096_to_8191_bytes_hi;
+	u32 rx_packets_8192_to_9216_bytes_lo;
+	u32 rx_packets_8192_to_9216_bytes_hi;
+};
+
+struct pport_stats_params {
+	u16 pport_num;
+	u8 rsvd;
+	u8 reset_stats;
+};
+
+struct lancer_cmd_req_pport_stats {
+	struct be_cmd_req_hdr hdr;
+	union {
+		struct pport_stats_params params;
+		u8 rsvd[sizeof(struct lancer_cmd_pport_stats)];
+	} cmd_params;
+};
+
+struct lancer_cmd_resp_pport_stats {
+	struct be_cmd_resp_hdr hdr;
+	struct lancer_cmd_pport_stats pport_stats;
+};
+
+static inline  struct lancer_cmd_pport_stats*
+	pport_stats_from_cmd(struct be_adapter *adapter)
+{
+	struct lancer_cmd_resp_pport_stats *cmd = adapter->stats_cmd.va;
+	return &cmd->pport_stats;
+}
+
 struct be_cmd_req_get_cntl_addnl_attribs {
 	struct be_cmd_req_hdr hdr;
 	u8 rsvd[8];
@@ -1258,6 +1453,8 @@ extern int be_cmd_link_status_query(struct be_adapter *adapter,
 extern int be_cmd_reset(struct be_adapter *adapter);
 extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
+extern int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
+			struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver);
 
 extern int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index cff2cca..93be84c 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -351,14 +351,73 @@ static void populate_be3_stats(struct be_adapter *adapter)
 	adapter->drv_stats.eth_red_drops = pmem_sts->eth_red_drops;
 }
 
+static void populate_lancer_stats(struct be_adapter *adapter)
+{
 
+	struct be_drv_stats *drvs = &adapter->drv_stats;
+	struct lancer_cmd_pport_stats *pport_stats = pport_stats_from_cmd
+						(adapter);
+	drvs->rx_priority_pause_frames = 0;
+	drvs->pmem_fifo_overflow_drop = 0;
+	drvs->rx_pause_frames =
+		make_64bit_val(pport_stats->rx_pause_frames_lo,
+				 pport_stats->rx_pause_frames_hi);
+	drvs->rx_crc_errors = make_64bit_val(pport_stats->rx_crc_errors_hi,
+						pport_stats->rx_crc_errors_lo);
+	drvs->rx_control_frames =
+			make_64bit_val(pport_stats->rx_control_frames_hi,
+			pport_stats->rx_control_frames_lo);
+	drvs->rx_in_range_errors = pport_stats->rx_in_range_errors;
+	drvs->rx_frame_too_long =
+		make_64bit_val(pport_stats->rx_internal_mac_errors_hi,
+					pport_stats->rx_frames_too_long_lo);
+	drvs->rx_dropped_runt = pport_stats->rx_dropped_runt;
+	drvs->rx_ip_checksum_errs = pport_stats->rx_ip_checksum_errors;
+	drvs->rx_tcp_checksum_errs = pport_stats->rx_tcp_checksum_errors;
+	drvs->rx_udp_checksum_errs = pport_stats->rx_udp_checksum_errors;
+	drvs->rx_dropped_tcp_length =
+				pport_stats->rx_dropped_invalid_tcp_length;
+	drvs->rx_dropped_too_small = pport_stats->rx_dropped_too_small;
+	drvs->rx_dropped_too_short = pport_stats->rx_dropped_too_short;
+	drvs->rx_out_range_errors = pport_stats->rx_out_of_range_errors;
+	drvs->rx_dropped_header_too_small =
+				pport_stats->rx_dropped_header_too_small;
+	drvs->rx_input_fifo_overflow_drop = pport_stats->rx_fifo_overflow;
+	drvs->rx_address_match_errors = pport_stats->rx_address_match_errors;
+	drvs->rx_alignment_symbol_errors =
+		make_64bit_val(pport_stats->rx_symbol_errors_hi,
+				pport_stats->rx_symbol_errors_lo);
+	drvs->rxpp_fifo_overflow_drop = pport_stats->rx_fifo_overflow;
+	drvs->tx_pauseframes = make_64bit_val(pport_stats->tx_pause_frames_hi,
+					pport_stats->tx_pause_frames_lo);
+	drvs->tx_controlframes =
+		make_64bit_val(pport_stats->tx_control_frames_hi,
+				pport_stats->tx_control_frames_lo);
+	drvs->jabber_events = pport_stats->rx_jabbers;
+	drvs->rx_drops_no_pbuf = 0;
+	drvs->rx_drops_no_txpb = 0;
+	drvs->rx_drops_no_erx_descr = 0;
+	drvs->rx_drops_invalid_ring = pport_stats->rx_drops_invalid_queue;
+	drvs->forwarded_packets = make_64bit_val(pport_stats->num_forwards_hi,
+						pport_stats->num_forwards_lo);
+	drvs->rx_drops_mtu = make_64bit_val(pport_stats->rx_drops_mtu_hi,
+						pport_stats->rx_drops_mtu_lo);
+	drvs->rx_drops_no_tpre_descr = 0;
+	drvs->rx_drops_too_many_frags =
+		make_64bit_val(pport_stats->rx_drops_too_many_frags_hi,
+				pport_stats->rx_drops_too_many_frags_lo);
+}
 
 void be_parse_stats(struct be_adapter *adapter)
 {
-	if (adapter->generation == BE_GEN3)
-		populate_be3_stats(adapter);
-	else
+	if (adapter->generation == BE_GEN3) {
+		if (lancer_chip(adapter))
+			populate_lancer_stats(adapter);
+		 else
+			populate_be3_stats(adapter);
+	} else {
 		populate_be2_stats(adapter);
+	}
 }
 
 void netdev_stats_update(struct be_adapter *adapter)
@@ -375,10 +434,12 @@ void netdev_stats_update(struct be_adapter *adapter)
 		dev_stats->multicast += rx_stats(rxo)->rx_mcast_pkts;
 		/*  no space in linux buffers: best possible approximation */
 		if (adapter->generation == BE_GEN3) {
-			struct be_erx_stats_v1 *erx_stats =
+			if (!(lancer_chip(adapter))) {
+				struct be_erx_stats_v1 *erx_stats =
 					be_erx_stats_from_cmd(adapter);
-			dev_stats->rx_dropped +=
+				dev_stats->rx_dropped +=
 				erx_stats->rx_drops_no_fragments[rxo->q.id];
+			}
 		} else {
 			struct be_erx_stats_v0 *erx_stats =
 					be_erx_stats_from_cmd(adapter);
@@ -2022,9 +2083,13 @@ static void be_worker(struct work_struct *work)
 		goto reschedule;
 	}
 
-	if (!adapter->stats_cmd_sent)
-		be_cmd_get_stats(adapter, &adapter->stats_cmd);
-
+	if (!adapter->stats_cmd_sent) {
+		if (lancer_chip(adapter))
+			lancer_cmd_get_pport_stats(adapter,
+						&adapter->stats_cmd);
+		else
+			be_cmd_get_stats(adapter, &adapter->stats_cmd);
+	}
 	be_tx_rate_update(adapter);
 
 	for_all_rx_queues(adapter, rxo, i) {
@@ -2944,10 +3009,14 @@ static int be_stats_init(struct be_adapter *adapter)
 {
 	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
-	if (adapter->generation == BE_GEN2)
+	if (adapter->generation == BE_GEN2) {
 		cmd->size = sizeof(struct be_cmd_req_get_stats_v0);
-	else
-		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
+	} else {
+		if (lancer_chip(adapter))
+			cmd->size = sizeof(struct lancer_cmd_req_pport_stats);
+		else
+			cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
+	}
 	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
 				     GFP_KERNEL);
 	if (cmd->va == NULL)
-- 
1.6.0.2

