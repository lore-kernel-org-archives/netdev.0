From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 02/06: sch_hfsc: use dynamic class hash helpers
Date: Thu,  3 Jul 2008 17:16:03 +0200 (MEST)
Message-ID: <20080703151603.26225.64740.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40220 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbYGCPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:06 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_hfsc: use dynamic class hash helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d0d016e7dea2408ca6f795fe987f6abae3e5f526
tree 2844dbdc1b13151534c574b97849c84aee02cdd8
parent ba0c034039d0c4a76c38cd1d252a4e6a5a65333d
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200

 net/sched/sch_hfsc.c |   81 +++++++++++++++++++++++++-------------------------
 1 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e817aa0..3a82672 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -113,7 +113,7 @@ enum hfsc_class_flags
 
 struct hfsc_class
 {
-	u32		classid;	/* class id */
+	struct Qdisc_class_common cl_common;
 	unsigned int	refcnt;		/* usage count */
 
 	struct gnet_stats_basic bstats;
@@ -134,7 +134,6 @@ struct hfsc_class
 	struct rb_node vt_node;		/* parent's vt_tree member */
 	struct rb_root cf_tree;		/* active children sorted by cl_f */
 	struct rb_node cf_node;		/* parent's cf_heap member */
-	struct list_head hlist;		/* hash list member */
 	struct list_head dlist;		/* drop list member */
 
 	u64	cl_total;		/* total work in bytes */
@@ -177,13 +176,11 @@ struct hfsc_class
 	unsigned long	cl_nactive;	/* number of active children */
 };
 
-#define HFSC_HSIZE	16
-
 struct hfsc_sched
 {
 	u16	defcls;				/* default class id */
 	struct hfsc_class root;			/* root class */
-	struct list_head clhash[HFSC_HSIZE];	/* class hash */
+	struct Qdisc_class_hash clhash;		/* class hash */
 	struct rb_root eligible;		/* eligible tree */
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
@@ -933,26 +930,16 @@ hfsc_adjust_levels(struct hfsc_class *cl)
 	} while ((cl = cl->cl_parent) != NULL);
 }
 
-static inline unsigned int
-hfsc_hash(u32 h)
-{
-	h ^= h >> 8;
-	h ^= h >> 4;
-
-	return h & (HFSC_HSIZE - 1);
-}
-
 static inline struct hfsc_class *
 hfsc_find_class(u32 classid, struct Qdisc *sch)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl;
+	struct Qdisc_class_common *clc;
 
-	list_for_each_entry(cl, &q->clhash[hfsc_hash(classid)], hlist) {
-		if (cl->classid == classid)
-			return cl;
-	}
-	return NULL;
+	clc = qdisc_class_find(&q->clhash, classid);
+	if (clc == NULL)
+		return NULL;
+	return container_of(clc, struct hfsc_class, cl_common);
 }
 
 static void
