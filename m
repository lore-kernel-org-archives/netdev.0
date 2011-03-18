From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 01/36] net,rcu: convert call_rcu(free_dm_hw_stat) to kfree_rcu()
Date: Fri, 18 Mar 2011 11:39:43 +0800
Message-ID: <4D82D3FF.2080303__21858.5482369692$1300419501$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58870 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755759Ab1CRDh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:37:58 -0400
In-Reply-To: <4D82D071.5020703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback free_dm_hw_stat() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(free_dm_hw_stat).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/drop_monitor.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 36e603c..32365e7 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -207,14 +207,6 @@ static void trace_napi_poll_hit(void *ignore, struct napi_struct *napi)
 	rcu_read_unlock();
 }
 
-
-static void free_dm_hw_stat(struct rcu_head *head)
-{
-	struct dm_hw_stat_delta *n;
-	n = container_of(head, struct dm_hw_stat_delta, rcu);
-	kfree(n);
-}
-
 static int set_all_monitor_traces(int state)
 {
 	int rc = 0;
@@ -245,7 +237,7 @@ static int set_all_monitor_traces(int state)
 		list_for_each_entry_safe(new_stat, temp, &hw_stats_list, list) {
 			if (new_stat->dev == NULL) {
 				list_del_rcu(&new_stat->list);
-				call_rcu(&new_stat->rcu, free_dm_hw_stat);
+				kfree_rcu(new_stat, rcu);
 			}
 		}
 		break;
@@ -314,7 +306,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 				new_stat->dev = NULL;
 				if (trace_state == TRACE_OFF) {
 					list_del_rcu(&new_stat->list);
-					call_rcu(&new_stat->rcu, free_dm_hw_stat);
+					kfree_rcu(new_stat, rcu);
 					break;
 				}
 			}
-- 
1.7.4
