From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] connector: replace delayed work with usual work queue.
Date: Mon, 18 Dec 2006 12:44:35 +0300
Message-ID: <20061218094435.GA22620@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34610 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753658AbWLRJoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:44:46 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index b418b16..296f510 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -34,7 +34,7 @@
 void cn_queue_wrapper(struct work_struct *work)
 {
 	struct cn_callback_entry *cbq =
-		container_of(work, struct cn_callback_entry, work.work);
+		container_of(work, struct cn_callback_entry, work);
 	struct cn_callback_data *d = &cbq->data;
 
 	d->callback(d->callback_priv);
@@ -59,13 +59,12 @@ static struct cn_callback_entry *cn_queue_alloc_callback_entry(char *name, struc
 	memcpy(&cbq->id.id, id, sizeof(struct cb_id));
 	cbq->data.callback = callback;
 	
-	INIT_DELAYED_WORK(&cbq->work, &cn_queue_wrapper);
+	INIT_WORK(&cbq->work, &cn_queue_wrapper);
 	return cbq;
 }
 
 static void cn_queue_free_callback(struct cn_callback_entry *cbq)
 {
-	cancel_delayed_work(&cbq->work);
 	flush_workqueue(cbq->pdev->cn_queue);
 
 	kfree(cbq);
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 4cec1a8..e4b9c37 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -135,16 +135,15 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 	spin_lock_bh(&dev->cbdev->queue_lock);
 	list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
-			if (likely(!work_pending(&__cbq->work.work) &&
+			if (likely(!work_pending(&__cbq->work) &&
 					__cbq->data.ddata == NULL)) {
 				__cbq->data.callback_priv = msg;
 
 				__cbq->data.ddata = data;
 				__cbq->data.destruct_data = destruct_data;
 
-				if (queue_delayed_work(
-					    dev->cbdev->cn_queue,
-					    &__cbq->work, 0))
+				if (queue_work(dev->cbdev->cn_queue, 
+							&__cbq->work))
 					err = 0;
 			} else {
 				struct cn_callback_data *d;
@@ -158,12 +157,11 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 					d->destruct_data = destruct_data;
 					d->free = __cbq;
 
-					INIT_DELAYED_WORK(&__cbq->work,
-							  &cn_queue_wrapper);
+					INIT_WORK(&__cbq->work, 
+							&cn_queue_wrapper);
 					
-					if (queue_delayed_work(
-						    dev->cbdev->cn_queue,
-						    &__cbq->work, 0))
+					if (queue_work(dev->cbdev->cn_queue,
+						    &__cbq->work))
 						err = 0;
 					else {
 						kfree(__cbq);
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 3ea1cd5..10eb56b 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -133,7 +133,7 @@ struct cn_callback_data {
 struct cn_callback_entry {
 	struct list_head callback_entry;
 	struct cn_callback *cb;
-	struct delayed_work work;
+	struct work_struct work;
 	struct cn_queue_dev *pdev;
 
 	struct cn_callback_id id;

-- 
	Evgeniy Polyakov
