From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4 3/4]: replace actlist by rbtrees
Date: Sat, 14 Aug 2004 22:01:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6FB2.3050501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060501030002060205020209"
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060501030002060205020209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch replaces actlist by two rbtrees: vt_tree, sorted by virtual
time and cf_tree, sorted by fit-time.


--------------060501030002060205020209
Content-Type: text/x-patch;
 name="03-hfsc-2.4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03-hfsc-2.4.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 23:22:13+02:00 kaber@coreworks.de 
#   [NET_SCHED]: Replace actlist by rbtrees in HFSC scheduler
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_hfsc.c
#   2004/08/11 23:22:06+02:00 kaber@coreworks.de +92 -90
#   [NET_SCHED]: Replace actlist by rbtrees in HFSC scheduler
# 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2004-08-12 23:23:16 +02:00
+++ b/net/sched/sch_hfsc.c	2004-08-12 23:23:16 +02:00
@@ -133,8 +133,10 @@
 	struct Qdisc	*qdisc;		/* leaf qdisc */
 
 	rb_node_t el_node;		/* qdisc's eligible tree member */
-	struct list_head actlist;	/* active children list */
-	struct list_head alist;		/* active children list member */
+	rb_root_t vt_tree;		/* active children sorted by cl_vt */
+	rb_node_t vt_node;		/* parent's vt_tree member */
+	rb_root_t cf_tree;		/* active children sorted by cl_f */
+	rb_node_t cf_node;		/* parent's cf_heap member */
 	struct list_head hlist;		/* hash list member */
 	struct list_head dlist;		/* drop list member */
 
@@ -284,84 +286,51 @@
 }
 
 /*
- * active children list holds backlogged child classes being sorted
- * by their virtual time. each intermediate class has one active
- * children list.
+ * vttree holds holds backlogged child classes being sorted by their virtual
+ * time. each intermediate class has one vttree.
  */
 static void
