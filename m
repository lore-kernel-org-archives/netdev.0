From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 3/5] net/sched/sch_hfsc.c: remove leftover dlist and droplist
Date: Thu, 30 Jun 2016 02:26:46 +0200
Message-ID: <1467246408-913-4-git-send-email-soltys@ziu.info>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50044 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbcF3A1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:31 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is update to:
commit a09ceb0e08140a ("sched: remove qdisc->drop")

That commit removed qdisc->drop, but left alone dlist and droplist
that no longer serve any meaningful purpose.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e2244bb..df07f06 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -130,7 +130,6 @@ struct hfsc_class {
 	struct rb_node vt_node;		/* parent's vt_tree member */
 	struct rb_root cf_tree;		/* active children sorted by cl_f */
 	struct rb_node cf_node;		/* parent's cf_heap member */
-	struct list_head dlist;		/* drop list member */
 
 	u64	cl_total;		/* total work in bytes */
 	u64	cl_cumul;		/* cumulative work in bytes done by
@@ -177,8 +176,6 @@ struct hfsc_sched {
 	struct hfsc_class root;			/* root class */
 	struct Qdisc_class_hash clhash;		/* class hash */
 	struct rb_root eligible;		/* eligible tree */
-	struct list_head droplist;		/* active leaf class list (for
-						   dropping) */
 	struct qdisc_watchdog watchdog;		/* watchdog timer */
 };
 
@@ -858,7 +855,6 @@ set_active(struct hfsc_class *cl, unsigned int len)
 	if (cl->cl_flags & HFSC_FSC)
 		init_vf(cl, len);
 
-	list_add_tail(&cl->dlist, &cl->sched->droplist);
 }
 
 static void
@@ -867,8 +863,6 @@ set_passive(struct hfsc_class *cl)
 	if (cl->cl_flags & HFSC_RSC)
 		eltree_remove(cl);
 
-	list_del(&cl->dlist);
-
 	/*
 	 * vttree is now handled in update_vf() so that update_vf(cl, 0, 0)
 	 * needs to be called explicitly to remove a class from vttree.
@@ -1443,7 +1437,6 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	if (err < 0)
 		return err;
 	q->eligible = RB_ROOT;
-	INIT_LIST_HEAD(&q->droplist);
 
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
@@ -1527,7 +1520,6 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 			hfsc_reset_class(cl);
 	}
 	q->eligible = RB_ROOT;
-	INIT_LIST_HEAD(&q->droplist);
 	qdisc_watchdog_cancel(&q->watchdog);
 	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
-- 
2.1.3
