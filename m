From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_htb: htb_class optimization
Date: Wed, 24 Jan 2007 10:43:29 +0100
Message-ID: <20070124094329.GA3829@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:57404 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750842AbXAXJlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 04:41:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Some time ago Patrick McHardy suggested to separate
structures of htb_class for inner and leaf. Currently
they are part of an union and because of big difference
in their sizes some memory is unnecessary used for leaves.

Here is my preliminary proposal. It's done with a premise
to change (or to work) as little as possible, so it isn't
probably the optimal solution, but if it's really bad or
could be much better without serious rewriting, I'd like
to know your suggestions. From the above reasons it's also
not tested - I'd better do it with something accepted,
just a little.

Regards,
Jarek P.
---

[PATCH][NET_SCHED] sch_htb: htb_class optimization 

htb_class_leaf and htb_class_inner are separated from
main htb_class structure to use memory more effectively.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-rc5-/net/sched/sch_htb.c linux-2.6.20-rc5/net/sched/sch_htb.c
--- linux-2.6.20-rc5-/net/sched/sch_htb.c	2007-01-08 20:23:58.000000000 +0100
+++ linux-2.6.20-rc5/net/sched/sch_htb.c	2007-01-24 07:54:21.000000000 +0100
@@ -85,6 +85,26 @@ enum htb_cmode {
 	HTB_CAN_SEND		/* class can send */
 };
 
