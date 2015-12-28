From: Bjorn Andersson <bjorn@kryo.se>
Subject: [PATCH 2/4] wcn36xx: Change indication list lock to spinlock
Date: Sun, 27 Dec 2015 17:34:25 -0800
Message-ID: <1451266467-15377-3-git-send-email-bjorn.andersson@sonymobile.com>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Cc: fengwei.yin@linaro.org, linux-arm-msm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, wcn36xx@lists.infradead.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33526 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbbL1Bei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 20:34:38 -0500
Received: by mail-pf0-f172.google.com with SMTP id q63so69406222pfb.0
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 17:34:38 -0800 (PST)
In-Reply-To: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for handling incoming messages from IRQ context, change
the indication list lock to a spinlock

Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
---
 drivers/net/wireless/ath/wcn36xx/smd.c     | 12 ++++++------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 6b5dbe6f0d0a..4307429740a9 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2165,10 +2165,10 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 		msg_ind->msg_len = len;
 		memcpy(msg_ind->msg, buf, len);
 
-		mutex_lock(&wcn->hal_ind_mutex);
+		spin_lock(&wcn->hal_ind_lock);
 		list_add_tail(&msg_ind->list, &wcn->hal_ind_queue);
 		queue_work(wcn->hal_ind_wq, &wcn->hal_ind_work);
-		mutex_unlock(&wcn->hal_ind_mutex);
+		spin_unlock(&wcn->hal_ind_lock);
 		wcn36xx_dbg(WCN36XX_DBG_HAL, "indication arrived\n");
 		break;
 	default:
@@ -2182,8 +2182,9 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 		container_of(work, struct wcn36xx, hal_ind_work);
 	struct wcn36xx_hal_msg_header *msg_header;
 	struct wcn36xx_hal_ind_msg *hal_ind_msg;
+	unsigned long flags;
 
-	mutex_lock(&wcn->hal_ind_mutex);
+	spin_lock_irqsave(&wcn->hal_ind_lock, flags);
 
 	hal_ind_msg = list_first_entry(&wcn->hal_ind_queue,
 				       struct wcn36xx_hal_ind_msg,
@@ -2215,8 +2216,8 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 			      msg_header->msg_type);
 	}
 	list_del(wcn->hal_ind_queue.next);
+	spin_unlock_irqrestore(&wcn->hal_ind_lock, flags);
 	kfree(hal_ind_msg);
-	mutex_unlock(&wcn->hal_ind_mutex);
 }
 int wcn36xx_smd_open(struct wcn36xx *wcn)
 {
@@ -2229,7 +2230,7 @@ int wcn36xx_smd_open(struct wcn36xx *wcn)
 	}
 	INIT_WORK(&wcn->hal_ind_work, wcn36xx_ind_smd_work);
 	INIT_LIST_HEAD(&wcn->hal_ind_queue);
-	mutex_init(&wcn->hal_ind_mutex);
+	spin_lock_init(&wcn->hal_ind_lock);
 
 	ret = wcn->ctrl_ops->open(wcn, wcn36xx_smd_rsp_process);
 	if (ret) {
@@ -2249,5 +2250,4 @@ void wcn36xx_smd_close(struct wcn36xx *wcn)
 {
 	wcn->ctrl_ops->close();
 	destroy_workqueue(wcn->hal_ind_wq);
-	mutex_destroy(&wcn->hal_ind_mutex);
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 7b41e833e18c..7997cc1312ee 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -215,7 +215,7 @@ struct wcn36xx {
 	struct completion	hal_rsp_compl;
 	struct workqueue_struct	*hal_ind_wq;
 	struct work_struct	hal_ind_work;
-	struct mutex		hal_ind_mutex;
+	spinlock_t		hal_ind_lock;
 	struct list_head	hal_ind_queue;
 
 	/* DXE channels */
-- 
2.5.0
