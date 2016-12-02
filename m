From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: gen_estimator: account for timer drifts
Date: Fri, 02 Dec 2016 08:11:00 -0800
Message-ID: <1480695060.18162.363.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35068 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcLBQMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 11:12:03 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so8298332pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 08:12:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under heavy stress, timer used in estimators tend to slowly be delayed
by a few jiffies, leading to inaccuracies.

Lets remember what was the last scheduled jiffies so that we get more
precise estimations, without having to add a multiply/divide in the loop
to account for the drifts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/gen_estimator.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cad8e791f28e..0993844faeea 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -78,8 +78,7 @@
 
 #define EST_MAX_INTERVAL	5
 
-struct gen_estimator
-{
+struct gen_estimator {
 	struct list_head	list;
 	struct gnet_stats_basic_packed	*bstats;
 	struct gnet_stats_rate_est64	*rate_est;
@@ -96,8 +95,8 @@ struct gen_estimator
 	struct rcu_head		head;
 };
 
-struct gen_estimator_head
-{
+struct gen_estimator_head {
+	unsigned long		next_jiffies;
 	struct timer_list	timer;
 	struct list_head	list;
 };
@@ -146,8 +145,15 @@ static void est_timer(unsigned long arg)
 			spin_unlock(e->stats_lock);
 	}
 
-	if (!list_empty(&elist[idx].list))
-		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
+	if (!list_empty(&elist[idx].list)) {
+		elist[idx].next_jiffies += ((HZ/4) << idx);
+
+		if (unlikely(time_after_eq(jiffies, elist[idx].next_jiffies))) {
+			/* Ouch... timer was delayed. */
+			elist[idx].next_jiffies = jiffies + 1;
+		}
+		mod_timer(&elist[idx].timer, elist[idx].next_jiffies);
+	}
 	rcu_read_unlock();
 }
 
@@ -251,9 +257,10 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		setup_timer(&elist[idx].timer, est_timer, idx);
 	}
 
-	if (list_empty(&elist[idx].list))
-		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
-
+	if (list_empty(&elist[idx].list)) {
+		elist[idx].next_jiffies = jiffies + ((HZ/4) << idx);
+		mod_timer(&elist[idx].timer, elist[idx].next_jiffies);
+	}
 	list_add_rcu(&est->list, &elist[idx].list);
 	gen_add_node(est);
 	spin_unlock_bh(&est_tree_lock);
