From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATHC 4/6] htb: Lindent
Date: Wed, 2 Aug 2006 13:01:08 -0700
Message-ID: <20060802130108.1e1cb13a@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50893 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932271AbWHBWMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:21 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code was a mess in terms of indentation.  Run through Lindent
script, and cleanup the damage. Also, don't use, vim magic
comment, and substitute inline for __inline__.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c | 1001 +++++++++++++++++++++++++++------------------------
 1 files changed, 526 insertions(+), 475 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d8c1a6b..528d5c5 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1,4 +1,4 @@
-/* vim: ts=8 sw=8
+/*
  * net/sched/sch_htb.c	Hierarchical token bucket, feed tree version
  *
  *		This program is free software; you can redistribute it and/or
@@ -68,11 +68,11 @@ #include <linux/rbtree.h>
     one less than their parent.
 */
 
-#define HTB_HSIZE 16	/* classid hash size */
-#define HTB_EWMAC 2	/* rate average over HTB_EWMAC*HTB_HSIZE sec */
-#define HTB_RATECM 1    /* whether to use rate computer */
-#define HTB_HYSTERESIS 1/* whether to use mode hysteresis for speedup */
-#define HTB_VER 0x30011	/* major must be matched with number suplied by TC as version */
+#define HTB_HSIZE 16		/* classid hash size */
+#define HTB_EWMAC 2		/* rate average over HTB_EWMAC*HTB_HSIZE sec */
+#define HTB_RATECM 1		/* whether to use rate computer */
+#define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
+#define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
 #error "Mismatched sch_htb.c and pkt_sch.h"
@@ -80,154 +80,152 @@ #endif
 
 /* used internaly to keep status of single class */
 enum htb_cmode {
-    HTB_CANT_SEND,		/* class can't send and can't borrow */
-    HTB_MAY_BORROW,		/* class can't send but may borrow */
-    HTB_CAN_SEND		/* class can send */
+	HTB_CANT_SEND,		/* class can't send and can't borrow */
+	HTB_MAY_BORROW,		/* class can't send but may borrow */
+	HTB_CAN_SEND		/* class can send */
 };
 
 /* interior & leaf nodes; props specific to leaves are marked L: */
