From: kan.liang@intel.com
Subject: [RFC V3 PATCH 17/26] net/netpolicy: introduce netpolicy_pick_queue
Date: Mon, 12 Sep 2016 07:55:50 -0700
Message-ID: <1473692159-4017-18-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:43285 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759593AbcILO4q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 10:56:46 -0400
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

To achieve better network performance, the key step is to distribute the
packets to dedicated queues according to policy and system run time
status.

This patch provides an interface which can return the proper dedicated
queue for socket/task. Then the packets of the socket/task will be
redirect to the dedicated queue for better network performance.

For selecting the proper queue, currently it checks the CPU loads and
ref number. The object which has lowest CPU loads and ref number will be
chosen.

The selected object will be stored in hashtable. So it does not need to
go through the whole object list every time.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  12 ++++
 include/linux/sched.h     |   3 +
 kernel/sched/fair.c       |   8 +--
 net/core/netpolicy.c      | 179 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 198 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index ee33978..e06b74c 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -85,8 +85,15 @@ struct netpolicy_instance {
 	struct net_device	*dev;
 	enum netpolicy_name	policy; /* required policy */
 	void			*ptr;   /* pointers */
+	struct task_struct	*task;
 };
 
+struct netpolicy_cpu_load {
+	unsigned long		load;
+	struct netpolicy_object	*obj;
+};
+#define LOAD_TOLERANCE	5
+
 /* check if policy is valid */
 static inline int is_net_policy_valid(enum netpolicy_name policy)
 {
@@ -98,6 +105,7 @@ extern void update_netpolicy_sys_map(void);
 extern int netpolicy_register(struct netpolicy_instance *instance,
 			      enum netpolicy_name policy);
 extern void netpolicy_unregister(struct netpolicy_instance *instance);
+extern int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx);
 #else
 static inline void update_netpolicy_sys_map(void)
 {
@@ -112,6 +120,10 @@ static inline void netpolicy_unregister(struct netpolicy_instance *instance)
 {
 }
 
+static inline int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
+{
+	return 0;
+}
 #endif
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 62c68e5..3b716a3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3481,4 +3481,7 @@ void cpufreq_add_update_util_hook(int cpu, struct update_util_data *data,
 void cpufreq_remove_update_util_hook(int cpu);
 #endif /* CONFIG_CPU_FREQ */
 
+extern unsigned long weighted_cpuload(const int cpu);
+extern unsigned long capacity_of(int cpu);
+
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 039de34..a579ba2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1257,10 +1257,10 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
 	       group_faults_cpu(ng, src_nid) * group_faults(p, dst_nid) * 4;
 }
 
-static unsigned long weighted_cpuload(const int cpu);
+unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
-static unsigned long capacity_of(int cpu);
+unsigned long capacity_of(int cpu);
 static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
 
 /* Cached statistics for all CPUs within a node */
@@ -4752,7 +4752,7 @@ static void cpu_load_update(struct rq *this_rq, unsigned long this_load,
 }
 
 /* Used instead of source_load when we know the type == 0 */
-static unsigned long weighted_cpuload(const int cpu)
+unsigned long weighted_cpuload(const int cpu)
 {
 	return cfs_rq_runnable_load_avg(&cpu_rq(cpu)->cfs);
 }
@@ -4902,7 +4902,7 @@ static unsigned long target_load(int cpu, int type)
 	return max(rq->cpu_load[type-1], total);
 }
 
-static unsigned long capacity_of(int cpu)
+unsigned long capacity_of(int cpu)
 {
 	return cpu_rq(cpu)->cpu_capacity;
 }
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 503ebd1..e82e0d3 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -40,6 +40,7 @@
 #include <linux/ctype.h>
 #include <linux/cpu.h>
 #include <linux/hashtable.h>
+#include <linux/sched.h>
 
 struct netpolicy_record {
 	struct hlist_node	hash_node;
@@ -293,6 +294,184 @@ static void netpolicy_record_clear_dev_node(struct net_device *dev)
 	spin_unlock_bh(&np_hashtable_lock);
 }
 
