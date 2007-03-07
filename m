From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] connector: Bugfix for cn_call_callback()
Date: Wed, 7 Mar 2007 15:10:30 +0300
Message-ID: <20070307121030.GA19089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Philipp Reisner <philipp.reisner@linbit.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57474 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbXCGMLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 07:11:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When system under heavy stress and must allocate new work
instead of reusing old one, new work must use correct 
completion callback.

Patch is based on Philipp's and Lars' work.
I only cleaned small stuff (and removed spaces instead of tabs).

Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
Signed-off-by: Lars Ellenberg <lars.ellenberg@linbit.com>
Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index a44db75..a905f78 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -128,7 +128,7 @@ EXPORT_SYMBOL_GPL(cn_netlink_send);
  */
 static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), void *data)
 {
-	struct cn_callback_entry *__cbq;
+	struct cn_callback_entry *__cbq, *__new_cbq;
 	struct cn_dev *dev = &cdev;
 	int err = -ENODEV;
 
@@ -148,27 +148,27 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 			} else {
 				struct cn_callback_data *d;
 				
-				__cbq = kzalloc(sizeof(*__cbq), GFP_ATOMIC);
-				if (__cbq) {
-					d = &__cbq->data;
+				err = -ENOMEM;
+				__new_cbq = kzalloc(sizeof(struct cn_callback_entry), GFP_ATOMIC);
+				if (__new_cbq) {
+					d = &__new_cbq->data;
 					d->callback_priv = msg;
 					d->callback = __cbq->data.callback;
 					d->ddata = data;
 					d->destruct_data = destruct_data;
-					d->free = __cbq;
+					d->free = __new_cbq;
 
-					INIT_WORK(&__cbq->work,
+					INIT_WORK(&__new_cbq->work,
 							&cn_queue_wrapper);
-					
+
 					if (queue_work(dev->cbdev->cn_queue,
-						    &__cbq->work))
+						    &__new_cbq->work))
 						err = 0;
 					else {
-						kfree(__cbq);
+						kfree(__new_cbq);
 						err = -EINVAL;
 					}
-				} else
-					err = -ENOMEM;
+				}
 			}
 			break;
 		}

-- 
	Evgeniy Polyakov
