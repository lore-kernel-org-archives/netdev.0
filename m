From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/4] bnxt_en: Update firmware interface spec to 1.5.4.
Date: Wed, 16 Nov 2016 21:13:07 -0500
Message-ID: <1479348790-6218-2-git-send-email-michael.chan@broadcom.com>
References: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35254 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbcKQCVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:21:15 -0500
Received: by mail-pg0-f44.google.com with SMTP id p66so85726476pga.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 18:21:14 -0800 (PST)
In-Reply-To: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new FORCE_LINK_DWN bit to shutdown link during close.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  8 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h | 91 +++++++++++++++++++++++++--
 2 files changed, 94 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 27a2dd9..1332577 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5346,7 +5346,7 @@ static int bnxt_hwrm_shutdown_link(struct bnxt *bp)
 		return 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_CFG, -1, -1);
-	req.flags = cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DOWN);
+	req.flags = cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DWN);
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
@@ -5409,6 +5409,12 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 			update_link = true;
 	}
 
+	/* The last close may have shutdown the link, so need to call
+	 * PHY_CFG to bring it back up.
+	 */
+	if (!netif_carrier_ok(bp->dev))
+		update_link = true;
+
 	if (!bnxt_eee_config_ok(bp))
 		update_eee = true;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 04a96cc..0456d5b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -215,6 +215,9 @@ struct hwrm_async_event_cmpl_dcb_config_change {
 	__le16 event_id;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_ID_DCB_CONFIG_CHANGE 0x3UL
 	__le32 event_data2;
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA2_ETS 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA2_PFC 0x2UL
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA2_APP 0x4UL
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_V	    0x1UL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_OPAQUE_MASK 0xfeUL
@@ -224,6 +227,14 @@ struct hwrm_async_event_cmpl_dcb_config_change {
 	__le32 event_data1;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffffUL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_PORT_ID_SFT 0
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_ROCE_PRIORITY_MASK 0xff0000UL
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_ROCE_PRIORITY_SFT 16
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_ROCE_PRIORITY_NONE (0xffUL << 16)
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_ROCE_PRIORITY_LAST    HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_ROCE_PRIORITY_NONE
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_L2_PRIORITY_MASK 0xff000000UL
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_L2_PRIORITY_SFT 24
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_L2_PRIORITY_NONE (0xffUL << 24)
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_L2_PRIORITY_LAST    HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_DATA1_RECOMMEND_L2_PRIORITY_NONE
 };
 
 /* HWRM Asynchronous Event Completion Record for port connection not allowed (16 bytes) */
@@ -485,12 +496,12 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA1_TIMESTAMP 0x1UL
 };
 
-/* HW Resource Manager Specification 1.5.1 */
+/* HW Resource Manager Specification 1.5.4 */
 #define HWRM_VERSION_MAJOR	1
 #define HWRM_VERSION_MINOR	5
-#define HWRM_VERSION_UPDATE	1
+#define HWRM_VERSION_UPDATE	4
 
-#define HWRM_VERSION_STR	"1.5.1"
+#define HWRM_VERSION_STR	"1.5.4"
 /*
  * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
@@ -612,6 +623,9 @@ struct cmd_nums {
 	#define HWRM_FW_QSTATUS				   (0xc1UL)
 	#define HWRM_FW_SET_TIME				   (0xc8UL)
 	#define HWRM_FW_GET_TIME				   (0xc9UL)
+	#define HWRM_FW_SET_STRUCTURED_DATA			   (0xcaUL)
+	#define HWRM_FW_GET_STRUCTURED_DATA			   (0xcbUL)
+	#define HWRM_FW_IPC_MAILBOX				   (0xccUL)
 	#define HWRM_EXEC_FWD_RESP				   (0xd0UL)
 	#define HWRM_REJECT_FWD_RESP				   (0xd1UL)
 	#define HWRM_FWD_RESP					   (0xd2UL)
@@ -626,6 +640,8 @@ struct cmd_nums {
 	#define HWRM_DBG_WRITE_DIRECT				   (0xff12UL)
 	#define HWRM_DBG_WRITE_INDIRECT			   (0xff13UL)
 	#define HWRM_DBG_DUMP					   (0xff14UL)
+	#define HWRM_NVM_GET_VARIABLE				   (0xfff1UL)
+	#define HWRM_NVM_SET_VARIABLE				   (0xfff2UL)
 	#define HWRM_NVM_INSTALL_UPDATE			   (0xfff3UL)
 	#define HWRM_NVM_MODIFY				   (0xfff4UL)
 	#define HWRM_NVM_VERIFY_UPDATE				   (0xfff5UL)
@@ -1399,6 +1415,7 @@ struct hwrm_func_drv_rgtr_input {
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_ESXI			   0x68UL
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN864		   0x73UL
 	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN2012R2		   0x74UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_UEFI			   0x8000UL
 	u8 ver_maj;
 	u8 ver_min;
 	u8 ver_upd;
@@ -1549,7 +1566,7 @@ struct hwrm_port_phy_cfg_input {
 	__le64 resp_addr;
 	__le32 flags;
 	#define PORT_PHY_CFG_REQ_FLAGS_RESET_PHY		    0x1UL
-	#define PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DOWN		    0x2UL
+	#define PORT_PHY_CFG_REQ_FLAGS_DEPRECATED		    0x2UL
 	#define PORT_PHY_CFG_REQ_FLAGS_FORCE			    0x4UL
 	#define PORT_PHY_CFG_REQ_FLAGS_RESTART_AUTONEG		    0x8UL
 	#define PORT_PHY_CFG_REQ_FLAGS_EEE_ENABLE		    0x10UL
@@ -1562,6 +1579,7 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE74_DISABLE	    0x800UL
 	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE91_ENABLE	    0x1000UL
 	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE91_DISABLE	    0x2000UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DWN		    0x4000UL
 	__le32 enables;
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_MODE		    0x1UL
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_DUPLEX		    0x2UL
@@ -4023,6 +4041,71 @@ struct hwrm_fw_set_time_output {
 	u8 valid;
 };
 
+/* hwrm_fw_set_structured_data */
+/* Input (32 bytes) */
+struct hwrm_fw_set_structured_data_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le64 src_data_addr;
+	__le16 data_len;
+	u8 hdr_cnt;
+	u8 unused_0[5];
+};
+
+/* Output (16 bytes) */
+struct hwrm_fw_set_structured_data_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
+/* hwrm_fw_get_structured_data */
+/* Input (32 bytes) */
+struct hwrm_fw_get_structured_data_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le64 dest_data_addr;
+	__le16 data_len;
+	__le16 structure_id;
+	__le16 subtype;
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_ALL		   0xffffUL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NEAR_BRIDGE_ADMIN 0x100UL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NEAR_BRIDGE_PEER 0x101UL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NEAR_BRIDGE_OPERATIONAL 0x102UL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NON_TPMR_ADMIN 0x200UL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NON_TPMR_PEER  0x201UL
+	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NON_TPMR_OPERATIONAL 0x202UL
+	u8 count;
+	u8 unused_0;
+};
+
+/* Output (16 bytes) */
+struct hwrm_fw_get_structured_data_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 hdr_cnt;
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
-- 
1.8.3.1