+
+struct htb_class_leaf {
+	struct Qdisc *q;
+	int aprio;
+	int deficit[TC_HTB_MAXDEPTH];
+	struct list_head drop_list;
+};
+
+struct htb_class_inner {
+	struct rb_root feed[TC_HTB_NUMPRIO];	/* feed trees */
+	struct rb_node *ptr[TC_HTB_NUMPRIO];	/* current class ptr */
+	/*
+	 * When class changes from state 1->2 and disconnects from
+	 * parent's feed then we lost ptr value and start from the
+	 * first child again. Here we store classid of the
+	 * last valid ptr (used when ptr is NULL).
+	 */
+	u32 last_ptr_id[TC_HTB_NUMPRIO];
+};
+
 /* interior & leaf nodes; props specific to leaves are marked L: */
 struct htb_class {
 	/* general class parameters */
@@ -109,23 +129,8 @@ struct htb_class {
 	struct list_head children;	/* children list */
 
 	union {
-		struct htb_class_leaf {
-			struct Qdisc *q;
-			int prio;
-			int aprio;
-			int quantum;
-			int deficit[TC_HTB_MAXDEPTH];
-			struct list_head drop_list;
-		} leaf;
-		struct htb_class_inner {
-			struct rb_root feed[TC_HTB_NUMPRIO];	/* feed trees */
-			struct rb_node *ptr[TC_HTB_NUMPRIO];	/* current class ptr */
-			/* When class changes from state 1->2 and disconnects from
-			   parent's feed then we lost ptr value and start from the
-			   first child again. Here we store classid of the
-			   last valid ptr (used when ptr is NULL). */
-			u32 last_ptr_id[TC_HTB_NUMPRIO];
-		} inner;
+		struct htb_class_leaf *leaf;
+		struct htb_class_inner *inner;
 	} un;
 	struct rb_node node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
 	struct rb_node pq_node;	/* node for event queue */
@@ -148,11 +153,51 @@ struct htb_class {
 	long tokens, ctokens;	/* current number of tokens */
 	psched_time_t t_c;	/* checkpoint time */
 
-	int prio;		/* For parent to leaf return possible here */
-	int quantum;		/* we do backup. Finally full replacement  */
-				/* of un.leaf originals should be done. */
+	int prio;		/* Used only by leaves but made common for */
+	int quantum;		/* parent to leaf change after class delete. */
 };
 
+#define HTB_DEBUG_MM 1
+#ifdef HTB_DEBUG_MM
+static int htb_debug_mm[3];
+
+static inline void HTB_DEBUG_LEAF(int sign)
+{
+	if ((htb_debug_mm[0] += sign * sizeof(struct htb_class_leaf)) < 0) {
+		printk("htb_class_leaf kfree error");
+		BUG();
+	}
+}
+
+static inline void HTB_DEBUG_INNER(int sign)
+{
+	if ((htb_debug_mm[1] += sign * sizeof(struct htb_class_inner)) < 0) {
+		printk("htb_class_inner kfree error");
+		BUG();
+	}
+}
+
+static inline void HTB_DEBUG_CLASS(int sign)
+{
+	if ((htb_debug_mm[2] += sign * sizeof(struct htb_class)) < 0) {
+		printk("htb_class kfree error");
+		BUG();
+	}
+}
+
+static inline void HTB_DEBUG_CLASSES(void)
+{
+	if (htb_debug_mm[0] || htb_debug_mm[1] || htb_debug_mm[2])
+		printk("htb_classes error: %d %d %d\n",
+			htb_debug_mm[0], htb_debug_mm[1], htb_debug_mm[2]);
+}
+#else
+static inline void HTB_DEBUG_LEAF(int sign) {}
+static inline void HTB_DEBUG_INNER(int sign) {}
+static inline void HTB_DEBUG_CLASS(int sign) {}
+static inline void HTB_DEBUG_CLASSES(void) {}
+#endif
+
 /* TODO: maybe compute rate when size is too large .. or drop ? */
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 			   int size)
@@ -447,12 +492,12 @@ static void htb_activate_prios(struct ht
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
 
-			if (p->un.inner.feed[prio].rb_node)
+			if (p->un.inner->feed[prio].rb_node)
 				/* parent already has its feed in use so that
 				   reset bit in mask as parent is already ok */
 				mask &= ~(1 << prio);
 
-			htb_add_to_id_tree(p->un.inner.feed + prio, cl, prio);
+			htb_add_to_id_tree(p->un.inner->feed + prio, cl, prio);
 		}
 		p->prio_activity |= mask;
 		cl = p;
@@ -482,17 +527,20 @@ static void htb_deactivate_prios(struct 
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
 
-			if (p->un.inner.ptr[prio] == cl->node + prio) {
-				/* we are removing child which is pointed to from
-				   parent feed - forget the pointer but remember
-				   classid */
-				p->un.inner.last_ptr_id[prio] = cl->classid;
-				p->un.inner.ptr[prio] = NULL;
+			if (p->un.inner->ptr[prio] == cl->node + prio) {
+				/*
+				 * We are removing child which is pointed to
+				 * from parent feed - forget the pointer but
+				 * remember classid.
+				 */
+				p->un.inner->last_ptr_id[prio] = cl->classid;
+				p->un.inner->ptr[prio] = NULL;
 			}
 
-			htb_safe_rb_erase(cl->node + prio, p->un.inner.feed + prio);
+			htb_safe_rb_erase(cl->node + prio,
+					p->un.inner->feed + prio);
 
-			if (!p->un.inner.feed[prio].rb_node)
+			if (!p->un.inner->feed[prio].rb_node)
 				mask |= 1 << prio;
 		}
 
@@ -583,13 +631,13 @@ htb_change_class_mode(struct htb_sched *
  */
 static inline void htb_activate(struct htb_sched *q, struct htb_class *cl)
 {
-	BUG_TRAP(!cl->level && cl->un.leaf.q && cl->un.leaf.q->q.qlen);
+	BUG_TRAP(!cl->level && cl->un.leaf->q && cl->un.leaf->q->q.qlen);
 
 	if (!cl->prio_activity) {
-		cl->prio_activity = 1 << (cl->un.leaf.aprio = cl->un.leaf.prio);
+		cl->prio_activity = 1 << (cl->un.leaf->aprio = cl->prio);
 		htb_activate_prios(q, cl);
-		list_add_tail(&cl->un.leaf.drop_list,
-			      q->drops + cl->un.leaf.aprio);
+		list_add_tail(&cl->un.leaf->drop_list,
+			      q->drops + cl->un.leaf->aprio);
 	}
 }
 
@@ -605,7 +653,7 @@ static inline void htb_deactivate(struct
 
 	htb_deactivate_prios(q, cl);
 	cl->prio_activity = 0;
-	list_del_init(&cl->un.leaf.drop_list);
+	list_del_init(&cl->un.leaf->drop_list);
 }
 
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
@@ -631,7 +679,7 @@ static int htb_enqueue(struct sk_buff *s
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
+	} else if (cl->un.leaf->q->enqueue(skb, cl->un.leaf->q) !=
 		   NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
@@ -667,7 +715,7 @@ static int htb_requeue(struct sk_buff *s
 			sch->qstats.drops++;
 			return NET_XMIT_CN;
 		}
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
+	} else if (cl->un.leaf->q->ops->requeue(skb, cl->un.leaf->q) !=
 		   NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
@@ -877,9 +925,9 @@ static struct htb_class *htb_lookup_leaf
 			cl = rb_entry(*sp->pptr, struct htb_class, node[prio]);
 			if (!cl->level)
 				return cl;
-			(++sp)->root = cl->un.inner.feed[prio].rb_node;
-			sp->pptr = cl->un.inner.ptr + prio;
-			sp->pid = cl->un.inner.last_ptr_id + prio;
+			(++sp)->root = cl->un.inner->feed[prio].rb_node;
+			sp->pptr = cl->un.inner->ptr + prio;
+			sp->pid = cl->un.inner->last_ptr_id + prio;
 		}
 	}
 	BUG_TRAP(0);
@@ -908,7 +956,7 @@ next:
 		   qdisc drops packets in enqueue routine or if someone used
 		   graft operation on the leaf since last dequeue; 
 		   simply deactivate and skip such class */
-		if (unlikely(cl->un.leaf.q->q.qlen == 0)) {
+		if (unlikely(cl->un.leaf->q->q.qlen == 0)) {
 			struct htb_class *next;
 			htb_deactivate(q, cl);
 
@@ -926,7 +974,7 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		skb = cl->un.leaf->q->dequeue(cl->un.leaf->q);
 		if (likely(skb != NULL))
 			break;
 		if (!cl->warned) {
@@ -936,8 +984,9 @@ next:
 			cl->warned = 1;
 		}
 		q->nwc_hit++;
-		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
-				  ptr[0]) + prio);
+		htb_next_rb_node((level ?
+				cl->parent->un.inner->ptr : q->ptr[0]) + prio);
+		
 		cl = htb_lookup_leaf(q->row[level] + prio, prio,
 				     q->ptr[level] + prio,
 				     q->last_ptr_id[level] + prio);
@@ -945,14 +994,16 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
-			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
-			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
-					  ptr[0]) + prio);
-		}
-		/* this used to be after charge_class but this constelation
-		   gives us slightly better performance */
-		if (!cl->un.leaf.q->q.qlen)
+		if ((cl->un.leaf->deficit[level] -= skb->len) < 0) {
+			cl->un.leaf->deficit[level] += cl->quantum;
+			htb_next_rb_node((level ?
+				cl->parent->un.inner->ptr : q->ptr[0]) + prio);
+		}
+		/*
+		 * This used to be after charge_class but this constelation
+		 * gives us slightly better performance.
+		 */
+		if (!cl->un.leaf->q->q.qlen)
 			htb_deactivate(q, cl);
 		htb_charge_class(q, cl, level, skb->len);
 	}
