From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 7/7] net: wireless: wcn36xx: handle new trigger_ba format
Date: Sun, 18 Jan 2015 13:11:17 +0800
Message-ID: <20150118051117.31866.68634.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:38430 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbARFLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:11:25 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wcn3620 has a new message structure for the reply to trigger_ba
We don't know what to do with the candidate list he sends back,
but we can at least accept and ignore it nicely instead of dying.

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c |   28 ++++++++++++++++++++++++++--
 drivers/net/wireless/ath/wcn36xx/smd.h |    9 +++++++++
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 819741c..dc24e1b 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -243,8 +243,31 @@ static int wcn36xx_smd_rsp_status_check(void *buf, size_t len)
 	rsp = (struct wcn36xx_fw_msg_status_rsp *)
 		(buf + sizeof(struct wcn36xx_hal_msg_header));
 
-	if (WCN36XX_FW_MSG_RESULT_SUCCESS != rsp->status)
+	if (WCN36XX_FW_MSG_RESULT_SUCCESS != rsp->status) {
+		pr_err("%s: bad status, len = %d\n", __func__, len);
+		return rsp->status;
+	}
+
+	return 0;
+}
+
+static int wcn36xx_smd_rsp_status_check_bav2(struct wcn36xx *wcn, void *buf,
+					     size_t len)
+{
+	struct wcn36xx_fw_msg_status_rspv2 *rsp;
+
+	if (wcn->chip_version != WCN36XX_CHIP_3620)
+		return wcn36xx_smd_rsp_status_check(buf, len);
+
+	if (len < sizeof(struct wcn36xx_hal_msg_header) + sizeof(*rsp))
+		return -EIO;
+
+	rsp = buf + sizeof(struct wcn36xx_hal_msg_header);
+
+	if (WCN36XX_FW_MSG_RESULT_SUCCESS != rsp->status) {
+		pr_err("%s: bad status, len = %d\n", __func__, len);
 		return rsp->status;
+	}
 
 	return 0;
 }
@@ -1884,7 +1907,8 @@ int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index)
 		wcn36xx_err("Sending hal_trigger_ba failed\n");
 		goto out;
 	}
-	ret = wcn36xx_smd_rsp_status_check(wcn->hal_buf, wcn->hal_rsp_len);
+	ret = wcn36xx_smd_rsp_status_check_bav2(wcn, wcn->hal_buf,
+						wcn->hal_rsp_len);
 	if (ret) {
 		wcn36xx_err("hal_trigger_ba response failed err=%d\n", ret);
 		goto out;
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index 008d034..432d3b8 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -44,6 +44,15 @@ struct wcn36xx_fw_msg_status_rsp {
 	u32	status;
 } __packed;
 
+/* wcn3620 returns this for tigger_ba */
+
+struct wcn36xx_fw_msg_status_rspv2 {
+	u8	bss_id[6];
+	u32	status __packed;
+	u16	count_following_candidates __packed;
+	/* candidate list follows */
+};
+
 struct wcn36xx_hal_ind_msg {
 	struct list_head list;
 	u8 *msg;
