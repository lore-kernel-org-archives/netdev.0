From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 16/36] net,rcu: convert call_rcu(rps_map_release) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:01:31 +0800
Message-ID: <4D82D91B.1080102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@go
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50016 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab1CRD7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback rps_map_release() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(rps_map_release).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/net-sysfs.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index e23c01b..21e9208 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -550,13 +550,6 @@ static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 	return len;
 }
 
-static void rps_map_release(struct rcu_head *rcu)
-{
-	struct rps_map *map = container_of(rcu, struct rps_map, rcu);
-
-	kfree(map);
-}
-
 static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		      struct rx_queue_attribute *attribute,
 		      const char *buf, size_t len)
@@ -604,7 +597,7 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	spin_unlock(&rps_map_lock);
 
 	if (old_map)
-		call_rcu(&old_map->rcu, rps_map_release);
+		kfree_rcu(old_map, rcu);
 
 	free_cpumask_var(mask);
 	return len;
@@ -713,7 +706,7 @@ static void rx_queue_release(struct kobject *kobj)
 	map = rcu_dereference_raw(queue->rps_map);
 	if (map) {
 		RCU_INIT_POINTER(queue->rps_map, NULL);
-		call_rcu(&map->rcu, rps_map_release);
+		kfree_rcu(map, rcu);
 	}
 
 	flow_table = rcu_dereference_raw(queue->rps_flow_table);
-- 
1.7.4
