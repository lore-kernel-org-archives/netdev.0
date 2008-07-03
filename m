From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 04/06: sch_htb: move hash and sibling list removal to htb_delete
Date: Thu,  3 Jul 2008 17:16:06 +0200 (MEST)
Message-ID: <20080703151606.26225.61647.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40232 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbYGCPQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:08 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_htb: move hash and sibling list removal to htb_delete

Hash list removal currently happens twice (once in htb_delete, once
in htb_destroy_class), which makes it harder to use the dynamically
sized class hash without adding special cases for HTB. The reason is
that qdisc destruction destroys classes in hierarchical order, which
is not necessary if filters are destroyed in a separate iteration
during qdisc destruction.

Adjust qdisc destruction to follow the same scheme as other hierarchical
qdiscs by first performing a filter destruction pass, then destroying
all classes in hash order.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3fcfd66ab1737d4bcb2158866d7b2b574b0099bf
tree 9146a96a6353464ef6a42706ad5bc4a7c8ce92d2
parent 7ce0dc13a43a80bcce1dc862f35fddc9740aaf27
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:46 +0200

 net/sched/sch_htb.c |   40 +++++++++++++++++-----------------------
 1 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0284791..d01fe3a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1226,8 +1226,6 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
-	struct htb_sched *q = qdisc_priv(sch);
-
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
@@ -1237,21 +1235,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 	qdisc_put_rtab(cl->ceil);
 
 	tcf_destroy_chain(&cl->filter_list);
-
-	while (!list_empty(&cl->children))
-		htb_destroy_class(sch, list_entry(cl->children.next,
-						  struct htb_class, sibling));
-
-	/* note: this delete may happen twice (see htb_delete) */
-	hlist_del_init(&cl->hlist);
-	list_del(&cl->sibling);
-
-	if (cl->prio_activity)
-		htb_deactivate(q, cl);
-
-	if (cl->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
-
 	kfree(cl);
 }
 
@@ -1259,6 +1242,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+	struct hlist_node *n, *next;
+	struct htb_class *cl;
+	unsigned int i;
 
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
@@ -1267,10 +1253,14 @@ static void htb_destroy(struct Qdisc *sch)
 	   unbind_filter on it (without Oops). */
 	tcf_destroy_chain(&q->filter_list);
 
-	while (!list_empty(&q->root))
-		htb_destroy_class(sch, list_entry(q->root.next,
-						  struct htb_class, sibling));
-
+	for (i = 0; i < HTB_HSIZE; i++) {
+		hlist_for_each_entry(cl, n, q->hash + i, hlist)
+			tcf_destroy_chain(&cl->filter_list);
+	}
+	for (i = 0; i < HTB_HSIZE; i++) {
+		hlist_for_each_entry_safe(cl, n, next, q->hash + i, hlist)
+			htb_destroy_class(sch, cl);
+	}
 	__skb_queue_purge(&q->direct_queue);
 }
 
@@ -1302,12 +1292,16 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
+	/* delete from hash, sibling list and active */
+	hlist_del(&cl->hlist);
+	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
+	if (cl->cmode != HTB_CAN_SEND)
+		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+
 	if (last_child)
 		htb_parent_to_leaf(q, cl, new_q);
 
