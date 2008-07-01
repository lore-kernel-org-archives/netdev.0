From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 04/05: sch_htb: move hash and sibling list removal to htb_delete
Date: Tue,  1 Jul 2008 16:34:16 +0200 (MEST)
Message-ID: <20080701143415.26309.95825.sendpatchset@localhost.localdomain>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39064 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757403AbYGAOeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 10:34:17 -0400
In-Reply-To: <20080701143410.26309.45560.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_htb: move hash and sibling list removal to htb_delete

Hash list removal currently happens twice (once in htb_delete, once
in htb_destroy_class), which makes it harder to use the dynamically
sized class hash without adding special cases for HTB. The reason is
that qdisc destruction destroys class in hierarchical order, which
is not necessary if filters are destroyed in a seperate iteration
during qdisc destruction.

Adjust qdisc destruction to follow the same scheme as other hierarchical
qdiscs by first performing a filter destruction pass, then destroying
all classes in hash order.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9f2a43febc3ce5413407769c4f5fe3a36b713386
tree 7d0b8be1f29d8167635b67ecd5cb1e392b7e19a7
parent 1c1dd74775cc105566840b020475186ee321e6ec
author Patrick McHardy <kaber@trash.net> Tue, 01 Jul 2008 16:01:24 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 01 Jul 2008 16:01:24 +0200

 net/sched/sch_htb.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0284791..879f0b6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1238,14 +1238,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 
 	tcf_destroy_chain(&cl->filter_list);
 
-	while (!list_empty(&cl->children))
-		htb_destroy_class(sch, list_entry(cl->children.next,
-						  struct htb_class, sibling));
-
-	/* note: this delete may happen twice (see htb_delete) */
-	hlist_del_init(&cl->hlist);
-	list_del(&cl->sibling);
-
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
@@ -1259,6 +1251,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+	struct hlist_node *n, *next;
+	struct htb_class *cl;
+	unsigned int i;
 
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
@@ -1267,10 +1262,14 @@ static void htb_destroy(struct Qdisc *sch)
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
 
@@ -1302,8 +1301,9 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
+	/* delete from hash, sibling list and active */
+	hlist_del(&cl->hlist);
+	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
