From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 07/11] sch_hfsc.c: make cl_vt keep all periods in itself
Date: Sat,  5 Nov 2011 03:32:53 +0100
Message-ID: <1320460377-8682-8-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:15225 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab1KECdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:10 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, cl_vt is kept at all cost to be relative to actual backlog
period - thus we have cl_vtoff that is carefully updated to track
current "start" of vt; cl_vtmax, that keeps highest vt seen among
siblings in last backlog period; cl_cvtoff that keeps sum of all
previous cl_vtmax.

Despite that, the actual service curve is always updated from "full" vt,
and subsequent computations have vtoff part subtracted.

This is unnecessary, as vt can simply keep all vtoff values in itself -
while keeping the algorithm behaviour exactly the same.

This change allows us to remove cl_vtoff (no longer needed - part of
cl_vt now) and cl_cvtmax (no longer needed, cl_cvtoff is updated
directly from cl_vt).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |   37 ++++++++++++-------------------------
 1 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 8da2d88..ceff8a6 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -152,9 +152,8 @@ struct hfsc_class {
 					   (monotonic within a period) */
 	u64	cl_vtadj;		/* intra-period cumulative vt
 					   adjustment */
-	u64	cl_vtoff;		/* inter-period cumulative vt offset */
-	u64	cl_cvtmax;		/* max child's vt in the last period */
-	u64	cl_cvtoff;		/* cumulative cvtmax of all periods */
+	u64	cl_cvtoff;		/* last (biggest) vt seen between
+					   siblings */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
 	struct internal_sc cl_fsc;	/* internal fair service curve */
@@ -710,26 +709,17 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 			} else {
 				/*
 				 * first child for a new parent backlog period.
-				 * add parent's cvtmax to cvtoff to make a new
-				 * vt (vtoff + vt) larger than the vt in the
-				 * last period for all children.
+				 * use the biggest vt seen between siblings so far
 				 */
-				vt = cl->cl_parent->cl_cvtmax;
-				cl->cl_parent->cl_cvtoff += vt;
-				cl->cl_parent->cl_cvtmax = 0;
-				cl->cl_parent->cl_cvtmin = 0;
-				cl->cl_vt = 0;
+				cl->cl_vt = cl->cl_parent->cl_cvtoff;
+				cl->cl_parent->cl_cvtmin = cl->cl_vt;
 			}
 
-			cl->cl_vtoff = cl->cl_parent->cl_cvtoff;
-
 			/* update the virtual curve */
-			vt = cl->cl_vt + cl->cl_vtoff;
-			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, vt,
-						      cl->cl_total);
-			cl->cl_vtadj = 0;
+			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vt, cl->cl_total);
 
-			cl->cl_vtperiod++;  /* increment vt period */
+			cl->cl_vtadj = 0;
+			cl->cl_vtperiod++;
 			cl->cl_parentperiod = cl->cl_parent->cl_vtperiod;
 			if (cl->cl_parent->cl_nactive == 0)
 				cl->cl_parentperiod++;
@@ -778,8 +768,7 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 			continue;
 
 		/* update vt */
-		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total)
-			    - cl->cl_vtoff + cl->cl_vtadj;
+		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total) + cl->cl_vtadj;
 
 		/*
 		 * fixup vt due to upperlimit (if applicable)
@@ -801,9 +790,9 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 		if (go_passive) {
 			/* no more active child, going passive */
 
-			/* update cvtmax of the parent class */
-			if (cl->cl_vt > cl->cl_parent->cl_cvtmax)
-				cl->cl_parent->cl_cvtmax = cl->cl_vt;
+			/* update cl_cvtoff of the parent class */
+			if (cl->cl_vt > cl->cl_parent->cl_cvtoff)
+				cl->cl_parent->cl_cvtoff = cl->cl_vt;
 
 			/* remove this class from the vt tree */
 			vttree_remove(cl);
@@ -1507,9 +1496,7 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_e            = 0;
 	cl->cl_vt           = 0;
 	cl->cl_vtadj        = 0;
-	cl->cl_vtoff        = 0;
 	cl->cl_cvtmin       = 0;
-	cl->cl_cvtmax       = 0;
 	cl->cl_cvtoff       = 0;
 	cl->cl_vtperiod     = 0;
 	cl->cl_parentperiod = 0;
-- 
1.7.7.1
