From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] qdisc: propagate errors from qdisc_create_dflt
Date: Sun, 17 Mar 2013 09:36:22 -0700
Message-ID: <20130317093622.088bfb3f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:65372 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351Ab3CQQg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:36:27 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so5783180pbb.34
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 09:36:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves the error handling of default queuing discipline.

The function qdisc_create_dflt masks the error code from the underlying
qdisc init function. Use IS_ERR() to propagate it back out to the callers.

Change the error handling of several qdisc's to report error rather than
silently substituting a noop qdisc. Change the log level of failure to
setup queue discipline from info to notice, since it is a real error.

In current kernel, the only likely error from pfifo_fast is out of memory,
but the API shouldn't be hiding errors.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 net/sched/sch_atm.c     |   13 +++++++++----
 net/sched/sch_cbq.c     |   13 +++++++++----
 net/sched/sch_drr.c     |   11 +++++++----
 net/sched/sch_dsmark.c  |   11 +++++++----
 net/sched/sch_fifo.c    |    9 ++++-----
 net/sched/sch_generic.c |   21 +++++++++++++--------
 net/sched/sch_hfsc.c    |   17 +++++++++++------
 net/sched/sch_htb.c     |   20 +++++++++++++++-----
 net/sched/sch_mq.c      |   11 +++++------
 net/sched/sch_mqprio.c  |    4 ++--
 net/sched/sch_multiq.c  |   20 ++++++++++----------
 net/sched/sch_prio.c    |   18 +++++++++---------
 net/sched/sch_qfq.c     |    8 ++++----
 13 files changed, 105 insertions(+), 71 deletions(-)

--- a/net/sched/sch_atm.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_atm.c	2013-03-16 09:52:20.301591904 -0700
@@ -275,8 +275,12 @@ static int atm_tc_change(struct Qdisc *s
 	}
 	flow->filter_list = NULL;
 	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
-	if (!flow->q)
-		flow->q = &noop_qdisc;
+	if (IS_ERR(flow->q)) {
+		error = PTR_ERR(flow->q);
+		kfree(flow);
+		return error;
+	}
+
 	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
 	flow->sock = sock;
 	flow->vcc = ATM_SD(sock);	/* speedup */
@@ -541,8 +545,9 @@ static int atm_tc_init(struct Qdisc *sch
 	list_add(&p->link.list, &p->flows);
 	p->link.q = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, sch->handle);
-	if (!p->link.q)
-		p->link.q = &noop_qdisc;
+	if (IS_ERR(p->link.q))
+		return PTR_ERR(p->link.q);
+
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
 	p->link.filter_list = NULL;
 	p->link.vcc = NULL;
--- a/net/sched/sch_cbq.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_cbq.c	2013-03-16 09:52:20.301591904 -0700
@@ -1382,8 +1382,10 @@ static int cbq_init(struct Qdisc *sch, s
 	q->link.qdisc = sch;
 	q->link.q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 				      sch->handle);
-	if (!q->link.q)
-		q->link.q = &noop_qdisc;
+	if (IS_ERR(q->link.q)) {
+		err = PTR_ERR(q->link.q);
+		goto put_rtab;
+	}
 
 	q->link.priority = TC_CBQ_MAXPRIO - 1;
 	q->link.priority2 = TC_CBQ_MAXPRIO - 1;
