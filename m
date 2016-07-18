From: kan.liang@intel.com
Subject: [RFC PATCH 27/30] net/netpolicy: fast path for finding the queues
Date: Sun, 17 Jul 2016 23:56:21 -0700
Message-ID: <1468824984-65318-28-git-send-email-kan.liang@intel.com>
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

Current implementation searches the hash table to get assigned object
for each transmit/receive packet. It's not necessory, because the
assigned object usually remain unchanged.

This patch store the assigned queue into netpolicy_reg struct. So it
doesnot need to search the hash table everytime unless the system cpu
and queue mapping changed.

netpolicy_sys_map_version is used to track the system cpu and queue
mapping changes. It's protected by a rw lock (TODO: will replace by RCU
shortly).

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/init_task.h |  3 +++
 include/linux/netpolicy.h |  5 +++++
 kernel/fork.c             |  3 +++
 net/core/netpolicy.c      | 36 ++++++++++++++++++++++++++++++++++++
 net/core/sock.c           |  6 ++++++
 5 files changed, 53 insertions(+)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index eda7ffc..06ea231 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -189,6 +189,9 @@ extern struct task_group root_task_group;
 	.task_netpolicy.dev = NULL,					\
 	.task_netpolicy.location = ~0,					\
 	.task_netpolicy.rule_queue = ~0,				\
+	.task_netpolicy.rx_queue = ~0,					\
+	.task_netpolicy.tx_queue = ~0,					\
+	.task_netpolicy.sys_map_version = 0,				\
 	.task_netpolicy.ptr = (void *)&tsk,
 #else
 #define INIT_NETPOLICY(tsk)
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 1cd5ac4..fa740b5 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -39,6 +39,7 @@ enum netpolicy_traffic {
 
 #define POLICY_NAME_LEN_MAX	64
 extern const char *policy_name[];
+extern int netpolicy_sys_map_version __read_mostly;
 
 struct netpolicy_dev_info {
 	u32	rx_num;
@@ -86,6 +87,10 @@ struct netpolicy_reg {
 	void			*ptr;		/* pointers */
 	u32			location;	/* rule location */
 	u32			rule_queue;	/* queue set by rule */
+	/* Info for fast path */
+	u32			rx_queue;
+	u32			tx_queue;
+	int			sys_map_version;
 };
 
 struct netpolicy_tcpudpip4_spec {
diff --git a/kernel/fork.c b/kernel/fork.c
index 31262d2..fcb856b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1456,6 +1456,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #ifdef CONFIG_NETPOLICY
 	p->task_netpolicy.location = ~0;
 	p->task_netpolicy.rule_queue = ~0;
+	p->task_netpolicy.rx_queue = ~0;
+	p->task_netpolicy.tx_queue = ~0;
+	p->task_netpolicy.sys_map_version = 0;
 	p->task_netpolicy.ptr = (void *)p;
 	if (is_net_policy_valid(p->task_netpolicy.policy))
 		netpolicy_register(&p->task_netpolicy, p->task_netpolicy.policy);
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 9e14137..a63ccd4 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -82,6 +82,10 @@ struct netpolicy_record {
 static DEFINE_HASHTABLE(np_record_hash, 10);
 static DEFINE_SPINLOCK(np_hashtable_lock);
 
+int netpolicy_sys_map_version;
+/* read write lock to protect sys map version */
+static DEFINE_RWLOCK(np_sys_map_lock);
+
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
 {
@@ -394,6 +398,24 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	    (current->task_netpolicy.policy != reg->policy))
 		return -EINVAL;
 
+	/* fast path */
+	read_lock(&np_sys_map_lock);
+	if (netpolicy_sys_map_version == reg->sys_map_version) {
+		if (is_rx && (reg->rx_queue != ~0)) {
+			read_unlock(&np_sys_map_lock);
+			return reg->rx_queue;
+		}
+		if (!is_rx && (reg->tx_queue != ~0)) {
+			read_unlock(&np_sys_map_lock);
+			return reg->tx_queue;
+		}
+	} else {
+		reg->rx_queue = ~0;
+		reg->tx_queue = ~0;
+		reg->sys_map_version = netpolicy_sys_map_version;
+	}
+	read_unlock(&np_sys_map_lock);
+
 	old_record = netpolicy_record_search(ptr_id);
 	if (!old_record) {
 		pr_warn("NETPOLICY: doesn't registered. Remove net policy settings!\n");
@@ -435,6 +457,11 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	spin_unlock_bh(&np_hashtable_lock);
 	kfree(old_record);
 
+	if (is_rx)
+		reg->rx_queue  = queue;
+	else
+		reg->tx_queue  = queue;
+
 	return queue;
 
 err:
@@ -522,6 +549,9 @@ void netpolicy_unregister(struct netpolicy_reg *reg)
 		rtnl_unlock();
 		reg->location = ~0;
 		reg->rule_queue = ~0;
+		reg->rx_queue = ~0;
+		reg->tx_queue = ~0;
+		reg->sys_map_version = 0;
 	}
 
 	spin_lock_bh(&np_hashtable_lock);
@@ -1272,6 +1302,10 @@ void update_netpolicy_sys_map(void)
 				netpolicy_disable(dev);
 				goto unlock;
 			}
+			write_lock(&np_sys_map_lock);
+			if (netpolicy_sys_map_version++ < 0)
+				netpolicy_sys_map_version = 0;
+			write_unlock(&np_sys_map_lock);
 
 			dev->netpolicy->cur_policy = cur_policy;
 unlock:
@@ -1305,6 +1339,8 @@ static int __init netpolicy_init(void)
 {
 	int ret;
 
+	netpolicy_sys_map_version = 0;
+
 	ret = register_pernet_subsys(&netpolicy_net_ops);
 	if (!ret)
 		register_netdevice_notifier(&netpolicy_dev_notf);
diff --git a/net/core/sock.c b/net/core/sock.c
index 4d47a89..284aafd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1447,6 +1447,9 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sk->sk_netpolicy.policy = NET_POLICY_INVALID;
 		sk->sk_netpolicy.location = ~0;
 		sk->sk_netpolicy.rule_queue = ~0;
+		sk->sk_netpolicy.rx_queue = ~0;
+		sk->sk_netpolicy.tx_queue = ~0;
+		sk->sk_netpolicy.sys_map_version = 0;
 #endif
 	}
 
@@ -1630,6 +1633,9 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_netpolicy.ptr = (void *)newsk;
 		newsk->sk_netpolicy.location = ~0;
 		newsk->sk_netpolicy.rule_queue = ~0;
+		newsk->sk_netpolicy.rx_queue = ~0;
+		newsk->sk_netpolicy.tx_queue = ~0;
+		newsk->sk_netpolicy.sys_map_version = 0;
 		if (is_net_policy_valid(current->task_netpolicy.policy))
 			newsk->sk_netpolicy.policy = NET_POLICY_INVALID;
 		if (is_net_policy_valid(newsk->sk_netpolicy.policy))
-- 
2.5.5
