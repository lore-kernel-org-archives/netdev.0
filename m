From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Mon, 3 Sep 2007 09:31:00 +0200
Message-ID: <20070903073059.GA1899@ff.dom.local>
References: <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local> <46D8265B.6000405@bigtelecom.ru> <46D82AEC.5010404@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42302 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751676AbXICH33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 03:29:29 -0400
Content-Disposition: inline
In-Reply-To: <46D82AEC.5010404@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 06:51:24PM +0400, Badalian Vyacheslav wrote:
> I found that bug in this place
> 
> (gdb) l *0xc01c8973
> 0xc01c8973 is in rb_insert_color (lib/rbtree.c:80).
...
> if i not wrong understand message "unable to handle kernel NULL pointer 
> dereference at virtual address 00000008" its was known that "gparent == 
> Null"?
> Or i hope or i try find a mare's-nest?

Your errors trigger in rbtree, which does indexing for HTB, but since
it's something quite rare I think there is a very small probability
that it's caused by HTB class/level handling (but it's possible, too),
but more probable (to me) these indexes are corrupted by something e.g.
like accessing them without proper locking.

Below I attach a patch for testing: it adds some lock debugging (plus
one place: htb_put is locked). There is mainly checking of locks
needed for writing to rbtree, but it doesn't check all readings yet,
so there will be still something to check if this patch doesn't help
to find anything.

It should be applied to 2.6.23-rc4, but if you prefer 2.6.22.5 version
let me know (BTW, I hope you let us know if you have to apply any
other patches/changes to these kernels...).

> 
> >Ok =) I hope in next week you found bug place and fix it!
> >
> >PS. if you ask where i can read "kernel panic dump logic" literature 
> >and try find bugline in code.
> >I read dump and see that bug in function "rb_insert_color" + some 
> >shift (in asm?) that called from htb_dequeue? But in htb_dequeue not 
> >have calling rb_insert_color =( Or some nodes in trace was skipped?
> >
> >Its for change up my education ;)

I didn't learn much about this, but usually objdump is enough for me.
Here are some links for kernel education:

http://kernelnewbies.org/
http://www.tux.org/lkml/
http://en.tldp.org/LDP/khg/HyperNews/get/khg.html
http://www.stardust.webpages.pl/files/handbook/tmp-en/

Regards,
Jarek P.

---

diff -Nurp linux-2.6.23-rc4-/net/sched/sch_htb.c linux-2.6.23-rc4/net/sched/sch_htb.c
--- linux-2.6.23-rc4-/net/sched/sch_htb.c	2007-08-28 19:52:25.000000000 +0200
+++ linux-2.6.23-rc4/net/sched/sch_htb.c	2007-09-02 10:34:39.000000000 +0200
@@ -52,6 +52,7 @@
     one less than their parent.
 */
 
+#define DEBUG_HTB
 #define HTB_HSIZE 16		/* classid hash size */
 #define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
@@ -127,6 +128,9 @@ struct htb_class {
 	int prio;		/* For parent to leaf return possible here */
 	int quantum;		/* we do backup. Finally full replacement  */
 				/* of un.leaf originals should be done. */
+#ifdef DEBUG_HTB
+	struct Qdisc *sch;
+#endif
 };
 
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
@@ -175,6 +179,23 @@ struct htb_sched {
 	long direct_pkts;
 };
 
+#ifdef DEBUG_HTB
+static inline int htb_queue_locked(struct htb_class *cl)
+{
+	if (cl->sch) {
+		if (!spin_is_locked(&cl->sch->dev->queue_lock) ||
+						!in_softirq()) {
+			cl->sch = NULL;
+			return 0;
+		}
+	}
+	return 1;
+}
+#define DEBUG_QUEUE_LOCKED(cl)	WARN_ON(!htb_queue_locked(cl))
+#else
+#define DEBUG_QUEUE_LOCKED(dev)	do { } while (0)
+#endif
+
 /* compute hash of size HTB_HSIZE for given handle */
 static inline int htb_hash(u32 h)
 {
@@ -280,6 +301,7 @@ static void htb_add_to_id_tree(struct rb
 {
 	struct rb_node **p = &root->rb_node, *parent = NULL;
 
+	DEBUG_QUEUE_LOCKED(cl);
 	while (*p) {
 		struct htb_class *c;
 		parent = *p;
@@ -306,6 +328,7 @@ static void htb_add_to_wait_tree(struct 
 {
 	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;
 
+	DEBUG_QUEUE_LOCKED(cl);
 	cl->pq_key = q->now + delay;
 	if (cl->pq_key == q->now)
 		cl->pq_key++;
@@ -378,6 +401,7 @@ static inline void htb_remove_class_from
 {
 	int m = 0;
 
+	DEBUG_QUEUE_LOCKED(cl);
 	while (mask) {
 		int prio = ffz(~mask);
 
@@ -438,6 +462,7 @@ static void htb_deactivate_prios(struct 
 	struct htb_class *p = cl->parent;
 	long m, mask = cl->prio_activity;
 
+	DEBUG_QUEUE_LOCKED(cl);
 	while (cl->cmode == HTB_MAY_BORROW && p && mask) {
 		m = mask;
 		mask = 0;
@@ -668,6 +693,7 @@ static void htb_charge_class(struct htb_
 	if (toks <= -cl->mbuffer) toks = 1-cl->mbuffer; \
 	cl->T = toks
 
+	DEBUG_QUEUE_LOCKED(cl);
 	while (cl) {
 		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
 		if (cl->level >= level) {
@@ -724,6 +750,7 @@ static psched_time_t htb_do_events(struc
 		if (cl->pq_key > q->now)
 			return cl->pq_key;
 
+		DEBUG_QUEUE_LOCKED(cl);
 		htb_safe_rb_erase(p, q->wait_pq + level);
 		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
 		htb_change_class_mode(q, cl, &diff);
@@ -822,6 +849,7 @@ static struct sk_buff *htb_dequeue_tree(
 	start = cl = htb_lookup_leaf(q->row[level] + prio, prio,
 				     q->ptr[level] + prio,
 				     q->last_ptr_id[level] + prio);
+	DEBUG_QUEUE_LOCKED(cl);
 
 	do {
 next:
@@ -1197,6 +1225,7 @@ static void htb_destroy_class(struct Qdi
 {
 	struct htb_sched *q = qdisc_priv(sch);
 
+	DEBUG_QUEUE_LOCKED(cl);
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
@@ -1291,8 +1320,11 @@ static void htb_put(struct Qdisc *sch, u
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
-	if (--cl->refcnt == 0)
+	if (--cl->refcnt == 0) {
+		sch_tree_lock(sch);
 		htb_destroy_class(sch, cl);
+		sch_tree_unlock(sch);
+	}
 }
 
 static int htb_change_class(struct Qdisc *sch, u32 classid,
@@ -1367,6 +1399,9 @@ static int htb_change_class(struct Qdisc
 		for (prio = 0; prio < TC_HTB_NUMPRIO; prio++)
 			RB_CLEAR_NODE(&cl->node[prio]);
 
+#ifdef DEBUG_HTB
+		cl->sch = sch;
+#endif
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
