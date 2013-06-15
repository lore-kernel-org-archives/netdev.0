From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] htb: refactor struct htb_sched fields for
 performance
Date: Sat, 15 Jun 2013 03:30:10 -0700
Message-ID: <1371292210.3252.159.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:59820 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab3FOKaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 06:30:15 -0400
Received: by mail-ea0-f174.google.com with SMTP id o10so819995eaj.33
        for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 03:30:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

htb_sched structures are big, and source of false sharing on SMP.

Every time a packet is queued or dequeue, many cache lines must be
touched because structures are not lay out properly.

By carefully splitting htb_sched in two parts, and define sub structures
to increase data locality, we can improve performance dramatically on
SMP.

New htb_prio structure can also be used in htb_class to increase data
locality.

I got 26 % performance increase on a 24 threads machine, with 200
concurrent netperf in TCP_RR mode, using a HTB hierarchy of 4 classes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/sched/sch_htb.c |  181 ++++++++++++++++++++++--------------------
 1 file changed, 95 insertions(+), 86 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 7954e73..c2124ea 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -76,6 +76,20 @@ enum htb_cmode {
 	HTB_CAN_SEND		/* class can send */
 };
 
+struct htb_prio {
+	union {
+		struct rb_root	row;
+		struct rb_root	feed;
+	};
+	struct rb_node	*ptr;
+	/* When class changes from state 1->2 and disconnects from
+	 * parent's feed then we lost ptr value and start from the
+	 * first child again. Here we store classid of the
+	 * last valid ptr (used when ptr is NULL).
+	 */
+	u32		last_ptr_id;
+};
+
 /* interior & leaf nodes; props specific to leaves are marked L:
  * To reduce false sharing, place mostly read fields at beginning,
  * and mostly written ones at the end.
@@ -112,19 +126,12 @@ struct htb_class {
 
 	union {
 		struct htb_class_leaf {
-			struct Qdisc *q;
-			int deficit[TC_HTB_MAXDEPTH];
 			struct list_head drop_list;
+			int		deficit[TC_HTB_MAXDEPTH];
+			struct Qdisc	*q;
 		} leaf;
 		struct htb_class_inner {
-			struct rb_root feed[TC_HTB_NUMPRIO];	/* feed trees */
-			struct rb_node *ptr[TC_HTB_NUMPRIO];	/* current class ptr */
-			/* When class changes from state 1->2 and disconnects from
-			 * parent's feed then we lost ptr value and start from the
-			 * first child again. Here we store classid of the
-			 * last valid ptr (used when ptr is NULL).
-			 */
-			u32 last_ptr_id[TC_HTB_NUMPRIO];
+			struct htb_prio clprio[TC_HTB_NUMPRIO];
 		} inner;
 	} un;
 	s64			pq_key;
@@ -135,40 +142,39 @@ struct htb_class {
 	struct rb_node		node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
 };
 
