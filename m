From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 06/11] sch_hfsc.c: seg_y2x(), rtsc_y2x(), hfsc_change_class() minor changes
Date: Sat,  5 Nov 2011 03:32:52 +0100
Message-ID: <1320460377-8682-7-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:2710 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab1KECdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:10 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hfsc_change_class():

Make sure that invalid input (flat 2nd segment, USC without FSC) is not
allowed. Even though userspace (tc) does the respective checks as well - we
want to verify if everything is in order before the following seg_y2x() change
(and some other userspace tools not doing such checks might exist):

seg_y2x():

All callers (actually there's only one - rtsc_y2x()) guarantee that the
slope argument actually makese sense (otherwise the results would be
unusable) - so we don't heave to check for +inf case.

rtsc_y2x():

In case of flat 1st segment of a service curve, the function always
returns maximum a, such that f(a) = y (for our curves then, a = x + dx).
To keep things consistent (and continuous), we also return x+dx for
values < y.
---
 net/sched/sch_hfsc.c |   39 +++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e0cf11b..8da2d88 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -400,6 +400,8 @@ seg_y2x(u64 y, u64 ism)
 {
 	u64 x;
 
+	/* callers guarantee that ism is not infinity */
+#if 0
 	if (y == 0)
 		x = 0;
 	else if (ism == HT_INFINITY)
@@ -408,6 +410,8 @@ seg_y2x(u64 y, u64 ism)
 		x = (y >> ISM_SHIFT) * ism
 		    + (((y & ISM_MASK) * ism) >> ISM_SHIFT);
 	}
+#endif
+	x = (y >> ISM_SHIFT) * ism + (((y & ISM_MASK) * ism) >> ISM_SHIFT);
 	return x;
 }
 
@@ -509,7 +513,7 @@ rtsc_y2x(struct runtime_sc *rtsc, u64 y)
 {
 	u64 x;
 
-	if (y < rtsc->y)
+	if (y < rtsc->y && rtsc->dy != 0)
 		x = rtsc->x;
 	else if (y <= rtsc->y + rtsc->dy) {
 		/* x belongs to the 1st segment */
@@ -985,22 +989,40 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tb[TCA_HFSC_RSC]) {
 		rsc = nla_data(tb[TCA_HFSC_RSC]);
-		if (rsc->m1 == 0 && rsc->m2 == 0)
-			rsc = NULL;
+		if (rsc->m2 == 0) {
+			if (rsc->m1 != 0)
+				return -EINVAL;
+			else
+				rsc = NULL;
+		}
 	}
 
 	if (tb[TCA_HFSC_FSC]) {
 		fsc = nla_data(tb[TCA_HFSC_FSC]);
-		if (fsc->m1 == 0 && fsc->m2 == 0)
-			fsc = NULL;
+		if (fsc->m2 == 0) {
+			if (fsc->m1 != 0)
+				return -EINVAL;
+			else
+				fsc = NULL;
+		}
 	}
 
 	if (tb[TCA_HFSC_USC]) {
 		usc = nla_data(tb[TCA_HFSC_USC]);
-		if (usc->m1 == 0 && usc->m2 == 0)
-			usc = NULL;
+		if (usc->m2 == 0) {
+			if (usc->m1 != 0)
+				return -EINVAL;
+			else
+				usc = NULL;
+		}
 	}
 
+	if (rsc == NULL && fsc == NULL)
+		return -EINVAL;
+
+	if (fsc == NULL && usc != NULL)
+		return -EINVAL;
+
 	if (cl != NULL) {
 		if (parentid) {
 			if (cl->cl_parent &&
@@ -1053,9 +1075,6 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (hfsc_find_class(classid, sch))
 		return -EEXIST;
 
-	if (rsc == NULL && fsc == NULL)
-		return -EINVAL;
-
 	cl = kzalloc(sizeof(struct hfsc_class), GFP_KERNEL);
 	if (cl == NULL)
 		return -ENOBUFS;
-- 
1.7.7.1
