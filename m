From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_htb: turn intermediate classes into leaves
Date: Tue, 28 Nov 2006 07:39:48 +0100
Message-ID: <20061128063948.GA1818@ff.dom.local>
References: <20061127070401.GA1886@ff.dom.local> <456ABA07.1010508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:62912 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S935663AbWK1GdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 01:33:12 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <456ABA07.1010508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED] sch_htb:

[PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]

- turn intermediate classes into leaves again when their
  last child is deleted (struct htb_class changed)


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.19-rc6-endless-/net/sched/sch_htb.c linux-2.6.19-rc6-endless/net/sched/sch_htb.c
--- linux-2.6.19-rc6-endless-/net/sched/sch_htb.c	2006-11-27 18:40:30.000000000 +0100
+++ linux-2.6.19-rc6-endless/net/sched/sch_htb.c	2006-11-27 20:27:52.000000000 +0100
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
@@ -1271,6 +1275,38 @@ static void htb_destroy_filters(struct t
 	}
 }
 
+static inline int htb_parent_last_child(struct htb_class *cl)
+{
+	if (!cl->parent)
+		/* the root class */
+		return 0;
+
+	if (!(cl->parent->children.next == &cl->sibling &&
+		cl->parent->children.prev == &cl->sibling))
+		/* not the last child */
+		return 0;	
+
+	return 1;
+}
+
+static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
+{
+	struct htb_class *parent = cl->parent;
+
+	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
+
+	parent->level = 0;
+	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
+	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
+	parent->un.leaf.q = new_q ? new_q : &noop_qdisc;
+	parent->un.leaf.quantum = parent->quantum;
+	parent->un.leaf.prio = parent->prio;
+	parent->tokens = parent->buffer;
+	parent->ctokens = parent->cbuffer;
+	PSCHED_GET_TIME(parent->t_c);
+	parent->cmode = HTB_CAN_SEND;
+}
+
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -1328,6 +1364,8 @@ static int htb_delete(struct Qdisc *sch,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 	unsigned int qlen;
+	struct Qdisc *new_q = NULL;
+	int last_child = 0;
 
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
@@ -1335,6 +1373,12 @@ static int htb_delete(struct Qdisc *sch,
 	if (!list_empty(&cl->children) || cl->filter_cnt)
 		return -EBUSY;
 
+	if (!cl->level && htb_parent_last_child(cl)) {
+		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+						cl->parent->classid);
+		last_child = 1;
+	}
+
 	sch_tree_lock(sch);
 
 	/* delete from hash and active; remainder in destroy_class */
@@ -1349,6 +1393,9 @@ static int htb_delete(struct Qdisc *sch,
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
+	if (last_child)
+		htb_parent_to_leaf(cl, new_q);
+		
 	if (--cl->refcnt == 0)
 		htb_destroy_class(sch, cl);
 
@@ -1483,6 +1530,10 @@ static int htb_change_class(struct Qdisc
 			cl->un.leaf.quantum = hopt->quantum;
 		if ((cl->un.leaf.prio = hopt->prio) >= TC_HTB_NUMPRIO)
 			cl->un.leaf.prio = TC_HTB_NUMPRIO - 1;
+
+		/* backup for htb_parent_to_leaf */
+		cl->quantum = cl->un.leaf.quantum;
+		cl->prio = cl->un.leaf.prio;
 	}
 
 	cl->buffer = hopt->buffer;
