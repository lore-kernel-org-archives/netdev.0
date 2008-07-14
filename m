From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/14]: pkt_sched: Make classful ->graft() three stage.
Date: Mon, 14 Jul 2008 15:59:28 -0700 (PDT)
Message-ID: <20080714.155928.254035359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758325AbYGNW7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5CFE6C8C188
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In order to unwind from errors we need to split the ->graft()
operation for classful qdiscs into three seperate operations.

1) Prepare.

   This validates arguments, and allocated any resources if
   necessary.

2) Commit.

   This actually commits the graft operation, it must not fail.

3) Cancel.

   This undoes the operations done by a Prepare.  It frees
   any resources allocated by Prepare.  This is only invoked
   if the Commit was not performed.

This is part of the plan to replicate qdisc changes across
more than one netdev_queue.  It will be done in three
phases.  Allocate qdiscs, prepare grafts, and if all goes
well commit them.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    9 +++++-
 net/sched/sch_api.c       |    8 +++++-
 net/sched/sch_atm.c       |   28 +++++++++++++++-----
 net/sched/sch_cbq.c       |   61 ++++++++++++++++++++++++++++----------------
 net/sched/sch_dsmark.c    |   40 ++++++++++++++++++++---------
 net/sched/sch_hfsc.c      |   45 +++++++++++++++++++++++---------
 net/sched/sch_htb.c       |   59 ++++++++++++++++++++++++++++++-------------
 net/sched/sch_ingress.c   |    8 +++---
 net/sched/sch_netem.c     |   20 ++++++++++++---
 net/sched/sch_prio.c      |   24 ++++++++++++++---
 net/sched/sch_red.c       |   21 ++++++++++++---
 net/sched/sch_tbf.c       |   20 ++++++++++++---
 12 files changed, 247 insertions(+), 96 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b47f556..5318c37 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -56,8 +56,13 @@ struct Qdisc
 struct Qdisc_class_ops
 {
 	/* Child qdisc manipulation */
-	int			(*graft)(struct Qdisc *, unsigned long cl,
-					struct Qdisc *, struct Qdisc **);
+	void *			(*prepare_graft)(struct Qdisc *, unsigned long cl,
+						 struct Qdisc *);
+	void			(*cancel_graft)(struct Qdisc *, unsigned long cl,
+						struct Qdisc *, void *);
+	void			(*commit_graft)(struct Qdisc *, unsigned long cl,
+						struct Qdisc *, void *,
+						struct Qdisc **);
 	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
 	void			(*qlen_notify)(struct Qdisc *, unsigned long);
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b0da006..fdc79b4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -547,7 +547,13 @@ static int qdisc_graft(struct netdev_queue *dev_queue, struct Qdisc *parent,
 		if (cops) {
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
-				err = cops->graft(parent, cl, new, old);
+				void *gp = cops->prepare_graft(parent, cl, new);
+
+				err = 0;
+				if (IS_ERR(gp))
+					err = PTR_ERR(gp);
+				else
+					cops->commit_graft(parent, cl, new, gp, old);
 				cops->put(parent, cl);
 			}
 		}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0de757e..c084050 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -90,22 +90,34 @@ static inline struct atm_flow_data *lookup_flow(struct Qdisc *sch, u32 classid)
 	return flow;
 }
 
-static int atm_tc_graft(struct Qdisc *sch, unsigned long arg,
-			struct Qdisc *new, struct Qdisc **old)
+static void *atm_prepare_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	pr_debug("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",
-		sch, p, flow, new, old);
 	if (!find_flow(p, flow))
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
+
+	return NULL;
+}
+
+static void atm_commit_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem,
+			     struct Qdisc **old)
+{
+	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
+
 	if (!new)
 		new = &noop_qdisc;
 	*old = xchg(&flow->q, new);
 	if (*old)
 		qdisc_reset(*old);
-	return 0;
+}
+
+static void atm_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem)
+{
 }
 
 static struct Qdisc *atm_tc_leaf(struct Qdisc *sch, unsigned long cl)
@@ -672,7 +684,9 @@ static int atm_tc_dump(struct Qdisc *sch, struct sk_buff *skb)
 }
 
 static const struct Qdisc_class_ops atm_class_ops = {
-	.graft		= atm_tc_graft,
+	.prepare_graft	= atm_prepare_graft,
+	.commit_graft	= atm_commit_graft,
+	.cancel_graft	= atm_cancel_graft,
 	.leaf		= atm_tc_leaf,
 	.get		= atm_tc_get,
 	.put		= atm_tc_put,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4efc836..224b9c0 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1639,33 +1639,48 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
 }
 
