From: Simon Lodal <simonl@parknet.dk>
Subject: [PATCH] HTB O(1) class lookup
Date: Thu, 1 Feb 2007 06:18:48 +0100
Message-ID: <200702010618.48692.simonl@parknet.dk>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4gXwF1c+c/t9pjG"
Cc: lartc@mailman.ds9a.nl
To: netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

--Boundary-00=_4gXwF1c+c/t9pjG
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This patch changes HTB's class storage from hash+lists to a two-level linear 
array, so it can do constant time (O(1)) class lookup by classid. It improves 
scalability for large number of classes.

Without the patch, ~14k htb classes can starve a Xeon-3.2 at only 15kpps, 
using most of it's cycles traversing lists in htb_find(). The patch 
eliminates this problem, and has a measurable impact even with a few hundred 
classes.

Previously, scalability could be improved by increasing HTB_HSIZE, modify the 
hash function, and recompile, but this patch works for everyone without 
recompile and scales better too.

The patch is for 2.6.20-rc6, I have older ones for 2.6.18 and 2.6.19 if anyone 
is interested.

Signed-off-by: Simon Lodal <simonl@parknet.dk>

--Boundary-00=_4gXwF1c+c/t9pjG
Content-Type: text/x-diff; charset="us-ascii";
	name="htb_O(1)_class_lookup.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="htb_O(1)_class_lookup.diff"

--- linux-2.6.20-rc6.base/net/sched/sch_htb.c	2007-01-25 03:19:28.000000000 +0100
+++ linux-2.6.20-rc6/net/sched/sch_htb.c	2007-02-01 05:44:36.000000000 +0100
@@ -68,16 +68,37 @@
     one less than their parent.
 */
 
-#define HTB_HSIZE 16		/* classid hash size */
-#define HTB_EWMAC 2		/* rate average over HTB_EWMAC*HTB_HSIZE sec */
-#define HTB_RATECM 1		/* whether to use rate computer */
+#define HTB_MAX_CLS		(TC_H_MIN(-1)+1)
+#define HTB_CLS_ARRAY_SIZE	PAGE_SIZE
+#define HTB_CLS_PER_ARRAY	(HTB_CLS_ARRAY_SIZE / sizeof(void*))
+#define HTB_CLS_ARRAYS		(HTB_MAX_CLS / HTB_CLS_PER_ARRAY)
+#define HTB_CLS_ARRAY(CID)	(CID / HTB_CLS_PER_ARRAY)
+#define HTB_CLS_INDEX(CID)	(CID & (HTB_CLS_PER_ARRAY-1))
+
+
 #define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
-#define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
+#define HTB_VER 0x30012		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
 #error "Mismatched sch_htb.c and pkt_sch.h"
 #endif
 
+/* Whether to use rate computer. This is only used for statistics output to
+   userspace (tc -s class show dev ...); if you do not care about that and
+   want the last bit of performance, disable this. */
+#define HTB_RATECM
+#ifdef HTB_RATECM
+/* Time between rate computation updates, in seconds, for each class. */
+#define HTB_RATECM_UPDATE_INTERVAL	16
+/* How many HTB_RATECM_UPDATE_INTERVAL intervals to average over when
+   computing the rate. If set to 1, the computed rate will be exactly the
+   observed rate of the last interval. If set to higher values, the computed
+   rate will converge slower, but also vary less with small, temporary changes
+   in traffic.
+*/
+#define HTB_RATECM_AVERAGE_INTERVALS	2
+#endif
+
 /* used internaly to keep status of single class */
 enum htb_cmode {
 	HTB_CANT_SEND,		/* class can't send and can't borrow */
@@ -104,7 +125,7 @@
 	/* topology */
 	int level;		/* our level (see above) */
 	struct htb_class *parent;	/* parent class */
-	struct hlist_node hlist;	/* classid hash list item */
+	struct list_head clist;		/* classid list item */
 	struct list_head sibling;	/* sibling list item */
 	struct list_head children;	/* children list */
 
@@ -165,9 +186,13 @@
 	return rate->data[slot];
 }
 