@@ -1881,8 +1883,11 @@ cbq_change_class(struct Qdisc *sch, u32
 	rtab = NULL;
 	cl->refcnt = 1;
 	cl->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
-	if (!cl->q)
-		cl->q = &noop_qdisc;
+	if (IS_ERR(cl->q)) {
+		err = PTR_ERR(cl->q);
+		kfree(cl);
+		goto failure;
+	}
 	cl->common.classid = classid;
 	cl->tparent = parent;
 	cl->qdisc = sch;
--- a/net/sched/sch_drr.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_drr.c	2013-03-16 09:52:20.301591904 -0700
@@ -112,8 +112,11 @@ static int drr_change_class(struct Qdisc
 	cl->quantum	   = quantum;
 	cl->qdisc	   = qdisc_create_dflt(sch->dev_queue,
 					       &pfifo_qdisc_ops, classid);
-	if (cl->qdisc == NULL)
-		cl->qdisc = &noop_qdisc;
+	if (IS_ERR(cl->qdisc)) {
+		err = PTR_ERR(cl->qdisc);
+		kfree(cl);
+		return err;
+	}
 
 	if (tca[TCA_RATE]) {
 		err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
@@ -220,8 +223,8 @@ static int drr_graft_class(struct Qdisc
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue,
 					&pfifo_qdisc_ops, cl->common.classid);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (IS_ERR(new))
+			return PTR_ERR(new);
 	}
 
 	sch_tree_lock(sch);
--- a/net/sched/sch_dsmark.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_dsmark.c	2013-03-16 09:52:20.301591904 -0700
@@ -63,8 +63,8 @@ static int dsmark_graft(struct Qdisc *sc
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					sch->handle);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (IS_ERR(new))
+			return PTR_ERR(new);
 	}
 
 	sch_tree_lock(sch);
@@ -381,8 +381,11 @@ static int dsmark_init(struct Qdisc *sch
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
 	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
-	if (p->q == NULL)
-		p->q = &noop_qdisc;
+	if (IS_ERR(p->q)) {
+		err = PTR_ERR(p->q);
+		kfree(mask);
+		goto errout;
+	}
 
 	pr_debug("dsmark_init: qdisc %p\n", p->q);
 
--- a/net/sched/sch_fifo.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_fifo.c	2013-03-16 09:52:20.301591904 -0700
@@ -164,17 +164,16 @@ struct Qdisc *fifo_create_dflt(struct Qd
 			       unsigned int limit)
 {
 	struct Qdisc *q;
-	int err = -ENOMEM;
 
 	q = qdisc_create_dflt(sch->dev_queue, ops, TC_H_MAKE(sch->handle, 1));
-	if (q) {
-		err = fifo_set_limit(q, limit);
+	if (!IS_ERR(q)) {
+		int err = fifo_set_limit(q, limit);
 		if (err < 0) {
 			qdisc_destroy(q);
-			q = NULL;
+			q = ERR_PTR(err);
 		}
 	}
 
-	return q ? : ERR_PTR(err);
+	return q;
 }
 EXPORT_SYMBOL(fifo_create_dflt);
--- a/net/sched/sch_generic.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_generic.c	2013-03-16 09:52:20.301591904 -0700
@@ -577,18 +577,18 @@ struct Qdisc *qdisc_create_dflt(struct n
 				struct Qdisc_ops *ops, unsigned int parentid)
 {
 	struct Qdisc *sch;
+	int err = 0;
 
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
-		goto errout;
-	sch->parent = parentid;
+		return sch;
 
-	if (!ops->init || ops->init(sch, NULL) == 0)
+	sch->parent = parentid;
+	if (!ops->init || !(err = ops->init(sch, NULL)))
 		return sch;
 
 	qdisc_destroy(sch);
-errout:
-	return NULL;
+	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
 
@@ -682,10 +682,12 @@ static void attach_one_default_qdisc(str
 	if (dev->tx_queue_len) {
 		qdisc = qdisc_create_dflt(dev_queue,
 					  &pfifo_fast_ops, TC_H_ROOT);
-		if (!qdisc) {
-			netdev_info(dev, "activation failed\n");
+		if (IS_ERR(qdisc)) {
+			netdev_notice(dev, "activation failed (%ld)\n",
+				    PTR_ERR(qdisc));
 			return;
 		}
+
 		if (!netif_is_multiqueue(dev))
 			qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
@@ -705,7 +707,10 @@ static void attach_default_qdiscs(struct
 		atomic_inc(&dev->qdisc->refcnt);
 	} else {
 		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
-		if (qdisc) {
+		if (IS_ERR(qdisc))
+			netdev_notice(dev, "mq activation failed (%ld)\n",
+				      PTR_ERR(qdisc));
+		else {
 			qdisc->ops->attach(qdisc);
 			dev->qdisc = qdisc;
 		}
--- a/net/sched/sch_hfsc.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_hfsc.c	2013-03-16 09:52:20.301591904 -0700
@@ -1085,8 +1085,12 @@ hfsc_change_class(struct Qdisc *sch, u32
 	cl->cl_parent = parent;
 	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
-	if (cl->qdisc == NULL)
-		cl->qdisc = &noop_qdisc;
+	if (IS_ERR(cl->qdisc)) {
+		err = PTR_ERR(cl->qdisc);
+		kfree(cl);
+		return err;
+	}
+
 	INIT_LIST_HEAD(&cl->children);
 	cl->vt_tree = RB_ROOT;
 	cl->cf_tree = RB_ROOT;
@@ -1208,8 +1212,8 @@ hfsc_graft_class(struct Qdisc *sch, unsi
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					cl->cl_common.classid);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (IS_ERR(new))
+			return PTR_ERR(new);
 	}
 
 	sch_tree_lock(sch);
@@ -1452,8 +1456,9 @@ hfsc_init_qdisc(struct Qdisc *sch, struc
 	q->root.sched   = q;
 	q->root.qdisc = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					  sch->handle);
-	if (q->root.qdisc == NULL)
-		q->root.qdisc = &noop_qdisc;
+	if (IS_ERR(q->root.qdisc))
+		return PTR_ERR(q->root.qdisc);
+
 	INIT_LIST_HEAD(&q->root.children);
 	q->root.vt_tree = RB_ROOT;
 	q->root.cf_tree = RB_ROOT;
--- a/net/sched/sch_htb.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_htb.c	2013-03-16 09:52:20.301591904 -0700
@@ -1135,10 +1135,12 @@ static int htb_graft(struct Qdisc *sch,
 
 	if (cl->level)
 		return -EINVAL;
-	if (new == NULL &&
-	    (new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-				     cl->common.classid)) == NULL)
-		return -ENOBUFS;
+	if (new == NULL) {
+		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
+					cl->common.classid);
+		if (IS_ERR(new))
+			return PTR_ERR(new);
+	}
 
 	sch_tree_lock(sch);
 	*old = cl->un.leaf.q;
@@ -1261,6 +1263,8 @@ static int htb_delete(struct Qdisc *sch,
 	if (!cl->level && htb_parent_last_child(cl)) {
 		new_q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					  cl->parent->common.classid);
+		if (IS_ERR(new_q))
+			return PTR_ERR(new_q);
 		last_child = 1;
 	}
 
@@ -1388,6 +1392,12 @@ static int htb_change_class(struct Qdisc
 		 */
 		new_q = qdisc_create_dflt(sch->dev_queue,
 					  &pfifo_qdisc_ops, classid);
+		if (IS_ERR(new_q)) {
+			err = PTR_ERR(new_q);
+			kfree(cl);
+			goto failure;
+		}
+
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;
@@ -1409,7 +1419,7 @@ static int htb_change_class(struct Qdisc
 			memset(&parent->un.inner, 0, sizeof(parent->un.inner));
 		}
 		/* leaf (we) needs elementary qdisc */
-		cl->un.leaf.q = new_q ? new_q : &noop_qdisc;
+		cl->un.leaf.q = new_q;
 
 		cl->common.classid = classid;
 		cl->parent = parent;
--- a/net/sched/sch_mq.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_mq.c	2013-03-16 09:52:20.301591904 -0700
@@ -60,18 +60,17 @@ static int mq_init(struct Qdisc *sch, st
 		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
-		if (qdisc == NULL)
-			goto err;
+		if (IS_ERR(qdisc)) {
+			mq_destroy(sch);
+			return PTR_ERR(qdisc);
+		}
+
 		priv->qdiscs[ntx] = qdisc;
 		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	sch->flags |= TCQ_F_MQROOT;
 	return 0;
-
-err:
-	mq_destroy(sch);
-	return -ENOMEM;
 }
 
 static void mq_attach(struct Qdisc *sch)
--- a/net/sched/sch_mqprio.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_mqprio.c	2013-03-16 09:52:20.305591852 -0700
@@ -127,8 +127,8 @@ static int mqprio_init(struct Qdisc *sch
 		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
-		if (qdisc == NULL) {
-			err = -ENOMEM;
+		if (IS_ERR(qdisc)) {
+			err = PTR_ERR(qdisc);
 			goto err;
 		}
 		priv->qdiscs[i] = qdisc;
--- a/net/sched/sch_multiq.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_multiq.c	2013-03-16 09:52:20.305591852 -0700
@@ -232,18 +232,18 @@ static int multiq_tune(struct Qdisc *sch
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle,
 							    i + 1));
-			if (child) {
-				sch_tree_lock(sch);
-				old = q->queues[i];
-				q->queues[i] = child;
+			if (IS_ERR(child))
+				return PTR_ERR(child);
 
-				if (old != &noop_qdisc) {
-					qdisc_tree_decrease_qlen(old,
-								 old->q.qlen);
-					qdisc_destroy(old);
-				}
-				sch_tree_unlock(sch);
+			sch_tree_lock(sch);
+			old = q->queues[i];
+			q->queues[i] = child;
+
+			if (old != &noop_qdisc) {
+				qdisc_tree_decrease_qlen(old, old->q.qlen);
+				qdisc_destroy(old);
 			}
+			sch_tree_unlock(sch);
 		}
 	}
 	return 0;
--- a/net/sched/sch_prio.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_prio.c	2013-03-16 09:53:12.608915409 -0700
@@ -202,18 +202,18 @@ static int prio_tune(struct Qdisc *sch,
 			child = qdisc_create_dflt(sch->dev_queue,
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle, i + 1));
-			if (child) {
-				sch_tree_lock(sch);
-				old = q->queues[i];
-				q->queues[i] = child;
+			if (IS_ERR(child))
+				return PTR_ERR(child);
 
-				if (old != &noop_qdisc) {
-					qdisc_tree_decrease_qlen(old,
-								 old->q.qlen);
-					qdisc_destroy(old);
-				}
-				sch_tree_unlock(sch);
+			sch_tree_lock(sch);
+			old = q->queues[i];
+			q->queues[i] = child;
+
+			if (old != &noop_qdisc) {
+				qdisc_tree_decrease_qlen(old, old->q.qlen);
+				qdisc_destroy(old);
 			}
+			sch_tree_unlock(sch);
 		}
 	}
 	return 0;
--- a/net/sched/sch_qfq.c	2013-03-16 09:52:16.785637376 -0700
+++ b/net/sched/sch_qfq.c	2013-03-16 09:52:20.305591852 -0700
@@ -475,8 +475,8 @@ static int qfq_change_class(struct Qdisc
 
 	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
-	if (cl->qdisc == NULL)
-		cl->qdisc = &noop_qdisc;
+	if (IS_ERR(cl->qdisc))
+		return PTR_ERR(cl->qdisc);
 
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
@@ -607,8 +607,8 @@ static int qfq_graft_class(struct Qdisc
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue,
 					&pfifo_qdisc_ops, cl->common.classid);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (IS_ERR(new))
+			return PTR_ERR(new);
 	}
 
 	sch_tree_lock(sch);
