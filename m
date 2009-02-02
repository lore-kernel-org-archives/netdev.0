From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH] connector: create connector workqueue only while needed once
Date: Sun, 01 Feb 2009 16:05:01 -0800 (PST)
Message-ID: <498638ad.1438560a.537e.51b8@mx.google.com>
Cc: James Morris <jmorris@namei.org>, Li Zefan <lizf@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, <fweisbec@gmail.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:62345 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbZBBAFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 19:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink connector uses its own workqueue to relay the datas sent from
userspace to the appropriate callback.
If you launch the test from Documentation/connector and change it a bit to send
a high flow of data, you will see thousands of events coming to the "cqueue" workqueue
by looking at the workqueue tracer.

This flow of events can be sent very quickly. So, to not encumber the kevent workqueue and
delay other jobs, the "cqueue" workqueue should remain.

But this workqueue is pointless most of the time, it will always be created (assuming you have
built it of course) although only developpers with specific needs will use it.

So avoid this "most of the time useless task", this patch proposes to create this workqueue only when needed
once.
The first jobs to be sent to connector callbacks will be sent to kevent while the "cqueue" thread creation
will be scheduled to kevent too.

The following jobs will continue to be scheduled to keventd until the cqueue workqueue is created, and then
the rest of the jobs will continue to perform as usual, through this dedicated workqueue.

Each time I tested this patch, only the first event was sent to keventd, the rest has been sent to cqueue which
have been created quickly.

Also, this patch fixes some trailing whitespaces on the connector files.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
---
 drivers/connector/cn_queue.c  |   80 +++++++++++++++++++++++++++++++++++------
 drivers/connector/connector.c |   19 +++++-----
 include/linux/connector.h     |    8 ++++
 3 files changed, 87 insertions(+), 20 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index b6fe7e7..c769ef2 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -1,9 +1,9 @@
 /*
  * 	cn_queue.c
- * 
+ *
  * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -31,6 +31,48 @@
 #include <linux/connector.h>
 #include <linux/delay.h>
 
+
+/*
+ * This job is sent to the kevent workqueue.
+ * While no event is once sent to any callback, the connector workqueue
+ * is not created to avoid a useless waiting kernel task.
+ * Once the first event is received, we create this dedicated workqueue which
+ * is necessary because the flow of data can be high and we don't want
+ * to encumber keventd with that.
+ */
+static void cn_queue_create(struct work_struct *work)
+{
+	struct cn_queue_dev *dev;
+
+	dev = container_of(work, struct cn_queue_dev, wq_creation);
+
+	dev->cn_queue = create_singlethread_workqueue(dev->name);
+	/* If we fail, we will use keventd for all following connector jobs */
+	WARN_ON(!dev->cn_queue);
+}
+
+/*
+ * Queue a data sent to a callback.
+ * If the connector workqueue is already created, we queue the job on it.
+ * Otherwise, we queue the job to kevent and queue the connector workqueue
+ * creation too.
+ */
+int queue_cn_work(struct cn_callback_entry *cbq, struct work_struct *work)
+{
+	struct cn_queue_dev *pdev = cbq->pdev;
+
+	if (likely(pdev->cn_queue))
+		return queue_work(pdev->cn_queue, work);
+
+	/* Don't create the connector workqueue twice */
+	if (atomic_inc_return(&pdev->wq_requested) == 1)
+		schedule_work(&pdev->wq_creation);
+	else
+		atomic_dec(&pdev->wq_requested);
+
+	return schedule_work(work);
+}
+
 void cn_queue_wrapper(struct work_struct *work)
 {
 	struct cn_callback_entry *cbq =
@@ -58,14 +100,17 @@ static struct cn_callback_entry *cn_queue_alloc_callback_entry(char *name, struc
 	snprintf(cbq->id.name, sizeof(cbq->id.name), "%s", name);
 	memcpy(&cbq->id.id, id, sizeof(struct cb_id));
 	cbq->data.callback = callback;
-	
+
 	INIT_WORK(&cbq->work, &cn_queue_wrapper);
 	return cbq;
 }
 
 static void cn_queue_free_callback(struct cn_callback_entry *cbq)
 {
-	flush_workqueue(cbq->pdev->cn_queue);
+	/* The first jobs have been sent to kevent, flush them too */
+	flush_scheduled_work();
+	if (cbq->pdev->cn_queue)
+		flush_workqueue(cbq->pdev->cn_queue);
 
 	kfree(cbq);
 }
@@ -143,14 +188,11 @@ struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *nls)
 	atomic_set(&dev->refcnt, 0);
 	INIT_LIST_HEAD(&dev->queue_list);
 	spin_lock_init(&dev->queue_lock);