@@ -1037,13 +1088,13 @@ static unsigned int htb_drop(struct Qdis
 	for (prio = TC_HTB_NUMPRIO - 1; prio >= 0; prio--) {
 		struct list_head *p;
 		list_for_each(p, q->drops + prio) {
-			struct htb_class *cl = list_entry(p, struct htb_class,
-							  un.leaf.drop_list);
 			unsigned int len;
-			if (cl->un.leaf.q->ops->drop &&
-			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+			struct htb_class *cl = list_entry(p, struct htb_class,
+							  un.leaf->drop_list);
+			if (cl->un.leaf->q->ops->drop &&
+			    (len = cl->un.leaf->q->ops->drop(cl->un.leaf->q))) {
 				sch->q.qlen--;
-				if (!cl->un.leaf.q->q.qlen)
+				if (!cl->un.leaf->q->q.qlen)
 					htb_deactivate(q, cl);
 				return len;
 			}
@@ -1065,11 +1116,11 @@ static void htb_reset(struct Qdisc *sch)
 
 		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
 			if (cl->level)
-				memset(&cl->un.inner, 0, sizeof(cl->un.inner));
+				memset(cl->un.inner, 0, sizeof(*cl->un.inner));
 			else {
-				if (cl->un.leaf.q)
-					qdisc_reset(cl->un.leaf.q);
-				INIT_LIST_HEAD(&cl->un.leaf.drop_list);
+				if (cl->un.leaf->q)
+					qdisc_reset(cl->un.leaf->q);
+				INIT_LIST_HEAD(&cl->un.leaf->drop_list);
 			}
 			cl->prio_activity = 0;
 			cl->cmode = HTB_CAN_SEND;
@@ -1173,8 +1224,8 @@ static int htb_dump_class(struct Qdisc *
 	spin_lock_bh(&sch->dev->queue_lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
-	if (!cl->level && cl->un.leaf.q)
-		tcm->tcm_info = cl->un.leaf.q->handle;
+	if (!cl->level && cl->un.leaf->q)
+		tcm->tcm_info = cl->un.leaf->q->handle;
 
 	rta = (struct rtattr *)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
@@ -1185,8 +1236,8 @@ static int htb_dump_class(struct Qdisc *
 	opt.buffer = cl->buffer;
 	opt.ceil = cl->ceil->rate;
 	opt.cbuffer = cl->cbuffer;
-	opt.quantum = cl->un.leaf.quantum;
-	opt.prio = cl->un.leaf.prio;
+	opt.quantum = cl->quantum;
+	opt.prio = cl->prio;
 	opt.level = cl->level;
 	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 	rta->rta_len = skb->tail - b;
@@ -1208,8 +1259,8 @@ htb_dump_class_stats(struct Qdisc *sch, 
 	cl->rate_est.pps = cl->rate_packets / (HTB_EWMAC * HTB_HSIZE);
 #endif
 
-	if (!cl->level && cl->un.leaf.q)
-		cl->qstats.qlen = cl->un.leaf.q->q.qlen;
+	if (!cl->level && cl->un.leaf->q)
+		cl->qstats.qlen = cl->un.leaf->q->q.qlen;
 	cl->xstats.tokens = cl->tokens;
 	cl->xstats.ctokens = cl->ctokens;
 
@@ -1233,7 +1284,7 @@ static int htb_graft(struct Qdisc *sch, 
 		    == NULL)
 			return -ENOBUFS;
 		sch_tree_lock(sch);
-		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
+		if ((*old = xchg(&cl->un.leaf->q, new)) != NULL) {
 			qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 			qdisc_reset(*old);
 		}
@@ -1246,14 +1297,14 @@ static int htb_graft(struct Qdisc *sch, 
 static struct Qdisc *htb_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
-	return (cl && !cl->level) ? cl->un.leaf.q : NULL;
+	return (cl && !cl->level) ? cl->un.leaf->q : NULL;
 }
 
 static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
-	if (cl->un.leaf.q->q.qlen == 0)
+	if (cl->un.leaf->q->q.qlen == 0)
 		htb_deactivate(qdisc_priv(sch), cl);
 }
 
@@ -1289,18 +1340,19 @@ static inline int htb_parent_last_child(
 	return 1;
 }
 
-static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
+static void htb_parent_to_leaf(struct htb_class *cl,
+					struct htb_class_leaf *tmp_leaf)
 {
 	struct htb_class *parent = cl->parent;
 
-	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
+	BUG_TRAP(!cl->level && cl->un.leaf->q && !cl->prio_activity);
 
 	parent->level = 0;
-	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
-	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
-	parent->un.leaf.q = new_q ? new_q : &noop_qdisc;
-	parent->un.leaf.quantum = parent->quantum;
-	parent->un.leaf.prio = parent->prio;
+	HTB_DEBUG_INNER(-1);
+	kfree(parent->un.inner);
+	/* tmp_leaf->q has &noop_qdisc at least */
+	parent->un.leaf = tmp_leaf;
+	INIT_LIST_HEAD(&parent->un.leaf->drop_list);
 	parent->tokens = parent->buffer;
 	parent->ctokens = parent->cbuffer;
 	PSCHED_GET_TIME(parent->t_c);
@@ -1312,8 +1364,8 @@ static void htb_destroy_class(struct Qdi
 	struct htb_sched *q = qdisc_priv(sch);
 
 	if (!cl->level) {
-		BUG_TRAP(cl->un.leaf.q);
-		qdisc_destroy(cl->un.leaf.q);
+		BUG_TRAP(cl->un.leaf->q);
+		qdisc_destroy(cl->un.leaf->q);
 	}
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
@@ -1334,6 +1386,15 @@ static void htb_destroy_class(struct Qdi
 	if (cl->cmode != HTB_CAN_SEND)
 		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
 
+	if (!cl->level) {
+		HTB_DEBUG_LEAF(-1);
+		kfree(cl->un.leaf);
+	} else {
+		HTB_DEBUG_INNER(-1);
+		kfree(cl->un.inner);
+	}
+
+	HTB_DEBUG_CLASS(-1);
 	kfree(cl);
 }
 
@@ -1364,19 +1425,34 @@ static int htb_delete(struct Qdisc *sch,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 	unsigned int qlen;
-	struct Qdisc *new_q = NULL;
+	struct htb_class_leaf *tmp_leaf = NULL;
 	int last_child = 0;
 
-	// TODO: why don't allow to delete subtree ? references ? does
-	// tc subsys quarantee us that in htb_destroy it holds no class
-	// refs so that we can remove children safely there ?
+	/*
+	 * TODO: why don't allow to delete subtree ? references ? does
+	 * tc subsys quarantee us that in htb_destroy it holds no class
+	 * refs so that we can remove children safely there ?
+	 */
 	if (!list_empty(&cl->children) || cl->filter_cnt)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-						cl->parent->classid);
-		last_child = 1;
+		if ((tmp_leaf = kzalloc(sizeof(struct htb_class_leaf),
+								GFP_KERNEL))) {
+			HTB_DEBUG_LEAF(1);
+			tmp_leaf->q = qdisc_create_dflt(sch->dev,
+					&pfifo_qdisc_ops, cl->parent->classid);
+			if (!tmp_leaf->q)
+				tmp_leaf->q = &noop_qdisc;
+
+			last_child = 1;
+		} else
+			printk(KERN_WARNING
+				"htb: no memory for parent to leaf change!\n");
+			/*
+			 * last_child == 0, so no htb_parent_to_leaf
+			 * but we delete anyway.
+			 */
 	}
 
 	sch_tree_lock(sch);
@@ -1385,16 +1461,16 @@ static int htb_delete(struct Qdisc *sch,
 	hlist_del_init(&cl->hlist);
 
 	if (!cl->level) {
-		qlen = cl->un.leaf.q->q.qlen;
-		qdisc_reset(cl->un.leaf.q);
-		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
+		qlen = cl->un.leaf->q->q.qlen;
+		qdisc_reset(cl->un.leaf->q);
+		qdisc_tree_decrease_qlen(cl->un.leaf->q, qlen);
 	}
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
 	if (last_child)
-		htb_parent_to_leaf(cl, new_q);
+		htb_parent_to_leaf(cl, tmp_leaf);
 
 	if (--cl->refcnt == 0)
 		htb_destroy_class(sch, cl);
@@ -1441,6 +1517,7 @@ static int htb_change_class(struct Qdisc
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
 		int prio;
+		struct htb_class_inner *tmp_inner = NULL;
 
 		/* check for valid classid */
 		if (!classid || TC_H_MAJ(classid ^ sch->handle)
@@ -1456,11 +1533,32 @@ static int htb_change_class(struct Qdisc
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
+		HTB_DEBUG_CLASS(1);
+		if ((cl->un.leaf = kzalloc(sizeof(struct htb_class_leaf),
+						GFP_KERNEL)) == NULL) {
+			HTB_DEBUG_CLASS(-1);
+			kfree(cl);
+			goto failure;
+		}
+
+		HTB_DEBUG_LEAF(1);
+		if (parent && !parent->level) {
+			if ((tmp_inner = kzalloc(sizeof(struct htb_class_inner),
+							GFP_KERNEL)) == NULL) {
+				HTB_DEBUG_LEAF(-1);
+				kfree(cl->un.leaf);
+				HTB_DEBUG_CLASS(-1);
+				kfree(cl);
+				goto failure;
+			} else
+				HTB_DEBUG_INNER(1);
+		}
+
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
-		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
+		INIT_LIST_HEAD(&cl->un.leaf->drop_list);
 		RB_CLEAR_NODE(&cl->pq_node);
 
 		for (prio = 0; prio < TC_HTB_NUMPRIO; prio++)
@@ -1472,12 +1570,12 @@ static int htb_change_class(struct Qdisc
 		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
-			unsigned int qlen = parent->un.leaf.q->q.qlen;
+			unsigned int qlen = parent->un.leaf->q->q.qlen;
 
 			/* turn parent into inner node */
-			qdisc_reset(parent->un.leaf.q);
-			qdisc_tree_decrease_qlen(parent->un.leaf.q, qlen);
-			qdisc_destroy(parent->un.leaf.q);
+			qdisc_reset(parent->un.leaf->q);
+			qdisc_tree_decrease_qlen(parent->un.leaf->q, qlen);
+			qdisc_destroy(parent->un.leaf->q);
 			if (parent->prio_activity)
 				htb_deactivate(q, parent);
 
@@ -1486,12 +1584,17 @@ static int htb_change_class(struct Qdisc
 				htb_safe_rb_erase(&parent->pq_node, q->wait_pq);
 				parent->cmode = HTB_CAN_SEND;
 			}
-			parent->level = (parent->parent ? parent->parent->level
-					 : TC_HTB_MAXDEPTH) - 1;
-			memset(&parent->un.inner, 0, sizeof(parent->un.inner));
+			parent->level = (parent->parent ?
+				parent->parent->level : TC_HTB_MAXDEPTH) - 1;
+
+			HTB_DEBUG_LEAF(-1);
+			kfree(parent->un.leaf);
+			parent->un.inner = tmp_inner;
+			tmp_inner = NULL;
 		}
+
 		/* leaf (we) needs elementary qdisc */
-		cl->un.leaf.q = new_q ? new_q : &noop_qdisc;
+		cl->un.leaf->q = new_q ? new_q : &noop_qdisc;
 
 		cl->classid = classid;
 		cl->parent = parent;
@@ -1513,27 +1616,23 @@ static int htb_change_class(struct Qdisc
 	/* it used to be a nasty bug here, we have to check that node
 	   is really leaf before changing cl->un.leaf ! */
 	if (!cl->level) {
-		cl->un.leaf.quantum = rtab->rate.rate / q->rate2quantum;
-		if (!hopt->quantum && cl->un.leaf.quantum < 1000) {
+		cl->quantum = rtab->rate.rate / q->rate2quantum;
+		if (!hopt->quantum && cl->quantum < 1000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
 			       cl->classid);
-			cl->un.leaf.quantum = 1000;
+			cl->quantum = 1000;
 		}
-		if (!hopt->quantum && cl->un.leaf.quantum > 200000) {
+		if (!hopt->quantum && cl->quantum > 200000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is big. Consider r2q change.\n",
 			       cl->classid);
-			cl->un.leaf.quantum = 200000;
+			cl->quantum = 200000;
 		}
 		if (hopt->quantum)
-			cl->un.leaf.quantum = hopt->quantum;
-		if ((cl->un.leaf.prio = hopt->prio) >= TC_HTB_NUMPRIO)
-			cl->un.leaf.prio = TC_HTB_NUMPRIO - 1;
-
-		/* backup for htb_parent_to_leaf */
-		cl->quantum = cl->un.leaf.quantum;
-		cl->prio = cl->un.leaf.prio;
+			cl->quantum = hopt->quantum;
+		if ((cl->prio = hopt->prio) >= TC_HTB_NUMPRIO)
+			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
 	cl->buffer = hopt->buffer;
@@ -1665,6 +1764,7 @@ static int __init htb_module_init(void)
 static void __exit htb_module_exit(void)
 {
 	unregister_qdisc(&htb_qdisc_ops);
+	HTB_DEBUG_CLASSES(); 
 }
 
 module_init(htb_module_init)
