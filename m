From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 04/07: remove some unnecessary checks in classful schedulers
Date: Fri,  4 Sep 2009 18:41:17 +0200 (MEST)
Message-ID: <20090904164116.27300.19071.sendpatchset@x2.localnet>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35537 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756495AbZIDQlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:15 -0400
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eca9dbb05c5bf47f4bc3162b4f19dcb4dd85acfc
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 16:12:45 2009 +0200

    net_sched: remove some unnecessary checks in classful schedulers
    
    The class argument to the ->graft(), ->leaf(), ->dump(), ->dump_stats() all
    originate from either ->get() or ->walk() and are always valid.
    
    Remove unnecessary checks.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d5798e1..5b132c4 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1621,29 +1621,25 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 {
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
-	if (cl) {
-		if (new == NULL) {
-			new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-						&pfifo_qdisc_ops,
-						cl->common.classid);
-			if (new == NULL)
-				return -ENOBUFS;
-		} else {
+	if (new == NULL) {
+		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+					&pfifo_qdisc_ops, cl->common.classid);
+		if (new == NULL)
+			return -ENOBUFS;
+	} else {
 #ifdef CONFIG_NET_CLS_ACT
-			if (cl->police == TC_POLICE_RECLASSIFY)
-				new->reshape_fail = cbq_reshape_fail;
+		if (cl->police == TC_POLICE_RECLASSIFY)
+			new->reshape_fail = cbq_reshape_fail;
 #endif
-		}
-		sch_tree_lock(sch);
-		*old = cl->q;
-		cl->q = new;
-		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-		qdisc_reset(*old);
-		sch_tree_unlock(sch);
-
-		return 0;
 	}
-	return -ENOENT;
+	sch_tree_lock(sch);
+	*old = cl->q;
+	cl->q = new;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+
+	return 0;
 }
 
 static struct Qdisc *
@@ -1651,7 +1647,7 @@ cbq_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
-	return cl ? cl->q : NULL;
+	return cl->q;
 }
 
 static void cbq_qlen_notify(struct Qdisc *sch, unsigned long arg)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index dad0144..375d64c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1203,8 +1203,6 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
-	if (cl == NULL)
-		return -ENOENT;
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
@@ -1228,7 +1226,7 @@ hfsc_class_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
-	if (cl != NULL && cl->level == 0)
+	if (cl->level == 0)
 		return cl->qdisc;
 
 	return NULL;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index ec4d463..85acab9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1117,30 +1117,29 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
-	if (cl && !cl->level) {
-		if (new == NULL &&
-		    (new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					     &pfifo_qdisc_ops,
-					     cl->common.classid))
-		    == NULL)
-			return -ENOBUFS;
-		sch_tree_lock(sch);
-		*old = cl->un.leaf.q;
-		cl->un.leaf.q = new;
-		if (*old != NULL) {
-			qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-			qdisc_reset(*old);
-		}
-		sch_tree_unlock(sch);
-		return 0;
+	if (cl->level)
+		return -EINVAL;
+	if (new == NULL &&
+	    (new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+				     &pfifo_qdisc_ops,
+				     cl->common.classid)) == NULL)
+		return -ENOBUFS;
+
+	sch_tree_lock(sch);
+	*old = cl->un.leaf.q;
+	cl->un.leaf.q = new;
+	if (*old != NULL) {
+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+		qdisc_reset(*old);
 	}
-	return -ENOENT;
+	sch_tree_unlock(sch);
+	return 0;
 }
 
 static struct Qdisc *htb_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
-	return (cl && !cl->level) ? cl->un.leaf.q : NULL;
+	return !cl->level ? cl->un.leaf.q : NULL;
 }
 
 static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index a0ffe71..069f81c 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -298,9 +298,6 @@ static int multiq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	struct multiq_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
-	if (band >= q->bands)
-		return -EINVAL;
-
 	if (new == NULL)
 		new = &noop_qdisc;
 
@@ -320,9 +317,6 @@ multiq_leaf(struct Qdisc *sch, unsigned long arg)
 	struct multiq_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
-	if (band >= q->bands)
-		return NULL;
-
 	return q->queues[band];
 }
 
@@ -353,11 +347,8 @@ static int multiq_dump_class(struct Qdisc *sch, unsigned long cl,
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
-	if (cl - 1 > q->bands)
-		return -ENOENT;
 	tcm->tcm_handle |= TC_H_MIN(cl);
-	if (q->queues[cl-1])
-		tcm->tcm_info = q->queues[cl-1]->handle;
+	tcm->tcm_info = q->queues[cl-1]->handle;
 	return 0;
 }
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 209a4ca..0f73c41 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -262,9 +262,6 @@ static int prio_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
-	if (band >= q->bands)
-		return -EINVAL;
-
 	if (new == NULL)
 		new = &noop_qdisc;
 
@@ -284,9 +281,6 @@ prio_leaf(struct Qdisc *sch, unsigned long arg)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
-	if (band >= q->bands)
-		return NULL;
-
 	return q->queues[band];
 }
 
@@ -316,11 +310,8 @@ static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 
-	if (cl - 1 > q->bands)
-		return -ENOENT;
 	tcm->tcm_handle |= TC_H_MIN(cl);
-	if (q->queues[cl-1])
-		tcm->tcm_info = q->queues[cl-1]->handle;
+	tcm->tcm_info = q->queues[cl-1]->handle;
 	return 0;
 }
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a2c4d1a..072cdf4 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -268,8 +268,6 @@ static int red_dump_class(struct Qdisc *sch, unsigned long cl,
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
-	if (cl != 1)
-		return -ENOENT;
 	tcm->tcm_handle |= TC_H_MIN(1);
 	tcm->tcm_info = q->qdisc->handle;
 	return 0;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index d904167..8fb8107 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -368,9 +368,6 @@ static int tbf_dump_class(struct Qdisc *sch, unsigned long cl,
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
-	if (cl != 1) 	/* only one class */
-		return -ENOENT;
-
 	tcm->tcm_handle |= TC_H_MIN(1);
 	tcm->tcm_info = q->qdisc->handle;
 
