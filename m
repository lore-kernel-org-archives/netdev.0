From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: gen_estimator: Optimize gen_estimator_active()
Date: Wed, 26 Nov 2008 11:10:22 +0000
Message-ID: <20081126111021.GA12337@ff.dom.local>
References: <20081125102113.371db7b1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:9138 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbYKZLK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 06:10:29 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1375010ugf.37
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 03:10:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081125102113.371db7b1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: gen_estimator: Optimize gen_estimator_active()

Since all other gen_estimator functions use bstats and rate_est params
together, and searching for them is optimized now, let's use this also
in gen_estimator_active(). The return type of gen_estimator_active()
is changed to bool, and gen_find_node() parameters to const, btw.

In tcf_act_police_locate() a check for ACT_P_CREATED is added before
calling gen_estimator_active().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/gen_stats.h  |    4 ++--
 net/core/gen_estimator.c |   25 ++++++++-----------------
 net/sched/act_police.c   |    4 +++-
 3 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index dcf5bfa..d136b52 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -45,6 +45,6 @@ extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
 extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
 				 struct gnet_stats_rate_est *rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
-extern int gen_estimator_active(const struct gnet_stats_rate_est *rate_est);
-
+extern bool gen_estimator_active(const struct gnet_stats_basic *bstats,
+				 const struct gnet_stats_rate_est *rate_est);
 #endif
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 3885550..9cc9f95 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -163,8 +163,9 @@ static void gen_add_node(struct gen_estimator *est)
 	rb_insert_color(&est->node, &est_root);
 }
 
-static struct gen_estimator *gen_find_node(struct gnet_stats_basic *bstats,
-					   struct gnet_stats_rate_est *rate_est)
+static
+struct gen_estimator *gen_find_node(const struct gnet_stats_basic *bstats,
+				    const struct gnet_stats_rate_est *rate_est)
 {
 	struct rb_node *p = est_root.rb_node;
 
@@ -301,26 +302,16 @@ EXPORT_SYMBOL(gen_replace_estimator);
 
 /**
  * gen_estimator_active - test if estimator is currently in use
+ * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  *
- * Returns 1 if estimator is active, and 0 if not.
+ * Returns true if estimator is active, and false if not.
  */
-int gen_estimator_active(const struct gnet_stats_rate_est *rate_est)
+bool gen_estimator_active(const struct gnet_stats_basic *bstats,
+			  const struct gnet_stats_rate_est *rate_est)
 {
-	int idx;
-	struct gen_estimator *e;
-
 	ASSERT_RTNL();
 
-	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		if (!elist[idx].timer.function)
-			continue;
-
-		list_for_each_entry(e, &elist[idx].list, list) {
-			if (e->rate_est == rate_est)
-				return 1;
-		}
-	}
-	return 0;
+	return gen_find_node(bstats, rate_est) != NULL;
 }
 EXPORT_SYMBOL(gen_estimator_active);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 40df1d0..40f9a81 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -183,7 +183,9 @@ override:
 		if (R_tab == NULL)
 			goto failure;
 
-		if (!est && !gen_estimator_active(&police->tcf_rate_est)) {
+		if (!est && (ret == ACT_P_CREATED ||
+			     !gen_estimator_active(&police->tcf_bstats,
+						   &police->tcf_rate_est))) {
 			err = -EINVAL;
 			goto failure;
 		}
