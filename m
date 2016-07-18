From: kan.liang@intel.com
Subject: [RFC PATCH 14/30] net/netpolicy: add MIX policy
Date: Sun, 17 Jul 2016 23:56:08 -0700
Message-ID: <1468824984-65318-15-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

MIX policy is combine of other policies. It allows different queue has
different policy. If MIX policy is applied,
/proc/net/netpolicy/$DEV/policy shows per queue policy.
Usually, the workloads requires either high throughput or low latency.
So for current implementation, MIX policy is combine of latency policy
and bulk policy.
The workloads which requires high throughput are usually utilize more
CPU resources compared to the workloads which requires low latency. This
means that if there is an equal interest in latency and throughput
performance, it is better to reserve more bulk queues than latency
queues.
In this patch, MIX policy is forced to include 1/3 latency policy queues
and 2/3 bulk policy queues.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |   7 +++
 net/core/netpolicy.c      | 139 ++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 136 insertions(+), 10 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 3d348a7..579ff98 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -22,6 +22,12 @@ enum netpolicy_name {
 	NET_POLICY_BULK,
 	NET_POLICY_LATENCY,
 	NET_POLICY_MAX,
+
+	/*
+	 * Mixture of the above policy
+	 * Can only be set as global policy.
+	 */
+	NET_POLICY_MIX,
 };
 
 enum netpolicy_traffic {
@@ -66,6 +72,7 @@ struct netpolicy_object {
 struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
+	bool	has_mix_policy;
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 71e9163..8336106 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -280,6 +280,9 @@ static inline int node_distance_cmp(const void *a, const void *b)
 	return _a->distance - _b->distance;
 }
 
+#define mix_latency_num(num)	((num) / 3)
+#define mix_throughput_num(num)	((num) - mix_latency_num(num))
+
 static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 				   enum netpolicy_name policy,
 				   struct sort_node *nodes, int num_node,
@@ -287,7 +290,9 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 {
 	cpumask_var_t node_tmp_cpumask, sibling_tmp_cpumask;
 	struct cpumask *node_assigned_cpumask;
+	int *l_num = NULL, *b_num = NULL;
 	int i, ret = -ENOMEM;
+	int num_node_cpu;
 	u32 cpu;
 
 	if (!alloc_cpumask_var(&node_tmp_cpumask, GFP_ATOMIC))
@@ -299,6 +304,23 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 	if (!node_assigned_cpumask)
 		goto alloc_fail2;
 
+	if (policy == NET_POLICY_MIX) {
+		l_num = kcalloc(num_node, sizeof(int), GFP_ATOMIC);
+		if (!l_num)
+			goto alloc_fail3;
+		b_num = kcalloc(num_node, sizeof(int), GFP_ATOMIC);
+		if (!b_num) {
+			kfree(l_num);
+			goto alloc_fail3;
+		}
+
+		for (i = 0; i < num_node; i++) {
+			num_node_cpu = cpumask_weight(&node_avail_cpumask[nodes[i].node]);
+			l_num[i] = mix_latency_num(num_node_cpu);
+			b_num[i] = mix_throughput_num(num_node_cpu);
+		}
+	}
+
 	/* Don't share physical core */
 	for (i = 0; i < num_node; i++) {
 		if (cpumask_weight(&node_avail_cpumask[nodes[i].node]) == 0)
@@ -309,7 +331,13 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 			cpu = cpumask_first(node_tmp_cpumask);
 
 			/* push to obj list */
-			ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
+			if (policy == NET_POLICY_MIX) {
+				if (l_num[i]-- > 0)
+					ret = netpolicy_add_obj(dev, cpu, is_rx, NET_POLICY_LATENCY);
+				else if (b_num[i]-- > 0)
+					ret = netpolicy_add_obj(dev, cpu, is_rx, NET_POLICY_BULK);
+			} else
+				ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
 			if (ret) {
 				spin_unlock(&dev->np_ob_list_lock);
 				goto err;
@@ -322,6 +350,41 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 		spin_unlock(&dev->np_ob_list_lock);
 	}
 
+	if (policy == NET_POLICY_MIX) {
+		struct netpolicy_object *obj;
+		int dir = is_rx ? 0 : 1;
+		u32 sibling;
+
+		/* if have to share core, choose latency core first. */
+		for (i = 0; i < num_node; i++) {
+			if ((l_num[i] < 1) && (b_num[i] < 1))
+				continue;
+			spin_lock(&dev->np_ob_list_lock);
+			list_for_each_entry(obj, &dev->netpolicy->obj_list[dir][NET_POLICY_LATENCY], list) {
+				if (cpu_to_node(obj->cpu) != nodes[i].node)
+					continue;
+
+				cpu = obj->cpu;
+				for_each_cpu(sibling, topology_sibling_cpumask(cpu)) {
+					if (cpumask_test_cpu(sibling, &node_assigned_cpumask[nodes[i].node]) ||
+					    !cpumask_test_cpu(sibling, &node_avail_cpumask[nodes[i].node]))
+						continue;
+
+					if (l_num[i]-- > 0)
+						ret = netpolicy_add_obj(dev, sibling, is_rx, NET_POLICY_LATENCY);
+					else if (b_num[i]-- > 0)
+						ret = netpolicy_add_obj(dev, sibling, is_rx, NET_POLICY_BULK);
+					if (ret) {
+						spin_unlock(&dev->np_ob_list_lock);
+						goto err;
+					}
+					cpumask_set_cpu(sibling, &node_assigned_cpumask[nodes[i].node]);
+				}
+			}
+			spin_unlock(&dev->np_ob_list_lock);
+		}
+	}
+
 	for (i = 0; i < num_node; i++) {
 		cpumask_xor(node_tmp_cpumask, &node_avail_cpumask[nodes[i].node], &node_assigned_cpumask[nodes[i].node]);
 		if (cpumask_weight(node_tmp_cpumask) == 0)
@@ -329,7 +392,15 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 		spin_lock(&dev->np_ob_list_lock);
 		for_each_cpu(cpu, node_tmp_cpumask) {
 			/* push to obj list */
-			ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
+			if (policy == NET_POLICY_MIX) {
+				if (l_num[i]-- > 0)
+					ret = netpolicy_add_obj(dev, cpu, is_rx, NET_POLICY_LATENCY);
+				else if (b_num[i]-- > 0)
+					ret = netpolicy_add_obj(dev, cpu, is_rx, NET_POLICY_BULK);
+				else
+					ret = netpolicy_add_obj(dev, cpu, is_rx, NET_POLICY_NONE);
+			} else
+				ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
 			if (ret) {
 				spin_unlock(&dev->np_ob_list_lock);
 				goto err;
@@ -340,6 +411,11 @@ static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
 	}
 
 err:
+	if (policy == NET_POLICY_MIX) {
+		kfree(l_num);
+		kfree(b_num);
+	}
+alloc_fail3:
 	kfree(node_assigned_cpumask);
 alloc_fail2:
 	free_cpumask_var(sibling_tmp_cpumask);
@@ -377,6 +453,22 @@ static int netpolicy_gen_obj_list(struct net_device *dev,
 	 * 2. Remote core + the only logical core
 	 * 3. Local core + the core's sibling is already in the object list
 	 * 4. Remote core + the core's sibling is already in the object list
+	 *
+	 * For MIX policy, on each node, force 1/3 core as latency policy core,
+	 * the rest cores are bulk policy core.
+	 *
+	 * Besides the above priority rules, there is one more rule
+	 * - If it's sibling core's object has been applied a policy
+	 *   Choose the object which the sibling logical core applies latency policy first
+	 *
+	 * So the order of object list for MIX policy is as below:
+	 * 1. Local core + the only logical core
+	 * 2. Remote core + the only logical core
+	 * 3. Local core + the core's sibling is latency policy core
+	 * 4. Remote core + the core's sibling is latency policy core
+	 * 5. Local core + the core's sibling is bulk policy core
+	 * 6. Remote core + the core's sibling is bulk policy core
+	 *
 	 */
 #ifdef CONFIG_NUMA
 	dev_node = dev_to_node(dev->dev.parent);
@@ -447,14 +539,23 @@ static int net_policy_set_by_name(char *name, struct net_device *dev)
 		goto unlock;
 	}
 
-	for (i = 0; i < NET_POLICY_MAX; i++) {
-		if (!strncmp(name, policy_name[i], strlen(policy_name[i])))
-		break;
-	}
+	if (!strncmp(name, "MIX", strlen("MIX"))) {
+		if (dev->netpolicy->has_mix_policy) {
+			i = NET_POLICY_MIX;
+		} else {
+			ret = -ENOTSUPP;
+			goto unlock;
+		}
+	} else {
+		for (i = 0; i < NET_POLICY_MAX; i++) {
+			if (!strncmp(name, policy_name[i], strlen(policy_name[i])))
+			break;
+		}
 
-	if (!test_bit(i, dev->netpolicy->avail_policy)) {
-		ret = -ENOTSUPP;
-		goto unlock;
+		if (!test_bit(i, dev->netpolicy->avail_policy)) {
+			ret = -ENOTSUPP;
+			goto unlock;
+		}
 	}
 
 	if (i == dev->netpolicy->cur_policy)
@@ -502,17 +603,35 @@ unlock:
 static int net_policy_proc_show(struct seq_file *m, void *v)
 {
 	struct net_device *dev = (struct net_device *)m->private;
+	enum netpolicy_name cur;
+	struct netpolicy_object *obj, *tmp;
 	int i;
 
 	if (WARN_ON(!dev->netpolicy))
 		return -EINVAL;
 
-	if (dev->netpolicy->cur_policy == NET_POLICY_NONE) {
+	cur = dev->netpolicy->cur_policy;
+	if (cur == NET_POLICY_NONE) {
 		seq_printf(m, "%s: There is no policy applied\n", dev->name);
 		seq_printf(m, "%s: The available policy include:", dev->name);
 		for_each_set_bit(i, dev->netpolicy->avail_policy, NET_POLICY_MAX)
 			seq_printf(m, " %s", policy_name[i]);
+		if (dev->netpolicy->has_mix_policy)
+			seq_printf(m, " MIX");
 		seq_printf(m, "\n");
+	} else if (cur == NET_POLICY_MIX) {
+		seq_printf(m, "%s: MIX policy is running on the system\n", dev->name);
+		spin_lock(&dev->np_ob_list_lock);
+		for (i = NET_POLICY_NONE; i < NET_POLICY_MAX; i++) {
+			seq_printf(m, "%s: queues for %s policy\n", dev->name, policy_name[i]);
+			list_for_each_entry_safe(obj, tmp, &dev->netpolicy->obj_list[NETPOLICY_RX][i], list) {
+				seq_printf(m, "%s: rx queue %d\n", dev->name, obj->queue);
+			}
+			list_for_each_entry_safe(obj, tmp, &dev->netpolicy->obj_list[NETPOLICY_TX][i], list) {
+				seq_printf(m, "%s: tx queue %d\n", dev->name, obj->queue);
+			}
+		}
+		spin_unlock(&dev->np_ob_list_lock);
 	} else {
 		seq_printf(m, "%s: POLICY %s is running on the system\n",
 			   dev->name, policy_name[dev->netpolicy->cur_policy]);
-- 
2.5.5
