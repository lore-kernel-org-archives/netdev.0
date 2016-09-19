From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/10] bnxt_en: Update to firmware interface spec 1.5.1.
Date: Mon, 19 Sep 2016 03:58:02 -0400
Message-ID: <1474271889-8229-4-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36267 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760095AbcISH62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:28 -0400
Received: by mail-pf0-f174.google.com with SMTP id q2so28220933pfj.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:27 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |    3 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |   14 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h | 1251 +++++++++++++++----------
 3 files changed, 760 insertions(+), 508 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d9b4cd1..f6b4f34 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4253,6 +4253,9 @@ static int bnxt_hwrm_queue_qportcfg(struct bnxt *bp)
 	if (bp->max_tc > BNXT_MAX_QUEUE)
 		bp->max_tc = BNXT_MAX_QUEUE;
 
+	if (resp->queue_cfg_info & QUEUE_QPORTCFG_RESP_QUEUE_CFG_INFO_ASYM_CFG)
+		bp->max_tc = 1;
+
 	qptr = &resp->queue_id0;
 	for (i = 0; i < bp->max_tc; i++) {
 		bp->q_info[i].queue_id = *qptr++;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index db4814e..012cc51 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -11,10 +11,10 @@
 #define BNXT_H
 
 #define DRV_MODULE_NAME		"bnxt_en"
-#define DRV_MODULE_VERSION	"1.3.0"
+#define DRV_MODULE_VERSION	"1.5.0"
 
 #define DRV_VER_MAJ	1
-#define DRV_VER_MIN	3
+#define DRV_VER_MIN	5
 #define DRV_VER_UPD	0
 
 struct tx_bd {
@@ -106,11 +106,11 @@ struct tx_cmp {
 	 #define CMP_TYPE_REMOTE_DRIVER_REQ			 34
 	 #define CMP_TYPE_REMOTE_DRIVER_RESP			 36
 	 #define CMP_TYPE_ERROR_STATUS				 48
-	 #define CMPL_BASE_TYPE_STAT_EJECT			 (0x1aUL << 0)
-	 #define CMPL_BASE_TYPE_HWRM_DONE			 (0x20UL << 0)
-	 #define CMPL_BASE_TYPE_HWRM_FWD_REQ			 (0x22UL << 0)
-	 #define CMPL_BASE_TYPE_HWRM_FWD_RESP			 (0x24UL << 0)
-	 #define CMPL_BASE_TYPE_HWRM_ASYNC_EVENT		 (0x2eUL << 0)
+	 #define CMPL_BASE_TYPE_STAT_EJECT			 0x1aUL
+	 #define CMPL_BASE_TYPE_HWRM_DONE			 0x20UL
+	 #define CMPL_BASE_TYPE_HWRM_FWD_REQ			 0x22UL
+	 #define CMPL_BASE_TYPE_HWRM_FWD_RESP			 0x24UL
+	 #define CMPL_BASE_TYPE_HWRM_ASYNC_EVENT		 0x2eUL
 
 	#define TX_CMP_FLAGS_ERROR				(1 << 6)
 	#define TX_CMP_FLAGS_PUSH				(1 << 7)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 517567f..04a96cc 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -39,7 +39,7 @@ struct eject_cmpl {
 	__le16 type;
 	#define EJECT_CMPL_TYPE_MASK				    0x3fUL
 	#define EJECT_CMPL_TYPE_SFT				    0
-	#define EJECT_CMPL_TYPE_STAT_EJECT			   (0x1aUL << 0)
+	#define EJECT_CMPL_TYPE_STAT_EJECT			   0x1aUL
 	__le16 len;
 	__le32 opaque;
 	__le32 v;
@@ -52,7 +52,7 @@ struct hwrm_cmpl {
 	__le16 type;
 	#define HWRM_CMPL_TYPE_MASK				    0x3fUL
 	#define HWRM_CMPL_TYPE_SFT				    0
-	#define HWRM_CMPL_TYPE_HWRM_DONE			   (0x20UL << 0)
+	#define HWRM_CMPL_TYPE_HWRM_DONE			   0x20UL
 	__le16 sequence_id;
 	__le32 unused_1;
 	__le32 v;
@@ -65,7 +65,7 @@ struct hwrm_fwd_req_cmpl {
 	__le16 req_len_type;
 	#define HWRM_FWD_REQ_CMPL_TYPE_MASK			    0x3fUL
 	#define HWRM_FWD_REQ_CMPL_TYPE_SFT			    0
-	#define HWRM_FWD_REQ_CMPL_TYPE_HWRM_FWD_REQ		   (0x22UL << 0)
+	#define HWRM_FWD_REQ_CMPL_TYPE_HWRM_FWD_REQ		   0x22UL
 	#define HWRM_FWD_REQ_CMPL_REQ_LEN_MASK			    0xffc0UL
 	#define HWRM_FWD_REQ_CMPL_REQ_LEN_SFT			    6
 	__le16 source_id;
@@ -81,7 +81,7 @@ struct hwrm_fwd_resp_cmpl {
 	__le16 type;
 	#define HWRM_FWD_RESP_CMPL_TYPE_MASK			    0x3fUL
 	#define HWRM_FWD_RESP_CMPL_TYPE_SFT			    0
-	#define HWRM_FWD_RESP_CMPL_TYPE_HWRM_FWD_RESP		   (0x24UL << 0)
+	#define HWRM_FWD_RESP_CMPL_TYPE_HWRM_FWD_RESP		   0x24UL
 	__le16 source_id;
 	__le16 resp_len;
 	__le16 unused_1;
@@ -96,25 +96,26 @@ struct hwrm_async_event_cmpl {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_TYPE_MASK		    0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_TYPE_SFT			    0
-	#define HWRM_ASYNC_EVENT_CMPL_TYPE_HWRM_ASYNC_EVENT       (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_TYPE_HWRM_ASYNC_EVENT       0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE (0x0UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_MTU_CHANGE    (0x1UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CHANGE  (0x2UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_DCB_CONFIG_CHANGE  (0x3UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED (0x4UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE (0x6UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_PHY_CFG_CHANGE (0x7UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_UNLOAD   (0x10UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_LOAD     (0x11UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD     (0x20UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_LOAD       (0x21UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_FLR		   (0x30UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_MAC_ADDR_CHANGE (0x31UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_VF_COMM_STATUS_CHANGE (0x32UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_CFG_CHANGE      (0x33UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_HWRM_ERROR	   (0xffUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE 0x0UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_MTU_CHANGE    0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CHANGE  0x2UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_DCB_CONFIG_CHANGE  0x3UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED 0x4UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED 0x5UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE 0x6UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_PHY_CFG_CHANGE 0x7UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_UNLOAD   0x10UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_LOAD     0x11UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_FLR_PROC_CMPLT 0x12UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD     0x20UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_LOAD       0x21UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_FLR		   0x30UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_MAC_ADDR_CHANGE 0x31UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_VF_COMM_STATUS_CHANGE 0x32UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_CFG_CHANGE      0x33UL
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_HWRM_ERROR	   0xffUL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_V			    0x1UL
@@ -130,9 +131,9 @@ struct hwrm_async_event_cmpl_link_status_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_TYPE_SFT  0
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_ID_LINK_STATUS_CHANGE (0x0UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_EVENT_ID_LINK_STATUS_CHANGE 0x0UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_STATUS_CHANGE_V	    0x1UL
@@ -156,9 +157,9 @@ struct hwrm_async_event_cmpl_link_mtu_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_TYPE_MASK    0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_TYPE_SFT     0
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_EVENT_ID_LINK_MTU_CHANGE (0x1UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_EVENT_ID_LINK_MTU_CHANGE 0x1UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_MTU_CHANGE_V	    0x1UL
@@ -176,9 +177,9 @@ struct hwrm_async_event_cmpl_link_speed_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_TYPE_MASK  0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_TYPE_SFT   0
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_ID_LINK_SPEED_CHANGE (0x2UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_ID_LINK_SPEED_CHANGE 0x2UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_V	    0x1UL
@@ -200,8 +201,7 @@ struct hwrm_async_event_cmpl_link_speed_change {
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_40GB (0x190UL << 1)
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_50GB (0x1f4UL << 1)
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_100GB (0x3e8UL << 1)
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_10MB (0xffffUL << 1)
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_LAST    HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_10MB
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_LAST    HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_NEW_LINK_SPEED_100MBPS_100GB
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_PORT_ID_MASK 0xffff0000UL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CHANGE_EVENT_DATA1_PORT_ID_SFT 16
 };
@@ -211,9 +211,9 @@ struct hwrm_async_event_cmpl_dcb_config_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_TYPE_MASK  0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_TYPE_SFT   0
-	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_ID_DCB_CONFIG_CHANGE (0x3UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_EVENT_ID_DCB_CONFIG_CHANGE 0x3UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_DCB_CONFIG_CHANGE_V	    0x1UL
@@ -231,9 +231,9 @@ struct hwrm_async_event_cmpl_port_conn_not_allowed {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_TYPE_SFT 0
-	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_ID_PORT_CONN_NOT_ALLOWED (0x4UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_ID_PORT_CONN_NOT_ALLOWED 0x4UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_V      0x1UL
@@ -258,9 +258,9 @@ struct hwrm_async_event_cmpl_link_speed_cfg_not_allowed {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_SFT 0
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED 0x5UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_NOT_ALLOWED_V 0x1UL
@@ -278,9 +278,9 @@ struct hwrm_async_event_cmpl_link_speed_cfg_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_SFT 0
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_ID_LINK_SPEED_CFG_CHANGE (0x6UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_EVENT_ID_LINK_SPEED_CFG_CHANGE 0x6UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_LINK_SPEED_CFG_CHANGE_V      0x1UL
@@ -300,9 +300,9 @@ struct hwrm_async_event_cmpl_func_drvr_unload {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_TYPE_MASK   0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_TYPE_SFT    0
-	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_EVENT_ID_FUNC_DRVR_UNLOAD (0x10UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_EVENT_ID_FUNC_DRVR_UNLOAD 0x10UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_UNLOAD_V	    0x1UL
@@ -320,9 +320,9 @@ struct hwrm_async_event_cmpl_func_drvr_load {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_TYPE_MASK     0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_TYPE_SFT      0
-	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_EVENT_ID_FUNC_DRVR_LOAD (0x11UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_EVENT_ID_FUNC_DRVR_LOAD 0x11UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_FUNC_DRVR_LOAD_V		    0x1UL
@@ -340,9 +340,9 @@ struct hwrm_async_event_cmpl_pf_drvr_unload {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_TYPE_MASK     0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_TYPE_SFT      0
-	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_ID_PF_DRVR_UNLOAD (0x20UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_EVENT_ID_PF_DRVR_UNLOAD 0x20UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_UNLOAD_V		    0x1UL
@@ -362,9 +362,9 @@ struct hwrm_async_event_cmpl_pf_drvr_load {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_MASK       0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_SFT	    0
-	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_ID_PF_DRVR_LOAD (0x21UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_EVENT_ID_PF_DRVR_LOAD 0x21UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_DRVR_LOAD_V		    0x1UL
@@ -384,9 +384,9 @@ struct hwrm_async_event_cmpl_vf_flr {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_TYPE_MASK		    0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_TYPE_SFT		    0
-	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_EVENT_ID_VF_FLR      (0x30UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_EVENT_ID_VF_FLR      0x30UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_FLR_V			    0x1UL
@@ -404,9 +404,9 @@ struct hwrm_async_event_cmpl_vf_mac_addr_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_TYPE_SFT  0
-	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_EVENT_ID_VF_MAC_ADDR_CHANGE (0x31UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_EVENT_ID_VF_MAC_ADDR_CHANGE 0x31UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_MAC_ADDR_CHANGE_V	    0x1UL
@@ -424,9 +424,9 @@ struct hwrm_async_event_cmpl_pf_vf_comm_status_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_MASK 0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_SFT 0
-	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_EVENT_ID_PF_VF_COMM_STATUS_CHANGE (0x32UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_EVENT_ID_PF_VF_COMM_STATUS_CHANGE 0x32UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_PF_VF_COMM_STATUS_CHANGE_V   0x1UL
@@ -443,9 +443,9 @@ struct hwrm_async_event_cmpl_vf_cfg_change {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_MASK      0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_SFT       0
-	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_ID_VF_CFG_CHANGE (0x33UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_EVENT_ID_VF_CFG_CHANGE 0x33UL
 	__le32 event_data2;
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_VF_CFG_CHANGE_V		    0x1UL
@@ -465,15 +465,15 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	__le16 type;
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_TYPE_MASK	    0x3fUL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_TYPE_SFT	    0
-	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_TYPE_HWRM_ASYNC_EVENT (0x2eUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_TYPE_HWRM_ASYNC_EVENT 0x2eUL
 	__le16 event_id;
-	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_ID_HWRM_ERROR (0xffUL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_ID_HWRM_ERROR 0xffUL
 	__le32 event_data2;
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_MASK 0xffUL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_SFT 0
-	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_WARNING (0x0UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_NONFATAL (0x1UL << 0)
-	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_FATAL (0x2UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_WARNING 0x0UL
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_NONFATAL 0x1UL
+	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_FATAL 0x2UL
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_LAST    HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA2_SEVERITY_FATAL
 	u8 opaque_v;
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_V		    0x1UL
@@ -485,12 +485,12 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA1_TIMESTAMP 0x1UL
 };
 
-/* HW Resource Manager Specification 1.3.0 */
+/* HW Resource Manager Specification 1.5.1 */
 #define HWRM_VERSION_MAJOR	1
-#define HWRM_VERSION_MINOR	3
-#define HWRM_VERSION_UPDATE	0
+#define HWRM_VERSION_MINOR	5
+#define HWRM_VERSION_UPDATE	1
 
-#define HWRM_VERSION_STR	"1.3.0"
+#define HWRM_VERSION_STR	"1.5.1"
 /*
  * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
@@ -556,8 +556,8 @@ struct cmd_nums {
 	#define HWRM_QUEUE_QPORTCFG				   (0x30UL)
 	#define HWRM_QUEUE_QCFG				   (0x31UL)
 	#define HWRM_QUEUE_CFG					   (0x32UL)
-	#define HWRM_QUEUE_BUFFERS_QCFG			   (0x33UL)
-	#define HWRM_QUEUE_BUFFERS_CFG				   (0x34UL)
+	#define RESERVED2					   (0x33UL)
+	#define RESERVED3					   (0x34UL)
 	#define HWRM_QUEUE_PFCENABLE_QCFG			   (0x35UL)
 	#define HWRM_QUEUE_PFCENABLE_CFG			   (0x36UL)
 	#define HWRM_QUEUE_PRI2COS_QCFG			   (0x37UL)
@@ -574,6 +574,7 @@ struct cmd_nums {
 	#define HWRM_VNIC_RSS_QCFG				   (0x47UL)
 	#define HWRM_VNIC_PLCMODES_CFG				   (0x48UL)
 	#define HWRM_VNIC_PLCMODES_QCFG			   (0x49UL)
+	#define HWRM_VNIC_QCAPS				   (0x4aUL)
 	#define HWRM_RING_ALLOC				   (0x50UL)
 	#define HWRM_RING_FREE					   (0x51UL)
 	#define HWRM_RING_CMPL_RING_QAGGINT_PARAMS		   (0x52UL)
@@ -581,13 +582,15 @@ struct cmd_nums {
 	#define HWRM_RING_RESET				   (0x5eUL)
 	#define HWRM_RING_GRP_ALLOC				   (0x60UL)
 	#define HWRM_RING_GRP_FREE				   (0x61UL)
+	#define RESERVED5					   (0x64UL)
+	#define RESERVED6					   (0x65UL)
 	#define HWRM_VNIC_RSS_COS_LB_CTX_ALLOC			   (0x70UL)
 	#define HWRM_VNIC_RSS_COS_LB_CTX_FREE			   (0x71UL)
 	#define HWRM_CFA_L2_FILTER_ALLOC			   (0x90UL)
 	#define HWRM_CFA_L2_FILTER_FREE			   (0x91UL)
 	#define HWRM_CFA_L2_FILTER_CFG				   (0x92UL)
 	#define HWRM_CFA_L2_SET_RX_MASK			   (0x93UL)
-	#define RESERVED3					   (0x94UL)
+	#define RESERVED4					   (0x94UL)
 	#define HWRM_CFA_TUNNEL_FILTER_ALLOC			   (0x95UL)
 	#define HWRM_CFA_TUNNEL_FILTER_FREE			   (0x96UL)
 	#define HWRM_CFA_ENCAP_RECORD_ALLOC			   (0x97UL)
@@ -607,6 +610,8 @@ struct cmd_nums {
 	#define HWRM_STAT_CTX_CLR_STATS			   (0xb3UL)
 	#define HWRM_FW_RESET					   (0xc0UL)
 	#define HWRM_FW_QSTATUS				   (0xc1UL)
+	#define HWRM_FW_SET_TIME				   (0xc8UL)
+	#define HWRM_FW_GET_TIME				   (0xc9UL)
 	#define HWRM_EXEC_FWD_RESP				   (0xd0UL)
 	#define HWRM_REJECT_FWD_RESP				   (0xd1UL)
 	#define HWRM_FWD_RESP					   (0xd2UL)
@@ -615,11 +620,13 @@ struct cmd_nums {
 	#define HWRM_WOL_FILTER_ALLOC				   (0xf0UL)
 	#define HWRM_WOL_FILTER_FREE				   (0xf1UL)
 	#define HWRM_WOL_FILTER_QCFG				   (0xf2UL)
+	#define HWRM_WOL_REASON_QCFG				   (0xf3UL)
 	#define HWRM_DBG_READ_DIRECT				   (0xff10UL)
 	#define HWRM_DBG_READ_INDIRECT				   (0xff11UL)
 	#define HWRM_DBG_WRITE_DIRECT				   (0xff12UL)
 	#define HWRM_DBG_WRITE_INDIRECT			   (0xff13UL)
 	#define HWRM_DBG_DUMP					   (0xff14UL)
+	#define HWRM_NVM_INSTALL_UPDATE			   (0xfff3UL)
 	#define HWRM_NVM_MODIFY				   (0xfff4UL)
 	#define HWRM_NVM_VERIFY_UPDATE				   (0xfff5UL)
 	#define HWRM_NVM_GET_DEV_INFO				   (0xfff6UL)
@@ -824,7 +831,9 @@ struct hwrm_ver_get_output {
 	u8 netctrl_fw_min;
 	u8 netctrl_fw_bld;
 	u8 netctrl_fw_rsvd;
-	__le32 reserved1;
+	__le32 dev_caps_cfg;
+	#define VER_GET_RESP_DEV_CAPS_CFG_SECURE_FW_UPD_SUPPORTED  0x1UL
+	#define VER_GET_RESP_DEV_CAPS_CFG_FW_DCBX_AGENT_SUPPORTED  0x2UL
 	u8 roce_fw_maj;
 	u8 roce_fw_min;
 	u8 roce_fw_bld;
@@ -839,9 +848,9 @@ struct hwrm_ver_get_output {
 	u8 chip_metal;
 	u8 chip_bond_id;
 	u8 chip_platform_type;
-	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_ASIC		   (0x0UL << 0)
-	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_FPGA		   (0x1UL << 0)
-	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_PALLADIUM	   (0x2UL << 0)
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_ASIC		   0x0UL
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_FPGA		   0x1UL
+	#define VER_GET_RESP_CHIP_PLATFORM_TYPE_PALLADIUM	   0x2UL
 	__le16 max_req_win_len;
 	__le16 max_resp_len;
 	__le16 def_req_timeout;
@@ -863,10 +872,10 @@ struct hwrm_func_reset_input {
 	#define FUNC_RESET_REQ_ENABLES_VF_ID_VALID		    0x1UL
 	__le16 vf_id;
 	u8 func_reset_level;
-	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETALL	   (0x0UL << 0)
-	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETME	   (0x1UL << 0)
-	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETCHILDREN     (0x2UL << 0)
-	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETVF	   (0x3UL << 0)
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETALL	   0x0UL
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETME	   0x1UL
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETCHILDREN     0x2UL
+	#define FUNC_RESET_REQ_FUNC_RESET_LEVEL_RESETVF	   0x3UL
 	u8 unused_0;
 };
 
@@ -1028,6 +1037,10 @@ struct hwrm_func_qcaps_output {
 	#define FUNC_QCAPS_RESP_FLAGS_ROCE_V2_SUPPORTED	    0x10UL
 	#define FUNC_QCAPS_RESP_FLAGS_WOL_MAGICPKT_SUPPORTED       0x20UL
 	#define FUNC_QCAPS_RESP_FLAGS_WOL_BMP_SUPPORTED	    0x40UL
+	#define FUNC_QCAPS_RESP_FLAGS_TX_RING_RL_SUPPORTED	    0x80UL
+	#define FUNC_QCAPS_RESP_FLAGS_TX_BW_CFG_SUPPORTED	    0x100UL
+	#define FUNC_QCAPS_RESP_FLAGS_VF_TX_RING_RL_SUPPORTED      0x200UL
+	#define FUNC_QCAPS_RESP_FLAGS_VF_BW_CFG_SUPPORTED	    0x400UL
 	u8 mac_address[6];
 	__le16 max_rsscos_ctx;
 	__le16 max_cmpl_rings;
@@ -1047,9 +1060,8 @@ struct hwrm_func_qcaps_output {
 	__le32 max_mcast_filters;
 	__le32 max_flow_id;
 	__le32 max_hw_ring_grps;
+	__le16 max_sp_tx_rings;
 	u8 unused_0;
-	u8 unused_1;
-	u8 unused_2;
 	u8 valid;
 };
 
@@ -1077,6 +1089,7 @@ struct hwrm_func_qcfg_output {
 	__le16 flags;
 	#define FUNC_QCFG_RESP_FLAGS_OOB_WOL_MAGICPKT_ENABLED      0x1UL
 	#define FUNC_QCFG_RESP_FLAGS_OOB_WOL_BMP_ENABLED	    0x2UL
+	#define FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED	    0x4UL
 	u8 mac_address[6];
 	__le16 pci_id;
 	__le16 alloc_rsscos_ctx;
@@ -1089,29 +1102,46 @@ struct hwrm_func_qcfg_output {
 	__le16 mru;
 	__le16 stat_ctx_id;
 	u8 port_partition_type;
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_SPF		   (0x0UL << 0)
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_MPFS	   (0x1UL << 0)
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0	   (0x2UL << 0)
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5	   (0x3UL << 0)
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR2_0	   (0x4UL << 0)
-	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_UNKNOWN	   (0xffUL << 0)
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_SPF		   0x0UL
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_MPFS	   0x1UL
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0	   0x2UL
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5	   0x3UL
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR2_0	   0x4UL
+	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_UNKNOWN	   0xffUL
 	u8 unused_0;
 	__le16 dflt_vnic_id;
 	u8 unused_1;
 	u8 unused_2;
 	__le32 min_bw;
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_MASK		    0xfffffffUL
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_SFT		    0
+	#define FUNC_QCFG_RESP_MIN_BW_RSVD			    0x10000000UL
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_MASK	    0xe0000000UL
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_SFT	    29
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_MBPS	   (0x0UL << 29)
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_PERCENT1_100  (0x1UL << 29)
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_INVALID       (0x7UL << 29)
+	#define FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_LAST    FUNC_QCFG_RESP_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 max_bw;
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_MASK		    0xfffffffUL
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_SFT		    0
+	#define FUNC_QCFG_RESP_MAX_BW_RSVD			    0x10000000UL
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_MASK	    0xe0000000UL
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_SFT	    29
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_MBPS	   (0x0UL << 29)
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_PERCENT1_100  (0x1UL << 29)
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_INVALID       (0x7UL << 29)
+	#define FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_LAST    FUNC_QCFG_RESP_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 evb_mode;
-	#define FUNC_QCFG_RESP_EVB_MODE_NO_EVB			   (0x0UL << 0)
-	#define FUNC_QCFG_RESP_EVB_MODE_VEB			   (0x1UL << 0)
-	#define FUNC_QCFG_RESP_EVB_MODE_VEPA			   (0x2UL << 0)
+	#define FUNC_QCFG_RESP_EVB_MODE_NO_EVB			   0x0UL
+	#define FUNC_QCFG_RESP_EVB_MODE_VEB			   0x1UL
+	#define FUNC_QCFG_RESP_EVB_MODE_VEPA			   0x2UL
 	u8 unused_3;
-	__le16 unused_4;
+	__le16 alloc_vfs;
 	__le32 alloc_mcast_filters;
 	__le32 alloc_hw_ring_grps;
-	u8 unused_5;
-	u8 unused_6;
-	u8 unused_7;
+	__le16 alloc_sp_tx_rings;
+	u8 unused_4;
 	u8 valid;
 };
 
@@ -1171,18 +1201,36 @@ struct hwrm_func_cfg_input {
 	__le16 dflt_vlan;
 	__be32 dflt_ip_addr[4];
 	__le32 min_bw;
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_MASK		    0xfffffffUL
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_SFT		    0
+	#define FUNC_CFG_REQ_MIN_BW_RSVD			    0x10000000UL
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_MASK		    0xe0000000UL
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_SFT		    29
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_MBPS		   (0x0UL << 29)
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_PERCENT1_100    (0x1UL << 29)
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_INVALID	   (0x7UL << 29)
+	#define FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_LAST    FUNC_CFG_REQ_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 max_bw;
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_MASK		    0xfffffffUL
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_SFT		    0
+	#define FUNC_CFG_REQ_MAX_BW_RSVD			    0x10000000UL
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_MASK		    0xe0000000UL
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_SFT		    29
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_MBPS		   (0x0UL << 29)
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_PERCENT1_100    (0x1UL << 29)
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_INVALID	   (0x7UL << 29)
+	#define FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_LAST    FUNC_CFG_REQ_MAX_BW_BW_VALUE_UNIT_INVALID
 	__le16 async_event_cr;
 	u8 vlan_antispoof_mode;
-	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_NOCHECK	   (0x0UL << 0)
-	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_VALIDATE_VLAN    (0x1UL << 0)
-	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_IF_VLANDNE (0x2UL << 0)
-	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_OR_OVERRIDE_VLAN (0x3UL << 0)
+	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_NOCHECK	   0x0UL
+	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_VALIDATE_VLAN    0x1UL
+	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_IF_VLANDNE 0x2UL
+	#define FUNC_CFG_REQ_VLAN_ANTISPOOF_MODE_INSERT_OR_OVERRIDE_VLAN 0x3UL
 	u8 allowed_vlan_pris;
 	u8 evb_mode;
-	#define FUNC_CFG_REQ_EVB_MODE_NO_EVB			   (0x0UL << 0)
-	#define FUNC_CFG_REQ_EVB_MODE_VEB			   (0x1UL << 0)
-	#define FUNC_CFG_REQ_EVB_MODE_VEPA			   (0x2UL << 0)
+	#define FUNC_CFG_REQ_EVB_MODE_NO_EVB			   0x0UL
+	#define FUNC_CFG_REQ_EVB_MODE_VEB			   0x1UL
+	#define FUNC_CFG_REQ_EVB_MODE_VEPA			   0x2UL
 	u8 unused_2;
 	__le16 num_mcast_filters;
 };
@@ -1341,16 +1389,16 @@ struct hwrm_func_drv_rgtr_input {
 	#define FUNC_DRV_RGTR_REQ_ENABLES_VF_REQ_FWD		    0x8UL
 	#define FUNC_DRV_RGTR_REQ_ENABLES_ASYNC_EVENT_FWD	    0x10UL
 	__le16 os_type;
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_UNKNOWN		   (0x0UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_OTHER		   (0x1UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_MSDOS		   (0xeUL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WINDOWS		   (0x12UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_SOLARIS		   (0x1dUL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX		   (0x24UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_FREEBSD		   (0x2aUL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_ESXI			   (0x68UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN864		   (0x73UL << 0)
-	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN2012R2		   (0x74UL << 0)
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_UNKNOWN		   0x0UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_OTHER		   0x1UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_MSDOS		   0xeUL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WINDOWS		   0x12UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_SOLARIS		   0x1dUL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX		   0x24UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_FREEBSD		   0x2aUL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_ESXI			   0x68UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN864		   0x73UL
+	#define FUNC_DRV_RGTR_REQ_OS_TYPE_WIN2012R2		   0x74UL
 	u8 ver_maj;
 	u8 ver_min;
 	u8 ver_upd;
@@ -1415,13 +1463,13 @@ struct hwrm_func_buf_rgtr_input {
 	__le16 vf_id;
 	__le16 req_buf_num_pages;
 	__le16 req_buf_page_size;
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_16B	   (0x4UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4K		   (0xcUL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_8K		   (0xdUL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_64K	   (0x10UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_2M		   (0x15UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4M		   (0x16UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_1G		   (0x1eUL << 0)
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_16B	   0x4UL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4K		   0xcUL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_8K		   0xdUL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_64K	   0x10UL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_2M		   0x15UL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4M		   0x16UL
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_1G		   0x1eUL
 	__le16 req_buf_len;
 	__le16 resp_buf_len;
 	u8 unused_0;
@@ -1473,16 +1521,16 @@ struct hwrm_func_drv_qver_output {
 	__le16 seq_id;
 	__le16 resp_len;
 	__le16 os_type;
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_UNKNOWN		   (0x0UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_OTHER		   (0x1UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_MSDOS		   (0xeUL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_WINDOWS		   (0x12UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_SOLARIS		   (0x1dUL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_LINUX		   (0x24UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_FREEBSD		   (0x2aUL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_ESXI		   (0x68UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN864		   (0x73UL << 0)
-	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN2012R2		   (0x74UL << 0)
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_UNKNOWN		   0x0UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_OTHER		   0x1UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_MSDOS		   0xeUL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WINDOWS		   0x12UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_SOLARIS		   0x1dUL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_LINUX		   0x24UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_FREEBSD		   0x2aUL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_ESXI		   0x68UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN864		   0x73UL
+	#define FUNC_DRV_QVER_RESP_OS_TYPE_WIN2012R2		   0x74UL
 	u8 ver_maj;
 	u8 ver_min;
 	u8 ver_upd;
@@ -1528,44 +1576,44 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_ENABLES_TX_LPI_TIMER		    0x400UL
 	__le16 port_id;
 	__le16 force_link_speed;
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100MB	   (0x1UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_1GB		   (0xaUL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_2GB		   (0x14UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_2_5GB	   (0x19UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10GB		   (0x64UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_20GB		   (0xc8UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_25GB		   (0xfaUL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_40GB		   (0x190UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_50GB		   (0x1f4UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100GB	   (0x3e8UL << 0)
-	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10MB		   (0xffffUL << 0)
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100MB	   0x1UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_1GB		   0xaUL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_2GB		   0x14UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_2_5GB	   0x19UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10GB		   0x64UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_20GB		   0xc8UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_25GB		   0xfaUL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_40GB		   0x190UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_50GB		   0x1f4UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_100GB	   0x3e8UL
+	#define PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10MB		   0xffffUL
 	u8 auto_mode;
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_NONE		   (0x0UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_ALL_SPEEDS		   (0x1UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_SPEED		   (0x2UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_OR_BELOW	   (0x3UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_MODE_SPEED_MASK		   (0x4UL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_NONE		   0x0UL
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_ALL_SPEEDS		   0x1UL
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_SPEED		   0x2UL
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_ONE_OR_BELOW	   0x3UL
+	#define PORT_PHY_CFG_REQ_AUTO_MODE_SPEED_MASK		   0x4UL
 	u8 auto_duplex;
-	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_HALF		   (0x0UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_FULL		   (0x1UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_BOTH		   (0x2UL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_HALF		   0x0UL
+	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_FULL		   0x1UL
+	#define PORT_PHY_CFG_REQ_AUTO_DUPLEX_BOTH		   0x2UL
 	u8 auto_pause;
 	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_TX			    0x1UL
 	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_RX			    0x2UL
 	#define PORT_PHY_CFG_REQ_AUTO_PAUSE_AUTONEG_PAUSE	    0x4UL
 	u8 unused_0;
 	__le16 auto_link_speed;
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100MB		   (0x1UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_1GB		   (0xaUL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2GB		   (0x14UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2_5GB		   (0x19UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10GB		   (0x64UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_20GB		   (0xc8UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_25GB		   (0xfaUL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_40GB		   (0x190UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB		   (0x1f4UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100GB		   (0x3e8UL << 0)
-	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10MB		   (0xffffUL << 0)
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100MB		   0x1UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_1GB		   0xaUL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2GB		   0x14UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2_5GB		   0x19UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10GB		   0x64UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_20GB		   0xc8UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_25GB		   0xfaUL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_40GB		   0x190UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB		   0x1f4UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100GB		   0x3e8UL
+	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10MB		   0xffffUL
 	__le16 auto_link_speed_mask;
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_100MBHD      0x1UL
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_100MB	    0x2UL
@@ -1582,12 +1630,12 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_10MBHD       0x1000UL
 	#define PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_MASK_10MB	    0x2000UL
 	u8 wirespeed;
-	#define PORT_PHY_CFG_REQ_WIRESPEED_OFF			   (0x0UL << 0)
-	#define PORT_PHY_CFG_REQ_WIRESPEED_ON			   (0x1UL << 0)
+	#define PORT_PHY_CFG_REQ_WIRESPEED_OFF			   0x0UL
+	#define PORT_PHY_CFG_REQ_WIRESPEED_ON			   0x1UL
 	u8 lpbk;
-	#define PORT_PHY_CFG_REQ_LPBK_NONE			   (0x0UL << 0)
-	#define PORT_PHY_CFG_REQ_LPBK_LOCAL			   (0x1UL << 0)
-	#define PORT_PHY_CFG_REQ_LPBK_REMOTE			   (0x2UL << 0)
+	#define PORT_PHY_CFG_REQ_LPBK_NONE			   0x0UL
+	#define PORT_PHY_CFG_REQ_LPBK_LOCAL			   0x1UL
+	#define PORT_PHY_CFG_REQ_LPBK_REMOTE			   0x2UL
 	u8 force_pause;
 	#define PORT_PHY_CFG_REQ_FORCE_PAUSE_TX		    0x1UL
 	#define PORT_PHY_CFG_REQ_FORCE_PAUSE_RX		    0x2UL
@@ -1641,25 +1689,25 @@ struct hwrm_port_phy_qcfg_output {
 	__le16 seq_id;
 	__le16 resp_len;
 	u8 link;
-	#define PORT_PHY_QCFG_RESP_LINK_NO_LINK		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SIGNAL			   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_LINK			   (0x2UL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_NO_LINK		   0x0UL
+	#define PORT_PHY_QCFG_RESP_LINK_SIGNAL			   0x1UL
+	#define PORT_PHY_QCFG_RESP_LINK_LINK			   0x2UL
 	u8 unused_0;
 	__le16 link_speed;
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_100MB		   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_1GB		   (0xaUL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_2GB		   (0x14UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_2_5GB		   (0x19UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_10GB		   (0x64UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_20GB		   (0xc8UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_25GB		   (0xfaUL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_40GB		   (0x190UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_50GB		   (0x1f4UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_100GB		   (0x3e8UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_SPEED_10MB		   (0xffffUL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_100MB		   0x1UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_1GB		   0xaUL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_2GB		   0x14UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_2_5GB		   0x19UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_10GB		   0x64UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_20GB		   0xc8UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_25GB		   0xfaUL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_40GB		   0x190UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_50GB		   0x1f4UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_100GB		   0x3e8UL
+	#define PORT_PHY_QCFG_RESP_LINK_SPEED_10MB		   0xffffUL
 	u8 duplex;
-	#define PORT_PHY_QCFG_RESP_DUPLEX_HALF			   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_DUPLEX_FULL			   (0x1UL << 0)
+	#define PORT_PHY_QCFG_RESP_DUPLEX_HALF			   0x0UL
+	#define PORT_PHY_QCFG_RESP_DUPLEX_FULL			   0x1UL
 	u8 pause;
 	#define PORT_PHY_QCFG_RESP_PAUSE_TX			    0x1UL
 	#define PORT_PHY_QCFG_RESP_PAUSE_RX			    0x2UL
@@ -1679,39 +1727,39 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_10MBHD	    0x1000UL
 	#define PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_10MB		    0x2000UL
 	__le16 force_link_speed;
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100MB	   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_1GB	   (0xaUL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_2GB	   (0x14UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_2_5GB	   (0x19UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_10GB	   (0x64UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_20GB	   (0xc8UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_25GB	   (0xfaUL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_40GB	   (0x190UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_50GB	   (0x1f4UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100GB	   (0x3e8UL << 0)
-	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_10MB	   (0xffffUL << 0)
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100MB	   0x1UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_1GB	   0xaUL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_2GB	   0x14UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_2_5GB	   0x19UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_10GB	   0x64UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_20GB	   0xc8UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_25GB	   0xfaUL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_40GB	   0x190UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_50GB	   0x1f4UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_100GB	   0x3e8UL
+	#define PORT_PHY_QCFG_RESP_FORCE_LINK_SPEED_10MB	   0xffffUL
 	u8 auto_mode;
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_NONE		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ALL_SPEEDS	   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_SPEED		   (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_OR_BELOW	   (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_MODE_SPEED_MASK	   (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_NONE		   0x0UL
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ALL_SPEEDS	   0x1UL
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_SPEED		   0x2UL
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_ONE_OR_BELOW	   0x3UL
+	#define PORT_PHY_QCFG_RESP_AUTO_MODE_SPEED_MASK	   0x4UL
 	u8 auto_pause;
 	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_TX		    0x1UL
 	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_RX		    0x2UL
 	#define PORT_PHY_QCFG_RESP_AUTO_PAUSE_AUTONEG_PAUSE	    0x4UL
 	__le16 auto_link_speed;
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100MB	   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_1GB		   (0xaUL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_2GB		   (0x14UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_2_5GB	   (0x19UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_10GB	   (0x64UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_20GB	   (0xc8UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_25GB	   (0xfaUL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_40GB	   (0x190UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_50GB	   (0x1f4UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100GB	   (0x3e8UL << 0)
-	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_10MB	   (0xffffUL << 0)
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100MB	   0x1UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_1GB		   0xaUL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_2GB		   0x14UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_2_5GB	   0x19UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_10GB	   0x64UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_20GB	   0xc8UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_25GB	   0xfaUL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_40GB	   0x190UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_50GB	   0x1f4UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_100GB	   0x3e8UL
+	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_10MB	   0xffffUL
 	__le16 auto_link_speed_mask;
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_100MBHD    0x1UL
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_100MB      0x2UL
@@ -1728,46 +1776,46 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_10MBHD     0x1000UL
 	#define PORT_PHY_QCFG_RESP_AUTO_LINK_SPEED_MASK_10MB       0x2000UL
 	u8 wirespeed;
-	#define PORT_PHY_QCFG_RESP_WIRESPEED_OFF		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_WIRESPEED_ON		   (0x1UL << 0)
+	#define PORT_PHY_QCFG_RESP_WIRESPEED_OFF		   0x0UL
+	#define PORT_PHY_QCFG_RESP_WIRESPEED_ON		   0x1UL
 	u8 lpbk;
-	#define PORT_PHY_QCFG_RESP_LPBK_NONE			   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_LPBK_LOCAL			   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_LPBK_REMOTE			   (0x2UL << 0)
+	#define PORT_PHY_QCFG_RESP_LPBK_NONE			   0x0UL
+	#define PORT_PHY_QCFG_RESP_LPBK_LOCAL			   0x1UL
+	#define PORT_PHY_QCFG_RESP_LPBK_REMOTE			   0x2UL
 	u8 force_pause;
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_TX		    0x1UL
 	#define PORT_PHY_QCFG_RESP_FORCE_PAUSE_RX		    0x2UL
 	u8 module_status;
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NONE		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_DISABLETX	   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_WARNINGMSG       (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_PWRDOWN	   (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTINSERTED      (0x4UL << 0)
-	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTAPPLICABLE    (0xffUL << 0)
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NONE		   0x0UL
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_DISABLETX	   0x1UL
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_WARNINGMSG       0x2UL
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_PWRDOWN	   0x3UL
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTINSERTED      0x4UL
+	#define PORT_PHY_QCFG_RESP_MODULE_STATUS_NOTAPPLICABLE    0xffUL
 	__le32 preemphasis;
 	u8 phy_maj;
 	u8 phy_min;
 	u8 phy_bld;
 	u8 phy_type;
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_UNKNOWN		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASECR		   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR4		   (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASELR		   (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASESR		   (0x4UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR2		   (0x5UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKX		   (0x6UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR		   (0x7UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASET		   (0x8UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASETE		   (0x9UL << 0)
-	#define PORT_PHY_QCFG_RESP_PHY_TYPE_SGMIIEXTPHY	   (0xaUL << 0)
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_UNKNOWN		   0x0UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASECR		   0x1UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR4		   0x2UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASELR		   0x3UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASESR		   0x4UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR2		   0x5UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKX		   0x6UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASEKR		   0x7UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASET		   0x8UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_BASETE		   0x9UL
+	#define PORT_PHY_QCFG_RESP_PHY_TYPE_SGMIIEXTPHY	   0xaUL
 	u8 media_type;
-	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_UNKNOWN		   (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP		   (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_DAC		   (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_FIBRE		   (0x3UL << 0)
+	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_UNKNOWN		   0x0UL
+	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP		   0x1UL
+	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_DAC		   0x2UL
+	#define PORT_PHY_QCFG_RESP_MEDIA_TYPE_FIBRE		   0x3UL
 	u8 xcvr_pkg_type;
-	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL    (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_EXTERNAL    (0x2UL << 0)
+	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL    0x1UL
+	#define PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_EXTERNAL    0x2UL
 	u8 eee_config_phy_addr;
 	#define PORT_PHY_QCFG_RESP_PHY_ADDR_MASK		    0x1fUL
 	#define PORT_PHY_QCFG_RESP_PHY_ADDR_SFT		    0
@@ -1796,11 +1844,11 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_10MBHD  0x1000UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_SPEEDS_10MB    0x2000UL
 	u8 link_partner_adv_auto_mode;
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_NONE (0x0UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ALL_SPEEDS (0x1UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_SPEED (0x2UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_OR_BELOW (0x3UL << 0)
-	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_SPEED_MASK (0x4UL << 0)
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_NONE 0x0UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ALL_SPEEDS 0x1UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_SPEED 0x2UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_ONE_OR_BELOW 0x3UL
+	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_AUTO_MODE_SPEED_MASK 0x4UL
 	u8 link_partner_adv_pause;
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_PAUSE_TX       0x1UL
 	#define PORT_PHY_QCFG_RESP_LINK_PARTNER_ADV_PAUSE_RX       0x2UL
@@ -1859,7 +1907,7 @@ struct hwrm_port_mac_cfg_input {
 	__le64 resp_addr;
 	__le32 flags;
 	#define PORT_MAC_CFG_REQ_FLAGS_MATCH_LINK		    0x1UL
-	#define PORT_MAC_CFG_REQ_FLAGS_COS_ASSIGNMENT_ENABLE       0x2UL
+	#define PORT_MAC_CFG_REQ_FLAGS_VLAN_PRI2COS_ENABLE	    0x2UL
 	#define PORT_MAC_CFG_REQ_FLAGS_TUNNEL_PRI2COS_ENABLE       0x4UL
 	#define PORT_MAC_CFG_REQ_FLAGS_IP_DSCP2COS_ENABLE	    0x8UL
 	#define PORT_MAC_CFG_REQ_FLAGS_PTP_RX_TS_CAPTURE_ENABLE    0x10UL
@@ -1868,28 +1916,50 @@ struct hwrm_port_mac_cfg_input {
 	#define PORT_MAC_CFG_REQ_FLAGS_PTP_TX_TS_CAPTURE_DISABLE   0x80UL
 	#define PORT_MAC_CFG_REQ_FLAGS_OOB_WOL_ENABLE		    0x100UL
 	#define PORT_MAC_CFG_REQ_FLAGS_OOB_WOL_DISABLE		    0x200UL
+	#define PORT_MAC_CFG_REQ_FLAGS_VLAN_PRI2COS_DISABLE	    0x400UL
+	#define PORT_MAC_CFG_REQ_FLAGS_TUNNEL_PRI2COS_DISABLE      0x800UL
+	#define PORT_MAC_CFG_REQ_FLAGS_IP_DSCP2COS_DISABLE	    0x1000UL
 	__le32 enables;
 	#define PORT_MAC_CFG_REQ_ENABLES_IPG			    0x1UL
 	#define PORT_MAC_CFG_REQ_ENABLES_LPBK			    0x2UL
-	#define PORT_MAC_CFG_REQ_ENABLES_IVLAN_PRI2COS_MAP_PRI     0x4UL
-	#define PORT_MAC_CFG_REQ_ENABLES_LCOS_MAP_PRI		    0x8UL
+	#define PORT_MAC_CFG_REQ_ENABLES_VLAN_PRI2COS_MAP_PRI      0x4UL
+	#define PORT_MAC_CFG_REQ_ENABLES_RESERVED1		    0x8UL
 	#define PORT_MAC_CFG_REQ_ENABLES_TUNNEL_PRI2COS_MAP_PRI    0x10UL
 	#define PORT_MAC_CFG_REQ_ENABLES_DSCP2COS_MAP_PRI	    0x20UL
 	#define PORT_MAC_CFG_REQ_ENABLES_RX_TS_CAPTURE_PTP_MSG_TYPE 0x40UL
 	#define PORT_MAC_CFG_REQ_ENABLES_TX_TS_CAPTURE_PTP_MSG_TYPE 0x80UL
+	#define PORT_MAC_CFG_REQ_ENABLES_COS_FIELD_CFG		    0x100UL
 	__le16 port_id;
 	u8 ipg;
 	u8 lpbk;
-	#define PORT_MAC_CFG_REQ_LPBK_NONE			   (0x0UL << 0)
-	#define PORT_MAC_CFG_REQ_LPBK_LOCAL			   (0x1UL << 0)
-	#define PORT_MAC_CFG_REQ_LPBK_REMOTE			   (0x2UL << 0)
-	u8 ivlan_pri2cos_map_pri;
-	u8 lcos_map_pri;
+	#define PORT_MAC_CFG_REQ_LPBK_NONE			   0x0UL
+	#define PORT_MAC_CFG_REQ_LPBK_LOCAL			   0x1UL
+	#define PORT_MAC_CFG_REQ_LPBK_REMOTE			   0x2UL
+	u8 vlan_pri2cos_map_pri;
+	u8 reserved1;
 	u8 tunnel_pri2cos_map_pri;
 	u8 dscp2pri_map_pri;
 	__le16 rx_ts_capture_ptp_msg_type;
 	__le16 tx_ts_capture_ptp_msg_type;
-	__le32 unused_0;
+	u8 cos_field_cfg;
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_RSVD1		    0x1UL
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_MASK   0x6UL
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_SFT    1
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_INNERMOST (0x0UL << 1)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_OUTER (0x1UL << 1)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_OUTERMOST (0x2UL << 1)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_UNSPECIFIED (0x3UL << 1)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_LAST    PORT_MAC_CFG_REQ_COS_FIELD_CFG_VLAN_PRI_SEL_UNSPECIFIED
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_MASK 0x18UL
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_SFT  3
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_INNERMOST (0x0UL << 3)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_OUTER (0x1UL << 3)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_OUTERMOST (0x2UL << 3)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_UNSPECIFIED (0x3UL << 3)
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_LAST    PORT_MAC_CFG_REQ_COS_FIELD_CFG_T_VLAN_PRI_SEL_UNSPECIFIED
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_DEFAULT_COS_MASK    0xe0UL
+	#define PORT_MAC_CFG_REQ_COS_FIELD_CFG_DEFAULT_COS_SFT     5
+	u8 unused_0[3];
 };
 
 /* Output (16 bytes) */
@@ -1902,9 +1972,9 @@ struct hwrm_port_mac_cfg_output {
 	__le16 mtu;
 	u8 ipg;
 	u8 lpbk;
-	#define PORT_MAC_CFG_RESP_LPBK_NONE			   (0x0UL << 0)
-	#define PORT_MAC_CFG_RESP_LPBK_LOCAL			   (0x1UL << 0)
-	#define PORT_MAC_CFG_RESP_LPBK_REMOTE			   (0x2UL << 0)
+	#define PORT_MAC_CFG_RESP_LPBK_NONE			   0x0UL
+	#define PORT_MAC_CFG_RESP_LPBK_LOCAL			   0x1UL
+	#define PORT_MAC_CFG_RESP_LPBK_REMOTE			   0x2UL
 	u8 unused_0;
 	u8 valid;
 };
@@ -2163,8 +2233,8 @@ struct hwrm_queue_qportcfg_input {
 	__le64 resp_addr;
 	__le32 flags;
 	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH			    0x1UL
-	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
-	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
+	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_TX		   0x0UL
+	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_RX		   0x1UL
 	#define QUEUE_QPORTCFG_REQ_FLAGS_PATH_LAST    QUEUE_QPORTCFG_REQ_FLAGS_PATH_RX
 	__le16 port_id;
 	__le16 unused_0;
@@ -2179,50 +2249,51 @@ struct hwrm_queue_qportcfg_output {
 	u8 max_configurable_queues;
 	u8 max_configurable_lossless_queues;
 	u8 queue_cfg_allowed;
-	u8 queue_buffers_cfg_allowed;
+	u8 queue_cfg_info;
+	#define QUEUE_QPORTCFG_RESP_QUEUE_CFG_INFO_ASYM_CFG	    0x1UL
 	u8 queue_pfcenable_cfg_allowed;
 	u8 queue_pri2cos_cfg_allowed;
 	u8 queue_cos2bw_cfg_allowed;
 	u8 queue_id0;
 	u8 queue_id0_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID0_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id1;
 	u8 queue_id1_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID1_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id2;
 	u8 queue_id2_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID2_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id3;
 	u8 queue_id3_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID3_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id4;
 	u8 queue_id4_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID4_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id5;
 	u8 queue_id5_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID5_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id6;
 	u8 queue_id6_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID6_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 queue_id7;
 	u8 queue_id7_service_profile;
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_LOSSY (0x0UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_LOSSLESS (0x1UL << 0)
-	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_UNKNOWN (0xffUL << 0)
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_LOSSY 0x0UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_LOSSLESS 0x1UL
+	#define QUEUE_QPORTCFG_RESP_QUEUE_ID7_SERVICE_PROFILE_UNKNOWN 0xffUL
 	u8 valid;
 };
 
@@ -2235,19 +2306,21 @@ struct hwrm_queue_cfg_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	__le32 flags;
-	#define QUEUE_CFG_REQ_FLAGS_PATH			    0x1UL
-	#define QUEUE_CFG_REQ_FLAGS_PATH_TX			   (0x0UL << 0)
-	#define QUEUE_CFG_REQ_FLAGS_PATH_RX			   (0x1UL << 0)
-	#define QUEUE_CFG_REQ_FLAGS_PATH_LAST    QUEUE_CFG_REQ_FLAGS_PATH_RX
+	#define QUEUE_CFG_REQ_FLAGS_PATH_MASK			    0x3UL
+	#define QUEUE_CFG_REQ_FLAGS_PATH_SFT			    0
+	#define QUEUE_CFG_REQ_FLAGS_PATH_TX			   0x0UL
+	#define QUEUE_CFG_REQ_FLAGS_PATH_RX			   0x1UL
+	#define QUEUE_CFG_REQ_FLAGS_PATH_BIDIR			   0x2UL
+	#define QUEUE_CFG_REQ_FLAGS_PATH_LAST    QUEUE_CFG_REQ_FLAGS_PATH_BIDIR
 	__le32 enables;
 	#define QUEUE_CFG_REQ_ENABLES_DFLT_LEN			    0x1UL
 	#define QUEUE_CFG_REQ_ENABLES_SERVICE_PROFILE		    0x2UL
 	__le32 queue_id;
 	__le32 dflt_len;
 	u8 service_profile;
-	#define QUEUE_CFG_REQ_SERVICE_PROFILE_LOSSY		   (0x0UL << 0)
-	#define QUEUE_CFG_REQ_SERVICE_PROFILE_LOSSLESS		   (0x1UL << 0)
-	#define QUEUE_CFG_REQ_SERVICE_PROFILE_UNKNOWN		   (0xffUL << 0)
+	#define QUEUE_CFG_REQ_SERVICE_PROFILE_LOSSY		   0x0UL
+	#define QUEUE_CFG_REQ_SERVICE_PROFILE_LOSSLESS		   0x1UL
+	#define QUEUE_CFG_REQ_SERVICE_PROFILE_UNKNOWN		   0xffUL
 	u8 unused_0[7];
 };
 
@@ -2264,50 +2337,6 @@ struct hwrm_queue_cfg_output {
 	u8 valid;
 };
 
-/* hwrm_queue_buffers_cfg */
-/* Input (56 bytes) */
-struct hwrm_queue_buffers_cfg_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le32 flags;
-	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH		    0x1UL
-	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
-	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
-	#define QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_LAST    QUEUE_BUFFERS_CFG_REQ_FLAGS_PATH_RX
-	__le32 enables;
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_RESERVED		    0x1UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_SHARED		    0x2UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XOFF		    0x4UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_XON		    0x8UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_FULL		    0x10UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_NOTFULL		    0x20UL
-	#define QUEUE_BUFFERS_CFG_REQ_ENABLES_MAX		    0x40UL
-	__le32 queue_id;
-	__le32 reserved;
-	__le32 shared;
-	__le32 xoff;
-	__le32 xon;
-	__le32 full;
-	__le32 notfull;
-	__le32 max;
-};
-
-/* Output (16 bytes) */
-struct hwrm_queue_buffers_cfg_output {
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
 /* hwrm_queue_pfcenable_cfg */
 /* Input (24 bytes) */
 struct hwrm_queue_pfcenable_cfg_input {
@@ -2351,12 +2380,22 @@ struct hwrm_queue_pri2cos_cfg_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	__le32 flags;
-	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH		    0x1UL
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_MASK		    0x3UL
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_SFT		    0
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_TX		   (0x0UL << 0)
 	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_RX		   (0x1UL << 0)
-	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_LAST    QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_RX
-	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_IVLAN		    0x2UL
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_BIDIR		   (0x2UL << 0)
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_LAST    QUEUE_PRI2COS_CFG_REQ_FLAGS_PATH_BIDIR
+	#define QUEUE_PRI2COS_CFG_REQ_FLAGS_IVLAN		    0x4UL
 	__le32 enables;
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI0_COS_QUEUE_ID    0x1UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI1_COS_QUEUE_ID    0x2UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI2_COS_QUEUE_ID    0x4UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI3_COS_QUEUE_ID    0x8UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI4_COS_QUEUE_ID    0x10UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI5_COS_QUEUE_ID    0x20UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI6_COS_QUEUE_ID    0x40UL
+	#define QUEUE_PRI2COS_CFG_REQ_ENABLES_PRI7_COS_QUEUE_ID    0x80UL
 	u8 port_id;
 	u8 pri0_cos_queue_id;
 	u8 pri1_cos_queue_id;
@@ -2404,82 +2443,226 @@ struct hwrm_queue_cos2bw_cfg_input {
 	u8 queue_id0;
 	u8 unused_0;
 	__le32 queue_id0_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id0_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id0_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id0_pri_lvl;
 	u8 queue_id0_bw_weight;
 	u8 queue_id1;
 	__le32 queue_id1_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id1_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id1_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id1_pri_lvl;
 	u8 queue_id1_bw_weight;
 	u8 queue_id2;
 	__le32 queue_id2_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id2_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id2_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id2_pri_lvl;
 	u8 queue_id2_bw_weight;
 	u8 queue_id3;
 	__le32 queue_id3_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id3_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id3_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id3_pri_lvl;
 	u8 queue_id3_bw_weight;
 	u8 queue_id4;
 	__le32 queue_id4_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id4_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id4_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id4_pri_lvl;
 	u8 queue_id4_bw_weight;
 	u8 queue_id5;
 	__le32 queue_id5_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id5_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id5_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id5_pri_lvl;
 	u8 queue_id5_bw_weight;
 	u8 queue_id6;
 	__le32 queue_id6_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id6_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id6_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id6_pri_lvl;
 	u8 queue_id6_bw_weight;
 	u8 queue_id7;
 	__le32 queue_id7_min_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MIN_BW_BW_VALUE_UNIT_INVALID
 	__le32 queue_id7_max_bw;
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_MASK 0xfffffffUL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_SFT 0
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_RSVD	    0x10000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_MASK 0xe0000000UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_SFT 29
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_MBPS (0x0UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_PERCENT1_100 (0x1UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_INVALID (0x7UL << 29)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_LAST    QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 queue_id7_tsa_assign;
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_SP      (0x0UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_ETS     (0x1UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_SP      0x0UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_ETS     0x1UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_FIRST 0x2UL
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_LAST 0xffUL
 	u8 queue_id7_pri_lvl;
 	u8 queue_id7_bw_weight;
 	u8 unused_1[5];
@@ -2563,6 +2746,7 @@ struct hwrm_vnic_cfg_input {
 	#define VNIC_CFG_REQ_FLAGS_BD_STALL_MODE		    0x4UL
 	#define VNIC_CFG_REQ_FLAGS_ROCE_DUAL_VNIC_MODE		    0x8UL
 	#define VNIC_CFG_REQ_FLAGS_ROCE_ONLY_VNIC_MODE		    0x10UL
+	#define VNIC_CFG_REQ_FLAGS_RSS_DFLT_CR_MODE		    0x20UL
 	__le32 enables;
 	#define VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP		    0x1UL
 	#define VNIC_CFG_REQ_ENABLES_RSS_RULE			    0x2UL
@@ -2615,18 +2799,18 @@ struct hwrm_vnic_tpa_cfg_input {
 	#define VNIC_TPA_CFG_REQ_ENABLES_MIN_AGG_LEN		    0x8UL
 	__le16 vnic_id;
 	__le16 max_agg_segs;
-	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_1		   (0x0UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_2		   (0x1UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_4		   (0x2UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_8		   (0x3UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_MAX		   (0x1fUL << 0)
+	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_1		   0x0UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_2		   0x1UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_4		   0x2UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_8		   0x3UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGG_SEGS_MAX		   0x1fUL
 	__le16 max_aggs;
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_1			   (0x0UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_2			   (0x1UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_4			   (0x2UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_8			   (0x3UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_16			   (0x4UL << 0)
-	#define VNIC_TPA_CFG_REQ_MAX_AGGS_MAX			   (0x7UL << 0)
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_1			   0x0UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_2			   0x1UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_4			   0x2UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_8			   0x3UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_16			   0x4UL
+	#define VNIC_TPA_CFG_REQ_MAX_AGGS_MAX			   0x7UL
 	u8 unused_0;
 	u8 unused_1;
 	__le32 max_agg_timer;
@@ -2780,15 +2964,15 @@ struct hwrm_ring_alloc_input {
 	__le64 resp_addr;
 	__le32 enables;
 	#define RING_ALLOC_REQ_ENABLES_RESERVED1		    0x1UL
-	#define RING_ALLOC_REQ_ENABLES_RESERVED2		    0x2UL
+	#define RING_ALLOC_REQ_ENABLES_RING_ARB_CFG		    0x2UL
 	#define RING_ALLOC_REQ_ENABLES_RESERVED3		    0x4UL
 	#define RING_ALLOC_REQ_ENABLES_STAT_CTX_ID_VALID	    0x8UL
 	#define RING_ALLOC_REQ_ENABLES_RESERVED4		    0x10UL
 	#define RING_ALLOC_REQ_ENABLES_MAX_BW_VALID		    0x20UL
 	u8 ring_type;
-	#define RING_ALLOC_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
-	#define RING_ALLOC_REQ_RING_TYPE_TX			   (0x1UL << 0)
-	#define RING_ALLOC_REQ_RING_TYPE_RX			   (0x2UL << 0)
+	#define RING_ALLOC_REQ_RING_TYPE_CMPL			   0x0UL
+	#define RING_ALLOC_REQ_RING_TYPE_TX			   0x1UL
+	#define RING_ALLOC_REQ_RING_TYPE_RX			   0x2UL
 	u8 unused_0;
 	__le16 unused_1;
 	__le64 page_tbl_addr;
@@ -2804,18 +2988,36 @@ struct hwrm_ring_alloc_input {
 	u8 unused_4;
 	u8 unused_5;
 	__le32 reserved1;
-	__le16 reserved2;
+	__le16 ring_arb_cfg;
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_MASK	    0xfUL
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_SFT	    0
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_SP	   (0x1UL << 0)
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_WFQ	   (0x2UL << 0)
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_LAST    RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_WFQ
+	#define RING_ALLOC_REQ_RING_ARB_CFG_RSVD_MASK		    0xf0UL
+	#define RING_ALLOC_REQ_RING_ARB_CFG_RSVD_SFT		    4
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_PARAM_MASK  0xff00UL
+	#define RING_ALLOC_REQ_RING_ARB_CFG_ARB_POLICY_PARAM_SFT   8
 	u8 unused_6;
 	u8 unused_7;
 	__le32 reserved3;
 	__le32 stat_ctx_id;
 	__le32 reserved4;
 	__le32 max_bw;
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_MASK		    0xfffffffUL
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_SFT		    0
+	#define RING_ALLOC_REQ_MAX_BW_RSVD			    0x10000000UL
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_MASK	    0xe0000000UL
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_SFT	    29
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_MBPS	   (0x0UL << 29)
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_PERCENT1_100  (0x1UL << 29)
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_INVALID       (0x7UL << 29)
+	#define RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_LAST    RING_ALLOC_REQ_MAX_BW_BW_VALUE_UNIT_INVALID
 	u8 int_mode;
-	#define RING_ALLOC_REQ_INT_MODE_LEGACY			   (0x0UL << 0)
-	#define RING_ALLOC_REQ_INT_MODE_RSVD			   (0x1UL << 0)
-	#define RING_ALLOC_REQ_INT_MODE_MSIX			   (0x2UL << 0)
-	#define RING_ALLOC_REQ_INT_MODE_POLL			   (0x3UL << 0)
+	#define RING_ALLOC_REQ_INT_MODE_LEGACY			   0x0UL
+	#define RING_ALLOC_REQ_INT_MODE_RSVD			   0x1UL
+	#define RING_ALLOC_REQ_INT_MODE_MSIX			   0x2UL
+	#define RING_ALLOC_REQ_INT_MODE_POLL			   0x3UL
 	u8 unused_8[3];
 };
 
@@ -2842,9 +3044,9 @@ struct hwrm_ring_free_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 ring_type;
-	#define RING_FREE_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
-	#define RING_FREE_REQ_RING_TYPE_TX			   (0x1UL << 0)
-	#define RING_FREE_REQ_RING_TYPE_RX			   (0x2UL << 0)
+	#define RING_FREE_REQ_RING_TYPE_CMPL			   0x0UL
+	#define RING_FREE_REQ_RING_TYPE_TX			   0x1UL
+	#define RING_FREE_REQ_RING_TYPE_RX			   0x2UL
 	u8 unused_0;
 	__le16 ring_id;
 	__le32 unused_1;
@@ -2942,9 +3144,9 @@ struct hwrm_ring_reset_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 ring_type;
-	#define RING_RESET_REQ_RING_TYPE_CMPL			   (0x0UL << 0)
-	#define RING_RESET_REQ_RING_TYPE_TX			   (0x1UL << 0)
-	#define RING_RESET_REQ_RING_TYPE_RX			   (0x2UL << 0)
+	#define RING_RESET_REQ_RING_TYPE_CMPL			   0x0UL
+	#define RING_RESET_REQ_RING_TYPE_TX			   0x1UL
+	#define RING_RESET_REQ_RING_TYPE_RX			   0x2UL
 	u8 unused_0;
 	__le16 ring_id;
 	__le32 unused_1;
@@ -3068,36 +3270,36 @@ struct hwrm_cfa_l2_filter_alloc_input {
 	__le16 t_l2_ivlan;
 	__le16 t_l2_ivlan_mask;
 	u8 src_type;
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_NPORT		   (0x0UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_PF		   (0x1UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_VF		   (0x2UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_VNIC		   (0x3UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_KONG		   (0x4UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_APE		   (0x5UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_BONO		   (0x6UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_TANG		   (0x7UL << 0)
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_NPORT		   0x0UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_PF		   0x1UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_VF		   0x2UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_VNIC		   0x3UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_KONG		   0x4UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_APE		   0x5UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_BONO		   0x6UL
+	#define CFA_L2_FILTER_ALLOC_REQ_SRC_TYPE_TANG		   0x7UL
 	u8 unused_6;
 	__le32 src_id;
 	u8 tunnel_type;
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL     (0x0UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN	   (0x1UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE	   (0x2UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE	   (0x3UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP	   (0x4UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE	   (0x5UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS	   (0x6UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT	   (0x7UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE	   (0x8UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL     (0xffUL << 0)
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL     0x0UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN	   0x1UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE	   0x2UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE	   0x3UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP	   0x4UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE	   0x5UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS	   0x6UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT	   0x7UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE	   0x8UL
+	#define CFA_L2_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL     0xffUL
 	u8 unused_7;
 	__le16 dst_id;
 	__le16 mirror_vnic_id;
 	u8 pri_hint;
-	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER	   (0x0UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_ABOVE_FILTER     (0x1UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_BELOW_FILTER     (0x2UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_MAX		   (0x3UL << 0)
-	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_MIN		   (0x4UL << 0)
+	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER	   0x0UL
+	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_ABOVE_FILTER     0x1UL
+	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_BELOW_FILTER     0x2UL
+	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_MAX		   0x3UL
+	#define CFA_L2_FILTER_ALLOC_REQ_PRI_HINT_MIN		   0x4UL
 	u8 unused_8;
 	__le32 unused_9;
 	__le64 l2_filter_id_hint;
@@ -3246,16 +3448,16 @@ struct hwrm_cfa_tunnel_filter_alloc_input {
 	u8 l3_addr_type;
 	u8 t_l3_addr_type;
 	u8 tunnel_type;
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL (0x0UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN     (0x1UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE     (0x2UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE     (0x3UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP      (0x4UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE    (0x5UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS      (0x6UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT       (0x7UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE     (0x8UL << 0)
-	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL (0xffUL << 0)
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL 0x0UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN     0x1UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE     0x2UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE     0x3UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP      0x4UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE    0x5UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS      0x6UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT       0x7UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE     0x8UL
+	#define CFA_TUNNEL_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL 0xffUL
 	u8 unused_0;
 	__le32 vni;
 	__le32 dst_vnic_id;
@@ -3311,14 +3513,14 @@ struct hwrm_cfa_encap_record_alloc_input {
 	__le32 flags;
 	#define CFA_ENCAP_RECORD_ALLOC_REQ_FLAGS_LOOPBACK	    0x1UL
 	u8 encap_type;
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_VXLAN       (0x1UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_NVGRE       (0x2UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_L2GRE       (0x3UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_IPIP	   (0x4UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_GENEVE      (0x5UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_MPLS	   (0x6UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_VLAN	   (0x7UL << 0)
-	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_IPGRE       (0x8UL << 0)
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_VXLAN       0x1UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_NVGRE       0x2UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_L2GRE       0x3UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_IPIP	   0x4UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_GENEVE      0x5UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_MPLS	   0x6UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_VLAN	   0x7UL
+	#define CFA_ENCAP_RECORD_ALLOC_REQ_ENCAP_TYPE_IPGRE       0x8UL
 	u8 unused_0;
 	__le16 unused_1;
 	__le32 encap_data[16];
@@ -3397,32 +3599,32 @@ struct hwrm_cfa_ntuple_filter_alloc_input {
 	u8 src_macaddr[6];
 	__be16 ethertype;
 	u8 ip_addr_type;
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_UNKNOWN  (0x0UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV4     (0x4UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV6     (0x6UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_UNKNOWN  0x0UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV4     0x4UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV6     0x6UL
 	u8 ip_protocol;
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UNKNOWN   (0x0UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UDP       (0x6UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_TCP       (0x11UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UNKNOWN   0x0UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_UDP       0x6UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_IP_PROTOCOL_TCP       0x11UL
 	__le16 dst_id;
 	__le16 mirror_vnic_id;
 	u8 tunnel_type;
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL (0x0UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN     (0x1UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE     (0x2UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE     (0x3UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP      (0x4UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE    (0x5UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS      (0x6UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT       (0x7UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE     (0x8UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL (0xffUL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_NONTUNNEL 0x0UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_VXLAN     0x1UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_NVGRE     0x2UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_L2GRE     0x3UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPIP      0x4UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_GENEVE    0x5UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_MPLS      0x6UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_STT       0x7UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_IPGRE     0x8UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL 0xffUL
 	u8 pri_hint;
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER    (0x0UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_ABOVE	   (0x1UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_BELOW	   (0x2UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_HIGHEST      (0x3UL << 0)
-	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_LOWEST       (0x4UL << 0)
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_NO_PREFER    0x0UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_ABOVE	   0x1UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_BELOW	   0x2UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_HIGHEST      0x3UL
+	#define CFA_NTUPLE_FILTER_ALLOC_REQ_PRI_HINT_LOWEST       0x4UL
 	__be32 src_ipaddr[4];
 	__be32 src_ipaddr_mask[4];
 	__be32 dst_ipaddr[4];
@@ -3511,8 +3713,8 @@ struct hwrm_tunnel_dst_port_query_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_VXLAN       (0x1UL << 0)
-	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_GENEVE      (0x5UL << 0)
+	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_VXLAN       0x1UL
+	#define TUNNEL_DST_PORT_QUERY_REQ_TUNNEL_TYPE_GENEVE      0x5UL
 	u8 unused_0[7];
 };
 
@@ -3539,8 +3741,8 @@ struct hwrm_tunnel_dst_port_alloc_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_VXLAN       (0x1UL << 0)
-	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE      (0x5UL << 0)
+	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_VXLAN       0x1UL
+	#define TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE      0x5UL
 	u8 unused_0;
 	__be16 tunnel_dst_port_val;
 	__le32 unused_1;
@@ -3570,8 +3772,8 @@ struct hwrm_tunnel_dst_port_free_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 tunnel_type;
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN	   (0x1UL << 0)
-	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE       (0x5UL << 0)
+	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN	   0x1UL
+	#define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE       0x5UL
 	u8 unused_0;
 	__le16 tunnel_dst_port_id;
 	__le32 unused_1;
@@ -3720,15 +3922,15 @@ struct hwrm_fw_reset_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 embedded_proc_type;
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_BOOT		   (0x0UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_MGMT		   (0x1UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   (0x2UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_ROCE		   (0x3UL << 0)
-	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_RSVD		   (0x4UL << 0)
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_BOOT		   0x0UL
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_MGMT		   0x1UL
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   0x2UL
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_ROCE		   0x3UL
+	#define FW_RESET_REQ_EMBEDDED_PROC_TYPE_RSVD		   0x4UL
 	u8 selfrst_status;
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST	   (0x2UL << 0)
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTNONE	   0x0UL
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTASAP	   0x1UL
+	#define FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST	   0x2UL
 	__le16 unused_0[3];
 };
 
@@ -3739,9 +3941,9 @@ struct hwrm_fw_reset_output {
 	__le16 seq_id;
 	__le16 resp_len;
 	u8 selfrst_status;
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTPCIERST       (0x2UL << 0)
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTNONE	   0x0UL
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTASAP	   0x1UL
+	#define FW_RESET_RESP_SELFRST_STATUS_SELFRSTPCIERST       0x2UL
 	u8 unused_0;
 	__le16 unused_1;
 	u8 unused_2;
@@ -3759,11 +3961,11 @@ struct hwrm_fw_qstatus_input {
 	__le16 target_id;
 	__le64 resp_addr;
 	u8 embedded_proc_type;
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_BOOT		   (0x0UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_MGMT		   (0x1UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   (0x2UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_ROCE		   (0x3UL << 0)
-	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_RSVD		   (0x4UL << 0)
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_BOOT		   0x0UL
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_MGMT		   0x1UL
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_NETCTRL	   0x2UL
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_ROCE		   0x3UL
+	#define FW_QSTATUS_REQ_EMBEDDED_PROC_TYPE_RSVD		   0x4UL
 	u8 unused_0[7];
 };
 
@@ -3774,9 +3976,9 @@ struct hwrm_fw_qstatus_output {
 	__le16 seq_id;
 	__le16 resp_len;
 	u8 selfrst_status;
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTNONE	   (0x0UL << 0)
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTASAP	   (0x1UL << 0)
-	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTPCIERST     (0x2UL << 0)
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTNONE	   0x0UL
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTASAP	   0x1UL
+	#define FW_QSTATUS_RESP_SELFRST_STATUS_SELFRSTPCIERST     0x2UL
 	u8 unused_0;
 	__le16 unused_1;
 	u8 unused_2;
@@ -3785,6 +3987,42 @@ struct hwrm_fw_qstatus_output {
 	u8 valid;
 };
 
+/* hwrm_fw_set_time */
+/* Input (32 bytes) */
+struct hwrm_fw_set_time_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le16 year;
+	#define FW_SET_TIME_REQ_YEAR_UNKNOWN			   0x0UL
+	u8 month;
+	u8 day;
+	u8 hour;
+	u8 minute;
+	u8 second;
+	u8 unused_0;
+	__le16 millisecond;
+	__le16 zone;
+	#define FW_SET_TIME_REQ_ZONE_UTC			   0x0UL
+	#define FW_SET_TIME_REQ_ZONE_UNKNOWN			   0xffffUL
+	__le32 unused_1;
+};
+
+/* Output (16 bytes) */
+struct hwrm_fw_set_time_output {
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
 /* hwrm_exec_fwd_resp */
 /* Input (128 bytes) */
 struct hwrm_exec_fwd_resp_input {
@@ -3921,32 +4159,6 @@ struct hwrm_temp_monitor_query_output {
 	u8 valid;
 };
 
-/* hwrm_nvm_raw_write_blk */
-/* Input (32 bytes) */
-struct hwrm_nvm_raw_write_blk_input {
-	__le16 req_type;
-	__le16 cmpl_ring;
-	__le16 seq_id;
-	__le16 target_id;
-	__le64 resp_addr;
-	__le64 host_src_addr;
-	__le32 dest_addr;
-	__le32 len;
-};
-
-/* Output (16 bytes) */
-struct hwrm_nvm_raw_write_blk_output {
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
 /* hwrm_nvm_read */
 /* Input (40 bytes) */
 struct hwrm_nvm_read_input {
@@ -4132,9 +4344,9 @@ struct hwrm_nvm_find_dir_entry_input {
 	u8 opt_ordinal;
 	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_MASK	    0x3UL
 	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_SFT		    0
-	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_EQ		   (0x0UL << 0)
-	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_GE		   (0x1UL << 0)
-	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_GT		   (0x2UL << 0)
+	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_EQ		   0x0UL
+	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_GE		   0x1UL
+	#define NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_GT		   0x2UL
 	u8 unused_1[3];
 };
 
@@ -4266,4 +4478,41 @@ struct hwrm_nvm_verify_update_output {
 	u8 valid;
 };
 
+/* hwrm_nvm_install_update */
+/* Input (24 bytes) */
+struct hwrm_nvm_install_update_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 install_type;
+	#define NVM_INSTALL_UPDATE_REQ_INSTALL_TYPE_NORMAL	   0x0UL
+	#define NVM_INSTALL_UPDATE_REQ_INSTALL_TYPE_ALL	   0xffffffffUL
+	__le32 unused_0;
+};
+
+/* Output (24 bytes) */
+struct hwrm_nvm_install_update_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le64 installed_items;
+	u8 result;
+	#define NVM_INSTALL_UPDATE_RESP_RESULT_SUCCESS		   0x0UL
+	u8 problem_item;
+	#define NVM_INSTALL_UPDATE_RESP_PROBLEM_ITEM_NONE	   0x0UL
+	#define NVM_INSTALL_UPDATE_RESP_PROBLEM_ITEM_PACKAGE      0xffUL
+	u8 reset_required;
+	#define NVM_INSTALL_UPDATE_RESP_RESET_REQUIRED_NONE       0x0UL
+	#define NVM_INSTALL_UPDATE_RESP_RESET_REQUIRED_PCI	   0x1UL
+	#define NVM_INSTALL_UPDATE_RESP_RESET_REQUIRED_POWER      0x2UL
+	u8 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
 #endif
-- 
1.8.3.1
