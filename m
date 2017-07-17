From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH 2/2] openvswitch: Optimize operations for OvS flow_stats.
Date: Sun, 16 Jul 2017 23:29:24 -0700
Message-ID: <1500272964-27238-2-git-send-email-xiangxia.m.yue@gmail.com>
References: <1500272964-27238-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, dev@openvswitch.org,
        Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33261 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdGQG35 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 02:29:57 -0400
Received: by mail-pf0-f195.google.com with SMTP id e199so18510445pfh.0
        for <netdev@vger.kernel.org>; Sun, 16 Jul 2017 23:29:56 -0700 (PDT)
In-Reply-To: <1500272964-27238-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calling the flow_free() to free the flow, we call many times
(cpu_possible_mask, eg. 128 as default) cpumask_next(). That will
take up our CPU usage if we call the flow_free() frequently.
When we put all packets to userspace via upcall, and OvS will send
them back via netlink to ovs_packet_cmd_execute(will call flow_free).

The test topo is shown as below. VM01 sends TCP packets to VM02,
and OvS forward packtets. When testing, we use perf to report the
system performance.

VM01 --- OvS-VM --- VM02

Without this patch, perf-top show as below: The flow_free() is
3.02% CPU usage.

	4.23%  [kernel]            [k] _raw_spin_unlock_irqrestore
	3.62%  [kernel]            [k] __do_softirq
	3.16%  [kernel]            [k] __memcpy
	3.02%  [kernel]            [k] flow_free
	2.42%  libc-2.17.so        [.] __memcpy_ssse3_back
	2.18%  [kernel]            [k] copy_user_generic_unrolled
	2.17%  [kernel]            [k] find_next_bit

When applied this patch, perf-top show as below: Not shown on
the list anymore.

	4.11%  [kernel]            [k] _raw_spin_unlock_irqrestore
	3.79%  [kernel]            [k] __do_softirq
	3.46%  [kernel]            [k] __memcpy
	2.73%  libc-2.17.so        [.] __memcpy_ssse3_back
	2.25%  [kernel]            [k] copy_user_generic_unrolled
	1.89%  libc-2.17.so        [.] _int_malloc
	1.53%  ovs-vswitchd        [.] xlate_actions

With this patch, the TCP throughput(we dont use Megaflow Cache
+ Microflow Cache) between VMs is 1.18Gbs/sec up to 1.30Gbs/sec
(maybe ~10% performance imporve).

This patch adds cpumask struct, the cpu_used_mask stores the cpu_id
that the flow used. And we only check the flow_stats on the cpu we
used, and it is unncessary to check all possible cpu when getting,
cleaning, and updating the flow_stats. Adding the cpu_used_mask to
sw_flow struct does’t increase the cacheline number.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/openvswitch/flow.c       | 7 ++++---
 net/openvswitch/flow.h       | 2 ++
 net/openvswitch/flow_table.c | 5 ++++-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 89aeb32..cfb652a 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -72,7 +72,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 			   const struct sk_buff *skb)
 {
 	struct flow_stats *stats;
-	int cpu = smp_processor_id();
+	unsigned int cpu = smp_processor_id();
 	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	stats = rcu_dereference(flow->stats[cpu]);
@@ -117,6 +117,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 
 					rcu_assign_pointer(flow->stats[cpu],
 							   new_stats);
+					cpumask_set_cpu(cpu, &flow->cpu_used_mask);
 					goto unlock;
 				}
 			}
@@ -144,7 +145,7 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
 	memset(ovs_stats, 0, sizeof(*ovs_stats));
 
 	/* We open code this to make sure cpu 0 is always considered */
-	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask)) {
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, &flow->cpu_used_mask)) {
 		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[cpu]);
 
 		if (stats) {
@@ -168,7 +169,7 @@ void ovs_flow_stats_clear(struct sw_flow *flow)
 	int cpu;
 
 	/* We open code this to make sure cpu 0 is always considered */
-	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask)) {
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, &flow->cpu_used_mask)) {
 		struct flow_stats *stats = ovsl_dereference(flow->stats[cpu]);
 
 		if (stats) {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a9bc1c8..1875bba 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -31,6 +31,7 @@
 #include <linux/jiffies.h>
 #include <linux/time.h>
 #include <linux/flex_array.h>
+#include <linux/cpumask.h>
 #include <net/inet_ecn.h>
 #include <net/ip_tunnels.h>
 #include <net/dst_metadata.h>
@@ -219,6 +220,7 @@ struct sw_flow {
 					 */
 	struct sw_flow_key key;
 	struct sw_flow_id id;
+	struct cpumask cpu_used_mask;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
 	struct flow_stats __rcu *stats[]; /* One for each CPU.  First one
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index ea7a807..324a246 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -98,6 +98,9 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	RCU_INIT_POINTER(flow->stats[0], stats);
 
+	cpumask_clear(&flow->cpu_used_mask);
+	cpumask_set_cpu(0, &flow->cpu_used_mask);
+
 	return flow;
 err:
 	kmem_cache_free(flow_cache, flow);
@@ -141,7 +144,7 @@ static void flow_free(struct sw_flow *flow)
 	if (flow->sf_acts)
 		ovs_nla_free_flow_actions((struct sw_flow_actions __force *)flow->sf_acts);
 	/* We open code this to make sure cpu 0 is always considered */
-	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask))
+	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, &flow->cpu_used_mask))
 		if (flow->stats[cpu])
 			kmem_cache_free(flow_stats_cache,
 					(struct flow_stats __force *)flow->stats[cpu]);
-- 
1.8.3.1
