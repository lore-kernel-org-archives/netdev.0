From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/3] pkt_sched: sch_htb: Clean htb_class prio and quantum
	fields
Date: Tue, 2 Dec 2008 08:56:48 +0000
Message-ID: <20081202085648.GC10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:23651 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbYLBI4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:56:54 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1228579eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 00:56:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While implementing htb_parent_to_leaf() there where added backup prio
and quantum struct htb_class fields to preserve these values for inner
classes in case of their return to leaf. This patch cleans this a bit
by removing union leaf duplicates.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |   41 ++++++++++++++++-------------------------
 1 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 7a71e94..80cb94d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -84,11 +84,12 @@ struct htb_class {
 	unsigned int children;
 	struct htb_class *parent;	/* parent class */
 
+	int prio;		/* these two are used only by leaves... */
+	int quantum;		/* but stored for parent-to-leaf return */
+
 	union {
 		struct htb_class_leaf {
 			struct Qdisc *q;
-			int prio;
-			int quantum;
 			int deficit[TC_HTB_MAXDEPTH];
 			struct list_head drop_list;
 		} leaf;
@@ -122,10 +123,6 @@ struct htb_class {
 	psched_tdiff_t mbuffer;	/* max wait time */
 	long tokens, ctokens;	/* current number of tokens */
 	psched_time_t t_c;	/* checkpoint time */
-
-	int prio;		/* For parent to leaf return possible here */
-	int quantum;		/* we do backup. Finally full replacement  */
-				/* of un.leaf originals should be done. */
 };
 
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
@@ -523,10 +520,10 @@ static inline void htb_activate(struct htb_sched *q, struct htb_class *cl)
 	WARN_ON(cl->level || !cl->un.leaf.q || !cl->un.leaf.q->q.qlen);
 
 	if (!cl->prio_activity) {
-		cl->prio_activity = 1 << cl->un.leaf.prio;
+		cl->prio_activity = 1 << cl->prio;
 		htb_activate_prios(q, cl);
 		list_add_tail(&cl->un.leaf.drop_list,
-			      q->drops + cl->un.leaf.prio);
+			      q->drops + cl->prio);
 	}
 }
 
@@ -816,7 +813,7 @@ next:
 	if (likely(skb != NULL)) {
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
-			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
+			cl->un.leaf.deficit[level] += cl->quantum;
 			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 					  ptr[0]) + prio);
 		}
@@ -1050,8 +1047,8 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	opt.buffer = cl->buffer;
 	opt.ceil = cl->ceil->rate;
 	opt.cbuffer = cl->cbuffer;
-	opt.quantum = cl->un.leaf.quantum;
-	opt.prio = cl->un.leaf.prio;
+	opt.quantum = cl->quantum;
+	opt.prio = cl->prio;
 	opt.level = cl->level;
 	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 
@@ -1155,8 +1152,6 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
 	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
 	parent->un.leaf.q = new_q ? new_q : &noop_qdisc;
-	parent->un.leaf.quantum = parent->quantum;
-	parent->un.leaf.prio = parent->prio;
 	parent->tokens = parent->buffer;
 	parent->ctokens = parent->cbuffer;
 	parent->t_c = psched_get_time();
@@ -1400,27 +1395,23 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	/* it used to be a nasty bug here, we have to check that node
 	   is really leaf before changing cl->un.leaf ! */
 	if (!cl->level) {
-		cl->un.leaf.quantum = rtab->rate.rate / q->rate2quantum;
-		if (!hopt->quantum && cl->un.leaf.quantum < 1000) {
+		cl->quantum = rtab->rate.rate / q->rate2quantum;
+		if (!hopt->quantum && cl->quantum < 1000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
 			       cl->common.classid);
-			cl->un.leaf.quantum = 1000;
+			cl->quantum = 1000;
 		}
-		if (!hopt->quantum && cl->un.leaf.quantum > 200000) {
+		if (!hopt->quantum && cl->quantum > 200000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is big. Consider r2q change.\n",
 			       cl->common.classid);
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
-- 
1.5.6.5

