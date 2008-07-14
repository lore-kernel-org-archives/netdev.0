From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/14]: pkt_sched: qdisc_lookup() takes a netdev_queue
Date: Mon, 14 Jul 2008 16:00:18 -0700 (PDT)
Message-ID: <20080714.160018.239443255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758539AbYGNXAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 28C80C8C188
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Everyone outside of sch_api.c is using __qdisc_lookup() which
takes a netdev_queue.

Rename the existing qdisc_lookup() to qdisc_lookup_dev() and
mark it static.  Then rename __qdisc_lookup() to qdisc_lookup.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_sched.h |    3 +--
 net/sched/cls_api.c     |    4 ++--
 net/sched/sch_api.c     |   28 ++++++++++++++--------------
 3 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 88f07c0..6a6d546 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -79,8 +79,7 @@ extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 
 extern int register_qdisc(struct Qdisc_ops *qops);
 extern int unregister_qdisc(struct Qdisc_ops *qops);
-extern struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle);
-extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
+extern struct Qdisc *qdisc_lookup(struct netdev_queue *dev_queue, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 65ca460..d50c3b6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -179,7 +179,7 @@ static int tcf_prepare_one(struct tcf_op_parms *parms, struct tcf_op_info *tp,
 		tp->q = dev_queue->qdisc_sleeping;
 		parent = tp->q->handle;
 	} else {
-		tp->q = __qdisc_lookup(dev_queue, TC_H_MAJ(t->tcm_parent));
+		tp->q = qdisc_lookup(dev_queue, TC_H_MAJ(t->tcm_parent));
 		if (!tp->q)
 			return -EINVAL;
 	}
@@ -583,7 +583,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!tcm->tcm_parent)
 		q = dev_queue->qdisc_sleeping;
 	else
-		q = __qdisc_lookup(dev_queue, TC_H_MAJ(tcm->tcm_parent));
+		q = qdisc_lookup(dev_queue, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
 		goto out;
 	if ((cops = q->ops->cl_ops) == NULL)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7d646db..cd5ff65 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -183,7 +183,7 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
-struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
+struct Qdisc *qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
 {
 	struct Qdisc *q;
 
@@ -194,13 +194,13 @@ struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
 	return NULL;
 }
 
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
+static struct Qdisc *qdisc_lookup_dev(struct net_device *dev, u32 handle)
 {
 	unsigned int i;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q = __qdisc_lookup(txq, handle);
+		struct Qdisc *q = qdisc_lookup(txq, handle);
 		if (q)
 			return q;
 	}
@@ -444,7 +444,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 		autohandle += TC_H_MAKE(0x10000U, 0);
 		if (autohandle == TC_H_MAKE(TC_H_ROOT, 0))
 			autohandle = TC_H_MAKE(0x80000000U, 0);
-	} while	(qdisc_lookup(dev, autohandle) && --i > 0);
+	} while	(qdisc_lookup_dev(dev, autohandle) && --i > 0);
 
 	return i>0 ? autohandle : 0;
 }
@@ -505,7 +505,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
 			return;
 
-		sch = __qdisc_lookup(sch->dev_queue, TC_H_MAJ(parentid));
+		sch = qdisc_lookup(sch->dev_queue, TC_H_MAJ(parentid));
 		if (sch == NULL) {
 			WARN_ON(parentid != TC_H_ROOT);
 			return;
@@ -708,7 +708,7 @@ static int tc_get_prep_request(struct tc_qdisc_op_info *queue_arr, unsigned int
 			dev_queue = netdev_get_tx_queue(dev, i);
 
 		if (!clid) {
-			qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
+			qp->op_q = qdisc_lookup(dev_queue, tcm->tcm_handle);
 			if (!qp->op_q)
 				return -ENOENT;
 		} else {
@@ -718,8 +718,8 @@ static int tc_get_prep_request(struct tc_qdisc_op_info *queue_arr, unsigned int
 				if (TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS)) {
 					qp->op_q = dev_queue->qdisc;
 				} else {
-					qp->parent_q = __qdisc_lookup(dev_queue,
-								      TC_H_MAJ(clid));
+					qp->parent_q = qdisc_lookup(dev_queue,
+								    TC_H_MAJ(clid));
 					if (!qp->parent_q)
 						return -ENOENT;
 					qp->op_q = qdisc_leaf(qp->parent_q, clid);
@@ -1187,8 +1187,8 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (clid != TC_H_INGRESS) {
-				qp->parent_q = __qdisc_lookup(dev_queue,
-							      TC_H_MAJ(clid));
+				qp->parent_q = qdisc_lookup(dev_queue,
+							    TC_H_MAJ(clid));
 				if (!qp->parent_q)
 					return -ENOENT;
 				qp->op_q = qdisc_leaf(qp->parent_q, clid);
@@ -1212,8 +1212,8 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 				if (TC_H_MIN(tcm->tcm_handle))
 					return -EINVAL;
 
-				qp->op_q = __qdisc_lookup(dev_queue,
-							  tcm->tcm_handle);
+				qp->op_q = qdisc_lookup(dev_queue,
+							tcm->tcm_handle);
 				if (!qp->op_q)
 					goto create_and_graft;
 
@@ -1268,7 +1268,7 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 	} else {
 		if (!tcm->tcm_handle)
 			return -EINVAL;
-		qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
+		qp->op_q = qdisc_lookup(dev_queue, tcm->tcm_handle);
 	}
 
 	/* Change qdisc parameters */
@@ -1577,7 +1577,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	}
 
 	/* OK. Locate qdisc */
-	if ((q = __qdisc_lookup(dev_queue, qid)) == NULL)
+	if ((q = qdisc_lookup(dev_queue, qid)) == NULL)
 		return -ENOENT;
 
 	/* An check that it supports classes */
-- 
1.5.6.2.255.gbed62

