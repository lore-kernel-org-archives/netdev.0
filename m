From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rps: add __rcu annotations
Date: Mon, 25 Oct 2010 15:02:02 +0200
Message-ID: <1288011722.2826.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51462 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab0JYNCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:02:07 -0400
Received: by eye27 with SMTP id 27so4076548eye.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 06:02:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations to :
	(struct netdev_rx_queue)->rps_map
	(struct netdev_rx_queue)->rps_flow_table
	struct rps_sock_flow_table *rps_sock_flow_table;

And use appropriate rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h  |   12 ++++++------
 net/core/dev.c             |   12 ++++++------
 net/core/net-sysfs.c       |   20 +++++++++++++-------
 net/core/sysctl_net_core.c |    3 ++-
 4 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fcd3dda..2475206 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -585,15 +585,15 @@ static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
 		table->ents[hash & table->mask] = RPS_NO_CPU;
 }
 
-extern struct rps_sock_flow_table *rps_sock_flow_table;
+extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
 
 /* This structure contains an instance of an RX queue. */
 struct netdev_rx_queue {
-	struct rps_map *rps_map;
-	struct rps_dev_flow_table *rps_flow_table;
-	struct kobject kobj;
-	struct netdev_rx_queue *first;
-	atomic_t count;
+	struct rps_map __rcu		*rps_map;
+	struct rps_dev_flow_table __rcu	*rps_flow_table;
+	struct kobject			kobj;
+	struct netdev_rx_queue		*first;
+	atomic_t			count;
 } ____cacheline_aligned_in_smp;
 #endif /* CONFIG_RPS */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 78b5a89..625fde2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2413,7 +2413,7 @@ EXPORT_SYMBOL(__skb_get_rxhash);
 #ifdef CONFIG_RPS
 
 /* One global table that all flow-based protocols share. */
-struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
+struct rps_sock_flow_table __rcu *rps_sock_flow_table __read_mostly;
 EXPORT_SYMBOL(rps_sock_flow_table);
 
 /*
@@ -2425,7 +2425,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		       struct rps_dev_flow **rflowp)
 {
 	struct netdev_rx_queue *rxqueue;
-	struct rps_map *map = NULL;
+	struct rps_map *map;
 	struct rps_dev_flow_table *flow_table;
 	struct rps_sock_flow_table *sock_flow_table;
 	int cpu = -1;
@@ -2444,15 +2444,15 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	} else
 		rxqueue = dev->_rx;
 
-	if (rxqueue->rps_map) {
-		map = rcu_dereference(rxqueue->rps_map);
-		if (map && map->len == 1) {
+	map = rcu_dereference(rxqueue->rps_map);
+	if (map) {
+		if (map->len == 1) {
 			tcpu = map->cpus[0];
 			if (cpu_online(tcpu))
 				cpu = tcpu;
 			goto done;
 		}
-	} else if (!rxqueue->rps_flow_table) {
+	} else if (!rcu_dereference_raw(rxqueue->rps_flow_table)) {
 		goto done;
 	}
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b143173..a5ff5a8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -598,7 +598,8 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	}
 
 	spin_lock(&rps_map_lock);
-	old_map = queue->rps_map;
+	old_map = rcu_dereference_protected(queue->rps_map,
+					    lockdep_is_held(&rps_map_lock));
 	rcu_assign_pointer(queue->rps_map, map);
 	spin_unlock(&rps_map_lock);
 
@@ -677,7 +678,8 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 		table = NULL;
 
 	spin_lock(&rps_dev_flow_lock);
-	old_table = queue->rps_flow_table;
+	old_table = rcu_dereference_protected(queue->rps_flow_table,
+					      lockdep_is_held(&rps_dev_flow_lock));
 	rcu_assign_pointer(queue->rps_flow_table, table);
 	spin_unlock(&rps_dev_flow_lock);
 
@@ -705,13 +707,17 @@ static void rx_queue_release(struct kobject *kobj)
 {
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 	struct netdev_rx_queue *first = queue->first;
+	struct rps_map *map;
+	struct rps_dev_flow_table *flow_table;
 
-	if (queue->rps_map)
-		call_rcu(&queue->rps_map->rcu, rps_map_release);
 
-	if (queue->rps_flow_table)
-		call_rcu(&queue->rps_flow_table->rcu,
-		    rps_dev_flow_table_release);
+	map = rcu_dereference_raw(queue->rps_map);
+	if (map)
+		call_rcu(&map->rcu, rps_map_release);
+
+	flow_table = rcu_dereference_raw(queue->rps_flow_table);
+	if (flow_table)
+		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
 
 	if (atomic_dec_and_test(&first->count))
 		kfree(first);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 01eee5d..385b609 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -34,7 +34,8 @@ static int rps_sock_flow_sysctl(ctl_table *table, int write,
 
 	mutex_lock(&sock_flow_mutex);
 
-	orig_sock_table = rps_sock_flow_table;
+	orig_sock_table = rcu_dereference_protected(rps_sock_flow_table,
+					lockdep_is_held(&sock_flow_mutex));
 	size = orig_size = orig_sock_table ? orig_sock_table->mask + 1 : 0;
 
 	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);


