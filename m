From: Patrick McHardy <kaber@trash.net>
Subject: connector: convert to synchronous netlink message processing
Date: Mon, 28 Mar 2011 20:39:36 +0200
Message-ID: <4D90D5E8.4080002@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060203020603090708050308"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab1C1Sjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 14:39:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060203020603090708050308
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch fixes up connector to work properly with the recent
netlink changes that require synchronous netlink message processing.

The patch is so far only compile tested since I'm still looking
for a good way to test it. If you could point me to some software
using the proc events that would be appreciated.



--------------060203020603090708050308
Content-Type: text/x-patch;
 name="cn.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cn.diff"

commit 21c40e4675954b42c939334e3ed15e1bd0a4da29
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Mar 28 20:20:26 2011 +0200

    connector: convert to synchronous netlink message processing
    
    Commits 01a16b21 (netlink: kill eff_cap from struct netlink_skb_parms)
    and c53fa1ed (netlink: kill loginuid/sessionid/sid members from struct
    netlink_skb_parms) removed some members from struct netlink_skb_parms
    that depend on the current context, all netlink users are now required
    to do synchronous message processing.
    
    connector however queues received messages and processes them in a work
    queue, which is not valid anymore. This patch converts connector to do
    synchronous message processing by invoking the registered callback handler
    directly from the netlink receive function.
    
    In order to avoid invoking the callback with connector locks held, a
    reference count is added to struct cn_callback_entry, the reference
    is taken when finding a matching callback entry on the device's queue_list
    and released after the callback handler has been invoked.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 55653ab..c42c9d5 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -31,24 +31,9 @@
 #include <linux/connector.h>
 #include <linux/delay.h>
 
-void cn_queue_wrapper(struct work_struct *work)
-{
-	struct cn_callback_entry *cbq =
-		container_of(work, struct cn_callback_entry, work);
-	struct cn_callback_data *d = &cbq->data;
-	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(d->skb));
-	struct netlink_skb_parms *nsp = &NETLINK_CB(d->skb);
-
-	d->callback(msg, nsp);
-
-	kfree_skb(d->skb);
-	d->skb = NULL;
-
-	kfree(d->free);
-}
-
 static struct cn_callback_entry *
-cn_queue_alloc_callback_entry(const char *name, struct cb_id *id,
+cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
+			      struct cb_id *id,
 			      void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq;
@@ -59,17 +44,23 @@ cn_queue_alloc_callback_entry(const char *name, struct cb_id *id,
 		return NULL;
 	}
 
+	atomic_set(&cbq->refcnt, 1);
+
+	atomic_inc(&dev->refcnt);
+	cbq->pdev = dev;
+
 	snprintf(cbq->id.name, sizeof(cbq->id.name), "%s", name);
 	memcpy(&cbq->id.id, id, sizeof(struct cb_id));
-	cbq->data.callback = callback;
-
-	INIT_WORK(&cbq->work, &cn_queue_wrapper);
+	cbq->callback = callback;
 	return cbq;
 }
 
-static void cn_queue_free_callback(struct cn_callback_entry *cbq)
+void cn_queue_release_callback(struct cn_callback_entry *cbq)
 {
-	flush_workqueue(cbq->pdev->cn_queue);
+	if (!atomic_dec_and_test(&cbq->refcnt))
+		return;
+
+	atomic_dec(&cbq->pdev->refcnt);
 	kfree(cbq);
 }
 
@@ -85,13 +76,10 @@ int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
 	struct cn_callback_entry *cbq, *__cbq;
 	int found = 0;
 
-	cbq = cn_queue_alloc_callback_entry(name, id, callback);
+	cbq = cn_queue_alloc_callback_entry(dev, name, id, callback);
 	if (!cbq)
 		return -ENOMEM;
 
-	atomic_inc(&dev->refcnt);
-	cbq->pdev = dev;
-
 	spin_lock_bh(&dev->queue_lock);
 	list_for_each_entry(__cbq, &dev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->id.id, id)) {
@@ -104,8 +92,7 @@ int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
 	spin_unlock_bh(&dev->queue_lock);
 
 	if (found) {
-		cn_queue_free_callback(cbq);
-		atomic_dec(&dev->refcnt);
+		cn_queue_release_callback(cbq);
 		return -EINVAL;
 	}
 
@@ -130,10 +117,8 @@ void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id)
 	}
 	spin_unlock_bh(&dev->queue_lock);
 
-	if (found) {
-		cn_queue_free_callback(cbq);
-		atomic_dec(&dev->refcnt);
-	}
+	if (found)
+		cn_queue_release_callback(cbq);
 }
 
 struct cn_queue_dev *cn_queue_alloc_dev(const char *name, struct sock *nls)
