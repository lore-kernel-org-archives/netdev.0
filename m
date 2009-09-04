From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 06/07: move dev_graft_qdisc() to sch_generic.c
Date: Fri,  4 Sep 2009 18:41:20 +0200 (MEST)
Message-ID: <20090904164118.27300.84490.sendpatchset@x2.localnet>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35547 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbZIDQlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:18 -0400
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7d0411697d850bcabf79bdc5bce9bf140fb317ef
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 16:12:45 2009 +0200

    net_sched: move dev_graft_qdisc() to sch_generic.c
    
    It will be used in a following patch by the multiqueue qdisc.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a48a4cc..a92dc62 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -302,6 +302,8 @@ extern void dev_init_scheduler(struct net_device *dev);
 extern void dev_shutdown(struct net_device *dev);
 extern void dev_activate(struct net_device *dev);
 extern void dev_deactivate(struct net_device *dev);
+extern struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+				     struct Qdisc *qdisc);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8aa9a0c..d71f12b 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -610,32 +610,6 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 	return i>0 ? autohandle : 0;
 }
 
-/* Attach toplevel qdisc to device queue. */
-
-static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
-				     struct Qdisc *qdisc)
-{
-	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
-	spinlock_t *root_lock;
-
-	root_lock = qdisc_lock(oqdisc);
-	spin_lock_bh(root_lock);
-
-	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
-	/* ... and graft new one */
-	if (qdisc == NULL)
-		qdisc = &noop_qdisc;
-	dev_queue->qdisc_sleeping = qdisc;
-	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
-
-	spin_unlock_bh(root_lock);
-
-	return oqdisc;
-}
-
 void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 {
 	const struct Qdisc_class_ops *cops;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a91f079..e7c47ce 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -623,6 +623,31 @@ void qdisc_destroy(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
+/* Attach toplevel qdisc to device queue. */
+struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+			      struct Qdisc *qdisc)
+{
+	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
+	spinlock_t *root_lock;
+
+	root_lock = qdisc_lock(oqdisc);
+	spin_lock_bh(root_lock);
+
+	/* Prune old scheduler */
+	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
+		qdisc_reset(oqdisc);
+
+	/* ... and graft new one */
+	if (qdisc == NULL)
+		qdisc = &noop_qdisc;
+	dev_queue->qdisc_sleeping = qdisc;
+	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
+
+	spin_unlock_bh(root_lock);
+
+	return oqdisc;
+}
+
 static void attach_one_default_qdisc(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_unused)
