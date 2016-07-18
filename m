From: kan.liang@intel.com
Subject: [RFC PATCH 10/30] net/netpolicy: introduce netpolicy object
Date: Sun, 17 Jul 2016 23:56:04 -0700
Message-ID: <1468824984-65318-11-git-send-email-kan.liang@intel.com>
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

This patch introduces the concept of netpolicy object and policy object
list.

The netpolicy object is the instance of CPU/queue mapping. The object
can be shared between different tasks/sockets. So besides CPU and queue
information, the object also maintains a reference counter.

Each policy will have a dedicated object list. If the policy is set as
device policy, all objects will be inserted into the related policy
object list. The user will search and pickup the available objects from
the list later.

The network performance for objects could be different because of the
queue and CPU topology. To generate a proper object list, dev location,
HT and CPU topology have to be considered. The high performance objects
are in the front of the list.

The object lists will be regenerated if sys mapping changes or device
net policy changes.

Lock np_ob_list_lock is used to protect the object list.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netdevice.h |   2 +
 include/linux/netpolicy.h |  15 +++
 net/core/netpolicy.c      | 237 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 253 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3470943..e60c30f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1600,6 +1600,7 @@ enum netdev_priv_flags {
  *	@proc_dev:	device node in proc to configure device net policy
  *	@netpolicy:	NET policy related information of net device
  *	@np_lock:	protect the state of NET policy
+ *	@np_ob_list_lock:	protect the net policy object list
  *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
@@ -1874,6 +1875,7 @@ struct net_device {
 #endif /* CONFIG_PROC_FS */
 	struct netpolicy_info	*netpolicy;
 	spinlock_t		np_lock;
+	spinlock_t		np_ob_list_lock;
 #endif /* CONFIG_NETPOLICY */
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index a946b75c..73a5fa6 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -21,6 +21,12 @@ enum netpolicy_name {
 	NET_POLICY_MAX,
 };
 
+enum netpolicy_traffic {
+	NETPOLICY_RX		= 0,
+	NETPOLICY_TX,
+	NETPOLICY_RXTX,
+};
+
 extern const char *policy_name[];
 
 struct netpolicy_dev_info {
@@ -46,11 +52,20 @@ struct netpolicy_sys_info {
 	struct netpolicy_sys_map	*tx;
 };
 
+struct netpolicy_object {
+	struct list_head	list;
+	u32			cpu;
+	u32			queue;
+	atomic_t		refcnt;
+};
+
 struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
+	/* List of policy objects 0 rx 1 tx */
+	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
 };
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 7d4a49d..0f8ff16 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -35,6 +35,7 @@
 #include <linux/uaccess.h>
 #include <linux/netdevice.h>
 #include <net/net_namespace.h>
+#include <linux/sort.h>
 
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
@@ -161,10 +162,30 @@ static void netpolicy_set_affinity(struct net_device *dev)
 	}
 }
 
+static void netpolicy_free_obj_list(struct net_device *dev)
+{
+	int i, j;
+	struct netpolicy_object *obj, *tmp;
+
+	spin_lock(&dev->np_ob_list_lock);
+	for (i = 0; i < NETPOLICY_RXTX; i++) {
+		for (j = NET_POLICY_NONE; j < NET_POLICY_MAX; j++) {
+			if (list_empty(&dev->netpolicy->obj_list[i][j]))
+				continue;
+			list_for_each_entry_safe(obj, tmp, &dev->netpolicy->obj_list[i][j], list) {
+				list_del(&obj->list);
+				kfree(obj);
+			}
+		}
+	}
+	spin_unlock(&dev->np_ob_list_lock);
+}
+
 static int netpolicy_disable(struct net_device *dev)
 {
 	netpolicy_clear_affinity(dev);
 	netpolicy_free_sys_map(dev);
+	netpolicy_free_obj_list(dev);
 
 	return 0;
 }
@@ -203,6 +224,212 @@ static int netpolicy_enable(struct net_device *dev)
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE"
 };
