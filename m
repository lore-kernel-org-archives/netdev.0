From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 05/11] sch_hfsc.c: don't subtract from cl_vtoff and cl_cvtoff
Date: Sat,  5 Nov 2011 03:32:51 +0100
Message-ID: <1320460377-8682-6-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:16183 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab1KECdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:09 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using pcvtoff to keep vtoff as close to 0 as possible is not necessary. All
curves (based on real or virtual time) use the same mechanics, and real time
based ones are obviously not even allowed anything like that.

This might be some leftover from earlier hfsc versions (or perhaps versions
[that are/were ?] limited to 32 bit values only, where such thing would help a
bit against hitting overflow ... though what about RSC/USC ?).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 97d720c..e0cf11b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -155,8 +155,6 @@ struct hfsc_class {
 	u64	cl_vtoff;		/* inter-period cumulative vt offset */
 	u64	cl_cvtmax;		/* max child's vt in the last period */
 	u64	cl_cvtoff;		/* cumulative cvtmax of all periods */
-	u64	cl_pcvtoff;		/* parent's cvtoff at initialization
-					   time */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
 	struct internal_sc cl_fsc;	/* internal fair service curve */
@@ -719,17 +717,12 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 				cl->cl_vt = 0;
 			}
 
-			cl->cl_vtoff = cl->cl_parent->cl_cvtoff -
-							cl->cl_pcvtoff;
+			cl->cl_vtoff = cl->cl_parent->cl_cvtoff;
 
 			/* update the virtual curve */
 			vt = cl->cl_vt + cl->cl_vtoff;
 			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, vt,
 						      cl->cl_total);
-			if (cl->cl_virtual.x == vt) {
-				cl->cl_virtual.x -= cl->cl_vtoff;
-				cl->cl_vtoff = 0;
-			}
 			cl->cl_vtadj = 0;
 
 			cl->cl_vtperiod++;  /* increment vt period */
@@ -1102,7 +1095,6 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (parent->level == 0)
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
-	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_grow(sch, &q->clhash);
@@ -1500,7 +1492,6 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_cvtmin       = 0;
 	cl->cl_cvtmax       = 0;
 	cl->cl_cvtoff       = 0;
-	cl->cl_pcvtoff      = 0;
 	cl->cl_vtperiod     = 0;
 	cl->cl_parentperiod = 0;
 	cl->cl_f            = 0;
-- 
1.7.7.1