@@ -151,12 +136,6 @@ struct cn_queue_dev *cn_queue_alloc_dev(const char *name, struct sock *nls)
 
 	dev->nls = nls;
 
-	dev->cn_queue = alloc_ordered_workqueue(dev->name, 0);
-	if (!dev->cn_queue) {
-		kfree(dev);
-		return NULL;
-	}
-
 	return dev;
 }
 
@@ -164,9 +143,6 @@ void cn_queue_free_dev(struct cn_queue_dev *dev)
 {
 	struct cn_callback_entry *cbq, *n;
 
-	flush_workqueue(dev->cn_queue);
-	destroy_workqueue(dev->cn_queue);
-
 	spin_lock_bh(&dev->queue_lock);
 	list_for_each_entry_safe(cbq, n, &dev->queue_list, callback_entry)
 		list_del(&cbq->callback_entry);
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index f7554de..d770058 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -122,51 +122,28 @@ EXPORT_SYMBOL_GPL(cn_netlink_send);
  */
 static int cn_call_callback(struct sk_buff *skb)
 {
-	struct cn_callback_entry *__cbq, *__new_cbq;
+	struct cn_callback_entry *i, *cbq = NULL;
 	struct cn_dev *dev = &cdev;
 	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(skb));
+	struct netlink_skb_parms *nsp = &NETLINK_CB(skb);
 	int err = -ENODEV;
 
 	spin_lock_bh(&dev->cbdev->queue_lock);
-	list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
-		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
-			if (likely(!work_pending(&__cbq->work) &&
-					__cbq->data.skb == NULL)) {
-				__cbq->data.skb = skb;
-
-				if (queue_work(dev->cbdev->cn_queue,
-					       &__cbq->work))
-					err = 0;
-				else
-					err = -EINVAL;
-			} else {
-				struct cn_callback_data *d;
-
-				err = -ENOMEM;
-				__new_cbq = kzalloc(sizeof(struct cn_callback_entry), GFP_ATOMIC);
-				if (__new_cbq) {
-					d = &__new_cbq->data;
-					d->skb = skb;
-					d->callback = __cbq->data.callback;
-					d->free = __new_cbq;
-
-					INIT_WORK(&__new_cbq->work,
-							&cn_queue_wrapper);
-
-					if (queue_work(dev->cbdev->cn_queue,
-						       &__new_cbq->work))
-						err = 0;
-					else {
-						kfree(__new_cbq);
-						err = -EINVAL;
-					}
-				}
-			}
+	list_for_each_entry(i, &dev->cbdev->queue_list, callback_entry) {
+		if (cn_cb_equal(&i->id.id, &msg->id)) {
+			atomic_inc(&i->refcnt);
+			cbq = i;
 			break;
 		}
 	}
 	spin_unlock_bh(&dev->cbdev->queue_lock);
 
+	if (cbq != NULL) {
+		cbq->callback(msg, nsp);
+		kfree_skb(skb);
+		cn_queue_release_callback(cbq);
+	}
+
 	return err;
 }
 
diff --git a/include/linux/connector.h b/include/linux/connector.h
index bcafc94..7c60d09 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -88,8 +88,6 @@ struct cn_queue_dev {
 	atomic_t refcnt;
 	unsigned char name[CN_CBQ_NAMELEN];
 
-	struct workqueue_struct *cn_queue;
-
 	struct list_head queue_list;
 	spinlock_t queue_lock;
 
@@ -101,20 +99,13 @@ struct cn_callback_id {
 	struct cb_id id;
 };
 
-struct cn_callback_data {
-	struct sk_buff *skb;
-	void (*callback) (struct cn_msg *, struct netlink_skb_parms *);
-
-	void *free;
-};
-
 struct cn_callback_entry {
 	struct list_head callback_entry;
-	struct work_struct work;
+	atomic_t refcnt;
 	struct cn_queue_dev *pdev;
 
 	struct cn_callback_id id;
-	struct cn_callback_data data;
+	void (*callback) (struct cn_msg *, struct netlink_skb_parms *);
 
 	u32 seq, group;
 };
@@ -138,13 +129,12 @@ int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
 			  struct cb_id *id,
 			  void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id);
+void cn_queue_release_callback(struct cn_callback_entry *);
 
 struct cn_queue_dev *cn_queue_alloc_dev(const char *name, struct sock *);
 void cn_queue_free_dev(struct cn_queue_dev *dev);
 
 int cn_cb_equal(struct cb_id *, struct cb_id *);
 
-void cn_queue_wrapper(struct work_struct *work);
-
 #endif				/* __KERNEL__ */
 #endif				/* __CONNECTOR_H */


--------------060203020603090708050308--
