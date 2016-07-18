From: kan.liang@intel.com
Subject: [RFC PATCH 21/30] net/policy: introduce netpolicy_pick_queue
Date: Sun, 17 Jul 2016 23:56:15 -0700
Message-ID: <1468824984-65318-22-git-send-email-kan.liang@intel.com>
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

This function will be used to get assigned queues by policy and ptr.
If it's first time, get_avail_queue will be called to find the available
object from the given policy object list.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |   5 ++
 net/core/netpolicy.c      | 119 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 124 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 89361d9..e20820d 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -97,6 +97,7 @@ extern void update_netpolicy_sys_map(void);
 extern int netpolicy_register(struct netpolicy_reg *reg,
 			      enum netpolicy_name policy);
 extern void netpolicy_unregister(struct netpolicy_reg *reg);
+extern int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
 #else
 static inline void update_netpolicy_sys_map(void)
 {
@@ -111,6 +112,10 @@ static inline void netpolicy_unregister(struct netpolicy_reg *reg)
 {
 }
 
+static inline int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
+{
+	return 0;
+}
 #endif
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 13ab5e1..6992d08 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -289,6 +289,125 @@ static void put_queue(struct net_device *dev,
 		atomic_dec(&tx_obj->refcnt);
 }
 
+static struct netpolicy_object *get_avail_queue(struct net_device *dev,
+						enum netpolicy_name policy,
+						bool is_rx)
+{
+	int dir = is_rx ? NETPOLICY_RX : NETPOLICY_TX;
+	struct netpolicy_object *tmp, *obj = NULL;
+	int val = -1;
+
+	/* Check if net policy is supported */
+	if (!dev || !dev->netpolicy)
+		return NULL;
+
+	/* The system should have queues which support the request policy. */
+	if ((policy != dev->netpolicy->cur_policy) &&
+	    (dev->netpolicy->cur_policy != NET_POLICY_MIX))
+		return NULL;
+
+	spin_lock(&dev->np_ob_list_lock);
+	list_for_each_entry(tmp, &dev->netpolicy->obj_list[dir][policy], list) {
+		if ((val > atomic_read(&tmp->refcnt)) ||
+		    (val == -1)) {
+			val = atomic_read(&tmp->refcnt);
+			obj = tmp;
+		}
+	}
+	spin_unlock(&dev->np_ob_list_lock);
+
+	if (WARN_ON(!obj))
+		return NULL;
+	atomic_inc(&obj->refcnt);
+
+	return obj;
+}
+
+/**
+ * netpolicy_pick_queue() - Find assigned queue
+ * @reg:	NET policy register info
+ * @is_rx:	RX queue or TX queue
+ *
+ * This function intends to find the assigned queue according to policy and
+ * ptr. If it's first time, get_avail_queue will be called to find the
+ * available object from the given policy object list. Then the object info
+ * will be updated in the hash table.
+ *
+ * Return: negative on failure, otherwise on the assigned queue
+ */
+int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
+{
+	struct netpolicy_record *old_record, *new_record;
+	struct net_device *dev = reg->dev;
+	enum netpolicy_name cur_policy;
+	unsigned long ptr_id = (uintptr_t)reg->ptr;
+	int queue = -1;
+
+	if (!dev || !dev->netpolicy)
+		goto err;
+
+	cur_policy = dev->netpolicy->cur_policy;
+	if ((reg->policy == NET_POLICY_NONE) ||
+	    (cur_policy == NET_POLICY_NONE))
+		return queue;
+
+	if (((cur_policy != NET_POLICY_MIX) && (cur_policy != reg->policy)) ||
+	    ((cur_policy == NET_POLICY_MIX) && (reg->policy == NET_POLICY_CPU))) {
+		pr_warn("NETPOLICY: %s current device policy %s doesn't support required policy %s! Remove net policy settings!\n",
+			dev->name, policy_name[cur_policy],
+			policy_name[reg->policy]);
+		goto err;
+	}
+
+	old_record = netpolicy_record_search(ptr_id);
+	if (!old_record) {
+		pr_warn("NETPOLICY: doesn't registered. Remove net policy settings!\n");
+		goto err;
+	}
+
+	new_record = kzalloc(sizeof(*new_record), GFP_KERNEL);
+	if (!new_record)
+		return -ENOMEM;
+	memcpy(new_record, old_record, sizeof(*new_record));
+
+	if (is_rx) {
+		if (!new_record->rx_obj) {
+			new_record->rx_obj = get_avail_queue(dev, new_record->policy, is_rx);
+			if (!new_record->dev)
+				new_record->dev = dev;
+			if (!new_record->rx_obj) {
+				kfree(new_record);
+				return -ENOTSUPP;
+			}
+		}
+		queue = new_record->rx_obj->queue;
+	} else {
+		if (!new_record->tx_obj) {
+			new_record->tx_obj = get_avail_queue(dev, new_record->policy, is_rx);
+			if (!new_record->dev)
+				new_record->dev = dev;
+			if (!new_record->tx_obj) {
+				kfree(new_record);
+				return -ENOTSUPP;
+			}
+		}
+		queue = new_record->tx_obj->queue;
+	}
+
+	/* update record */
+	spin_lock_bh(&np_hashtable_lock);
+	hlist_replace_rcu(&old_record->hash_node, &new_record->hash_node);
+	spin_unlock_bh(&np_hashtable_lock);
+	kfree(old_record);
+
+	return queue;
+
+err:
+	netpolicy_unregister(reg);
+	return -EINVAL;
+}
+EXPORT_SYMBOL(netpolicy_pick_queue);
+
 /**
  * netpolicy_register() - Register per socket/task policy request
  * @reg:	NET policy register info
-- 
2.5.5
