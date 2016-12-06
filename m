From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: xt_rateest_put() can directly call
 kfree()
Date: Tue, 06 Dec 2016 09:30:02 -0800
Message-ID: <1481045402.18162.588.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33126 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbcLFRbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:31:05 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so20462473pgd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:31:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 1c0d32fde5bd ("net_sched: gen_estimator: complete rewrite
of rate estimators") we no longer have to respect an RCU grace period
after calling gen_kill_estimator()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netfilter/xt_rateest.h |    1 -
 net/netfilter/xt_RATEEST.c         |    6 +-----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index 130e58361f998ecdf361910b196e69778224d955..76c9347c3645f86d55696126909f9898a6f41594 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -14,7 +14,6 @@ struct xt_rateest {
 	struct hlist_node		list;
 	char				name[IFNAMSIZ];
 	struct gnet_estimator		params;
-	struct rcu_head			rcu;
 
 	/* keep this field far away to speedup xt_rateest_mt() */
 	struct net_rate_estimator __rcu *rate_est;
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 91a373a3f534de8d8641341c33c08d8fc49cbd29..e534648aa516a86aba29b741378160a37e5b9dcb 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -64,11 +64,7 @@ void xt_rateest_put(struct xt_rateest *est)
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
 		gen_kill_estimator(&est->rate_est);
-		/*
-		 * gen_estimator est_timer() might access est->lock or bstats,
-		 * wait a RCU grace period before freeing 'est'
-		 */
-		kfree_rcu(est, rcu);
+		kfree(est);
 	}
 	mutex_unlock(&xt_rateest_mutex);
 }
