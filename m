From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
Date: Wed, 09 Jun 2010 11:56:56 +0200
Message-ID: <1276077416.2442.97.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1276076415.2442.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62752 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756907Ab0FIJ5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 05:57:07 -0400
Received: by wyf28 with SMTP id 28so774367wyf.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 02:57:04 -0700 (PDT)
In-Reply-To: <1276076415.2442.92.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Oops, I missed  kfree() deletion in  :


>  static void tcf_police_destroy(struct tcf_police *p)
>  {
>  	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
> @@ -113,6 +118,7 @@ static void tcf_police_destroy(struct tcf_police *p)
>  				qdisc_put_rtab(p->tcfp_R_tab);
>  			if (p->tcfp_P_tab)
>  				qdisc_put_rtab(p->tcfp_P_tab);
> +			call_rcu(&p->tcf_rcu, tcf_police_free_rcu);
>  			kfree(p);
>  			return;

Updated patch follows :

[PATCH] pkt_sched: gen_kill_estimator() rcu fixes

gen_kill_estimator() API is a bit misleading, since caller
should make sure an RCU grace period is respected before
freeing stats_lock.

This was partially addressed in commit 5d944c640b4 
(gen_estimator: deadlock fix), but same problem exist for all
gen_kill_estimator() users, if lock they use is not already rcu
protected.

A code review shows xt_RATEEST.c, act_api.c, act_police.c have this
problem. Other are ok because they use qdisc lock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/act_api.h              |    2 ++
 include/net/netfilter/xt_rateest.h |    1 +
 net/core/gen_estimator.c           |    1 +
 net/netfilter/xt_RATEEST.c         |    8 +++++++-
 net/sched/act_api.c                |    7 ++++++-
 net/sched/act_police.c             |    8 +++++++-
 6 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index c05fd71..bab385f 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -20,6 +20,7 @@ struct tcf_common {
 	struct gnet_stats_queue		tcfc_qstats;
 	struct gnet_stats_rate_est	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
+	struct rcu_head			tcfc_rcu;
 };
 #define tcf_next	common.tcfc_next
 #define tcf_index	common.tcfc_index
@@ -32,6 +33,7 @@ struct tcf_common {
 #define tcf_qstats	common.tcfc_qstats
 #define tcf_rate_est	common.tcfc_rate_est
 #define tcf_lock	common.tcfc_lock
+#define tcf_rcu		common.tcfc_rcu
 
 struct tcf_police {
 	struct tcf_common	common;
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index ddbf37e..5e14277 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -9,6 +9,7 @@ struct xt_rateest {
 	struct gnet_estimator		params;
 	struct gnet_stats_rate_est	rstats;
 	struct gnet_stats_basic_packed	bstats;
+	struct rcu_head			rcu;
 };
 
 extern struct xt_rateest *xt_rateest_lookup(const char *name);
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 785e527..9fbe7f7 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -263,6 +263,7 @@ static void __gen_kill_estimator(struct rcu_head *head)
  *
  * Removes the rate estimator specified by &bstats and &rate_est.
  *
+ * Note : Caller should respect an RCU grace period before freeing stats_lock
  */
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est *rate_est)
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 69c01e1..096b18b 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -60,13 +60,18 @@ struct xt_rateest *xt_rateest_lookup(const char *name)
 }
 EXPORT_SYMBOL_GPL(xt_rateest_lookup);
 
+static void xt_rateeset_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct xt_rateest, rcu));
+}
+
 void xt_rateest_put(struct xt_rateest *est)
 {
 	mutex_lock(&xt_rateest_mutex);
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
 		gen_kill_estimator(&est->bstats, &est->rstats);
-		kfree(est);
+		call_rcu(&est->rcu, xt_rateeset_free_rcu);
 	}
 	mutex_unlock(&xt_rateest_mutex);
 }
@@ -179,6 +184,7 @@ static int __init xt_rateest_tg_init(void)
 static void __exit xt_rateest_tg_fini(void)
 {
 	xt_unregister_target(&xt_rateest_tg_reg);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 972378f..0e6fd2b 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -26,6 +26,11 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
+static void tcf_common_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct tcf_common, tcfc_rcu));
+}
+
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
@@ -38,7 +43,7 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 			write_unlock_bh(hinfo->lock);
 			gen_kill_estimator(&p->tcfc_bstats,
 					   &p->tcfc_rate_est);
-			kfree(p);
+			call_rcu(&p->tcfc_rcu, tcf_common_free_rcu);
 			return;
 		}
 	}
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 654f73d..04929ce 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -97,6 +97,11 @@ nla_put_failure:
 	goto done;
 }
 
+static void tcf_police_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct tcf_police, tcf_rcu));
+}
+
 static void tcf_police_destroy(struct tcf_police *p)
 {
 	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
@@ -113,7 +118,7 @@ static void tcf_police_destroy(struct tcf_police *p)
 				qdisc_put_rtab(p->tcfp_R_tab);
 			if (p->tcfp_P_tab)
 				qdisc_put_rtab(p->tcfp_P_tab);
-			kfree(p);
+			call_rcu(&p->tcf_rcu, tcf_police_free_rcu);
 			return;
 		}
 	}
@@ -397,6 +402,7 @@ static void __exit
 police_cleanup_module(void)
 {
 	tcf_unregister_action(&act_police_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 module_init(police_init_module);


