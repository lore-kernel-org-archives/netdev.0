From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Mon, 20 Nov 2006 14:08:48 +0100 (MET)
Message-ID: <20061120130848.22347.85130.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:12542 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965885AbWKTNIu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 08:08:50 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Fix endless loops (part 4): HTB

Convert HTB to use qdisc_tree_decrease_len() and add a callback
for deactivating a class when its child queue becomes empty.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cc6f4de81d666f76192bee629473ff6fbd66286c
tree 237aa915ea3b619fb817e719821bb0667e19eafd
parent 62ab4431af7bccd0a8cd9b1933fb03e78fd63252
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:50:11 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:50:11 +0100

 net/sched/sch_htb.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3b36e9d..215e68c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1230,11 +1230,7 @@ static int htb_graft(struct Qdisc *sch, 
 			return -ENOBUFS;
 		sch_tree_lock(sch);
 		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
-			if (cl->prio_activity)
-				htb_deactivate(qdisc_priv(sch), cl);
-
-			/* TODO: is it correct ? Why CBQ doesn't do it ? */
-			sch->q.qlen -= (*old)->q.qlen;
+			qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 			qdisc_reset(*old);
 		}
 		sch_tree_unlock(sch);
@@ -1249,6 +1245,14 @@ static struct Qdisc *htb_leaf(struct Qdi
 	return (cl && !cl->level) ? cl->un.leaf.q : NULL;
 }
 
+static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
+{
+	struct htb_class *cl = (struct htb_class *)arg;
+
+	if (cl->un.leaf.q->q.qlen == 0)
+		htb_deactivate(qdisc_priv(sch), cl);
+}
+
 static unsigned long htb_get(struct Qdisc *sch, u32 classid)
 {
 	struct htb_class *cl = htb_find(classid, sch);
@@ -1323,6 +1327,7 @@ static int htb_delete(struct Qdisc *sch,
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
+	unsigned int qlen;
 
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
@@ -1336,8 +1341,9 @@ static int htb_delete(struct Qdisc *sch,
 	hlist_del_init(&cl->hlist);
 
 	if (!cl->level) {
-		sch->q.qlen -= cl->un.leaf.q->q.qlen;
+		qlen = cl->un.leaf.q->q.qlen;
 		qdisc_reset(cl->un.leaf.q);
+		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
 	if (cl->prio_activity)
@@ -1419,8 +1425,11 @@ static int htb_change_class(struct Qdisc
 		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
+			unsigned int qlen = parent->un.leaf.q->q.qlen;
+
 			/* turn parent into inner node */
-			sch->q.qlen -= parent->un.leaf.q->q.qlen;
+			qdisc_reset(parent->un.leaf.q);
+			qdisc_tree_decrease_qlen(parent->un.leaf.q, qlen);
 			qdisc_destroy(parent->un.leaf.q);
 			if (parent->prio_activity)
 				htb_deactivate(q, parent);
@@ -1568,6 +1577,7 @@ static void htb_walk(struct Qdisc *sch, 
 static struct Qdisc_class_ops htb_class_ops = {
 	.graft		=	htb_graft,
 	.leaf		=	htb_leaf,
+	.qlen_notify	=	htb_qlen_notify,
 	.get		=	htb_get,
 	.put		=	htb_put,
 	.change		=	htb_change_class,
