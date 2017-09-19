From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next] net_sched: no need to free qdisc in RCU callback
Date: Tue, 19 Sep 2017 13:15:42 -0700
Message-ID: <20170919201542.14890-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38277 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISUPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:15:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id a7so269685pfj.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 13:15:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gen estimator has been rewritten in commit 1c0d32fde5bd
("net_sched: gen_estimator: complete rewrite of rate estimators"),
the caller no longer needs to wait for a grace period. So this
patch gets rid of it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  1 -
 net/sched/sch_generic.c   | 10 ++--------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 135f5a2dd931..684d8ed27eaa 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -93,7 +93,6 @@ struct Qdisc {
 	unsigned long		state;
 	struct Qdisc            *next_sched;
 	struct sk_buff		*skb_bad_txq;
-	struct rcu_head		rcu_head;
 	int			padded;
 	refcount_t		refcnt;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 92237e75dbbc..1fb0c754b7fd 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -688,10 +688,8 @@ void qdisc_reset(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_reset);
 
-static void qdisc_rcu_free(struct rcu_head *head)
+static void qdisc_free(struct Qdisc *qdisc)
 {
-	struct Qdisc *qdisc = container_of(head, struct Qdisc, rcu_head);
-
 	if (qdisc_is_percpu_stats(qdisc)) {
 		free_percpu(qdisc->cpu_bstats);
 		free_percpu(qdisc->cpu_qstats);
@@ -724,11 +722,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	kfree_skb_list(qdisc->gso_skb);
 	kfree_skb(qdisc->skb_bad_txq);
-	/*
-	 * gen_estimator est_timer() might access qdisc->q.lock,
-	 * wait a RCU grace period before freeing qdisc.
-	 */
-	call_rcu(&qdisc->rcu_head, qdisc_rcu_free);
+	qdisc_free(qdisc);
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
-- 
2.13.0
