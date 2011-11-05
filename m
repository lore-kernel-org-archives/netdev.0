From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 09/11] sch_hfsc.c: split update_vf()
Date: Sat,  5 Nov 2011 03:32:55 +0100
Message-ID: <1320460377-8682-10-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:2710 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603Ab1KECdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:11 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split update_vf() into 2 spearate functions, one responsible for just
updating the vt, and the other responsible for setting the class [and
possibly parent nodes] passive.

This is actually how it was once done in the past, but at some point it
was merged into one larger function.

Two functions are shorter and cleaner, and during normal update_vf() it
has a bit less work to do.
---
 net/sched/sch_hfsc.c |   51 +++++++++++++++++--------------------------------
 1 files changed, 18 insertions(+), 33 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e73d2e0..26cdfaa 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -800,15 +800,11 @@ static void
 update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 {
 	u64 f; /* , myf_bound, delta; */
-	int go_passive = 0;
-
-	if (cl->qdisc->q.qlen == 0 && cl->cl_flags & HFSC_FSC)
-		go_passive = 1;
 
 	for (; cl->cl_parent != NULL; cl = cl->cl_parent) {
 		cl->cl_total += len;
 
-		if (!(cl->cl_flags & HFSC_FSC) || cl->cl_nactive == 0)
+		if (!(cl->cl_flags & HFSC_FSC))
 			continue;
 
 		/* update vt */
@@ -826,27 +822,6 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 			cl->cl_vt = cl->cl_parent->cl_cvtmin;
 		}
 
-		if (go_passive && --cl->cl_nactive == 0)
-			go_passive = 1;
-		else
-			go_passive = 0;
-
-		if (go_passive) {
-			/* no more active child, going passive */
-
-			/* update cl_cvtoff of the parent class */
-			if (cl->cl_vt > cl->cl_parent->cl_cvtoff)
-				cl->cl_parent->cl_cvtoff = cl->cl_vt;
-
-			/* remove this class from the vt tree */
-			vttree_remove(cl);
-
-			cftree_remove(cl);
-			update_cfmin(cl->cl_parent);
-
-			continue;
-		}
-
 		/* update the vt tree */
 		vttree_update(cl);
 
@@ -899,15 +874,27 @@ set_active(struct hfsc_class *cl, unsigned int len)
 static void
 set_passive(struct hfsc_class *cl)
 {
+	list_del(&cl->dlist);
+
 	if (cl->cl_flags & HFSC_RSC)
 		eltree_remove(cl);
 
-	list_del(&cl->dlist);
+	if (cl->cl_flags & HFSC_FSC)
+	for (; cl->cl_parent != NULL; cl = cl->cl_parent) {
+		if (--cl->cl_nactive > 0)
+			break;
 
-	/*
-	 * vttree is now handled in update_vf() so that update_vf(cl, 0, 0)
-	 * needs to be called explicitly to remove a class from vttree.
-	 */
+		/* update cl_cvtoff of the parent class */
+		if (cl->cl_vt > cl->cl_parent->cl_cvtoff)
+			cl->cl_parent->cl_cvtoff = cl->cl_vt;
+
+		/* remove this class from the parent's vt & cf trees */
+		vttree_remove(cl);
+		cftree_remove(cl);
+
+		/* update cfmin of the parent, after removal */
+		update_cfmin(cl->cl_parent);
+	}
 }
 
 static unsigned int
@@ -1286,7 +1273,6 @@ hfsc_qlen_notify(struct Qdisc *sch, unsigned long arg)
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
 	if (cl->qdisc->q.qlen == 0) {
-		update_vf(cl, 0, 0);
 		set_passive(cl);
 	}
 }
@@ -1729,7 +1715,6 @@ hfsc_drop(struct Qdisc *sch)
 		if (cl->qdisc->ops->drop != NULL &&
 		    (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
 			if (cl->qdisc->q.qlen == 0) {
-				update_vf(cl, 0, 0);
 				set_passive(cl);
 			} else {
 				list_move_tail(&cl->dlist, &q->droplist);
-- 
1.7.7.1