+typedef struct htb_class* htb_cls_array[HTB_CLS_PER_ARRAY];
+
 struct htb_sched {
-	struct list_head root;	/* root classes list */
-	struct hlist_head hash[HTB_HSIZE];	/* hashed by classid */
+	struct list_head root;		/* root classes list */
+	struct list_head clist;		/* all classes list */
+	/* all classes arrays for fast lookup */
+	htb_cls_array* classes[HTB_CLS_ARRAYS];
 	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
 	/* self list - roots of self generating tree */
@@ -198,8 +223,10 @@
 	psched_time_t now;	/* cached dequeue time */
 	struct timer_list timer;	/* send delay timer */
 #ifdef HTB_RATECM
-	struct timer_list rttim;	/* rate computer timer */
-	int recmp_bucket;	/* which hash bucket to recompute next */
+	struct timer_list rttim;/* rate computer timer */
+	int clscnt;		/* total number of classes */
+	struct list_head *rtcur;/* current class to update rate timer for */
+	int rtiter;		/* current iteration (1..UPDATE_INTERVAL) */
 #endif
 
 	/* non shaped skbs; let them go directly thru */
@@ -209,32 +236,22 @@
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
-/* find class in global hash table using given handle */
+/* find class in class arrays using given handle */
 static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct hlist_node *p;
-	struct htb_class *cl;
+	htb_cls_array* a;
+	int minorid;
 
 	if (TC_H_MAJ(handle) != sch->handle)
 		return NULL;
 
-	hlist_for_each_entry(cl, p, q->hash + htb_hash(handle), hlist) {
-		if (cl->classid == handle)
-			return cl;
-	}
-	return NULL;
+	minorid = TC_H_MIN(handle);
+	a = q->classes[HTB_CLS_ARRAY(minorid)];
+	if (a == NULL)
+		return NULL;
+
+	return (*a)[HTB_CLS_INDEX(minorid)];
 }
 
 /**
@@ -689,13 +706,14 @@
 }
 
 #ifdef HTB_RATECM
-#define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
+#define RT_GEN(R,S) R+=S-(R/HTB_RATECM_AVERAGE_INTERVALS);S=0
+/* recompute rate for approximately clscnt/UPDATE_INTERVAL classes */
 static void htb_rate_timer(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct htb_sched *q = qdisc_priv(sch);
-	struct hlist_node *p;
 	struct htb_class *cl;
+	int cnt,done;
 
 
 	/* lock queue so that we can muck with it */
@@ -704,14 +722,35 @@
 	q->rttim.expires = jiffies + HZ;
 	add_timer(&q->rttim);
 
-	/* scan and recompute one bucket at time */
-	if (++q->recmp_bucket >= HTB_HSIZE)
-		q->recmp_bucket = 0;
-
-	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist) {
-		RT_GEN(cl->sum_bytes, cl->rate_bytes);
-		RT_GEN(cl->sum_packets, cl->rate_packets);
+	if (q->clscnt == 0)
+		goto done;
+	if (q->rtiter == HTB_RATECM_UPDATE_INTERVAL)
+		q->rtiter = 0;
+	if (q->rtiter == 0)
+		q->rtcur = q->clist.next;
+	q->rtiter++;
+	cnt = ((q->clscnt * q->rtiter) / HTB_RATECM_UPDATE_INTERVAL) -
+	      ((q->clscnt * (q->rtiter-1)) / HTB_RATECM_UPDATE_INTERVAL);
+	done = 0;
+	for (;;) {
+		/* end of class list */
+		if (q->rtcur == NULL)
+			break;
+		/* last iteration must continue until end */
+		if ((done == cnt) &&
+		    (q->rtiter < HTB_RATECM_UPDATE_INTERVAL)) {
+			break;
+		}
+		cl = list_entry(q->rtcur, struct htb_class, clist);
+		RT_GEN(cl->rate_bytes, cl->sum_bytes);
+		RT_GEN(cl->rate_packets, cl->sum_packets);
+		done++;
+		q->rtcur = q->rtcur->next;
+		if (q->rtcur == &q->clist)
+			q->rtcur = NULL;
 	}
+
+done:
 	spin_unlock_bh(&sch->dev->queue_lock);
 }
 #endif
@@ -1058,23 +1097,19 @@
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	int i;
+	struct list_head *p;
 
-	for (i = 0; i < HTB_HSIZE; i++) {
-		struct hlist_node *p;
-		struct htb_class *cl;
-
-		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
-			if (cl->level)
-				memset(&cl->un.inner, 0, sizeof(cl->un.inner));
-			else {
-				if (cl->un.leaf.q)
-					qdisc_reset(cl->un.leaf.q);
-				INIT_LIST_HEAD(&cl->un.leaf.drop_list);
-			}
-			cl->prio_activity = 0;
-			cl->cmode = HTB_CAN_SEND;
-
+	list_for_each(p, &q->clist) {
+		struct htb_class *cl = list_entry(p, struct htb_class, clist);
+		if (cl->level)
+			memset(&cl->un.inner, 0, sizeof(cl->un.inner));
+		else {
+			if (cl->un.leaf.q) 
+				qdisc_reset(cl->un.leaf.q);
+			INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 		}
+		cl->prio_activity = 0;
+		cl->cmode = HTB_CAN_SEND;
 	}
 	sch->flags &= ~TCQ_F_THROTTLED;
 	del_timer(&q->timer);
@@ -1109,8 +1144,7 @@
 	}
 
 	INIT_LIST_HEAD(&q->root);
-	for (i = 0; i < HTB_HSIZE; i++)
-		INIT_HLIST_HEAD(q->hash + i);
+	INIT_LIST_HEAD(&q->clist);
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
 		INIT_LIST_HEAD(q->drops + i);
 
