From: David Miller <davem@davemloft.net>
Subject: [PATCH 29/31]: pkt_sched: Add multiqueue handling to qdisc_graft().
Date: Thu, 17 Jul 2008 05:18:25 -0700 (PDT)
Message-ID: <20080717.051825.179223431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759126AbYGQMSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:18:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move the destruction of the old queue into qdisc_graft().

When operating on a root qdisc (ie. "parent == NULL"), apply
the operation to all queues.  The caller has grabbed a single
implicit reference for this graft, therefore when we apply the
change to more than one queue we must grab additional qdisc
references.

Otherwise, we are operating on a class of a specific parent qdisc, and
therefore no multiqueue handling is necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |  101 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 59 insertions(+), 42 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7492489..b3ef830 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -435,28 +435,22 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 	return i>0 ? autohandle : 0;
 }
 
-/* Attach toplevel qdisc to device dev */
+/* Attach toplevel qdisc to device queue. */
 
-static struct Qdisc *
-dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
+static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+				     struct Qdisc *qdisc)
 {
-	struct netdev_queue *dev_queue;
 	spinlock_t *root_lock;
 	struct Qdisc *oqdisc;
 	int ingress;
 
-	if (dev->flags & IFF_UP)
-		dev_deactivate(dev);
-
 	ingress = 0;
 	if (qdisc && qdisc->flags&TCQ_F_INGRESS)
 		ingress = 1;
 
 	if (ingress) {
-		dev_queue = &dev->rx_queue;
 		oqdisc = dev_queue->qdisc;
 	} else {
-		dev_queue = netdev_get_tx_queue(dev, 0);
 		oqdisc = dev_queue->qdisc_sleeping;
 	}
 
@@ -487,9 +481,6 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 
 	spin_unlock_bh(root_lock);
 
-	if (dev->flags & IFF_UP)
-		dev_activate(dev);
-
 	return oqdisc;
 }
 
@@ -521,26 +512,66 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
-/* Graft qdisc "new" to class "classid" of qdisc "parent" or
-   to device "dev".
+static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid,
+			       struct Qdisc *old, struct Qdisc *new)
+{
+	if (new || old)
+		qdisc_notify(skb, n, clid, old, new);
 
-   Old qdisc is not destroyed but returned in *old.
+	if (old) {
+		spin_lock_bh(&old->q.lock);
+		qdisc_destroy(old);
+		spin_unlock_bh(&old->q.lock);
+	}
+}
+
+/* Graft qdisc "new" to class "classid" of qdisc "parent" or
+ * to device "dev".
+ *
+ * When appropriate send a netlink notification using 'skb'
+ * and "n".
+ *
+ * On success, destroy old qdisc.
  */
 
 static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
-		       u32 classid,
-		       struct Qdisc *new, struct Qdisc **old)
+		       struct sk_buff *skb, struct nlmsghdr *n, u32 classid,
+		       struct Qdisc *new, struct Qdisc *old)
 {
+	struct Qdisc *q = old;
 	int err = 0;
-	struct Qdisc *q = *old;
-
 
 	if (parent == NULL) {
-		if (q && q->flags&TCQ_F_INGRESS) {
-			*old = dev_graft_qdisc(dev, q);
-		} else {
-			*old = dev_graft_qdisc(dev, new);
+		unsigned int i, num_q, ingress;
+
+		ingress = 0;
+		num_q = dev->num_tx_queues;
+		if (q && q->flags & TCQ_F_INGRESS) {
+			num_q = 1;
+			ingress = 1;
 		}
+
+		if (dev->flags & IFF_UP)
+			dev_deactivate(dev);
+
+		for (i = 0; i < num_q; i++) {
+			struct netdev_queue *dev_queue = &dev->rx_queue;
+
+			if (!ingress)
+				dev_queue = netdev_get_tx_queue(dev, i);
+
+			if (ingress) {
+				old = dev_graft_qdisc(dev_queue, q);
+			} else {
+				old = dev_graft_qdisc(dev_queue, new);
+				if (new && i > 0)
+					atomic_inc(&new->refcnt);
+			}
+			notify_and_destroy(skb, n, classid, old, new);
+		}
+
+		if (dev->flags & IFF_UP)
+			dev_activate(dev);
 	} else {
 		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
 
@@ -549,10 +580,12 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		if (cops) {
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
-				err = cops->graft(parent, cl, new, old);
+				err = cops->graft(parent, cl, new, &old);
 				cops->put(parent, cl);
 			}
 		}
+		if (!err)
+			notify_and_destroy(skb, n, classid, old, new);
 	}
 	return err;
 }
@@ -773,16 +806,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			return -EINVAL;
 		if (q->handle == 0)
 			return -ENOENT;
-		if ((err = qdisc_graft(dev, p, clid, NULL, &q)) != 0)
+		if ((err = qdisc_graft(dev, p, skb, n, clid, NULL, q)) != 0)
 			return err;
-		if (q) {
-			spinlock_t *root_lock = qdisc_root_lock(q);
-
-			qdisc_notify(skb, n, clid, q, NULL);
-			spin_unlock_bh(root_lock);
-			qdisc_destroy(q);
-			spin_unlock_bh(root_lock);
-		}
 	} else {
 		qdisc_notify(skb, n, clid, NULL, q);
 	}
@@ -923,10 +948,9 @@ create_n_graft:
 
 graft:
 	if (1) {
-		struct Qdisc *old_q = NULL;
 		spinlock_t *root_lock;
 
-		err = qdisc_graft(dev, p, clid, q, &old_q);
+		err = qdisc_graft(dev, p, skb, n, clid, q, NULL);
 		if (err) {
 			if (q) {
 				root_lock = qdisc_root_lock(q);
@@ -936,13 +960,6 @@ graft:
 			}
 			return err;
 		}
-		qdisc_notify(skb, n, clid, old_q, q);
-		if (old_q) {
-			root_lock = qdisc_root_lock(old_q);
-			spin_lock_bh(root_lock);
-			qdisc_destroy(old_q);
-			spin_unlock_bh(root_lock);
-		}
 	}
 	return 0;
 }
-- 
1.5.6.2.255.gbed62

