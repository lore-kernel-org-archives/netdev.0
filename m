From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 09/13] net_sched: redefine qdisc_create_dflt()
Date: Tue,  4 Nov 2014 09:56:32 -0800
Message-ID: <1415123796-8093-10-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35545 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbaKDR44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:56 -0500
Received: by mail-pd0-f174.google.com with SMTP id p10so14032368pdj.19
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:56 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 6da7c8fcbcbdb50ec68c61 (qdisc: allow
setting default queuing discipline) we can set default qdisc now.
The API qdisc_create_dflt() is now confusing since it doesn't
create the default one, instead it create a specified one. Rename
it to qdisc_create_internal(), and let qdisc_create_dflt() really
create a default one.

Cc: David S. Miller <davem@davemloft.net>
Cc: stephen hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 11 +++++++++--
 net/sched/sch_atm.c       |  6 +++---
 net/sched/sch_cbq.c       | 11 ++++++-----
 net/sched/sch_drr.c       |  9 +++++----
 net/sched/sch_dsmark.c    |  6 +++---
 net/sched/sch_fifo.c      |  2 +-
 net/sched/sch_generic.c   | 13 ++++++-------
 net/sched/sch_hfsc.c      | 12 ++++++------
 net/sched/sch_htb.c       | 12 ++++++------
 net/sched/sch_mq.c        |  2 +-
 net/sched/sch_mqprio.c    |  2 +-
 net/sched/sch_multiq.c    |  6 +++---
 net/sched/sch_prio.c      |  6 +++---
 net/sched/sch_qfq.c       |  8 ++++----
 14 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e02d250..ba3b6bf 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -403,13 +403,20 @@ void qdisc_destroy(struct Qdisc *qdisc);
 void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
 struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 			  const struct Qdisc_ops *ops);
-struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
-				const struct Qdisc_ops *ops, u32 parentid);
+struct Qdisc *qdisc_create_internal(struct netdev_queue *dev_queue,
+				    const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
 void tcf_destroy(struct tcf_proto *tp);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 
+static inline
+struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
+				unsigned int parentid)
+{
+	return qdisc_create_internal(dev_queue, default_qdisc_ops, parentid);
+}
+
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index a26e503..29f7067 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -274,7 +274,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto err_out;
 	}
 	RCU_INIT_POINTER(flow->filter_list, NULL);
-	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
+	flow->q = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
 	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
@@ -541,8 +541,8 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	INIT_LIST_HEAD(&p->flows);
 	INIT_LIST_HEAD(&p->link.list);
 	list_add(&p->link.list, &p->flows);
-	p->link.q = qdisc_create_dflt(sch->dev_queue,
-				      &pfifo_qdisc_ops, sch->handle);
+	p->link.q = qdisc_create_internal(sch->dev_queue,
+					  &pfifo_qdisc_ops, sch->handle);
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index ad2905a..af9eaef 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1366,8 +1366,8 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.sibling = &q->link;
 	q->link.common.classid = sch->handle;
 	q->link.qdisc = sch;
-	q->link.q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-				      sch->handle);
+	q->link.q = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					  sch->handle);
 	if (!q->link.q)
 		q->link.q = &noop_qdisc;
 
@@ -1613,8 +1613,9 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev_queue,
-					&pfifo_qdisc_ops, cl->common.classid);
+		new = qdisc_create_internal(sch->dev_queue,
+					    &pfifo_qdisc_ops,
+					    cl->common.classid);
 		if (new == NULL)
 			return -ENOBUFS;
 	} else {
@@ -1863,7 +1864,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
-	cl->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
+	cl->q = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!cl->q)
 		cl->q = &noop_qdisc;
 	cl->common.classid = classid;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 4007e40..c289528 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -111,8 +111,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->refcnt	   = 1;
 	cl->common.classid = classid;
 	cl->quantum	   = quantum;
-	cl->qdisc	   = qdisc_create_dflt(sch->dev_queue,
-					       &pfifo_qdisc_ops, classid);
+	cl->qdisc	   = qdisc_create_internal(sch->dev_queue,
+						   &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 
@@ -220,8 +220,9 @@ static int drr_graft_class(struct Qdisc *sch, unsigned long arg,
 	struct drr_class *cl = (struct drr_class *)arg;
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev_queue,
-					&pfifo_qdisc_ops, cl->common.classid);
+		new = qdisc_create_internal(sch->dev_queue,
+					    &pfifo_qdisc_ops,
+					    cl->common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 0a20722..a11a5b9 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -61,8 +61,8 @@ static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 		 __func__, sch, p, new, old);
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-					sch->handle);
+		new = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					    sch->handle);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
@@ -379,7 +379,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
-	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
+	p->q = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 55f5212..c21a037 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -168,7 +168,7 @@ struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 	struct Qdisc *q;
 	int err = -ENOMEM;
 
-	q = qdisc_create_dflt(sch->dev_queue, ops, TC_H_MAKE(sch->handle, 1));
+	q = qdisc_create_internal(sch->dev_queue, ops, TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		err = fifo_set_limit(q, limit);
 		if (err < 0) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4550a46..2b1931d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -623,9 +623,9 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	return ERR_PTR(err);
 }
 
-struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
-				const struct Qdisc_ops *ops,
-				unsigned int parentid)
+struct Qdisc *qdisc_create_internal(struct netdev_queue *dev_queue,
+				    const struct Qdisc_ops *ops,
+				    unsigned int parentid)
 {
 	struct Qdisc *sch;
 
@@ -644,7 +644,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 errout:
 	return NULL;
 }
-EXPORT_SYMBOL(qdisc_create_dflt);
+EXPORT_SYMBOL(qdisc_create_internal);
 
 /* Under qdisc_lock(qdisc) and BH! */
 
@@ -737,8 +737,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
 	struct Qdisc *qdisc = &noqueue_qdisc;
 
 	if (dev->tx_queue_len) {
-		qdisc = qdisc_create_dflt(dev_queue,
-					  default_qdisc_ops, TC_H_ROOT);
+		qdisc = qdisc_create_dflt(dev_queue, TC_H_ROOT);
 		if (!qdisc) {
 			netdev_info(dev, "activation failed\n");
 			return;
@@ -761,7 +760,7 @@ static void attach_default_qdiscs(struct net_device *dev)
 		dev->qdisc = txq->qdisc_sleeping;
 		atomic_inc(&dev->qdisc->refcnt);
 	} else {
-		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
+		qdisc = qdisc_create_internal(txq, &mq_qdisc_ops, TC_H_ROOT);
 		if (qdisc) {
 			dev->qdisc = qdisc;
 			qdisc->ops->attach(qdisc);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 3cc44a8..5741e39 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1084,8 +1084,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->refcnt    = 1;
 	cl->sched     = q;
 	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
-				      &pfifo_qdisc_ops, classid);
+	cl->qdisc = qdisc_create_internal(sch->dev_queue,
+					  &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 	INIT_LIST_HEAD(&cl->children);
@@ -1207,8 +1207,8 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-					cl->cl_common.classid);
+		new = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					    cl->cl_common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
@@ -1449,8 +1449,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
 	q->root.sched   = q;
-	q->root.qdisc = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-					  sch->handle);
+	q->root.qdisc = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					      sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
 	INIT_LIST_HEAD(&q->root.children);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b88a159..288e6c2 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1160,8 +1160,8 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level)
 		return -EINVAL;
 	if (new == NULL &&
-	    (new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-				     cl->common.classid)) == NULL)
+	    (new = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					 cl->common.classid)) == NULL)
 		return -ENOBUFS;
 
 	sch_tree_lock(sch);
@@ -1285,8 +1285,8 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
-		new_q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-					  cl->parent->common.classid);
+		new_q = qdisc_create_internal(sch->dev_queue, &pfifo_qdisc_ops,
+					      cl->parent->common.classid);
 		last_child = 1;
 	}
 
@@ -1424,8 +1424,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		 * so that can't be used inside of sch_tree_lock
 		 * -- thanks to Karlis Peisenieks
 		 */
-		new_q = qdisc_create_dflt(sch->dev_queue,
-					  &pfifo_qdisc_ops, classid);
+		new_q = qdisc_create_internal(sch->dev_queue,
+					      &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index cab9fc2..03b8069 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -57,7 +57,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		dev_queue = netdev_get_tx_queue(dev, ntx);
-		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
+		qdisc = qdisc_create_dflt(dev_queue,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index dc208c2..990368f 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -124,7 +124,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		dev_queue = netdev_get_tx_queue(dev, i);
-		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
+		qdisc = qdisc_create_dflt(dev_queue,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
 		if (qdisc == NULL) {
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index af52ec8..1ff48bb 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -226,9 +226,9 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child, *old;
-			child = qdisc_create_dflt(sch->dev_queue,
-						  &pfifo_qdisc_ops,
-						  TC_H_MAKE(sch->handle,
+			child = qdisc_create_internal(sch->dev_queue,
+						      &pfifo_qdisc_ops,
+						      TC_H_MAKE(sch->handle,
 							    i + 1));
 			if (child) {
 				sch_tree_lock(sch);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 200b3b0..0cf1c6c 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -201,9 +201,9 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child, *old;
 
-			child = qdisc_create_dflt(sch->dev_queue,
-						  &pfifo_qdisc_ops,
-						  TC_H_MAKE(sch->handle, i + 1));
+			child = qdisc_create_internal(sch->dev_queue,
+						      &pfifo_qdisc_ops,
+						      TC_H_MAKE(sch->handle, i + 1));
 			if (child) {
 				sch_tree_lock(sch);
 				old = q->queues[i];
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index a847e3a..7eb38b0 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -479,8 +479,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->common.classid = classid;
 	cl->deficit = lmax;
 
-	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
-				      &pfifo_qdisc_ops, classid);
+	cl->qdisc = qdisc_create_internal(sch->dev_queue,
+					  &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 
@@ -613,8 +613,8 @@ static int qfq_graft_class(struct Qdisc *sch, unsigned long arg,
 	struct qfq_class *cl = (struct qfq_class *)arg;
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev_queue,
-					&pfifo_qdisc_ops, cl->common.classid);
+		new = qdisc_create_internal(sch->dev_queue,
+					    &pfifo_qdisc_ops, cl->common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
-- 
1.8.3.1
