From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4 2/4]: replace eligible list by rbtree
Date: Sat, 14 Aug 2004 22:01:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6FAD.1090904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060408080200000501070206"
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060408080200000501070206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch replaces the eligible list by a rbtree.


--------------060408080200000501070206
Content-Type: text/x-patch;
 name="02-hfsc-2.4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-hfsc-2.4.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 23:14:22+02:00 kaber@coreworks.de 
#   [NET_SCHED]: Replace eligible list by rbtree in HFSC scheduler
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_hfsc.c
#   2004/08/11 23:14:17+02:00 kaber@coreworks.de +42 -69
#   [NET_SCHED]: Replace eligible list by rbtree in HFSC scheduler
# 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2004-08-12 23:23:11 +02:00
+++ b/net/sched/sch_hfsc.c	2004-08-12 23:23:11 +02:00
@@ -61,6 +61,7 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <linux/list.h>
+#include <linux/rbtree.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
@@ -131,9 +132,9 @@
 	struct list_head children;	/* child classes */
 	struct Qdisc	*qdisc;		/* leaf qdisc */
 
+	rb_node_t el_node;		/* qdisc's eligible tree member */
 	struct list_head actlist;	/* active children list */
 	struct list_head alist;		/* active children list member */
-	struct list_head ellist;	/* eligible list member */
 	struct list_head hlist;		/* hash list member */
 	struct list_head dlist;		/* drop list member */
 
@@ -181,7 +182,7 @@
 	u16	defcls;				/* default class id */
 	struct hfsc_class root;			/* root class */
 	struct list_head clhash[HFSC_HSIZE];	/* class hash */
-	struct list_head eligible;		/* eligible list */
+	rb_root_t eligible;			/* eligible tree */
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
 	struct sk_buff_head requeue;		/* requeued packet */
@@ -217,82 +218,51 @@
 
 
 /*
- * eligible list holds backlogged classes being sorted by their eligible times.
- * there is one eligible list per hfsc instance.
+ * eligible tree holds backlogged classes being sorted by their eligible times.
+ * there is one eligible tree per hfsc instance.
  */
 
 static void