+	init_waitqueue_head(&dev->wq_created);
 
 	dev->nls = nls;
 
-	dev->cn_queue = create_singlethread_workqueue(dev->name);
-	if (!dev->cn_queue) {
-		kfree(dev);
-		return NULL;
-	}
+	INIT_WORK(&dev->wq_creation, cn_queue_create);
 
 	return dev;
 }
@@ -158,9 +200,25 @@ struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *nls)
 void cn_queue_free_dev(struct cn_queue_dev *dev)
 {
 	struct cn_callback_entry *cbq, *n;
+	long timeout;
+	DEFINE_WAIT(wait);
+
+	/* Flush the first pending jobs queued on kevent */
+	flush_scheduled_work();
+
+	/* If the connector workqueue creation is still pending, wait for it */
+	prepare_to_wait(&dev->wq_created, &wait, TASK_UNINTERRUPTIBLE);
+	if (atomic_read(&dev->wq_requested) && !dev->cn_queue) {
+		timeout = schedule_timeout(HZ * 2);
+		if (!timeout && !dev->cn_queue)
+			WARN_ON(1);
+	}
+	finish_wait(&dev->wq_created, &wait);
 
-	flush_workqueue(dev->cn_queue);
-	destroy_workqueue(dev->cn_queue);
+	if (dev->cn_queue) {
+		flush_workqueue(dev->cn_queue);
+		destroy_workqueue(dev->cn_queue);
+	}
 
 	spin_lock_bh(&dev->queue_lock);
 	list_for_each_entry_safe(cbq, n, &dev->queue_list, callback_entry)
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index bf48300..fd336c5 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -1,9 +1,9 @@
 /*
  * 	connector.c
- * 
+ *
  * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -145,14 +145,13 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 				__cbq->data.ddata = data;
 				__cbq->data.destruct_data = destruct_data;
 
-				if (queue_work(dev->cbdev->cn_queue,
-							&__cbq->work))
+				if (queue_cn_work(__cbq, &__cbq->work))
 					err = 0;
 				else
 					err = -EINVAL;
 			} else {
 				struct cn_callback_data *d;
-				
+
 				err = -ENOMEM;
 				__new_cbq = kzalloc(sizeof(struct cn_callback_entry), GFP_ATOMIC);
 				if (__new_cbq) {
@@ -163,10 +162,12 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 					d->destruct_data = destruct_data;
 					d->free = __new_cbq;
 
+					__new_cbq->pdev = __cbq->pdev;
+
 					INIT_WORK(&__new_cbq->work,
 							&cn_queue_wrapper);
 
-					if (queue_work(dev->cbdev->cn_queue,
+					if (queue_cn_work(__new_cbq,
 						    &__new_cbq->work))
 						err = 0;
 					else {
@@ -237,7 +238,7 @@ static void cn_notify(struct cb_id *id, u32 notify_event)
 
 		req = (struct cn_notify_req *)ctl->data;
 		for (i = 0; i < ctl->idx_notify_num; ++i, ++req) {
-			if (id->idx >= req->first && 
+			if (id->idx >= req->first &&
 					id->idx < req->first + req->range) {
 				idx_found = 1;
 				break;
@@ -245,7 +246,7 @@ static void cn_notify(struct cb_id *id, u32 notify_event)
 		}
 
 		for (i = 0; i < ctl->val_notify_num; ++i, ++req) {
-			if (id->val >= req->first && 
+			if (id->val >= req->first &&
 					id->val < req->first + req->range) {
 				val_found = 1;
 				break;
@@ -459,7 +460,7 @@ static int __devinit cn_init(void)
 		netlink_kernel_release(dev->nls);
 		return -EINVAL;
 	}
-	
+
 	cn_already_initialized = 1;
 
 	err = cn_add_callback(&dev->id, "connector", &cn_callback);
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 34f2789..fc65d21 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -109,6 +109,12 @@ struct cn_queue_dev {
 	unsigned char name[CN_CBQ_NAMELEN];
 
 	struct workqueue_struct *cn_queue;
+	/* Sent to kevent to create cn_queue only when needed */
+	struct work_struct wq_creation;
+	/* Tell if the wq_creation job is pending/completed */
+	atomic_t wq_requested;
+	/* Wait for cn_queue to be created */
+	wait_queue_head_t wq_created;
 
 	struct list_head queue_list;
 	spinlock_t queue_lock;
@@ -164,6 +170,8 @@ int cn_netlink_send(struct cn_msg *, u32, gfp_t);
 int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id, void (*callback)(void *));
 void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id);
 
+int queue_cn_work(struct cn_callback_entry *cbq, struct work_struct *work);
+
 struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *);
 void cn_queue_free_dev(struct cn_queue_dev *dev);
 
-- 
1.6.1


