From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_htb: turn intermediate classes into leaves
Date: Mon, 27 Nov 2006 08:04:02 +0100
Message-ID: <20061127070401.GA1886@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:31678 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1757134AbWK0G52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 01:57:28 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a trial to do something suggested by Patrick McHardy. 

[NET_SCHED] sch_htb:

- turn intermediate classes into leaves again when their last child is deleted
  (qdisc of deleted class is reused; struct htb_class changed)
  
- sch_tree_lock added in htb_put before htb_destroy_class
  (for consistency with htb_delete and htb_destroy) - my own suggestion

PS: qdisc_reset added to htb_delete by P. McHardy's patch: "perform qlen
adjustment immediately in ->delete" should be reconsidered.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.19-rc6-/net/sched/sch_htb.c linux-2.6.19-rc6/net/sched/sch_htb.c
--- linux-2.6.19-rc6-/net/sched/sch_htb.c	2006-11-16 20:46:08.000000000 +0100
+++ linux-2.6.19-rc6/net/sched/sch_htb.c	2006-11-26 22:54:15.000000000 +0100
@@ -147,6 +147,10 @@ struct htb_class {
 	psched_tdiff_t mbuffer;	/* max wait time */
 	long tokens, ctokens;	/* current number of tokens */
 	psched_time_t t_c;	/* checkpoint time */
+	
+	int prio;		/* For parent to leaf return possible here */
+	int quantum;		/* we do backup. Finally full replacement  */
+				/* of un.leaf originals should be done. */
 };
 
 /* TODO: maybe compute rate when size is too large .. or drop ? */
@@ -1266,6 +1270,37 @@ static void htb_destroy_filters(struct t
 	}
 }
 
+static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl)
+{
+	struct htb_class *parent = cl->parent;
+
+	if (!parent)
+		/* the root class */
+		return;
+
+	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
+
+	if (!(parent->children.next == &cl->sibling &&
+		parent->children.prev == &cl->sibling))
+		/* not the last child */
+		return;	
+
+	parent->level = 0;
+	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
+	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
+	parent->un.leaf.q = cl->un.leaf.q;
+	cl->un.leaf.q = &noop_qdisc;
+	parent->un.leaf.quantum = parent->quantum;
+	parent->un.leaf.prio = parent->prio;
+	parent->tokens = parent->buffer;
+	parent->ctokens = parent->cbuffer;
+	PSCHED_GET_TIME(parent->t_c);
+	parent->cmode = HTB_CAN_SEND;
+
+	if (parent->un.leaf.q->q.qlen)
+		htb_activate(q, parent);
+}
+
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -1337,6 +1372,9 @@ static int htb_delete(struct Qdisc *sch,
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
+	if (!cl->level)
+		htb_parent_to_leaf(q, cl);
+		
 	if (--cl->refcnt == 0)
 		htb_destroy_class(sch, cl);
 
@@ -1348,8 +1386,11 @@ static void htb_put(struct Qdisc *sch, u
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
@@ -1468,6 +1509,10 @@ static int htb_change_class(struct Qdisc
 			cl->un.leaf.quantum = hopt->quantum;
 		if ((cl->un.leaf.prio = hopt->prio) >= TC_HTB_NUMPRIO)
 			cl->un.leaf.prio = TC_HTB_NUMPRIO - 1;
+
+		/* backup for htb_parent_to_leaf */
+		cl->quantum = cl->un.leaf.quantum;
+		cl->prio = cl->un.leaf.prio;
 	}
 
 	cl->buffer = hopt->buffer;
