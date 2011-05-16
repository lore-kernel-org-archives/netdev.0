From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 1/3] be2net: Support for version 1 of stats for BE3
Date: Mon, 16 May 2011 23:06:18 +0530
Message-ID: <d51c64b4-85e5-48eb-8ca5-aed1d17f2307@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Selvin Xavier <selvin.xavier@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37878 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753683Ab1EPRgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:36:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>

Added support to get version 1 of the stats for BE3.
Use old stats command for BE2.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Selvin Xavier <selvin.xavier@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be.h         |   38 ++++++++
 drivers/net/benet/be_cmds.c    |   32 +++++--
 drivers/net/benet/be_cmds.h    |  181 ++++++++++++++++++++++++++++++++++-----
 drivers/net/benet/be_ethtool.c |  108 +++++++++---------------
 drivers/net/benet/be_main.c    |  182 +++++++++++++++++++++++++++++++++-------
 5 files changed, 413 insertions(+), 128 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 41bbc32..0da0384 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -244,6 +244,43 @@ struct be_rx_obj {
 
 struct be_drv_stats {
 	u8 be_on_die_temperature;
+	u32 be_tx_events;
+	u32 eth_red_drops;
+	u32 rx_drops_no_pbuf;
+	u32 rx_drops_no_txpb;
+	u32 rx_drops_no_erx_descr;
+	u32 rx_drops_no_tpre_descr;
+	u32 rx_drops_too_many_frags;
+	u32 rx_drops_invalid_ring;
+	u32 forwarded_packets;
+	u32 rx_drops_mtu;
+	u32 rx_crc_errors;
+	u32 rx_alignment_symbol_errors;
+	u32 rx_pause_frames;
+	u32 rx_priority_pause_frames;
+	u32 rx_control_frames;
+	u32 rx_in_range_errors;
+	u32 rx_out_range_errors;
+	u32 rx_frame_too_long;
+	u32 rx_address_match_errors;
+	u32 rx_dropped_too_small;
+	u32 rx_dropped_too_short;
+	u32 rx_dropped_header_too_small;
+	u32 rx_dropped_tcp_length;
+	u32 rx_dropped_runt;
+	u32 rx_ip_checksum_errs;
+	u32 rx_tcp_checksum_errs;
+	u32 rx_udp_checksum_errs;
+	u32 rx_switched_unicast_packets;
+	u32 rx_switched_multicast_packets;
+	u32 rx_switched_broadcast_packets;
+	u32 tx_pauseframes;
+	u32 tx_priority_pauseframes;
+	u32 tx_controlframes;
+	u32 rxpp_fifo_overflow_drop;
+	u32 rx_input_fifo_overflow_drop;
+	u32 pmem_fifo_overflow_drop;
+	u32 jabber_events;
 };
 
 struct be_vf_cfg {
@@ -483,5 +520,6 @@ extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
 extern void netdev_stats_update(struct be_adapter *adapter);
+extern void be_parse_stats(struct be_adapter *adapter);
 extern int be_load_fw(struct be_adapter *adapter, u8 *func);
 #endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index f2c9099..08e0938 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -80,10 +80,20 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	if (compl_status == MCC_STATUS_SUCCESS) {
 		if ((compl->tag0 == OPCODE_ETH_GET_STATISTICS) &&
 			(compl->tag1 == CMD_SUBSYSTEM_ETH)) {
-			struct be_cmd_resp_get_stats *resp =
-						adapter->stats_cmd.va;
-			be_dws_le_to_cpu(&resp->hw_stats,
-						sizeof(resp->hw_stats));
+			if (adapter->generation == BE_GEN3) {
+				struct be_cmd_resp_get_stats_v1 *resp =
+							adapter->stats_cmd.va;
+
+				be_dws_le_to_cpu(&resp->hw_stats,
+							sizeof(resp->hw_stats));
+			} else {
+				struct be_cmd_resp_get_stats_v0 *resp =
+							adapter->stats_cmd.va;
+
+				be_dws_le_to_cpu(&resp->hw_stats,
+							sizeof(resp->hw_stats));
+			}
+			be_parse_stats(adapter);
 			netdev_stats_update(adapter);
 			adapter->stats_cmd_sent = false;
 		}
@@ -1075,7 +1085,7 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_get_stats *req;
+	struct be_cmd_req_hdr *hdr;
 	struct be_sge *sge;
 	int status = 0;
 
@@ -1089,14 +1099,18 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 		status = -EBUSY;
 		goto err;
 	}
-	req = nonemb_cmd->va;
+	hdr = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+	be_wrb_hdr_prepare(wrb, nonemb_cmd->size, false, 1,
 			OPCODE_ETH_GET_STATISTICS);
 
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_GET_STATISTICS, sizeof(*req));
+	be_cmd_hdr_prepare(hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_GET_STATISTICS, nonemb_cmd->size);
+
+	if (adapter->generation == BE_GEN3)
+		hdr->version = 1;
+
 	wrb->tag1 = CMD_SUBSYSTEM_ETH;
 	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
 	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 78256b6..bcf816d 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -568,7 +568,7 @@ struct be_cmd_req_if_destroy {
 };
 
 /*************** HW Stats Get **********************************/