@@ -1204,8 +1238,10 @@
 	struct htb_class *cl = (struct htb_class *)arg;
 
 #ifdef HTB_RATECM
-	cl->rate_est.bps = cl->rate_bytes / (HTB_EWMAC * HTB_HSIZE);
-	cl->rate_est.pps = cl->rate_packets / (HTB_EWMAC * HTB_HSIZE);
+	cl->rate_est.bps = cl->rate_bytes /
+		(HTB_RATECM_UPDATE_INTERVAL * HTB_RATECM_AVERAGE_INTERVALS);
+	cl->rate_est.pps = cl->rate_packets /
+		(HTB_RATECM_UPDATE_INTERVAL * HTB_RATECM_AVERAGE_INTERVALS);
 #endif
 
 	if (!cl->level && cl->un.leaf.q)
@@ -1310,6 +1346,7 @@
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+	int minorid = TC_H_MIN(cl->classid);
 
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
@@ -1325,7 +1362,7 @@
 						  struct htb_class, sibling));
 
 	/* note: this delete may happen twice (see htb_delete) */
-	hlist_del_init(&cl->hlist);
+	list_del(&cl->clist);
 	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
@@ -1334,6 +1371,7 @@
 	if (cl->cmode != HTB_CAN_SEND)
 		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
 
+	(*q->classes[HTB_CLS_ARRAY(minorid)])[HTB_CLS_INDEX(minorid)] = NULL;
 	kfree(cl);
 }
 
@@ -1341,6 +1379,7 @@
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+	int i;
 
 	del_timer_sync(&q->timer);
 #ifdef HTB_RATECM
@@ -1355,6 +1394,8 @@
 	while (!list_empty(&q->root))
 		htb_destroy_class(sch, list_entry(q->root.next,
 						  struct htb_class, sibling));
+	for (i=0; i<HTB_CLS_ARRAYS; i++)
+		kfree(q->classes[i]);
 
 	__skb_queue_purge(&q->direct_queue);
 }
@@ -1381,8 +1422,15 @@
 
 	sch_tree_lock(sch);
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
+	/* delete from class list and active; remainder in destroy_class */
+	if (q->rtcur == &cl->clist) {
+		q->rtcur = q->rtcur->next;
+		if (q->rtcur == &q->clist)
+			q->rtcur = NULL;
+	}
+	if (--q->clscnt == 0)
+		q->rtiter = 0;
+	list_del_init(&cl->clist);
 
 	if (!cl->level) {
 		qlen = cl->un.leaf.q->q.qlen;
@@ -1422,6 +1470,7 @@
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
 	struct rtattr *tb[TCA_HTB_RTAB];
 	struct tc_htb_opt *hopt;
+	int minorid = TC_H_MIN(classid);
 
 	/* extract all subattrs from opt attr */
 	if (!opt || rtattr_parse_nested(tb, TCA_HTB_RTAB, opt) ||
@@ -1453,12 +1502,18 @@
 			goto failure;
 		}
 		err = -ENOBUFS;
+		if (q->classes[HTB_CLS_ARRAY(minorid)] == NULL) {
+			if ((q->classes[HTB_CLS_ARRAY(minorid)] = 
+			     kzalloc(sizeof(htb_cls_array), GFP_KERNEL))
+			    == NULL)
+				goto failure;
+		}
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
 		cl->refcnt = 1;
+		INIT_LIST_HEAD(&cl->clist);
 		INIT_LIST_HEAD(&cl->sibling);
-		INIT_HLIST_NODE(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 		RB_CLEAR_NODE(&cl->pq_node);
@@ -1503,10 +1558,12 @@
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
-		/* attach to the hash list and parent's family */
-		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
+		/* attach to the classes list+array and parent's family */
+		list_add_tail(&cl->clist, &q->clist);
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
+		(*q->classes[HTB_CLS_ARRAY(minorid)])[HTB_CLS_INDEX(minorid)] = cl;
+		q->clscnt++;
 	} else
 		sch_tree_lock(sch);
 
@@ -1602,26 +1659,22 @@
 static void htb_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	int i;
+	struct list_head *p;
 
 	if (arg->stop)
 		return;
 
-	for (i = 0; i < HTB_HSIZE; i++) {
-		struct hlist_node *p;
-		struct htb_class *cl;
-
-		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
-			if (arg->count < arg->skip) {
-				arg->count++;
-				continue;
-			}
-			if (arg->fn(sch, (unsigned long)cl, arg) < 0) {
-				arg->stop = 1;
-				return;
-			}
+	list_for_each(p, &q->clist) {
+		struct htb_class *cl = list_entry(p, struct htb_class, clist);
+		if (arg->count < arg->skip) {
 			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, (unsigned long)cl, arg) < 0) {
+			arg->stop = 1;
+			return;
 		}
+		arg->count++;
 	}
 }
 

--Boundary-00=_4gXwF1c+c/t9pjG
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
LARTC mailing list
LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc

--Boundary-00=_4gXwF1c+c/t9pjG--
