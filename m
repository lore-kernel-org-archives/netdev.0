From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 1/2] net_sched: get rid of tcfa_rcu
Date: Wed,  6 Sep 2017 21:26:06 -0700
Message-ID: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
Cc: jakub.kicinski@netronome.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33807 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIGE0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:26:17 -0400
Received: by mail-pf0-f195.google.com with SMTP id y68so3991095pfd.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 21:26:17 -0700 (PDT)
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

Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  2 --
 net/sched/act_api.c   | 12 +++---------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 26ffd8333f50..68218a5f8e72 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -38,7 +38,6 @@ struct tc_action {
 	struct gnet_stats_queue		tcfa_qstats;
 	struct net_rate_estimator __rcu *tcfa_rate_est;
 	spinlock_t			tcfa_lock;
-	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 	struct tc_cookie	*act_cookie;
@@ -55,7 +54,6 @@ struct tc_action {
 #define tcf_qstats	common.tcfa_qstats
 #define tcf_rate_est	common.tcfa_rate_est
 #define tcf_lock	common.tcfa_lock
-#define tcf_rcu		common.tcfa_rcu
 
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
 {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f2e9ed34a963..fc17d286a6a2 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -53,10 +53,8 @@ static void tcf_action_goto_chain_exec(const struct tc_action *a,
 	res->goto_tp = rcu_dereference_bh(chain->filter_chain);
 }
 
-static void free_tcf(struct rcu_head *head)
+static void free_tcf(struct tc_action *p)
 {
-	struct tc_action *p = container_of(head, struct tc_action, tcfa_rcu);
-
 	free_percpu(p->cpu_bstats);
 	free_percpu(p->cpu_qstats);
 
@@ -76,11 +74,7 @@ static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
 	hlist_del(&p->tcfa_head);
 	spin_unlock_bh(&hinfo->lock);
 	gen_kill_estimator(&p->tcfa_rate_est);
-	/*
-	 * gen_estimator est_timer() might access p->tcfa_lock
-	 * or bstats, wait a RCU grace period before freeing p
-	 */
-	call_rcu(&p->tcfa_rcu, free_tcf);
+	free_tcf(p);
 }
 
 int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
@@ -271,7 +265,7 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 {
 	if (est)
 		gen_kill_estimator(&a->tcfa_rate_est);
-	call_rcu(&a->tcfa_rcu, free_tcf);
+	free_tcf(a);
 }
 EXPORT_SYMBOL(tcf_hash_cleanup);
 
-- 
2.13.0