-struct be_port_rxf_stats {
+struct be_port_rxf_stats_v0 {
 	u32 rx_bytes_lsd;	/* dword 0*/
 	u32 rx_bytes_msd;	/* dword 1*/
 	u32 rx_total_frames;	/* dword 2*/
@@ -637,8 +637,8 @@ struct be_port_rxf_stats {
 	u32 rx_input_fifo_overflow;	/* dword 65*/
 };
 
-struct be_rxf_stats {
-	struct be_port_rxf_stats port[2];
+struct be_rxf_stats_v0 {
+	struct be_port_rxf_stats_v0 port[2];
 	u32 rx_drops_no_pbuf;	/* dword 132*/
 	u32 rx_drops_no_txpb;	/* dword 133*/
 	u32 rx_drops_no_erx_descr;	/* dword 134*/
@@ -661,34 +661,31 @@ struct be_rxf_stats {
 	u32 rsvd1[6];
 };
 
-struct be_erx_stats {
+struct be_erx_stats_v0 {
 	u32 rx_drops_no_fragments[44];     /* dwordS 0 to 43*/
-	u32 debug_wdma_sent_hold;          /* dword 44*/
-	u32 debug_wdma_pbfree_sent_hold;   /* dword 45*/
-	u32 debug_wdma_zerobyte_pbfree_sent_hold; /* dword 46*/
-	u32 debug_pmem_pbuf_dealloc;       /* dword 47*/
+	u32 rsvd[4];
 };
 
 struct be_pmem_stats {
 	u32 eth_red_drops;
-	u32 rsvd[4];
+	u32 rsvd[5];
 };
 
-struct be_hw_stats {
-	struct be_rxf_stats rxf;
+struct be_hw_stats_v0 {
+	struct be_rxf_stats_v0 rxf;
 	u32 rsvd[48];
-	struct be_erx_stats erx;
+	struct be_erx_stats_v0 erx;
 	struct be_pmem_stats pmem;
 };
 
-struct be_cmd_req_get_stats {
+struct be_cmd_req_get_stats_v0 {
 	struct be_cmd_req_hdr hdr;
-	u8 rsvd[sizeof(struct be_hw_stats)];
+	u8 rsvd[sizeof(struct be_hw_stats_v0)];
 };
 
-struct be_cmd_resp_get_stats {
+struct be_cmd_resp_get_stats_v0 {
 	struct be_cmd_resp_hdr hdr;
-	struct be_hw_stats hw_stats;
+	struct be_hw_stats_v0 hw_stats;
 };
 
 struct be_cmd_req_get_cntl_addnl_attribs {
@@ -728,13 +725,6 @@ struct be_cmd_req_mcast_mac_config {
 	struct macaddr mac[BE_MAX_MC];
 } __packed;
 
-static inline struct be_hw_stats *
-hw_stats_from_cmd(struct be_cmd_resp_get_stats *cmd)
-{
-	return &cmd->hw_stats;
-}
-
-
 /******************* RX FILTER ******************************/
 struct be_cmd_req_rx_filter {
 	struct be_cmd_req_hdr hdr;
@@ -1087,6 +1077,151 @@ struct be_cmd_resp_set_func_cap {
 	u8 rsvd[212];
 };
 
+/*************** HW Stats Get v1 **********************************/
+#define BE_TXP_SW_SZ			48
+struct be_port_rxf_stats_v1 {
+	u32 rsvd0[12];
+	u32 rx_crc_errors;
+	u32 rx_alignment_symbol_errors;
+	u32 rx_pause_frames;
+	u32 rx_priority_pause_frames;
+	u32 rx_control_frames;
+	u32 rx_in_range_errors;
+	u32 rx_out_range_errors;
+	u32 rx_frame_too_long;
+	u32 rx_address_match_errors;
+	u32 rx_dropped_too_small;
+	u32 rx_dropped_too_short;
+	u32 rx_dropped_header_too_small;
+	u32 rx_dropped_tcp_length;
+	u32 rx_dropped_runt;
+	u32 rsvd1[10];
+	u32 rx_ip_checksum_errs;
+	u32 rx_tcp_checksum_errs;
+	u32 rx_udp_checksum_errs;
+	u32 rsvd2[7];
+	u32 rx_switched_unicast_packets;
+	u32 rx_switched_multicast_packets;
+	u32 rx_switched_broadcast_packets;
+	u32 rsvd3[3];
+	u32 tx_pauseframes;
+	u32 tx_priority_pauseframes;
+	u32 tx_controlframes;
+	u32 rsvd4[10];
+	u32 rxpp_fifo_overflow_drop;
+	u32 rx_input_fifo_overflow_drop;
+	u32 pmem_fifo_overflow_drop;
+	u32 jabber_events;
+	u32 rsvd5[3];
+};
+
+
+struct be_rxf_stats_v1 {
+	struct be_port_rxf_stats_v1 port[4];
+	u32 rsvd0[2];
+	u32 rx_drops_no_pbuf;
+	u32 rx_drops_no_txpb;
+	u32 rx_drops_no_erx_descr;
+	u32 rx_drops_no_tpre_descr;
+	u32 rsvd1[6];
+	u32 rx_drops_too_many_frags;
+	u32 rx_drops_invalid_ring;
+	u32 forwarded_packets;
+	u32 rx_drops_mtu;
+	u32 rsvd2[14];
+};
+
+struct be_erx_stats_v1 {
+	u32 rx_drops_no_fragments[68];     /* dwordS 0 to 67*/
+	u32 rsvd[4];
+};
+
+struct be_hw_stats_v1 {
+	struct be_rxf_stats_v1 rxf;
+	u32 rsvd0[BE_TXP_SW_SZ];
+	struct be_erx_stats_v1 erx;
+	struct be_pmem_stats pmem;
+	u32 rsvd1[3];
+};
+
+struct be_cmd_req_get_stats_v1 {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd[sizeof(struct be_hw_stats_v1)];
+};
+
+struct be_cmd_resp_get_stats_v1 {
+	struct be_cmd_resp_hdr hdr;
+	struct be_hw_stats_v1 hw_stats;
+};
+
+static inline void *
+hw_stats_from_cmd(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3) {
+		struct be_cmd_resp_get_stats_v1 *cmd = adapter->stats_cmd.va;
+
+		return &cmd->hw_stats;
+	} else {
+		struct be_cmd_resp_get_stats_v0 *cmd = adapter->stats_cmd.va;
+
+		return &cmd->hw_stats;
+	}
+}
+
+static inline void *be_port_rxf_stats_from_cmd(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3) {
+		struct be_hw_stats_v1 *hw_stats = hw_stats_from_cmd(adapter);
+		struct be_rxf_stats_v1 *rxf_stats = &hw_stats->rxf;
+
+		return &rxf_stats->port[adapter->port_num];
+	} else {
+		struct be_hw_stats_v0 *hw_stats = hw_stats_from_cmd(adapter);
+		struct be_rxf_stats_v0 *rxf_stats = &hw_stats->rxf;
+
+		return &rxf_stats->port[adapter->port_num];
+	}
+}
+
+static inline void *be_rxf_stats_from_cmd(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3) {
+		struct be_hw_stats_v1 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->rxf;
+	} else {
+		struct be_hw_stats_v0 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->rxf;
+	}
+}
+
+static inline void *be_erx_stats_from_cmd(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3) {
+		struct be_hw_stats_v1 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->erx;
+	} else {
+		struct be_hw_stats_v0 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->erx;
+	}
+}
+
+static inline void *be_pmem_stats_from_cmd(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3) {
+		struct be_hw_stats_v1 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->pmem;
+	} else {
+		struct be_hw_stats_v0 *hw_stats = hw_stats_from_cmd(adapter);
+
+		return &hw_stats->pmem;
+	}
+}
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 8e770e8..facfe3c 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -26,8 +26,8 @@ struct be_ethtool_stat {
 	int offset;
 };
 
-enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
-			PMEMSTAT, DRVSTAT};
+enum {NETSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
+			DRVSTAT};
 #define FIELDINFO(_struct, field) FIELD_SIZEOF(_struct, field), \
 					offsetof(_struct, field)
 #define NETSTAT_INFO(field) 	#field, NETSTAT,\
@@ -37,15 +37,8 @@ enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
 					FIELDINFO(struct be_tx_stats, field)
 #define DRVSTAT_RX_INFO(field)	#field, DRVSTAT_RX,\
 					FIELDINFO(struct be_rx_stats, field)
-#define MISCSTAT_INFO(field) 	#field, MISCSTAT,\
-					FIELDINFO(struct be_rxf_stats, field)
-#define PORTSTAT_INFO(field) 	#field, PORTSTAT,\
-					FIELDINFO(struct be_port_rxf_stats, \
-						field)
-#define ERXSTAT_INFO(field) 	#field, ERXSTAT,\
-					FIELDINFO(struct be_erx_stats, field)
-#define PMEMSTAT_INFO(field) 	#field, PMEMSTAT,\
-					FIELDINFO(struct be_pmem_stats, field)
+#define ERXSTAT_INFO(field)	#field, ERXSTAT,\
+					FIELDINFO(struct be_erx_stats_v1, field)
 #define	DRVSTAT_INFO(field)	#field, DRVSTAT,\
 					FIELDINFO(struct be_drv_stats, \
 						field)
@@ -65,50 +58,41 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_TX_INFO(be_tx_stops)},
 	{DRVSTAT_TX_INFO(be_tx_events)},
 	{DRVSTAT_TX_INFO(be_tx_compl)},
-	{PORTSTAT_INFO(rx_unicast_frames)},
-	{PORTSTAT_INFO(rx_multicast_frames)},
-	{PORTSTAT_INFO(rx_broadcast_frames)},
-	{PORTSTAT_INFO(rx_crc_errors)},
-	{PORTSTAT_INFO(rx_alignment_symbol_errors)},
-	{PORTSTAT_INFO(rx_pause_frames)},
-	{PORTSTAT_INFO(rx_control_frames)},
-	{PORTSTAT_INFO(rx_in_range_errors)},
-	{PORTSTAT_INFO(rx_out_range_errors)},
-	{PORTSTAT_INFO(rx_frame_too_long)},
-	{PORTSTAT_INFO(rx_address_match_errors)},
-	{PORTSTAT_INFO(rx_vlan_mismatch)},
-	{PORTSTAT_INFO(rx_dropped_too_small)},
-	{PORTSTAT_INFO(rx_dropped_too_short)},
-	{PORTSTAT_INFO(rx_dropped_header_too_small)},
-	{PORTSTAT_INFO(rx_dropped_tcp_length)},
-	{PORTSTAT_INFO(rx_dropped_runt)},
-	{PORTSTAT_INFO(rx_fifo_overflow)},
-	{PORTSTAT_INFO(rx_input_fifo_overflow)},
-	{PORTSTAT_INFO(rx_ip_checksum_errs)},
-	{PORTSTAT_INFO(rx_tcp_checksum_errs)},
-	{PORTSTAT_INFO(rx_udp_checksum_errs)},
-	{PORTSTAT_INFO(rx_non_rss_packets)},
-	{PORTSTAT_INFO(rx_ipv4_packets)},
-	{PORTSTAT_INFO(rx_ipv6_packets)},
-	{PORTSTAT_INFO(rx_switched_unicast_packets)},
-	{PORTSTAT_INFO(rx_switched_multicast_packets)},
-	{PORTSTAT_INFO(rx_switched_broadcast_packets)},
-	{PORTSTAT_INFO(tx_unicastframes)},
-	{PORTSTAT_INFO(tx_multicastframes)},
-	{PORTSTAT_INFO(tx_broadcastframes)},
-	{PORTSTAT_INFO(tx_pauseframes)},
-	{PORTSTAT_INFO(tx_controlframes)},
-	{MISCSTAT_INFO(rx_drops_no_pbuf)},
-	{MISCSTAT_INFO(rx_drops_no_txpb)},
-	{MISCSTAT_INFO(rx_drops_no_erx_descr)},
-	{MISCSTAT_INFO(rx_drops_no_tpre_descr)},
-	{MISCSTAT_INFO(rx_drops_too_many_frags)},
-	{MISCSTAT_INFO(rx_drops_invalid_ring)},
-	{MISCSTAT_INFO(forwarded_packets)},
-	{MISCSTAT_INFO(rx_drops_mtu)},
-	{MISCSTAT_INFO(port0_jabber_events)},
-	{MISCSTAT_INFO(port1_jabber_events)},
-	{PMEMSTAT_INFO(eth_red_drops)},
+	{DRVSTAT_INFO(rx_crc_errors)},
+	{DRVSTAT_INFO(rx_alignment_symbol_errors)},
+	{DRVSTAT_INFO(rx_pause_frames)},
+	{DRVSTAT_INFO(rx_control_frames)},
+	{DRVSTAT_INFO(rx_in_range_errors)},
+	{DRVSTAT_INFO(rx_out_range_errors)},
+	{DRVSTAT_INFO(rx_frame_too_long)},
+	{DRVSTAT_INFO(rx_address_match_errors)},
+	{DRVSTAT_INFO(rx_dropped_too_small)},
+	{DRVSTAT_INFO(rx_dropped_too_short)},
+	{DRVSTAT_INFO(rx_dropped_header_too_small)},
+	{DRVSTAT_INFO(rx_dropped_tcp_length)},
+	{DRVSTAT_INFO(rx_dropped_runt)},
+	{DRVSTAT_INFO(rxpp_fifo_overflow_drop)},
+	{DRVSTAT_INFO(rx_input_fifo_overflow_drop)},
+	{DRVSTAT_INFO(rx_ip_checksum_errs)},
+	{DRVSTAT_INFO(rx_tcp_checksum_errs)},
+	{DRVSTAT_INFO(rx_udp_checksum_errs)},
+	{DRVSTAT_INFO(rx_switched_unicast_packets)},
+	{DRVSTAT_INFO(rx_switched_multicast_packets)},
+	{DRVSTAT_INFO(rx_switched_broadcast_packets)},
+	{DRVSTAT_INFO(tx_pauseframes)},
+	{DRVSTAT_INFO(tx_controlframes)},
+	{DRVSTAT_INFO(rx_priority_pause_frames)},
+	{DRVSTAT_INFO(pmem_fifo_overflow_drop)},
+	{DRVSTAT_INFO(jabber_events)},
+	{DRVSTAT_INFO(rx_drops_no_pbuf)},
+	{DRVSTAT_INFO(rx_drops_no_txpb)},
+	{DRVSTAT_INFO(rx_drops_no_erx_descr)},
+	{DRVSTAT_INFO(rx_drops_no_tpre_descr)},
+	{DRVSTAT_INFO(rx_drops_too_many_frags)},
+	{DRVSTAT_INFO(rx_drops_invalid_ring)},
+	{DRVSTAT_INFO(forwarded_packets)},
+	{DRVSTAT_INFO(rx_drops_mtu)},
+	{DRVSTAT_INFO(eth_red_drops)},
 	{DRVSTAT_INFO(be_on_die_temperature)}
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
@@ -268,8 +252,6 @@ be_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats_cmd.va);
-	struct be_erx_stats *erx_stats = &hw_stats->erx;
 	struct be_rx_obj *rxo;
 	void *p = NULL;
 	int i, j;
@@ -282,15 +264,6 @@ be_get_ethtool_stats(struct net_device *netdev,
 		case DRVSTAT_TX:
 			p = &adapter->tx_stats;
 			break;
-		case PORTSTAT:
-			p = &hw_stats->rxf.port[adapter->port_num];
-			break;
-		case MISCSTAT:
-			p = &hw_stats->rxf;
-			break;
-		case PMEMSTAT:
-			p = &hw_stats->pmem;
-			break;
 		case DRVSTAT:
 			p = &adapter->drv_stats;
 			break;
@@ -308,7 +281,8 @@ be_get_ethtool_stats(struct net_device *netdev,
 				p = (u8 *)&rxo->stats + et_rx_stats[i].offset;
 				break;
 			case ERXSTAT:
-				p = (u32 *)erx_stats + rxo->q.id;
+				p = (u32 *)be_erx_stats_from_cmd(adapter) +
+								rxo->q.id;
 				break;
 			}
 			data[ETHTOOL_STATS_NUM + j * ETHTOOL_RXSTATS_NUM + i] =
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 243172b..cff2cca 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -245,14 +245,126 @@ netdev_addr:
 	return status;
 }
 
+static void populate_be2_stats(struct be_adapter *adapter)
+{
+
+	struct be_drv_stats *drvs = &adapter->drv_stats;
+	struct be_pmem_stats *pmem_sts = be_pmem_stats_from_cmd(adapter);
+	struct be_port_rxf_stats_v0 *port_stats =
+		be_port_rxf_stats_from_cmd(adapter);
+	struct be_rxf_stats_v0 *rxf_stats =
+		be_rxf_stats_from_cmd(adapter);
+
+	drvs->rx_pause_frames = port_stats->rx_pause_frames;
+	drvs->rx_crc_errors = port_stats->rx_crc_errors;
+	drvs->rx_control_frames = port_stats->rx_control_frames;
+	drvs->rx_in_range_errors = port_stats->rx_in_range_errors;
+	drvs->rx_frame_too_long = port_stats->rx_frame_too_long;
+	drvs->rx_dropped_runt = port_stats->rx_dropped_runt;
+	drvs->rx_ip_checksum_errs = port_stats->rx_ip_checksum_errs;
+	drvs->rx_tcp_checksum_errs = port_stats->rx_tcp_checksum_errs;
+	drvs->rx_udp_checksum_errs = port_stats->rx_udp_checksum_errs;
+	drvs->rxpp_fifo_overflow_drop = port_stats->rx_fifo_overflow;
+	drvs->rx_dropped_tcp_length = port_stats->rx_dropped_tcp_length;
+	drvs->rx_dropped_too_small = port_stats->rx_dropped_too_small;
+	drvs->rx_dropped_too_short = port_stats->rx_dropped_too_short;
+	drvs->rx_out_range_errors = port_stats->rx_out_range_errors;
+	drvs->rx_input_fifo_overflow_drop =
+		port_stats->rx_input_fifo_overflow;
+	drvs->rx_dropped_header_too_small =
+		port_stats->rx_dropped_header_too_small;
+	drvs->rx_address_match_errors =
+		port_stats->rx_address_match_errors;
+	drvs->rx_alignment_symbol_errors =
+		port_stats->rx_alignment_symbol_errors;
+
+	drvs->tx_pauseframes = port_stats->tx_pauseframes;
+	drvs->tx_controlframes = port_stats->tx_controlframes;
+
+	if (adapter->port_num)
+		drvs->jabber_events =
+			rxf_stats->port1_jabber_events;
+	else
+		drvs->jabber_events =
+			rxf_stats->port0_jabber_events;
+	drvs->rx_drops_no_pbuf = rxf_stats->rx_drops_no_pbuf;
+	drvs->rx_drops_no_txpb = rxf_stats->rx_drops_no_txpb;
+	drvs->rx_drops_no_erx_descr = rxf_stats->rx_drops_no_erx_descr;
+	drvs->rx_drops_invalid_ring = rxf_stats->rx_drops_invalid_ring;
+	drvs->forwarded_packets = rxf_stats->forwarded_packets;
+	drvs->rx_drops_mtu = rxf_stats->rx_drops_mtu;
+	drvs->rx_drops_no_tpre_descr =
+		rxf_stats->rx_drops_no_tpre_descr;
+	drvs->rx_drops_too_many_frags =
+		rxf_stats->rx_drops_too_many_frags;
+	adapter->drv_stats.eth_red_drops = pmem_sts->eth_red_drops;
+}
+
+static void populate_be3_stats(struct be_adapter *adapter)
+{
+	struct be_drv_stats *drvs = &adapter->drv_stats;
+	struct be_pmem_stats *pmem_sts = be_pmem_stats_from_cmd(adapter);
+
+	struct be_rxf_stats_v1 *rxf_stats =
+		be_rxf_stats_from_cmd(adapter);
+	struct be_port_rxf_stats_v1 *port_stats =
+		be_port_rxf_stats_from_cmd(adapter);
+
+	drvs->rx_priority_pause_frames = 0;
+	drvs->pmem_fifo_overflow_drop = 0;
+	drvs->rx_pause_frames = port_stats->rx_pause_frames;
+	drvs->rx_crc_errors = port_stats->rx_crc_errors;
+	drvs->rx_control_frames = port_stats->rx_control_frames;
+	drvs->rx_in_range_errors = port_stats->rx_in_range_errors;
+	drvs->rx_frame_too_long = port_stats->rx_frame_too_long;
+	drvs->rx_dropped_runt = port_stats->rx_dropped_runt;
+	drvs->rx_ip_checksum_errs = port_stats->rx_ip_checksum_errs;
+	drvs->rx_tcp_checksum_errs = port_stats->rx_tcp_checksum_errs;
+	drvs->rx_udp_checksum_errs = port_stats->rx_udp_checksum_errs;
+	drvs->rx_dropped_tcp_length = port_stats->rx_dropped_tcp_length;
+	drvs->rx_dropped_too_small = port_stats->rx_dropped_too_small;
+	drvs->rx_dropped_too_short = port_stats->rx_dropped_too_short;
+	drvs->rx_out_range_errors = port_stats->rx_out_range_errors;
+	drvs->rx_dropped_header_too_small =
+		port_stats->rx_dropped_header_too_small;
+	drvs->rx_input_fifo_overflow_drop =
+		port_stats->rx_input_fifo_overflow_drop;
+	drvs->rx_address_match_errors =
+		port_stats->rx_address_match_errors;
+	drvs->rx_alignment_symbol_errors =
+		port_stats->rx_alignment_symbol_errors;
+	drvs->rxpp_fifo_overflow_drop =
+		port_stats->rxpp_fifo_overflow_drop;
+	drvs->tx_pauseframes = port_stats->tx_pauseframes;
+	drvs->tx_controlframes = port_stats->tx_controlframes;
+	drvs->jabber_events = port_stats->jabber_events;
+	drvs->rx_drops_no_pbuf = rxf_stats->rx_drops_no_pbuf;
+	drvs->rx_drops_no_txpb = rxf_stats->rx_drops_no_txpb;
+	drvs->rx_drops_no_erx_descr = rxf_stats->rx_drops_no_erx_descr;
+	drvs->rx_drops_invalid_ring = rxf_stats->rx_drops_invalid_ring;
+	drvs->forwarded_packets = rxf_stats->forwarded_packets;
+	drvs->rx_drops_mtu = rxf_stats->rx_drops_mtu;
+	drvs->rx_drops_no_tpre_descr =
+		rxf_stats->rx_drops_no_tpre_descr;
+	drvs->rx_drops_too_many_frags =
+		rxf_stats->rx_drops_too_many_frags;
+	adapter->drv_stats.eth_red_drops = pmem_sts->eth_red_drops;
+}
+
+
+
+void be_parse_stats(struct be_adapter *adapter)
+{
+	if (adapter->generation == BE_GEN3)
+		populate_be3_stats(adapter);
+	else
+		populate_be2_stats(adapter);
+}
+
 void netdev_stats_update(struct be_adapter *adapter)
 {
-	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats_cmd.va);
-	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
-	struct be_port_rxf_stats *port_stats =
-			&rxf_stats->port[adapter->port_num];
+	struct be_drv_stats *drvs = &adapter->drv_stats;
 	struct net_device_stats *dev_stats = &adapter->netdev->stats;
-	struct be_erx_stats *erx_stats = &hw_stats->erx;
 	struct be_rx_obj *rxo;
 	int i;
 
@@ -262,43 +374,52 @@ void netdev_stats_update(struct be_adapter *adapter)
 		dev_stats->rx_bytes += rx_stats(rxo)->rx_bytes;
 		dev_stats->multicast += rx_stats(rxo)->rx_mcast_pkts;
 		/*  no space in linux buffers: best possible approximation */
-		dev_stats->rx_dropped +=
-			erx_stats->rx_drops_no_fragments[rxo->q.id];
+		if (adapter->generation == BE_GEN3) {
+			struct be_erx_stats_v1 *erx_stats =
+					be_erx_stats_from_cmd(adapter);
+			dev_stats->rx_dropped +=
+				erx_stats->rx_drops_no_fragments[rxo->q.id];
+		} else {
+			struct be_erx_stats_v0 *erx_stats =
+					be_erx_stats_from_cmd(adapter);
+			dev_stats->rx_dropped +=
+				erx_stats->rx_drops_no_fragments[rxo->q.id];
+		}
 	}
 
 	dev_stats->tx_packets = tx_stats(adapter)->be_tx_pkts;
 	dev_stats->tx_bytes = tx_stats(adapter)->be_tx_bytes;
 
 	/* bad pkts received */
-	dev_stats->rx_errors = port_stats->rx_crc_errors +
-		port_stats->rx_alignment_symbol_errors +
-		port_stats->rx_in_range_errors +
-		port_stats->rx_out_range_errors +
-		port_stats->rx_frame_too_long +
-		port_stats->rx_dropped_too_small +
-		port_stats->rx_dropped_too_short +
-		port_stats->rx_dropped_header_too_small +
-		port_stats->rx_dropped_tcp_length +
-		port_stats->rx_dropped_runt +
-		port_stats->rx_tcp_checksum_errs +
-		port_stats->rx_ip_checksum_errs +
-		port_stats->rx_udp_checksum_errs;
+	dev_stats->rx_errors = drvs->rx_crc_errors +
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
 
 	/* detailed rx errors */
-	dev_stats->rx_length_errors = port_stats->rx_in_range_errors +
-		port_stats->rx_out_range_errors +
-		port_stats->rx_frame_too_long;
+	dev_stats->rx_length_errors = drvs->rx_in_range_errors +
+		drvs->rx_out_range_errors +
+		drvs->rx_frame_too_long;
 
-	dev_stats->rx_crc_errors = port_stats->rx_crc_errors;
+	dev_stats->rx_crc_errors = drvs->rx_crc_errors;
 
 	/* frame alignment errors */
-	dev_stats->rx_frame_errors = port_stats->rx_alignment_symbol_errors;
+	dev_stats->rx_frame_errors = drvs->rx_alignment_symbol_errors;
 
 	/* receiver fifo overrun */
 	/* drops_no_pbuf is no per i/f, it's per BE card */
-	dev_stats->rx_fifo_errors = port_stats->rx_fifo_overflow +
-					port_stats->rx_input_fifo_overflow +
-					rxf_stats->rx_drops_no_pbuf;
+	dev_stats->rx_fifo_errors = drvs->rxpp_fifo_overflow_drop +
+				drvs->rx_input_fifo_overflow_drop +
+				drvs->rx_drops_no_pbuf;
 }
 
 void be_link_status_update(struct be_adapter *adapter, bool link_up)
@@ -2823,7 +2944,10 @@ static int be_stats_init(struct be_adapter *adapter)
 {
 	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
-	cmd->size = sizeof(struct be_cmd_req_get_stats);
+	if (adapter->generation == BE_GEN2)
+		cmd->size = sizeof(struct be_cmd_req_get_stats_v0);
+	else
+		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
 	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
 				     GFP_KERNEL);
 	if (cmd->va == NULL)
-- 
1.6.0.2

