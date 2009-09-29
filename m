From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH] connector: Keep the skb in cn_callback_data
Date: Tue, 29 Sep 2009 16:48:08 +0200
Message-ID: <1254235692-1631-2-git-send-email-philipp.reisner@linbit.com>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	Philipp Reisner <philipp.reisner@linbit.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752982AbZI2OsS@vger.kernel.org>
In-Reply-To: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>
---
 drivers/connector/cn_queue.c  |    3 ++-
 drivers/connector/connector.c |   11 +++++------
 include/linux/connector.h     |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 4a1dfe1..b4cfac9 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -78,8 +78,9 @@ void cn_queue_wrapper(struct work_struct *work)
 	struct cn_callback_entry *cbq =
 		container_of(work, struct cn_callback_entry, work);
 	struct cn_callback_data *d = &cbq->data;
+	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(d->skb));
 
-	d->callback(d->callback_priv);
+	d->callback(msg);
 
 	d->destruct_data(d->ddata);
 	d->ddata = NULL;
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 74f52af..fc9887f 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -129,10 +129,11 @@ EXPORT_SYMBOL_GPL(cn_netlink_send);
 /*
  * Callback helper - queues work and setup destructor for given data.
  */
-static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), void *data)
+static int cn_call_callback(struct sk_buff *skb, void (*destruct_data)(void *), void *data)
 {
 	struct cn_callback_entry *__cbq, *__new_cbq;
 	struct cn_dev *dev = &cdev;
+	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(skb));
 	int err = -ENODEV;
 
 	spin_lock_bh(&dev->cbdev->queue_lock);
@@ -140,7 +141,7 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
 			if (likely(!work_pending(&__cbq->work) &&
 					__cbq->data.ddata == NULL)) {
-				__cbq->data.callback_priv = msg;
+				__cbq->data.skb = skb;
 
 				__cbq->data.ddata = data;
 				__cbq->data.destruct_data = destruct_data;
@@ -156,7 +157,7 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 				__new_cbq = kzalloc(sizeof(struct cn_callback_entry), GFP_ATOMIC);
 				if (__new_cbq) {
 					d = &__new_cbq->data;
-					d->callback_priv = msg;
+					d->skb = skb;
 					d->callback = __cbq->data.callback;
 					d->ddata = data;
 					d->destruct_data = destruct_data;
@@ -191,7 +192,6 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
  */
 static void cn_rx_skb(struct sk_buff *__skb)
 {
-	struct cn_msg *msg;
 	struct nlmsghdr *nlh;
 	int err;
 	struct sk_buff *skb;
@@ -208,8 +208,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
 			return;
 		}
 
-		msg = NLMSG_DATA(nlh);
-		err = cn_call_callback(msg, (void (*)(void *))kfree_skb, skb);
+		err = cn_call_callback(skb, (void (*)(void *))kfree_skb, skb);
 		if (err < 0)
 			kfree_skb(skb);
 	}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 47ebf41..05a7a14 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -134,8 +134,8 @@ struct cn_callback_id {
 struct cn_callback_data {
 	void (*destruct_data) (void *);
 	void *ddata;
-	
-	void *callback_priv;
+
+	struct sk_buff *skb;
 	void (*callback) (struct cn_msg *);
 
 	void *free;
-- 
1.6.0.4
