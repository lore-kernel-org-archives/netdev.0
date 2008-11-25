From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] tc: check for errors from gen_replace_estimator
Date: Tue, 25 Nov 2008 10:16:56 -0800
Message-ID: <20081125101656.52348bdd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47118 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbYKYSVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:21:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gen_replace_estimator can return errors, but they were being ignored.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/act_police.c	2008-11-25 10:02:05.000000000 -0800
+++ b/net/sched/act_police.c	2008-11-25 10:15:50.000000000 -0800
@@ -185,14 +185,21 @@ override:
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
 					       tb[TCA_POLICE_PEAKRATE]);
-			if (P_tab == NULL) {
-				qdisc_put_rtab(R_tab);
+			if (P_tab == NULL)
 				goto failure;
-			}
 		}
 	}
-	/* No failure allowed after this point */
+
 	spin_lock_bh(&police->tcf_lock);
+	if (est) {
+		err = gen_replace_estimator(&police->tcf_bstats,
+					    &police->tcf_rate_est,
+					    &police->tcf_lock, est);
+		if (err)
+			goto failure_unlock;
+	}
+
+	/* No failure allowed after this point */
 	if (R_tab != NULL) {
 		qdisc_put_rtab(police->tcfp_R_tab);
 		police->tcfp_R_tab = R_tab;
@@ -217,10 +224,6 @@ override:
 
 	if (tb[TCA_POLICE_AVRATE])
 		police->tcfp_ewma_rate = nla_get_u32(tb[TCA_POLICE_AVRATE]);
-	if (est)
-		gen_replace_estimator(&police->tcf_bstats,
-				      &police->tcf_rate_est,
-				      &police->tcf_lock, est);
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
@@ -238,7 +241,13 @@ override:
 	a->priv = police;
 	return ret;
 
+failure_unlock:
+	spin_unlock_bh(&police->tcf_lock);
 failure:
+	if (P_tab)
+		qdisc_put_rtab(P_tab);
+	if (R_tab)
+		qdisc_put_rtab(R_tab);
 	if (ret == ACT_P_CREATED)
 		kfree(police);
 	return err;
--- a/net/sched/sch_api.c	2008-11-25 10:02:05.000000000 -0800
+++ b/net/sched/sch_api.c	2008-11-25 10:07:21.000000000 -0800
@@ -897,10 +897,10 @@ static int qdisc_change(struct Qdisc *sc
 	sch->stab = stab;
 
 	if (tca[TCA_RATE])
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-				      qdisc_root_sleeping_lock(sch),
-				      tca[TCA_RATE]);
-	return 0;
+		err = gen_replace_estimator(&sch->bstats, &sch->rate_est,
+					    qdisc_root_sleeping_lock(sch),
+					    tca[TCA_RATE]);
+	return err;
 }
 
 struct check_loop_arg
--- a/net/sched/sch_cbq.c	2008-11-25 10:02:05.000000000 -0800
+++ b/net/sched/sch_cbq.c	2008-11-25 10:07:21.000000000 -0800
@@ -1806,10 +1806,10 @@ cbq_change_class(struct Qdisc *sch, u32 
 		sch_tree_unlock(sch);
 
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
-		return 0;
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						    qdisc_root_sleeping_lock(sch),
+						    tca[TCA_RATE]);
+		return err;
 	}
 
 	if (parentid == TC_H_ROOT)
--- a/net/sched/sch_drr.c	2008-11-25 10:02:05.000000000 -0800
+++ b/net/sched/sch_drr.c	2008-11-25 10:07:21.000000000 -0800
@@ -88,10 +88,10 @@ static int drr_change_class(struct Qdisc
 		sch_tree_unlock(sch);
 
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
-		return 0;
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						    qdisc_root_sleeping_lock(sch),
+						    tca[TCA_RATE]);
+		return err;
 	}
 
 	cl = kzalloc(sizeof(struct drr_class), GFP_KERNEL);
@@ -106,10 +106,15 @@ static int drr_change_class(struct Qdisc
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 
-	if (tca[TCA_RATE])
-		gen_replace_estimator(&cl->bstats, &cl->rate_est,
-				      qdisc_root_sleeping_lock(sch),
-				      tca[TCA_RATE]);
+	if (tca[TCA_RATE]) {
+		err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+					    qdisc_root_sleeping_lock(sch),
+					    tca[TCA_RATE]);
+		if (err) {
+			kfree(cl);
+			return err;
+		}
+	}
 
 	sch_tree_lock(sch);
 	qdisc_class_hash_insert(&q->clhash, &cl->common);
--- a/net/sched/sch_hfsc.c	2008-11-25 10:02:05.000000000 -0800
+++ b/net/sched/sch_hfsc.c	2008-11-25 10:07:21.000000000 -0800
@@ -1035,10 +1035,10 @@ hfsc_change_class(struct Qdisc *sch, u32
 		sch_tree_unlock(sch);
 
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
 					      qdisc_root_sleeping_lock(sch),
 					      tca[TCA_RATE]);
-		return 0;
+		return err;
 	}
 
 	if (parentid == TC_H_ROOT)
