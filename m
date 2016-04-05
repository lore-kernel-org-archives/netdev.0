From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 1/9] bnxt_en: Update to Firmware 1.2.2 spec.
Date: Tue,  5 Apr 2016 14:08:55 -0400
Message-ID: <1459879743-16960-2-git-send-email-michael.chan@broadcom.com>
References: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34331 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759468AbcDESJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:09:09 -0400
In-Reply-To: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use new field names in API structs and stop using deprecated fields
auto_link_speed and auto_duplex in phy_cfg/phy_qcfg structs.

Update copyright year to 2016.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  20 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |   8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  |   4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h  |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h   |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h      | 433 +++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  14 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |   2 +-
 9 files changed, 431 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 12a009d..bfe98cb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -2763,7 +2763,7 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 	 * only checks if it is non-zero to enable async event forwarding
 	 */
 	req.async_event_fwd[0] |= cpu_to_le32(1);
-	req.os_type = cpu_to_le16(1);
+	req.os_type = cpu_to_le16(FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX);
 	req.ver_maj = DRV_VER_MAJ;
 	req.ver_min = DRV_VER_MIN;
 	req.ver_upd = DRV_VER_UPD;
@@ -3726,7 +3726,7 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 
 		pf->fw_fid = le16_to_cpu(resp->fid);
 		pf->port_id = le16_to_cpu(resp->port_id);
-		memcpy(pf->mac_addr, resp->perm_mac_address, ETH_ALEN);
+		memcpy(pf->mac_addr, resp->mac_address, ETH_ALEN);
 		memcpy(bp->dev->dev_addr, pf->mac_addr, ETH_ALEN);
 		pf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		pf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
@@ -3751,7 +3751,7 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		struct bnxt_vf_info *vf = &bp->vf;
 
 		vf->fw_fid = le16_to_cpu(resp->fid);
-		memcpy(vf->mac_addr, resp->perm_mac_address, ETH_ALEN);
+		memcpy(vf->mac_addr, resp->mac_address, ETH_ALEN);
 		if (is_valid_ether_addr(vf->mac_addr))
 			/* overwrite netdev dev_adr with admin VF MAC */
 			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
@@ -3842,6 +3842,8 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 
 	memcpy(&bp->ver_resp, resp, sizeof(struct hwrm_ver_get_output));
 
