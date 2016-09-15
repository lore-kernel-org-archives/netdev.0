From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH v2 2/2] openvswitch: use percpu flow stats
Date: Thu, 15 Sep 2016 19:11:53 -0300
Message-ID: <1473977513-7617-2-git-send-email-cascardo@redhat.com>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
Cc: dev@openvswitch.org, pshelar@ovn.org,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52140 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756417AbcIOWNW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 18:13:22 -0400
In-Reply-To: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using flow stats per NUMA node, use it per CPU. When using
megaflows, the stats lock can be a bottleneck in scalability.

On a E5-2690 12-core system, usual throughput went from ~4Mpps to
~15Mpps when forwarding between two 40GbE ports with a single flow
configured on the datapath.

This has been tested on a system with possible CPUs 0-7,16-23. After
module removal, there were no corruption on the slab cache.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>
---

v2:
* use smp_processor_id as ovs_flow_stats_update is always called from BH
context
* use kmem_cache_zalloc to allocate flow

---
 net/openvswitch/flow.c       | 42 ++++++++++++++++++++++--------------------
 net/openvswitch/flow.h       |  4 ++--
 net/openvswitch/flow_table.c | 26 +++++++++-----------------
 3 files changed, 33 insertions(+), 39 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 5b80612..0fa45439 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/in.h>
 #include <linux/rcupdate.h>
+#include <linux/cpumask.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -72,32 +73,33 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 {
 	struct flow_stats *stats;
 	int node = numa_node_id();
+	int cpu = smp_processor_id();
 	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
-	stats = rcu_dereference(flow->stats[node]);
+	stats = rcu_dereference(flow->stats[cpu]);
 
