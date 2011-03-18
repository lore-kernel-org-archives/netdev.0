From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 06/36] net,rcu: convert call_rcu(__gen_kill_estimator) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 11:43:26 +0800
Message-ID: <4D82D4DE.60105@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54758 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:41:40 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback __gen_kill_estimator() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(__gen_kill_estimator).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/gen_estimator.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 7c23733..43b03dd 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -249,13 +249,6 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 }
 EXPORT_SYMBOL(gen_new_estimator);
 
-static void __gen_kill_estimator(struct rcu_head *head)
-{
-	struct gen_estimator *e = container_of(head,
-					struct gen_estimator, e_rcu);
-	kfree(e);
-}
-
 /**
  * gen_kill_estimator - remove a rate estimator
  * @bstats: basic statistics
@@ -279,7 +272,7 @@ void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 		write_unlock(&est_lock);
 
 		list_del_rcu(&e->list);
-		call_rcu(&e->e_rcu, __gen_kill_estimator);
+		kfree_rcu(e, e_rcu);
 	}
 	spin_unlock_bh(&est_tree_lock);
 }
-- 
1.7.4
