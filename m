From: kan.liang@intel.com
Subject: [RFC PATCH 19/30] net/netpolicy: implement netpolicy register
Date: Sun, 17 Jul 2016 23:56:13 -0700
Message-ID: <1468824984-65318-20-git-send-email-kan.liang@intel.com>
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

User can register itself in netpolicy module with specific policy.
If it's the first time to register, an record will be created and
inserted into RCU hash table. The record includes ptr, policy and object
information. ptr is assigned by the user which is used as key to search
the record in hash table. Object will be assigned by netpolicy later.

If CPU/device are removed(hotplug), the assigned object will be clear.
This patch also introduces a new type NET_POLICY_INVALID, which
indicates that the task/socket are not registered.
np_hashtable_lock is introduced to protect the hash table.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  26 ++++++++
 net/core/netpolicy.c      | 150 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 176 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index cc75e3c..89361d9 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -17,6 +17,7 @@
 #define __LINUX_NETPOLICY_H
 
 enum netpolicy_name {
+	NET_POLICY_INVALID	= -1,
 	NET_POLICY_NONE		= 0,
 	NET_POLICY_CPU,
 	NET_POLICY_BULK,
@@ -79,12 +80,37 @@ struct netpolicy_info {
 	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
 };
 
+struct netpolicy_reg {
+	struct net_device	*dev;
+	enum netpolicy_name	policy; /* required policy */
+	void			*ptr;   /* pointers */
+};
+
+/* check if policy is valid */
+static inline int is_net_policy_valid(enum netpolicy_name policy)
+{
+	return ((policy < NET_POLICY_MAX) && (policy > NET_POLICY_INVALID));
+}
+
 #ifdef CONFIG_NETPOLICY
 extern void update_netpolicy_sys_map(void);
+extern int netpolicy_register(struct netpolicy_reg *reg,
+			      enum netpolicy_name policy);
+extern void netpolicy_unregister(struct netpolicy_reg *reg);
 #else
 static inline void update_netpolicy_sys_map(void)
 {
 }
+
+static inline int netpolicy_register(struct netpolicy_reg *reg,
+				     enum netpolicy_name policy)
+{	return 0;
+}
+
+static inline void netpolicy_unregister(struct netpolicy_reg *reg)
+{
+}
+
 #endif
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index da7d9f1..13ab5e1 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -38,6 +38,19 @@
 #include <linux/sort.h>
 #include <linux/ctype.h>
 #include <linux/cpu.h>
+#include <linux/hashtable.h>
+
+struct netpolicy_record {
+	struct hlist_node	hash_node;
+	unsigned long		ptr_id;
+	enum netpolicy_name	policy;
+	struct net_device	*dev;
+	struct netpolicy_object	*rx_obj;
+	struct netpolicy_object	*tx_obj;
+};
+
+static DEFINE_HASHTABLE(np_record_hash, 10);
+static DEFINE_SPINLOCK(np_hashtable_lock);
 
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
@@ -223,6 +236,140 @@ static int netpolicy_enable(struct net_device *dev)
 	return 0;
 }
 
