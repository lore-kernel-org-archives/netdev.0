From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/6] wcn36xx: Fold indication payload into message header
Date: Sun, 19 Jun 2016 23:19:43 -0700
Message-ID: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org,
	Bjorn Andersson <bjorn.andersson@sonymobile.com>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@sonymobile.com>

Merge the two allocation instead of separately allocating room for the
indication payload.

Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 15 ++++++---------
 drivers/net/wireless/ath/wcn36xx/smd.h |  2 +-
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index e8b630c4f11e..1a9580d72077 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2229,14 +2229,8 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
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
@@ -2245,6 +2239,10 @@ nomem:
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
@@ -2295,7 +2293,6 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 			      msg_header->msg_type);
 	}
 	list_del(wcn->hal_ind_queue.next);
-	kfree(hal_ind_msg->msg);
 	kfree(hal_ind_msg);
 	mutex_unlock(&wcn->hal_ind_mutex);
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index d93e3fd73831..c4375ce1019a 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -46,8 +46,8 @@ struct wcn36xx_fw_msg_status_rsp {
 
 struct wcn36xx_hal_ind_msg {
 	struct list_head list;
-	u8 *msg;
 	size_t msg_len;
+	u8 msg[];
 };
 
 struct wcn36xx;
-- 
2.5.0
