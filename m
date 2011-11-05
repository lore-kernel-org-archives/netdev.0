From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 02/11] sch_hfsc.c: go passive after cl_vt update in update_vf()
Date: Sat,  5 Nov 2011 03:32:48 +0100
Message-ID: <1320460377-8682-3-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:6168 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab1KECdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:08 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In contrast to RT and UL curves - which are based on actual time and
can always be properly initialized, LS is based on virtual time, which
we initialize manually, in three possible ways:

1. (max + min) / 2 of active siblings (min must not be upperlimited)
2. do not adjust existing vt, if parent has the same backlog period and
   newly calculated vt is smaller
3. initialize to cumulative cvtmax of all periods

In the hfsc paper, update_vf() was not responsible for setting class
passive - it only updated linksharing related stuff. So update
chores first, passivity second (if applicable).

In one of the patches to altq, setting class passive was merged into
update_vf(), but in doing so, go_passive condition was checked /before/
vt update.

This conflicts with point (2.), as vt tested at that point doesn't
reflect the situation after the last dequeue - and we update virtual
time curve later, after updating vt itself.

It also kind of conflicts with (3.) for single-packet backlog periods,
as vt will never move to the right, but total work will keep increasing
(this is handled by rtsc_min() conditions though, so the results are
still generally valid).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 261accc..6b73725 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -776,6 +776,22 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 		if (!(cl->cl_flags & HFSC_FSC) || cl->cl_nactive == 0)
 			continue;
 
+		/* update vt */
+		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total)
+			    - cl->cl_vtoff + cl->cl_vtadj;
+
+		/*
+		 * fixup vt due to upperlimit (if applicable)
+		 *
+		 * if vt of the class is smaller than cvtmin,
+		 * the class was skipped in the past due to non-fit.
+		 * if so, we need to adjust vtadj.
+		 */
+		if (cl->cl_vt < cl->cl_parent->cl_cvtmin) {
+			cl->cl_vtadj += cl->cl_parent->cl_cvtmin - cl->cl_vt;
+			cl->cl_vt = cl->cl_parent->cl_cvtmin;
+		}
+
 		if (go_passive && --cl->cl_nactive == 0)
 			go_passive = 1;
 		else
@@ -797,25 +813,10 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 			continue;
 		}
 
-		/*
-		 * update vt and f
-		 */
-		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total)
-			    - cl->cl_vtoff + cl->cl_vtadj;
-
-		/*
-		 * if vt of the class is smaller than cvtmin,
-		 * the class was skipped in the past due to non-fit.
-		 * if so, we need to adjust vtadj.
-		 */
-		if (cl->cl_vt < cl->cl_parent->cl_cvtmin) {
-			cl->cl_vtadj += cl->cl_parent->cl_cvtmin - cl->cl_vt;
-			cl->cl_vt = cl->cl_parent->cl_cvtmin;
-		}
-
 		/* update the vt tree */
 		vttree_update(cl);
 
+		/* update ft */
 		if (cl->cl_flags & HFSC_USC) {
 			cl->cl_myf = cl->cl_myfadj + rtsc_y2x(&cl->cl_ulimit,
 							      cl->cl_total);
-- 
1.7.7.1
