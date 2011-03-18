From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 17/36] net,rcu: convert call_rcu(xps_map_release) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:02:20 +0800
Message-ID: <4D82D94C.2090507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@go
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59022 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab1CREAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback xps_map_release() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(xps_map_release).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/net-sysfs.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 21e9208..9ae2e1d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -876,13 +876,6 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 	return len;
 }
 
-static void xps_map_release(struct rcu_head *rcu)
-{
-	struct xps_map *map = container_of(rcu, struct xps_map, rcu);
-
-	kfree(map);
-}
-
 static void xps_dev_maps_release(struct rcu_head *rcu)
 {
 	struct xps_dev_maps *dev_maps =
@@ -987,7 +980,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 		map = dev_maps ?
 			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
 		if (map && xmap_dereference(new_dev_maps->cpu_map[cpu]) != map)
-			call_rcu(&map->rcu, xps_map_release);
+			kfree_rcu(map, rcu);
 		if (new_dev_maps->cpu_map[cpu])
 			nonempty = 1;
 	}
@@ -1062,7 +1055,7 @@ static void netdev_queue_release(struct kobject *kobj)
 				else {
 					RCU_INIT_POINTER(dev_maps->cpu_map[i],
 					    NULL);
-					call_rcu(&map->rcu, xps_map_release);
+					kfree_rcu(map, rcu);
 					map = NULL;
 				}
 			}
-- 
1.7.4