-static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
+static void *cbq_prepare_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new)
 {
 	struct cbq_class *cl = (struct cbq_class*)arg;
+	void *ret = NULL;
+
+	if (!new) {
+		ret = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+					&pfifo_qdisc_ops,
+					cl->common.classid);
+		if (!ret)
+			return ERR_PTR(-ENOBUFS);
+	}
 
-	if (cl) {
-		if (new == NULL) {
-			new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-						&pfifo_qdisc_ops,
-						cl->common.classid);
-			if (new == NULL)
-				return -ENOBUFS;
-		} else {
+	return ret;
+}
+
+static void cbq_commit_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem,
+			     struct Qdisc **old)
+{
+	struct cbq_class *cl = (struct cbq_class*)arg;
+
+	if (mem)
+		new = mem;
 #ifdef CONFIG_NET_CLS_ACT
-			if (cl->police == TC_POLICE_RECLASSIFY)
-				new->reshape_fail = cbq_reshape_fail;
+	else if (cl->police == TC_POLICE_RECLASSIFY)
+		new->reshape_fail = cbq_reshape_fail;
 #endif
-		}
-		sch_tree_lock(sch);
-		*old = xchg(&cl->q, new);
-		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-		qdisc_reset(*old);
-		sch_tree_unlock(sch);
 
-		return 0;
-	}
-	return -ENOENT;
+	sch_tree_lock(sch);
+	*old = xchg(&cl->q, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+}
+
+static void cbq_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem)
+{
+	if (mem)
+		qdisc_destroy(mem);
 }
 
 static struct Qdisc *
@@ -2032,7 +2047,9 @@ static void cbq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 }
 
 static const struct Qdisc_class_ops cbq_class_ops = {
-	.graft		=	cbq_graft,
+	.prepare_graft	=	cbq_prepare_graft,
+	.commit_graft	=	cbq_commit_graft,
+	.cancel_graft	=	cbq_cancel_graft,
 	.leaf		=	cbq_leaf,
 	.qlen_notify	=	cbq_qlen_notify,
 	.get		=	cbq_get,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3aafbd1..28f4e77 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -51,29 +51,43 @@ static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
 
 /* ------------------------- Class/flow operations ------------------------- */
 
-static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
-			struct Qdisc *new, struct Qdisc **old)
+static void *dsmark_prepare_graft(struct Qdisc *sch, unsigned long arg,
+				  struct Qdisc *new)
 {
-	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-
-	pr_debug("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",
-		sch, p, new, old);
+	void *ret = NULL;
 
-	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+	if (!new) {
+		ret = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					&pfifo_qdisc_ops,
 					sch->handle);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (!ret)
+			return ERR_PTR(-ENOBUFS);
 	}
 
+	return ret;
+}
+
+static void dsmark_commit_graft(struct Qdisc *sch, unsigned long arg,
+				struct Qdisc *new, void *mem,
+				struct Qdisc **old)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+
+	if (!new)
+		new = mem;
+
 	sch_tree_lock(sch);
 	*old = xchg(&p->q, new);
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
+}
 
-	return 0;
+static void dsmark_cancel_graft(struct Qdisc *sch, unsigned long arg,
+				struct Qdisc *new, void *mem)
+{
+	if (mem)
+		qdisc_destroy(mem);
 }
 
 static struct Qdisc *dsmark_leaf(struct Qdisc *sch, unsigned long arg)
@@ -474,7 +488,9 @@ nla_put_failure:
 }
 
 static const struct Qdisc_class_ops dsmark_class_ops = {
-	.graft		=	dsmark_graft,
+	.prepare_graft	=	dsmark_prepare_graft,
+	.commit_graft	=	dsmark_commit_graft,
+	.cancel_graft	=	dsmark_cancel_graft,
 	.leaf		=	dsmark_leaf,
 	.get		=	dsmark_get,
 	.put		=	dsmark_put,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 997d520..59be192 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1191,29 +1191,46 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	return cl;
 }
 
-static int
-hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		 struct Qdisc **old)
+static void *hfsc_prepare_graft(struct Qdisc *sch, unsigned long arg,
+				struct Qdisc *new)
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
+	void *ret = NULL;
 
-	if (cl == NULL)
-		return -ENOENT;
-	if (cl->level > 0)
-		return -EINVAL;
-	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+	if (cl->level)
+		return ERR_PTR(-ENOENT);
+
+	if (!new) {
+		ret = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					&pfifo_qdisc_ops,
 					cl->cl_common.classid);
