From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 11/11] sch_hfsc.c: remove cl_vtadj, shift virtual curve instead
Date: Sat,  5 Nov 2011 03:32:57 +0100
Message-ID: <1320460377-8682-12-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:4061 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab1KECdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:13 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of keeping intra-period difference, we can simply shift
the virtual curve to the right (as the adjustment is permanent).
---
 net/sched/sch_hfsc.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 2109878..bf38551 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -151,8 +151,6 @@ struct hfsc_class {
 	u64	cl_cvtmin;		/* minimal virtual time among the
 					   children fit for link-sharing
 					   (monotonic within a period) */
-	u64	cl_vtadj;		/* intra-period cumulative vt
-					   adjustment */
 	u64	cl_cvtoff;		/* last (biggest) vt seen between
 					   siblings */
 
@@ -764,7 +762,6 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 			/* update the virtual curve */
 			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vt, cl->cl_total);
 
-			cl->cl_vtadj = 0;
 			cl->cl_vtperiod++;
 			cl->cl_parentperiod = cl->cl_parent->cl_vtperiod;
 			if (cl->cl_parent->cl_nactive == 0)
@@ -810,17 +807,19 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 			continue;
 
 		/* update vt */
-		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total) + cl->cl_vtadj;
+		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total);
 
 		/*
 		 * fixup vt due to upperlimit (if applicable)
 		 *
-		 * if vt of the class is smaller than cvtmin,
-		 * the class was skipped in the past due to non-fit.
-		 * if so, we need to adjust vtadj.
+		 * if we detect we're lagging past virtual times of other siblings,
+		 * that means we were skipped in the past due to non-fit.
+		 *
+		 * If so we adjust vt and shift virtual curve to match current
+		 * situation.
 		 */
 		if (cl->cl_vt < cl->cl_parent->cl_cvtmin) {
-			cl->cl_vtadj += cl->cl_parent->cl_cvtmin - cl->cl_vt;
+			cl->cl_virtual.x += cl->cl_parent->cl_cvtmin - cl->cl_vt;
 			cl->cl_vt = cl->cl_parent->cl_cvtmin;
 		}
 
@@ -1527,7 +1526,6 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_d            = 0;
 	cl->cl_e            = 0;
 	cl->cl_vt           = 0;
-	cl->cl_vtadj        = 0;
 	cl->cl_cvtmin       = 0;
 	cl->cl_cvtoff       = 0;
 	cl->cl_vtperiod     = 0;
-- 
1.7.7.1
