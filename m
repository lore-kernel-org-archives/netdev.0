From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] bnx2x: Utilize FW 7.12.30
Date: Wed, 22 Jul 2015 09:16:22 +0300
Message-ID: <1437545787-22097-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:50527 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753838AbbGVGRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:00 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves bnx2x into using 7.12.30 FW. Said firmware fixes the following:

 - Packets from a VF with pvid configured which were sent with a
   different vlan were transmitted instead of being discarded.

 - FCoE traffic might not recover after a failue while there's traffic
   to another function.

In addition, this FW opens the door for the driver to implement several
new features; Specifically, this enhances the device's support for
encapsulated packets and will allow vxlan/geneve offloads to be added in
the future, as well as vlan filtering offload.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    | 11 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |  2 +
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    | 87 +++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     | 53 +++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     | 45 +++++++----
 8 files changed, 136 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a90d736..fc32821 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2103,9 +2103,14 @@ int bnx2x_rss(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 		if (rss_obj->udp_rss_v6)
 			__set_bit(BNX2X_RSS_IPV6_UDP, &params.rss_flags);
 
-		if (!CHIP_IS_E1x(bp))
+		if (!CHIP_IS_E1x(bp)) {
+			/* valid only for TUNN_MODE_VXLAN tunnel mode */
+			__set_bit(BNX2X_RSS_IPV4_VXLAN, &params.rss_flags);
+			__set_bit(BNX2X_RSS_IPV6_VXLAN, &params.rss_flags);
+
 			/* valid only for TUNN_MODE_GRE tunnel mode */
-			__set_bit(BNX2X_RSS_GRE_INNER_HDRS, &params.rss_flags);
+			__set_bit(BNX2X_RSS_TUNN_INNER_HDRS, &params.rss_flags);
+		}
 	} else {
 		__set_bit(BNX2X_RSS_MODE_DISABLED, &params.rss_flags);
 	}
@@ -3677,7 +3682,7 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 		pbd2->fw_ip_hdr_to_payload_w =
 			hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
 		pbd_e2->data.tunnel_data.flags |=
-			ETH_TUNNEL_DATA_IP_HDR_TYPE_OUTER;
+			ETH_TUNNEL_DATA_IPV6_OUTER;
 	}
 
 	pbd2->tcp_send_seq = bswab32(inner_tcp_hdr(skb)->seq);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 03b7404..ec50d12 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -936,9 +936,7 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
 
