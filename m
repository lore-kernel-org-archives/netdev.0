From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: ingress: switch back to using ingress_lock
Date: Mon, 16 Apr 2007 09:53:55 +0200
Message-ID: <46232B93.1000807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090505010909010007020706"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbXDPH4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:56:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090505010909010007020706
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch fixes a few spots for using ingress_lock for the ingress
qdisc again and switches ing_filter back to use it.

Applies on top of the netlink dump patches.


--------------090505010909010007020706
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: ingress: switch back to using ingress_lock

Switch ingress queueing back to use ingress_lock. qdisc_lock_tree now locks
both the ingress and egress qdiscs on the device. All changes to data that
might be used on both ingress and egress needs to be protected by using
qdisc_lock_tree instead of manually taking dev->queue_lock. Additionally
the qdisc stats_lock needs to be initialized to ingress_lock for ingress
qdiscs.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d053117e309fa2cc5fd9f39890bcadc148e79202
tree 6cad0c900beb67101bf4f84cbf55338d3d302e42
parent cc965189583f5a980e1fc6acaf708c47d3661a22
author Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:48 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:48 +0200

 net/core/dev.c          |    4 ++--
 net/sched/cls_route.c   |    4 ++--
 net/sched/sch_api.c     |   26 +++++++++++++++-----------
 net/sched/sch_generic.c |    6 +++++-
 net/sched/sch_ingress.c |    9 ++-------
 5 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7f31d0f..c8f5ea9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1747,10 +1747,10 @@ static int ing_filter(struct sk_buff *skb)
 
 		skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_INGRESS);
 
-		spin_lock(&dev->queue_lock);
+		spin_lock(&dev->ingress_lock);
 		if ((q = dev->qdisc_ingress) != NULL)
 			result = q->enqueue(skb, q);
-		spin_unlock(&dev->queue_lock);
+		spin_unlock(&dev->ingress_lock);
 
 	}
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index e92d716..cc941d0 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -89,9 +89,9 @@ static __inline__ int route4_fastmap_hash(u32 id, int iif)
 static inline
 void route4_reset_fastmap(struct net_device *dev, struct route4_head *head, u32 id)
 {
-	spin_lock_bh(&dev->queue_lock);
+	qdisc_lock_tree(dev);
 	memset(head->fastmap, 0, sizeof(head->fastmap));
-	spin_unlock_bh(&dev->queue_lock);
+	qdisc_unlock_tree(dev);
 }
 
 static inline void
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 0ce6914..8699e70 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -500,12 +500,16 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
+		sch->stats_lock = &dev->ingress_lock;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
-	} else if (handle == 0) {
-		handle = qdisc_alloc_handle(dev);
-		err = -ENOMEM;
-		if (handle == 0)
-			goto err_out3;
+	} else {
+		sch->stats_lock = &dev->queue_lock;
+		if (handle == 0) {
+			handle = qdisc_alloc_handle(dev);
+			err = -ENOMEM;
+			if (handle == 0)
+				goto err_out3;
+		}
 	}
 
 	sch->handle = handle;
@@ -654,9 +658,9 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			return err;
 		if (q) {
 			qdisc_notify(skb, n, clid, q, NULL);
-			spin_lock_bh(&dev->queue_lock);
+			qdisc_lock_tree(dev);
 			qdisc_destroy(q);
-			spin_unlock_bh(&dev->queue_lock);
+			qdisc_unlock_tree(dev);
 		}
 	} else {
 		qdisc_notify(skb, n, clid, NULL, q);
@@ -789,17 +793,17 @@ graft:
 		err = qdisc_graft(dev, p, clid, q, &old_q);
 		if (err) {
 			if (q) {
-				spin_lock_bh(&dev->queue_lock);
+				qdisc_lock_tree(dev);
 				qdisc_destroy(q);
-				spin_unlock_bh(&dev->queue_lock);
+				qdisc_unlock_tree(dev);
 			}
 			return err;
 		}
 		qdisc_notify(skb, n, clid, old_q, q);
 		if (old_q) {
-			spin_lock_bh(&dev->queue_lock);
+			qdisc_lock_tree(dev);
 			qdisc_destroy(old_q);
-			spin_unlock_bh(&dev->queue_lock);
+			qdisc_unlock_tree(dev);
 		}
 	}
 	return 0;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 1894eb7..3385ee5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -42,16 +42,20 @@
  * The idea is the following:
  * - enqueue, dequeue are serialized via top level device
  *   spinlock dev->queue_lock.
+ * - ingress filtering is serialized via top level device
+ *   spinlock dev->ingress_lock.
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
 
 void qdisc_lock_tree(struct net_device *dev)
 {
 	spin_lock_bh(&dev->queue_lock);
+	spin_lock(&dev->ingress_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
 {
+	spin_unlock(&dev->ingress_lock);
 	spin_unlock_bh(&dev->queue_lock);
 }
 
@@ -431,7 +435,6 @@ struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops)
 	sch->dequeue = ops->dequeue;
 	sch->dev = dev;
 	dev_hold(dev);
-	sch->stats_lock = &dev->queue_lock;
 	atomic_set(&sch->refcnt, 1);
 
 	return sch;
@@ -447,6 +450,7 @@ struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops,
 	sch = qdisc_alloc(dev, ops);
 	if (IS_ERR(sch))
 		goto errout;
+	sch->stats_lock = &dev->queue_lock;
 	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 1fb60ab..ad22dc6 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -248,16 +248,11 @@ ing_hook(unsigned int hook, struct sk_buff **pskb,
 		skb->dev ? (*pskb)->dev->name : "(no dev)",
 		skb->len);
 
-/*
-revisit later: Use a private since lock dev->queue_lock is also
-used on the egress (might slow things for an iota)
-*/
-
 	if (dev->qdisc_ingress) {
-		spin_lock(&dev->queue_lock);
+		spin_lock(&dev->ingress_lock);
 		if ((q = dev->qdisc_ingress) != NULL)
 			fwres = q->enqueue(skb, q);
-		spin_unlock(&dev->queue_lock);
+		spin_unlock(&dev->ingress_lock);
 	}
 
 	return fwres;

--------------090505010909010007020706--
