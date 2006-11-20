From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen counters (part 1)
Date: Mon, 20 Nov 2006 14:08:41 +0100 (MET)
Message-ID: <20061120130840.22347.54563.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:9470 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965843AbWKTNIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 08:08:43 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Fix endless loops caused by inaccurate qlen counters (part 1)

There are multiple problems related to qlen adjustment that can lead
to an upper qdisc getting out of sync with the real number of packets
queued, leading to endless dequeueing attempts by the upper layer code.

All qdiscs must maintain an accurate q.qlen counter. There are basically
two groups of operations affecting the qlen: operations that propagate
down the tree (enqueue, dequeue, requeue, drop, reset) beginning at the
root qdisc and operations only affecting a subtree or single qdisc
(change, graft, delete class). Since qlen changes during operations from
the second group don't propagate to ancestor qdiscs, their qlen values
become desynchronized.

This patch adds a function to propagate qlen changes up the qdisc tree,
optionally calling a callback function to perform qdisc-internal
maintenance when the child qdisc becomes empty. The follow-up patches
will convert all qdiscs to use this function where necessary.

Noticed by Timo Steinbach <tsteinbach@astaro.com>.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 42706d154c660ac3915cc0debcfa09339af29de3
tree 26dd1060dcfd2d0633d63297bb4f988d5f6c8ea8
parent 825dfe1f03e69f3c2b56e6bd6ceea7ffe23c65bf
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:44:49 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:44:49 +0100

 include/net/sch_generic.h |    2 ++
 net/sched/sch_api.c       |   38 ++++++++++++++++++++++++++++++++------
 2 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 660ff0a..d61fb67 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -60,6 +60,7 @@ struct Qdisc_class_ops
 	int			(*graft)(struct Qdisc *, unsigned long cl,
 					struct Qdisc *, struct Qdisc **);
 	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
+	void			(*qlen_notify)(struct Qdisc *, unsigned long);
 
 	/* Class manipulation routines */
 	unsigned long		(*get)(struct Qdisc *, u32 classid);
@@ -172,6 +173,7 @@ extern void dev_activate(struct net_devi
 extern void dev_deactivate(struct net_device *dev);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
+extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
 extern struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct Qdisc_ops *ops, u32 parentid);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 0b64892..1c3c779 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -191,21 +191,27 @@ int unregister_qdisc(struct Qdisc_ops *q
    (root qdisc, all its children, children of children etc.)
  */
 
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
+static struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	struct Qdisc *q;
 
-	read_lock(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
-		if (q->handle == handle) {
-			read_unlock(&qdisc_tree_lock);
+		if (q->handle == handle)
 			return q;
-		}
 	}
-	read_unlock(&qdisc_tree_lock);
 	return NULL;
 }
 
+struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
+{
+	struct Qdisc *q;
+
+	read_lock(&qdisc_tree_lock);
+	q = __qdisc_lookup(dev, handle);
+	read_unlock(&qdisc_tree_lock);
+	return q;
+}
+
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 {
 	unsigned long cl;
@@ -348,6 +354,26 @@ dev_graft_qdisc(struct net_device *dev, 
 	return oqdisc;
 }
 
+void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
+{
+	struct Qdisc_class_ops *cops;
+	unsigned long cl;
+	u32 parentid;
+
+	if (n == 0)
+		return;
+	while ((parentid = sch->parent)) {
+		sch = __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		cops = sch->ops->cl_ops;
+		if (cops->qlen_notify) {
+			cl = cops->get(sch, parentid);
+			cops->qlen_notify(sch, cl);
+			cops->put(sch, cl);
+		}
+		sch->q.qlen -= n;
+	}
+}
+EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
 /* Graft qdisc "new" to class "classid" of qdisc "parent" or
    to device "dev".
