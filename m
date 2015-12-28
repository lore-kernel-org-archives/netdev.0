From: Bjorn Andersson <bjorn@kryo.se>
Subject: [PATCH 1/4] wcn36xx: Fold indication payload into message header
Date: Sun, 27 Dec 2015 17:34:24 -0800
Message-ID: <1451266467-15377-2-git-send-email-bjorn.andersson@sonymobile.com>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Cc: fengwei.yin@linaro.org, linux-arm-msm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, wcn36xx@lists.infradead.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35386 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbbL1Beg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 20:34:36 -0500
Received: by mail-pf0-f181.google.com with SMTP id 78so104351772pfw.2
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 17:34:36 -0800 (PST)
In-Reply-To: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge the two allocation instead of separately allocating room for the
indication payload.

Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 15 ++++++---------
 drivers/net/wireless/ath/wcn36xx/smd.h |  2 +-
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 74f56a81ad9a..6b5dbe6f0d0a 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2151,14 +2151,8 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
-		msg_ind = kmalloc(sizeof(*msg_ind), GFP_KERNEL);
-		if (!msg_ind)
-			goto nomem;
-		msg_ind->msg_len = len;
-		msg_ind->msg = kmemdup(buf, len, GFP_KERNEL);
-		if (!msg_ind->msg) {
-			kfree(msg_ind);
-nomem:
+		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_KERNEL);
+		if (!msg_ind) {
 			/*
 			 * FIXME: Do something smarter then just
 			 * printing an error.
@@ -2167,6 +2161,10 @@ nomem:
 				    msg_header->msg_type);
 			break;
 		}
+
+		msg_ind->msg_len = len;
+		memcpy(msg_ind->msg, buf, len);
+
 		mutex_lock(&wcn->hal_ind_mutex);
 		list_add_tail(&msg_ind->list, &wcn->hal_ind_queue);
 		queue_work(wcn->hal_ind_wq, &wcn->hal_ind_work);
@@ -2217,7 +2215,6 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 			      msg_header->msg_type);
 	}
 	list_del(wcn->hal_ind_queue.next);
-	kfree(hal_ind_msg->msg);
 	kfree(hal_ind_msg);
 	mutex_unlock(&wcn->hal_ind_mutex);
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index 8361f9e3995b..21cc4ac7b5ca 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -55,8 +55,8 @@ struct wcn36xx_fw_msg_status_rsp_v2 {
 
 struct wcn36xx_hal_ind_msg {
 	struct list_head list;
-	u8 *msg;
 	size_t msg_len;
+	u8 msg[];
 };
 
 struct wcn36xx;
-- 
2.5.0
