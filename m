From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH 2/2] net/neighbour: queue work on power efficient wq
Date: Wed, 22 Jan 2014 12:23:33 +0530
Message-ID: <faa5b965e81fcb4c3261561e58a8ab1194ecf562.1390373223.git.viresh.kumar@linaro.org>
References: <c24546776d8ec32afd1c084dd1d2a72fc96c6519.1390373223.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, patches@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c24546776d8ec32afd1c084dd1d2a72fc96c6519.1390373223.git.viresh.kumar@linaro.org>
In-Reply-To: <c24546776d8ec32afd1c084dd1d2a72fc96c6519.1390373223.git.viresh.kumar@linaro.org>
References: <c24546776d8ec32afd1c084dd1d2a72fc96c6519.1390373223.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Workqueue used in neighbour layer have no real dependency of scheduling these on
the cpu which scheduled them.

On a idle system, it is observed that an idle cpu wakes up many times just to
service this work. It would be better if we can schedule it on a cpu which the
scheduler believes to be the most appropriate one.

This patch replaces normal workqueues with power efficient versions. This
doesn't change existing behavior of code unless CONFIG_WQ_POWER_EFFICIENT is
enabled.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 net/core/neighbour.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f8012fe..b9e9e0d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -828,7 +828,7 @@ out:
 	 * ARP entry timeouts range from 1/2 BASE_REACHABLE_TIME to 3/2
 	 * BASE_REACHABLE_TIME.
 	 */
-	schedule_delayed_work(&tbl->gc_work,
+	queue_delayed_work(system_power_efficient_wq, &tbl->gc_work,
 			      NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME) >> 1);
 	write_unlock_bh(&tbl->lock);
 }
@@ -1565,7 +1565,8 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 
 	rwlock_init(&tbl->lock);
 	INIT_DEFERRABLE_WORK(&tbl->gc_work, neigh_periodic_work);
-	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
+	queue_delayed_work(system_power_efficient_wq, &tbl->gc_work,
+			tbl->parms.reachable_time);
 	setup_timer(&tbl->proxy_timer, neigh_proxy_process, (unsigned long)tbl);
 	skb_queue_head_init_class(&tbl->proxy_queue,
 			&neigh_table_proxy_queue_class);
-- 
1.7.12.rc2.18.g61b472e