-	/* Check if already have node-specific stats. */
+	/* Check if already have CPU-specific stats. */
 	if (likely(stats)) {
 		spin_lock(&stats->lock);
 		/* Mark if we write on the pre-allocated stats. */
-		if (node == 0 && unlikely(flow->stats_last_writer != node))
-			flow->stats_last_writer = node;
+		if (cpu == 0 && unlikely(flow->stats_last_writer != cpu))
+			flow->stats_last_writer = cpu;
 	} else {
 		stats = rcu_dereference(flow->stats[0]); /* Pre-allocated. */
 		spin_lock(&stats->lock);
 
-		/* If the current NUMA-node is the only writer on the
+		/* If the current CPU is the only writer on the
 		 * pre-allocated stats keep using them.
 		 */
-		if (unlikely(flow->stats_last_writer != node)) {
+		if (unlikely(flow->stats_last_writer != cpu)) {
 			/* A previous locker may have already allocated the
-			 * stats, so we need to check again.  If node-specific
+			 * stats, so we need to check again.  If CPU-specific
 			 * stats were already allocated, we update the pre-
 			 * allocated stats as we have already locked them.
 			 */
-			if (likely(flow->stats_last_writer != NUMA_NO_NODE)
-			    && likely(!rcu_access_pointer(flow->stats[node]))) {
-				/* Try to allocate node-specific stats. */
+			if (likely(flow->stats_last_writer != -1) &&
+			    likely(!rcu_access_pointer(flow->stats[cpu]))) {
+				/* Try to allocate CPU-specific stats. */
 				struct flow_stats *new_stats;
 
 				new_stats =
@@ -114,12 +116,12 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 					new_stats->tcp_flags = tcp_flags;
 					spin_lock_init(&new_stats->lock);
 
-					rcu_assign_pointer(flow->stats[node],
+					rcu_assign_pointer(flow->stats[cpu],
 							   new_stats);
 					goto unlock;
 				}
 			}
-			flow->stats_last_writer = node;
+			flow->stats_last_writer = cpu;
 		}
 	}
 
@@ -136,15 +138,15 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
 			struct ovs_flow_stats *ovs_stats,
 			unsigned long *used, __be16 *tcp_flags)
 {
-	int node;
+	int cpu;
 
 	*used = 0;
 	*tcp_flags = 0;
 	memset(ovs_stats, 0, sizeof(*ovs_stats));
 
-	/* We open code this to make sure node 0 is always considered */
-	for (node = 0; node < MAX_NUMNODES; node = next_node(node, node_possible_map)) {
-		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[node]);
+	/* We open code this to make sure cpu 0 is always considered */
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask)) {
+		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[cpu]);
 
 		if (stats) {
 			/* Local CPU may write on non-local stats, so we must
@@ -164,11 +166,11 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
 /* Called with ovs_mutex. */
 void ovs_flow_stats_clear(struct sw_flow *flow)
 {
-	int node;
+	int cpu;
 
-	/* We open code this to make sure node 0 is always considered */
-	for (node = 0; node < MAX_NUMNODES; node = next_node(node, node_possible_map)) {
-		struct flow_stats *stats = ovsl_dereference(flow->stats[node]);
+	/* We open code this to make sure cpu 0 is always considered */
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask)) {
+		struct flow_stats *stats = ovsl_dereference(flow->stats[cpu]);
 
 		if (stats) {
 			spin_lock_bh(&stats->lock);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 156a302..ae783f5 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -178,14 +178,14 @@ struct sw_flow {
 		struct hlist_node node[2];
 		u32 hash;
 	} flow_table, ufid_table;
-	int stats_last_writer;		/* NUMA-node id of the last writer on
+	int stats_last_writer;		/* CPU id of the last writer on
 					 * 'stats[0]'.
 					 */
 	struct sw_flow_key key;
 	struct sw_flow_id id;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
-	struct flow_stats __rcu *stats[]; /* One for each NUMA node.  First one
+	struct flow_stats __rcu *stats[]; /* One for each CPU.  First one
 					   * is allocated at flow creation time,
 					   * the rest are allocated on demand
 					   * while holding the 'stats[0].lock'.
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 957a3c3..ea7a807 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/in.h>
 #include <linux/rcupdate.h>
+#include <linux/cpumask.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -79,17 +80,12 @@ struct sw_flow *ovs_flow_alloc(void)
 {
 	struct sw_flow *flow;
 	struct flow_stats *stats;
-	int node;
 
-	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
+	flow = kmem_cache_zalloc(flow_cache, GFP_KERNEL);
 	if (!flow)
 		return ERR_PTR(-ENOMEM);
 
-	flow->sf_acts = NULL;
-	flow->mask = NULL;
-	flow->id.unmasked_key = NULL;
-	flow->id.ufid_len = 0;
-	flow->stats_last_writer = NUMA_NO_NODE;
+	flow->stats_last_writer = -1;
 
 	/* Initialize the default stat node. */
 	stats = kmem_cache_alloc_node(flow_stats_cache,
@@ -102,10 +98,6 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	RCU_INIT_POINTER(flow->stats[0], stats);
 
-	for_each_node(node)
-		if (node != 0)
-			RCU_INIT_POINTER(flow->stats[node], NULL);
-
 	return flow;
 err:
 	kmem_cache_free(flow_cache, flow);
@@ -142,17 +134,17 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
 
 static void flow_free(struct sw_flow *flow)
 {
-	int node;
+	int cpu;
 
 	if (ovs_identifier_is_key(&flow->id))
 		kfree(flow->id.unmasked_key);
 	if (flow->sf_acts)
 		ovs_nla_free_flow_actions((struct sw_flow_actions __force *)flow->sf_acts);
-	/* We open code this to make sure node 0 is always considered */
-	for (node = 0; node < MAX_NUMNODES; node = next_node(node, node_possible_map))
-		if (node != 0 && flow->stats[node])
+	/* We open code this to make sure cpu 0 is always considered */
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask))
+		if (flow->stats[cpu])
 			kmem_cache_free(flow_stats_cache,
-					(struct flow_stats __force *)flow->stats[node]);
+					(struct flow_stats __force *)flow->stats[cpu]);
 	kmem_cache_free(flow_cache, flow);
 }
 
@@ -757,7 +749,7 @@ int ovs_flow_init(void)
 	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
 
 	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow)
-				       + (nr_node_ids
+				       + (nr_cpu_ids
 					  * sizeof(struct flow_stats *)),
 				       0, 0, NULL);
 	if (flow_cache == NULL)
-- 
2.7.4
