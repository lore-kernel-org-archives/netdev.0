From: kan.liang@intel.com
Subject: [RFC V3 PATCH 23/26] net/netpolicy: fast path for finding the queues
Date: Mon, 12 Sep 2016 07:55:56 -0700
Message-ID: <1473692159-4017-24-git-send-email-kan.liang@intel.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Current implementation searches the hash table to get assigned object
for each transmit/receive packet. It's not necessory, because the
assigned object usually remain unchanged. This patch store the assigned
queue to speed up the searching process.

But under certain situations, the assigned objects has to be changed,
especially when system cpu and queue mapping changed, such as CPU
hotplug, device hotplug, queue number changes and so on. In this patch,
the netpolicy_sys_map_version is used to track the system cpu and queue
mapping changes. If the netpolicy_sys_map_version doesn't match with the
instance's version, the stored queue will be dropped. The
netpolicy_sys_map_version is protected by RCU lock.

Also, to reduce the overhead, this patch asynchronously find the
available object by work queue. So the first several packets may not be
benefited.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  23 +++++++---
 net/core/netpolicy.c      | 106 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/af_inet.c        |   7 +--
 3 files changed, 125 insertions(+), 11 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 04cd07d..88f4f60 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -55,14 +55,20 @@ struct netpolicy_sys_map {
 	u32	irq;
 };
 
