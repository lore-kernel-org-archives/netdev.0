From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 06/06: sch_htb: remove child and sibling lists
Date: Thu,  3 Jul 2008 17:16:09 +0200 (MEST)
Message-ID: <20080703151608.26225.74393.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40238 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbYGCPQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:11 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: sch_htb: remove child and sibling lists

Now that the qdisc isn't destroyed in hierarchical order anymore,
the only user of the child lists left is htb_parent_last_child().
This can be easily changed to use a counter of children to save
a few bytes.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b65c685ee892935858c9c2ec6cce8d3ca3022b27
tree 119adf6a4c6755fffcf9def44c6e16a633535b5e
parent e56e921c9ece0bd6f4201910292468f9c0e8f4de
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:47 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:47 +0200

 net/sched/sch_htb.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index e7461a1..128a5ab 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -81,9 +81,8 @@ struct htb_class {
 
 	/* topology */
 	int level;		/* our level (see above) */
+	unsigned int children;
 	struct htb_class *parent;	/* parent class */
-	struct list_head sibling;	/* sibling list item */
-	struct list_head children;	/* children list */
 
 	union {
 		struct htb_class_leaf {
@@ -138,7 +137,6 @@ static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 }
 
 struct htb_sched {
-	struct list_head root;	/* root classes list */
 	struct Qdisc_class_hash clhash;
 	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
@@ -1020,7 +1018,6 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 		return -EINVAL;
 	}
 
-	INIT_LIST_HEAD(&q->root);
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
 		return err;
@@ -1175,12 +1172,9 @@ static inline int htb_parent_last_child(struct htb_class *cl)
 	if (!cl->parent)
 		/* the root class */
 		return 0;
-
-	if (!(cl->parent->children.next == &cl->sibling &&
-		cl->parent->children.prev == &cl->sibling))
+	if (cl->parent->children > 1)
 		/* not the last child */
 		return 0;
-
 	return 1;
 }
 
@@ -1259,7 +1253,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
 	// refs so that we can remove children safely there ?
-	if (!list_empty(&cl->children) || cl->filter_cnt)
+	if (cl->children || cl->filter_cnt)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
@@ -1278,7 +1272,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	/* delete from hash and active; remainder in destroy_class */
 	qdisc_class_hash_remove(&q->clhash, &cl->common);
-	list_del(&cl->sibling);
+	cl->parent->children--;
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
@@ -1373,8 +1367,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 				  &sch->dev->queue_lock,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
-		INIT_LIST_HEAD(&cl->sibling);
-		INIT_LIST_HEAD(&cl->children);
+		cl->children = 0;
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 		RB_CLEAR_NODE(&cl->pq_node);
 
@@ -1420,8 +1413,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 		/* attach to the hash list and parent's family */
 		qdisc_class_hash_insert(&q->clhash, &cl->common);
-		list_add_tail(&cl->sibling,
-			      parent ? &parent->children : &q->root);
+		if (parent)
+			parent->children++;
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
