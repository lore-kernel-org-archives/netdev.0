From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/14]: pkt_sched: Manage qdisc_ops grab/release outside of
 qdisc_create.
Date: Mon, 14 Jul 2008 15:59:24 -0700 (PDT)
Message-ID: <20080714.155924.259503309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758303AbYGNW7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 50C75C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Let the caller do this.  That way, when we replicate qdisc creation
for multiple queues, we only have to do the ops lookup and
management once outside of the for-each-netdev-queue loop.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   54 ++++++++++++++++++++++++++++----------------------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3ed3b32..b0da006 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -555,20 +555,15 @@ static int qdisc_graft(struct netdev_queue *dev_queue, struct Qdisc *parent,
 	return err;
 }
 
-/* Allocate and initialize new qdisc.  Parameters are passed via tca.  */
-
-static struct Qdisc *
-qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
-	     u32 parent, u32 handle, struct nlattr **tca, int *errp)
+static struct Qdisc_ops *tc_grab_ops(struct nlattr *kind)
 {
-	int err;
-	struct nlattr *kind = tca[TCA_KIND];
-	struct Qdisc *sch;
-	struct Qdisc_ops *ops;
+	struct Qdisc_ops *ops = qdisc_lookup_ops(kind);
+
+	if (ops)
+		return ops;
 
-	ops = qdisc_lookup_ops(kind);
 #ifdef CONFIG_KMOD
-	if (ops == NULL && kind != NULL) {
+	if (kind) {
 		char name[IFNAMSIZ];
 		if (nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
 			/* We dropped the RTNL semaphore in order to
@@ -588,21 +583,28 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				 * so don't keep a reference.
 				 */
 				module_put(ops->owner);
-				err = -EAGAIN;
-				goto err_out;
+				return ERR_PTR(-EAGAIN);
 			}
 		}
 	}
 #endif
+	return ERR_PTR(-ENOENT);
+}
 
-	err = -ENOENT;
-	if (ops == NULL)
-		goto err_out;
+/* Allocate and initialize new qdisc.  Parameters are passed via tca.  */
+
+static struct Qdisc *
+qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
+	     struct Qdisc_ops *ops,
+	     u32 parent, u32 handle, struct nlattr **tca, int *errp)
+{
+	int err;
+	struct Qdisc *sch;
 
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch)) {
 		err = PTR_ERR(sch);
-		goto err_out2;
+		goto err_out;
 	}
 
 	sch->parent = parent;
@@ -615,7 +617,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			handle = qdisc_alloc_handle(dev);
 			err = -ENOMEM;
 			if (handle == 0)
-				goto err_out3;
+				goto err_out_dev_put;
 		}
 	}
 
@@ -634,7 +636,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				 */
 				if (ops->destroy)
 					ops->destroy(sch);
-				goto err_out3;
+				goto err_out_dev_put;
 			}
 		}
 		qdisc_lock_tree(dev);
@@ -643,11 +645,9 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 
 		return sch;
 	}
-err_out3:
+err_out_dev_put:
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
-err_out2:
-	module_put(ops->owner);
 err_out:
 	*errp = err;
 	return NULL;
@@ -786,12 +786,18 @@ static struct Qdisc *tc_create(struct net_device *dev,
 			       u32 parent, u32 handle,
 			       struct nlattr **tca)
 {
+	struct Qdisc_ops *ops = tc_grab_ops(tca[TCA_KIND]);
 	struct Qdisc *q;
 	int err = 0;
 
-	q = qdisc_create(dev, dev_queue, parent, handle, tca, &err);
-	if (unlikely(!q))
+	if (IS_ERR(ops))
+		return ERR_PTR(PTR_ERR(ops));
+
+	q = qdisc_create(dev, dev_queue, ops, parent, handle, tca, &err);
+	if (unlikely(!q)) {
+		module_put(ops->owner);
 		return ERR_PTR(err);
+	}
 
 	return q;
 }
-- 
1.5.6.2.255.gbed62

