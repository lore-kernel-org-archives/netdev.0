From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 1/3] net_sched: get rid of tcfa_rcu
Date: Mon, 11 Sep 2017 16:33:30 -0700
Message-ID: <20170911233332.7594-2-xiyou.wangcong@gmail.com>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Cc: jiri@mellanox.com, jakub.kicinski@netronome.com, jhs@mojatatu.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33769 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdIKXdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 19:33:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so5522148pfk.0
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 16:33:52 -0700 (PDT)
In-Reply-To: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gen estimator has been rewritten in commit 1c0d32fde5bd
("net_sched: gen_estimator: complete rewrite of rate estimators"),
the caller is no longer needed to wait for a grace period.
So this patch gets rid of it.

This also completely closes a race condition between action free
path and filter chain add/remove path for the following patch.
Because otherwise the nested RCU callback can't be caught by
rcu_barrier().

Please see also the comments in code.

Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  2 --
 net/sched/act_api.c   | 17 ++++++++---------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 8f3d5d8b5ae0..b944e0eb93be 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -34,7 +34,6 @@ struct tc_action {
 	struct gnet_stats_queue		tcfa_qstats;
 	struct net_rate_estimator __rcu *tcfa_rate_est;
 	spinlock_t			tcfa_lock;
-	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 	struct tc_cookie	*act_cookie;
@@ -50,7 +49,6 @@ struct tc_action {
 #define tcf_qstats	common.tcfa_qstats
 #define tcf_rate_est	common.tcfa_rate_est
 #define tcf_lock	common.tcfa_lock
-#define tcf_rcu		common.tcfa_rcu
 
 /* Update lastuse only if needed, to avoid dirtying a cache line.
  * We use a temp variable to avoid fetching jiffies twice.
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index a306974e2fb4..fcd7dc7b807a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -53,10 +53,13 @@ static void tcf_action_goto_chain_exec(const struct tc_action *a,
 	res->goto_tp = rcu_dereference_bh(chain->filter_chain);
 }
 
-static void free_tcf(struct rcu_head *head)
+/* XXX: For standalone actions, we don't need a RCU grace period either, because
+ * actions are always connected to filters and filters are already destroyed in
+ * RCU callbacks, so after a RCU grace period actions are already disconnected
+ * from filters. Readers later can not find us.
+ */
+static void free_tcf(struct tc_action *p)
 {
-	struct tc_action *p = container_of(head, struct tc_action, tcfa_rcu);
-
 	free_percpu(p->cpu_bstats);
 	free_percpu(p->cpu_qstats);
 
@@ -76,11 +79,7 @@ static void tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)
 	idr_remove_ext(&idrinfo->action_idr, p->tcfa_index);
 	spin_unlock_bh(&idrinfo->lock);
 	gen_kill_estimator(&p->tcfa_rate_est);
-	/*
-	 * gen_estimator est_timer() might access p->tcfa_lock
-	 * or bstats, wait a RCU grace period before freeing p
-	 */
-	call_rcu(&p->tcfa_rcu, free_tcf);
+	free_tcf(p);
 }
 
 int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
@@ -259,7 +258,7 @@ void tcf_idr_cleanup(struct tc_action *a, struct nlattr *est)
 {
 	if (est)
 		gen_kill_estimator(&a->tcfa_rate_est);
-	call_rcu(&a->tcfa_rcu, free_tcf);
+	free_tcf(a);
 }
 EXPORT_SYMBOL(tcf_idr_cleanup);
 
-- 
2.13.0
