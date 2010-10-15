From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] connector: remove lazy workqueue creation
Date: Fri, 15 Oct 2010 11:55:22 +0200
Message-ID: <4CB8250A.7040902@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:40723 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882Ab0JOJzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 05:55:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1a5645bc (connector: create connector workqueue only while
needed once) implements lazy workqueue creation for connector
workqueue.  With cmwq now in place, lazy workqueue creation doesn't
make much sense while adding a lot of complexity.  Remove it and
allocate an ordered workqueue during initialization.

This also removes a call to flush_scheduled_work() which is deprecated
and scheduled to be removed.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
---
 drivers/connector/cn_queue.c  |   75 ++++--------------------------------------
 drivers/connector/connector.c |    9 ++---
 include/linux/connector.h     |    8 ----
 3 files changed, 12 insertions(+), 80 deletions(-)

Index: work/drivers/connector/cn_queue.c
===================================================================
--- work.orig/drivers/connector/cn_queue.c
+++ work/drivers/connector/cn_queue.c
@@ -31,48 +31,6 @@
 #include <linux/connector.h>
 #include <linux/delay.h>

-
-/*
- * This job is sent to the kevent workqueue.
- * While no event is once sent to any callback, the connector workqueue
- * is not created to avoid a useless waiting kernel task.
- * Once the first event is received, we create this dedicated workqueue which
- * is necessary because the flow of data can be high and we don't want
- * to encumber keventd with that.
- */
-static void cn_queue_create(struct work_struct *work)
-{
-	struct cn_queue_dev *dev;
-
-	dev = container_of(work, struct cn_queue_dev, wq_creation);
-
-	dev->cn_queue = create_singlethread_workqueue(dev->name);
-	/* If we fail, we will use keventd for all following connector jobs */
-	WARN_ON(!dev->cn_queue);
-}
-
-/*
- * Queue a data sent to a callback.
- * If the connector workqueue is already created, we queue the job on it.
- * Otherwise, we queue the job to kevent and queue the connector workqueue
- * creation too.
- */
-int queue_cn_work(struct cn_callback_entry *cbq, struct work_struct *work)
-{
-	struct cn_queue_dev *pdev = cbq->pdev;
-
-	if (likely(pdev->cn_queue))
-		return queue_work(pdev->cn_queue, work);
-
-	/* Don't create the connector workqueue twice */
-	if (atomic_inc_return(&pdev->wq_requested) == 1)
-		schedule_work(&pdev->wq_creation);
-	else
-		atomic_dec(&pdev->wq_requested);
-
-	return schedule_work(work);
-}
-
 void cn_queue_wrapper(struct work_struct *work)
 {
 	struct cn_callback_entry *cbq =
@@ -111,11 +69,7 @@ cn_queue_alloc_callback_entry(char *name

 static void cn_queue_free_callback(struct cn_callback_entry *cbq)
 {
-	/* The first jobs have been sent to kevent, flush them too */
-	flush_scheduled_work();
-	if (cbq->pdev->cn_queue)
-		flush_workqueue(cbq->pdev->cn_queue);
-
+	flush_workqueue(cbq->pdev->cn_queue);
 	kfree(cbq);
 }

@@ -193,11 +147,14 @@ struct cn_queue_dev *cn_queue_alloc_dev(
 	atomic_set(&dev->refcnt, 0);
 	INIT_LIST_HEAD(&dev->queue_list);
 	spin_lock_init(&dev->queue_lock);
-	init_waitqueue_head(&dev->wq_created);

 	dev->nls = nls;

-	INIT_WORK(&dev->wq_creation, cn_queue_create);
+	dev->cn_queue = alloc_ordered_workqueue(dev->name, 0);
+	if (!dev->cn_queue) {
+		kfree(dev);
+		return NULL;
+	}

 	return dev;
 }
@@ -205,25 +162,9 @@ struct cn_queue_dev *cn_queue_alloc_dev(
 void cn_queue_free_dev(struct cn_queue_dev *dev)
 {
 	struct cn_callback_entry *cbq, *n;
-	long timeout;
-	DEFINE_WAIT(wait);

-	/* Flush the first pending jobs queued on kevent */
-	flush_scheduled_work();
-
-	/* If the connector workqueue creation is still pending, wait for it */
-	prepare_to_wait(&dev->wq_created, &wait, TASK_UNINTERRUPTIBLE);
-	if (atomic_read(&dev->wq_requested) && !dev->cn_queue) {
-		timeout = schedule_timeout(HZ * 2);
-		if (!timeout && !dev->cn_queue)
-			WARN_ON(1);
-	}
-	finish_wait(&dev->wq_created, &wait);
-
-	if (dev->cn_queue) {
-		flush_workqueue(dev->cn_queue);
-		destroy_workqueue(dev->cn_queue);
-	}
+	flush_workqueue(dev->cn_queue);
+	destroy_workqueue(dev->cn_queue);

 	spin_lock_bh(&dev->queue_lock);
 	list_for_each_entry_safe(cbq, n, &dev->queue_list, callback_entry)
Index: work/drivers/connector/connector.c
===================================================================
--- work.orig/drivers/connector/connector.c
+++ work/drivers/connector/connector.c
@@ -133,7 +133,8 @@ static int cn_call_callback(struct sk_bu
 					__cbq->data.skb == NULL)) {
 				__cbq->data.skb = skb;

-				if (queue_cn_work(__cbq, &__cbq->work))
+				if (queue_work(dev->cbdev->cn_queue,
+					       &__cbq->work))
 					err = 0;
 				else
 					err = -EINVAL;
@@ -148,13 +149,11 @@ static int cn_call_callback(struct sk_bu
 					d->callback = __cbq->data.callback;
 					d->free = __new_cbq;

-					__new_cbq->pdev = __cbq->pdev;
-
 					INIT_WORK(&__new_cbq->work,
 							&cn_queue_wrapper);

-					if (queue_cn_work(__new_cbq,
-						    &__new_cbq->work))
+					if (queue_work(dev->cbdev->cn_queue,
+						       &__new_cbq->work))
 						err = 0;
 					else {
 						kfree(__new_cbq);
Index: work/include/linux/connector.h
===================================================================
--- work.orig/include/linux/connector.h
+++ work/include/linux/connector.h
@@ -88,12 +88,6 @@ struct cn_queue_dev {
 	unsigned char name[CN_CBQ_NAMELEN];

 	struct workqueue_struct *cn_queue;
-	/* Sent to kevent to create cn_queue only when needed */
-	struct work_struct wq_creation;
-	/* Tell if the wq_creation job is pending/completed */
-	atomic_t wq_requested;
-	/* Wait for cn_queue to be created */
-	wait_queue_head_t wq_created;

 	struct list_head queue_list;
 	spinlock_t queue_lock;
@@ -141,8 +135,6 @@ int cn_netlink_send(struct cn_msg *, u32
 int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id, void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id);

-int queue_cn_work(struct cn_callback_entry *cbq, struct work_struct *work);
-
 struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *);
 void cn_queue_free_dev(struct cn_queue_dev *dev);

