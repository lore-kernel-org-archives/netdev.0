From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 18/36] net,rcu: convert call_rcu(xps_dev_maps_release) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:02:47 +0800
Message-ID: <4D82D967.7090408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@go
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54511 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab1CREBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:01:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback xps_dev_maps_release() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(xps_dev_maps_release).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/net-sysfs.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 9ae2e1d..06332e5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -876,14 +876,6 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 	return len;
 }
 
-static void xps_dev_maps_release(struct rcu_head *rcu)
-{
-	struct xps_dev_maps *dev_maps =
-	    container_of(rcu, struct xps_dev_maps, rcu);
-
-	kfree(dev_maps);
-}
-
 static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
 	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
@@ -993,7 +985,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	}
 
 	if (dev_maps)
-		call_rcu(&dev_maps->rcu, xps_dev_maps_release);
+		kfree_rcu(dev_maps, rcu);
 
 	netdev_queue_numa_node_write(queue, (numa_node >= 0) ? numa_node :
 					    NUMA_NO_NODE);
@@ -1065,7 +1057,7 @@ static void netdev_queue_release(struct kobject *kobj)
 
 		if (!nonempty) {
 			RCU_INIT_POINTER(dev->xps_maps, NULL);
-			call_rcu(&dev_maps->rcu, xps_dev_maps_release);
+			kfree_rcu(dev_maps, rcu);
 		}
 	}
 
-- 
1.7.4
