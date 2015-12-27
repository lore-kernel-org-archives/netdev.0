From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 11/12] bnxt_en: Update to Firmware interface spec 1.0.0.
Date: Sun, 27 Dec 2015 18:19:28 -0500
Message-ID: <1451258369-21543-12-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:4052 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbbL0XTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:33 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This interface will be forward compatible with future changes.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |  33 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |   8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h   | 865 +++++++++---------------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  15 +-
 4 files changed, 349 insertions(+), 572 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5737e0d..52dfaab 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2787,7 +2787,7 @@ static int bnxt_hwrm_cfa_l2_set_rx_mask(struct bnxt *bp, u16 vnic_id)
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_CFA_L2_SET_RX_MASK, -1, -1);
-	req.dflt_vnic_id = cpu_to_le32(vnic->fw_vnic_id);
+	req.vnic_id = cpu_to_le32(vnic->fw_vnic_id);
 
 	req.num_mc_entries = cpu_to_le32(vnic->mc_list_count);
 	req.mc_tbl_addr = cpu_to_le64(vnic->mc_list_mapping);
@@ -2820,7 +2820,7 @@ static int bnxt_hwrm_cfa_ntuple_filter_free(struct bnxt *bp,
 	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_SRC_PORT_MASK |	\
 	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_PORT |		\
 	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_PORT_MASK |	\
-	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_VNIC_ID)
+	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_ID)
 
 static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 					     struct bnxt_ntuple_filter *fltr)
@@ -2839,7 +2839,7 @@ static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 
 	req.ethertype = htons(ETH_P_IP);
 	memcpy(req.src_macaddr, fltr->src_mac_addr, ETH_ALEN);
-	req.ipaddr_type = 4;
+	req.ip_addr_type = CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV4;
 	req.ip_protocol = keys->basic.ip_proto;
 
 	req.src_ipaddr[0] = keys->addrs.v4addrs.src;
@@ -2852,7 +2852,7 @@ static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 	req.dst_port = keys->ports.dst;
 	req.dst_port_mask = cpu_to_be16(0xffff);
 
-	req.dst_vnic_id = cpu_to_le16(vnic->fw_vnic_id);
+	req.dst_id = cpu_to_le16(vnic->fw_vnic_id);
 	mutex_lock(&bp->hwrm_cmd_lock);
 	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 	if (!rc)
@@ -2872,10 +2872,10 @@ static int bnxt_hwrm_set_vnic_filter(struct bnxt *bp, u16 vnic_id, u16 idx,
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_CFA_L2_FILTER_ALLOC, -1, -1);
 	req.flags = cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX |
 				CFA_L2_FILTER_ALLOC_REQ_FLAGS_OUTERMOST);
-	req.dst_vnic_id = cpu_to_le16(bp->vnic_info[vnic_id].fw_vnic_id);
+	req.dst_id = cpu_to_le16(bp->vnic_info[vnic_id].fw_vnic_id);
 	req.enables =
 		cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_ENABLES_L2_ADDR |
-			    CFA_L2_FILTER_ALLOC_REQ_ENABLES_DST_VNIC_ID |
+			    CFA_L2_FILTER_ALLOC_REQ_ENABLES_DST_ID |
 			    CFA_L2_FILTER_ALLOC_REQ_ENABLES_L2_ADDR_MASK);
 	memcpy(req.l2_addr, mac_addr, ETH_ALEN);
 	req.l2_addr_mask[0] = 0xff;
@@ -2945,7 +2945,8 @@ static int bnxt_hwrm_vnic_set_tpa(struct bnxt *bp, u16 vnic_id, u32 tpa_flags)
 
 		req.enables =
 			cpu_to_le32(VNIC_TPA_CFG_REQ_ENABLES_MAX_AGG_SEGS |
-				    VNIC_TPA_CFG_REQ_ENABLES_MAX_AGGS);
+				    VNIC_TPA_CFG_REQ_ENABLES_MAX_AGGS |
+				    VNIC_TPA_CFG_REQ_ENABLES_MIN_AGG_LEN);
 
 		/* Number of segs are log2 units, and first packet is not
 		 * included as part of this units.
@@ -2963,6 +2964,8 @@ static int bnxt_hwrm_vnic_set_tpa(struct bnxt *bp, u16 vnic_id, u32 tpa_flags)
 		segs = ilog2(nsegs);
 		req.max_agg_segs = cpu_to_le16(segs);
 		req.max_aggs = cpu_to_le16(VNIC_TPA_CFG_REQ_MAX_AGGS_MAX);
+
+		req.min_agg_len = cpu_to_le32(512);
 	}
 	req.vnic_id = cpu_to_le16(vnic->fw_vnic_id);
 
@@ -3726,14 +3729,11 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 
 	memcpy(&bp->ver_resp, resp, sizeof(struct hwrm_ver_get_output));
 
-	if (req.hwrm_intf_maj != resp->hwrm_intf_maj ||
-	    req.hwrm_intf_min != resp->hwrm_intf_min ||
-	    req.hwrm_intf_upd != resp->hwrm_intf_upd) {
-		netdev_warn(bp->dev, "HWRM interface %d.%d.%d does not match driver interface %d.%d.%d.\n",
+	if (resp->hwrm_intf_maj < 1) {
+		netdev_warn(bp->dev, "HWRM interface %d.%d.%d is older than 1.0.0.\n",
 			    resp->hwrm_intf_maj, resp->hwrm_intf_min,
-			    resp->hwrm_intf_upd, req.hwrm_intf_maj,
-			    req.hwrm_intf_min, req.hwrm_intf_upd);
-		netdev_warn(bp->dev, "Please update driver or firmware with matching interface versions.\n");
+			    resp->hwrm_intf_upd);
+		netdev_warn(bp->dev, "Please update firmware with HWRM interface 1.0.0 or newer.\n");
 	}
 	snprintf(bp->fw_ver_str, BC_HWRM_STR_LEN, "bc %d.%d.%d rm %d.%d.%d",
 		 resp->hwrm_fw_maj, resp->hwrm_fw_min, resp->hwrm_fw_bld,
@@ -3936,8 +3936,7 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 	}
 	bp->vnic_info[0].uc_filter_count = 1;
 
-	bp->vnic_info[0].rx_mask = CFA_L2_SET_RX_MASK_REQ_MASK_UNICAST |
-				   CFA_L2_SET_RX_MASK_REQ_MASK_BCAST;
+	bp->vnic_info[0].rx_mask = CFA_L2_SET_RX_MASK_REQ_MASK_BCAST;
 
 	if ((bp->dev->flags & IFF_PROMISC) && BNXT_PF(bp))
 		bp->vnic_info[0].rx_mask |=
@@ -4343,7 +4342,7 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->auto_mode = resp->auto_mode;
 	link_info->auto_pause_setting = resp->auto_pause;
 	link_info->force_pause_setting = resp->force_pause;
-	link_info->duplex_setting = resp->duplex_setting;
+	link_info->duplex_setting = resp->duplex;
 	if (link_info->phy_link_status == BNXT_LINK_LINK)
 		link_info->link_speed = le16_to_cpu(resp->link_speed);
 	else
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 8241437..78d639d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -11,11 +11,11 @@
 #define BNXT_H
 
 #define DRV_MODULE_NAME		"bnxt_en"
-#define DRV_MODULE_VERSION	"0.1.24"
+#define DRV_MODULE_VERSION	"1.0.0"
 
-#define DRV_VER_MAJ	0
-#define DRV_VER_MIN	1
-#define DRV_VER_UPD	24
+#define DRV_VER_MAJ	1
+#define DRV_VER_MIN	0
+#define DRV_VER_UPD	0
 
 struct tx_bd {
 	__le32 tx_bd_len_flags_type;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 70fc825..4badbed 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -103,19 +103,22 @@ struct hwrm_async_event_cmpl {
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CHANGE  (0x2UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_DCB_CONFIG_CHANGE  (0x3UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED (0x4UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_UNLOAD   (0x10UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_LOAD     (0x11UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD     (0x20UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_LOAD       (0x20UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_LOAD       (0x21UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_FLR		   (0x30UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_MAC_ADDR_CHANGE (0x31UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_VF_COMM_STATUS_CHANGE (0x32UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_HWRM_ERROR	   (0xffUL << 0)
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_V			    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_OPAQUE_MASK		    0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_OPAQUE_SFT		    1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 };
 
@@ -132,9 +135,16 @@ struct hwrm_async_event_cmpl_link_status_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_OPAQUE_SFT 1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_UP 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_DOWN (0x0UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_UP (0x1UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_MASK 0xeUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_SFT 1
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffff0UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_ID_SFT 4
 };
 
 /* HWRM Asynchronous Event Completion Record for link MTU change (16 bytes) */
