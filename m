From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH 4/8] connector: Removed the destruct_data callback since it is always kfree_skb()
Date: Fri,  2 Oct 2009 14:40:07 +0200
Message-ID: <1254487211-11810-5-git-send-email-philipp.reisner@linbit.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-2-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-3-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-4-git-send-email-philipp.reisner@linbit.com>
Cc: dm-devel@redhat.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev-devel@lists.sourceforge.net,
	Philipp Reisner <philipp.reisner@linbit.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757720AbZJBMl4@vger.kernel.org>
In-Reply-To: <1254487211-11810-4-git-send-email-philipp.reisner@linbit.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
---
 drivers/connector/cn_queue.c  |    4 ++--
 drivers/connector/connector.c |   11 +++--------
 include/linux/connector.h     |    3 ---
 3 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 163c3e3..210338e 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -83,8 +83,8 @@ void cn_queue_wrapper(struct work_struct *work)
 
 	d->callback(msg, nsp);
 
-	d->destruct_data(d->ddata);
-	d->ddata = NULL;
+	kfree_skb(d->skb);
+	d->skb = NULL;
 
 	kfree(d->free);
 }
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index e59f0ab..f060246 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -129,7 +129,7 @@ EXPORT_SYMBOL_GPL(cn_netlink_send);
 /*
  * Callback helper - queues work and setup destructor for given data.
  */
-static int cn_call_callback(struct sk_buff *skb, void (*destruct_data)(void *), void *data)
+static int cn_call_callback(struct sk_buff *skb)
 {
 	struct cn_callback_entry *__cbq, *__new_cbq;
 	struct cn_dev *dev = &cdev;
@@ -140,12 +140,9 @@ static int cn_call_callback(struct sk_buff *skb, void (*destruct_data)(void *),
 	list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
 			if (likely(!work_pending(&__cbq->work) &&
-					__cbq->data.ddata == NULL)) {
+					__cbq->data.skb == NULL)) {
 				__cbq->data.skb = skb;
 
-				__cbq->data.ddata = data;
-				__cbq->data.destruct_data = destruct_data;
-
 				if (queue_cn_work(__cbq, &__cbq->work))
 					err = 0;
 				else
@@ -159,8 +156,6 @@ static int cn_call_callback(struct sk_buff *skb, void (*destruct_data)(void *),
 					d = &__new_cbq->data;
 					d->skb = skb;
 					d->callback = __cbq->data.callback;
-					d->ddata = data;
-					d->destruct_data = destruct_data;
 					d->free = __new_cbq;
 
 					__new_cbq->pdev = __cbq->pdev;
@@ -208,7 +203,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
 			return;
 		}
 
-		err = cn_call_callback(skb, (void (*)(void *))kfree_skb, skb);
+		err = cn_call_callback(skb);
 		if (err < 0)
 			kfree_skb(skb);
 	}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 545728e..3a14615 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -132,9 +132,6 @@ struct cn_callback_id {
 };
 
 struct cn_callback_data {
-	void (*destruct_data) (void *);
-	void *ddata;
-
 	struct sk_buff *skb;
 	void (*callback) (struct cn_msg *, struct netlink_skb_parms *);
 
-- 
1.6.0.4