+static struct netpolicy_record *netpolicy_record_search(unsigned long ptr_id)
+{
+	struct netpolicy_record *rec = NULL;
+
+	hash_for_each_possible_rcu(np_record_hash, rec, hash_node, ptr_id) {
+		if (rec->ptr_id == ptr_id)
+			break;
+	}
+
+	return rec;
+}
+
+static void netpolicy_record_clear_obj(void)
+{
+	struct netpolicy_record *rec;
+	int i;
+
+	spin_lock_bh(&np_hashtable_lock);
+	hash_for_each_rcu(np_record_hash, i, rec, hash_node) {
+		rec->rx_obj = NULL;
+		rec->tx_obj = NULL;
+	}
+	spin_unlock_bh(&np_hashtable_lock);
+}
+
+static void netpolicy_record_clear_dev_node(struct net_device *dev)
+{
+	struct netpolicy_record *rec;
+	int i;
+
+	spin_lock_bh(&np_hashtable_lock);
+	hash_for_each_rcu(np_record_hash, i, rec, hash_node) {
+		if (rec->dev == dev) {
+			hash_del_rcu(&rec->hash_node);
+			kfree(rec);
+		}
+	}
+	spin_unlock_bh(&np_hashtable_lock);
+}
+
+static void put_queue(struct net_device *dev,
+		      struct netpolicy_object *rx_obj,
+		      struct netpolicy_object *tx_obj)
+{
+	if (!dev || !dev->netpolicy)
+		return;
+
+	if (rx_obj)
+		atomic_dec(&rx_obj->refcnt);
+	if (tx_obj)
+		atomic_dec(&tx_obj->refcnt);
+}
+
+/**
+ * netpolicy_register() - Register per socket/task policy request
+ * @reg:	NET policy register info
+ * @policy:	request NET policy
+ *
+ * This function intends to register per socket/task policy request.
+ * If it's the first time to register, an record will be created and
+ * inserted into RCU hash table.
+ *
+ * The record includes ptr, policy and object info. ptr of the socket/task
+ * is the key to search the record in hash table. Object will be assigned
+ * until the first packet is received/transmitted.
+ *
+ * Return: 0 on success, others on failure
+ */
+int netpolicy_register(struct netpolicy_reg *reg,
+		       enum netpolicy_name policy)
+{
+	unsigned long ptr_id = (uintptr_t)reg->ptr;
+	struct netpolicy_record *new, *old;
+
+	if (!is_net_policy_valid(policy)) {
+		reg->policy = NET_POLICY_INVALID;
+		return -EINVAL;
+	}
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
+		reg->policy = NET_POLICY_INVALID;
+		return -ENOMEM;
+	}
+
+	spin_lock_bh(&np_hashtable_lock);
+	/* Check it in mapping table */
+	old = netpolicy_record_search(ptr_id);
+	if (old) {
+		if (old->policy != policy) {
+			put_queue(old->dev, old->rx_obj, old->tx_obj);
+			old->policy = policy;
+		}
+		kfree(new);
+	} else {
+		new->ptr_id = ptr_id;
+		new->dev = reg->dev;
+		new->policy = policy;
+		hash_add_rcu(np_record_hash, &new->hash_node, ptr_id);
+	}
+	reg->policy = policy;
+	spin_unlock_bh(&np_hashtable_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(netpolicy_register);
+
+/**
+ * netpolicy_unregister() - Unregister per socket/task policy request
+ * @reg:	NET policy register info
+ *
+ * This function intends to unregister policy request by del related record
+ * from hash table.
+ *
+ */
+void netpolicy_unregister(struct netpolicy_reg *reg)
+{
+	struct netpolicy_record *record;
+	unsigned long ptr_id = (uintptr_t)reg->ptr;
+
+	spin_lock_bh(&np_hashtable_lock);
+	/* del from hash table */
+	record = netpolicy_record_search(ptr_id);
+	if (record) {
+		hash_del_rcu(&record->hash_node);
+		/* The record cannot be share. It can be safely free. */
+		put_queue(record->dev, record->rx_obj, record->tx_obj);
+		kfree(record);
+	}
+	reg->policy = NET_POLICY_INVALID;
+	spin_unlock_bh(&np_hashtable_lock);
+}
+EXPORT_SYMBOL(netpolicy_unregister);
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE",
 	"CPU",
@@ -825,6 +972,7 @@ static int netpolicy_notify(struct notifier_block *this,
 		break;
 	case NETDEV_GOING_DOWN:
 		uninit_netpolicy(dev);
+		netpolicy_record_clear_dev_node(dev);
 #ifdef CONFIG_PROC_FS
 		proc_remove(dev->proc_dev);
 		dev->proc_dev = NULL;
@@ -863,6 +1011,8 @@ void update_netpolicy_sys_map(void)
 
 			dev->netpolicy->cur_policy = NET_POLICY_NONE;
 
+			/* clear mapping table */
+			netpolicy_record_clear_obj();
 			/* rebuild everything */
 			netpolicy_disable(dev);
 			netpolicy_enable(dev);
-- 
2.5.5