-struct htb_class
-{
-    /* general class parameters */
-    u32 classid;
-    struct gnet_stats_basic bstats;
-    struct gnet_stats_queue qstats;
-    struct gnet_stats_rate_est rate_est;
-    struct tc_htb_xstats xstats;/* our special stats */
-    int refcnt;			/* usage count of this class */
+struct htb_class {
+	/* general class parameters */
+	u32 classid;
+	struct gnet_stats_basic bstats;
+	struct gnet_stats_queue qstats;
+	struct gnet_stats_rate_est rate_est;
+	struct tc_htb_xstats xstats;	/* our special stats */
+	int refcnt;		/* usage count of this class */
 
 #ifdef HTB_RATECM
-    /* rate measurement counters */
-    unsigned long rate_bytes,sum_bytes;
-    unsigned long rate_packets,sum_packets;
+	/* rate measurement counters */
+	unsigned long rate_bytes, sum_bytes;
+	unsigned long rate_packets, sum_packets;
 #endif
 
-    /* topology */
-    int level;			/* our level (see above) */
-    struct htb_class *parent;	/* parent class */
-    struct list_head hlist;	/* classid hash list item */
-    struct list_head sibling;	/* sibling list item */
-    struct list_head children;	/* children list */
-
-    union {
-	    struct htb_class_leaf {
-		    struct Qdisc *q;
-		    int prio;
-		    int aprio;	
-		    int quantum;
-		    int deficit[TC_HTB_MAXDEPTH];
-		    struct list_head drop_list;
-	    } leaf;
-	    struct htb_class_inner {
-		    struct rb_root feed[TC_HTB_NUMPRIO]; /* feed trees */
-		    struct rb_node *ptr[TC_HTB_NUMPRIO]; /* current class ptr */
-            /* When class changes from state 1->2 and disconnects from 
-               parent's feed then we lost ptr value and start from the
-              first child again. Here we store classid of the
-              last valid ptr (used when ptr is NULL). */
-              u32 last_ptr_id[TC_HTB_NUMPRIO];
-	    } inner;
-    } un;
-    struct rb_node node[TC_HTB_NUMPRIO]; /* node for self or feed tree */
-    struct rb_node pq_node;		 /* node for event queue */
-    unsigned long pq_key;	/* the same type as jiffies global */
-    
-    int prio_activity;		/* for which prios are we active */
-    enum htb_cmode cmode;	/* current mode of the class */
-
-    /* class attached filters */
-    struct tcf_proto *filter_list;
-    int filter_cnt;
-
-    int warned;		/* only one warning about non work conserving .. */
-
-    /* token bucket parameters */
-    struct qdisc_rate_table *rate;	/* rate table of the class itself */
-    struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
-    long buffer,cbuffer;		/* token bucket depth/rate */
-    psched_tdiff_t mbuffer;		/* max wait time */
-    long tokens,ctokens;		/* current number of tokens */
-    psched_time_t t_c;			/* checkpoint time */
+	/* topology */
+	int level;		/* our level (see above) */
+	struct htb_class *parent;	/* parent class */
+	struct list_head hlist;	/* classid hash list item */
+	struct list_head sibling;	/* sibling list item */
+	struct list_head children;	/* children list */
+
+	union {
+		struct htb_class_leaf {
+			struct Qdisc *q;
+			int prio;
+			int aprio;
+			int quantum;
+			int deficit[TC_HTB_MAXDEPTH];
+			struct list_head drop_list;
+		} leaf;
+		struct htb_class_inner {
+			struct rb_root feed[TC_HTB_NUMPRIO];	/* feed trees */
+			struct rb_node *ptr[TC_HTB_NUMPRIO];	/* current class ptr */
+			/* When class changes from state 1->2 and disconnects from 
+			   parent's feed then we lost ptr value and start from the
+			   first child again. Here we store classid of the
+			   last valid ptr (used when ptr is NULL). */
+			u32 last_ptr_id[TC_HTB_NUMPRIO];
+		} inner;
+	} un;
+	struct rb_node node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
+	struct rb_node pq_node;	/* node for event queue */
+	unsigned long pq_key;	/* the same type as jiffies global */
+
+	int prio_activity;	/* for which prios are we active */
+	enum htb_cmode cmode;	/* current mode of the class */
+
+	/* class attached filters */
+	struct tcf_proto *filter_list;
+	int filter_cnt;
+
+	int warned;		/* only one warning about non work conserving .. */
+
+	/* token bucket parameters */
+	struct qdisc_rate_table *rate;	/* rate table of the class itself */
+	struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
+	long buffer, cbuffer;	/* token bucket depth/rate */
+	psched_tdiff_t mbuffer;	/* max wait time */
+	long tokens, ctokens;	/* current number of tokens */
+	psched_time_t t_c;	/* checkpoint time */
 };
 
 /* TODO: maybe compute rate when size is too large .. or drop ? */
-static __inline__ long L2T(struct htb_class *cl,struct qdisc_rate_table *rate,
-	int size)
-{ 
-    int slot = size >> rate->rate.cell_log;
-    if (slot > 255) {
-	cl->xstats.giants++;
-	slot = 255;
-    }
-    return rate->data[slot];
+static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
+			   int size)
+{
+	int slot = size >> rate->rate.cell_log;
+	if (slot > 255) {
+		cl->xstats.giants++;
+		slot = 255;
+	}
+	return rate->data[slot];
 }
 
-struct htb_sched
-{
-    struct list_head root;			/* root classes list */
-    struct list_head hash[HTB_HSIZE];		/* hashed by classid */
-    struct list_head drops[TC_HTB_NUMPRIO];	/* active leaves (for drops) */
-    
-    /* self list - roots of self generating tree */
-    struct rb_root row[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
-    int row_mask[TC_HTB_MAXDEPTH];
-    struct rb_node *ptr[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
-    u32 last_ptr_id[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
+struct htb_sched {
+	struct list_head root;	/* root classes list */
+	struct list_head hash[HTB_HSIZE];	/* hashed by classid */
+	struct list_head drops[TC_HTB_NUMPRIO];	/* active leaves (for drops) */
+
+	/* self list - roots of self generating tree */
+	struct rb_root row[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
+	int row_mask[TC_HTB_MAXDEPTH];
+	struct rb_node *ptr[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
+	u32 last_ptr_id[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
 
-    /* self wait list - roots of wait PQs per row */
-    struct rb_root wait_pq[TC_HTB_MAXDEPTH];
+	/* self wait list - roots of wait PQs per row */
+	struct rb_root wait_pq[TC_HTB_MAXDEPTH];
 
-    /* time of nearest event per level (row) */
-    unsigned long near_ev_cache[TC_HTB_MAXDEPTH];
+	/* time of nearest event per level (row) */
+	unsigned long near_ev_cache[TC_HTB_MAXDEPTH];
 
-    /* cached value of jiffies in dequeue */
-    unsigned long jiffies;
+	/* cached value of jiffies in dequeue */
+	unsigned long jiffies;
 
-    /* whether we hit non-work conserving class during this dequeue; we use */
-    int nwc_hit;	/* this to disable mindelay complaint in dequeue */
+	/* whether we hit non-work conserving class during this dequeue; we use */
+	int nwc_hit;		/* this to disable mindelay complaint in dequeue */
 
-    int defcls;		/* class where unclassified flows go to */
+	int defcls;		/* class where unclassified flows go to */
 
-    /* filters for qdisc itself */
-    struct tcf_proto *filter_list;
-    int filter_cnt;
+	/* filters for qdisc itself */
+	struct tcf_proto *filter_list;
+	int filter_cnt;
 
-    int rate2quantum;		/* quant = rate / rate2quantum */
-    psched_time_t now;		/* cached dequeue time */
-    struct timer_list timer;	/* send delay timer */
+	int rate2quantum;	/* quant = rate / rate2quantum */
+	psched_time_t now;	/* cached dequeue time */
+	struct timer_list timer;	/* send delay timer */
 #ifdef HTB_RATECM
-    struct timer_list rttim;	/* rate computer timer */
-    int recmp_bucket;		/* which hash bucket to recompute next */
+	struct timer_list rttim;	/* rate computer timer */
+	int recmp_bucket;	/* which hash bucket to recompute next */
 #endif
-    
-    /* non shaped skbs; let them go directly thru */
-    struct sk_buff_head direct_queue;
-    int direct_qlen;  /* max qlen of above */
 
-    long direct_pkts;
+	/* non shaped skbs; let them go directly thru */
+	struct sk_buff_head direct_queue;
+	int direct_qlen;	/* max qlen of above */
+
+	long direct_pkts;
 };
 
 /* compute hash of size HTB_HSIZE for given handle */
-static __inline__ int htb_hash(u32 h) 
+static inline int htb_hash(u32 h)
 {
 #if HTB_HSIZE != 16
- #error "Declare new hash for your HTB_HSIZE"
+#error "Declare new hash for your HTB_HSIZE"
 #endif
-    h ^= h>>8;	/* stolen from cbq_hash */
-    h ^= h>>4;
-    return h & 0xf;
+	h ^= h >> 8;		/* stolen from cbq_hash */
+	h ^= h >> 4;
+	return h & 0xf;
 }
 
 /* find class in global hash table using given handle */
-static __inline__ struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
+static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct list_head *p;
-	if (TC_H_MAJ(handle) != sch->handle) 
+	if (TC_H_MAJ(handle) != sch->handle)
 		return NULL;
-	
-	list_for_each (p,q->hash+htb_hash(handle)) {
-		struct htb_class *cl = list_entry(p,struct htb_class,hlist);
+
+	list_for_each(p, q->hash + htb_hash(handle)) {
+		struct htb_class *cl = list_entry(p, struct htb_class, hlist);
 		if (cl->classid == handle)
 			return cl;
 	}
@@ -252,7 +250,8 @@ static inline u32 htb_classid(struct htb
 	return (cl && cl != HTB_DIRECT) ? cl->classid : TC_H_UNSPEC;
 }
 
-static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
+static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
+				      int *qerr)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl;
@@ -264,8 +263,8 @@ static struct htb_class *htb_classify(st
 	   note that nfmark can be used too by attaching filter fw with no
 	   rules in it */
 	if (skb->priority == sch->handle)
-		return HTB_DIRECT;  /* X:0 (direct flow) selected */
-	if ((cl = htb_find(skb->priority,sch)) != NULL && cl->level == 0) 
+		return HTB_DIRECT;	/* X:0 (direct flow) selected */
+	if ((cl = htb_find(skb->priority, sch)) != NULL && cl->level == 0)
 		return cl;
 
 	*qerr = NET_XMIT_BYPASS;
@@ -274,7 +273,7 @@ static struct htb_class *htb_classify(st
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
-		case TC_ACT_STOLEN: 
+		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS;
 		case TC_ACT_SHOT:
 			return NULL;
@@ -283,22 +282,22 @@ #elif defined(CONFIG_NET_CLS_POLICE)
 		if (result == TC_POLICE_SHOT)
 			return HTB_DIRECT;
 #endif
-		if ((cl = (void*)res.class) == NULL) {
+		if ((cl = (void *)res.class) == NULL) {
 			if (res.classid == sch->handle)
-				return HTB_DIRECT;  /* X:0 (direct flow) */
-			if ((cl = htb_find(res.classid,sch)) == NULL)
-				break; /* filter selected invalid classid */
+				return HTB_DIRECT;	/* X:0 (direct flow) */
+			if ((cl = htb_find(res.classid, sch)) == NULL)
+				break;	/* filter selected invalid classid */
 		}
 		if (!cl->level)
-			return cl; /* we hit leaf; return it */
+			return cl;	/* we hit leaf; return it */
 
 		/* we have got inner class; apply inner filter chain */
 		tcf = cl->filter_list;
 	}
 	/* classification failed; try to use default class */
-	cl = htb_find(TC_H_MAKE(TC_H_MAJ(sch->handle),q->defcls),sch);
+	cl = htb_find(TC_H_MAKE(TC_H_MAJ(sch->handle), q->defcls), sch);
 	if (!cl || cl->level)
-		return HTB_DIRECT; /* bad default .. this is safe bet */
+		return HTB_DIRECT;	/* bad default .. this is safe bet */
 	return cl;
 }
 
@@ -308,18 +307,19 @@ #endif
  * Routine adds class to the list (actually tree) sorted by classid.
  * Make sure that class is not already on such list for given prio.
  */
-static void htb_add_to_id_tree (struct rb_root *root,
-		struct htb_class *cl,int prio)
+static void htb_add_to_id_tree(struct rb_root *root,
+			       struct htb_class *cl, int prio)
 {
 	struct rb_node **p = &root->rb_node, *parent = NULL;
 
 	while (*p) {
-		struct htb_class *c; parent = *p;
+		struct htb_class *c;
+		parent = *p;
 		c = rb_entry(parent, struct htb_class, node[prio]);
 
 		if (cl->classid > c->classid)
 			p = &parent->rb_right;
-		else 
+		else
 			p = &parent->rb_left;
 	}
 	rb_link_node(&cl->node[prio], parent, p);
@@ -333,8 +333,8 @@ static void htb_add_to_id_tree (struct r
  * change its mode in cl->pq_key microseconds. Make sure that class is not
  * already in the queue.
  */
-static void htb_add_to_wait_tree (struct htb_sched *q,
-				  struct htb_class *cl,long delay)
+static void htb_add_to_wait_tree(struct htb_sched *q,
+				 struct htb_class *cl, long delay)
 {
 	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;
 
@@ -345,13 +345,14 @@ static void htb_add_to_wait_tree (struct
 	/* update the nearest event cache */
 	if (time_after(q->near_ev_cache[cl->level], cl->pq_key))
 		q->near_ev_cache[cl->level] = cl->pq_key;
-	
+
 	while (*p) {
-		struct htb_class *c; parent = *p;
+		struct htb_class *c;
+		parent = *p;
 		c = rb_entry(parent, struct htb_class, pq_node);
 		if (time_after_eq(cl->pq_key, c->pq_key))
 			p = &parent->rb_right;
-		else 
+		else
 			p = &parent->rb_left;
 	}
 	rb_link_node(&cl->pq_node, parent, p);
@@ -375,14 +376,14 @@ static void htb_next_rb_node(struct rb_n
  * The class is added to row at priorities marked in mask.
  * It does nothing if mask == 0.
  */
-static inline void htb_add_class_to_row(struct htb_sched *q, 
-		struct htb_class *cl,int mask)
+static inline void htb_add_class_to_row(struct htb_sched *q,
+					struct htb_class *cl, int mask)
 {
 	q->row_mask[cl->level] |= mask;
 	while (mask) {
 		int prio = ffz(~mask);
 		mask &= ~(1 << prio);
-		htb_add_to_id_tree(q->row[cl->level]+prio,cl,prio);
+		htb_add_to_id_tree(q->row[cl->level] + prio, cl, prio);
 	}
 }
 
@@ -392,18 +393,18 @@ static inline void htb_add_class_to_row(
  * The class is removed from row at priorities marked in mask.
  * It does nothing if mask == 0.
  */
-static __inline__ void htb_remove_class_from_row(struct htb_sched *q,
-		struct htb_class *cl,int mask)
+static inline void htb_remove_class_from_row(struct htb_sched *q,
+						 struct htb_class *cl, int mask)
 {
 	int m = 0;
 
 	while (mask) {
 		int prio = ffz(~mask);
 		mask &= ~(1 << prio);
-		if (q->ptr[cl->level][prio] == cl->node+prio)
-			htb_next_rb_node(q->ptr[cl->level]+prio);
-		rb_erase(cl->node + prio,q->row[cl->level]+prio);
-		if (!q->row[cl->level][prio].rb_node) 
+		if (q->ptr[cl->level][prio] == cl->node + prio)
+			htb_next_rb_node(q->ptr[cl->level] + prio);
+		rb_erase(cl->node + prio, q->row[cl->level] + prio);
+		if (!q->row[cl->level][prio].rb_node)
 			m |= 1 << prio;
 	}
 	q->row_mask[cl->level] &= ~m;
@@ -416,30 +417,31 @@ static __inline__ void htb_remove_class_
  * for priorities it is participating on. cl->cmode must be new 
  * (activated) mode. It does nothing if cl->prio_activity == 0.
  */
-static void htb_activate_prios(struct htb_sched *q,struct htb_class *cl)
+static void htb_activate_prios(struct htb_sched *q, struct htb_class *cl)
 {
 	struct htb_class *p = cl->parent;
-	long m,mask = cl->prio_activity;
+	long m, mask = cl->prio_activity;
 
 	while (cl->cmode == HTB_MAY_BORROW && p && mask) {
-
-		m = mask; while (m) {
+		m = mask;
+		while (m) {
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
-			
+
 			if (p->un.inner.feed[prio].rb_node)
 				/* parent already has its feed in use so that
 				   reset bit in mask as parent is already ok */
 				mask &= ~(1 << prio);
-			
-			htb_add_to_id_tree(p->un.inner.feed+prio,cl,prio);
+
+			htb_add_to_id_tree(p->un.inner.feed + prio, cl, prio);
 		}
 		p->prio_activity |= mask;
-		cl = p; p = cl->parent;
+		cl = p;
+		p = cl->parent;
 
 	}
 	if (cl->cmode == HTB_CAN_SEND && mask)
-		htb_add_class_to_row(q,cl,mask);
+		htb_add_class_to_row(q, cl, mask);
 }
 
 /**
@@ -452,35 +454,36 @@ static void htb_activate_prios(struct ht
 static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 {
 	struct htb_class *p = cl->parent;
-	long m,mask = cl->prio_activity;
-
+	long m, mask = cl->prio_activity;
 
 	while (cl->cmode == HTB_MAY_BORROW && p && mask) {
-		m = mask; mask = 0; 
+		m = mask;
+		mask = 0;
 		while (m) {
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
-			
-			if (p->un.inner.ptr[prio] == cl->node+prio) {
+
+			if (p->un.inner.ptr[prio] == cl->node + prio) {
 				/* we are removing child which is pointed to from
 				   parent feed - forget the pointer but remember
 				   classid */
 				p->un.inner.last_ptr_id[prio] = cl->classid;
 				p->un.inner.ptr[prio] = NULL;
 			}
-			
-			rb_erase(cl->node + prio,p->un.inner.feed + prio);
-			
-			if (!p->un.inner.feed[prio].rb_node) 
+
+			rb_erase(cl->node + prio, p->un.inner.feed + prio);
+
+			if (!p->un.inner.feed[prio].rb_node)
 				mask |= 1 << prio;
 		}
 
 		p->prio_activity &= ~mask;
-		cl = p; p = cl->parent;
+		cl = p;
+		p = cl->parent;
 
 	}
-	if (cl->cmode == HTB_CAN_SEND && mask) 
-		htb_remove_class_from_row(q,cl,mask);
+	if (cl->cmode == HTB_CAN_SEND && mask)
+		htb_remove_class_from_row(q, cl, mask);
 }
 
 #if HTB_HYSTERESIS
@@ -508,21 +511,21 @@ #endif
  * 0 .. -cl->{c,}buffer range. It is meant to limit number of
  * mode transitions per time unit. The speed gain is about 1/6.
  */
-static __inline__ enum htb_cmode 
-htb_class_mode(struct htb_class *cl,long *diff)
+static inline enum htb_cmode
+htb_class_mode(struct htb_class *cl, long *diff)
 {
-    long toks;
+	long toks;
 
-    if ((toks = (cl->ctokens + *diff)) < htb_lowater(cl)) {
-	    *diff = -toks;
-	    return HTB_CANT_SEND;
-    }
+	if ((toks = (cl->ctokens + *diff)) < htb_lowater(cl)) {
+		*diff = -toks;
+		return HTB_CANT_SEND;
+	}
 
-    if ((toks = (cl->tokens + *diff)) >= htb_hiwater(cl))
-	    return HTB_CAN_SEND;
+	if ((toks = (cl->tokens + *diff)) >= htb_hiwater(cl))
+		return HTB_CAN_SEND;
 
-    *diff = -toks;
-    return HTB_MAY_BORROW;
+	*diff = -toks;
+	return HTB_MAY_BORROW;
 }
 
 /**
@@ -534,22 +537,21 @@ htb_class_mode(struct htb_class *cl,long
  * be different from old one and cl->pq_key has to be valid if changing
  * to mode other than HTB_CAN_SEND (see htb_add_to_wait_tree).
  */
-static void 
+static void
 htb_change_class_mode(struct htb_sched *q, struct htb_class *cl, long *diff)
-{ 
-	enum htb_cmode new_mode = htb_class_mode(cl,diff);
-	
+{
+	enum htb_cmode new_mode = htb_class_mode(cl, diff);
 
 	if (new_mode == cl->cmode)
-		return;	
-	
-	if (cl->prio_activity) { /* not necessary: speed optimization */
-		if (cl->cmode != HTB_CANT_SEND) 
-			htb_deactivate_prios(q,cl);
+		return;
+
+	if (cl->prio_activity) {	/* not necessary: speed optimization */
+		if (cl->cmode != HTB_CANT_SEND)
+			htb_deactivate_prios(q, cl);
 		cl->cmode = new_mode;
-		if (new_mode != HTB_CANT_SEND) 
-			htb_activate_prios(q,cl);
-	} else 
+		if (new_mode != HTB_CANT_SEND)
+			htb_activate_prios(q, cl);
+	} else
 		cl->cmode = new_mode;
 }
 
@@ -560,14 +562,15 @@ htb_change_class_mode(struct htb_sched *
  * for the prio. It can be called on already active leaf safely.
  * It also adds leaf into droplist.
  */
-static __inline__ void htb_activate(struct htb_sched *q,struct htb_class *cl)
+static inline void htb_activate(struct htb_sched *q, struct htb_class *cl)
 {
 	BUG_TRAP(!cl->level && cl->un.leaf.q && cl->un.leaf.q->q.qlen);
 
 	if (!cl->prio_activity) {
 		cl->prio_activity = 1 << (cl->un.leaf.aprio = cl->un.leaf.prio);
-		htb_activate_prios(q,cl);
-		list_add_tail(&cl->un.leaf.drop_list,q->drops+cl->un.leaf.aprio);
+		htb_activate_prios(q, cl);
+		list_add_tail(&cl->un.leaf.drop_list,
+			      q->drops + cl->un.leaf.aprio);
 	}
 }
 
@@ -577,97 +580,100 @@ static __inline__ void htb_activate(stru
  * Make sure that leaf is active. In the other words it can't be called
  * with non-active leaf. It also removes class from the drop list.
  */
-static __inline__ void 
-htb_deactivate(struct htb_sched *q,struct htb_class *cl)
+static inline void htb_deactivate(struct htb_sched *q, struct htb_class *cl)
 {
 	BUG_TRAP(cl->prio_activity);
 
-	htb_deactivate_prios(q,cl);
+	htb_deactivate_prios(q, cl);
 	cl->prio_activity = 0;
 	list_del_init(&cl->un.leaf.drop_list);
 }
 
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-    int ret;
-    struct htb_sched *q = qdisc_priv(sch);
-    struct htb_class *cl = htb_classify(skb,sch,&ret);
-
-    if (cl == HTB_DIRECT) {
-	/* enqueue to helper queue */
-	if (q->direct_queue.qlen < q->direct_qlen) {
-	    __skb_queue_tail(&q->direct_queue, skb);
-	    q->direct_pkts++;
-	} else {
-	    kfree_skb(skb);
-	    sch->qstats.drops++;
-	    return NET_XMIT_DROP;
-	}
+	int ret;
+	struct htb_sched *q = qdisc_priv(sch);
+	struct htb_class *cl = htb_classify(skb, sch, &ret);
+
+	if (cl == HTB_DIRECT) {
+		/* enqueue to helper queue */
+		if (q->direct_queue.qlen < q->direct_qlen) {
+			__skb_queue_tail(&q->direct_queue, skb);
+			q->direct_pkts++;
+		} else {
+			kfree_skb(skb);
+			sch->qstats.drops++;
+			return NET_XMIT_DROP;
+		}
 #ifdef CONFIG_NET_CLS_ACT
-    } else if (!cl) {
-	if (ret == NET_XMIT_BYPASS)
-		sch->qstats.drops++;
-	kfree_skb (skb);
-	return ret;
+	} else if (!cl) {
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
 #endif
-    } else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
-	sch->qstats.drops++;
-	cl->qstats.drops++;
-	return NET_XMIT_DROP;
-    } else {
-	cl->bstats.packets++; cl->bstats.bytes += skb->len;
-	htb_activate (q,cl);
-    }
-
-    sch->q.qlen++;
-    sch->bstats.packets++; sch->bstats.bytes += skb->len;
-    return NET_XMIT_SUCCESS;
+	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
+		   NET_XMIT_SUCCESS) {
+		sch->qstats.drops++;
+		cl->qstats.drops++;
+		return NET_XMIT_DROP;
+	} else {
+		cl->bstats.packets++;
+		cl->bstats.bytes += skb->len;
+		htb_activate(q, cl);
+	}
+
+	sch->q.qlen++;
+	sch->bstats.packets++;
+	sch->bstats.bytes += skb->len;
+	return NET_XMIT_SUCCESS;
 }
 
 /* TODO: requeuing packet charges it to policers again !! */
 static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-    struct htb_sched *q = qdisc_priv(sch);
-    int ret =  NET_XMIT_SUCCESS;
-    struct htb_class *cl = htb_classify(skb,sch, &ret);
-    struct sk_buff *tskb;
-
-    if (cl == HTB_DIRECT || !cl) {
-	/* enqueue to helper queue */
-	if (q->direct_queue.qlen < q->direct_qlen && cl) {
-	    __skb_queue_head(&q->direct_queue, skb);
-	} else {
-            __skb_queue_head(&q->direct_queue, skb);
-            tskb = __skb_dequeue_tail(&q->direct_queue);
-            kfree_skb (tskb);
-            sch->qstats.drops++;
-            return NET_XMIT_CN;	
-	}
-    } else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
-	sch->qstats.drops++;
-	cl->qstats.drops++;
-	return NET_XMIT_DROP;
-    } else 
-	    htb_activate (q,cl);
-
-    sch->q.qlen++;
-    sch->qstats.requeues++;
-    return NET_XMIT_SUCCESS;
+	struct htb_sched *q = qdisc_priv(sch);
+	int ret = NET_XMIT_SUCCESS;
+	struct htb_class *cl = htb_classify(skb, sch, &ret);
+	struct sk_buff *tskb;
+
+	if (cl == HTB_DIRECT || !cl) {
+		/* enqueue to helper queue */
+		if (q->direct_queue.qlen < q->direct_qlen && cl) {
+			__skb_queue_head(&q->direct_queue, skb);
+		} else {
+			__skb_queue_head(&q->direct_queue, skb);
+			tskb = __skb_dequeue_tail(&q->direct_queue);
+			kfree_skb(tskb);
+			sch->qstats.drops++;
+			return NET_XMIT_CN;
+		}
+	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
+		   NET_XMIT_SUCCESS) {
+		sch->qstats.drops++;
+		cl->qstats.drops++;
+		return NET_XMIT_DROP;
+	} else
+		htb_activate(q, cl);
+
+	sch->q.qlen++;
+	sch->qstats.requeues++;
+	return NET_XMIT_SUCCESS;
 }
 
 static void htb_timer(unsigned long arg)
 {
-    struct Qdisc *sch = (struct Qdisc*)arg;
-    sch->flags &= ~TCQ_F_THROTTLED;
-    wmb();
-    netif_schedule(sch->dev);
+	struct Qdisc *sch = (struct Qdisc *)arg;
+	sch->flags &= ~TCQ_F_THROTTLED;
+	wmb();
+	netif_schedule(sch->dev);
 }
 
 #ifdef HTB_RATECM
 #define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
 static void htb_rate_timer(unsigned long arg)
 {
-	struct Qdisc *sch = (struct Qdisc*)arg;
+	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct htb_sched *q = qdisc_priv(sch);
 	struct list_head *p;
 
@@ -678,13 +684,13 @@ static void htb_rate_timer(unsigned long
 	add_timer(&q->rttim);
 
 	/* scan and recompute one bucket at time */
-	if (++q->recmp_bucket >= HTB_HSIZE) 
+	if (++q->recmp_bucket >= HTB_HSIZE)
 		q->recmp_bucket = 0;
-	list_for_each (p,q->hash+q->recmp_bucket) {
-		struct htb_class *cl = list_entry(p,struct htb_class,hlist);
+	list_for_each(p, q->hash + q->recmp_bucket) {
+		struct htb_class *cl = list_entry(p, struct htb_class, hlist);
 
-		RT_GEN (cl->sum_bytes,cl->rate_bytes);
-		RT_GEN (cl->sum_packets,cl->rate_packets);
+		RT_GEN(cl->sum_bytes, cl->rate_bytes);
+		RT_GEN(cl->sum_packets, cl->rate_packets);
 	}
 	spin_unlock_bh(&sch->dev->queue_lock);
 }
@@ -701,10 +707,10 @@ #endif
  * CAN_SEND) because we can use more precise clock that event queue here.
  * In such case we remove class from event queue first.
  */
-static void htb_charge_class(struct htb_sched *q,struct htb_class *cl,
-		int level,int bytes)
-{	
-	long toks,diff;
+static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
+			     int level, int bytes)
+{
+	long toks, diff;
 	enum htb_cmode old_mode;
 
 #define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
@@ -714,29 +720,31 @@ #define HTB_ACCNT(T,B,R) toks = diff + c
 	cl->T = toks
 
 	while (cl) {
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
 		if (cl->level >= level) {
-			if (cl->level == level) cl->xstats.lends++;
-			HTB_ACCNT (tokens,buffer,rate);
+			if (cl->level == level)
+				cl->xstats.lends++;
+			HTB_ACCNT(tokens, buffer, rate);
 		} else {
 			cl->xstats.borrows++;
-			cl->tokens += diff; /* we moved t_c; update tokens */
+			cl->tokens += diff;	/* we moved t_c; update tokens */
 		}
-		HTB_ACCNT (ctokens,cbuffer,ceil);
+		HTB_ACCNT(ctokens, cbuffer, ceil);
 		cl->t_c = q->now;
 
-		old_mode = cl->cmode; diff = 0;
-		htb_change_class_mode(q,cl,&diff);
+		old_mode = cl->cmode;
+		diff = 0;
+		htb_change_class_mode(q, cl, &diff);
 		if (old_mode != cl->cmode) {
 			if (old_mode != HTB_CAN_SEND)
-				rb_erase(&cl->pq_node,q->wait_pq+cl->level);
+				rb_erase(&cl->pq_node, q->wait_pq + cl->level);
 			if (cl->cmode != HTB_CAN_SEND)
-				htb_add_to_wait_tree (q,cl,diff);
+				htb_add_to_wait_tree(q, cl, diff);
 		}
-		
 #ifdef HTB_RATECM
 		/* update rate counters */
-		cl->sum_bytes += bytes; cl->sum_packets++;
+		cl->sum_bytes += bytes;
+		cl->sum_packets++;
 #endif
 
 		/* update byte stats except for leaves which are already updated */
@@ -755,7 +763,7 @@ #endif
  * next pending event (0 for no event in pq).
  * Note: Aplied are events whose have cl->pq_key <= jiffies.
  */
-static long htb_do_events(struct htb_sched *q,int level)
+static long htb_do_events(struct htb_sched *q, int level)
 {
 	int i;
 
@@ -763,34 +771,38 @@ static long htb_do_events(struct htb_sch
 		struct htb_class *cl;
 		long diff;
 		struct rb_node *p = q->wait_pq[level].rb_node;
-		if (!p) return 0;
-		while (p->rb_left) p = p->rb_left;
+		if (!p)
+			return 0;
+		while (p->rb_left)
+			p = p->rb_left;
 
 		cl = rb_entry(p, struct htb_class, pq_node);
 		if (time_after(cl->pq_key, q->jiffies)) {
 			return cl->pq_key - q->jiffies;
 		}
-		rb_erase(p,q->wait_pq+level);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
-		htb_change_class_mode(q,cl,&diff);
+		rb_erase(p, q->wait_pq + level);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
+		htb_change_class_mode(q, cl, &diff);
 		if (cl->cmode != HTB_CAN_SEND)
-			htb_add_to_wait_tree (q,cl,diff);
+			htb_add_to_wait_tree(q, cl, diff);
 	}
 	if (net_ratelimit())
 		printk(KERN_WARNING "htb: too many events !\n");
-	return HZ/10;
+	return HZ / 10;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
    is no such one exists. */
-static struct rb_node *
-htb_id_find_next_upper(int prio,struct rb_node *n,u32 id)
+static struct rb_node *htb_id_find_next_upper(int prio, struct rb_node *n,
+					      u32 id)
 {
 	struct rb_node *r = NULL;
 	while (n) {
-		struct htb_class *cl = rb_entry(n,struct htb_class,node[prio]);
-		if (id == cl->classid) return n;
-		
+		struct htb_class *cl =
+		    rb_entry(n, struct htb_class, node[prio]);
+		if (id == cl->classid)
+			return n;
+
 		if (id > cl->classid) {
 			n = n->rb_right;
 		} else {
@@ -806,46 +818,49 @@ htb_id_find_next_upper(int prio,struct r
  *
  * Find leaf where current feed pointers points to.
  */
-static struct htb_class *
-htb_lookup_leaf(struct rb_root *tree,int prio,struct rb_node **pptr,u32 *pid)
+static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
+					 struct rb_node **pptr, u32 * pid)
 {
 	int i;
 	struct {
 		struct rb_node *root;
 		struct rb_node **pptr;
 		u32 *pid;
-	} stk[TC_HTB_MAXDEPTH],*sp = stk;
-	
+	} stk[TC_HTB_MAXDEPTH], *sp = stk;
+
 	BUG_TRAP(tree->rb_node);
 	sp->root = tree->rb_node;
 	sp->pptr = pptr;
 	sp->pid = pid;
 
 	for (i = 0; i < 65535; i++) {
-		if (!*sp->pptr && *sp->pid) { 
+		if (!*sp->pptr && *sp->pid) {
 			/* ptr was invalidated but id is valid - try to recover 
 			   the original or next ptr */
-			*sp->pptr = htb_id_find_next_upper(prio,sp->root,*sp->pid);
+			*sp->pptr =
+			    htb_id_find_next_upper(prio, sp->root, *sp->pid);
 		}
-		*sp->pid = 0; /* ptr is valid now so that remove this hint as it
-			         can become out of date quickly */
-		if (!*sp->pptr) { /* we are at right end; rewind & go up */
+		*sp->pid = 0;	/* ptr is valid now so that remove this hint as it
+				   can become out of date quickly */
+		if (!*sp->pptr) {	/* we are at right end; rewind & go up */
 			*sp->pptr = sp->root;
-			while ((*sp->pptr)->rb_left) 
+			while ((*sp->pptr)->rb_left)
 				*sp->pptr = (*sp->pptr)->rb_left;
 			if (sp > stk) {
 				sp--;
-				BUG_TRAP(*sp->pptr); if(!*sp->pptr) return NULL;
-				htb_next_rb_node (sp->pptr);
+				BUG_TRAP(*sp->pptr);
+				if (!*sp->pptr)
+					return NULL;
+				htb_next_rb_node(sp->pptr);
 			}
 		} else {
 			struct htb_class *cl;
-			cl = rb_entry(*sp->pptr,struct htb_class,node[prio]);
-			if (!cl->level) 
+			cl = rb_entry(*sp->pptr, struct htb_class, node[prio]);
+			if (!cl->level)
 				return cl;
 			(++sp)->root = cl->un.inner.feed[prio].rb_node;
-			sp->pptr = cl->un.inner.ptr+prio;
-			sp->pid = cl->un.inner.last_ptr_id+prio;
+			sp->pptr = cl->un.inner.ptr + prio;
+			sp->pid = cl->un.inner.last_ptr_id + prio;
 		}
 	}
 	BUG_TRAP(0);
@@ -854,19 +869,21 @@ htb_lookup_leaf(struct rb_root *tree,int
 
 /* dequeues packet at given priority and level; call only if
    you are sure that there is active class at prio/level */
-static struct sk_buff *
-htb_dequeue_tree(struct htb_sched *q,int prio,int level)
+static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
+					int level)
 {
 	struct sk_buff *skb = NULL;
-	struct htb_class *cl,*start;
+	struct htb_class *cl, *start;
 	/* look initial class up in the row */
-	start = cl = htb_lookup_leaf (q->row[level]+prio,prio,
-			q->ptr[level]+prio,q->last_ptr_id[level]+prio);
-	
+	start = cl = htb_lookup_leaf(q->row[level] + prio, prio,
+				     q->ptr[level] + prio,
+				     q->last_ptr_id[level] + prio);
+
 	do {
 next:
-		BUG_TRAP(cl); 
-		if (!cl) return NULL;
+		BUG_TRAP(cl);
+		if (!cl)
+			return NULL;
 
 		/* class can be empty - it is unlikely but can be true if leaf
 		   qdisc drops packets in enqueue routine or if someone used
@@ -874,56 +891,64 @@ next:
 		   simply deactivate and skip such class */
 		if (unlikely(cl->un.leaf.q->q.qlen == 0)) {
 			struct htb_class *next;
-			htb_deactivate(q,cl);
+			htb_deactivate(q, cl);
 
 			/* row/level might become empty */
 			if ((q->row_mask[level] & (1 << prio)) == 0)
-				return NULL; 
-			
-			next = htb_lookup_leaf (q->row[level]+prio,
-					prio,q->ptr[level]+prio,q->last_ptr_id[level]+prio);
+				return NULL;
 
-			if (cl == start) /* fix start if we just deleted it */
+			next = htb_lookup_leaf(q->row[level] + prio,
+					       prio, q->ptr[level] + prio,
+					       q->last_ptr_id[level] + prio);
+
+			if (cl == start)	/* fix start if we just deleted it */
 				start = next;
 			cl = next;
 			goto next;
 		}
-	
-		if (likely((skb = cl->un.leaf.q->dequeue(cl->un.leaf.q)) != NULL)) 
+
+		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		if (likely(skb != NULL))
 			break;
 		if (!cl->warned) {
-			printk(KERN_WARNING "htb: class %X isn't work conserving ?!\n",cl->classid);
+			printk(KERN_WARNING
+			       "htb: class %X isn't work conserving ?!\n",
+			       cl->classid);
 			cl->warned = 1;
 		}
 		q->nwc_hit++;
-		htb_next_rb_node((level?cl->parent->un.inner.ptr:q->ptr[0])+prio);
-		cl = htb_lookup_leaf (q->row[level]+prio,prio,q->ptr[level]+prio,
-				q->last_ptr_id[level]+prio);
+		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
+				  ptr[0]) + prio);
+		cl = htb_lookup_leaf(q->row[level] + prio, prio,
+				     q->ptr[level] + prio,
+				     q->last_ptr_id[level] + prio);
 
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
 		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
-			htb_next_rb_node((level?cl->parent->un.inner.ptr:q->ptr[0])+prio);
+			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
+					  ptr[0]) + prio);
 		}
 		/* this used to be after charge_class but this constelation
 		   gives us slightly better performance */
 		if (!cl->un.leaf.q->q.qlen)
-			htb_deactivate (q,cl);
-		htb_charge_class (q,cl,level,skb->len);
+			htb_deactivate(q, cl);
+		htb_charge_class(q, cl, level, skb->len);
 	}
 	return skb;
 }
 
-static void htb_delay_by(struct Qdisc *sch,long delay)
+static void htb_delay_by(struct Qdisc *sch, long delay)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	if (delay <= 0) delay = 1;
-	if (unlikely(delay > 5*HZ)) {
+	if (delay <= 0)
+		delay = 1;
+	if (unlikely(delay > 5 * HZ)) {
 		if (net_ratelimit())
 			printk(KERN_INFO "HTB delay %ld > 5sec\n", delay);
-		delay = 5*HZ;
+		delay = 5 * HZ;
 	}
 	/* why don't use jiffies here ? because expires can be in past */
 	mod_timer(&q->timer, q->jiffies + delay);
@@ -941,13 +966,15 @@ static struct sk_buff *htb_dequeue(struc
 	q->jiffies = jiffies;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
-	if ((skb = __skb_dequeue(&q->direct_queue)) != NULL) {
+	skb = __skb_dequeue(&q->direct_queue);
+	if (skb != NULL) {
 		sch->flags &= ~TCQ_F_THROTTLED;
 		sch->q.qlen--;
 		return skb;
 	}
 
-	if (!sch->q.qlen) goto fin;
+	if (!sch->q.qlen)
+		goto fin;
 	PSCHED_GET_TIME(q->now);
 
 	min_delay = LONG_MAX;
@@ -957,18 +984,19 @@ static struct sk_buff *htb_dequeue(struc
 		int m;
 		long delay;
 		if (time_after_eq(q->jiffies, q->near_ev_cache[level])) {
-			delay = htb_do_events(q,level);
-			q->near_ev_cache[level] = q->jiffies + (delay ? delay : HZ);
+			delay = htb_do_events(q, level);
+			q->near_ev_cache[level] =
+			    q->jiffies + (delay ? delay : HZ);
 		} else
-			delay = q->near_ev_cache[level] - q->jiffies;	
-		
-		if (delay && min_delay > delay) 
+			delay = q->near_ev_cache[level] - q->jiffies;
+
+		if (delay && min_delay > delay)
 			min_delay = delay;
 		m = ~q->row_mask[level];
 		while (m != (int)(-1)) {
-			int prio = ffz (m);
+			int prio = ffz(m);
 			m |= 1 << prio;
-			skb = htb_dequeue_tree(q,prio,level);
+			skb = htb_dequeue_tree(q, prio, level);
 			if (likely(skb != NULL)) {
 				sch->q.qlen--;
 				sch->flags &= ~TCQ_F_THROTTLED;
@@ -976,28 +1004,28 @@ static struct sk_buff *htb_dequeue(struc
 			}
 		}
 	}
-	htb_delay_by (sch,min_delay > 5*HZ ? 5*HZ : min_delay);
+	htb_delay_by(sch, min_delay > 5 * HZ ? 5 * HZ : min_delay);
 fin:
 	return skb;
 }
 
 /* try to drop from each class (by prio) until one succeed */
-static unsigned int htb_drop(struct Qdisc* sch)
+static unsigned int htb_drop(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	int prio;
 
 	for (prio = TC_HTB_NUMPRIO - 1; prio >= 0; prio--) {
 		struct list_head *p;
-		list_for_each (p,q->drops+prio) {
+		list_for_each(p, q->drops + prio) {
 			struct htb_class *cl = list_entry(p, struct htb_class,
 							  un.leaf.drop_list);
 			unsigned int len;
-			if (cl->un.leaf.q->ops->drop && 
-				(len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+			if (cl->un.leaf.q->ops->drop &&
+			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
 				sch->q.qlen--;
 				if (!cl->un.leaf.q->q.qlen)
-					htb_deactivate (q,cl);
+					htb_deactivate(q, cl);
 				return len;
 			}
 		}
@@ -1007,19 +1035,20 @@ static unsigned int htb_drop(struct Qdis
 
 /* reset all classes */
 /* always caled under BH & queue lock */
-static void htb_reset(struct Qdisc* sch)
+static void htb_reset(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	int i;
 
 	for (i = 0; i < HTB_HSIZE; i++) {
 		struct list_head *p;
-		list_for_each (p,q->hash+i) {
-			struct htb_class *cl = list_entry(p,struct htb_class,hlist);
+		list_for_each(p, q->hash + i) {
+			struct htb_class *cl =
+			    list_entry(p, struct htb_class, hlist);
 			if (cl->level)
-				memset(&cl->un.inner,0,sizeof(cl->un.inner));
+				memset(&cl->un.inner, 0, sizeof(cl->un.inner));
 			else {
-				if (cl->un.leaf.q) 
+				if (cl->un.leaf.q)
 					qdisc_reset(cl->un.leaf.q);
 				INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 			}
@@ -1032,12 +1061,12 @@ static void htb_reset(struct Qdisc* sch)
 	del_timer(&q->timer);
 	__skb_queue_purge(&q->direct_queue);
 	sch->q.qlen = 0;
-	memset(q->row,0,sizeof(q->row));
-	memset(q->row_mask,0,sizeof(q->row_mask));
-	memset(q->wait_pq,0,sizeof(q->wait_pq));
-	memset(q->ptr,0,sizeof(q->ptr));
+	memset(q->row, 0, sizeof(q->row));
+	memset(q->row_mask, 0, sizeof(q->row_mask));
+	memset(q->wait_pq, 0, sizeof(q->wait_pq));
+	memset(q->ptr, 0, sizeof(q->ptr));
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
-		INIT_LIST_HEAD(q->drops+i);
+		INIT_LIST_HEAD(q->drops + i);
 }
 
 static int htb_init(struct Qdisc *sch, struct rtattr *opt)
@@ -1047,29 +1076,30 @@ static int htb_init(struct Qdisc *sch, s
 	struct tc_htb_glob *gopt;
 	int i;
 	if (!opt || rtattr_parse_nested(tb, TCA_HTB_INIT, opt) ||
-			tb[TCA_HTB_INIT-1] == NULL ||
-			RTA_PAYLOAD(tb[TCA_HTB_INIT-1]) < sizeof(*gopt)) {
+	    tb[TCA_HTB_INIT - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_HTB_INIT - 1]) < sizeof(*gopt)) {
 		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
 		return -EINVAL;
 	}
-	gopt = RTA_DATA(tb[TCA_HTB_INIT-1]);
+	gopt = RTA_DATA(tb[TCA_HTB_INIT - 1]);
 	if (gopt->version != HTB_VER >> 16) {
-		printk(KERN_ERR "HTB: need tc/htb version %d (minor is %d), you have %d\n",
-				HTB_VER >> 16,HTB_VER & 0xffff,gopt->version);
+		printk(KERN_ERR
+		       "HTB: need tc/htb version %d (minor is %d), you have %d\n",
+		       HTB_VER >> 16, HTB_VER & 0xffff, gopt->version);
 		return -EINVAL;
 	}
 
 	INIT_LIST_HEAD(&q->root);
 	for (i = 0; i < HTB_HSIZE; i++)
-		INIT_LIST_HEAD(q->hash+i);
+		INIT_LIST_HEAD(q->hash + i);
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
-		INIT_LIST_HEAD(q->drops+i);
+		INIT_LIST_HEAD(q->drops + i);
 
 	init_timer(&q->timer);
 	skb_queue_head_init(&q->direct_queue);
 
 	q->direct_qlen = sch->dev->tx_queue_len;
-	if (q->direct_qlen < 2) /* some devices have zero tx_queue_len */
+	if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
 		q->direct_qlen = 2;
 	q->timer.function = htb_timer;
 	q->timer.data = (unsigned long)sch;
@@ -1091,7 +1121,7 @@ #endif
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	unsigned char	 *b = skb->tail;
+	unsigned char *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_glob gopt;
 	spin_lock_bh(&sch->dev->queue_lock);
@@ -1101,7 +1131,7 @@ static int htb_dump(struct Qdisc *sch, s
 	gopt.rate2quantum = q->rate2quantum;
 	gopt.defcls = q->defcls;
 	gopt.debug = 0;
-	rta = (struct rtattr*)b;
+	rta = (struct rtattr *)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	rta->rta_len = skb->tail - b;
@@ -1114,10 +1144,10 @@ rtattr_failure:
 }
 
 static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
-	struct sk_buff *skb, struct tcmsg *tcm)
+			  struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct htb_class *cl = (struct htb_class*)arg;
-	unsigned char	 *b = skb->tail;
+	struct htb_class *cl = (struct htb_class *)arg;
+	unsigned char *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_opt opt;
 
@@ -1127,15 +1157,18 @@ static int htb_dump_class(struct Qdisc *
 	if (!cl->level && cl->un.leaf.q)
 		tcm->tcm_info = cl->un.leaf.q->handle;
 
-	rta = (struct rtattr*)b;
+	rta = (struct rtattr *)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
-	memset (&opt,0,sizeof(opt));
+	memset(&opt, 0, sizeof(opt));
 
-	opt.rate = cl->rate->rate; opt.buffer = cl->buffer;
-	opt.ceil = cl->ceil->rate; opt.cbuffer = cl->cbuffer;
-	opt.quantum = cl->un.leaf.quantum; opt.prio = cl->un.leaf.prio;
-	opt.level = cl->level; 
+	opt.rate = cl->rate->rate;
+	opt.buffer = cl->buffer;
+	opt.ceil = cl->ceil->rate;
+	opt.cbuffer = cl->cbuffer;
+	opt.quantum = cl->un.leaf.quantum;
+	opt.prio = cl->un.leaf.prio;
+	opt.level = cl->level;
 	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 	rta->rta_len = skb->tail - b;
 	spin_unlock_bh(&sch->dev->queue_lock);
@@ -1147,14 +1180,13 @@ rtattr_failure:
 }
 
 static int
-htb_dump_class_stats(struct Qdisc *sch, unsigned long arg,
-	struct gnet_dump *d)
+htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 {
-	struct htb_class *cl = (struct htb_class*)arg;
+	struct htb_class *cl = (struct htb_class *)arg;
 
 #ifdef HTB_RATECM
-	cl->rate_est.bps = cl->rate_bytes/(HTB_EWMAC*HTB_HSIZE);
-	cl->rate_est.pps = cl->rate_packets/(HTB_EWMAC*HTB_HSIZE);
+	cl->rate_est.bps = cl->rate_bytes / (HTB_EWMAC * HTB_HSIZE);
+	cl->rate_est.pps = cl->rate_packets / (HTB_EWMAC * HTB_HSIZE);
 #endif
 
 	if (!cl->level && cl->un.leaf.q)
@@ -1171,21 +1203,22 @@ #endif
 }
 
 static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-	struct Qdisc **old)
+		     struct Qdisc **old)
 {
-	struct htb_class *cl = (struct htb_class*)arg;
+	struct htb_class *cl = (struct htb_class *)arg;
 
 	if (cl && !cl->level) {
-		if (new == NULL && (new = qdisc_create_dflt(sch->dev, 
-					&pfifo_qdisc_ops)) == NULL)
-					return -ENOBUFS;
+		if (new == NULL && (new = qdisc_create_dflt(sch->dev,
+							    &pfifo_qdisc_ops))
+		    == NULL)
+			return -ENOBUFS;
 		sch_tree_lock(sch);
 		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
 			if (cl->prio_activity)
-				htb_deactivate (qdisc_priv(sch),cl);
+				htb_deactivate(qdisc_priv(sch), cl);
 
 			/* TODO: is it correct ? Why CBQ doesn't do it ? */
-			sch->q.qlen -= (*old)->q.qlen;	
+			sch->q.qlen -= (*old)->q.qlen;
 			qdisc_reset(*old);
 		}
 		sch_tree_unlock(sch);
@@ -1194,16 +1227,16 @@ static int htb_graft(struct Qdisc *sch, 
 	return -ENOENT;
 }
 
-static struct Qdisc * htb_leaf(struct Qdisc *sch, unsigned long arg)
+static struct Qdisc *htb_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_class *cl = (struct htb_class*)arg;
+	struct htb_class *cl = (struct htb_class *)arg;
 	return (cl && !cl->level) ? cl->un.leaf.q : NULL;
 }
 
 static unsigned long htb_get(struct Qdisc *sch, u32 classid)
 {
-	struct htb_class *cl = htb_find(classid,sch);
-	if (cl) 
+	struct htb_class *cl = htb_find(classid, sch);
+	if (cl)
 		cl->refcnt++;
 	return (unsigned long)cl;
 }
@@ -1218,7 +1251,7 @@ static void htb_destroy_filters(struct t
 	}
 }
 
-static void htb_destroy_class(struct Qdisc* sch,struct htb_class *cl)
+static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	if (!cl->level) {
@@ -1228,44 +1261,44 @@ static void htb_destroy_class(struct Qdi
 	}
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
-	
-	htb_destroy_filters (&cl->filter_list);
-	
-	while (!list_empty(&cl->children)) 
-		htb_destroy_class (sch,list_entry(cl->children.next,
-					struct htb_class,sibling));
+
+	htb_destroy_filters(&cl->filter_list);
+
+	while (!list_empty(&cl->children))
+		htb_destroy_class(sch, list_entry(cl->children.next,
+						  struct htb_class, sibling));
 
 	/* note: this delete may happen twice (see htb_delete) */
 	list_del(&cl->hlist);
 	list_del(&cl->sibling);
-	
+
 	if (cl->prio_activity)
-		htb_deactivate (q,cl);
-	
+		htb_deactivate(q, cl);
+
 	if (cl->cmode != HTB_CAN_SEND)
-		rb_erase(&cl->pq_node,q->wait_pq+cl->level);
-	
+		rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+
 	kfree(cl);
 }
 
 /* always caled under BH & queue lock */
-static void htb_destroy(struct Qdisc* sch)
+static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 
-	del_timer_sync (&q->timer);
+	del_timer_sync(&q->timer);
 #ifdef HTB_RATECM
-	del_timer_sync (&q->rttim);
+	del_timer_sync(&q->rttim);
 #endif
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it 
 	   because filter need its target class alive to be able to call
 	   unbind_filter on it (without Oops). */
 	htb_destroy_filters(&q->filter_list);
-	
-	while (!list_empty(&q->root)) 
-		htb_destroy_class (sch,list_entry(q->root.next,
-					struct htb_class,sibling));
+
+	while (!list_empty(&q->root))
+		htb_destroy_class(sch, list_entry(q->root.next,
+						  struct htb_class, sibling));
 
 	__skb_queue_purge(&q->direct_queue);
 }
@@ -1273,23 +1306,23 @@ #endif
 static int htb_delete(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = (struct htb_class*)arg;
+	struct htb_class *cl = (struct htb_class *)arg;
 
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
 	// refs so that we can remove children safely there ?
 	if (!list_empty(&cl->children) || cl->filter_cnt)
 		return -EBUSY;
-	
+
 	sch_tree_lock(sch);
-	
+
 	/* delete from hash and active; remainder in destroy_class */
 	list_del_init(&cl->hlist);
 	if (cl->prio_activity)
-		htb_deactivate (q,cl);
+		htb_deactivate(q, cl);
 
 	if (--cl->refcnt == 0)
-		htb_destroy_class(sch,cl);
+		htb_destroy_class(sch, cl);
 
 	sch_tree_unlock(sch);
 	return 0;
@@ -1297,41 +1330,44 @@ static int htb_delete(struct Qdisc *sch,
 
 static void htb_put(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_class *cl = (struct htb_class*)arg;
+	struct htb_class *cl = (struct htb_class *)arg;
 
 	if (--cl->refcnt == 0)
-		htb_destroy_class(sch,cl);
+		htb_destroy_class(sch, cl);
 }
 
-static int htb_change_class(struct Qdisc *sch, u32 classid, 
-		u32 parentid, struct rtattr **tca, unsigned long *arg)
+static int htb_change_class(struct Qdisc *sch, u32 classid,
+			    u32 parentid, struct rtattr **tca,
+			    unsigned long *arg)
 {
 	int err = -EINVAL;
 	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = (struct htb_class*)*arg,*parent;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
+	struct htb_class *cl = (struct htb_class *)*arg, *parent;
+	struct rtattr *opt = tca[TCA_OPTIONS - 1];
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
 	struct rtattr *tb[TCA_HTB_RTAB];
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
 	if (!opt || rtattr_parse_nested(tb, TCA_HTB_RTAB, opt) ||
-			tb[TCA_HTB_PARMS-1] == NULL ||
-			RTA_PAYLOAD(tb[TCA_HTB_PARMS-1]) < sizeof(*hopt))
+	    tb[TCA_HTB_PARMS - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_HTB_PARMS - 1]) < sizeof(*hopt))
 		goto failure;
-	
-	parent = parentid == TC_H_ROOT ? NULL : htb_find (parentid,sch);
 
-	hopt = RTA_DATA(tb[TCA_HTB_PARMS-1]);
+	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
+
+	hopt = RTA_DATA(tb[TCA_HTB_PARMS - 1]);
 
-	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB-1]);
-	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB-1]);
-	if (!rtab || !ctab) goto failure;
+	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB - 1]);
+	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB - 1]);
+	if (!rtab || !ctab)
+		goto failure;
 
-	if (!cl) { /* new class */
+	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
 		/* check for valid classid */
-		if (!classid || TC_H_MAJ(classid^sch->handle) || htb_find(classid,sch))
+		if (!classid || TC_H_MAJ(classid ^ sch->handle)
+		    || htb_find(classid, sch))
 			goto failure;
 
 		/* check maximal depth */
@@ -1342,7 +1378,7 @@ static int htb_change_class(struct Qdisc
 		err = -ENOBUFS;
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
-		
+
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_LIST_HEAD(&cl->hlist);
@@ -1357,46 +1393,53 @@ static int htb_change_class(struct Qdisc
 		if (parent && !parent->level) {
 			/* turn parent into inner node */
 			sch->q.qlen -= parent->un.leaf.q->q.qlen;
-			qdisc_destroy (parent->un.leaf.q);
-			if (parent->prio_activity) 
-				htb_deactivate (q,parent);
+			qdisc_destroy(parent->un.leaf.q);
+			if (parent->prio_activity)
+				htb_deactivate(q, parent);
 
 			/* remove from evt list because of level change */
 			if (parent->cmode != HTB_CAN_SEND) {
-				rb_erase(&parent->pq_node,q->wait_pq);
+				rb_erase(&parent->pq_node, q->wait_pq);
 				parent->cmode = HTB_CAN_SEND;
 			}
 			parent->level = (parent->parent ? parent->parent->level
-					: TC_HTB_MAXDEPTH) - 1;
-			memset (&parent->un.inner,0,sizeof(parent->un.inner));
+					 : TC_HTB_MAXDEPTH) - 1;
+			memset(&parent->un.inner, 0, sizeof(parent->un.inner));
 		}
 		/* leaf (we) needs elementary qdisc */
 		cl->un.leaf.q = new_q ? new_q : &noop_qdisc;
 
-		cl->classid = classid; cl->parent = parent;
+		cl->classid = classid;
+		cl->parent = parent;
 
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60); /* 1min */
+		cl->mbuffer = PSCHED_JIFFIE2US(HZ * 60);	/* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
-		list_add_tail(&cl->hlist, q->hash+htb_hash(classid));
-		list_add_tail(&cl->sibling, parent ? &parent->children : &q->root);
-	} else sch_tree_lock(sch);
+		list_add_tail(&cl->hlist, q->hash + htb_hash(classid));
+		list_add_tail(&cl->sibling,
+			      parent ? &parent->children : &q->root);
+	} else
+		sch_tree_lock(sch);
 
 	/* it used to be a nasty bug here, we have to check that node
-           is really leaf before changing cl->un.leaf ! */
+	   is really leaf before changing cl->un.leaf ! */
 	if (!cl->level) {
 		cl->un.leaf.quantum = rtab->rate.rate / q->rate2quantum;
 		if (!hopt->quantum && cl->un.leaf.quantum < 1000) {
-			printk(KERN_WARNING "HTB: quantum of class %X is small. Consider r2q change.\n", cl->classid);
+			printk(KERN_WARNING
+			       "HTB: quantum of class %X is small. Consider r2q change.\n",
+			       cl->classid);
 			cl->un.leaf.quantum = 1000;
 		}
 		if (!hopt->quantum && cl->un.leaf.quantum > 200000) {
-			printk(KERN_WARNING "HTB: quantum of class %X is big. Consider r2q change.\n", cl->classid);
+			printk(KERN_WARNING
+			       "HTB: quantum of class %X is big. Consider r2q change.\n",
+			       cl->classid);
 			cl->un.leaf.quantum = 200000;
 		}
 		if (hopt->quantum)
@@ -1407,16 +1450,22 @@ static int htb_change_class(struct Qdisc
 
 	cl->buffer = hopt->buffer;
 	cl->cbuffer = hopt->cbuffer;
-	if (cl->rate) qdisc_put_rtab(cl->rate); cl->rate = rtab;
-	if (cl->ceil) qdisc_put_rtab(cl->ceil); cl->ceil = ctab;
+	if (cl->rate)
+		qdisc_put_rtab(cl->rate);
+	cl->rate = rtab;
+	if (cl->ceil)
+		qdisc_put_rtab(cl->ceil);
+	cl->ceil = ctab;
 	sch_tree_unlock(sch);
 
 	*arg = (unsigned long)cl;
 	return 0;
 
 failure:
-	if (rtab) qdisc_put_rtab(rtab);
-	if (ctab) qdisc_put_rtab(ctab);
+	if (rtab)
+		qdisc_put_rtab(rtab);
+	if (ctab)
+		qdisc_put_rtab(ctab);
 	return err;
 }
 
@@ -1430,23 +1479,23 @@ static struct tcf_proto **htb_find_tcf(s
 }
 
 static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
-	u32 classid)
+				     u32 classid)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = htb_find (classid,sch);
+	struct htb_class *cl = htb_find(classid, sch);
 
 	/*if (cl && !cl->level) return 0;
-	  The line above used to be there to prevent attaching filters to 
-	  leaves. But at least tc_index filter uses this just to get class 
-	  for other reasons so that we have to allow for it.
-	  ----
-	  19.6.2002 As Werner explained it is ok - bind filter is just
-	  another way to "lock" the class - unlike "get" this lock can
-	  be broken by class during destroy IIUC.
+	   The line above used to be there to prevent attaching filters to 
+	   leaves. But at least tc_index filter uses this just to get class 
+	   for other reasons so that we have to allow for it.
+	   ----
+	   19.6.2002 As Werner explained it is ok - bind filter is just
+	   another way to "lock" the class - unlike "get" this lock can
+	   be broken by class during destroy IIUC.
 	 */
-	if (cl) 
-		cl->filter_cnt++; 
-	else 
+	if (cl)
+		cl->filter_cnt++;
+	else
 		q->filter_cnt++;
 	return (unsigned long)cl;
 }
@@ -1456,9 +1505,9 @@ static void htb_unbind_filter(struct Qdi
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 
-	if (cl) 
-		cl->filter_cnt--; 
-	else 
+	if (cl)
+		cl->filter_cnt--;
+	else
 		q->filter_cnt--;
 }
 
@@ -1472,8 +1521,9 @@ static void htb_walk(struct Qdisc *sch, 
 
 	for (i = 0; i < HTB_HSIZE; i++) {
 		struct list_head *p;
-		list_for_each (p,q->hash+i) {
-			struct htb_class *cl = list_entry(p,struct htb_class,hlist);
+		list_for_each(p, q->hash + i) {
+			struct htb_class *cl =
+			    list_entry(p, struct htb_class, hlist);
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
@@ -1521,12 +1571,13 @@ static struct Qdisc_ops htb_qdisc_ops = 
 
 static int __init htb_module_init(void)
 {
-    return register_qdisc(&htb_qdisc_ops);
+	return register_qdisc(&htb_qdisc_ops);
 }
-static void __exit htb_module_exit(void) 
+static void __exit htb_module_exit(void)
 {
-    unregister_qdisc(&htb_qdisc_ops);
+	unregister_qdisc(&htb_qdisc_ops);
 }
+
 module_init(htb_module_init)
 module_exit(htb_module_exit)
 MODULE_LICENSE("GPL");
-- 
1.4.0

