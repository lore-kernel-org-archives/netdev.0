From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/14]: pkt_sched: Use __qdisc_lookup() more consistently
 and export.
Date: Mon, 14 Jul 2008 15:59:55 -0700 (PDT)
Message-ID: <20080714.155955.103946437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758506AbYGNW7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 798F9C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We should make lookups whenever possible in the namespace of a
specific queue.

Export so we can use in the classifier API in subsequent changesets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_sched.h |    1 +
 net/sched/sch_api.c     |   17 ++++++++++-------
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 5d9ffe8..88f07c0 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -79,6 +79,7 @@ extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 
 extern int register_qdisc(struct Qdisc_ops *qops);
 extern int unregister_qdisc(struct Qdisc_ops *qops);
+extern struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle);
 extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d190c49..7d646db 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -183,7 +183,7 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
-static struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
+struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
 {
 	struct Qdisc *q;
 
@@ -505,7 +505,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
 			return;
 
-		sch = qdisc_lookup(qdisc_dev(sch), TC_H_MAJ(parentid));
+		sch = __qdisc_lookup(sch->dev_queue, TC_H_MAJ(parentid));
 		if (sch == NULL) {
 			WARN_ON(parentid != TC_H_ROOT);
 			return;
@@ -718,7 +718,8 @@ static int tc_get_prep_request(struct tc_qdisc_op_info *queue_arr, unsigned int
 				if (TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS)) {
 					qp->op_q = dev_queue->qdisc;
 				} else {
-					qp->parent_q = qdisc_lookup(dev, TC_H_MAJ(clid));
+					qp->parent_q = __qdisc_lookup(dev_queue,
+								      TC_H_MAJ(clid));
 					if (!qp->parent_q)
 						return -ENOENT;
 					qp->op_q = qdisc_leaf(qp->parent_q, clid);
@@ -1186,7 +1187,8 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (clid != TC_H_INGRESS) {
-				qp->parent_q = qdisc_lookup(dev, TC_H_MAJ(clid));
+				qp->parent_q = __qdisc_lookup(dev_queue,
+							      TC_H_MAJ(clid));
 				if (!qp->parent_q)
 					return -ENOENT;
 				qp->op_q = qdisc_leaf(qp->parent_q, clid);
@@ -1210,7 +1212,8 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 				if (TC_H_MIN(tcm->tcm_handle))
 					return -EINVAL;
 
-				qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
+				qp->op_q = __qdisc_lookup(dev_queue,
+							  tcm->tcm_handle);
 				if (!qp->op_q)
 					goto create_and_graft;
 
@@ -1265,7 +1268,7 @@ static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
 	} else {
 		if (!tcm->tcm_handle)
 			return -EINVAL;
-		qp->op_q = qdisc_lookup(dev, tcm->tcm_handle);
+		qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
 	}
 
 	/* Change qdisc parameters */
@@ -1574,7 +1577,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	}
 
 	/* OK. Locate qdisc */
-	if ((q = qdisc_lookup(dev, qid)) == NULL)
+	if ((q = __qdisc_lookup(dev_queue, qid)) == NULL)
 		return -ENOENT;
 
 	/* An check that it supports classes */
-- 
1.5.6.2.255.gbed62