-ellist_insert(struct hfsc_class *cl)
+eltree_insert(struct hfsc_class *cl)
 {
-	struct list_head *head = &cl->sched->eligible;
-	struct hfsc_class *p;
-
-	/* check the last entry first */
-	if (list_empty(head) ||
-	    ((p = list_entry(head->prev, struct hfsc_class, ellist)) &&
-	     p->cl_e <= cl->cl_e)) {
-		list_add_tail(&cl->ellist, head);
-		return;
-	}
-
-	list_for_each_entry(p, head, ellist) {
-		if (cl->cl_e < p->cl_e) {
-			/* insert cl before p */
-			list_add_tail(&cl->ellist, &p->ellist);
-			return;
-		}
+	rb_node_t **p = &cl->sched->eligible.rb_node;
+	rb_node_t *parent = NULL;
+	struct hfsc_class *cl1;
+
+	while (*p != NULL) {
+		parent = *p;
+		cl1 = rb_entry(parent, struct hfsc_class, el_node);
+		if (cl->cl_e >= cl1->cl_e)
+			p = &parent->rb_right;
+		else
+			p = &parent->rb_left;
 	}
-	ASSERT(0); /* should not reach here */
+	rb_link_node(&cl->el_node, parent, p);
+	rb_insert_color(&cl->el_node, &cl->sched->eligible);
 }
 
 static inline void
-ellist_remove(struct hfsc_class *cl)
+eltree_remove(struct hfsc_class *cl)
 {
-	list_del(&cl->ellist);
+	rb_erase(&cl->el_node, &cl->sched->eligible);
 }
 
-static void
-ellist_update(struct hfsc_class *cl)
+static inline void
+eltree_update(struct hfsc_class *cl)
 {
-	struct list_head *head = &cl->sched->eligible;
-	struct hfsc_class *p, *last;
-
-	/*
-	 * the eligible time of a class increases monotonically.
-	 * if the next entry has a larger eligible time, nothing to do.
-	 */
-	if (cl->ellist.next == head ||
-	    ((p = list_entry(cl->ellist.next, struct hfsc_class, ellist)) &&
-	     cl->cl_e <= p->cl_e))
-		return;
-
-	/* check the last entry */
-	last = list_entry(head->prev, struct hfsc_class, ellist);
-	if (last->cl_e <= cl->cl_e) {
-		list_move_tail(&cl->ellist, head);
-		return;
-	}
-
-	/*
-	 * the new position must be between the next entry
-	 * and the last entry
-	 */
-	list_for_each_entry_continue(p, head, ellist) {
-		if (cl->cl_e < p->cl_e) {
-			list_move_tail(&cl->ellist, &p->ellist);
-			return;
-		}
-	}
-	ASSERT(0); /* should not reach here */
+	eltree_remove(cl);
+	eltree_insert(cl);
 }
 
 /* find the class with the minimum deadline among the eligible classes */
 static inline struct hfsc_class *
-ellist_get_mindl(struct list_head *head, u64 cur_time)
+eltree_get_mindl(struct hfsc_sched *q, u64 cur_time)
 {
 	struct hfsc_class *p, *cl = NULL;
+	rb_node_t *n;
 
-	list_for_each_entry(p, head, ellist) {
+	for (n = rb_first(&q->eligible); n != NULL; n = rb_next(n)) {
+		p = rb_entry(n, struct hfsc_class, el_node);
 		if (p->cl_e > cur_time)
 			break;
 		if (cl == NULL || p->cl_d < cl->cl_d)
@@ -303,11 +273,14 @@
 
 /* find the class with minimum eligible time among the eligible classes */
 static inline struct hfsc_class *
-ellist_get_minel(struct list_head *head)
+eltree_get_minel(struct hfsc_sched *q)
 {
-	if (list_empty(head))
+	rb_node_t *n;
+	
+	n = rb_first(&q->eligible);
+	if (n == NULL)
 		return NULL;
-	return list_entry(head->next, struct hfsc_class, ellist);
+	return rb_entry(n, struct hfsc_class, el_node);
 }
 
 /*
@@ -709,7 +682,7 @@
 	cl->cl_e = rtsc_y2x(&cl->cl_eligible, cl->cl_cumul);
 	cl->cl_d = rtsc_y2x(&cl->cl_deadline, cl->cl_cumul + next_len);
 
-	ellist_insert(cl);
+	eltree_insert(cl);
 }
 
 static void
@@ -718,7 +691,7 @@
 	cl->cl_e = rtsc_y2x(&cl->cl_eligible, cl->cl_cumul);
 	cl->cl_d = rtsc_y2x(&cl->cl_deadline, cl->cl_cumul + next_len);
 
-	ellist_update(cl);
+	eltree_update(cl);
 }
 
 static inline void
@@ -939,7 +912,7 @@
 set_passive(struct hfsc_class *cl)
 {
 	if (cl->cl_flags & HFSC_RSC)
-		ellist_remove(cl);
+		eltree_remove(cl);
 
 	list_del(&cl->dlist);
 
@@ -1500,7 +1473,7 @@
 	u64 next_time = 0;
 	long delay;
 
-	if ((cl = ellist_get_minel(&q->eligible)) != NULL)
+	if ((cl = eltree_get_minel(q)) != NULL)
 		next_time = cl->cl_e;
 	if (q->root.cl_cfmin != 0) {
 		if (next_time == 0 || next_time > q->root.cl_cfmin)
@@ -1531,7 +1504,7 @@
 	q->defcls = qopt->defcls;
 	for (i = 0; i < HFSC_HSIZE; i++)
 		INIT_LIST_HEAD(&q->clhash[i]);
-	INIT_LIST_HEAD(&q->eligible);
+	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	skb_queue_head_init(&q->requeue);
 
@@ -1614,7 +1587,7 @@
 			hfsc_reset_class(cl);
 	}
 	__skb_queue_purge(&q->requeue);
-	INIT_LIST_HEAD(&q->eligible);
+	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	del_timer(&q->wd_timer);
 	sch->flags &= ~TCQ_F_THROTTLED;
@@ -1712,7 +1685,7 @@
 	 * find the class with the minimum deadline among
 	 * the eligible classes.
 	 */
-	if ((cl = ellist_get_mindl(&q->eligible, cur_time)) != NULL) {
+	if ((cl = eltree_get_mindl(q, cur_time)) != NULL) {
 		realtime = 1;
 	} else {
 		/*

--------------060408080200000501070206--