+struct netpolicy_sys_map_version {
+	struct rcu_head		rcu;
+	int			major;
+};
+
 struct netpolicy_sys_info {
 	/*
 	 * Record the cpu and queue 1:1 mapping
 	 */
-	u32				avail_rx_num;
-	struct netpolicy_sys_map	*rx;
-	u32				avail_tx_num;
-	struct netpolicy_sys_map	*tx;
+	u32					avail_rx_num;
+	struct netpolicy_sys_map		*rx;
+	u32					avail_tx_num;
+	struct netpolicy_sys_map		*tx;
+	struct netpolicy_sys_map_version __rcu	*version;
 };
 
 struct netpolicy_object {
@@ -110,7 +116,14 @@ struct netpolicy_instance {
 	struct work_struct	fc_wk;		/* flow classification work */
 	atomic_t		fc_wk_cnt;	/* flow classification work number */
 	struct netpolicy_flow_spec	flow;	/* flow information */
-
+	/* For fast path */
+	atomic_t		rx_queue;
+	atomic_t		tx_queue;
+	struct work_struct	get_rx_wk;
+	atomic_t		get_rx_wk_cnt;
+	struct work_struct	get_tx_wk;
+	atomic_t		get_tx_wk_cnt;
+	int			sys_map_version;
 };
 
 struct netpolicy_cpu_load {
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 60a6d69..2f55a14 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -84,6 +84,7 @@ static DEFINE_HASHTABLE(np_record_hash, 10);
 static DEFINE_SPINLOCK(np_hashtable_lock);
 
 struct workqueue_struct *np_fc_wq;
+struct workqueue_struct *np_fast_path_wq;
 
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
@@ -456,6 +457,37 @@ err:
 	return queue;
 }
 
+static void np_find_rx_queue(struct work_struct *wk)
+{
+	struct netpolicy_instance *instance;
+	int queue;
+
+	instance = container_of(wk, struct netpolicy_instance,
+				get_rx_wk);
+
+	if (instance) {
+		queue = get_avail_queue(instance, true);
+		if (queue >= 0)
+			atomic_set(&instance->rx_queue, queue);
+	}
+	atomic_set(&instance->get_rx_wk_cnt, 0);
+}
+
+static void np_find_tx_queue(struct work_struct *wk)
+{
+	struct netpolicy_instance *instance;
+	int queue;
+
+	instance = container_of(wk, struct netpolicy_instance,
+				get_tx_wk);
+	if (instance) {
+		queue = get_avail_queue(instance, false);
+		if (queue >= 0)
+			atomic_set(&instance->tx_queue, queue);
+	}
+	atomic_set(&instance->get_tx_wk_cnt, 0);
+}
+
 static inline bool policy_validate(struct netpolicy_instance *instance)
 {
 	struct net_device *dev = instance->dev;
@@ -498,6 +530,7 @@ static inline bool policy_validate(struct netpolicy_instance *instance)
 int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
 {
 	struct net_device *dev = instance->dev;
+	int version;
 
 	if (!dev || !dev->netpolicy)
 		return -EINVAL;
@@ -505,7 +538,35 @@ int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
 	if (!policy_validate(instance))
 		return -EINVAL;
 
-	return get_avail_queue(instance, is_rx);
+	/* fast path */
+	rcu_read_lock();
+	version = rcu_dereference(dev->netpolicy->sys_info.version)->major;
+	if (version == instance->sys_map_version) {
+		if (is_rx && (atomic_read(&instance->rx_queue) != NETPOLICY_INVALID_QUEUE)) {
+			rcu_read_unlock();
+			return atomic_read(&instance->rx_queue);
+		}
+		if (!is_rx && (atomic_read(&instance->tx_queue) != NETPOLICY_INVALID_QUEUE)) {
+			rcu_read_unlock();
+			return atomic_read(&instance->tx_queue);
+		}
+	} else {
+		atomic_set(&instance->rx_queue, NETPOLICY_INVALID_QUEUE);
+		atomic_set(&instance->tx_queue, NETPOLICY_INVALID_QUEUE);
+		instance->sys_map_version = version;
+	}
+	rcu_read_unlock();
+
+	if (is_rx && !atomic_cmpxchg(&instance->get_rx_wk_cnt, 0, 1)) {
+		instance->task = current;
+		queue_work(np_fast_path_wq, &instance->get_rx_wk);
+	}
+	if (!is_rx && !atomic_cmpxchg(&instance->get_tx_wk_cnt, 0, 1)) {
+		instance->task = current;
+		queue_work(np_fast_path_wq, &instance->get_tx_wk);
+	}
+
+	return -1;
 }
 EXPORT_SYMBOL(netpolicy_pick_queue);
 
@@ -541,6 +602,7 @@ void np_flow_rule_set(struct work_struct *wk)
 	queue = get_avail_queue(instance, true);
 	if (queue < 0)
 		goto done;
+	atomic_set(&instance->rx_queue, queue);
 
 	/* using ethtool flow-type to configure
 	 * Rx network flow classification options or rules
@@ -591,6 +653,14 @@ static void init_instance(struct netpolicy_instance *instance)
 	atomic_set(&instance->rule_queue, NETPOLICY_INVALID_QUEUE);
 	atomic_set(&instance->fc_wk_cnt, 0);
 	INIT_WORK(&instance->fc_wk, np_flow_rule_set);
+
+	atomic_set(&instance->rx_queue, NETPOLICY_INVALID_QUEUE);
+	atomic_set(&instance->tx_queue, NETPOLICY_INVALID_QUEUE);
+	instance->sys_map_version = 0;
+	atomic_set(&instance->get_rx_wk_cnt, 0);
+	atomic_set(&instance->get_tx_wk_cnt, 0);
+	INIT_WORK(&instance->get_rx_wk, np_find_rx_queue);
+	INIT_WORK(&instance->get_tx_wk, np_find_tx_queue);
 }
 
 /**
@@ -664,6 +734,8 @@ void netpolicy_unregister(struct netpolicy_instance *instance)
 	struct net_device *dev = instance->dev;
 	struct netpolicy_record *record;
 
+	cancel_work_sync(&instance->get_rx_wk);
+	cancel_work_sync(&instance->get_tx_wk);
 	cancel_work_sync(&instance->fc_wk);
 	/* remove FD rules */
 	if (dev && instance->location != NETPOLICY_INVALID_LOC) {
@@ -1196,6 +1268,7 @@ static int netpolicy_proc_dev_init(struct net *net, struct net_device *dev)
 
 int init_netpolicy(struct net_device *dev)
 {
+	struct netpolicy_sys_map_version *version;
 	int ret, i, j;
 
 	spin_lock(&dev->np_lock);
@@ -1229,6 +1302,14 @@ int init_netpolicy(struct net_device *dev)
 	}
 	spin_unlock(&dev->np_ob_list_lock);
 
+	version = kzalloc(sizeof(*version), GFP_ATOMIC);
+	if (version)
+		rcu_assign_pointer(dev->netpolicy->sys_info.version, version);
+	else {
+		kfree(dev->netpolicy);
+		dev->netpolicy = NULL;
+		ret = -ENOMEM;
+	}
 unlock:
 	spin_unlock(&dev->np_lock);
 	return ret;
@@ -1240,6 +1321,8 @@ void uninit_netpolicy(struct net_device *dev)
 	if (dev->netpolicy) {
 		if (dev->netpolicy->cur_policy > NET_POLICY_NONE)
 			netpolicy_disable(dev);
+		RCU_INIT_POINTER(dev->netpolicy->sys_info.version, NULL);
+		synchronize_rcu();
 		kfree(dev->netpolicy);
 		dev->netpolicy = NULL;
 	}
@@ -1348,6 +1431,7 @@ void update_netpolicy_sys_map(void)
 	struct net *net;
 	struct net_device *dev, *aux;
 	enum netpolicy_name cur_policy;
+	struct netpolicy_sys_map_version *new_version, *old_version;
 
 	for_each_net(net) {
 		for_each_netdev_safe(net, dev, aux) {
@@ -1379,6 +1463,19 @@ void update_netpolicy_sys_map(void)
 			}
 
 			dev->netpolicy->cur_policy = cur_policy;
+
+			old_version = rcu_dereference_protected(dev->netpolicy->sys_info.version, 1);
+			new_version = kzalloc(sizeof(*new_version), GFP_ATOMIC);
+			if (new_version) {
+				new_version->major = old_version->major + 1;
+				if (new_version->major < 0)
+					new_version->major = 0;
+				rcu_assign_pointer(dev->netpolicy->sys_info.version, new_version);
+				kfree_rcu(old_version, rcu);
+			} else {
+				pr_warn("NETPOLICY: Failed to update sys map version for dev %s\n",
+					dev->name);
+			}
 unlock:
 			spin_unlock(&dev->np_lock);
 		}
@@ -1418,6 +1515,12 @@ static int __init netpolicy_init(void)
 	if (!np_fc_wq)
 		return -ENOMEM;
 
+	np_fast_path_wq = create_workqueue("np_fast_path");
+	if (!np_fast_path_wq) {
+		destroy_workqueue(np_fc_wq);
+		return -ENOMEM;
+	}
+
 	ret = register_pernet_subsys(&netpolicy_net_ops);
 	if (!ret)
 		register_netdevice_notifier(&netpolicy_dev_notf);
@@ -1432,6 +1535,7 @@ static int __init netpolicy_init(void)
 static void __exit netpolicy_exit(void)
 {
 	destroy_workqueue(np_fc_wq);
+	destroy_workqueue(np_fast_path_wq);
 
 	unregister_netdevice_notifier(&netpolicy_dev_notf);
 	unregister_pernet_subsys(&netpolicy_net_ops);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 71bee44..8d90afd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -760,7 +760,6 @@ static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
 	struct netpolicy_instance *instance;
 	struct netpolicy_flow_spec *flow;
 	bool change = false;
-	int queue;
 
 	instance = netpolicy_find_instance(sk);
 	if (!instance)
@@ -814,10 +813,8 @@ static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
 		return;
 	}
 
-	queue = netpolicy_pick_queue(instance, true);
-	if (queue < 0)
-		return;
-	if ((queue != atomic_read(&instance->rule_queue)) || change)
+	if ((atomic_read(&instance->rx_queue) != atomic_read(&instance->rule_queue)) ||
+	    change)
 		netpolicy_set_rules(instance);
 #endif
 }
-- 
2.5.5
