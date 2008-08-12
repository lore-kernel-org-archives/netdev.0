From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take 2] pkt_sched: Protect gen estimators under est_lock.
Date: Wed, 13 Aug 2008 00:02:18 +0200
Message-ID: <20080812220218.GA12387@ami.dom.local>
References: <20080811205357.GA15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:54678 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbYHLWCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 18:02:25 -0400
Received: by nf-out-0910.google.com with SMTP id d3so962836nfc.21
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 15:02:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080811205357.GA15293@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 10:53:57PM +0200, Jarek Poplawski wrote:
> pkt_sched: Destroy gen estimators under rtnl_lock().
> 
> gen_kill_estimator() requires rtnl_lock() protection, and since it is
> called in qdisc ->destroy() too, this has to go back from RCU callback
> to qdisc_destroy().

So, since it's currently impossible, here is an alternative solution.

Jarek P.

------------>

pkt_sched: Protect gen estimators under est_lock.

gen_kill_estimator() required rtnl_lock() protection, but since it is
moved to an RCU callback __qdisc_destroy() let's use est_lock instead.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/core/gen_estimator.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 57abe82..a89f32f 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -99,7 +99,7 @@ struct gen_estimator_head
 
 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 
-/* Protects against NULL dereference */
+/* Protects against NULL dereference and RCU write-side */
 static DEFINE_RWLOCK(est_lock);
 
 static void est_timer(unsigned long arg)
@@ -185,6 +185,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
+	write_lock_bh(&est_lock);
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
 		setup_timer(&elist[idx].timer, est_timer, idx);
@@ -194,6 +195,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
 
 	list_add_rcu(&est->list, &elist[idx].list);
+	write_unlock_bh(&est_lock);
 	return 0;
 }
 
@@ -212,7 +214,6 @@ static void __gen_kill_estimator(struct rcu_head *head)
  * Removes the rate estimator specified by &bstats and &rate_est
  * and deletes the timer.
  *
- * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
 	struct gnet_stats_rate_est *rate_est)
@@ -226,17 +227,17 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
 		if (!elist[idx].timer.function)
 			continue;
 
+		write_lock_bh(&est_lock);
 		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
 			if (e->rate_est != rate_est || e->bstats != bstats)
 				continue;
 
-			write_lock_bh(&est_lock);
 			e->bstats = NULL;
-			write_unlock_bh(&est_lock);
 
 			list_del_rcu(&e->list);
 			call_rcu(&e->e_rcu, __gen_kill_estimator);
 		}
+		write_unlock_bh(&est_lock);
 	}
 }
 
