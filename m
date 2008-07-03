From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 05/06: sch_htb: use dynamic class hash helpers
Date: Thu,  3 Jul 2008 17:16:07 +0200 (MEST)
Message-ID: <20080703151607.26225.47592.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40235 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbYGCPQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:09 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_htb: use dynamic class hash helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e56e921c9ece0bd6f4201910292468f9c0e8f4de
tree e231093d86d28b8bff2549cbebaa185b16248c2c
parent 3fcfd66ab1737d4bcb2158866d7b2b574b0099bf
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:47 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:47 +0200

 net/sched/sch_htb.c |  100 +++++++++++++++++++++------------------------------
 1 files changed, 42 insertions(+), 58 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d01fe3a..e7461a1 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -51,7 +51,6 @@
     one less than their parent.
 */
 
-#define HTB_HSIZE 16		/* classid hash size */
 static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
@@ -72,8 +71,8 @@ enum htb_cmode {
 
 /* interior & leaf nodes; props specific to leaves are marked L: */
 struct htb_class {
+	struct Qdisc_class_common common;
 	/* general class parameters */
-	u32 classid;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
@@ -83,7 +82,6 @@ struct htb_class {
 	/* topology */
 	int level;		/* our level (see above) */
 	struct htb_class *parent;	/* parent class */
-	struct hlist_node hlist;	/* classid hash list item */
 	struct list_head sibling;	/* sibling list item */
 	struct list_head children;	/* children list */
 
@@ -141,7 +139,7 @@ static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 
 struct htb_sched {
 	struct list_head root;	/* root classes list */
-	struct hlist_head hash[HTB_HSIZE];	/* hashed by classid */
+	struct Qdisc_class_hash clhash;
 	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
 	/* self list - roots of self generating tree */
@@ -176,32 +174,16 @@ struct htb_sched {
 	long direct_pkts;
 };
 
-/* compute hash of size HTB_HSIZE for given handle */
-static inline int htb_hash(u32 h)
-{
-#if HTB_HSIZE != 16
-#error "Declare new hash for your HTB_HSIZE"
-#endif
-	h ^= h >> 8;		/* stolen from cbq_hash */
-	h ^= h >> 4;
-	return h & 0xf;
-}
-
 /* find class in global hash table using given handle */
 static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct hlist_node *p;
-	struct htb_class *cl;
+	struct Qdisc_class_common *clc;
 
-	if (TC_H_MAJ(handle) != sch->handle)
+	clc = qdisc_class_find(&q->clhash, handle);
+	if (clc == NULL)
 		return NULL;
-
-	hlist_for_each_entry(cl, p, q->hash + htb_hash(handle), hlist) {
-		if (cl->classid == handle)
-			return cl;
-	}
-	return NULL;
+	return container_of(clc, struct htb_class, common);
 }
 
 /**
@@ -282,7 +264,7 @@ static void htb_add_to_id_tree(struct rb_root *root,
 		parent = *p;
 		c = rb_entry(parent, struct htb_class, node[prio]);
 
-		if (cl->classid > c->classid)
+		if (cl->common.classid > c->common.classid)
 			p = &parent->rb_right;
 		else
 			p = &parent->rb_left;
@@ -446,7 +428,7 @@ static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 				/* we are removing child which is pointed to from
 				   parent feed - forget the pointer but remember
 				   classid */
-				p->un.inner.last_ptr_id[prio] = cl->classid;
+				p->un.inner.last_ptr_id[prio] = cl->common.classid;
 				p->un.inner.ptr[prio] = NULL;
 			}
 
@@ -751,10 +733,10 @@ static struct rb_node *htb_id_find_next_upper(int prio, struct rb_node *n,
 	while (n) {
 		struct htb_class *cl =
 		    rb_entry(n, struct htb_class, node[prio]);
-		if (id == cl->classid)
+		if (id == cl->common.classid)
 			return n;
 
-		if (id > cl->classid) {
+		if (id > cl->common.classid) {
 			n = n->rb_right;
 		} else {
 			r = n;
@@ -864,7 +846,7 @@ next:
 		if (!cl->warned) {
 			printk(KERN_WARNING
 			       "htb: class %X isn't work conserving ?!\n",
-			       cl->classid);
+			       cl->common.classid);
 			cl->warned = 1;
 		}
 		q->nwc_hit++;
@@ -975,13 +957,12 @@ static unsigned int htb_drop(struct Qdisc *sch)
 static void htb_reset(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	int i;
-
-	for (i = 0; i < HTB_HSIZE; i++) {
-		struct hlist_node *p;
-		struct htb_class *cl;
+	struct htb_class *cl;
+	struct hlist_node *n;
+	unsigned int i;
 
-		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode) {
 			if (cl->level)
 				memset(&cl->un.inner, 0, sizeof(cl->un.inner));
 			else {
@@ -1040,8 +1021,9 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	INIT_LIST_HEAD(&q->root);
-	for (i = 0; i < HTB_HSIZE; i++)
-		INIT_HLIST_HEAD(q->hash + i);
+	err = qdisc_class_hash_init(&q->clhash);
+	if (err < 0)
+		return err;
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
 		INIT_LIST_HEAD(q->drops + i);
 
@@ -1096,8 +1078,8 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	struct tc_htb_opt opt;
 
 	spin_lock_bh(&sch->dev->queue_lock);
-	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
-	tcm->tcm_handle = cl->classid;
+	tcm->tcm_parent = cl->parent ? cl->parent->common.classid : TC_H_ROOT;
+	tcm->tcm_handle = cl->common.classid;
 	if (!cl->level && cl->un.leaf.q)
 		tcm->tcm_info = cl->un.leaf.q->handle;
 
@@ -1152,7 +1134,7 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl && !cl->level) {
 		if (new == NULL &&
 		    (new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-					     cl->classid))
+					     cl->common.classid))
 		    == NULL)
 			return -ENOBUFS;
 		sch_tree_lock(sch);
@@ -1253,14 +1235,16 @@ static void htb_destroy(struct Qdisc *sch)
 	   unbind_filter on it (without Oops). */
 	tcf_destroy_chain(&q->filter_list);
 
-	for (i = 0; i < HTB_HSIZE; i++) {
-		hlist_for_each_entry(cl, n, q->hash + i, hlist)
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode)
 			tcf_destroy_chain(&cl->filter_list);
 	}
-	for (i = 0; i < HTB_HSIZE; i++) {
-		hlist_for_each_entry_safe(cl, n, next, q->hash + i, hlist)
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry_safe(cl, n, next, &q->clhash.hash[i],
+					  common.hnode)
 			htb_destroy_class(sch, cl);
 	}
+	qdisc_class_hash_destroy(&q->clhash);
 	__skb_queue_purge(&q->direct_queue);
 }
 
@@ -1280,7 +1264,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	if (!cl->level && htb_parent_last_child(cl)) {
 		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-						cl->parent->classid);
+						cl->parent->common.classid);
 		last_child = 1;
 	}
 
@@ -1292,8 +1276,8 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
-	/* delete from hash, sibling list and active */
-	hlist_del(&cl->hlist);
+	/* delete from hash and active; remainder in destroy_class */
+	qdisc_class_hash_remove(&q->clhash, &cl->common);
 	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
@@ -1390,7 +1374,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
-		INIT_HLIST_NODE(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 		RB_CLEAR_NODE(&cl->pq_node);
@@ -1425,7 +1408,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* leaf (we) needs elementary qdisc */
 		cl->un.leaf.q = new_q ? new_q : &noop_qdisc;
 
-		cl->classid = classid;
+		cl->common.classid = classid;
 		cl->parent = parent;
 
 		/* set class to be in HTB_CAN_SEND state */
@@ -1436,7 +1419,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
-		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
+		qdisc_class_hash_insert(&q->clhash, &cl->common);
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
 	} else {
@@ -1454,13 +1437,13 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if (!hopt->quantum && cl->un.leaf.quantum < 1000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
-			       cl->classid);
+			       cl->common.classid);
 			cl->un.leaf.quantum = 1000;
 		}
 		if (!hopt->quantum && cl->un.leaf.quantum > 200000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is big. Consider r2q change.\n",
-			       cl->classid);
+			       cl->common.classid);
 			cl->un.leaf.quantum = 200000;
 		}
 		if (hopt->quantum)
@@ -1483,6 +1466,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	cl->ceil = ctab;
 	sch_tree_unlock(sch);
 
+	qdisc_class_hash_grow(sch, &q->clhash);
+
 	*arg = (unsigned long)cl;
 	return 0;
 
@@ -1539,16 +1524,15 @@ static void htb_unbind_filter(struct Qdisc *sch, unsigned long arg)
 static void htb_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	int i;
+	struct htb_class *cl;
+	struct hlist_node *n;
+	unsigned int i;
 
 	if (arg->stop)
 		return;
 
-	for (i = 0; i < HTB_HSIZE; i++) {
-		struct hlist_node *p;
-		struct htb_class *cl;
-
-		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode) {
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