+static struct netpolicy_object *get_avail_object(struct net_device *dev,
+						 enum netpolicy_name policy,
+						 struct netpolicy_instance *instance,
+						 bool is_rx)
+{
+	int avail_cpu_num = cpumask_weight(tsk_cpus_allowed(instance->task));
+	int dir = is_rx ? NETPOLICY_RX : NETPOLICY_TX;
+	struct netpolicy_object *tmp, *obj = NULL;
+	unsigned long load = 0, min_load = -1;
+	struct netpolicy_cpu_load *cpu_load;
+	int i = 0, val = -1;
+
+	/* Check if net policy is supported */
+	if (!dev || !dev->netpolicy)
+		goto exit;
+
+	/* The system should have queues which support the request policy. */
+	if ((policy != dev->netpolicy->cur_policy) &&
+	    (dev->netpolicy->cur_policy != NET_POLICY_MIX))
+		goto exit;
+
+	if (!avail_cpu_num)
+		goto exit;
+
+	cpu_load = kcalloc(avail_cpu_num, sizeof(*cpu_load), GFP_KERNEL);
+	if (!cpu_load)
+		goto exit;
+
+	spin_lock_bh(&dev->np_ob_list_lock);
+
+	/* find the lowest load and remove obvious high load objects */
+	list_for_each_entry(tmp, &dev->netpolicy->obj_list[dir][policy], list) {
+		if (!cpumask_test_cpu(tmp->cpu, tsk_cpus_allowed(instance->task)))
+			continue;
+
+#ifdef CONFIG_SMP
+		/* normalized load */
+		load = weighted_cpuload(tmp->cpu) * 100 / capacity_of(tmp->cpu);
+
+		if ((min_load != -1) &&
+		    load > (min_load + LOAD_TOLERANCE))
+			continue;
+#endif
+		cpu_load[i].load = load;
+		cpu_load[i].obj = tmp;
+		if ((min_load == -1) ||
+		    (load < min_load))
+			min_load = load;
+		i++;
+	}
+	avail_cpu_num = i;
+	spin_unlock_bh(&dev->np_ob_list_lock);
+
+	for (i = 0; i < avail_cpu_num; i++) {
+		if (cpu_load[i].load > (min_load + LOAD_TOLERANCE))
+			continue;
+
+		tmp = cpu_load[i].obj;
+		if ((val > atomic_read(&tmp->refcnt)) ||
+		    (val == -1)) {
+			val = atomic_read(&tmp->refcnt);
+			obj = tmp;
+		}
+	}
+
+	if (!obj)
+		goto free_load;
+
+	atomic_inc(&obj->refcnt);
+
+free_load:
+	kfree(cpu_load);
+exit:
+	return obj;
+}
+
+static int get_avail_queue(struct netpolicy_instance *instance, bool is_rx)
+{
+	struct netpolicy_record *old_record, *new_record;
+	struct net_device *dev = instance->dev;
+	unsigned long ptr_id = (uintptr_t)instance->ptr;
+	int queue = -1;
+
+	spin_lock_bh(&np_hashtable_lock);
+	old_record = netpolicy_record_search(ptr_id);
+	if (!old_record) {
+		pr_warn("NETPOLICY: doesn't registered. Remove net policy settings!\n");
+		instance->policy = NET_POLICY_INVALID;
+		goto err;
+	}
+
+	if (is_rx && old_record->rx_obj) {
+		queue = old_record->rx_obj->queue;
+	} else if (!is_rx && old_record->tx_obj) {
+		queue = old_record->tx_obj->queue;
+	} else {
+		new_record = kzalloc(sizeof(*new_record), GFP_KERNEL);
+		if (!new_record)
+			goto err;
+		memcpy(new_record, old_record, sizeof(*new_record));
+
+		if (is_rx) {
+			new_record->rx_obj = get_avail_object(dev, new_record->policy,
+							      instance, is_rx);
+			if (!new_record->dev)
+				new_record->dev = dev;
+			if (!new_record->rx_obj) {
+				kfree(new_record);
+				goto err;
+			}
+			queue = new_record->rx_obj->queue;
+		} else {
+			new_record->tx_obj = get_avail_object(dev, new_record->policy,
+							      instance, is_rx);
+			if (!new_record->dev)
+				new_record->dev = dev;
+			if (!new_record->tx_obj) {
+				kfree(new_record);
+				goto err;
+			}
+			queue = new_record->tx_obj->queue;
+		}
+		/* update record */
+		hlist_replace_rcu(&old_record->hash_node, &new_record->hash_node);
+		kfree(old_record);
+	}
+err:
+	spin_unlock_bh(&np_hashtable_lock);
+	return queue;
+}
+
+static inline bool policy_validate(struct netpolicy_instance *instance)
+{
+	struct net_device *dev = instance->dev;
+	enum netpolicy_name cur_policy;
+
+	cur_policy = dev->netpolicy->cur_policy;
+	if ((instance->policy == NET_POLICY_NONE) ||
+	    (cur_policy == NET_POLICY_NONE))
+		return false;
+
+	if (((cur_policy != NET_POLICY_MIX) && (cur_policy != instance->policy)) ||
+	    ((cur_policy == NET_POLICY_MIX) && (instance->policy == NET_POLICY_CPU))) {
+		pr_warn("NETPOLICY: %s current device policy %s doesn't support required policy %s! Remove net policy settings!\n",
+			dev->name, policy_name[cur_policy],
+			policy_name[instance->policy]);
+		return false;
+	}
+	return true;
+}
+
+/**
+ * netpolicy_pick_queue() - Find proper queue
+ * @instance:	NET policy per socket/task instance info
+ * @is_rx:	RX queue or TX queue
+ *
+ * This function intends to find the proper queue according to policy.
+ * For selecting the proper queue, currently it uses round-robin algorithm
+ * to find the available object from the given policy object list.
+ * The selected object will be stored in hashtable. So it does not need to
+ * go through the whole object list every time.
+ *
+ * Return: negative on failure, otherwise on the assigned queue
+ */
+int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
+{
+	struct net_device *dev = instance->dev;
+
+	if (!dev || !dev->netpolicy)
+		return -EINVAL;
+
+	if (!policy_validate(instance))
+		return -EINVAL;
+
+	return get_avail_queue(instance, is_rx);
+}
+EXPORT_SYMBOL(netpolicy_pick_queue);
+
 /**
  * netpolicy_register() - Register per socket/task policy request
  * @instance:	NET policy per socket/task instance info
-- 
2.5.5
