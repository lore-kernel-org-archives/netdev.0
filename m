From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] wcn36xx: Change indication list lock to spinlock
Date: Sun, 19 Jun 2016 23:19:44 -0700
Message-ID: <1466403588-7041-2-git-send-email-bjorn.andersson@linaro.org>
References: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466403588-7041-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>

In preparation for handling incoming messages from IRQ context, change
the indication list lock to a spinlock

Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c     | 12 ++++++------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 1a9580d72077..b2108076f5c0 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2243,10 +2243,10 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
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
@@ -2260,8 +2260,9 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 		container_of(work, struct wcn36xx, hal_ind_work);
 	struct wcn36xx_hal_msg_header *msg_header;
 	struct wcn36xx_hal_ind_msg *hal_ind_msg;
+	unsigned long flags;
 
-	mutex_lock(&wcn->hal_ind_mutex);
+	spin_lock_irqsave(&wcn->hal_ind_lock, flags);
 
 	hal_ind_msg = list_first_entry(&wcn->hal_ind_queue,
 				       struct wcn36xx_hal_ind_msg,
@@ -2293,8 +2294,8 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 			      msg_header->msg_type);
 	}
 	list_del(wcn->hal_ind_queue.next);
+	spin_unlock_irqrestore(&wcn->hal_ind_lock, flags);
 	kfree(hal_ind_msg);
-	mutex_unlock(&wcn->hal_ind_mutex);
 }
 int wcn36xx_smd_open(struct wcn36xx *wcn)
 {
@@ -2307,7 +2308,7 @@ int wcn36xx_smd_open(struct wcn36xx *wcn)
 	}
 	INIT_WORK(&wcn->hal_ind_work, wcn36xx_ind_smd_work);
 	INIT_LIST_HEAD(&wcn->hal_ind_queue);
-	mutex_init(&wcn->hal_ind_mutex);
+	spin_lock_init(&wcn->hal_ind_lock);
 
 	ret = wcn->ctrl_ops->open(wcn, wcn36xx_smd_rsp_process);
 	if (ret) {
@@ -2327,5 +2328,4 @@ void wcn36xx_smd_close(struct wcn36xx *wcn)
 {
 	wcn->ctrl_ops->close();
 	destroy_workqueue(wcn->hal_ind_wq);
-	mutex_destroy(&wcn->hal_ind_mutex);
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 7433d67a5929..f6d8d14f13d1 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
