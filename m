From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1b/2] tc: check for errors in gen_rate_estimator creation
Date: Tue, 25 Nov 2008 10:58:50 -0800
Message-ID: <20081125105850.7aa30a3d@extreme>
References: <20081125101656.52348bdd@extreme>
	<492C43DF.1040703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbYKYS6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:58:53 -0500
In-Reply-To: <492C43DF.1040703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions gen_new_estimator and gen_replace_estimator can return errors,
but they were being ignored.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/sched/act_police.c |   25 +++++++++++++++++--------
 net/sched/sch_api.c    |   12 ++++++++----
 net/sched/sch_cbq.c    |   33 ++++++++++++++++++++++++---------
 net/sched/sch_drr.c    |   26 ++++++++++++++++++--------
 net/sched/sch_hfsc.c   |   12 ++++++++----
 net/sched/sch_htb.c    |   22 +++++++++++++++-------
 6 files changed, 90 insertions(+), 40 deletions(-)

--- a/net/sched/act_police.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/act_police.c	2008-11-25 10:54:16.000000000 -0800
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
--- a/net/sched/sch_api.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/sch_api.c	2008-11-25 10:54:16.000000000 -0800
@@ -887,6 +887,14 @@ static int qdisc_change(struct Qdisc *sc
 			return err;
 	}
 
+	if (tca[TCA_RATE]) {
+		err = gen_replace_estimator(&sch->bstats, &sch->rate_est,
+					    qdisc_root_sleeping_lock(sch),
+					    tca[TCA_RATE]);
+		if (err)
+			return err;
+	}
+
 	if (tca[TCA_STAB]) {
 		stab = qdisc_get_stab(tca[TCA_STAB]);
 		if (IS_ERR(stab))
@@ -896,10 +904,6 @@ static int qdisc_change(struct Qdisc *sc
 	qdisc_put_stab(sch->stab);
 	sch->stab = stab;
 
-	if (tca[TCA_RATE])
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-				      qdisc_root_sleeping_lock(sch),
-				      tca[TCA_RATE]);
 	return 0;
 }
 
--- a/net/sched/sch_cbq.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/sch_cbq.c	2008-11-25 10:56:15.000000000 -0800
@@ -1765,11 +1765,23 @@ cbq_change_class(struct Qdisc *sch, u32 
 		}
 
 		if (tb[TCA_CBQ_RATE]) {
-			rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]), tb[TCA_CBQ_RTAB]);
+			rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]),
+					      tb[TCA_CBQ_RTAB]);
 			if (rtab == NULL)
 				return -EINVAL;
 		}
 
+		if (tca[TCA_RATE]) {
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						    qdisc_root_sleeping_lock(sch),
+						    tca[TCA_RATE]);
+			if (err) {
+				if (rtab)
+					qdisc_put_rtab(rtab);
+				return err;
+			}
+		}
+
 		/* Change class parameters */
 		sch_tree_lock(sch);
 
@@ -1805,10 +1817,6 @@ cbq_change_class(struct Qdisc *sch, u32 
 
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
 		return 0;
 	}
 
@@ -1855,6 +1863,17 @@ cbq_change_class(struct Qdisc *sch, u32 
 	cl = kzalloc(sizeof(*cl), GFP_KERNEL);
 	if (cl == NULL)
 		goto failure;
+
+	if (tca[TCA_RATE]) {
+		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+					qdisc_root_sleeping_lock(sch),
+					tca[TCA_RATE]);
+		if (err) {
+			kfree(cl);
+			goto failure;
+		}
+	}
+
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
@@ -1896,10 +1915,6 @@ cbq_change_class(struct Qdisc *sch, u32 
 
 	qdisc_class_hash_grow(sch, &q->clhash);
 
-	if (tca[TCA_RATE])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  qdisc_root_sleeping_lock(sch), tca[TCA_RATE]);
-
 	*arg = (unsigned long)cl;
 	return 0;
 
--- a/net/sched/sch_drr.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/sch_drr.c	2008-11-25 10:54:16.000000000 -0800
@@ -82,15 +82,19 @@ static int drr_change_class(struct Qdisc
 		quantum = psched_mtu(qdisc_dev(sch));
 
 	if (cl != NULL) {
+		if (tca[TCA_RATE]) {
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						    qdisc_root_sleeping_lock(sch),
+						    tca[TCA_RATE]);
+			if (err)
+				return err;
+		}
+
 		sch_tree_lock(sch);
 		if (tb[TCA_DRR_QUANTUM])
 			cl->quantum = quantum;
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
 		return 0;
 	}
 
@@ -106,10 +110,16 @@ static int drr_change_class(struct Qdisc
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
+			qdisc_destroy(cl->qdisc);
+			kfree(cl);
+			return err;
+		}
+	}
 
 	sch_tree_lock(sch);
 	qdisc_class_hash_insert(&q->clhash, &cl->common);
--- a/net/sched/sch_hfsc.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/sch_hfsc.c	2008-11-25 10:54:16.000000000 -0800
@@ -1018,6 +1018,14 @@ hfsc_change_class(struct Qdisc *sch, u32
 		}
 		cur_time = psched_get_time();
 
+		if (tca[TCA_RATE]) {
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+					      qdisc_root_sleeping_lock(sch),
+					      tca[TCA_RATE]);
+			if (err)
+				return err;
+		}
+
 		sch_tree_lock(sch);
 		if (rsc != NULL)
 			hfsc_change_rsc(cl, rsc, cur_time);
@@ -1034,10 +1042,6 @@ hfsc_change_class(struct Qdisc *sch, u32
 		}
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
 		return 0;
 	}
 
--- a/net/sched/sch_htb.c	2008-11-25 10:51:47.000000000 -0800
+++ b/net/sched/sch_htb.c	2008-11-25 10:54:16.000000000 -0800
@@ -1332,9 +1332,14 @@ static int htb_change_class(struct Qdisc
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  qdisc_root_sleeping_lock(sch),
-				  tca[TCA_RATE] ? : &est.nla);
+		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+					qdisc_root_sleeping_lock(sch),
+					tca[TCA_RATE] ? : &est.nla);
+		if (err) {
+			kfree(cl);
+			goto failure;
+		}
+
 		cl->refcnt = 1;
 		cl->children = 0;
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
@@ -1386,10 +1391,13 @@ static int htb_change_class(struct Qdisc
 		if (parent)
 			parent->children++;
 	} else {
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
+		if (tca[TCA_RATE]) {
+			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						    qdisc_root_sleeping_lock(sch),
+						    tca[TCA_RATE]);
+			if (err)
+				return err;
+		}
 		sch_tree_lock(sch);
 	}
 