-	start_params->tunnel_mode	= TUNN_MODE_GRE;
-	start_params->gre_tunnel_type	= IPGRE_TUNNEL;
-	start_params->inner_gre_rss_en	= 1;
+	start_params->inner_rss = 1;
 
 	if (IS_MF_UFP(bp) && BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)) {
 		start_params->class_fail_ethtype = ETH_P_FIP;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 6e4294e..b50f154 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1850,6 +1850,8 @@ static void bnx2x_dcbx_fw_struct(struct bnx2x *bp,
 			if (bp->dcbx_port_params.ets.cos_params[cos].
 						pri_bitmask & pri_bit)
 					tt2cos[pri].cos = cos;
+
+		pfc_fw_cfg->dcb_outer_pri[pri]  = ttp[pri];
 	}
 
 	/* we never want the FW to add a 0 vlan tag */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 7636e3c..bfda526 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -372,7 +372,7 @@
 #define MAX_COS_NUMBER 4
 #define MAX_TRAFFIC_TYPES 8
 #define MAX_PFC_PRIORITIES 8
-
+#define MAX_VLAN_PRIORITIES 8
 	/* used by array traffic_type_to_priority[] to mark traffic type \
 	that is not mapped to priority*/
 #define LLFC_TRAFFIC_TYPE_TO_PRIORITY_UNMAPPED 0xFF
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 058bc73..2b6f97b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2898,8 +2898,8 @@ struct afex_stats {
 };
 
 #define BCM_5710_FW_MAJOR_VERSION			7
-#define BCM_5710_FW_MINOR_VERSION			10
-#define BCM_5710_FW_REVISION_VERSION		51
+#define BCM_5710_FW_MINOR_VERSION			12
+#define BCM_5710_FW_REVISION_VERSION		30
 #define BCM_5710_FW_ENGINEERING_VERSION		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
@@ -3901,7 +3901,11 @@ struct eth_fast_path_rx_cqe {
 	__le16 len_on_bd;
 	struct parsing_flags pars_flags;
 	union eth_sgl_or_raw_data sgl_or_raw_data;
-	__le32 reserved1[7];
+	u8 tunn_type;
+	u8 tunn_inner_hdrs_offset;
+	__le16 reserved1;
+	__le32 tunn_tenant_id;
+	__le32 padding[5];
 	u32 marker;
 };
 
@@ -4012,8 +4016,8 @@ struct eth_tunnel_data {
 	__le16 pseudo_csum;
 	u8 ip_hdr_start_inner_w;
 	u8 flags;
-#define ETH_TUNNEL_DATA_IP_HDR_TYPE_OUTER (0x1<<0)
-#define ETH_TUNNEL_DATA_IP_HDR_TYPE_OUTER_SHIFT 0
+#define ETH_TUNNEL_DATA_IPV6_OUTER (0x1<<0)
+#define ETH_TUNNEL_DATA_IPV6_OUTER_SHIFT 0
 #define ETH_TUNNEL_DATA_RESERVED (0x7F<<1)
 #define ETH_TUNNEL_DATA_RESERVED_SHIFT 1
 };
@@ -4120,16 +4124,12 @@ struct eth_rss_update_ramrod_data {
 #define ETH_RSS_UPDATE_RAMROD_DATA_IPV6_UDP_CAPABILITY_SHIFT 6
 #define ETH_RSS_UPDATE_RAMROD_DATA_IPV6_VXLAN_CAPABILITY (0x1<<7)
 #define ETH_RSS_UPDATE_RAMROD_DATA_IPV6_VXLAN_CAPABILITY_SHIFT 7
-#define ETH_RSS_UPDATE_RAMROD_DATA_EN_5_TUPLE_CAPABILITY (0x1<<8)
-#define ETH_RSS_UPDATE_RAMROD_DATA_EN_5_TUPLE_CAPABILITY_SHIFT 8
-#define ETH_RSS_UPDATE_RAMROD_DATA_NVGRE_KEY_ENTROPY_CAPABILITY (0x1<<9)
-#define ETH_RSS_UPDATE_RAMROD_DATA_NVGRE_KEY_ENTROPY_CAPABILITY_SHIFT 9
-#define ETH_RSS_UPDATE_RAMROD_DATA_GRE_INNER_HDRS_CAPABILITY (0x1<<10)
-#define ETH_RSS_UPDATE_RAMROD_DATA_GRE_INNER_HDRS_CAPABILITY_SHIFT 10
-#define ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY (0x1<<11)
-#define ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY_SHIFT 11
-#define ETH_RSS_UPDATE_RAMROD_DATA_RESERVED (0xF<<12)
-#define ETH_RSS_UPDATE_RAMROD_DATA_RESERVED_SHIFT 12
+#define ETH_RSS_UPDATE_RAMROD_DATA_TUNN_INNER_HDRS_CAPABILITY (0x1<<8)
+#define ETH_RSS_UPDATE_RAMROD_DATA_TUNN_INNER_HDRS_CAPABILITY_SHIFT 8
+#define ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY (0x1<<9)
+#define ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY_SHIFT 9
+#define ETH_RSS_UPDATE_RAMROD_DATA_RESERVED (0x3F<<10)
+#define ETH_RSS_UPDATE_RAMROD_DATA_RESERVED_SHIFT 10
 	u8 rss_result_mask;
 	u8 reserved3;
 	__le16 reserved4;
@@ -4314,6 +4314,18 @@ enum eth_tunnel_non_lso_csum_location {
 	MAX_ETH_TUNNEL_NON_LSO_CSUM_LOCATION
 };
 
+enum eth_tunn_type {
+	TUNN_TYPE_NONE,
+	TUNN_TYPE_VXLAN,
+	TUNN_TYPE_L2_GRE,
+	TUNN_TYPE_IPV4_GRE,
+	TUNN_TYPE_IPV6_GRE,
+	TUNN_TYPE_L2_GENEVE,
+	TUNN_TYPE_IPV4_GENEVE,
+	TUNN_TYPE_IPV6_GENEVE,
+	MAX_ETH_TUNN_TYPE
+};
+
 /*
  * Tx regular BD structure
  */
@@ -4758,6 +4770,9 @@ struct afex_vif_list_ramrod_data {
 	__le16 reserved1;
 };
 
+struct c2s_pri_trans_table_entry {
+	u8 val[MAX_VLAN_PRIORITIES];
+};
 
 /*
  * cfc delete event data
@@ -5246,6 +5261,7 @@ struct flow_control_configuration {
 	u8 dont_add_pri_0_en;
 	u8 reserved1;
 	__le32 reserved2;
+	u8 dcb_outer_pri[MAX_TRAFFIC_TYPES];
 };
 
 
@@ -5260,18 +5276,25 @@ struct function_start_data {
 	u8 path_id;
 	u8 network_cos_mode;
 	u8 dmae_cmd_id;
-	u8 tunnel_mode;
-	u8 gre_tunnel_type;
-	u8 tunn_clss_en;
-	u8 inner_gre_rss_en;
-	u8 sd_accept_mf_clss_fail;
+	u8 no_added_tags;
+	__le16 reserved0;
+	__le32 reserved1;
+	u8 inner_clss_vxlan;
+	u8 inner_clss_l2gre;
+	u8 inner_clss_l2geneve;
+	u8 inner_rss;
 	__le16 vxlan_dst_port;
+	__le16 geneve_dst_port;
+	u8 sd_accept_mf_clss_fail;
+	u8 sd_accept_mf_clss_fail_match_ethtype;
 	__le16 sd_accept_mf_clss_fail_ethtype;
 	__le16 sd_vlan_eth_type;
 	u8 sd_vlan_force_pri_flg;
 	u8 sd_vlan_force_pri_val;
-	u8 sd_accept_mf_clss_fail_match_ethtype;
-	u8 no_added_tags;
+	u8 c2s_pri_tt_valid;
+	u8 c2s_pri_default;
+	u8 reserved2[6];
+	struct c2s_pri_trans_table_entry c2s_pri_trans_table;
 };
 
 struct function_update_data {
@@ -5289,11 +5312,12 @@ struct function_update_data {
 	u8 tx_switch_suspend;
 	u8 echo;
 	u8 update_tunn_cfg_flg;
-	u8 tunnel_mode;
-	u8 gre_tunnel_type;
-	u8 tunn_clss_en;
-	u8 inner_gre_rss_en;
+	u8 inner_clss_vxlan;
+	u8 inner_clss_l2gre;
+	u8 inner_clss_l2geneve;
+	u8 inner_rss;
 	__le16 vxlan_dst_port;
+	__le16 geneve_dst_port;
 	u8 sd_vlan_force_pri_change_flg;
 	u8 sd_vlan_force_pri_flg;
 	u8 sd_vlan_force_pri_val;
@@ -5302,6 +5326,8 @@ struct function_update_data {
 	u8 reserved1;
 	__le16 sd_vlan_tag;
 	__le16 sd_vlan_eth_type;
+	__le16 reserved0;
+	__le32 reserved2;
 };
 
 /*
@@ -5330,15 +5356,6 @@ struct fw_version {
 #define __FW_VERSION_RESERVED_SHIFT 4
 };
 
-
-/* GRE Tunnel Mode */
-enum gre_tunnel_type {
-	NVGRE_TUNNEL,
-	L2GRE_TUNNEL,
-	IPGRE_TUNNEL,
-	MAX_GRE_TUNNEL_TYPE
-};
-
 /*
  * Dynamic Host-Coalescing - Driver(host) counters
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c27af12..845471b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5568,6 +5568,8 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_OPEN):
 		case (EVENT_RING_OPCODE_RSS_UPDATE_RULES |
 		      BNX2X_STATE_OPENING_WAIT4_PORT):
+		case (EVENT_RING_OPCODE_RSS_UPDATE_RULES |
+		      BNX2X_STATE_CLOSING_WAIT4_HALT):
 			cid = elem->message.data.eth_event.echo &
 				BNX2X_SWCID_MASK;
 			DP(BNX2X_MSG_SP, "got RSS_UPDATE ramrod. CID %d\n",
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 4ad415a..c55f780 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4060,8 +4060,14 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 	if (test_bit(BNX2X_RSS_IPV6_UDP, &p->rss_flags))
 		caps |= ETH_RSS_UPDATE_RAMROD_DATA_IPV6_UDP_CAPABILITY;
 
-	if (test_bit(BNX2X_RSS_GRE_INNER_HDRS, &p->rss_flags))
-		caps |= ETH_RSS_UPDATE_RAMROD_DATA_GRE_INNER_HDRS_CAPABILITY;
+	if (test_bit(BNX2X_RSS_IPV4_VXLAN, &p->rss_flags))
+		caps |= ETH_RSS_UPDATE_RAMROD_DATA_IPV4_VXLAN_CAPABILITY;
+
+	if (test_bit(BNX2X_RSS_IPV6_VXLAN, &p->rss_flags))
+		caps |= ETH_RSS_UPDATE_RAMROD_DATA_IPV6_VXLAN_CAPABILITY;
+
+	if (test_bit(BNX2X_RSS_TUNN_INNER_HDRS, &p->rss_flags))
+		caps |= ETH_RSS_UPDATE_RAMROD_DATA_TUNN_INNER_HDRS_CAPABILITY;
 
 	/* RSS keys */
 	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
@@ -5669,10 +5675,14 @@ static inline int bnx2x_func_send_start(struct bnx2x *bp,
 	rdata->sd_vlan_tag	= cpu_to_le16(start_params->sd_vlan_tag);
 	rdata->path_id		= BP_PATH(bp);
 	rdata->network_cos_mode	= start_params->network_cos_mode;
-	rdata->tunnel_mode	= start_params->tunnel_mode;
-	rdata->gre_tunnel_type	= start_params->gre_tunnel_type;
-	rdata->inner_gre_rss_en = start_params->inner_gre_rss_en;
-	rdata->vxlan_dst_port	= cpu_to_le16(4789);
+
+	rdata->vxlan_dst_port	= cpu_to_le16(start_params->vxlan_dst_port);
+	rdata->geneve_dst_port	= cpu_to_le16(start_params->geneve_dst_port);
+	rdata->inner_clss_l2gre	= start_params->inner_clss_l2gre;
+	rdata->inner_clss_l2geneve = start_params->inner_clss_l2geneve;
+	rdata->inner_clss_vxlan	= start_params->inner_clss_vxlan;
+	rdata->inner_rss	= start_params->inner_rss;
+
 	rdata->sd_accept_mf_clss_fail = start_params->class_fail;
 	if (start_params->class_fail_ethtype) {
 		rdata->sd_accept_mf_clss_fail_match_ethtype = 1;
@@ -5690,6 +5700,14 @@ static inline int bnx2x_func_send_start(struct bnx2x *bp,
 			cpu_to_le16(0x8100);
 
 	rdata->no_added_tags = start_params->no_added_tags;
+
+	rdata->c2s_pri_tt_valid = start_params->c2s_pri_valid;
+	if (rdata->c2s_pri_tt_valid) {
+		memcpy(rdata->c2s_pri_trans_table.val,
+		       start_params->c2s_pri,
+		       MAX_VLAN_PRIORITIES);
+		rdata->c2s_pri_default = start_params->c2s_pri_default;
+	}
 	/* No need for an explicit memory barrier here as long we would
 	 * need to ensure the ordering of writing to the SPQ element
 	 * and updating of the SPQ producer which involves a memory
@@ -5750,15 +5768,22 @@ static inline int bnx2x_func_send_switch_update(struct bnx2x *bp,
 	if (test_bit(BNX2X_F_UPDATE_TUNNEL_CFG_CHNG,
 		     &switch_update_params->changes)) {
 		rdata->update_tunn_cfg_flg = 1;
-		if (test_bit(BNX2X_F_UPDATE_TUNNEL_CLSS_EN,
+		if (test_bit(BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_L2GRE,
+			     &switch_update_params->changes))
+			rdata->inner_clss_l2gre = 1;
+		if (test_bit(BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_VXLAN,
+			     &switch_update_params->changes))
+			rdata->inner_clss_vxlan = 1;
+		if (test_bit(BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_L2GENEVE,
 			     &switch_update_params->changes))
-			rdata->tunn_clss_en = 1;
-		if (test_bit(BNX2X_F_UPDATE_TUNNEL_INNER_GRE_RSS_EN,
+			rdata->inner_clss_l2geneve = 1;
+		if (test_bit(BNX2X_F_UPDATE_TUNNEL_INNER_RSS,
 			     &switch_update_params->changes))
-			rdata->inner_gre_rss_en = 1;
-		rdata->tunnel_mode = switch_update_params->tunnel_mode;
-		rdata->gre_tunnel_type = switch_update_params->gre_tunnel_type;
-		rdata->vxlan_dst_port = cpu_to_le16(4789);
+			rdata->inner_rss = 1;
+		rdata->vxlan_dst_port =
+			cpu_to_le16(switch_update_params->vxlan_dst_port);
+		rdata->geneve_dst_port =
+			cpu_to_le16(switch_update_params->geneve_dst_port);
 	}
 
 	rdata->echo = SWITCH_UPDATE;
@@ -5885,6 +5910,8 @@ static inline int bnx2x_func_send_tx_start(struct bnx2x *bp,
 		rdata->traffic_type_to_priority_cos[i] =
 			tx_start_params->traffic_type_to_priority_cos[i];
 
+	for (i = 0; i < MAX_TRAFFIC_TYPES; i++)
+		rdata->dcb_outer_pri[i] = tx_start_params->dcb_outer_pri[i];
 	/* No need for an explicit memory barrier here as long as we
 	 * ensure the ordering of writing to the SPQ element
 	 * and updating of the SPQ producer which involves a memory
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 86baecb..df27bb8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -711,7 +711,10 @@ enum {
 	BNX2X_RSS_IPV6,
 	BNX2X_RSS_IPV6_TCP,
 	BNX2X_RSS_IPV6_UDP,
-	BNX2X_RSS_GRE_INNER_HDRS,
+
+	BNX2X_RSS_IPV4_VXLAN,
+	BNX2X_RSS_IPV6_VXLAN,
+	BNX2X_RSS_TUNN_INNER_HDRS,
 };
 
 struct bnx2x_config_rss_params {
@@ -1105,8 +1108,10 @@ enum {
 	BNX2X_F_UPDATE_VLAN_FORCE_PRIO_CHNG,
 	BNX2X_F_UPDATE_VLAN_FORCE_PRIO_FLAG,
 	BNX2X_F_UPDATE_TUNNEL_CFG_CHNG,
-	BNX2X_F_UPDATE_TUNNEL_CLSS_EN,
-	BNX2X_F_UPDATE_TUNNEL_INNER_GRE_RSS_EN,
+	BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_L2GRE,
+	BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_VXLAN,
+	BNX2X_F_UPDATE_TUNNEL_INNER_CLSS_L2GENEVE,
+	BNX2X_F_UPDATE_TUNNEL_INNER_RSS,
 };
 
 /* Allowed Function states */
@@ -1171,19 +1176,23 @@ struct bnx2x_func_start_params {
 	/* Function cos mode */
 	u8 network_cos_mode;
 
-	/* TUNN_MODE_NONE/TUNN_MODE_VXLAN/TUNN_MODE_GRE */
-	u8 tunnel_mode;
+	/* UDP dest port for VXLAN */
+	u16 vxlan_dst_port;
 
-	/* tunneling classification enablement */
-	u8 tunn_clss_en;
+	/* UDP dest port for Geneve */
+	u16 geneve_dst_port;
 
-	/* NVGRE_TUNNEL/L2GRE_TUNNEL/IPGRE_TUNNEL */
-	u8 gre_tunnel_type;
+	/* Enable inner Rx classifications for L2GRE packets */
+	u8 inner_clss_l2gre;
 
-	/* Enables Inner GRE RSS on the function, depends on the client RSS
-	 * capailities
-	 */
-	u8 inner_gre_rss_en;
+	/* Enable inner Rx classifications for L2-Geneve packets */
+	u8 inner_clss_l2geneve;
+
+	/* Enable inner Rx classification for vxlan packets */
+	u8 inner_clss_vxlan;
+
+	/* Enable RSS according to inner header */
+	u8 inner_rss;
 
 	/* Allows accepting of packets failing MF classification, possibly
 	 * only matching a given ethertype
@@ -1200,6 +1209,11 @@ struct bnx2x_func_start_params {
 
 	/* Prevent inner vlans from being added by FW */
 	u8 no_added_tags;
+
+	/* Inner-to-Outer vlan priority mapping */
+	u8 c2s_pri[MAX_VLAN_PRIORITIES];
+	u8 c2s_pri_default;
+	u8 c2s_pri_valid;
 };
 
 struct bnx2x_func_switch_update_params {
@@ -1207,8 +1221,8 @@ struct bnx2x_func_switch_update_params {
 	u16 vlan;
 	u16 vlan_eth_type;
 	u8 vlan_force_prio;
-	u8 tunnel_mode;
-	u8 gre_tunnel_type;
+	u16 vxlan_dst_port;
+	u16 geneve_dst_port;
 };
 
 struct bnx2x_func_afex_update_params {
@@ -1229,6 +1243,7 @@ struct bnx2x_func_tx_start_params {
 	u8 dcb_enabled;
 	u8 dcb_version;
 	u8 dont_add_pri_0_en;
+	u8 dcb_outer_pri[MAX_TRAFFIC_TYPES];
 };
 
 struct bnx2x_func_set_timesync_params {
-- 
1.9.3