+struct htb_level {
+	struct rb_root	wait_pq;
+	struct htb_prio hprio[TC_HTB_NUMPRIO];
+};
+
 struct htb_sched {
 	struct Qdisc_class_hash clhash;
-	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
-
-	/* self list - roots of self generating tree */
-	struct rb_root row[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
-	int row_mask[TC_HTB_MAXDEPTH];
-	struct rb_node *ptr[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
-	u32 last_ptr_id[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
+	int			defcls;		/* class where unclassified flows go to */
+	int			rate2quantum;	/* quant = rate / rate2quantum */
 
-	/* self wait list - roots of wait PQs per row */
-	struct rb_root wait_pq[TC_HTB_MAXDEPTH];
+	/* filters for qdisc itself */
+	struct tcf_proto	*filter_list;
 
-	/* time of nearest event per level (row) */
-	s64	near_ev_cache[TC_HTB_MAXDEPTH];
+#define HTB_WARN_TOOMANYEVENTS	0x1
+	unsigned int		warned;	/* only one warning */
+	int			direct_qlen;
+	struct work_struct	work;
 
-	int defcls;		/* class where unclassified flows go to */
+	/* non shaped skbs; let them go directly thru */
+	struct sk_buff_head	direct_queue;
+	long			direct_pkts;
 
-	/* filters for qdisc itself */
-	struct tcf_proto *filter_list;
+	struct qdisc_watchdog	watchdog;
 
-	int	rate2quantum;	/* quant = rate / rate2quantum */
-	s64	now;	/* cached dequeue time */
-	struct qdisc_watchdog watchdog;
+	s64			now;	/* cached dequeue time */
+	struct list_head	drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
-	/* non shaped skbs; let them go directly thru */
-	struct sk_buff_head direct_queue;
-	int direct_qlen;	/* max qlen of above */
+	/* time of nearest event per level (row) */
+	s64			near_ev_cache[TC_HTB_MAXDEPTH];
 
-	long direct_pkts;
+	int			row_mask[TC_HTB_MAXDEPTH];
 
-#define HTB_WARN_TOOMANYEVENTS	0x1
-	unsigned int warned;	/* only one warning */
-	struct work_struct work;
+	struct htb_level	hlevel[TC_HTB_MAXDEPTH];
 };
 
 /* find class in global hash table using given handle */
@@ -284,7 +290,7 @@ static void htb_add_to_id_tree(struct rb_root *root,
 static void htb_add_to_wait_tree(struct htb_sched *q,
 				 struct htb_class *cl, s64 delay)
 {
-	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;
+	struct rb_node **p = &q->hlevel[cl->level].wait_pq.rb_node, *parent = NULL;
 
 	cl->pq_key = q->now + delay;
 	if (cl->pq_key == q->now)
@@ -304,7 +310,7 @@ static void htb_add_to_wait_tree(struct htb_sched *q,
 			p = &parent->rb_left;
 	}
 	rb_link_node(&cl->pq_node, parent, p);
-	rb_insert_color(&cl->pq_node, &q->wait_pq[cl->level]);
+	rb_insert_color(&cl->pq_node, &q->hlevel[cl->level].wait_pq);
 }
 
 /**
@@ -331,7 +337,7 @@ static inline void htb_add_class_to_row(struct htb_sched *q,
 	while (mask) {
 		int prio = ffz(~mask);
 		mask &= ~(1 << prio);
-		htb_add_to_id_tree(q->row[cl->level] + prio, cl, prio);
+		htb_add_to_id_tree(&q->hlevel[cl->level].hprio[prio].row, cl, prio);
 	}
 }
 
@@ -357,16 +363,18 @@ static inline void htb_remove_class_from_row(struct htb_sched *q,
 						 struct htb_class *cl, int mask)
 {
 	int m = 0;
+	struct htb_level *hlevel = &q->hlevel[cl->level];
 
 	while (mask) {
 		int prio = ffz(~mask);
+		struct htb_prio *hprio = &hlevel->hprio[prio];
 
 		mask &= ~(1 << prio);
-		if (q->ptr[cl->level][prio] == cl->node + prio)
-			htb_next_rb_node(q->ptr[cl->level] + prio);
+		if (hprio->ptr == cl->node + prio)
+			htb_next_rb_node(&hprio->ptr);
 
-		htb_safe_rb_erase(cl->node + prio, q->row[cl->level] + prio);
-		if (!q->row[cl->level][prio].rb_node)
+		htb_safe_rb_erase(cl->node + prio, &hprio->row);
+		if (!hprio->row.rb_node)
 			m |= 1 << prio;
 	}
 	q->row_mask[cl->level] &= ~m;
@@ -390,13 +398,13 @@ static void htb_activate_prios(struct htb_sched *q, struct htb_class *cl)
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
 
-			if (p->un.inner.feed[prio].rb_node)
+			if (p->un.inner.clprio[prio].feed.rb_node)
 				/* parent already has its feed in use so that
 				 * reset bit in mask as parent is already ok
 				 */
 				mask &= ~(1 << prio);
 
-			htb_add_to_id_tree(p->un.inner.feed + prio, cl, prio);
+			htb_add_to_id_tree(&p->un.inner.clprio[prio].feed, cl, prio);
 		}
 		p->prio_activity |= mask;
 		cl = p;
@@ -426,18 +434,19 @@ static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
 
-			if (p->un.inner.ptr[prio] == cl->node + prio) {
+			if (p->un.inner.clprio[prio].ptr == cl->node + prio) {
 				/* we are removing child which is pointed to from
 				 * parent feed - forget the pointer but remember
 				 * classid
 				 */
-				p->un.inner.last_ptr_id[prio] = cl->common.classid;
-				p->un.inner.ptr[prio] = NULL;
+				p->un.inner.clprio[prio].last_ptr_id = cl->common.classid;
+				p->un.inner.clprio[prio].ptr = NULL;
 			}
 
-			htb_safe_rb_erase(cl->node + prio, p->un.inner.feed + prio);
+			htb_safe_rb_erase(cl->node + prio,
+					  &p->un.inner.clprio[prio].feed);
 
-			if (!p->un.inner.feed[prio].rb_node)
+			if (!p->un.inner.clprio[prio].feed.rb_node)
 				mask |= 1 << prio;
 		}
 
@@ -652,7 +661,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 		htb_change_class_mode(q, cl, &diff);
 		if (old_mode != cl->cmode) {
 			if (old_mode != HTB_CAN_SEND)
-				htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+				htb_safe_rb_erase(&cl->pq_node, &q->hlevel[cl->level].wait_pq);
 			if (cl->cmode != HTB_CAN_SEND)
 				htb_add_to_wait_tree(q, cl, diff);
 		}
@@ -672,7 +681,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
  * next pending event (0 for no event in pq, q->now for too many events).
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
-static s64 htb_do_events(struct htb_sched *q, int level,
+static s64 htb_do_events(struct htb_sched *q, const int level,
 			 unsigned long start)
 {
 	/* don't run for longer than 2 jiffies; 2 is used instead of
@@ -680,10 +689,12 @@ static s64 htb_do_events(struct htb_sched *q, int level,
 	 * too soon
 	 */
 	unsigned long stop_at = start + 2;
+	struct rb_root *wait_pq = &q->hlevel[level].wait_pq;
+
 	while (time_before(jiffies, stop_at)) {
 		struct htb_class *cl;
 		s64 diff;
-		struct rb_node *p = rb_first(&q->wait_pq[level]);
+		struct rb_node *p = rb_first(wait_pq);
 
 		if (!p)
 			return 0;
@@ -692,7 +703,7 @@ static s64 htb_do_events(struct htb_sched *q, int level,
 		if (cl->pq_key > q->now)
 			return cl->pq_key;
 
-		htb_safe_rb_erase(p, q->wait_pq + level);
+		htb_safe_rb_erase(p, wait_pq);
 		diff = min_t(s64, q->now - cl->t_c, cl->mbuffer);
 		htb_change_class_mode(q, cl, &diff);
 		if (cl->cmode != HTB_CAN_SEND)
@@ -736,8 +747,7 @@ static struct rb_node *htb_id_find_next_upper(int prio, struct rb_node *n,
  *
  * Find leaf where current feed pointers points to.
  */
-static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
-					 struct rb_node **pptr, u32 * pid)
+static struct htb_class *htb_lookup_leaf(struct htb_prio *hprio, const int prio)
 {
 	int i;
 	struct {
@@ -746,10 +756,10 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 		u32 *pid;
 	} stk[TC_HTB_MAXDEPTH], *sp = stk;
 
-	BUG_ON(!tree->rb_node);
-	sp->root = tree->rb_node;
-	sp->pptr = pptr;
-	sp->pid = pid;
+	BUG_ON(!hprio->row.rb_node);
+	sp->root = hprio->row.rb_node;
+	sp->pptr = &hprio->ptr;
+	sp->pid = &hprio->last_ptr_id;
 
 	for (i = 0; i < 65535; i++) {
 		if (!*sp->pptr && *sp->pid) {
@@ -776,12 +786,15 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 			}
 		} else {
 			struct htb_class *cl;
+			struct htb_prio *clp;
+
 			cl = rb_entry(*sp->pptr, struct htb_class, node[prio]);
 			if (!cl->level)
 				return cl;
-			(++sp)->root = cl->un.inner.feed[prio].rb_node;
-			sp->pptr = cl->un.inner.ptr + prio;
-			sp->pid = cl->un.inner.last_ptr_id + prio;
+			clp = &cl->un.inner.clprio[prio];
+			(++sp)->root = clp->feed.rb_node;
+			sp->pptr = &clp->ptr;
+			sp->pid = &clp->last_ptr_id;
 		}
 	}
 	WARN_ON(1);
@@ -791,15 +804,16 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 /* dequeues packet at given priority and level; call only if
  * you are sure that there is active class at prio/level
  */
-static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
-					int level)
+static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, const int prio,
+					const int level)
 {
 	struct sk_buff *skb = NULL;
 	struct htb_class *cl, *start;
+	struct htb_level *hlevel = &q->hlevel[level];
+	struct htb_prio *hprio = &hlevel->hprio[prio];
+
 	/* look initial class up in the row */
-	start = cl = htb_lookup_leaf(q->row[level] + prio, prio,
-				     q->ptr[level] + prio,
-				     q->last_ptr_id[level] + prio);
+	start = cl = htb_lookup_leaf(hprio, prio);
 
 	do {
 next:
@@ -819,9 +833,7 @@ next:
 			if ((q->row_mask[level] & (1 << prio)) == 0)
 				return NULL;
 
-			next = htb_lookup_leaf(q->row[level] + prio,
-					       prio, q->ptr[level] + prio,
-					       q->last_ptr_id[level] + prio);
+			next = htb_lookup_leaf(hprio, prio);
 
 			if (cl == start)	/* fix start if we just deleted it */
 				start = next;
@@ -834,11 +846,9 @@ next:
 			break;
 
 		qdisc_warn_nonwc("htb", cl->un.leaf.q);
-		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
-				  ptr[0]) + prio);
-		cl = htb_lookup_leaf(q->row[level] + prio, prio,
-				     q->ptr[level] + prio,
-				     q->last_ptr_id[level] + prio);
+		htb_next_rb_node(level ? &cl->parent->un.inner.clprio[prio].ptr:
+					 &q->hlevel[0].hprio[prio].ptr);
+		cl = htb_lookup_leaf(hprio, prio);
 
 	} while (cl != start);
 
@@ -847,8 +857,8 @@ next:
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->quantum;
-			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
-					  ptr[0]) + prio);
+			htb_next_rb_node(level ? &cl->parent->un.inner.clprio[prio].ptr :
+						 &q->hlevel[0].hprio[prio].ptr);
 		}
 		/* this used to be after charge_class but this constelation
 		 * gives us slightly better performance
@@ -888,15 +898,14 @@ ok:
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
 		int m;
-		s64 event;
+		s64 event = q->near_ev_cache[level];
 
-		if (q->now >= q->near_ev_cache[level]) {
+		if (q->now >= event) {
 			event = htb_do_events(q, level, start_at);
 			if (!event)
 				event = q->now + NSEC_PER_SEC;
 			q->near_ev_cache[level] = event;
-		} else
-			event = q->near_ev_cache[level];
+		}
 
 		if (next_event > event)
 			next_event = event;
@@ -976,10 +985,8 @@ static void htb_reset(struct Qdisc *sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 	__skb_queue_purge(&q->direct_queue);
 	sch->q.qlen = 0;
-	memset(q->row, 0, sizeof(q->row));
+	memset(q->hlevel, 0, sizeof(q->hlevel));
 	memset(q->row_mask, 0, sizeof(q->row_mask));
-	memset(q->wait_pq, 0, sizeof(q->wait_pq));
-	memset(q->ptr, 0, sizeof(q->ptr));
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
 		INIT_LIST_HEAD(q->drops + i);
 }
@@ -1200,7 +1207,8 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 	WARN_ON(cl->level || !cl->un.leaf.q || cl->prio_activity);
 
 	if (parent->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&parent->pq_node, q->wait_pq + parent->level);
+		htb_safe_rb_erase(&parent->pq_node,
+				  &q->hlevel[parent->level].wait_pq);
 
 	parent->level = 0;
 	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
@@ -1289,7 +1297,8 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		htb_deactivate(q, cl);
 
 	if (cl->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+		htb_safe_rb_erase(&cl->pq_node,
+				  &q->hlevel[cl->level].wait_pq);
 
 	if (last_child)
 		htb_parent_to_leaf(q, cl, new_q);
@@ -1411,7 +1420,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 			/* remove from evt list because of level change */
 			if (parent->cmode != HTB_CAN_SEND) {
-				htb_safe_rb_erase(&parent->pq_node, q->wait_pq);
+				htb_safe_rb_erase(&parent->pq_node, &q->hlevel[0].wait_pq);
 				parent->cmode = HTB_CAN_SEND;
 			}
 			parent->level = (parent->parent ? parent->parent->level
