From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 03/06: sch_cbq: use dynamic class hash helpers
Date: Thu,  3 Jul 2008 17:16:05 +0200 (MEST)
Message-ID: <20080703151604.26225.54548.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40226 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbYGCPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:06 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_cbq: use dynamic class hash helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7ce0dc13a43a80bcce1dc862f35fddc9740aaf27
tree c7a1b94865e509d6ea36fbdc915b120fafc853d7
parent d0d016e7dea2408ca6f795fe987f6abae3e5f526
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200

 net/sched/sch_cbq.c |  112 +++++++++++++++++++++++++--------------------------
 1 files changed, 55 insertions(+), 57 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2a3c97f..968b4c7 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -73,11 +73,10 @@ struct cbq_sched_data;
 
 struct cbq_class
 {
-	struct cbq_class	*next;		/* hash table link */
+	struct Qdisc_class_common common;
 	struct cbq_class	*next_alive;	/* next class with backlog in this priority band */
 
 /* Parameters */
-	u32			classid;
 	unsigned char		priority;	/* class priority */
 	unsigned char		priority2;	/* priority to be used after overlimit */
 	unsigned char		ewma_log;	/* time constant for idle time calculation */
@@ -144,7 +143,7 @@ struct cbq_class
 
 struct cbq_sched_data
 {
-	struct cbq_class	*classes[16];		/* Hash table of all classes */
+	struct Qdisc_class_hash	clhash;			/* Hash table of all classes */
 	int			nclasses[TC_CBQ_MAXPRIO+1];
 	unsigned		quanta[TC_CBQ_MAXPRIO+1];
 
@@ -177,23 +176,15 @@ struct cbq_sched_data
 
 #define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
 
-
-static __inline__ unsigned cbq_hash(u32 h)
-{
-	h ^= h>>8;
-	h ^= h>>4;
-	return h&0xF;
-}
-
 static __inline__ struct cbq_class *
 cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
 {
-	struct cbq_class *cl;
+	struct Qdisc_class_common *clc;
 
-	for (cl = q->classes[cbq_hash(classid)]; cl; cl = cl->next)
-		if (cl->classid == classid)
-			return cl;
-	return NULL;
+	clc = qdisc_class_find(&q->clhash, classid);
+	if (clc == NULL)
+		return NULL;
+	return container_of(clc, struct cbq_class, common);
 }
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -1071,13 +1062,14 @@ static void cbq_adjust_levels(struct cbq_class *this)
 static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 {
 	struct cbq_class *cl;
-	unsigned h;
+	struct hlist_node *n;
+	unsigned int h;
 
 	if (q->quanta[prio] == 0)
 		return;
 
-	for (h=0; h<16; h++) {
-		for (cl = q->classes[h]; cl; cl = cl->next) {
+	for (h = 0; h < q->clhash.hashsize; h++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[h], common.hnode) {
 			/* BUGGGG... Beware! This expression suffer of
 			   arithmetic overflows!
 			 */
@@ -1086,7 +1078,7 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 					q->quanta[prio];
 			}
 			if (cl->quantum <= 0 || cl->quantum>32*cl->qdisc->dev->mtu) {
-				printk(KERN_WARNING "CBQ: class %08x has bad quantum==%ld, repaired.\n", cl->classid, cl->quantum);
+				printk(KERN_WARNING "CBQ: class %08x has bad quantum==%ld, repaired.\n", cl->common.classid, cl->quantum);
 				cl->quantum = cl->qdisc->dev->mtu/2 + 1;
 			}
 		}
@@ -1114,10 +1106,12 @@ static void cbq_sync_defmap(struct cbq_class *cl)
 		if (split->defaults[i])
 			continue;
 
-		for (h=0; h<16; h++) {
+		for (h = 0; h < q->clhash.hashsize; h++) {
+			struct hlist_node *n;
 			struct cbq_class *c;
 
-			for (c = q->classes[h]; c; c = c->next) {
+			hlist_for_each_entry(c, n, &q->clhash.hash[h],
+					     common.hnode) {
 				if (c->split == split && c->level < level &&
 				    c->defmap&(1<<i)) {
 					split->defaults[i] = c;
@@ -1135,12 +1129,12 @@ static void cbq_change_defmap(struct cbq_class *cl, u32 splitid, u32 def, u32 ma
 	if (splitid == 0) {
 		if ((split = cl->split) == NULL)
 			return;
-		splitid = split->classid;
+		splitid = split->common.classid;
 	}
 
-	if (split == NULL || split->classid != splitid) {
+	if (split == NULL || split->common.classid != splitid) {
 		for (split = cl->tparent; split; split = split->tparent)
-			if (split->classid == splitid)
+			if (split->common.classid == splitid)
 				break;
 	}
 
@@ -1163,13 +1157,7 @@ static void cbq_unlink_class(struct cbq_class *this)
 	struct cbq_class *cl, **clp;
 	struct cbq_sched_data *q = qdisc_priv(this->qdisc);
 
-	for (clp = &q->classes[cbq_hash(this->classid)]; (cl = *clp) != NULL; clp = &cl->next) {
-		if (cl == this) {
-			*clp = cl->next;
-			cl->next = NULL;
-			break;
-		}
-	}
+	qdisc_class_hash_remove(&q->clhash, &this->common);
 
 	if (this->tparent) {
 		clp=&this->sibling;
@@ -1195,12 +1183,10 @@ static void cbq_unlink_class(struct cbq_class *this)
 static void cbq_link_class(struct cbq_class *this)
 {
 	struct cbq_sched_data *q = qdisc_priv(this->qdisc);
-	unsigned h = cbq_hash(this->classid);
 	struct cbq_class *parent = this->tparent;
 
 	this->sibling = this;
-	this->next = q->classes[h];
-	q->classes[h] = this;
+	qdisc_class_hash_insert(&q->clhash, &this->common);
 
 	if (parent == NULL)
 		return;
@@ -1242,6 +1228,7 @@ cbq_reset(struct Qdisc* sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
+	struct hlist_node *n;
 	int prio;
 	unsigned h;
 
@@ -1258,8 +1245,8 @@ cbq_reset(struct Qdisc* sch)
 	for (prio = 0; prio <= TC_CBQ_MAXPRIO; prio++)
 		q->active[prio] = NULL;
 
-	for (h = 0; h < 16; h++) {
-		for (cl = q->classes[h]; cl; cl = cl->next) {
+	for (h = 0; h < q->clhash.hashsize; h++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[h], common.hnode) {
 			qdisc_reset(cl->q);
 
 			cl->next_alive = NULL;
@@ -1406,9 +1393,13 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	if ((q->link.R_tab = qdisc_get_rtab(r, tb[TCA_CBQ_RTAB])) == NULL)
 		return -EINVAL;
 
+	err = qdisc_class_hash_init(&q->clhash);
+	if (err < 0)
+		goto put_rtab;
+
 	q->link.refcnt = 1;
 	q->link.sibling = &q->link;
-	q->link.classid = sch->handle;
+	q->link.common.classid = sch->handle;
 	q->link.qdisc = sch;
 	if (!(q->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
 					    sch->handle)))
@@ -1441,6 +1432,10 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 
 	cbq_addprio(q, &q->link);
 	return 0;
+
+put_rtab:
+	qdisc_put_rtab(q->link.R_tab);
+	return err;
 }
 
 static __inline__ int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
@@ -1521,7 +1516,7 @@ static __inline__ int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 	struct tc_cbq_fopt opt;
 
 	if (cl->split || cl->defmap) {
-		opt.split = cl->split ? cl->split->classid : 0;
+		opt.split = cl->split ? cl->split->common.classid : 0;
 		opt.defmap = cl->defmap;
 		opt.defchange = ~0;
 		NLA_PUT(skb, TCA_CBQ_FOPT, sizeof(opt), &opt);
@@ -1602,10 +1597,10 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	struct nlattr *nest;
 
 	if (cl->tparent)
-		tcm->tcm_parent = cl->tparent->classid;
+		tcm->tcm_parent = cl->tparent->common.classid;
 	else
 		tcm->tcm_parent = TC_H_ROOT;
-	tcm->tcm_handle = cl->classid;
+	tcm->tcm_handle = cl->common.classid;
 	tcm->tcm_info = cl->q->handle;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
@@ -1650,8 +1645,9 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 
 	if (cl) {
 		if (new == NULL) {
-			if ((new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-						     cl->classid)) == NULL)
+			new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+						cl->common.classid);
+			if (new == NULL)
 				return -ENOBUFS;
 		} else {
 #ifdef CONFIG_NET_CLS_ACT
@@ -1716,6 +1712,7 @@ static void
 cbq_destroy(struct Qdisc* sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct hlist_node *n, *next;
 	struct cbq_class *cl;
 	unsigned h;
 
@@ -1727,18 +1724,16 @@ cbq_destroy(struct Qdisc* sch)
 	 * classes from root to leafs which means that filters can still
 	 * be bound to classes which have been destroyed already. --TGR '04
 	 */
-	for (h = 0; h < 16; h++) {
-		for (cl = q->classes[h]; cl; cl = cl->next)
+	for (h = 0; h < q->clhash.hashsize; h++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[h], common.hnode)
 			tcf_destroy_chain(&cl->filter_list);
 	}
-	for (h = 0; h < 16; h++) {
-		struct cbq_class *next;
-
-		for (cl = q->classes[h]; cl; cl = next) {
-			next = cl->next;
+	for (h = 0; h < q->clhash.hashsize; h++) {
+		hlist_for_each_entry_safe(cl, n, next, &q->clhash.hash[h],
+					  common.hnode)
 			cbq_destroy_class(sch, cl);
-		}
 	}
+	qdisc_class_hash_destroy(&q->clhash);
 }
 
 static void cbq_put(struct Qdisc *sch, unsigned long arg)
@@ -1781,7 +1776,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (cl) {
 		/* Check parent */
 		if (parentid) {
-			if (cl->tparent && cl->tparent->classid != parentid)
+			if (cl->tparent &&
+			    cl->tparent->common.classid != parentid)
 				return -EINVAL;
 			if (!cl->tparent && parentid != TC_H_ROOT)
 				return -EINVAL;
@@ -1883,7 +1879,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->refcnt = 1;
 	if (!(cl->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid)))
 		cl->q = &noop_qdisc;
-	cl->classid = classid;
+	cl->common.classid = classid;
 	cl->tparent = parent;
 	cl->qdisc = sch;
 	cl->allot = parent->allot;
@@ -1916,6 +1912,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
 	sch_tree_unlock(sch);
 
+	qdisc_class_hash_grow(sch, &q->clhash);
+
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
@@ -2008,15 +2006,15 @@ static void cbq_unbind_filter(struct Qdisc *sch, unsigned long arg)
 static void cbq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct cbq_class *cl;
+	struct hlist_node *n;
 	unsigned h;
 
 	if (arg->stop)
 		return;
 
-	for (h = 0; h < 16; h++) {
-		struct cbq_class *cl;
-
-		for (cl = q->classes[h]; cl; cl = cl->next) {
+	for (h = 0; h < q->clhash.hashsize; h++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[h], common.hnode) {
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
