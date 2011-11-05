From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 10/11] sch_hfsc.c: make sure classes are able to use 1st segment on fresh backlog period
Date: Sat,  5 Nov 2011 03:32:56 +0100
Message-ID: <1320460377-8682-11-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:15225 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753635Ab1KECdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:12 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change guarantees, that when a class starts fresh backlog period,
it will be able to use its 1st segment for subsequent vt update.
---
 net/sched/sch_hfsc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 26cdfaa..2109878 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -88,6 +88,7 @@ struct internal_sc {
 	u64	dy;	/* the y-projection of the 1st segment */
 	u64	sm2;	/* scaled slope of the 2nd segment */
 	u64	ism2;	/* scaled inverse-slope of the 2nd segment */
+	u64	i2dy;	/* x-projection of dy, using 2nd slope */
 };
 
 /* runtime service curve */
@@ -531,6 +532,7 @@ sc2isc(struct tc_service_curve *sc, struct internal_sc *isc)
 	isc->dy   = seg_x2y(isc->dx, isc->sm1);
 	isc->sm2  = m2sm(sc->m2);
 	isc->ism2 = m2ism(sc->m2);
+	isc->i2dy = seg_y2x(isc->dy, isc->ism2);
 }
 
 /*
@@ -885,8 +887,8 @@ set_passive(struct hfsc_class *cl)
 			break;
 
 		/* update cl_cvtoff of the parent class */
-		if (cl->cl_vt > cl->cl_parent->cl_cvtoff)
-			cl->cl_parent->cl_cvtoff = cl->cl_vt;
+		if (cl->cl_vt + cl->cl_fsc.i2dy > cl->cl_parent->cl_cvtoff)
+			cl->cl_parent->cl_cvtoff = cl->cl_vt + cl->cl_fsc.i2dy;
 
 		/* remove this class from the parent's vt & cf trees */
 		vttree_remove(cl);
-- 
1.7.7.1