-actlist_insert(struct hfsc_class *cl)
+vttree_insert(struct hfsc_class *cl)
 {
-	struct list_head *head = &cl->cl_parent->actlist;
-	struct hfsc_class *p;
-
-	/* check the last entry first */
-	if (list_empty(head) ||
-	    ((p = list_entry(head->prev, struct hfsc_class, alist)) &&
-	     p->cl_vt <= cl->cl_vt)) {
-		list_add_tail(&cl->alist, head);
-		return;
-	}
+	rb_node_t **p = &cl->cl_parent->vt_tree.rb_node;
+	rb_node_t *parent = NULL;
+	struct hfsc_class *cl1;
 
-	list_for_each_entry(p, head, alist) {
-		if (cl->cl_vt < p->cl_vt) {
-			/* insert cl before p */
-			list_add_tail(&cl->alist, &p->alist);
-			return;
-		}
+	while (*p != NULL) {
+		parent = *p;
+		cl1 = rb_entry(parent, struct hfsc_class, vt_node);
+		if (cl->cl_vt >= cl1->cl_vt)
+			p = &parent->rb_right;
+		else
+			p = &parent->rb_left;
 	}
-	ASSERT(0); /* should not reach here */
+	rb_link_node(&cl->vt_node, parent, p);
+	rb_insert_color(&cl->vt_node, &cl->cl_parent->vt_tree);
 }
 
 static inline void
-actlist_remove(struct hfsc_class *cl)
+vttree_remove(struct hfsc_class *cl)
 {
-	list_del(&cl->alist);
+	rb_erase(&cl->vt_node, &cl->cl_parent->vt_tree);
 }
 
-static void
-actlist_update(struct hfsc_class *cl)
+static inline void
+vttree_update(struct hfsc_class *cl)
 {
-	struct list_head *head = &cl->cl_parent->actlist;
-	struct hfsc_class *p, *last;
-
-	/*
-	 * the virtual time of a class increases monotonically.
-	 * if the next entry has a larger virtual time, nothing to do.
-	 */
-	if (cl->alist.next == head ||
-	    ((p = list_entry(cl->alist.next, struct hfsc_class, alist)) &&
-	     cl->cl_vt <= p->cl_vt))
-		return;
-
-	/* check the last entry */
-	last = list_entry(head->prev, struct hfsc_class, alist);
-	if (last->cl_vt <= cl->cl_vt) {
-		list_move_tail(&cl->alist, head);
-		return;
-	}
-
-	/*
-	 * the new position must be between the next entry
-	 * and the last entry
-	 */
-	list_for_each_entry_continue(p, head, alist) {
-		if (cl->cl_vt < p->cl_vt) {
-			list_move_tail(&cl->alist, &p->alist);
-			return;
-		}
-	}
-	ASSERT(0); /* should not reach here */
+	vttree_remove(cl);
+	vttree_insert(cl);
 }
 
 static inline struct hfsc_class *
-actlist_firstfit(struct hfsc_class *cl, u64 cur_time)
+vttree_firstfit(struct hfsc_class *cl, u64 cur_time)
 {
 	struct hfsc_class *p;
+	rb_node_t *n;
 
-	list_for_each_entry(p, &cl->actlist, alist) {
-		if (p->cl_f <= cur_time) {
+	for (n = rb_first(&cl->vt_tree); n != NULL; n = rb_next(n)) {
+		p = rb_entry(n, struct hfsc_class, vt_node);
+		if (p->cl_f <= cur_time)
 			return p;
-		}
 	}
 	return NULL;
 }
@@ -370,14 +339,14 @@
  * get the leaf class with the minimum vt in the hierarchy
  */
 static struct hfsc_class *
-actlist_get_minvt(struct hfsc_class *cl, u64 cur_time)
+vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
 {
 	/* if root-class's cfmin is bigger than cur_time nothing to do */
 	if (cl->cl_cfmin > cur_time)
 		return NULL;
 
 	while (cl->level > 0) {
-		cl = actlist_firstfit(cl, cur_time);
+		cl = vttree_firstfit(cl, cur_time);
 		if (cl == NULL)
 			return NULL;
 		/*
@@ -389,6 +358,38 @@
 	return cl;
 }
 
+static void
+cftree_insert(struct hfsc_class *cl)
+{
+	rb_node_t **p = &cl->cl_parent->cf_tree.rb_node;
+	rb_node_t *parent = NULL;
+	struct hfsc_class *cl1;
+
+	while (*p != NULL) {
+		parent = *p;
+		cl1 = rb_entry(parent, struct hfsc_class, cf_node);
+		if (cl->cl_f >= cl1->cl_f)
+			p = &parent->rb_right;
+		else
+			p = &parent->rb_left;
+	}
+	rb_link_node(&cl->cf_node, parent, p);
+	rb_insert_color(&cl->cf_node, &cl->cl_parent->cf_tree);
+}
+
+static inline void
+cftree_remove(struct hfsc_class *cl)
+{
+	rb_erase(&cl->cf_node, &cl->cl_parent->cf_tree);
+}
+
+static inline void
+cftree_update(struct hfsc_class *cl)
+{
+	cftree_remove(cl);
+	cftree_insert(cl);
+}
+
 /*
  * service curve support functions
  *
@@ -700,32 +701,25 @@
 	cl->cl_d = rtsc_y2x(&cl->cl_deadline, cl->cl_cumul + next_len);
 }
 
-static void
+static inline void
 update_cfmin(struct hfsc_class *cl)
 {
+	rb_node_t *n = rb_first(&cl->cf_tree);
 	struct hfsc_class *p;
-	u64 cfmin;
 
-	if (list_empty(&cl->actlist)) {
+	if (n == NULL) {
 		cl->cl_cfmin = 0;
 		return;
 	}
-	cfmin = HT_INFINITY;
-	list_for_each_entry(p, &cl->actlist, alist) {
-		if (p->cl_f == 0) {
-			cl->cl_cfmin = 0;
-			return;
-		}
-		if (p->cl_f < cfmin)
-			cfmin = p->cl_f;
-	}
-	cl->cl_cfmin = cfmin;
+	p = rb_entry(n, struct hfsc_class, cf_node);
+	cl->cl_cfmin = p->cl_f;
 }
 
 static void
 init_vf(struct hfsc_class *cl, unsigned int len)
 {
 	struct hfsc_class *max_cl, *p;
+	rb_node_t *n;
 	u64 vt, f, cur_time;
 	int go_active;
 
@@ -738,9 +732,9 @@
 			go_active = 0;
 
 		if (go_active) {
-			if (!list_empty(&cl->cl_parent->actlist)) {
-				max_cl = list_entry(cl->cl_parent->actlist.prev,
-				                    struct hfsc_class, alist);
+			n = rb_last(&cl->cl_parent->vt_tree);
+			if (n != NULL) {
+				max_cl = rb_entry(n, struct hfsc_class,vt_node);
 				/*
 				 * set vt to the average of the min and max
 				 * classes.  if the parent's period didn't
@@ -785,7 +779,8 @@
 				cl->cl_parentperiod++;
 			cl->cl_f = 0;
 
-			actlist_insert(cl);
+			vttree_insert(cl);
+			cftree_insert(cl);
 
 			if (cl->cl_flags & HFSC_USC) {
 				/* class has upper limit curve */
@@ -805,6 +800,7 @@
 		f = max(cl->cl_myf, cl->cl_cfmin);
 		if (f != cl->cl_f) {
 			cl->cl_f = f;
+			cftree_update(cl);
 			update_cfmin(cl->cl_parent);
 		}
 	}
@@ -837,9 +833,10 @@
 			if (cl->cl_vt > cl->cl_parent->cl_cvtmax)
 				cl->cl_parent->cl_cvtmax = cl->cl_vt;
 
-			/* remove this class from the vt list */
-			actlist_remove(cl);
+			/* remove this class from the vt tree */
+			vttree_remove(cl);
 
+			cftree_remove(cl);
 			update_cfmin(cl->cl_parent);
 
 			continue;
@@ -861,8 +858,8 @@
 			cl->cl_vt = cl->cl_parent->cl_cvtmin;
 		}
 
-		/* update the vt list */
-		actlist_update(cl);
+		/* update the vt tree */
+		vttree_update(cl);
 
 		if (cl->cl_flags & HFSC_USC) {
 			cl->cl_myf = cl->cl_myfadj + rtsc_y2x(&cl->cl_ulimit,
@@ -892,6 +889,7 @@
 		f = max(cl->cl_myf, cl->cl_cfmin);
 		if (f != cl->cl_f) {
 			cl->cl_f = f;
+			cftree_update(cl);
 			update_cfmin(cl->cl_parent);
 		}
 	}
@@ -917,8 +915,8 @@
 	list_del(&cl->dlist);
 
 	/*
-	 * actlist is now handled in update_vf() so that update_vf(cl, 0, 0)
-	 * needs to be called explicitly to remove a class from actlist
+	 * vttree is now handled in update_vf() so that update_vf(cl, 0, 0)
+	 * needs to be called explicitly to remove a class from vttree.
 	 */
 }
 
@@ -1141,7 +1139,8 @@
 		cl->qdisc = &noop_qdisc;
 	cl->stats.lock = &sch->dev->queue_lock;
 	INIT_LIST_HEAD(&cl->children);
-	INIT_LIST_HEAD(&cl->actlist);
+	cl->vt_tree = RB_ROOT;
+	cl->cf_tree = RB_ROOT;
 
 	sch_tree_lock(sch);
 	list_add_tail(&cl->hlist, &q->clhash[hfsc_hash(classid)]);
@@ -1516,7 +1515,8 @@
 		q->root.qdisc = &noop_qdisc;
 	q->root.stats.lock = &sch->dev->queue_lock;
 	INIT_LIST_HEAD(&q->root.children);
-	INIT_LIST_HEAD(&q->root.actlist);
+	q->root.vt_tree = RB_ROOT;
+	q->root.cf_tree = RB_ROOT;
 
 	list_add(&q->root.hlist, &q->clhash[hfsc_hash(q->root.classid)]);
 
@@ -1564,7 +1564,9 @@
 	cl->cl_myfadj       = 0;
 	cl->cl_cfmin        = 0;
 	cl->cl_nactive      = 0;
-	INIT_LIST_HEAD(&cl->actlist);
+
+	cl->vt_tree = RB_ROOT;
+	cl->cf_tree = RB_ROOT;
 	qdisc_reset(cl->qdisc);
 
 	if (cl->cl_flags & HFSC_RSC)
@@ -1692,7 +1694,7 @@
 		 * use link-sharing criteria
 		 * get the class with the minimum vt in the hierarchy
 		 */
-		cl = actlist_get_minvt(&q->root, cur_time);
+		cl = vttree_get_minvt(&q->root, cur_time);
 		if (cl == NULL) {
 			sch->stats.overlimits++;
 			hfsc_schedule_watchdog(sch, cur_time);

--------------060501030002060205020209--
