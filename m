From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] tc: policing requires a rate estimator
Date: Tue, 25 Nov 2008 10:21:13 -0800
Message-ID: <20081125102113.371db7b1@extreme>
References: <20081125101656.52348bdd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47125 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbYKYSVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:21:22 -0500
In-Reply-To: <20081125101656.52348bdd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found that while trying average rate policing, it was possible to
request average rate policing without a rate estimator. This results
in no policing which is harmless but incorrect.

Since policing could be setup in two steps, need to check
in the kernel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/net/gen_stats.h  |    1 +
 net/core/gen_estimator.c |   30 +++++++++++++++++++++++++++---
 net/sched/act_police.c   |   16 ++++++++++++----
 3 files changed, 40 insertions(+), 7 deletions(-)

--- a/net/sched/act_police.c	2008-11-25 10:15:50.000000000 -0800
+++ b/net/sched/act_police.c	2008-11-25 10:17:54.000000000 -0800
@@ -182,6 +182,12 @@ override:
 		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
 		if (R_tab == NULL)
 			goto failure;
+
+		if (!est && !gen_estimator_active(&police->tcf_rate_est)) {
+			err = -EINVAL;
+			goto failure;
+		}
+
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
 					       tb[TCA_POLICE_PEAKRATE]);
--- a/include/net/gen_stats.h	2008-11-25 10:14:52.000000000 -0800
+++ b/include/net/gen_stats.h	2008-11-25 10:16:52.000000000 -0800
@@ -45,5 +45,6 @@ extern void gen_kill_estimator(struct gn
 extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
 				 struct gnet_stats_rate_est *rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
+extern int gen_estimator_active(const struct gnet_stats_rate_est *rate_est);
 
 #endif
--- a/net/core/gen_estimator.c	2008-11-25 10:14:52.000000000 -0800
+++ b/net/core/gen_estimator.c	2008-11-25 10:16:52.000000000 -0800
@@ -242,6 +242,7 @@ int gen_new_estimator(struct gnet_stats_
 
 	return 0;
 }
+EXPORT_SYMBOL(gen_new_estimator);
 
 static void __gen_kill_estimator(struct rcu_head *head)
 {
@@ -275,6 +276,7 @@ void gen_kill_estimator(struct gnet_stat
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
 }
+EXPORT_SYMBOL(gen_kill_estimator);
 
 /**
  * gen_replace_estimator - replace rate estimator configuration
@@ -295,8 +297,30 @@ int gen_replace_estimator(struct gnet_st
 	gen_kill_estimator(bstats, rate_est);
 	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
 }
+EXPORT_SYMBOL(gen_replace_estimator);
+
+/**
+ * gen_estimator_active - test if estimator is currently in use
+ * @rate_est: rate estimator statistics
+ *
+ * Returns 1 if estimator is active, and 0 if not.
+ */
+int gen_estimator_active(const struct gnet_stats_rate_est *rate_est)
+{
+	int idx;
+	struct gen_estimator *e;
 
+	ASSERT_RTNL();
 
-EXPORT_SYMBOL(gen_kill_estimator);
-EXPORT_SYMBOL(gen_new_estimator);
-EXPORT_SYMBOL(gen_replace_estimator);
+	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
+		if (!elist[idx].timer.function)
+			continue;
+
+		list_for_each_entry(e, &elist[idx].list, list) {
+			if (e->rate_est == rate_est)
+				return 1;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(gen_estimator_active);
