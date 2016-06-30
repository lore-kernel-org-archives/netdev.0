From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 4/5] net/sched/sch_hfsc.c: go passive after vt update
Date: Thu, 30 Jun 2016 02:26:47 +0200
Message-ID: <1467246408-913-5-git-send-email-soltys@ziu.info>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50043 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbcF3A1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:31 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a class is going passive, it should update its cl_vt first
to be consistent with the last dequeue operation.

Otherwise its cl_vt will be one packet behind and parent's cvtmax might
not be updated as well.

One possible side effect is if some class goes passive and subsequently
goes active /without/ its parent going passive - with cl_vt lagging one
packet behind - comparison made in init_vf() will be affected (same
period).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index df07f06..4eef857 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -778,6 +778,20 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 		else
 			go_passive = 0;
 
+		/* update vt */
+		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total)
+			    - cl->cl_vtoff + cl->cl_vtadj;
+
+		/*
+		 * if vt of the class is smaller than cvtmin,
+		 * the class was skipped in the past due to non-fit.
+		 * if so, we need to adjust vtadj.
+		 */
+		if (cl->cl_vt < cl->cl_parent->cl_cvtmin) {
+			cl->cl_vtadj += cl->cl_parent->cl_cvtmin - cl->cl_vt;
+			cl->cl_vt = cl->cl_parent->cl_cvtmin;
+		}
+
 		if (go_passive) {
 			/* no more active child, going passive */
 
@@ -794,25 +808,10 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
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
 
+		/* update f */
 		if (cl->cl_flags & HFSC_USC) {
 			cl->cl_myf = cl->cl_myfadj + rtsc_y2x(&cl->cl_ulimit,
 							      cl->cl_total);
-- 
2.1.3