+	bp->hwrm_spec_code = resp->hwrm_intf_maj << 16 |
+			     resp->hwrm_intf_min << 8 | resp->hwrm_intf_upd;
 	if (resp->hwrm_intf_maj < 1) {
 		netdev_warn(bp->dev, "HWRM interface %d.%d.%d is older than 1.0.0.\n",
 			    resp->hwrm_intf_maj, resp->hwrm_intf_min,
@@ -4523,7 +4525,6 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	else
 		link_info->link_speed = 0;
 	link_info->force_link_speed = le16_to_cpu(resp->force_link_speed);
-	link_info->auto_link_speed = le16_to_cpu(resp->auto_link_speed);
 	link_info->support_speeds = le16_to_cpu(resp->support_speeds);
 	link_info->auto_link_speeds = le16_to_cpu(resp->auto_link_speed_mask);
 	link_info->lp_auto_link_speeds =
@@ -4533,8 +4534,8 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->phy_ver[1] = resp->phy_min;
 	link_info->phy_ver[2] = resp->phy_bld;
 	link_info->media_type = resp->media_type;
-	link_info->transceiver = resp->transceiver_type;
-	link_info->phy_addr = resp->phy_addr;
+	link_info->transceiver = resp->xcvr_pkg_type;
+	link_info->phy_addr = resp->eee_config_phy_addr;
 
 	/* TODO: need to add more logic to report VF link */
 	if (chng_link_state) {
@@ -4581,7 +4582,7 @@ static void bnxt_hwrm_set_link_common(struct bnxt *bp,
 
 	if (autoneg & BNXT_AUTONEG_SPEED) {
 		req->auto_mode |=
-			PORT_PHY_CFG_REQ_AUTO_MODE_MASK;
+			PORT_PHY_CFG_REQ_AUTO_MODE_SPEED_MASK;
 
 		req->enables |= cpu_to_le32(
 			PORT_PHY_CFG_REQ_ENABLES_AUTO_LINK_SPEED_MASK);
@@ -4595,9 +4596,6 @@ static void bnxt_hwrm_set_link_common(struct bnxt *bp,
 		req->flags |= cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_FORCE);
 	}
 
-	/* currently don't support half duplex */
-	req->auto_duplex = PORT_PHY_CFG_REQ_AUTO_DUPLEX_FULL;
-	req->enables |= cpu_to_le32(PORT_PHY_CFG_REQ_ENABLES_AUTO_DUPLEX);
 	/* tell chimp that the setting takes effect immediately */
 	req->flags |= cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_RESET_PHY);
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 709b95b..e98c37a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -11,7 +11,7 @@
 #define BNXT_H
 
 #define DRV_MODULE_NAME		"bnxt_en"
-#define DRV_MODULE_VERSION	"1.0.0"
+#define DRV_MODULE_VERSION	"1.2.0"
 
 #define DRV_VER_MAJ	1
 #define DRV_VER_MIN	0
@@ -788,7 +788,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_AUTO_ALLSPDS	PORT_PHY_QCFG_RESP_AUTO_MODE_ALL_SPEEDS
 #define BNXT_LINK_AUTO_ONESPD	PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_SPEED
 #define BNXT_LINK_AUTO_ONEORBELOW PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_OR_BELOW
-#define BNXT_LINK_AUTO_MSK	PORT_PHY_QCFG_RESP_AUTO_MODE_MASK
+#define BNXT_LINK_AUTO_MSK	PORT_PHY_QCFG_RESP_AUTO_MODE_SPEED_MASK
 #define PHY_VER_LEN		3
 	u8			phy_ver[PHY_VER_LEN];
 	u16			link_speed;
@@ -813,7 +813,6 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_MSK_40GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_40GB
 #define BNXT_LINK_SPEED_MSK_50GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_50GB
 	u16			lp_auto_link_speeds;
-	u16			auto_link_speed;
 	u16			force_link_speed;
 	u32			preemphasis;
 
@@ -940,6 +939,7 @@ struct bnxt {
 
 	u32			msg_enable;
 
+	u32			hwrm_spec_code;
 	u16			hwrm_cmd_seq;
 	u32			hwrm_intr_seq_id;
 	void			*hwrm_cmd_resp_addr;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 2e472f6..f103f9b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -728,7 +728,7 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	ethtool_speed = bnxt_fw_to_ethtool_speed(link_info->link_speed);
 	ethtool_cmd_speed_set(cmd, ethtool_speed);
 	if (link_info->transceiver ==
-		PORT_PHY_QCFG_RESP_TRANSCEIVER_TYPE_XCVR_INTERNAL)
+	    PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL)
 		cmd->transceiver = XCVR_INTERNAL;
 	else
 		cmd->transceiver = XCVR_EXTERNAL;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index 98fa81e..b2d8bd3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
index e0aac65..461675c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 4badbed..80f9556 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -104,6 +104,7 @@ struct hwrm_async_event_cmpl {
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_DCB_CONFIG_CHANGE  (0x3UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED (0x4UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE (0x6UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_UNLOAD   (0x10UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_LOAD     (0x11UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD     (0x20UL << 0)
@@ -111,6 +112,7 @@ struct hwrm_async_event_cmpl {
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_FLR		   (0x30UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_MAC_ADDR_CHANGE (0x31UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_VF_COMM_STATUS_CHANGE (0x32UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_CFG_CHANGE      (0x33UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_HWRM_ERROR	   (0xffUL << 0)
 	__le32 event_data2;
 	u8 opaque_v;
@@ -141,6 +143,7 @@ struct hwrm_async_event_cmpl_link_status_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE 0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_DOWN (0x0UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_UP (0x1UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_LAST    HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_LINK_CHANGE_UP
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_MASK 0xeUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_SFT 1
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffff0UL
@@ -195,6 +198,9 @@ struct hwrm_async_event_cmpl_link_speed_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_25GB (0xfaUL << 1)
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_40GB (0x190UL << 1)
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_50GB (0x1f4UL << 1)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_100GB (0x3e8UL << 1)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_10MB (0xffffUL << 1)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_LAST    HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_10MB
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffff0000UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_PORT_ID_SFT 16
 };
@@ -237,6 +243,55 @@ struct hwrm_async_event_cmpl_port_conn_not_allowed {
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_MASK 0xff0000UL
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_SFT 16
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_NONE (0x0UL << 16)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_DISABLETX (0x1UL << 16)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_WARNINGMSG (0x2UL << 16)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_PWRDOWN (0x3UL << 16)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_LAST    HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_PWRDOWN
+};
+
+/* HWRM Asynchronous Event Completion Record for link speed config not allowed (16 bytes) */
+struct hwrm_async_event_cmpl_link_speed_cfg_not_allowed {
+	__le16 type;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_MASK 0x3fUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	__le16 event_id;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
+	__le32 event_data2;
+	u8 opaque_v;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_V 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_OPAQUE_MASK 0xfeUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_OPAQUE_SFT 1
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
+	__le32 event_data1;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_EVENT_DATA1_PORT_ID_MASK 0xffffUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_EVENT_DATA1_PORT_ID_SFT 0
+};
+
+/* HWRM Asynchronous Event Completion Record for link speed configuration change (16 bytes) */
+struct hwrm_async_event_cmpl_link_speed_cfg_change {
+	__le16 type;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_MASK 0x3fUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	__le16 event_id;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_ID_LINK_SPEED_CFG_CHANGE (0x6UL << 0)
+	__le32 event_data2;
+	u8 opaque_v;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_V      0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_OPAQUE_MASK 0xfeUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_OPAQUE_SFT 1
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
+	__le32 event_data1;
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffffUL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_DATA1_PORT_ID_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_DATA1_SUPPORTED_LINK_SPEEDS_CHANGE 0x10000UL
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_DATA1_ILLEGAL_LINK_SPEED_CFG 0x20000UL
 };
 
 /* HWRM Asynchronous Event Completion Record for Function Driver Unload (16 bytes) */
@@ -363,6 +418,47 @@ struct hwrm_async_event_cmpl_vf_mac_addr_change {
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_EVENT_DATA1_VF_ID_SFT 0
 };
 
+/* HWRM Asynchronous Event Completion Record for PF-VF communication status change (16 bytes) */
+struct hwrm_async_event_cmpl_pf_vf_comm_status_change {
+	__le16 type;
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_MASK 0x3fUL
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	__le16 event_id;
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_EVENT_ID_PF_VF_COMM_STATUS_CHANGE (0x32UL << 0)
+	__le32 event_data2;
+	u8 opaque_v;
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_V   0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_OPAQUE_MASK 0xfeUL
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_OPAQUE_SFT 1
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
+	__le32 event_data1;
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_EVENT_DATA1_COMM_ESTABLISHED 0x1UL
+};
+
+/* HWRM Asynchronous Event Completion Record for VF configuration change (16 bytes) */
+struct hwrm_async_event_cmpl_vf_cfg_change {
+	__le16 type;
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_MASK      0x3fUL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_SFT       0
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	__le16 event_id;
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_ID_VF_CFG_CHANGE (0x33UL << 0)
+	__le32 event_data2;
+	u8 opaque_v;
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_V		    0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_OPAQUE_MASK    0xfeUL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_OPAQUE_SFT     1
+	u8 timestamp_lo;
+	__le16 timestamp_hi;
+	__le32 event_data1;
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_DATA1_MTU_CHANGE 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_DATA1_MRU_CHANGE 0x2UL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_DATA1_DFLT_MAC_ADDR_CHANGE 0x4UL
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_DATA1_DFLT_VLAN_CHANGE 0x8UL
+};
+
 /* HWRM Asynchronous Event Completion Record for HWRM Error (16 bytes) */
 struct hwrm_async_event_cmpl_hwrm_error {
 	__le16 type;
@@ -377,6 +473,7 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_WARNING (0x0UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_NONFATAL (0x1UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_FATAL (0x2UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_LAST    HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_FATAL
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_V		    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_OPAQUE_MASK       0xfeUL
@@ -387,12 +484,12 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA1_TIMESTAMP 0x1UL
 };
 
-/* HW Resource Manager Specification 1.0.0 */
+/* HW Resource Manager Specification 1.2.2 */
 #define HWRM_VERSION_MAJOR	1
-#define HWRM_VERSION_MINOR	0
-#define HWRM_VERSION_UPDATE	0
+#define HWRM_VERSION_MINOR	2
+#define HWRM_VERSION_UPDATE	2
 
-#define HWRM_VERSION_STR	"1.0.0"
+#define HWRM_VERSION_STR	"1.2.2"
 /*
  * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
@@ -444,7 +541,7 @@ struct cmd_nums {
 	#define HWRM_FUNC_BUF_RGTR				   (0x1fUL)
 	#define HWRM_PORT_PHY_CFG				   (0x20UL)
 	#define HWRM_PORT_MAC_CFG				   (0x21UL)
-	#define RESERVED2					   (0x22UL)
+	#define HWRM_PORT_TS_QUERY				   (0x22UL)
 	#define HWRM_PORT_QSTATS				   (0x23UL)
 	#define HWRM_PORT_LPBK_QSTATS				   (0x24UL)
 	#define HWRM_PORT_CLR_STATS				   (0x25UL)
@@ -452,6 +549,9 @@ struct cmd_nums {
 	#define HWRM_PORT_PHY_QCFG				   (0x27UL)
 	#define HWRM_PORT_MAC_QCFG				   (0x28UL)
 	#define HWRM_PORT_BLINK_LED				   (0x29UL)
+	#define HWRM_PORT_PHY_QCAPS				   (0x2aUL)
+	#define HWRM_PORT_PHY_I2C_WRITE			   (0x2bUL)
+	#define HWRM_PORT_PHY_I2C_READ				   (0x2cUL)
 	#define HWRM_QUEUE_QPORTCFG				   (0x30UL)
 	#define HWRM_QUEUE_QCFG				   (0x31UL)
 	#define HWRM_QUEUE_CFG					   (0x32UL)
@@ -531,6 +631,7 @@ struct cmd_nums {
 	__le16 unused_0[3];
 };
 
+/* Return Codes (8 bytes) */
 struct ret_codes {
 	__le16 error_code;
 	#define HWRM_ERR_CODE_SUCCESS				   (0x0UL)
@@ -875,10 +976,11 @@ struct hwrm_func_vf_cfg_input {
 	#define FUNC_VF_CFG_REQ_ENABLES_MTU			    0x1UL
 	#define FUNC_VF_CFG_REQ_ENABLES_GUEST_VLAN		    0x2UL
 	#define FUNC_VF_CFG_REQ_ENABLES_ASYNC_EVENT_CR		    0x4UL
+	#define FUNC_VF_CFG_REQ_ENABLES_DFLT_MAC_ADDR		    0x8UL
 	__le16 mtu;
 	__le16 guest_vlan;
 	__le16 async_event_cr;
-	__le16 unused_0[3];
+	u8 dflt_mac_addr[6];
 };
 
 /* Output (16 bytes) */
@@ -917,7 +1019,8 @@ struct hwrm_func_qcaps_output {
 	__le32 flags;
 	#define FUNC_QCAPS_RESP_FLAGS_PUSH_MODE_SUPPORTED	    0x1UL
 	#define FUNC_QCAPS_RESP_FLAGS_GLOBAL_MSIX_AUTOMASKING      0x2UL
-	u8 perm_mac_address[6];
+	#define FUNC_QCAPS_RESP_FLAGS_PTP_SUPPORTED		    0x4UL
+	u8 mac_address[6];
 	__le16 max_rsscos_ctx;
 	__le16 max_cmpl_rings;
 	__le16 max_tx_rings;
@@ -942,6 +1045,67 @@ struct hwrm_func_qcaps_output {
 	u8 valid;
 };
 
+/* hwrm_func_qcfg */
+/* Input (24 bytes) */
+struct hwrm_func_qcfg_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le16 fid;
+	__le16 unused_0[3];
+};
+
+/* Output (72 bytes) */
+struct hwrm_func_qcfg_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le16 fid;
+	__le16 port_id;
+	__le16 vlan;
+	u8 unused_0;
+	u8 unused_1;
+	u8 mac_address[6];
+	__le16 pci_id;
+	__le16 alloc_rsscos_ctx;
+	__le16 alloc_cmpl_rings;
+	__le16 alloc_tx_rings;
+	__le16 alloc_rx_rings;
+	__le16 alloc_l2_ctx;
+	__le16 alloc_vnics;
+	__le16 mtu;
+	__le16 mru;
+	__le16 stat_ctx_id;
+	u8 port_partition_type;
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_SPF		   (0x0UL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_MPFS	   (0x1UL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0	   (0x2UL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5	   (0x3UL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR2_0	   (0x4UL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_UNKNOWN	   (0xffUL << 0)
+	u8 unused_2;
+	__le16 dflt_vnic_id;
+	u8 unused_3;
+	u8 unused_4;
+	__le32 min_bw;
+	__le32 max_bw;
+	u8 evb_mode;
+	#define FUNC_QCFG_RESP_EVB_MODE_NO_EVB			   (0x0UL << 0)
+	#define FUNC_QCFG_RESP_EVB_MODE_VEB			   (0x1UL << 0)
+	#define FUNC_QCFG_RESP_EVB_MODE_VEPA			   (0x2UL << 0)
+	u8 unused_5;
+	__le16 unused_6;
+	__le32 alloc_mcast_filters;
+	__le32 alloc_hw_ring_grps;
+	u8 unused_7;
+	u8 unused_8;
+	u8 unused_9;
+	u8 valid;
+};
+
 /* hwrm_func_cfg */
 /* Input (88 bytes) */
 struct hwrm_func_cfg_input {
@@ -1171,6 +1335,7 @@ struct hwrm_func_drv_rgtr_input {
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_UNKNOWN		   (0x0UL << 0)
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_OTHER		   (0x1UL << 0)
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_MSDOS		   (0xeUL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WINDOWS		   (0x12UL << 0)
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_SOLARIS		   (0x1dUL << 0)
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX		   (0x24UL << 0)
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_FREEBSD		   (0x2aUL << 0)
@@ -1302,6 +1467,7 @@ struct hwrm_func_drv_qver_output {
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_UNKNOWN		   (0x0UL << 0)
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_OTHER		   (0x1UL << 0)
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_MSDOS		   (0xeUL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WINDOWS		   (0x12UL << 0)
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_SOLARIS		   (0x1dUL << 0)
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_LINUX		   (0x24UL << 0)
 	#define FUNC_DRV_QVER_RESP_OS_TYPE_FREEBSD		   (0x2aUL << 0)
@@ -1317,7 +1483,7 @@ struct hwrm_func_drv_qver_output {
 };
 
 /* hwrm_port_phy_cfg */
-/* Input (48 bytes) */
+/* Input (56 bytes) */
 struct hwrm_port_phy_cfg_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -1329,6 +1495,10 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DOWN		    0x2UL
 	#define PORT_PHY_CFG_REQ_FLAGS_FORCE			    0x4UL
 	#define PORT_PHY_CFG_REQ_FLAGS_RESTART_AUTONEG		    0x8UL
+	#define PORT_PHY_CFG_REQ_FLAGS_EEE_ENABLE		    0x10UL
+	#define PORT_PHY_CFG_REQ_FLAGS_EEE_DISABLE		    0x20UL
+	#define PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_ENABLE	    0x40UL
+	#define PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_DISABLE	    0x80UL
 	__le32 enables;
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_MODE		    0x1UL
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_DUPLEX		    0x2UL
@@ -1339,6 +1509,8 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_ENABLES_LPBK			    0x40UL
 	#define PORT_PHY_CFG_REQ_ENABLES_PREEMPHASIS		    0x80UL
 	#define PORT_PHY_CFG_REQ_ENABLES_FORCE_PAUSE		    0x100UL
+	#define PORT_PHY_CFG_REQ_ENABLES_EEE_LINK_SPEED_MASK       0x200UL
+	#define PORT_PHY_CFG_REQ_ENABLES_TX_LPI_TIMER		    0x400UL
 	__le16 port_id;
 	__le16 force_link_speed;
 	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100MB	   (0x1UL << 0)
@@ -1350,12 +1522,14 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_25GB		   (0xfaUL << 0)
 	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_40GB		   (0x190UL << 0)
 	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_50GB		   (0x1f4UL << 0)
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100GB	   (0x3e8UL << 0)
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10MB		   (0xffffUL << 0)
 	u8 auto_mode;
 	#define PORT_PHY_CFG_REQ_AUTO_MODE_NONE		   (0x0UL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_MODE_ALL_SPEEDS		   (0x1UL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_SPEED		   (0x2UL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_OR_BELOW	   (0x3UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_MASK		   (0x4UL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_SPEED_MASK		   (0x4UL << 0)
 	u8 auto_duplex;
 	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_HALF		   (0x0UL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_FULL		   (0x1UL << 0)
@@ -1363,6 +1537,7 @@ struct hwrm_port_phy_cfg_input {
 	u8 auto_pause;
 	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_TX			    0x1UL
 	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_RX			    0x2UL
+	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_AUTONEG_PAUSE	    0x4UL
 	u8 unused_0;
 	__le16 auto_link_speed;
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100MB		   (0x1UL << 0)
@@ -1374,6 +1549,8 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_25GB		   (0xfaUL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_40GB		   (0x190UL << 0)
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB		   (0x1f4UL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100GB		   (0x3e8UL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10MB		   (0xffffUL << 0)
 	__le16 auto_link_speed_mask;
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_100MBHD      0x1UL
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_100MB	    0x2UL
@@ -1386,6 +1563,9 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_25GB	    0x100UL
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_40GB	    0x200UL
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_50GB	    0x400UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_100GB	    0x800UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_10MBHD       0x1000UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_10MB	    0x2000UL
 	u8 wirespeed;
 	#define PORT_PHY_CFG_REQ_WIRESPEED_OFF			   (0x0UL << 0)
 	#define PORT_PHY_CFG_REQ_WIRESPEED_ON			   (0x1UL << 0)
@@ -1398,7 +1578,20 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_FORCE_PAUSE_RX		    0x2UL
 	u8 unused_1;
 	__le32 preemphasis;
-	__le32 unused_2;
+	__le16 eee_link_speed_mask;
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_RSVD1	    0x1UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_100MB	    0x2UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_RSVD2	    0x4UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_1GB	    0x8UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_RSVD3	    0x10UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_RSVD4	    0x20UL
+	#define PORT_PHY_CFG_REQ_EEE_LINK_SPEED_MASK_10GB	    0x40UL
+	u8 unused_2;
+	u8 unused_3;
+	__le32 tx_lpi_timer;
+	__le32 unused_4;
+	#define PORT_PHY_CFG_REQ_TX_LPI_TIMER_MASK		    0xffffffUL
+	#define PORT_PHY_CFG_REQ_TX_LPI_TIMER_SFT		    0
 };
 
 /* Output (16 bytes) */
@@ -1426,7 +1619,7 @@ struct hwrm_port_phy_qcfg_input {
 	__le16 unused_0[3];
 };
 
-/* Output (48 bytes) */
+/* Output (96 bytes) */
 struct hwrm_port_phy_qcfg_output {
 	__le16 error_code;
 	__le16 req_type;
@@ -1447,6 +1640,8 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_LINK_SPEED_25GB		   (0xfaUL << 0)
 	#define PORT_PHY_QCFG_RESP_LINK_SPEED_40GB		   (0x190UL << 0)
 	#define PORT_PHY_QCFG_RESP_LINK_SPEED_50GB		   (0x1f4UL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_100GB		   (0x3e8UL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_10MB		   (0xffffUL << 0)
 	u8 duplex;
 	#define PORT_PHY_QCFG_RESP_DUPLEX_HALF			   (0x0UL << 0)
 	#define PORT_PHY_QCFG_RESP_DUPLEX_FULL			   (0x1UL << 0)
@@ -1465,6 +1660,9 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_25GB		    0x100UL
 	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_40GB		    0x200UL
 	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_50GB		    0x400UL
+	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_100GB	    0x800UL
+	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_10MBHD	    0x1000UL
+	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_10MB		    0x2000UL
 	__le16 force_link_speed;
 	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100MB	   (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_1GB	   (0xaUL << 0)
@@ -1475,15 +1673,18 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_25GB	   (0xfaUL << 0)
 	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_40GB	   (0x190UL << 0)
 	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_50GB	   (0x1f4UL << 0)
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100GB	   (0x3e8UL << 0)
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_10MB	   (0xffffUL << 0)
 	u8 auto_mode;
 	#define PORT_PHY_QCFG_RESP_AUTO_MODE_NONE		   (0x0UL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ALL_SPEEDS	   (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_SPEED		   (0x2UL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_OR_BELOW	   (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_MASK		   (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_SPEED_MASK	   (0x4UL << 0)
 	u8 auto_pause;
 	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_TX		    0x1UL
 	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_RX		    0x2UL
+	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_AUTONEG_PAUSE	    0x4UL
 	__le16 auto_link_speed;
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100MB	   (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_1GB		   (0xaUL << 0)
@@ -1494,6 +1695,8 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_25GB	   (0xfaUL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_40GB	   (0x190UL << 0)
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_50GB	   (0x1f4UL << 0)
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100GB	   (0x3e8UL << 0)
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_10MB	   (0xffffUL << 0)
 	__le16 auto_link_speed_mask;
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_100MBHD    0x1UL
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_100MB      0x2UL
@@ -1506,6 +1709,9 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_25GB       0x100UL
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_40GB       0x200UL
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_50GB       0x400UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_100GB      0x800UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_10MBHD     0x1000UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_10MB       0x2000UL
 	u8 wirespeed;
 	#define PORT_PHY_QCFG_RESP_WIRESPEED_OFF		   (0x0UL << 0)
 	#define PORT_PHY_QCFG_RESP_WIRESPEED_ON		   (0x1UL << 0)
@@ -1516,31 +1722,49 @@ struct hwrm_port_phy_qcfg_output {
 	u8 force_pause;
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_TX		    0x1UL
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_RX		    0x2UL
-	u8 reserved1;
+	u8 module_status;
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NONE		   (0x0UL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_DISABLETX	   (0x1UL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_WARNINGMSG       (0x2UL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_PWRDOWN	   (0x3UL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTINSERTED      (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTAPPLICABLE    (0xffUL << 0)
 	__le32 preemphasis;
 	u8 phy_maj;
 	u8 phy_min;
 	u8 phy_bld;
 	u8 phy_type;
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASECR4		   (0x1UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_UNKNOWN		   (0x0UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASECR		   (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR4		   (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASELR4		   (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASESR4		   (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASELR		   (0x3UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASESR		   (0x4UL << 0)
 	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR2		   (0x5UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKX4		   (0x6UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKX		   (0x6UL << 0)
 	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR		   (0x7UL << 0)
 	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASET		   (0x8UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASETE		   (0x9UL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_SGMIIEXTPHY	   (0xaUL << 0)
 	u8 media_type;
+	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_UNKNOWN		   (0x0UL << 0)
 	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP		   (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_DAC		   (0x2UL << 0)
 	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_FIBRE		   (0x3UL << 0)
-	u8 transceiver_type;
-	#define PORT_PHY_QCFG_RESP_TRANSCEIVER_TYPE_XCVR_INTERNAL (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_TRANSCEIVER_TYPE_XCVR_EXTERNAL (0x2UL << 0)
-	u8 phy_addr;
+	u8 xcvr_pkg_type;
+	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL    (0x1UL << 0)
+	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_EXTERNAL    (0x2UL << 0)
+	u8 eee_config_phy_addr;
 	#define PORT_PHY_QCFG_RESP_PHY_ADDR_MASK		    0x1fUL
 	#define PORT_PHY_QCFG_RESP_PHY_ADDR_SFT		    0
-	u8 unused_2;
+	#define PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_ENABLED	    0x20UL
+	#define PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_ACTIVE	    0x40UL
+	#define PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_TX_LPI	    0x80UL
+	#define PORT_PHY_QCFG_RESP_EEE_CONFIG_MASK		    0xe0UL
+	#define PORT_PHY_QCFG_RESP_EEE_CONFIG_SFT		    5
+	u8 parallel_detect;
+	#define PORT_PHY_QCFG_RESP_PARALLEL_DETECT		    0x1UL
+	#define PORT_PHY_QCFG_RESP_RESERVED_MASK		    0xfeUL
+	#define PORT_PHY_QCFG_RESP_RESERVED_SFT		    1
 	__le16 link_partner_adv_speeds;
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_100MBHD 0x1UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_100MB   0x2UL
@@ -1553,15 +1777,48 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_25GB    0x100UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_40GB    0x200UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_50GB    0x400UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_100GB   0x800UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_10MBHD  0x1000UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_10MB    0x2000UL
 	u8 link_partner_adv_auto_mode;
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_NONE (0x0UL << 0)
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ALL_SPEEDS (0x1UL << 0)
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_SPEED (0x2UL << 0)
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_OR_BELOW (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_MASK (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_SPEED_MASK (0x4UL << 0)
 	u8 link_partner_adv_pause;
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_PAUSE_TX       0x1UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_PAUSE_RX       0x2UL
+	__le16 adv_eee_link_speed_mask;
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_RSVD1   0x1UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_100MB   0x2UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_RSVD2   0x4UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_1GB     0x8UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_RSVD3   0x10UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_RSVD4   0x20UL
+	#define PORT_PHY_QCFG_RESP_ADV_EEE_LINK_SPEED_MASK_10GB    0x40UL
+	__le16 link_partner_adv_eee_link_speed_mask;
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_RSVD1 0x1UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_100MB 0x2UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_RSVD2 0x4UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_1GB 0x8UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_RSVD3 0x10UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_RSVD4 0x20UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_EEE_LINK_SPEED_MASK_10GB 0x40UL
+	__le32 xcvr_identifier_type_tx_lpi_timer;
+	#define PORT_PHY_QCFG_RESP_TX_LPI_TIMER_MASK		    0xffffffUL
+	#define PORT_PHY_QCFG_RESP_TX_LPI_TIMER_SFT		    0
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_MASK       0xff000000UL
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_SFT	    24
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_UNKNOWN   (0x0UL << 24)
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_SFP       (0x3UL << 24)
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFP      (0xcUL << 24)
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFPPLUS  (0xdUL << 24)
+	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFP28    (0x11UL << 24)
+	__le32 unused_1;
+	char phy_vendor_name[16];
+	char phy_vendor_partnumber[16];
+	__le32 unused_2;
 	u8 unused_3;
 	u8 unused_4;
 	u8 unused_5;
@@ -1569,7 +1826,7 @@ struct hwrm_port_phy_qcfg_output {
 };
 
 /* hwrm_port_mac_cfg */
-/* Input (32 bytes) */
+/* Input (40 bytes) */
 struct hwrm_port_mac_cfg_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -1581,6 +1838,10 @@ struct hwrm_port_mac_cfg_input {
 	#define PORT_MAC_CFG_REQ_FLAGS_COS_ASSIGNMENT_ENABLE       0x2UL
 	#define PORT_MAC_CFG_REQ_FLAGS_TUNNEL_PRI2COS_ENABLE       0x4UL
 	#define PORT_MAC_CFG_REQ_FLAGS_IP_DSCP2COS_ENABLE	    0x8UL
+	#define PORT_MAC_CFG_REQ_FLAGS_PTP_RX_TS_CAPTURE_ENABLE    0x10UL
+	#define PORT_MAC_CFG_REQ_FLAGS_PTP_RX_TS_CAPTURE_DISABLE   0x20UL
+	#define PORT_MAC_CFG_REQ_FLAGS_PTP_TX_TS_CAPTURE_ENABLE    0x40UL
+	#define PORT_MAC_CFG_REQ_FLAGS_PTP_TX_TS_CAPTURE_DISABLE   0x80UL
 	__le32 enables;
 	#define PORT_MAC_CFG_REQ_ENABLES_IPG			    0x1UL
 	#define PORT_MAC_CFG_REQ_ENABLES_LPBK			    0x2UL
@@ -1588,6 +1849,8 @@ struct hwrm_port_mac_cfg_input {
 	#define PORT_MAC_CFG_REQ_ENABLES_LCOS_MAP_PRI		    0x8UL
 	#define PORT_MAC_CFG_REQ_ENABLES_TUNNEL_PRI2COS_MAP_PRI    0x10UL
 	#define PORT_MAC_CFG_REQ_ENABLES_DSCP2COS_MAP_PRI	    0x20UL
+	#define PORT_MAC_CFG_REQ_ENABLES_RX_TS_CAPTURE_PTP_MSG_TYPE 0x40UL
+	#define PORT_MAC_CFG_REQ_ENABLES_TX_TS_CAPTURE_PTP_MSG_TYPE 0x80UL
 	__le16 port_id;
 	u8 ipg;
 	u8 lpbk;
@@ -1598,6 +1861,9 @@ struct hwrm_port_mac_cfg_input {
 	u8 lcos_map_pri;
 	u8 tunnel_pri2cos_map_pri;
 	u8 dscp2pri_map_pri;
+	__le16 rx_ts_capture_ptp_msg_type;
+	__le16 tx_ts_capture_ptp_msg_type;
+	__le32 unused_0;
 };
 
 /* Output (16 bytes) */
@@ -1754,7 +2020,79 @@ struct hwrm_port_blink_led_output {
 	u8 valid;
 };
 
-/* hwrm_queue_qportcfg */
+/* hwrm_port_phy_qcaps */
+/* Input (24 bytes) */
+struct hwrm_port_phy_qcaps_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le16 port_id;
+	__le16 unused_0[3];
+};
+
+/* Output (24 bytes) */
+struct hwrm_port_phy_qcaps_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 eee_supported;
+	#define PORT_PHY_QCAPS_RESP_EEE_SUPPORTED		    0x1UL
+	#define PORT_PHY_QCAPS_RESP_RSVD1_MASK			    0xfeUL
+	#define PORT_PHY_QCAPS_RESP_RSVD1_SFT			    1
+	u8 unused_0;
+	__le16 supported_speeds_force_mode;
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_100MBHD 0x1UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_100MB 0x2UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_1GBHD 0x4UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_1GB 0x8UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_2GB 0x10UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_2_5GB 0x20UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_10GB 0x40UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_20GB 0x80UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_25GB 0x100UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_40GB 0x200UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_50GB 0x400UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_100GB 0x800UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_10MBHD 0x1000UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_FORCE_MODE_10MB 0x2000UL
+	__le16 supported_speeds_auto_mode;
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_100MBHD 0x1UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_100MB 0x2UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_1GBHD 0x4UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_1GB 0x8UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_2GB 0x10UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_2_5GB 0x20UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_10GB 0x40UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_20GB 0x80UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_25GB 0x100UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_40GB 0x200UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_50GB 0x400UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_100GB 0x800UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_10MBHD 0x1000UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_AUTO_MODE_10MB 0x2000UL
+	__le16 supported_speeds_eee_mode;
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_RSVD1 0x1UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_100MB 0x2UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_RSVD2 0x4UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_1GB  0x8UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_RSVD3 0x10UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_RSVD4 0x20UL
+	#define PORT_PHY_QCAPS_RESP_SUPPORTED_SPEEDS_EEE_MODE_10GB 0x40UL
+	__le32 tx_lpi_timer_low;
+	#define PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_LOW_MASK	    0xffffffUL
+	#define PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_LOW_SFT	    0
+	#define PORT_PHY_QCAPS_RESP_RSVD2_MASK			    0xff000000UL
+	#define PORT_PHY_QCAPS_RESP_RSVD2_SFT			    24
+	__le32 valid_tx_lpi_timer_high;
+	#define PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_HIGH_MASK	    0xffffffUL
+	#define PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_HIGH_SFT	    0
+	#define PORT_PHY_QCAPS_RESP_VALID_MASK			    0xff000000UL
+	#define PORT_PHY_QCAPS_RESP_VALID_SFT			    24
+};
+
 /* Input (24 bytes) */
 struct hwrm_queue_qportcfg_input {
 	__le16 req_type;
@@ -1766,6 +2104,7 @@ struct hwrm_queue_qportcfg_input {
 	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH			    0x1UL
 	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_LAST    QUEUE_QPORTCFG_REQ_FLAGS_PATH_RX
 	__le16 port_id;
 	__le16 unused_0;
 };
@@ -1838,6 +2177,7 @@ struct hwrm_queue_cfg_input {
 	#define QUEUE_CFG_REQ_FLAGS_PATH			    0x1UL
 	#define QUEUE_CFG_REQ_FLAGS_PATH_TX			   (0x0UL << 0)
 	#define QUEUE_CFG_REQ_FLAGS_PATH_RX			   (0x1UL << 0)
+	#define QUEUE_CFG_REQ_FLAGS_PATH_LAST    QUEUE_CFG_REQ_FLAGS_PATH_RX
 	__le32 enables;
 	#define QUEUE_CFG_REQ_ENABLES_DFLT_LEN			    0x1UL
 	#define QUEUE_CFG_REQ_ENABLES_SERVICE_PROFILE		    0x2UL
@@ -1875,6 +2215,7 @@ struct hwrm_queue_buffers_cfg_input {
 	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH		    0x1UL
 	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_LAST    QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_RX
 	__le32 enables;
 	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_RESERVED		    0x1UL
 	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_SHARED		    0x2UL
@@ -1952,6 +2293,7 @@ struct hwrm_queue_pri2cos_cfg_input {
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH		    0x1UL
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_LAST    QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_RX
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_IVLAN		    0x2UL
 	__le32 enables;
 	u8 port_id;
@@ -2158,6 +2500,8 @@ struct hwrm_vnic_cfg_input {
 	#define VNIC_CFG_REQ_FLAGS_DEFAULT			    0x1UL
 	#define VNIC_CFG_REQ_FLAGS_VLAN_STRIP_MODE		    0x2UL
 	#define VNIC_CFG_REQ_FLAGS_BD_STALL_MODE		    0x4UL
+	#define VNIC_CFG_REQ_FLAGS_ROCE_DUAL_VNIC_MODE		    0x8UL
+	#define VNIC_CFG_REQ_FLAGS_ROCE_ONLY_VNIC_MODE		    0x10UL
 	__le32 enables;
 	#define VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP		    0x1UL
 	#define VNIC_CFG_REQ_ENABLES_RSS_RULE			    0x2UL
@@ -2622,6 +2966,7 @@ struct hwrm_cfa_l2_filter_alloc_input {
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH		    0x1UL
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_LAST    CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_LOOPBACK		    0x2UL
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_DROP		    0x4UL
 	#define CFA_L2_FILTER_ALLOC_REQ_FLAGS_OUTERMOST	    0x8UL
@@ -2747,6 +3092,7 @@ struct hwrm_cfa_l2_filter_cfg_input {
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_PATH		    0x1UL
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define CFA_L2_FILTER_CFG_REQ_FLAGS_PATH_LAST    CFA_L2_FILTER_CFG_REQ_FLAGS_PATH_RX
 	#define CFA_L2_FILTER_CFG_REQ_FLAGS_DROP		    0x2UL
 	__le32 enables;
 	#define CFA_L2_FILTER_CFG_REQ_ENABLES_DST_ID		    0x1UL
@@ -3337,6 +3683,41 @@ struct hwrm_fw_reset_output {
 	u8 valid;
 };
 
+/* hwrm_fw_qstatus */
+/* Input (24 bytes) */
+struct hwrm_fw_qstatus_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	u8 embedded_proc_type;
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_BOOT		   (0x0UL << 0)
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_MGMT		   (0x1UL << 0)
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   (0x2UL << 0)
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_ROCE		   (0x3UL << 0)
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_RSVD		   (0x4UL << 0)
+	u8 unused_0[7];
+};
+
+/* Output (16 bytes) */
+struct hwrm_fw_qstatus_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 selfrst_status;
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTPCIERST     (0x2UL << 0)
+	u8 unused_0;
+	__le16 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 unused_4;
+	u8 valid;
+};
+
 /* hwrm_exec_fwd_resp */
 /* Input (128 bytes) */
 struct hwrm_exec_fwd_resp_input {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
index 43ef392..40a7b0e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 0c5f510..8457850 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -771,12 +771,8 @@ static int bnxt_vf_set_link(struct bnxt *bp, struct bnxt_vf_info *vf)
 			    PORT_PHY_QCFG_RESP_LINK_NO_LINK) {
 				phy_qcfg_resp.link =
 					PORT_PHY_QCFG_RESP_LINK_LINK;
-				if (phy_qcfg_resp.auto_link_speed)
-					phy_qcfg_resp.link_speed =
-						phy_qcfg_resp.auto_link_speed;
-				else
-					phy_qcfg_resp.link_speed =
-						phy_qcfg_resp.force_link_speed;
+				phy_qcfg_resp.link_speed = cpu_to_le16(
+					PORT_PHY_QCFG_RESP_LINK_SPEED_10GB);
 				phy_qcfg_resp.duplex =
 					PORT_PHY_QCFG_RESP_DUPLEX_FULL;
 				phy_qcfg_resp.pause =
@@ -859,8 +855,8 @@ void bnxt_update_vf_mac(struct bnxt *bp)
 	 *    default but the stored zero MAC will allow the VF user to change
 	 *    the random MAC address using ndo_set_mac_address() if he wants.
 	 */
-	if (!ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
-		memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
+	if (!ether_addr_equal(resp->mac_address, bp->vf.mac_addr))
+		memcpy(bp->vf.mac_addr, resp->mac_address, ETH_ALEN);
 
 	/* overwrite netdev dev_addr with admin VF MAC */
 	if (is_valid_ether_addr(bp->vf.mac_addr))
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
index c151280..3f08354 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
@@ -1,6 +1,6 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
- * Copyright (c) 2014-2015 Broadcom Corporation
+ * Copyright (c) 2014-2016 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.8.3.1
