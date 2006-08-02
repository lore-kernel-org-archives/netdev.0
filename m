From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/6] htb: remove broken debug code
Date: Wed, 2 Aug 2006 15:11:50 -0700
Message-ID: <20060802151150.2c320102@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55757 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932273AbWHBWMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:43 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The HTB network scheduler had debug code that wouldn't compile
and confused and obfuscated the code, remove it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c |  302 ++++++---------------------------------------------
 1 files changed, 34 insertions(+), 268 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 880a339..73094e7 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -70,7 +70,6 @@ #include <linux/rbtree.h>
 
 #define HTB_HSIZE 16	/* classid hash size */
 #define HTB_EWMAC 2	/* rate average over HTB_EWMAC*HTB_HSIZE sec */
-#undef HTB_DEBUG	/* compile debugging support (activated by tc tool) */
 #define HTB_RATECM 1    /* whether to use rate computer */
 #define HTB_HYSTERESIS 1/* whether to use mode hysteresis for speedup */
 #define HTB_QLOCK(S) spin_lock_bh(&(S)->dev->queue_lock)
@@ -81,51 +80,6 @@ #if HTB_VER >> 16 != TC_HTB_PROTOVER
 #error "Mismatched sch_htb.c and pkt_sch.h"
 #endif
 
-/* debugging support; S is subsystem, these are defined:
-  0 - netlink messages
-  1 - enqueue
-  2 - drop & requeue
-  3 - dequeue main
-  4 - dequeue one prio DRR part
-  5 - dequeue class accounting
-  6 - class overlimit status computation
-  7 - hint tree
-  8 - event queue
- 10 - rate estimator
- 11 - classifier 
- 12 - fast dequeue cache
-
- L is level; 0 = none, 1 = basic info, 2 = detailed, 3 = full
- q->debug uint32 contains 16 2-bit fields one for subsystem starting
- from LSB
- */
-#ifdef HTB_DEBUG
-#define HTB_DBG_COND(S,L) (((q->debug>>(2*S))&3) >= L)
-#define HTB_DBG(S,L,FMT,ARG...) if (HTB_DBG_COND(S,L)) \
-	printk(KERN_DEBUG FMT,##ARG)
-#define HTB_CHCL(cl) BUG_TRAP((cl)->magic == HTB_CMAGIC)
-#define HTB_PASSQ q,
-#define HTB_ARGQ struct htb_sched *q,
-#define static
-#undef __inline__
-#define __inline__
-#undef inline
-#define inline
-#define HTB_CMAGIC 0xFEFAFEF1
-#define htb_safe_rb_erase(N,R) do { BUG_TRAP((N)->rb_color != -1); \
-		if ((N)->rb_color == -1) break; \
-		rb_erase(N,R); \
-		(N)->rb_color = -1; } while (0)
-#else
-#define HTB_DBG_COND(S,L) (0)
-#define HTB_DBG(S,L,FMT,ARG...)
-#define HTB_PASSQ
-#define HTB_ARGQ
-#define HTB_CHCL(cl)
-#define htb_safe_rb_erase(N,R) rb_erase(N,R)
-#endif
-
-
 /* used internaly to keep status of single class */
 enum htb_cmode {
     HTB_CANT_SEND,		/* class can't send and can't borrow */
@@ -136,9 +90,6 @@ enum htb_cmode {
 /* interior & leaf nodes; props specific to leaves are marked L: */
 struct htb_class
 {
-#ifdef HTB_DEBUG
-	unsigned magic;
-#endif
     /* general class parameters */
     u32 classid;
     struct gnet_stats_basic bstats;
@@ -238,7 +189,6 @@ struct htb_sched
     int nwc_hit;	/* this to disable mindelay complaint in dequeue */
 
     int defcls;		/* class where unclassified flows go to */
-    u32 debug;		/* subsystem debug levels */
 
     /* filters for qdisc itself */
     struct tcf_proto *filter_list;
@@ -354,75 +304,21 @@ #endif
 	return cl;
 }
 
-#ifdef HTB_DEBUG
-static void htb_next_rb_node(struct rb_node **n);
-#define HTB_DUMTREE(root,memb) if(root) { \
-	struct rb_node *n = (root)->rb_node; \
-	while (n->rb_left) n = n->rb_left; \
-	while (n) { \
-		struct htb_class *cl = rb_entry(n, struct htb_class, memb); \
-		printk(" %x",cl->classid); htb_next_rb_node (&n); \
-	} }
-
-static void htb_debug_dump (struct htb_sched *q)
-{
-	int i,p;
-	printk(KERN_DEBUG "htb*g j=%lu lj=%lu\n",jiffies,q->jiffies);
-	/* rows */
-	for (i=TC_HTB_MAXDEPTH-1;i>=0;i--) {
-		printk(KERN_DEBUG "htb*r%d m=%x",i,q->row_mask[i]);
-		for (p=0;p<TC_HTB_NUMPRIO;p++) {
-			if (!q->row[i][p].rb_node) continue;
-			printk(" p%d:",p);
-			HTB_DUMTREE(q->row[i]+p,node[p]);
-		}
-		printk("\n");
-	}
-	/* classes */
-	for (i = 0; i < HTB_HSIZE; i++) {
-		struct list_head *l;
-		list_for_each (l,q->hash+i) {
-			struct htb_class *cl = list_entry(l,struct htb_class,hlist);
-			long diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
-			printk(KERN_DEBUG "htb*c%x m=%d t=%ld c=%ld pq=%lu df=%ld ql=%d "
-					"pa=%x f:",
-				cl->classid,cl->cmode,cl->tokens,cl->ctokens,
-				cl->pq_node.rb_color==-1?0:cl->pq_key,diff,
-				cl->level?0:cl->un.leaf.q->q.qlen,cl->prio_activity);
-			if (cl->level)
-			for (p=0;p<TC_HTB_NUMPRIO;p++) {
-				if (!cl->un.inner.feed[p].rb_node) continue;
-				printk(" p%d a=%x:",p,cl->un.inner.ptr[p]?rb_entry(cl->un.inner.ptr[p], struct htb_class,node[p])->classid:0);
-				HTB_DUMTREE(cl->un.inner.feed+p,node[p]);
-			}
-			printk("\n");
-		}
-	}
-}
-#endif
 /**
  * htb_add_to_id_tree - adds class to the round robin list
  *
  * Routine adds class to the list (actually tree) sorted by classid.
  * Make sure that class is not already on such list for given prio.
  */
-static void htb_add_to_id_tree (HTB_ARGQ struct rb_root *root,
+static void htb_add_to_id_tree (struct rb_root *root,
 		struct htb_class *cl,int prio)
 {
 	struct rb_node **p = &root->rb_node, *parent = NULL;
-	HTB_DBG(7,3,"htb_add_id_tree cl=%X prio=%d\n",cl->classid,prio);
-#ifdef HTB_DEBUG
-	if (cl->node[prio].rb_color != -1) { BUG_TRAP(0); return; }
-	HTB_CHCL(cl);
-	if (*p) {
-		struct htb_class *x = rb_entry(*p,struct htb_class,node[prio]);
-		HTB_CHCL(x);
-	}
-#endif
+
 	while (*p) {
 		struct htb_class *c; parent = *p;
 		c = rb_entry(parent, struct htb_class, node[prio]);
-		HTB_CHCL(c);
+
 		if (cl->classid > c->classid)
 			p = &parent->rb_right;
 		else 
@@ -440,16 +336,10 @@ #endif
  * already in the queue.
  */
 static void htb_add_to_wait_tree (struct htb_sched *q,
-		struct htb_class *cl,long delay,int debug_hint)
+				  struct htb_class *cl,long delay)
 {
 	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;
-	HTB_DBG(7,3,"htb_add_wt cl=%X key=%lu\n",cl->classid,cl->pq_key);
-#ifdef HTB_DEBUG
-	if (cl->pq_node.rb_color != -1) { BUG_TRAP(0); return; }
-	HTB_CHCL(cl);
-	if ((delay <= 0 || delay > cl->mbuffer) && net_ratelimit())
-		printk(KERN_ERR "HTB: suspicious delay in wait_tree d=%ld cl=%X h=%d\n",delay,cl->classid,debug_hint);
-#endif
+
 	cl->pq_key = q->jiffies + PSCHED_US2JIFFIE(delay);
 	if (cl->pq_key == q->jiffies)
 		cl->pq_key++;
@@ -490,14 +380,11 @@ static void htb_next_rb_node(struct rb_n
 static inline void htb_add_class_to_row(struct htb_sched *q, 
 		struct htb_class *cl,int mask)
 {
-	HTB_DBG(7,2,"htb_addrow cl=%X mask=%X rmask=%X\n",
-			cl->classid,mask,q->row_mask[cl->level]);
-	HTB_CHCL(cl);
 	q->row_mask[cl->level] |= mask;
 	while (mask) {
 		int prio = ffz(~mask);
 		mask &= ~(1 << prio);
-		htb_add_to_id_tree(HTB_PASSQ q->row[cl->level]+prio,cl,prio);
+		htb_add_to_id_tree(q->row[cl->level]+prio,cl,prio);
 	}
 }
 
@@ -511,18 +398,16 @@ static __inline__ void htb_remove_class_
 		struct htb_class *cl,int mask)
 {
 	int m = 0;
-	HTB_CHCL(cl);
+
 	while (mask) {
 		int prio = ffz(~mask);
 		mask &= ~(1 << prio);
 		if (q->ptr[cl->level][prio] == cl->node+prio)
 			htb_next_rb_node(q->ptr[cl->level]+prio);
-		htb_safe_rb_erase(cl->node + prio,q->row[cl->level]+prio);
+		rb_erase(cl->node + prio,q->row[cl->level]+prio);
 		if (!q->row[cl->level][prio].rb_node) 
 			m |= 1 << prio;
 	}
-	HTB_DBG(7,2,"htb_delrow cl=%X mask=%X rmask=%X maskdel=%X\n",
-			cl->classid,mask,q->row_mask[cl->level],m);
 	q->row_mask[cl->level] &= ~m;
 }
 
@@ -537,11 +422,9 @@ static void htb_activate_prios(struct ht
 {
 	struct htb_class *p = cl->parent;
 	long m,mask = cl->prio_activity;
-	HTB_DBG(7,2,"htb_act_prios cl=%X mask=%lX cmode=%d\n",cl->classid,mask,cl->cmode);
-	HTB_CHCL(cl);
 
 	while (cl->cmode == HTB_MAY_BORROW && p && mask) {
-		HTB_CHCL(p);
+
 		m = mask; while (m) {
 			int prio = ffz(~m);
 			m &= ~(1 << prio);
@@ -551,13 +434,11 @@ static void htb_activate_prios(struct ht
 				   reset bit in mask as parent is already ok */
 				mask &= ~(1 << prio);
 			
-			htb_add_to_id_tree(HTB_PASSQ p->un.inner.feed+prio,cl,prio);
+			htb_add_to_id_tree(p->un.inner.feed+prio,cl,prio);
 		}
-		HTB_DBG(7,3,"htb_act_pr_aft p=%X pact=%X mask=%lX pmode=%d\n",
-				p->classid,p->prio_activity,mask,p->cmode);
 		p->prio_activity |= mask;
 		cl = p; p = cl->parent;
-		HTB_CHCL(cl);
+
 	}
 	if (cl->cmode == HTB_CAN_SEND && mask)
 		htb_add_class_to_row(q,cl,mask);
@@ -574,8 +455,7 @@ static void htb_deactivate_prios(struct 
 {
 	struct htb_class *p = cl->parent;
 	long m,mask = cl->prio_activity;
-	HTB_DBG(7,2,"htb_deact_prios cl=%X mask=%lX cmode=%d\n",cl->classid,mask,cl->cmode);
-	HTB_CHCL(cl);
+
 
 	while (cl->cmode == HTB_MAY_BORROW && p && mask) {
 		m = mask; mask = 0; 
@@ -591,16 +471,15 @@ static void htb_deactivate_prios(struct 
 				p->un.inner.ptr[prio] = NULL;
 			}
 			
-			htb_safe_rb_erase(cl->node + prio,p->un.inner.feed + prio);
+			rb_erase(cl->node + prio,p->un.inner.feed + prio);
 			
 			if (!p->un.inner.feed[prio].rb_node) 
 				mask |= 1 << prio;
 		}
-		HTB_DBG(7,3,"htb_deact_pr_aft p=%X pact=%X mask=%lX pmode=%d\n",
-				p->classid,p->prio_activity,mask,p->cmode);
+
 		p->prio_activity &= ~mask;
 		cl = p; p = cl->parent;
-		HTB_CHCL(cl);
+
 	}
 	if (cl->cmode == HTB_CAN_SEND && mask) 
 		htb_remove_class_from_row(q,cl,mask);
@@ -655,8 +534,6 @@ htb_change_class_mode(struct htb_sched *
 { 
 	enum htb_cmode new_mode = htb_class_mode(cl,diff);
 	
-	HTB_CHCL(cl);
-	HTB_DBG(7,1,"htb_chging_clmode %d->%d cl=%X\n",cl->cmode,new_mode,cl->classid);
 
 	if (new_mode == cl->cmode)
 		return;	
@@ -681,7 +558,7 @@ htb_change_class_mode(struct htb_sched *
 static __inline__ void htb_activate(struct htb_sched *q,struct htb_class *cl)
 {
 	BUG_TRAP(!cl->level && cl->un.leaf.q && cl->un.leaf.q->q.qlen);
-	HTB_CHCL(cl);
+
 	if (!cl->prio_activity) {
 		cl->prio_activity = 1 << (cl->un.leaf.aprio = cl->un.leaf.prio);
 		htb_activate_prios(q,cl);
@@ -699,7 +576,7 @@ static __inline__ void 
 htb_deactivate(struct htb_sched *q,struct htb_class *cl)
 {
 	BUG_TRAP(cl->prio_activity);
-	HTB_CHCL(cl);
+
 	htb_deactivate_prios(q,cl);
 	cl->prio_activity = 0;
 	list_del_init(&cl->un.leaf.drop_list);
@@ -739,7 +616,6 @@ #endif
 
     sch->q.qlen++;
     sch->bstats.packets++; sch->bstats.bytes += skb->len;
-    HTB_DBG(1,1,"htb_enq_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
 
@@ -771,7 +647,6 @@ static int htb_requeue(struct sk_buff *s
 
     sch->q.qlen++;
     sch->qstats.requeues++;
-    HTB_DBG(1,1,"htb_req_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
 
@@ -793,7 +668,6 @@ static void htb_rate_timer(unsigned long
 
 	/* lock queue so that we can muck with it */
 	HTB_QLOCK(sch);
-	HTB_DBG(10,1,"htb_rttmr j=%ld\n",jiffies);
 
 	q->rttim.expires = jiffies + HZ;
 	add_timer(&q->rttim);
@@ -803,8 +677,7 @@ static void htb_rate_timer(unsigned long
 		q->recmp_bucket = 0;
 	list_for_each (p,q->hash+q->recmp_bucket) {
 		struct htb_class *cl = list_entry(p,struct htb_class,hlist);
-		HTB_DBG(10,2,"htb_rttmr_cl cl=%X sbyte=%lu spkt=%lu\n",
-				cl->classid,cl->sum_bytes,cl->sum_packets);
+
 		RT_GEN (cl->sum_bytes,cl->rate_bytes);
 		RT_GEN (cl->sum_packets,cl->rate_packets);
 	}
@@ -828,7 +701,6 @@ static void htb_charge_class(struct htb_
 {	
 	long toks,diff;
 	enum htb_cmode old_mode;
-	HTB_DBG(5,1,"htb_chrg_cl cl=%X lev=%d len=%d\n",cl->classid,level,bytes);
 
 #define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
 	if (toks > cl->B) toks = cl->B; \
@@ -837,24 +709,7 @@ #define HTB_ACCNT(T,B,R) toks = diff + c
 	cl->T = toks
 
 	while (cl) {
-		HTB_CHCL(cl);
 		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
-#ifdef HTB_DEBUG
-		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
-			if (net_ratelimit())
-				printk(KERN_ERR "HTB: bad diff in charge, cl=%X diff=%lX now=%Lu then=%Lu j=%lu\n",
-				       cl->classid, diff,
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-				       q->now.tv_sec * 1000000ULL + q->now.tv_usec,
-				       cl->t_c.tv_sec * 1000000ULL + cl->t_c.tv_usec,
-#else
-				       (unsigned long long) q->now,
-				       (unsigned long long) cl->t_c,
-#endif
-				       q->jiffies);
-			diff = 1000;
-		}
-#endif
 		if (cl->level >= level) {
 			if (cl->level == level) cl->xstats.lends++;
 			HTB_ACCNT (tokens,buffer,rate);
@@ -864,15 +719,14 @@ #endif
 		}
 		HTB_ACCNT (ctokens,cbuffer,ceil);
 		cl->t_c = q->now;
-		HTB_DBG(5,2,"htb_chrg_clp cl=%X diff=%ld tok=%ld ctok=%ld\n",cl->classid,diff,cl->tokens,cl->ctokens);
 
 		old_mode = cl->cmode; diff = 0;
 		htb_change_class_mode(q,cl,&diff);
 		if (old_mode != cl->cmode) {
 			if (old_mode != HTB_CAN_SEND)
-				htb_safe_rb_erase(&cl->pq_node,q->wait_pq+cl->level);
+				rb_erase(&cl->pq_node,q->wait_pq+cl->level);
 			if (cl->cmode != HTB_CAN_SEND)
-				htb_add_to_wait_tree (q,cl,diff,1);
+				htb_add_to_wait_tree (q,cl,diff);
 		}
 		
 #ifdef HTB_RATECM
@@ -899,8 +753,7 @@ #endif
 static long htb_do_events(struct htb_sched *q,int level)
 {
 	int i;
-	HTB_DBG(8,1,"htb_do_events l=%d root=%p rmask=%X\n",
-			level,q->wait_pq[level].rb_node,q->row_mask[level]);
+
 	for (i = 0; i < 500; i++) {
 		struct htb_class *cl;
 		long diff;
@@ -910,30 +763,13 @@ static long htb_do_events(struct htb_sch
 
 		cl = rb_entry(p, struct htb_class, pq_node);
 		if (time_after(cl->pq_key, q->jiffies)) {
-			HTB_DBG(8,3,"htb_do_ev_ret delay=%ld\n",cl->pq_key - q->jiffies);
 			return cl->pq_key - q->jiffies;
 		}
-		htb_safe_rb_erase(p,q->wait_pq+level);
+		rb_erase(p,q->wait_pq+level);
 		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
-#ifdef HTB_DEBUG
-		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
-			if (net_ratelimit())
-				printk(KERN_ERR "HTB: bad diff in events, cl=%X diff=%lX now=%Lu then=%Lu j=%lu\n",
-				       cl->classid, diff,
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-				       q->now.tv_sec * 1000000ULL + q->now.tv_usec,
-				       cl->t_c.tv_sec * 1000000ULL + cl->t_c.tv_usec,
-#else
-				       (unsigned long long) q->now,
-				       (unsigned long long) cl->t_c,
-#endif
-				       q->jiffies);
-			diff = 1000;
-		}
-#endif
 		htb_change_class_mode(q,cl,&diff);
 		if (cl->cmode != HTB_CAN_SEND)
-			htb_add_to_wait_tree (q,cl,diff,2);
+			htb_add_to_wait_tree (q,cl,diff);
 	}
 	if (net_ratelimit())
 		printk(KERN_WARNING "htb: too many events !\n");
@@ -966,7 +802,7 @@ htb_id_find_next_upper(int prio,struct r
  * Find leaf where current feed pointers points to.
  */
 static struct htb_class *
-htb_lookup_leaf(HTB_ARGQ struct rb_root *tree,int prio,struct rb_node **pptr,u32 *pid)
+htb_lookup_leaf(struct rb_root *tree,int prio,struct rb_node **pptr,u32 *pid)
 {
 	int i;
 	struct {
@@ -981,8 +817,6 @@ htb_lookup_leaf(HTB_ARGQ struct rb_root 
 	sp->pid = pid;
 
 	for (i = 0; i < 65535; i++) {
-		HTB_DBG(4,2,"htb_lleaf ptr=%p pid=%X\n",*sp->pptr,*sp->pid);
-		
 		if (!*sp->pptr && *sp->pid) { 
 			/* ptr was invalidated but id is valid - try to recover 
 			   the original or next ptr */
@@ -1002,7 +836,6 @@ htb_lookup_leaf(HTB_ARGQ struct rb_root 
 		} else {
 			struct htb_class *cl;
 			cl = rb_entry(*sp->pptr,struct htb_class,node[prio]);
-			HTB_CHCL(cl);
 			if (!cl->level) 
 				return cl;
 			(++sp)->root = cl->un.inner.feed[prio].rb_node;
@@ -1022,15 +855,13 @@ htb_dequeue_tree(struct htb_sched *q,int
 	struct sk_buff *skb = NULL;
 	struct htb_class *cl,*start;
 	/* look initial class up in the row */
-	start = cl = htb_lookup_leaf (HTB_PASSQ q->row[level]+prio,prio,
+	start = cl = htb_lookup_leaf (q->row[level]+prio,prio,
 			q->ptr[level]+prio,q->last_ptr_id[level]+prio);
 	
 	do {
 next:
 		BUG_TRAP(cl); 
 		if (!cl) return NULL;
-		HTB_DBG(4,1,"htb_deq_tr prio=%d lev=%d cl=%X defic=%d\n",
-				prio,level,cl->classid,cl->un.leaf.deficit[level]);
 
 		/* class can be empty - it is unlikely but can be true if leaf
 		   qdisc drops packets in enqueue routine or if someone used
@@ -1044,7 +875,7 @@ next:
 			if ((q->row_mask[level] & (1 << prio)) == 0)
 				return NULL; 
 			
-			next = htb_lookup_leaf (HTB_PASSQ q->row[level]+prio,
+			next = htb_lookup_leaf (q->row[level]+prio,
 					prio,q->ptr[level]+prio,q->last_ptr_id[level]+prio);
 
 			if (cl == start) /* fix start if we just deleted it */
@@ -1061,15 +892,13 @@ next:
 		}
 		q->nwc_hit++;
 		htb_next_rb_node((level?cl->parent->un.inner.ptr:q->ptr[0])+prio);
-		cl = htb_lookup_leaf (HTB_PASSQ q->row[level]+prio,prio,q->ptr[level]+prio,
+		cl = htb_lookup_leaf (q->row[level]+prio,prio,q->ptr[level]+prio,
 				q->last_ptr_id[level]+prio);
 
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
 		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
-			HTB_DBG(4,2,"htb_next_cl oldptr=%p quant_add=%d\n",
-				level?cl->parent->un.inner.ptr[prio]:q->ptr[0][prio],cl->un.leaf.quantum);
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
 			htb_next_rb_node((level?cl->parent->un.inner.ptr:q->ptr[0])+prio);
 		}
@@ -1095,7 +924,6 @@ static void htb_delay_by(struct Qdisc *s
 	mod_timer(&q->timer, q->jiffies + delay);
 	sch->flags |= TCQ_F_THROTTLED;
 	sch->qstats.overlimits++;
-	HTB_DBG(3,1,"htb_deq t_delay=%ld\n",delay);
 }
 
 static struct sk_buff *htb_dequeue(struct Qdisc *sch)
@@ -1104,13 +932,8 @@ static struct sk_buff *htb_dequeue(struc
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	long min_delay;
-#ifdef HTB_DEBUG
-	int evs_used = 0;
-#endif
 
 	q->jiffies = jiffies;
-	HTB_DBG(3,1,"htb_deq dircnt=%d qlen=%d\n",skb_queue_len(&q->direct_queue),
-			sch->q.qlen);
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	if ((skb = __skb_dequeue(&q->direct_queue)) != NULL) {
@@ -1131,9 +954,6 @@ #endif
 		if (time_after_eq(q->jiffies, q->near_ev_cache[level])) {
 			delay = htb_do_events(q,level);
 			q->near_ev_cache[level] = q->jiffies + (delay ? delay : HZ);
-#ifdef HTB_DEBUG
-			evs_used++;
-#endif
 		} else
 			delay = q->near_ev_cache[level] - q->jiffies;	
 		
@@ -1151,20 +971,8 @@ #endif
 			}
 		}
 	}
-#ifdef HTB_DEBUG
-	if (!q->nwc_hit && min_delay >= 10*HZ && net_ratelimit()) {
-		if (min_delay == LONG_MAX) {
-			printk(KERN_ERR "HTB: dequeue bug (%d,%lu,%lu), report it please !\n",
-					evs_used,q->jiffies,jiffies);
-			htb_debug_dump(q);
-		} else 
-			printk(KERN_WARNING "HTB: mindelay=%ld, some class has "
-					"too small rate\n",min_delay);
-	}
-#endif
 	htb_delay_by (sch,min_delay > 5*HZ ? 5*HZ : min_delay);
 fin:
-	HTB_DBG(3,1,"htb_deq_end %s j=%lu skb=%p\n",sch->dev->name,q->jiffies,skb);
 	return skb;
 }
 
@@ -1198,7 +1006,6 @@ static void htb_reset(struct Qdisc* sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	int i;
-	HTB_DBG(0,1,"htb_reset sch=%p, handle=%X\n",sch,sch->handle);
 
 	for (i = 0; i < HTB_HSIZE; i++) {
 		struct list_head *p;
@@ -1213,10 +1020,6 @@ static void htb_reset(struct Qdisc* sch)
 			}
 			cl->prio_activity = 0;
 			cl->cmode = HTB_CAN_SEND;
-#ifdef HTB_DEBUG
-			cl->pq_node.rb_color = -1;
-			memset(cl->node,255,sizeof(cl->node));
-#endif
 
 		}
 	}
@@ -1238,10 +1041,6 @@ static int htb_init(struct Qdisc *sch, s
 	struct rtattr *tb[TCA_HTB_INIT];
 	struct tc_htb_glob *gopt;
 	int i;
-#ifdef HTB_DEBUG
-	printk(KERN_INFO "HTB init, kernel part version %d.%d\n",
-			  HTB_VER >> 16,HTB_VER & 0xffff);
-#endif
 	if (!opt || rtattr_parse_nested(tb, TCA_HTB_INIT, opt) ||
 			tb[TCA_HTB_INIT-1] == NULL ||
 			RTA_PAYLOAD(tb[TCA_HTB_INIT-1]) < sizeof(*gopt)) {
@@ -1254,8 +1053,6 @@ #endif
 				HTB_VER >> 16,HTB_VER & 0xffff,gopt->version);
 		return -EINVAL;
 	}
-	q->debug = gopt->debug;
-	HTB_DBG(0,1,"htb_init sch=%p handle=%X r2q=%d\n",sch,sch->handle,gopt->rate2quantum);
 
 	INIT_LIST_HEAD(&q->root);
 	for (i = 0; i < HTB_HSIZE; i++)
@@ -1292,18 +1089,13 @@ static int htb_dump(struct Qdisc *sch, s
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_glob gopt;
-	HTB_DBG(0,1,"htb_dump sch=%p, handle=%X\n",sch,sch->handle);
 	HTB_QLOCK(sch);
 	gopt.direct_pkts = q->direct_pkts;
 
-#ifdef HTB_DEBUG
-	if (HTB_DBG_COND(0,2))
-		htb_debug_dump(q);
-#endif
 	gopt.version = HTB_VER;
 	gopt.rate2quantum = q->rate2quantum;
 	gopt.defcls = q->defcls;
-	gopt.debug = q->debug;
+	gopt.debug = 0;
 	rta = (struct rtattr*)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
@@ -1319,16 +1111,11 @@ rtattr_failure:
 static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	struct sk_buff *skb, struct tcmsg *tcm)
 {
-#ifdef HTB_DEBUG
-	struct htb_sched *q = qdisc_priv(sch);
-#endif
 	struct htb_class *cl = (struct htb_class*)arg;
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_opt opt;
 
-	HTB_DBG(0,1,"htb_dump_class handle=%X clid=%X\n",sch->handle,cl->classid);
-
 	HTB_QLOCK(sch);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
@@ -1410,11 +1197,7 @@ static struct Qdisc * htb_leaf(struct Qd
 
 static unsigned long htb_get(struct Qdisc *sch, u32 classid)
 {
-#ifdef HTB_DEBUG
-	struct htb_sched *q = qdisc_priv(sch);
-#endif
 	struct htb_class *cl = htb_find(classid,sch);
-	HTB_DBG(0,1,"htb_get clid=%X q=%p cl=%p ref=%d\n",classid,q,cl,cl?cl->refcnt:0);
 	if (cl) 
 		cl->refcnt++;
 	return (unsigned long)cl;
@@ -1433,7 +1216,6 @@ static void htb_destroy_filters(struct t
 static void htb_destroy_class(struct Qdisc* sch,struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	HTB_DBG(0,1,"htb_destrycls clid=%X ref=%d\n", cl?cl->classid:0,cl?cl->refcnt:0);
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
 		sch->q.qlen -= cl->un.leaf.q->q.qlen;
@@ -1456,7 +1238,7 @@ static void htb_destroy_class(struct Qdi
 		htb_deactivate (q,cl);
 	
 	if (cl->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&cl->pq_node,q->wait_pq+cl->level);
+		rb_erase(&cl->pq_node,q->wait_pq+cl->level);
 	
 	kfree(cl);
 }
@@ -1465,7 +1247,6 @@ static void htb_destroy_class(struct Qdi
 static void htb_destroy(struct Qdisc* sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	HTB_DBG(0,1,"htb_destroy q=%p\n",q);
 
 	del_timer_sync (&q->timer);
 #ifdef HTB_RATECM
@@ -1488,7 +1269,6 @@ static int htb_delete(struct Qdisc *sch,
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class*)arg;
-	HTB_DBG(0,1,"htb_delete q=%p cl=%X ref=%d\n",q,cl?cl->classid:0,cl?cl->refcnt:0);
 
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
@@ -1512,11 +1292,7 @@ static int htb_delete(struct Qdisc *sch,
 
 static void htb_put(struct Qdisc *sch, unsigned long arg)
 {
-#ifdef HTB_DEBUG
-	struct htb_sched *q = qdisc_priv(sch);
-#endif
 	struct htb_class *cl = (struct htb_class*)arg;
-	HTB_DBG(0,1,"htb_put q=%p cl=%X ref=%d\n",q,cl?cl->classid:0,cl?cl->refcnt:0);
 
 	if (--cl->refcnt == 0)
 		htb_destroy_class(sch,cl);
@@ -1542,7 +1318,7 @@ static int htb_change_class(struct Qdisc
 	parent = parentid == TC_H_ROOT ? NULL : htb_find (parentid,sch);
 
 	hopt = RTA_DATA(tb[TCA_HTB_PARMS-1]);
-	HTB_DBG(0,1,"htb_chg cl=%p(%X), clid=%X, parid=%X, opt/prio=%d, rate=%u, buff=%d, quant=%d\n", cl,cl?cl->classid:0,classid,parentid,(int)hopt->prio,hopt->rate.rate,hopt->buffer,hopt->quantum);
+
 	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB-1]);
 	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB-1]);
 	if (!rtab || !ctab) goto failure;
@@ -1567,9 +1343,6 @@ static int htb_change_class(struct Qdisc
 		INIT_LIST_HEAD(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
-#ifdef HTB_DEBUG
-		cl->magic = HTB_CMAGIC;
-#endif
 
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
@@ -1585,7 +1358,7 @@ #endif
 
 			/* remove from evt list because of level change */
 			if (parent->cmode != HTB_CAN_SEND) {
-				htb_safe_rb_erase(&parent->pq_node,q->wait_pq /*+0*/);
+				rb_erase(&parent->pq_node,q->wait_pq);
 				parent->cmode = HTB_CAN_SEND;
 			}
 			parent->level = (parent->parent ? parent->parent->level
@@ -1607,13 +1380,6 @@ #endif
 		/* attach to the hash list and parent's family */
 		list_add_tail(&cl->hlist, q->hash+htb_hash(classid));
 		list_add_tail(&cl->sibling, parent ? &parent->children : &q->root);
-#ifdef HTB_DEBUG
-		{ 
-			int i;
-			for (i = 0; i < TC_HTB_NUMPRIO; i++) cl->node[i].rb_color = -1;
-			cl->pq_node.rb_color = -1;
-		}
-#endif
 	} else sch_tree_lock(sch);
 
 	/* it used to be a nasty bug here, we have to check that node
@@ -1654,7 +1420,7 @@ static struct tcf_proto **htb_find_tcf(s
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 	struct tcf_proto **fl = cl ? &cl->filter_list : &q->filter_list;
-	HTB_DBG(0,2,"htb_tcf q=%p clid=%X fref=%d fl=%p\n",q,cl?cl->classid:0,cl?cl->filter_cnt:q->filter_cnt,*fl);
+
 	return fl;
 }
 
@@ -1663,7 +1429,7 @@ static unsigned long htb_bind_filter(str
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_find (classid,sch);
-	HTB_DBG(0,2,"htb_bind q=%p clid=%X cl=%p fref=%d\n",q,classid,cl,cl?cl->filter_cnt:q->filter_cnt);
+
 	/*if (cl && !cl->level) return 0;
 	  The line above used to be there to prevent attaching filters to 
 	  leaves. But at least tc_index filter uses this just to get class 
@@ -1684,7 +1450,7 @@ static void htb_unbind_filter(struct Qdi
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
-	HTB_DBG(0,2,"htb_unbind q=%p cl=%p fref=%d\n",q,cl,cl?cl->filter_cnt:q->filter_cnt);
+
 	if (cl) 
 		cl->filter_cnt--; 
 	else 
-- 
1.4.0

