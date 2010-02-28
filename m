From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Why does connector use a work queue???
Date: Sat, 27 Feb 2010 18:57:02 -0800
Message-ID: <m1pr3qcbk1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These days netlink callbacks for messages happen in the context of the
process who sent the message.  Things like permission checks are much
more complicated if we don't use that process context.

I was looking at removing NETLINK_CB(skb).eff_cap but I discovered
that connected takes the netlink messages, them from their
perfectly good process context, and puts the into a workqueue
for reasons that are not apparent to me.

Unless I am misreading something we should just be able to remove the
work queues and greatly simplify the connector code.

Something like:

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 537c29a..4c9af0a 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -120,52 +120,28 @@ EXPORT_SYMBOL_GPL(cn_netlink_send);
  */
 static int cn_call_callback(struct sk_buff *skb)
 {
-	struct cn_callback_entry *__cbq, *__new_cbq;
+	struct cn_callback_entry *__cbq;
 	struct cn_dev *dev = &cdev;
 	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(skb));
 	int err = -ENODEV;
+	void (*callback)(struct cn_msg *req, struct netlink_skb_parms *nsp);
 
+	callback = NULL;
 	spin_lock_bh(&dev->cbdev->queue_lock);
 	list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
-			if (likely(!work_pending(&__cbq->work) &&
-					__cbq->data.skb == NULL)) {
-				__cbq->data.skb = skb;
-
-				if (queue_cn_work(__cbq, &__cbq->work))
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
-					__new_cbq->pdev = __cbq->pdev;
-
-					INIT_WORK(&__new_cbq->work,
-							&cn_queue_wrapper);
-
-					if (queue_cn_work(__new_cbq,
-						    &__new_cbq->work))
-						err = 0;
-					else {
-						kfree(__new_cbq);
-						err = -EINVAL;
-					}
-				}
-			}
+			callback = __cbq->data.callback;
+			err = 0;
 			break;
 		}
 	}
 	spin_unlock_bh(&dev->cbdev->queue_lock);
 
+	if (!err) {
+		callback(msg, &NETLINK_CB(skb));
+		kfree_skb(skb);
+	}
+
 	return err;
 }
 
