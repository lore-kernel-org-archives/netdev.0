From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH] wcn36xx: Implement print_reg indication
Date: Thu, 30 Jun 2016 10:46:29 -0700
Message-ID: <1467308789-23475-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dechesne <ndec@linaro.org>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35502 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbcF3Rqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:46:37 -0400
Received: by mail-pa0-f48.google.com with SMTP id hl6so30379774pac.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:46:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some firmware versions sends a "print register indication", handle this
by printing out the content.

Cc: Nicolas Dechesne <ndec@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h | 16 ++++++++++++++++
 drivers/net/wireless/ath/wcn36xx/smd.c | 30 ++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index 4f87ef1e1eb8..b765c647319d 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -350,6 +350,8 @@ enum wcn36xx_hal_host_msg_type {
 
 	WCN36XX_HAL_AVOID_FREQ_RANGE_IND = 233,
 
+	WCN36XX_HAL_PRINT_REG_INFO_IND = 259,
+
 	WCN36XX_HAL_MSG_MAX = WCN36XX_HAL_MSG_TYPE_MAX_ENUM_SIZE
 };
 
@@ -4703,4 +4705,18 @@ struct stats_class_b_ind {
 	u32 rx_time_total;
 };
 
+/* WCN36XX_HAL_PRINT_REG_INFO_IND */
+struct wcn36xx_hal_print_reg_info_ind {
+	struct wcn36xx_hal_msg_header header;
+
+	u32 count;
+	u32 scenario;
+	u32 reason;
+
+	struct {
+		u32 addr;
+		u32 value;
+	} regs[];
+} __packed;
+
 #endif /* _HAL_H_ */
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 87a62eb6228c..28d6ca0ca819 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2109,6 +2109,30 @@ static int wcn36xx_smd_delete_sta_context_ind(struct wcn36xx *wcn,
 	return -ENOENT;
 }
 
+static int wcn36xx_smd_print_reg_info_ind(struct wcn36xx *wcn,
+					  void *buf,
+					  size_t len)
+{
+	struct wcn36xx_hal_print_reg_info_ind *rsp = buf;
+	int i;
+
+	if (len < sizeof(*rsp)) {
+		wcn36xx_warn("Corrupted print reg info indication\n");
+		return -EIO;
+	}
+
+	wcn36xx_dbg(WCN36XX_DBG_HAL,
+		    "reginfo indication, scenario: 0x%x reason: 0x%x\n",
+		    rsp->scenario, rsp->reason);
+
+	for (i = 0; i < rsp->count; i++) {
+		wcn36xx_dbg(WCN36XX_DBG_HAL, "\t0x%x: 0x%x\n",
+			    rsp->regs[i].addr, rsp->regs[i].value);
+	}
+
+	return 0;
+}
+
 int wcn36xx_smd_update_cfg(struct wcn36xx *wcn, u32 cfg_id, u32 value)
 {
 	struct wcn36xx_hal_update_cfg_req_msg msg_body, *body;
@@ -2238,6 +2262,7 @@ int wcn36xx_smd_rsp_process(struct qcom_smd_channel *channel,
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
+	case WCN36XX_HAL_PRINT_REG_INFO_IND:
 		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_ATOMIC);
 		if (!msg_ind) {
 			/*
@@ -2300,6 +2325,11 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 						   hal_ind_msg->msg,
 						   hal_ind_msg->msg_len);
 		break;
+	case WCN36XX_HAL_PRINT_REG_INFO_IND:
+		wcn36xx_smd_print_reg_info_ind(wcn,
+					       hal_ind_msg->msg,
+					       hal_ind_msg->msg_len);
+		break;
 	default:
 		wcn36xx_err("SMD_EVENT (%d) not supported\n",
 			      msg_header->msg_type);
-- 
2.5.0