+
+static u32 cpu_to_queue(struct net_device *dev,
+			u32 cpu, bool is_rx)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+	int i;
+
+	if (is_rx) {
+		for (i = 0; i < s_info->avail_rx_num; i++) {
+			if (s_info->rx[i].cpu == cpu)
+				return s_info->rx[i].queue;
+		}
+	} else {
+		for (i = 0; i < s_info->avail_tx_num; i++) {
+			if (s_info->tx[i].cpu == cpu)
+				return s_info->tx[i].queue;
+		}
+	}
+
+	return ~0;
+}
+
+static int netpolicy_add_obj(struct net_device *dev,
+			     u32 cpu, bool is_rx,
+			     enum netpolicy_name policy)
+{
+	struct netpolicy_object *obj;
+	int dir = is_rx ? NETPOLICY_RX : NETPOLICY_TX;
+
+	obj = kzalloc(sizeof(*obj), GFP_ATOMIC);
+	if (!obj)
+		return -ENOMEM;
+	obj->cpu = cpu;
+	obj->queue = cpu_to_queue(dev, cpu, is_rx);
+	list_add_tail(&obj->list, &dev->netpolicy->obj_list[dir][policy]);
+
+	return 0;
+}
+
+struct sort_node {
+	int	node;
+	int	distance;
+};
+
+static inline int node_distance_cmp(const void *a, const void *b)
+{
+	const struct sort_node *_a = a;
+	const struct sort_node *_b = b;
+
+	return _a->distance - _b->distance;
+}
+
+static int _netpolicy_gen_obj_list(struct net_device *dev, bool is_rx,
+				   enum netpolicy_name policy,
+				   struct sort_node *nodes, int num_node,
+				   struct cpumask *node_avail_cpumask)
+{
+	cpumask_var_t node_tmp_cpumask, sibling_tmp_cpumask;
+	struct cpumask *node_assigned_cpumask;
+	int i, ret = -ENOMEM;
+	u32 cpu;
+
+	if (!alloc_cpumask_var(&node_tmp_cpumask, GFP_ATOMIC))
+		return ret;
+	if (!alloc_cpumask_var(&sibling_tmp_cpumask, GFP_ATOMIC))
+		goto alloc_fail1;
+
+	node_assigned_cpumask = kcalloc(num_node, sizeof(struct cpumask), GFP_ATOMIC);
+	if (!node_assigned_cpumask)
+		goto alloc_fail2;
+
+	/* Don't share physical core */
+	for (i = 0; i < num_node; i++) {
+		if (cpumask_weight(&node_avail_cpumask[nodes[i].node]) == 0)
+			continue;
+		spin_lock(&dev->np_ob_list_lock);
+		cpumask_copy(node_tmp_cpumask, &node_avail_cpumask[nodes[i].node]);
+		while (cpumask_weight(node_tmp_cpumask)) {
+			cpu = cpumask_first(node_tmp_cpumask);
+
+			/* push to obj list */
+			ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
+			if (ret) {
+				spin_unlock(&dev->np_ob_list_lock);
+				goto err;
+			}
+
+			cpumask_set_cpu(cpu, &node_assigned_cpumask[nodes[i].node]);
+			cpumask_and(sibling_tmp_cpumask, node_tmp_cpumask, topology_sibling_cpumask(cpu));
+			cpumask_xor(node_tmp_cpumask, node_tmp_cpumask, sibling_tmp_cpumask);
+		}
+		spin_unlock(&dev->np_ob_list_lock);
+	}
+
+	for (i = 0; i < num_node; i++) {
+		cpumask_xor(node_tmp_cpumask, &node_avail_cpumask[nodes[i].node], &node_assigned_cpumask[nodes[i].node]);
+		if (cpumask_weight(node_tmp_cpumask) == 0)
+			continue;
+		spin_lock(&dev->np_ob_list_lock);
+		for_each_cpu(cpu, node_tmp_cpumask) {
+			/* push to obj list */
+			ret = netpolicy_add_obj(dev, cpu, is_rx, policy);
+			if (ret) {
+				spin_unlock(&dev->np_ob_list_lock);
+				goto err;
+			}
+			cpumask_set_cpu(cpu, &node_assigned_cpumask[nodes[i].node]);
+		}
+		spin_unlock(&dev->np_ob_list_lock);
+	}
+
+err:
+	kfree(node_assigned_cpumask);
+alloc_fail2:
+	free_cpumask_var(sibling_tmp_cpumask);
+alloc_fail1:
+	free_cpumask_var(node_tmp_cpumask);
+
+	return ret;
+}
+
+static int netpolicy_gen_obj_list(struct net_device *dev,
+				  enum netpolicy_name policy)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+	struct cpumask *node_avail_cpumask;
+	int dev_node = 0, num_nodes = 1;
+	struct sort_node *nodes;
+	int i, ret, node = 0;
+	u32 cpu;
+#ifdef CONFIG_NUMA
+	int val;
+#endif
+	/* The network performance for objects could be different
+	 * because of the queue and cpu topology.
+	 * The objects will be ordered accordingly,
+	 * and put high performance object in the front.
+	 *
+	 * The priority rules as below,
+	 * - The local object. (Local means cpu and queue are in the same node.)
+	 * - The cpu in the object is the only logical core in physical core.
+	 *   The sibiling core's object has not been added in the object list yet.
+	 * - The rest of objects
+	 *
+	 * So the order of object list is as below:
+	 * 1. Local core + the only logical core
+	 * 2. Remote core + the only logical core
+	 * 3. Local core + the core's sibling is already in the object list
+	 * 4. Remote core + the core's sibling is already in the object list
+	 */
+#ifdef CONFIG_NUMA
+	dev_node = dev_to_node(dev->dev.parent);
+	num_nodes = num_online_nodes();
+#endif
+
+	nodes = kcalloc(num_nodes, sizeof(*nodes), GFP_ATOMIC);
+	if (!nodes)
+		return -ENOMEM;
+
+	node_avail_cpumask = kcalloc(num_nodes, sizeof(struct cpumask), GFP_ATOMIC);
+	if (!node_avail_cpumask) {
+		kfree(nodes);
+		return -ENOMEM;
+	}
+
+#ifdef CONFIG_NUMA
+	/* order the node from near to far */
+	for_each_node_mask(i, node_online_map) {
+		val = node_distance(dev_node, i);
+		nodes[node].node = i;
+		nodes[node].distance = val;
+		node++;
+	}
+	sort(nodes, num_nodes, sizeof(*nodes),
+	     node_distance_cmp, NULL);
+#else
+	nodes[0].node = 0;
+#endif
+
+	for (i = 0; i < s_info->avail_rx_num; i++) {
+		cpu = s_info->rx[i].cpu;
+		cpumask_set_cpu(cpu, &node_avail_cpumask[cpu_to_node(cpu)]);
+	}
+	ret = _netpolicy_gen_obj_list(dev, true, policy, nodes,
+				      node, node_avail_cpumask);
+	if (ret)
+		goto err;
+
+	for (i = 0; i < node; i++)
+		cpumask_clear(&node_avail_cpumask[nodes[i].node]);
+
+	for (i = 0; i < s_info->avail_tx_num; i++) {
+		cpu = s_info->tx[i].cpu;
+		cpumask_set_cpu(cpu, &node_avail_cpumask[cpu_to_node(cpu)]);
+	}
+	ret = _netpolicy_gen_obj_list(dev, false, policy, nodes,
+				      node, node_avail_cpumask);
+	if (ret)
+		goto err;
+
+err:
+	kfree(nodes);
+	kfree(node_avail_cpumask);
+	return ret;
+}
+
 #ifdef CONFIG_PROC_FS
 
 static int net_policy_proc_show(struct seq_file *m, void *v)
@@ -258,7 +485,7 @@ static int netpolicy_proc_dev_init(struct net *net, struct net_device *dev)
 
 int init_netpolicy(struct net_device *dev)
 {
-	int ret;
+	int ret, i, j;
 
 	spin_lock(&dev->np_lock);
 	ret = 0;
@@ -281,7 +508,15 @@ int init_netpolicy(struct net_device *dev)
 	if (ret) {
 		kfree(dev->netpolicy);
 		dev->netpolicy = NULL;
+		goto unlock;
+	}
+
+	spin_lock(&dev->np_ob_list_lock);
+	for (i = 0; i < NETPOLICY_RXTX; i++) {
+		for (j = NET_POLICY_NONE; j < NET_POLICY_MAX; j++)
+			INIT_LIST_HEAD(&dev->netpolicy->obj_list[i][j]);
 	}
+	spin_unlock(&dev->np_ob_list_lock);
 
 unlock:
 	spin_unlock(&dev->np_lock);
-- 
2.5.5