-		if (new == NULL)
-			new = &noop_qdisc;
+		if (!ret)
+			return ERR_PTR(-ENOBUFS);
 	}
 
+	return ret;
+}
+
+static void hfsc_commit_graft(struct Qdisc *sch, unsigned long arg,
+			      struct Qdisc *new, void *mem,
+			      struct Qdisc **old)
+{
+	struct hfsc_class *cl = (struct hfsc_class *)arg;
+
+	if (mem)
+		new = mem;
+
 	sch_tree_lock(sch);
 	hfsc_purge_queue(sch, cl);
 	*old = xchg(&cl->qdisc, new);
 	sch_tree_unlock(sch);
-	return 0;
+}
+
+static void hfsc_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			      struct Qdisc *new, void *mem)
+{
+	if (mem)
+		qdisc_destroy(mem);
 }
 
 static struct Qdisc *
@@ -1713,7 +1730,9 @@ hfsc_drop(struct Qdisc *sch)
 static const struct Qdisc_class_ops hfsc_class_ops = {
 	.change		= hfsc_change_class,
 	.delete		= hfsc_delete_class,
-	.graft		= hfsc_graft_class,
+	.prepare_graft	= hfsc_prepare_graft,
+	.commit_graft	= hfsc_commit_graft,
+	.cancel_graft	= hfsc_cancel_graft,
 	.leaf		= hfsc_class_leaf,
 	.qlen_notify	= hfsc_qlen_notify,
 	.get		= hfsc_get_class,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c8ca54c..292129d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1122,27 +1122,48 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
 }
 
-static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
+static void *htb_prepare_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
+	void *ret = NULL;
 
-	if (cl && !cl->level) {
-		if (new == NULL &&
-		    (new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					     &pfifo_qdisc_ops,
-					     cl->common.classid))
-		    == NULL)
-			return -ENOBUFS;
-		sch_tree_lock(sch);
-		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
-			qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-			qdisc_reset(*old);
-		}
-		sch_tree_unlock(sch);
-		return 0;
+	if (cl->level)
+		return ERR_PTR(-ENOENT);
+
+	if (!new) {
+		ret = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+					&pfifo_qdisc_ops,
+					cl->common.classid);
+		if (!ret)
+			return ERR_PTR(-ENOBUFS);
+	}
+
+	return ret;
+}
+
+static void htb_commit_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem,
+			     struct Qdisc **old)
+{
+	struct htb_class *cl = (struct htb_class*)arg;
+
+	if (mem)
+		new = mem;
+
+	sch_tree_lock(sch);
+	if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+		qdisc_reset(*old);
 	}
-	return -ENOENT;
+	sch_tree_unlock(sch);
+}
+
+static void htb_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem)
+{
+	if (mem)
+		qdisc_destroy(mem);
 }
 
 static struct Qdisc *htb_leaf(struct Qdisc *sch, unsigned long arg)
@@ -1536,7 +1557,9 @@ static void htb_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 }
 
 static const struct Qdisc_class_ops htb_class_ops = {
-	.graft		=	htb_graft,
+	.prepare_graft	=	htb_prepare_graft,
+	.commit_graft	=	htb_commit_graft,
+	.cancel_graft	=	htb_cancel_graft,
 	.leaf		=	htb_leaf,
 	.qlen_notify	=	htb_qlen_notify,
 	.get		=	htb_get,
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 956c80a..1cfb57e 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -22,10 +22,10 @@ struct ingress_qdisc_data {
 
 /* ------------------------- Class/flow operations ------------------------- */
 
-static int ingress_graft(struct Qdisc *sch, unsigned long arg,
-			 struct Qdisc *new, struct Qdisc **old)
+static void *ingress_prepare_graft(struct Qdisc *sch, unsigned long arg,
+				   struct Qdisc *new)
 {
-	return -EOPNOTSUPP;
+	return ERR_PTR(-EOPNOTSUPP);
 }
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
@@ -123,7 +123,7 @@ nla_put_failure:
 }
 
 static const struct Qdisc_class_ops ingress_class_ops = {
-	.graft		=	ingress_graft,
+	.prepare_graft	=	ingress_prepare_graft,
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
 	.put		=	ingress_put,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc585f2..180c1e4 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -615,8 +615,15 @@ static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
 	return 0;
 }
 
-static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
+static void *netem_prepare_graft(struct Qdisc *sch, unsigned long arg,
+				 struct Qdisc *new)
+{
+	return NULL;
+}
+
+static void netem_commit_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new, void *mem,
+			       struct Qdisc **old)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
@@ -628,8 +635,11 @@ static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
+}
 