@@ -150,7 +160,8 @@ struct hwrm_async_event_cmpl_link_mtu_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_OPAQUE_MASK  0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_OPAQUE_SFT   1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_EVENT_DATA1_NEW_MTU_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_EVENT_DATA1_NEW_MTU_SFT 0
@@ -169,7 +180,8 @@ struct hwrm_async_event_cmpl_link_speed_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_OPAQUE_SFT 1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_FORCE 0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_MASK 0xfffeUL
@@ -200,7 +212,8 @@ struct hwrm_async_event_cmpl_dcb_config_change {
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_OPAQUE_SFT 1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_PORT_ID_SFT 0
@@ -219,7 +232,8 @@ struct hwrm_async_event_cmpl_port_conn_not_allowed {
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_V      0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_OPAQUE_SFT 1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_SFT 0
@@ -238,7 +252,8 @@ struct hwrm_async_event_cmpl_func_drvr_unload {
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_OPAQUE_SFT  1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_EVENT_DATA1_FUNC_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_EVENT_DATA1_FUNC_ID_SFT 0
@@ -257,7 +272,8 @@ struct hwrm_async_event_cmpl_func_drvr_load {
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_V		    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_OPAQUE_MASK   0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_OPAQUE_SFT    1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_EVENT_DATA1_FUNC_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_EVENT_DATA1_FUNC_ID_SFT 0
@@ -276,10 +292,13 @@ struct hwrm_async_event_cmpl_pf_drvr_unload {
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_V		    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_OPAQUE_MASK   0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_OPAQUE_SFT    1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_DATA1_FUNC_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_DATA1_FUNC_ID_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_DATA1_PORT_MASK 0x70000UL
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_DATA1_PORT_SFT 16
 };
 
 /* HWRM Asynchronous Event Completion Record for PF Driver load (16 bytes) */
@@ -289,16 +308,19 @@ struct hwrm_async_event_cmpl_pf_drvr_load {
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_SFT	    0
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_ID_PF_DRVR_LOAD (0x20UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_ID_PF_DRVR_LOAD (0x21UL << 0)
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_V		    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_OPAQUE_MASK     0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_OPAQUE_SFT      1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_DATA1_FUNC_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_DATA1_FUNC_ID_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_DATA1_PORT_MASK 0x70000UL
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_DATA1_PORT_SFT 16
 };
 
 /* HWRM Asynchronous Event Completion Record for VF FLR (16 bytes) */
@@ -314,7 +336,8 @@ struct hwrm_async_event_cmpl_vf_flr {
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_V			    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_OPAQUE_MASK	    0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_OPAQUE_SFT	    1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_EVENT_DATA1_VF_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_EVENT_DATA1_VF_ID_SFT 0
@@ -333,7 +356,8 @@ struct hwrm_async_event_cmpl_vf_mac_addr_change {
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_OPAQUE_MASK 0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_OPAQUE_SFT 1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_EVENT_DATA1_VF_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_EVENT_DATA1_VF_ID_SFT 0
@@ -357,18 +381,20 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_V		    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_OPAQUE_MASK       0xfeUL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_OPAQUE_SFT	    1
-	u8 unused_1[3];
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA1_TIMESTAMP 0x1UL
 };
 
-/* HW Resource Manager Specification 0.7.8 */
-#define HWRM_VERSION_MAJOR	0
-#define HWRM_VERSION_MINOR	7
-#define HWRM_VERSION_UPDATE	8
+/* HW Resource Manager Specification 1.0.0 */
+#define HWRM_VERSION_MAJOR	1
+#define HWRM_VERSION_MINOR	0
+#define HWRM_VERSION_UPDATE	0
 
-#define HWRM_VERSION_STR	"0.7.8"
-/* Following is the signature for HWRM message field that indicates not
+#define HWRM_VERSION_STR	"1.0.0"
+/*
+ * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
  */
 #define HWRM_NA_SIGNATURE	((__le32)(-1))
@@ -398,7 +424,9 @@ struct output {
 struct cmd_nums {
 	__le16 req_type;
 	#define HWRM_VER_GET					   (0x0UL)
-	#define HWRM_FUNC_DISABLE				   (0x10UL)
+	#define HWRM_FUNC_BUF_UNRGTR				   (0xeUL)
+	#define HWRM_FUNC_VF_CFG				   (0xfUL)
+	#define RESERVED1					   (0x10UL)
 	#define HWRM_FUNC_RESET				   (0x11UL)
 	#define HWRM_FUNC_GETFID				   (0x12UL)
 	#define HWRM_FUNC_VF_ALLOC				   (0x13UL)
@@ -414,10 +442,9 @@ struct cmd_nums {
 	#define HWRM_FUNC_DRV_RGTR				   (0x1dUL)
 	#define HWRM_FUNC_DRV_QVER				   (0x1eUL)
 	#define HWRM_FUNC_BUF_RGTR				   (0x1fUL)
-	#define HWRM_FUNC_VF_CFG				   (0x20UL)
 	#define HWRM_PORT_PHY_CFG				   (0x20UL)
 	#define HWRM_PORT_MAC_CFG				   (0x21UL)
-	#define HWRM_PORT_ENABLE				   (0x22UL)
+	#define RESERVED2					   (0x22UL)
 	#define HWRM_PORT_QSTATS				   (0x23UL)
 	#define HWRM_PORT_LPBK_QSTATS				   (0x24UL)
 	#define HWRM_PORT_CLR_STATS				   (0x25UL)
@@ -455,13 +482,11 @@ struct cmd_nums {
 	#define HWRM_RING_GRP_FREE				   (0x61UL)
 	#define HWRM_VNIC_RSS_COS_LB_CTX_ALLOC			   (0x70UL)
 	#define HWRM_VNIC_RSS_COS_LB_CTX_FREE			   (0x71UL)
-	#define HWRM_ARB_GRP_ALLOC				   (0x80UL)
-	#define HWRM_ARB_GRP_CFG				   (0x81UL)
 	#define HWRM_CFA_L2_FILTER_ALLOC			   (0x90UL)
 	#define HWRM_CFA_L2_FILTER_FREE			   (0x91UL)
 	#define HWRM_CFA_L2_FILTER_CFG				   (0x92UL)
 	#define HWRM_CFA_L2_SET_RX_MASK			   (0x93UL)
-	#define HWRM_CFA_L2_SET_BCASTMCAST_MIRRORING		   (0x94UL)
+	#define RESERVED3					   (0x94UL)
 	#define HWRM_CFA_TUNNEL_FILTER_ALLOC			   (0x95UL)
 	#define HWRM_CFA_TUNNEL_FILTER_FREE			   (0x96UL)
 	#define HWRM_CFA_ENCAP_RECORD_ALLOC			   (0x97UL)
@@ -469,6 +494,9 @@ struct cmd_nums {
 	#define HWRM_CFA_NTUPLE_FILTER_ALLOC			   (0x99UL)
 	#define HWRM_CFA_NTUPLE_FILTER_FREE			   (0x9aUL)
 	#define HWRM_CFA_NTUPLE_FILTER_CFG			   (0x9bUL)
+	#define HWRM_CFA_EM_FLOW_ALLOC				   (0x9cUL)
+	#define HWRM_CFA_EM_FLOW_FREE				   (0x9dUL)
+	#define HWRM_CFA_EM_FLOW_CFG				   (0x9eUL)
 	#define HWRM_TUNNEL_DST_PORT_QUERY			   (0xa0UL)
 	#define HWRM_TUNNEL_DST_PORT_ALLOC			   (0xa1UL)
 	#define HWRM_TUNNEL_DST_PORT_FREE			   (0xa2UL)
@@ -483,8 +511,6 @@ struct cmd_nums {
 	#define HWRM_FWD_RESP					   (0xd2UL)
 	#define HWRM_FWD_ASYNC_EVENT_CMPL			   (0xd3UL)
 	#define HWRM_TEMP_MONITOR_QUERY			   (0xe0UL)
-	#define HWRM_MGMT_L2_FILTER_ALLOC			   (0x100UL)
-	#define HWRM_MGMT_L2_FILTER_FREE			   (0x101UL)
 	#define HWRM_DBG_READ_DIRECT				   (0xff10UL)
 	#define HWRM_DBG_READ_INDIRECT				   (0xff11UL)
 	#define HWRM_DBG_WRITE_DIRECT				   (0xff12UL)
@@ -505,7 +531,6 @@ struct cmd_nums {
 	__le16 unused_0[3];
 };
 
-/* Return Codes (8 bytes) */
 struct ret_codes {
 	__le16 error_code;
 	#define HWRM_ERR_CODE_SUCCESS				   (0x0UL)
@@ -529,7 +554,7 @@ struct hwrm_err_output {
 	__le16 resp_len;
 	__le32 opaque_0;
 	__le16 opaque_1;
-	u8 opaque_2;
+	u8 cmd_err;
 	u8 valid;
 };
 
@@ -686,65 +711,38 @@ struct hwrm_ver_get_output {
 	u8 hwrm_fw_min;
 	u8 hwrm_fw_bld;
 	u8 hwrm_fw_rsvd;
-	u8 ape_fw_maj;
-	u8 ape_fw_min;
-	u8 ape_fw_bld;
-	u8 ape_fw_rsvd;
-	u8 kong_fw_maj;
-	u8 kong_fw_min;
-	u8 kong_fw_bld;
-	u8 kong_fw_rsvd;
-	u8 tang_fw_maj;
-	u8 tang_fw_min;
-	u8 tang_fw_bld;
-	u8 tang_fw_rsvd;
-	u8 bono_fw_maj;
-	u8 bono_fw_min;
-	u8 bono_fw_bld;
-	u8 bono_fw_rsvd;
+	u8 mgmt_fw_maj;
+	u8 mgmt_fw_min;
+	u8 mgmt_fw_bld;
+	u8 mgmt_fw_rsvd;
+	u8 netctrl_fw_maj;
+	u8 netctrl_fw_min;
+	u8 netctrl_fw_bld;
+	u8 netctrl_fw_rsvd;
+	__le32 reserved1;
+	u8 roce_fw_maj;
+	u8 roce_fw_min;
+	u8 roce_fw_bld;
+	u8 roce_fw_rsvd;
 	char hwrm_fw_name[16];
-	char ape_fw_name[16];
-	char kong_fw_name[16];
-	char tang_fw_name[16];
-	char bono_fw_name[16];
+	char mgmt_fw_name[16];
+	char netctrl_fw_name[16];
+	__le32 reserved2[4];
+	char roce_fw_name[16];
 	__le16 chip_num;
 	u8 chip_rev;
 	u8 chip_metal;
 	u8 chip_bond_id;
-	u8 unused_0;
+	u8 chip_platform_type;
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_ASIC		   (0x0UL << 0)
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_FPGA		   (0x1UL << 0)
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_PALLADIUM	   (0x2UL << 0)
 	__le16 max_req_win_len;
 	__le16 max_resp_len;
 	__le16 def_req_timeout;
+	u8 unused_0;
 	u8 unused_1;
 	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
-/* hwrm_func_disable */
-/* Input (24 bytes) */
-struct hwrm_func_disable_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 enables;
-	#define FUNC_DISABLE_REQ_ENABLES_VF_ID_VALID		    0x1UL
-	__le16 vf_id;
-	__le16 unused_0;
-};
-
-/* Output (16 bytes) */
-struct hwrm_func_disable_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
 	u8 valid;
 };
 
@@ -759,7 +757,12 @@ struct hwrm_func_reset_input {
 	__le32 enables;
 	#define FUNC_RESET_REQ_ENABLES_VF_ID_VALID		    0x1UL
 	__le16 vf_id;
-	__le16 unused_0;
+	u8 func_reset_level;
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETALL	   (0x0UL << 0)
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETME	   (0x1UL << 0)
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETCHILDREN     (0x2UL << 0)
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETVF	   (0x3UL << 0)
+	u8 unused_0;
 };
 
 /* Output (16 bytes) */
@@ -861,7 +864,7 @@ struct hwrm_func_vf_free_output {
 };
 
 /* hwrm_func_vf_cfg */
-/* Input (24 bytes) */
+/* Input (32 bytes) */
 struct hwrm_func_vf_cfg_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -871,8 +874,11 @@ struct hwrm_func_vf_cfg_input {
 	__le32 enables;
 	#define FUNC_VF_CFG_REQ_ENABLES_MTU			    0x1UL
 	#define FUNC_VF_CFG_REQ_ENABLES_GUEST_VLAN		    0x2UL
+	#define FUNC_VF_CFG_REQ_ENABLES_ASYNC_EVENT_CR		    0x4UL
 	__le16 mtu;
 	__le16 guest_vlan;
+	__le16 async_event_cr;
+	__le16 unused_0[3];
 };
 
 /* Output (16 bytes) */
@@ -944,7 +950,7 @@ struct hwrm_func_cfg_input {
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le16 vf_id;
+	__le16 fid;
 	u8 unused_0;
 	u8 unused_1;
 	__le32 flags;
@@ -1000,10 +1006,6 @@ struct hwrm_func_cfg_input {
 	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_IF_VLANDNE (0x2UL << 0)
 	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_OR_OVERRIDE_VLAN (0x3UL << 0)
 	u8 allowed_vlan_pris;
-	#define FUNC_CFG_REQ_ALLOWED_VLAN_PRIS_NOCHECK		   (0x0UL << 0)
-	#define FUNC_CFG_REQ_ALLOWED_VLAN_PRIS_VALIDATE_VLAN      (0x1UL << 0)
-	#define FUNC_CFG_REQ_ALLOWED_VLAN_PRIS_INSERT_IF_VLANDNE  (0x2UL << 0)
-	#define FUNC_CFG_REQ_ALLOWED_VLAN_PRIS_INSERT_OR_OVERRIDE_VLAN (0x3UL << 0)
 	u8 evb_mode;
 	#define FUNC_CFG_REQ_EVB_MODE_NO_EVB			   (0x0UL << 0)
 	#define FUNC_CFG_REQ_EVB_MODE_VEB			   (0x1UL << 0)
@@ -1166,6 +1168,15 @@ struct hwrm_func_drv_rgtr_input {
 	#define FUNC_DRV_RGTR_REQ_ENABLES_VF_REQ_FWD		    0x8UL
 	#define FUNC_DRV_RGTR_REQ_ENABLES_ASYNC_EVENT_FWD	    0x10UL
 	__le16 os_type;
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_UNKNOWN		   (0x0UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_OTHER		   (0x1UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_MSDOS		   (0xeUL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_SOLARIS		   (0x1dUL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX		   (0x24UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_FREEBSD		   (0x2aUL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_ESXI			   (0x68UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN864		   (0x73UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN2012R2		   (0x74UL << 0)
 	u8 ver_maj;
 	u8 ver_min;
 	u8 ver_upd;
@@ -1276,9 +1287,7 @@ struct hwrm_func_drv_qver_input {
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le32 enables;
-	#define FUNC_DRV_QVER_REQ_ENABLES_OS_TYPE_VALID	    0x1UL
-	#define FUNC_DRV_QVER_REQ_ENABLES_VER_VALID		    0x2UL
+	__le32 reserved;
 	__le16 fid;
 	__le16 unused_0;
 };
@@ -1290,6 +1299,15 @@ struct hwrm_func_drv_qver_output {
 	__le16 seq_id;
 	__le16 resp_len;
 	__le16 os_type;
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_UNKNOWN		   (0x0UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_OTHER		   (0x1UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_MSDOS		   (0xeUL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_SOLARIS		   (0x1dUL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_LINUX		   (0x24UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_FREEBSD		   (0x2aUL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_ESXI		   (0x68UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN864		   (0x73UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN2012R2		   (0x74UL << 0)
 	u8 ver_maj;
 	u8 ver_min;
 	u8 ver_upd;
@@ -1498,9 +1516,7 @@ struct hwrm_port_phy_qcfg_output {
 	u8 force_pause;
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_TX		    0x1UL
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_RX		    0x2UL
-	u8 duplex_setting;
-	#define PORT_PHY_QCFG_RESP_DUPLEX_SETTING_HALF		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_DUPLEX_SETTING_FULL		   (0x1UL << 0)
+	u8 reserved1;
 	__le32 preemphasis;
 	u8 phy_maj;
 	u8 phy_min;
@@ -1601,33 +1617,6 @@ struct hwrm_port_mac_cfg_output {
 	u8 valid;
 };
 
-/* hwrm_port_enable */
-/* Input (24 bytes) */
-struct hwrm_port_enable_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 flags;
-	#define PORT_ENABLE_REQ_FLAGS_FORWARD_TRAFFIC		    0x1UL
-	__le16 port_id;
-	__le16 unused_0;
-};
-
-/* Output (16 bytes) */
-struct hwrm_port_enable_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
 /* hwrm_port_qstats */
 /* Input (40 bytes) */
 struct hwrm_port_qstats_input {
@@ -1651,10 +1640,11 @@ struct hwrm_port_qstats_output {
 	__le16 req_type;
 	__le16 seq_id;
 	__le16 resp_len;
-	__le32 unused_0;
+	__le16 tx_stat_size;
+	__le16 rx_stat_size;
+	u8 unused_0;
 	u8 unused_1;
 	u8 unused_2;
-	u8 unused_3;
 	u8 valid;
 };
 
@@ -1668,7 +1658,7 @@ struct hwrm_port_lpbk_qstats_input {
 	__le64 resp_addr;
 };
 
-/* Output (64 bytes) */
+/* Output (96 bytes) */
 struct hwrm_port_lpbk_qstats_output {
 	__le16 error_code;
 	__le16 req_type;
@@ -1680,6 +1670,10 @@ struct hwrm_port_lpbk_qstats_output {
 	__le64 lpbk_ucast_bytes;
 	__le64 lpbk_mcast_bytes;
 	__le64 lpbk_bcast_bytes;
+	__le64 tx_stat_discard;
+	__le64 tx_stat_error;
+	__le64 rx_stat_discard;
+	__le64 rx_stat_error;
 	__le32 unused_0;
 	u8 unused_1;
 	u8 unused_2;
@@ -1884,12 +1878,11 @@ struct hwrm_queue_buffers_cfg_input {
 	__le32 enables;
 	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_RESERVED		    0x1UL
 	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_SHARED		    0x2UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_GROUP		    0x4UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XOFF		    0x8UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XON		    0x10UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_FULL		    0x20UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_NOTFULL		    0x40UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_MAX		    0x80UL
+	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XOFF		    0x4UL
+	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XON		    0x8UL
+	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_FULL		    0x10UL
+	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_NOTFULL		    0x20UL
+	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_MAX		    0x40UL
 	__le32 queue_id;
 	__le32 reserved;
 	__le32 shared;
@@ -1921,15 +1914,15 @@ struct hwrm_queue_pfcenable_cfg_input {
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le32 enables;
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI0_PFC_ENABLED   0x1UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI1_PFC_ENABLED   0x2UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI2_PFC_ENABLED   0x4UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI3_PFC_ENABLED   0x8UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI4_PFC_ENABLED   0x10UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI5_PFC_ENABLED   0x20UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI6_PFC_ENABLED   0x40UL
-	#define QUEUE_PFCENABLE_CFG_REQ_ENABLES_PRI7_PFC_ENABLED   0x80UL
+	__le32 flags;
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI0_PFC_ENABLED     0x1UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI1_PFC_ENABLED     0x2UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI2_PFC_ENABLED     0x4UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI3_PFC_ENABLED     0x8UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI4_PFC_ENABLED     0x10UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI5_PFC_ENABLED     0x20UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI6_PFC_ENABLED     0x40UL
+	#define QUEUE_PFCENABLE_CFG_REQ_FLAGS_PRI7_PFC_ENABLED     0x80UL
 	__le16 port_id;
 	__le16 unused_0;
 };
@@ -1962,14 +1955,14 @@ struct hwrm_queue_pri2cos_cfg_input {
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_IVLAN		    0x2UL
 	__le32 enables;
 	u8 port_id;
-	u8 pri0_cos;
-	u8 pri1_cos;
-	u8 pri2_cos;
-	u8 pri3_cos;
-	u8 pri4_cos;
-	u8 pri5_cos;
-	u8 pri6_cos;
-	u8 pri7_cos;
+	u8 pri0_cos_queue_id;
+	u8 pri1_cos_queue_id;
+	u8 pri2_cos_queue_id;
+	u8 pri3_cos_queue_id;
+	u8 pri4_cos_queue_id;
+	u8 pri5_cos_queue_id;
+	u8 pri6_cos_queue_id;
+	u8 pri7_cos_queue_id;
 	u8 unused_0[7];
 };
 
@@ -2164,6 +2157,7 @@ struct hwrm_vnic_cfg_input {
 	__le32 flags;
 	#define VNIC_CFG_REQ_FLAGS_DEFAULT			    0x1UL
 	#define VNIC_CFG_REQ_FLAGS_VLAN_STRIP_MODE		    0x2UL
+	#define VNIC_CFG_REQ_FLAGS_BD_STALL_MODE		    0x4UL
 	__le32 enables;
 	#define VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP		    0x1UL
 	#define VNIC_CFG_REQ_ENABLES_RSS_RULE			    0x2UL
@@ -2380,18 +2374,16 @@ struct hwrm_ring_alloc_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	__le32 enables;
-	#define RING_ALLOC_REQ_ENABLES_ARB_GRP_ID_VALID	    0x1UL
-	#define RING_ALLOC_REQ_ENABLES_INPUT_NUM_VALID		    0x2UL
-	#define RING_ALLOC_REQ_ENABLES_WEIGHT_VALID		    0x4UL
+	#define RING_ALLOC_REQ_ENABLES_RESERVED1		    0x1UL
+	#define RING_ALLOC_REQ_ENABLES_RESERVED2		    0x2UL
+	#define RING_ALLOC_REQ_ENABLES_RESERVED3		    0x4UL
 	#define RING_ALLOC_REQ_ENABLES_STAT_CTX_ID_VALID	    0x8UL
-	#define RING_ALLOC_REQ_ENABLES_MIN_BW_VALID		    0x10UL
+	#define RING_ALLOC_REQ_ENABLES_RESERVED4		    0x10UL
 	#define RING_ALLOC_REQ_ENABLES_MAX_BW_VALID		    0x20UL
 	u8 ring_type;
 	#define RING_ALLOC_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
 	#define RING_ALLOC_REQ_RING_TYPE_TX			   (0x1UL << 0)
 	#define RING_ALLOC_REQ_RING_TYPE_RX			   (0x2UL << 0)
-	#define RING_ALLOC_REQ_RING_TYPE_STATUS		   (0x3UL << 0)
-	#define RING_ALLOC_REQ_RING_TYPE_CMD			   (0x4UL << 0)
 	u8 unused_0;
 	__le16 unused_1;
 	__le64 page_tbl_addr;
@@ -2406,17 +2398,17 @@ struct hwrm_ring_alloc_input {
 	__le16 queue_id;
 	u8 unused_4;
 	u8 unused_5;
-	__le32 arb_grp_id;
-	__le16 input_number;
+	__le32 reserved1;
+	__le16 reserved2;
 	u8 unused_6;
 	u8 unused_7;
-	__le32 weight;
+	__le32 reserved3;
 	__le32 stat_ctx_id;
-	__le32 min_bw;
+	__le32 reserved4;
 	__le32 max_bw;
 	u8 int_mode;
 	#define RING_ALLOC_REQ_INT_MODE_LEGACY			   (0x0UL << 0)
-	#define RING_ALLOC_REQ_INT_MODE_MSI			   (0x1UL << 0)
+	#define RING_ALLOC_REQ_INT_MODE_RSVD			   (0x1UL << 0)
 	#define RING_ALLOC_REQ_INT_MODE_MSIX			   (0x2UL << 0)
 	#define RING_ALLOC_REQ_INT_MODE_POLL			   (0x3UL << 0)
 	u8 unused_8[3];
@@ -2448,8 +2440,6 @@ struct hwrm_ring_free_input {
 	#define RING_FREE_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
 	#define RING_FREE_REQ_RING_TYPE_TX			   (0x1UL << 0)
 	#define RING_FREE_REQ_RING_TYPE_RX			   (0x2UL << 0)
-	#define RING_FREE_REQ_RING_TYPE_STATUS			   (0x3UL << 0)
-	#define RING_FREE_REQ_RING_TYPE_CMD			   (0x4UL << 0)
 	u8 unused_0;
 	__le16 ring_id;
 	__le32 unused_1;
@@ -2550,8 +2540,6 @@ struct hwrm_ring_reset_input {
 	#define RING_RESET_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
 	#define RING_RESET_REQ_RING_TYPE_TX			   (0x1UL << 0)
 	#define RING_RESET_REQ_RING_TYPE_RX			   (0x2UL << 0)
-	#define RING_RESET_REQ_RING_TYPE_STATUS		   (0x3UL << 0)
-	#define RING_RESET_REQ_RING_TYPE_CMD			   (0x4UL << 0)
 	u8 unused_0;
 	__le16 ring_id;
 	__le32 unused_1;
@@ -2622,61 +2610,6 @@ struct hwrm_ring_grp_free_output {
 	u8 valid;
 };
 
-/* hwrm_arb_grp_alloc */
-/* Input (24 bytes) */
-struct hwrm_arb_grp_alloc_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le16 input_number;
-	__le16 unused_0[3];
-};
-
-/* Output (16 bytes) */
-struct hwrm_arb_grp_alloc_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le16 arb_grp_id;
-	u8 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 unused_4;
-	u8 valid;
-};
-
-/* hwrm_arb_grp_cfg */
-/* Input (32 bytes) */
-struct hwrm_arb_grp_cfg_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 arb_grp_id;
-	__le16 input_number;
-	__le16 tx_ring;
-	__le32 weight;
-	__le32 unused_0;
-};
-
-/* Output (16 bytes) */
-struct hwrm_arb_grp_cfg_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
 /* hwrm_cfa_l2_filter_alloc */
 /* Input (96 bytes) */
 struct hwrm_cfa_l2_filter_alloc_input {
@@ -2708,7 +2641,7 @@ struct hwrm_cfa_l2_filter_alloc_input {
 	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_SRC_TYPE	    0x1000UL
 	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_SRC_ID		    0x2000UL
 	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_TUNNEL_TYPE	    0x4000UL
-	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_DST_VNIC_ID	    0x8000UL
+	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_DST_ID		    0x8000UL
 	#define CFA_L2_FILTER_ALLOC_REQ_ENABLES_MIRROR_VNIC_ID     0x10000UL
 	u8 l2_addr[6];
 	u8 unused_0;
@@ -2751,7 +2684,7 @@ struct hwrm_cfa_l2_filter_alloc_input {
 	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE	   (0x8UL << 0)
 	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL     (0xffUL << 0)
 	u8 unused_7;
-	__le16 dst_vnic_id;
+	__le16 dst_id;
 	__le16 mirror_vnic_id;
 	u8 pri_hint;
 	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER	   (0x0UL << 0)
@@ -2816,10 +2749,11 @@ struct hwrm_cfa_l2_filter_cfg_input {
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_DROP		    0x2UL
 	__le32 enables;
-	#define CFA_L2_FILTER_CFG_REQ_ENABLES_DST_VNIC_ID_VALID    0x1UL
+	#define CFA_L2_FILTER_CFG_REQ_ENABLES_DST_ID		    0x1UL
+	#define CFA_L2_FILTER_CFG_REQ_ENABLES_NEW_MIRROR_VNIC_ID   0x2UL
 	__le64 l2_filter_id;
-	__le32 dst_vnic_id;
-	__le32 unused_0;
+	__le32 dst_id;
+	__le32 new_mirror_vnic_id;
 };
 
 /* Output (16 bytes) */
@@ -2843,9 +2777,9 @@ struct hwrm_cfa_l2_set_rx_mask_input {
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le32 dflt_vnic_id;
+	__le32 vnic_id;
 	__le32 mask;
-	#define CFA_L2_SET_RX_MASK_REQ_MASK_UNICAST		    0x1UL
+	#define CFA_L2_SET_RX_MASK_REQ_MASK_RESERVED		    0x1UL
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_MCAST		    0x2UL
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_ALL_MCAST		    0x4UL
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_BCAST		    0x8UL
@@ -2869,46 +2803,6 @@ struct hwrm_cfa_l2_set_rx_mask_output {
 	u8 valid;
 };
 
-/* hwrm_cfa_l2_set_bcastmcast_mirroring */
-/* Input (32 bytes) */
-struct hwrm_cfa_l2_set_bcastmcast_mirroring_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 dflt_vnic_id;
-	__le32 mirroring_flags;
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MIRRORING_FLAGS_BCAST_MIRRORING 0x1UL
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MIRRORING_FLAGS_MCAST_MIRRORING 0x2UL
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MIRRORING_FLAGS_BCAST_SRC_KNOCKOUT 0x4UL
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MIRRORING_FLAGS_MCAST_SRC_KNOCKOUT 0x8UL
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MIRRORING_FLAGS_VLAN_ID_VALID 0x10UL
-	__le16 vlan_id;
-	u8 bcast_domain;
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_BCAST_DOMAIN_PFONLY (0x0UL << 0)
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_BCAST_DOMAIN_ALLPFS (0x1UL << 0)
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_BCAST_DOMAIN_ALLPFSVFS (0x2UL << 0)
-	u8 mcast_domain;
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MCAST_DOMAIN_PFONLY (0x0UL << 0)
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MCAST_DOMAIN_ALLPFS (0x1UL << 0)
-	#define CFA_L2_SET_BCASTMCAST_MIRRORING_REQ_MCAST_DOMAIN_ALLPFSVFS (0x2UL << 0)
-	__le32 unused_0;
-};
-
-/* Output (16 bytes) */
-struct hwrm_cfa_l2_set_bcastmcast_mirroring_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
 /* hwrm_cfa_tunnel_filter_alloc */
 /* Input (88 bytes) */
 struct hwrm_cfa_tunnel_filter_alloc_input {
@@ -3017,17 +2911,16 @@ struct hwrm_cfa_encap_record_alloc_input {
 	__le32 encap_data[16];
 };
 
-/* Output (24 bytes) */
+/* Output (16 bytes) */
 struct hwrm_cfa_encap_record_alloc_output {
 	__le16 error_code;
 	__le16 req_type;
 	__le16 seq_id;
 	__le16 resp_len;
-	__le64 encap_record_id;
-	__le32 unused_0;
+	__le32 encap_record_id;
+	u8 unused_0;
 	u8 unused_1;
 	u8 unused_2;
-	u8 unused_3;
 	u8 valid;
 };
 
@@ -3039,7 +2932,8 @@ struct hwrm_cfa_encap_record_free_input {
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le64 encap_record_id;
+	__le32 encap_record_id;
+	__le32 unused_0;
 };
 
 /* Output (16 bytes) */
@@ -3083,14 +2977,21 @@ struct hwrm_cfa_ntuple_filter_alloc_input {
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_PORT_MASK  0x2000UL
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_PRI_HINT       0x4000UL
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_NTUPLE_FILTER_ID 0x8000UL
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_VNIC_ID    0x10000UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_ID	    0x10000UL
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_MIRROR_VNIC_ID 0x20000UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_MACADDR    0x40000UL
 	__le64 l2_filter_id;
 	u8 src_macaddr[6];
 	__be16 ethertype;
-	u8 ipaddr_type;
+	u8 ip_addr_type;
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_UNKNOWN  (0x0UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV4     (0x4UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV6     (0x6UL << 0)
 	u8 ip_protocol;
-	__le16 dst_vnic_id;
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UNKNOWN   (0x0UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UDP       (0x6UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_TCP       (0x11UL << 0)
+	__le16 dst_id;
 	__le16 mirror_vnic_id;
 	u8 tunnel_type;
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL (0x0UL << 0)
@@ -3104,6 +3005,11 @@ struct hwrm_cfa_ntuple_filter_alloc_input {
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE     (0x8UL << 0)
 	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL (0xffUL << 0)
 	u8 pri_hint;
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER    (0x0UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_ABOVE	   (0x1UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_BELOW	   (0x2UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_HIGHEST      (0x3UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_LOWEST       (0x4UL << 0)
 	__be32 src_ipaddr[4];
 	__be32 src_ipaddr_mask[4];
 	__be32 dst_ipaddr[4];
@@ -3162,11 +3068,11 @@ struct hwrm_cfa_ntuple_filter_cfg_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	__le32 enables;
-	#define CFA_NTUPLE_FILTER_CFG_REQ_ENABLES_NEW_DST_VNIC_ID_VALID 0x1UL
-	#define CFA_NTUPLE_FILTER_CFG_REQ_ENABLES_NEW_MIRROR_VNIC_ID_VALID 0x2UL
+	#define CFA_NTUPLE_FILTER_CFG_REQ_ENABLES_NEW_DST_ID       0x1UL
+	#define CFA_NTUPLE_FILTER_CFG_REQ_ENABLES_NEW_MIRROR_VNIC_ID 0x2UL
 	__le32 unused_0;
 	__le64 ntuple_filter_id;
-	__le32 new_dst_vnic_id;
+	__le32 new_dst_id;
 	__le32 new_mirror_vnic_id;
 };
 
@@ -3192,16 +3098,8 @@ struct hwrm_tunnel_dst_port_query_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_NONTUNNEL   (0x0UL << 0)
 	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_VXLAN       (0x1UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_NVGRE       (0x2UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_L2GRE       (0x3UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_IPIP	   (0x4UL << 0)
 	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_GENEVE      (0x5UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_MPLS	   (0x6UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_STT	   (0x7UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_IPGRE       (0x8UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_ANYTUNNEL   (0xffUL << 0)
 	u8 unused_0[7];
 };
 
@@ -3228,16 +3126,8 @@ struct hwrm_tunnel_dst_port_alloc_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL   (0x0UL << 0)
 	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_VXLAN       (0x1UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_NVGRE       (0x2UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_L2GRE       (0x3UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_IPIP	   (0x4UL << 0)
 	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE      (0x5UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_MPLS	   (0x6UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_STT	   (0x7UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_IPGRE       (0x8UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL   (0xffUL << 0)
 	u8 unused_0;
 	__be16 tunnel_dst_port_val;
 	__le32 unused_1;
@@ -3267,16 +3157,8 @@ struct hwrm_tunnel_dst_port_free_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_NONTUNNEL    (0x0UL << 0)
 	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN	   (0x1UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_NVGRE	   (0x2UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_L2GRE	   (0x3UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_IPIP	   (0x4UL << 0)
 	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE       (0x5UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_MPLS	   (0x6UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_STT	   (0x7UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_IPGRE	   (0x8UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_ANYTUNNEL    (0xffUL << 0)
 	u8 unused_0;
 	__le16 tunnel_dst_port_id;
 	__le32 unused_1;
@@ -3416,68 +3298,145 @@ struct hwrm_stat_ctx_clr_stats_output {
 	u8 valid;
 };
 
-/* hwrm_mgmt_l2_filter_alloc */
-/* Input (56 bytes) */
-struct hwrm_mgmt_l2_filter_alloc_input {
+/* hwrm_fw_reset */
+/* Input (24 bytes) */
+struct hwrm_fw_reset_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le32 flags;
-	#define MGMT_L2_FILTER_ALLOC_REQ_FLAGS_PATH		    0x1UL
-	#define MGMT_L2_FILTER_ALLOC_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
-	#define MGMT_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
-	__le32 enables;
-	#define MGMT_L2_FILTER_ALLOC_REQ_ENABLES_L2_ADDRESS	    0x1UL
-	#define MGMT_L2_FILTER_ALLOC_REQ_ENABLES_OVLAN		    0x2UL
-	#define MGMT_L2_FILTER_ALLOC_REQ_ENABLES_IVLAN		    0x4UL
-	#define MGMT_L2_FILTER_ALLOC_REQ_ENABLES_ACTION_ID	    0x8UL
-	u8 l2_address[6];
+	u8 embedded_proc_type;
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_BOOT		   (0x0UL << 0)
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_MGMT		   (0x1UL << 0)
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   (0x2UL << 0)
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_ROCE		   (0x3UL << 0)
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_RSVD		   (0x4UL << 0)
+	u8 selfrst_status;
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST	   (0x2UL << 0)
+	__le16 unused_0[3];
+};
+
+/* Output (16 bytes) */
+struct hwrm_fw_reset_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 selfrst_status;
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTPCIERST       (0x2UL << 0)
 	u8 unused_0;
+	__le16 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 unused_4;
+	u8 valid;
+};
+
+/* hwrm_exec_fwd_resp */
+/* Input (128 bytes) */
+struct hwrm_exec_fwd_resp_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 encap_request[26];
+	__le16 encap_resp_target_id;
+	__le16 unused_0[3];
+};
+
+/* Output (16 bytes) */
+struct hwrm_exec_fwd_resp_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 unused_0;
 	u8 unused_1;
-	u8 l2_address_mask[6];
-	__le16 ovlan;
-	__le16 ovlan_mask;
-	__le16 ivlan;
-	__le16 ivlan_mask;
 	u8 unused_2;
 	u8 unused_3;
-	__le32 action_id;
-	u8 action_bypass;
-	#define MGMT_L2_FILTER_ALLOC_REQ_ACTION_BYPASS		    0x1UL
-	u8 unused_5[3];
+	u8 valid;
+};
+
+/* hwrm_reject_fwd_resp */
+/* Input (128 bytes) */
+struct hwrm_reject_fwd_resp_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 encap_request[26];
+	__le16 encap_resp_target_id;
+	__le16 unused_0[3];
 };
 
 /* Output (16 bytes) */
-struct hwrm_mgmt_l2_filter_alloc_output {
+struct hwrm_reject_fwd_resp_output {
 	__le16 error_code;
 	__le16 req_type;
 	__le16 seq_id;
 	__le16 resp_len;
-	__le16 mgmt_l2_filter_id;
+	__le32 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
+/* hwrm_fwd_resp */
+/* Input (40 bytes) */
+struct hwrm_fwd_resp_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le16 encap_resp_target_id;
+	__le16 encap_resp_cmpl_ring;
+	__le16 encap_resp_len;
 	u8 unused_0;
 	u8 unused_1;
+	__le64 encap_resp_addr;
+	__le32 encap_resp[24];
+};
+
+/* Output (16 bytes) */
+struct hwrm_fwd_resp_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 unused_0;
+	u8 unused_1;
 	u8 unused_2;
 	u8 unused_3;
-	u8 unused_4;
 	u8 valid;
 };
 
-/* hwrm_mgmt_l2_filter_free */
-/* Input (24 bytes) */
-struct hwrm_mgmt_l2_filter_free_input {
+/* hwrm_fwd_async_event_cmpl */
+/* Input (32 bytes) */
+struct hwrm_fwd_async_event_cmpl_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
 	__le16 seq_id;
 	__le16 target_id;
 	__le64 resp_addr;
-	__le16 mgmt_l2_filter_id;
-	__le16 unused_0[3];
+	__le16 encap_async_event_target_id;
+	u8 unused_0;
+	u8 unused_1;
+	u8 unused_2[3];
+	u8 unused_3;
+	__le32 encap_async_event_cmpl[4];
 };
 
 /* Output (16 bytes) */
-struct hwrm_mgmt_l2_filter_free_output {
+struct hwrm_fwd_async_event_cmpl_output {
 	__le16 error_code;
 	__le16 req_type;
 	__le16 seq_id;
@@ -3489,6 +3448,31 @@ struct hwrm_mgmt_l2_filter_free_output {
 	u8 valid;
 };
 
+/* hwrm_temp_monitor_query */
+/* Input (16 bytes) */
+struct hwrm_temp_monitor_query_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+};
+
+/* Output (16 bytes) */
+struct hwrm_temp_monitor_query_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 temp;
+	u8 unused_0;
+	__le16 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 unused_4;
+	u8 valid;
+};
+
 /* hwrm_nvm_raw_write_blk */
 /* Input (32 bytes) */
 struct hwrm_nvm_raw_write_blk_input {
@@ -3621,7 +3605,7 @@ struct hwrm_nvm_get_dir_info_output {
 };
 
 /* hwrm_nvm_write */
-/* Input (40 bytes) */
+/* Input (48 bytes) */
 struct hwrm_nvm_write_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -3637,6 +3621,8 @@ struct hwrm_nvm_write_input {
 	__le16 option;
 	__le16 flags;
 	#define NVM_WRITE_REQ_FLAGS_KEEP_ORIG_ACTIVE_IMG	    0x1UL
+	__le32 dir_item_length;
+	__le32 unused_0;
 };
 
 /* Output (16 bytes) */
@@ -3645,10 +3631,9 @@ struct hwrm_nvm_write_output {
 	__le16 req_type;
 	__le16 seq_id;
 	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
+	__le32 dir_item_length;
+	__le16 dir_idx;
+	u8 unused_0;
 	u8 valid;
 };
 
@@ -3833,214 +3818,4 @@ struct hwrm_nvm_verify_update_output {
 	u8 valid;
 };
 
-/* hwrm_exec_fwd_resp */
-/* Input (120 bytes) */
-struct hwrm_exec_fwd_resp_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 encap_request[24];
-	__le16 encap_resp_target_id;
-	__le16 unused_0[3];
-};
-
-/* Output (16 bytes) */
-struct hwrm_exec_fwd_resp_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
-/* hwrm_reject_fwd_resp */
-/* Input (120 bytes) */
-struct hwrm_reject_fwd_resp_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 encap_request[24];
-	__le16 encap_resp_target_id;
-	__le16 unused_0[3];
-};
-
-/* Output (16 bytes) */
-struct hwrm_reject_fwd_resp_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
-/* hwrm_fwd_resp */
-/* Input (40 bytes) */
-struct hwrm_fwd_resp_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le16 encap_resp_target_id;
-	__le16 encap_resp_cmpl_ring;
-	__le16 encap_resp_len;
-	u8 unused_0;
-	u8 unused_1;
-	__le64 encap_resp_addr;
-	__le32 encap_resp[24];
-};
-
-/* Output (16 bytes) */
-struct hwrm_fwd_resp_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
-/* hwrm_fwd_async_event_cmpl */
-/* Input (32 bytes) */
-struct hwrm_fwd_async_event_cmpl_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le16 encap_async_event_target_id;
-	u8 unused_0;
-	u8 unused_1;
-	u8 unused_2[3];
-	u8 unused_3;
-	__le32 encap_async_event_cmpl[4];
-};
-
-/* Output (16 bytes) */
-struct hwrm_fwd_async_event_cmpl_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	__le32 unused_0;
-	u8 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 valid;
-};
-
-/* hwrm_fw_reset */
-/* Input (24 bytes) */
-struct hwrm_fw_reset_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	u8 embedded_proc_type;
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_CHIMP		   (0x0UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_APE		   (0x1UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_KONG		   (0x2UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_BONO		   (0x3UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_TANG		   (0x4UL << 0)
-	u8 selfrst_status;
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST	   (0x2UL << 0)
-	__le16 unused_0[3];
-};
-
-/* Output (16 bytes) */
-struct hwrm_fw_reset_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	u8 selfrst_status;
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTPCIERST       (0x2UL << 0)
-	u8 unused_0;
-	__le16 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 unused_4;
-	u8 valid;
-};
-
-/* hwrm_fw_qstatus */
-/* Input (24 bytes) */
-struct hwrm_fw_qstatus_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	u8 embedded_proc_type;
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_CHIMP	   (0x0UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_APE		   (0x1UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_KONG		   (0x2UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_BONO		   (0x3UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_TANG		   (0x4UL << 0)
-	u8 unused_0[7];
-};
-
-/* Output (16 bytes) */
-struct hwrm_fw_qstatus_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	u8 selfrst_status;
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTPCIERST     (0x2UL << 0)
-	u8 unused_0;
-	__le16 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 unused_4;
-	u8 valid;
-};
-
-/* hwrm_temp_monitor_query */
-/* Input (16 bytes) */
-struct hwrm_temp_monitor_query_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-};
-
-/* Output (16 bytes) */
-struct hwrm_temp_monitor_query_output {
-	__le16 error_code;
-	__le16 req_type;
-	__le16 seq_id;
-	__le16 resp_len;
-	u8 temp;
-	u8 unused_0;
-	__le16 unused_1;
-	u8 unused_2;
-	u8 unused_3;
-	u8 unused_4;
-	u8 valid;
-};
-
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 79b48e4..c1cc83d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -64,7 +64,7 @@ int bnxt_set_vf_spoofchk(struct net_device *dev, int vf_id, bool setting)
 	 * the spoof check should also include vlan anti-spoofing
 	 */
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
-	req.vf_id = cpu_to_le16(vf->fw_fid);
+	req.fid = cpu_to_le16(vf->fw_fid);
 	req.flags = cpu_to_le32(func_flags);
 	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 	if (!rc) {
@@ -128,7 +128,7 @@ int bnxt_set_vf_mac(struct net_device *dev, int vf_id, u8 *mac)
 
 	memcpy(vf->mac_addr, mac, ETH_ALEN);
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
-	req.vf_id = cpu_to_le16(vf->fw_fid);
+	req.fid = cpu_to_le16(vf->fw_fid);
 	req.flags = cpu_to_le32(vf->func_flags);
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_DFLT_MAC_ADDR);
 	memcpy(req.dflt_mac_addr, mac, ETH_ALEN);
@@ -159,7 +159,7 @@ int bnxt_set_vf_vlan(struct net_device *dev, int vf_id, u16 vlan_id, u8 qos)
 		return 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
-	req.vf_id = cpu_to_le16(vf->fw_fid);
+	req.fid = cpu_to_le16(vf->fw_fid);
 	req.flags = cpu_to_le32(vf->func_flags);
 	req.dflt_vlan = cpu_to_le16(vlan_tag);
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_DFLT_VLAN);
@@ -198,7 +198,7 @@ int bnxt_set_vf_bw(struct net_device *dev, int vf_id, int min_tx_rate,
 	if (min_tx_rate == vf->min_tx_rate && max_tx_rate == vf->max_tx_rate)
 		return 0;
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
-	req.vf_id = cpu_to_le16(vf->fw_fid);
+	req.fid = cpu_to_le16(vf->fw_fid);
 	req.flags = cpu_to_le32(vf->func_flags);
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_MAX_BW);
 	req.max_bw = cpu_to_le32(max_tx_rate);
@@ -421,13 +421,13 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < num_vfs; i++) {
-		req.vf_id = cpu_to_le16(pf->first_vf_id + i);
+		req.fid = cpu_to_le16(pf->first_vf_id + i);
 		rc = _hwrm_send_message(bp, &req, sizeof(req),
 					HWRM_CMD_TIMEOUT);
 		if (rc)
 			break;
 		pf->active_vfs = i + 1;
-		pf->vf[i].fw_fid = le16_to_cpu(req.vf_id);
+		pf->vf[i].fw_fid = le16_to_cpu(req.fid);
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	if (!rc) {
@@ -600,6 +600,7 @@ static int bnxt_hwrm_fwd_resp(struct bnxt *bp, struct bnxt_vf_info *vf,
 
 	/* Set the new target id */
 	req.target_id = cpu_to_le16(vf->fw_fid);
+	req.encap_resp_target_id = cpu_to_le16(vf->fw_fid);
 	req.encap_resp_len = cpu_to_le16(msg_size);
 	req.encap_resp_addr = encap_resp_addr;
 	req.encap_resp_cmpl_ring = encap_resp_cpr;
@@ -634,6 +635,7 @@ static int bnxt_hwrm_fwd_err_resp(struct bnxt *bp, struct bnxt_vf_info *vf,
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_REJECT_FWD_RESP, -1, -1);
 	/* Set the new target id */
 	req.target_id = cpu_to_le16(vf->fw_fid);
+	req.encap_resp_target_id = cpu_to_le16(vf->fw_fid);
 	memcpy(req.encap_request, vf->hwrm_cmd_req_addr, msg_size);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
@@ -665,6 +667,7 @@ static int bnxt_hwrm_exec_fwd_resp(struct bnxt *bp, struct bnxt_vf_info *vf,
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_EXEC_FWD_RESP, -1, -1);
 	/* Set the new target id */
 	req.target_id = cpu_to_le16(vf->fw_fid);
+	req.encap_resp_target_id = cpu_to_le16(vf->fw_fid);
 	memcpy(req.encap_request, vf->hwrm_cmd_req_addr, msg_size);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
-- 
1.8.3.1
