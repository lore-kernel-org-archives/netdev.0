From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/04]: Eliminate qdisc_tree_lock
Date: Mon, 16 Apr 2007 09:51:57 +0200 (MEST)
Message-ID: <20070416074954.19262.99623.sendpatchset@localhost.localdomain>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34171 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbXDPHv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:51:58 -0400
In-Reply-To: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Eliminate qdisc_tree_lock

Since we're now holding the rtnl during the entire dump operation, we
can remove qdisc_tree_lock, whose only purpose is to protect dump
callbacks from concurrent changes to the qdisc tree.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cc965189583f5a980e1fc6acaf708c47d3661a22
tree faede9cc5c6b86b39517c56c71caa6942e748f20
parent 49310148887f3d7a6b78809b0a771628be4ef0a8
author Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:39 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:39 +0200

 include/net/pkt_sched.h |    2 --
 net/sched/cls_api.c     |    2 --
 net/sched/sch_api.c     |   22 +++-------------------
 net/sched/sch_generic.c |   29 +++++++----------------------
 4 files changed, 10 insertions(+), 45 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b2cc9a8..5754d53 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -13,8 +13,6 @@ struct qdisc_walker
 	int	(*fn)(struct Qdisc *, unsigned long cl, struct qdisc_walker *);
 };
 
-extern rwlock_t qdisc_tree_lock;
-
 #define QDISC_ALIGNTO		32
 #define QDISC_ALIGN(len)	(((len) + QDISC_ALIGNTO-1) & ~(QDISC_ALIGNTO-1))
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index ca3da50..ebf94ed 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -400,7 +400,6 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if ((dev = dev_get_by_index(tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
-	read_lock(&qdisc_tree_lock);
 	if (!tcm->tcm_parent)
 		q = dev->qdisc_sleeping;
 	else
@@ -457,7 +456,6 @@ errout:
 	if (cl)
 		cops->put(q, cl);
 out:
-	read_unlock(&qdisc_tree_lock);
 	dev_put(dev);
 	return skb->len;
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2e863bd..0ce6914 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -191,7 +191,7 @@ int unregister_qdisc(struct Qdisc_ops *qops)
    (root qdisc, all its children, children of children etc.)
  */
 
-static struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle)
+struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	struct Qdisc *q;
 
@@ -202,16 +202,6 @@ static struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle)
 	return NULL;
 }
 
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
-{
-	struct Qdisc *q;
-
-	read_lock(&qdisc_tree_lock);
-	q = __qdisc_lookup(dev, handle);
-	read_unlock(&qdisc_tree_lock);
-	return q;
-}
-
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 {
 	unsigned long cl;
@@ -405,7 +395,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 	if (n == 0)
 		return;
 	while ((parentid = sch->parent)) {
-		sch = __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
@@ -905,7 +895,6 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 			continue;
 		if (idx > s_idx)
 			s_q_idx = 0;
-		read_lock(&qdisc_tree_lock);
 		q_idx = 0;
 		list_for_each_entry(q, &dev->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
@@ -913,13 +902,10 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 				continue;
 			}
 			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
-					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
-				read_unlock(&qdisc_tree_lock);
+					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
 				goto done;
-			}
 			q_idx++;
 		}
-		read_unlock(&qdisc_tree_lock);
 	}
 
 done:
@@ -1142,7 +1128,6 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	read_lock(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
@@ -1164,7 +1149,6 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 		t++;
 	}
-	read_unlock(&qdisc_tree_lock);
 
 	cb->args[0] = t;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 52eb343..1894eb7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -36,34 +36,23 @@
 
 /* Main transmission queue. */
 
-/* Main qdisc structure lock.
-
-   However, modifications
-   to data, participating in scheduling must be additionally
-   protected with dev->queue_lock spinlock.
-
-   The idea is the following:
-   - enqueue, dequeue are serialized via top level device
-     spinlock dev->queue_lock.
-   - tree walking is protected by read_lock(qdisc_tree_lock)
-     and this lock is used only in process context.
-   - updates to tree are made only under rtnl semaphore,
-     hence this lock may be made without local bh disabling.
-
-   qdisc_tree_lock must be grabbed BEFORE dev->queue_lock!
+/* Modifications to data participating in scheduling must be protected with
+ * dev->queue_lock spinlock.
+ *
+ * The idea is the following:
+ * - enqueue, dequeue are serialized via top level device
+ *   spinlock dev->queue_lock.
+ * - updates to tree and tree walking are only done under the rtnl mutex.
  */
-DEFINE_RWLOCK(qdisc_tree_lock);
 
 void qdisc_lock_tree(struct net_device *dev)
 {
-	write_lock(&qdisc_tree_lock);
 	spin_lock_bh(&dev->queue_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
 {
 	spin_unlock_bh(&dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
 }
 
 /*
@@ -528,15 +517,11 @@ void dev_activate(struct net_device *dev)
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-			write_lock(&qdisc_tree_lock);
 			list_add_tail(&qdisc->list, &dev->qdisc_list);
-			write_unlock(&qdisc_tree_lock);
 		} else {
 			qdisc =  &noqueue_qdisc;
 		}
-		write_lock(&qdisc_tree_lock);
 		dev->qdisc_sleeping = qdisc;
-		write_unlock(&qdisc_tree_lock);
 	}
 
 	if (!netif_carrier_ok(dev))