@@ -1032,7 +1019,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (cl != NULL) {
 		if (parentid) {
-			if (cl->cl_parent && cl->cl_parent->classid != parentid)
+			if (cl->cl_parent &&
+			    cl->cl_parent->cl_common.classid != parentid)
 				return -EINVAL;
 			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
 				return -EINVAL;
@@ -1091,8 +1079,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (usc != NULL)
 		hfsc_change_usc(cl, usc, 0);
 
+	cl->cl_common.classid = classid;
 	cl->refcnt    = 1;
-	cl->classid   = classid;
 	cl->sched     = q;
 	cl->cl_parent = parent;
 	cl->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
@@ -1103,7 +1091,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->cf_tree = RB_ROOT;
 
 	sch_tree_lock(sch);
-	list_add_tail(&cl->hlist, &q->clhash[hfsc_hash(classid)]);
+	qdisc_class_hash_insert(&q->clhash, &cl->cl_common);
 	list_add_tail(&cl->siblings, &parent->children);
 	if (parent->level == 0)
 		hfsc_purge_queue(sch, parent);
@@ -1111,6 +1099,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
+	qdisc_class_hash_grow(sch, &q->clhash);
+
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
@@ -1145,7 +1135,7 @@ hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 	hfsc_adjust_levels(cl->cl_parent);
 
 	hfsc_purge_queue(sch, cl);
-	list_del(&cl->hlist);
+	qdisc_class_hash_remove(&q->clhash, &cl->cl_common);
 
 	if (--cl->refcnt == 0)
 		hfsc_destroy_class(sch, cl);
@@ -1212,7 +1202,7 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 		return -EINVAL;
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-					cl->classid);
+					cl->cl_common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
@@ -1345,8 +1335,9 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 	struct nlattr *nest;
 
-	tcm->tcm_parent = cl->cl_parent ? cl->cl_parent->classid : TC_H_ROOT;
-	tcm->tcm_handle = cl->classid;
+	tcm->tcm_parent = cl->cl_parent ? cl->cl_parent->cl_common.classid :
+					  TC_H_ROOT;
+	tcm->tcm_handle = cl->cl_common.classid;
 	if (cl->level == 0)
 		tcm->tcm_info = cl->qdisc->handle;
 
@@ -1390,14 +1381,16 @@ static void
 hfsc_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
+	struct hlist_node *n;
 	struct hfsc_class *cl;
 	unsigned int i;
 
 	if (arg->stop)
 		return;
 
-	for (i = 0; i < HFSC_HSIZE; i++) {
-		list_for_each_entry(cl, &q->clhash[i], hlist) {
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i],
+				     cl_common.hnode) {
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
@@ -1433,21 +1426,22 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct tc_hfsc_qopt *qopt;
-	unsigned int i;
+	int err;
 
 	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 	qopt = nla_data(opt);
 
 	q->defcls = qopt->defcls;
-	for (i = 0; i < HFSC_HSIZE; i++)
-		INIT_LIST_HEAD(&q->clhash[i]);
+	err = qdisc_class_hash_init(&q->clhash);
+	if (err < 0)
+		return err;
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	skb_queue_head_init(&q->requeue);
 
+	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
-	q->root.classid = sch->handle;
 	q->root.sched   = q;
 	q->root.qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
 					  sch->handle);
@@ -1457,7 +1451,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.vt_tree = RB_ROOT;
 	q->root.cf_tree = RB_ROOT;
 
-	list_add(&q->root.hlist, &q->clhash[hfsc_hash(q->root.classid)]);
+	qdisc_class_hash_insert(&q->clhash, &q->root.cl_common);
+	qdisc_class_hash_grow(sch, &q->clhash);
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
@@ -1520,10 +1515,11 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
+	struct hlist_node *n;
 	unsigned int i;
 
-	for (i = 0; i < HFSC_HSIZE; i++) {
-		list_for_each_entry(cl, &q->clhash[i], hlist)
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], cl_common.hnode)
 			hfsc_reset_class(cl);
 	}
 	__skb_queue_purge(&q->requeue);
@@ -1537,17 +1533,20 @@ static void
 hfsc_destroy_qdisc(struct Qdisc *sch)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl, *next;
+	struct hlist_node *n, *next;
+	struct hfsc_class *cl;
 	unsigned int i;
 
-	for (i = 0; i < HFSC_HSIZE; i++) {
-		list_for_each_entry(cl, &q->clhash[i], hlist)
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], cl_common.hnode)
 			tcf_destroy_chain(&cl->filter_list);
 	}
-	for (i = 0; i < HFSC_HSIZE; i++) {
-		list_for_each_entry_safe(cl, next, &q->clhash[i], hlist)
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry_safe(cl, n, next, &q->clhash.hash[i],
+					  cl_common.hnode)
 			hfsc_destroy_class(sch, cl);
 	}
+	qdisc_class_hash_destroy(&q->clhash);
 	__skb_queue_purge(&q->requeue);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