-	return 0;
+static void netem_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new, void *mem)
+{
 }
 
 static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
@@ -676,7 +686,9 @@ static struct tcf_proto **netem_find_tcf(struct Qdisc *sch, unsigned long cl)
 }
 
 static const struct Qdisc_class_ops netem_class_ops = {
-	.graft		=	netem_graft,
+	.prepare_graft	=	netem_prepare_graft,
+	.commit_graft	=	netem_commit_graft,
+	.cancel_graft	=	netem_cancel_graft,
 	.leaf		=	netem_leaf,
 	.get		=	netem_get,
 	.put		=	netem_put,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 536ca47..ba3b261 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -269,14 +269,23 @@ nla_put_failure:
 	return -1;
 }
 
-static int prio_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		      struct Qdisc **old)
+static void *prio_prepare_graft(struct Qdisc *sch, unsigned long arg,
+				struct Qdisc *new)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
 	if (band >= q->bands)
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
+	return NULL;
+}
+
+static void prio_commit_graft(struct Qdisc *sch, unsigned long arg,
+			      struct Qdisc *new, void *mem,
+			      struct Qdisc **old)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	unsigned long band = arg - 1;
 
 	if (new == NULL)
 		new = &noop_qdisc;
@@ -287,8 +296,11 @@ static int prio_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
+}
 
-	return 0;
+static void prio_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			      struct Qdisc *new, void *mem)
+{
 }
 
 static struct Qdisc *
@@ -401,7 +413,9 @@ static struct tcf_proto ** prio_find_tcf(struct Qdisc *sch, unsigned long cl)
 }
 
 static const struct Qdisc_class_ops prio_class_ops = {
-	.graft		=	prio_graft,
+	.prepare_graft	=	prio_prepare_graft,
+	.commit_graft	=	prio_commit_graft,
+	.cancel_graft	=	prio_cancel_graft,
 	.leaf		=	prio_leaf,
 	.get		=	prio_get,
 	.put		=	prio_put,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 77098ac..c106e0e 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -283,8 +283,15 @@ static int red_dump_class(struct Qdisc *sch, unsigned long cl,
 	return 0;
 }
 
-static int red_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
+static void *red_prepare_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new)
+{
+	return NULL;
+}
+
+static void red_commit_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem,
+			     struct Qdisc **old)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
@@ -296,7 +303,11 @@ static int red_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
-	return 0;
+}
+
+static void red_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem)
+{
 }
 
 static struct Qdisc *red_leaf(struct Qdisc *sch, unsigned long arg)
@@ -344,7 +355,9 @@ static struct tcf_proto **red_find_tcf(struct Qdisc *sch, unsigned long cl)
 }
 
 static const struct Qdisc_class_ops red_class_ops = {
-	.graft		=	red_graft,
+	.prepare_graft	=	red_prepare_graft,
+	.commit_graft	=	red_commit_graft,
+	.cancel_graft	=	red_cancel_graft,
 	.leaf		=	red_leaf,
 	.get		=	red_get,
 	.put		=	red_put,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 444c227..1afea06 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -394,8 +394,15 @@ static int tbf_dump_class(struct Qdisc *sch, unsigned long cl,
 	return 0;
 }
 
-static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
+static void *tbf_prepare_graft(struct Qdisc *sch, unsigned long arg,
+			       struct Qdisc *new)
+{
+	return NULL;
+}
+
+static void tbf_commit_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem,
+			     struct Qdisc **old)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
@@ -407,8 +414,11 @@ static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
+}
 
-	return 0;
+static void tbf_cancel_graft(struct Qdisc *sch, unsigned long arg,
+			     struct Qdisc *new, void *mem)
+{
 }
 
 static struct Qdisc *tbf_leaf(struct Qdisc *sch, unsigned long arg)
@@ -456,7 +466,9 @@ static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
 
 static const struct Qdisc_class_ops tbf_class_ops =
 {
-	.graft		=	tbf_graft,
+	.prepare_graft	=	tbf_prepare_graft,
+	.commit_graft	=	tbf_commit_graft,
+	.cancel_graft	=	tbf_cancel_graft,
 	.leaf		=	tbf_leaf,
 	.get		=	tbf_get,
 	.put		=	tbf_put,
-- 
1.5.6.2.255.gbed62

