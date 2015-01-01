From: kan.liang@intel.com
Subject: [RFC V2 PATCH 24/25] net/netpolicy: limit the total record number
Date: Wed, 31 Dec 2014 20:39:13 -0500
Message-ID: <1420076354-4861-25-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

NET policy can not fulfill users request without limit, because of the
security consideration and device limitation. For security
consideration, the attacker may fake millions of per task/socket request
to crash the system. For device limitation, the flow director rules
number is limited on i40e driver. NET policy should not run out the
rules, otherwise it cannot guarantee the good performance.

This patch limits the total record number in RCU hash table to fix the
cases as above. The max total record number could vary for different
device. For i40e driver, it limits the record number according to flow
director rules number. If it exceeds the limitation, the registeration
and new object request will be denied.

Since the dev may not be aware in registeration, the cur_rec_num may not
be updated on time. So the actual registered record may exceeds the
max_rec_num. But it will not bring any problems. Because the patch also
check the limitation on object request. It guarantees that the device
resource will not run out.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  4 ++++
 net/core/netpolicy.c      | 22 ++++++++++++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 0eba512..9bc2ee0 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -40,6 +40,7 @@ enum netpolicy_traffic {
 #define NETPOLICY_INVALID_QUEUE	-1
 #define NETPOLICY_INVALID_LOC	NETPOLICY_INVALID_QUEUE
 #define POLICY_NAME_LEN_MAX	64
+#define NETPOLICY_MAX_RECORD_NUM	7000
 extern const char *policy_name[];
 
 struct netpolicy_dev_info {
@@ -81,6 +82,9 @@ struct netpolicy_info {
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
 	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
+	/* for record number limitation */
+	int				max_rec_num;
+	atomic_t			cur_rec_num;
 };
 
 struct netpolicy_tcpudpip4_spec {
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 735405c..e9f3800 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -368,6 +368,9 @@ static int get_avail_queue(struct netpolicy_instance *instance, bool is_rx)
 	unsigned long ptr_id = (uintptr_t)instance->ptr;
 	int queue = -1;
 
+	if (atomic_read(&dev->netpolicy->cur_rec_num) > dev->netpolicy->max_rec_num)
+		return queue;
+
 	spin_lock_bh(&np_hashtable_lock);
 	old_record = netpolicy_record_search(ptr_id);
 	if (!old_record) {
@@ -388,8 +391,10 @@ static int get_avail_queue(struct netpolicy_instance *instance, bool is_rx)
 
 		if (is_rx) {
 			new_record->rx_obj = get_avail_object(dev, new_record->policy, is_rx);
-			if (!new_record->dev)
+			if (!new_record->dev) {
 				new_record->dev = dev;
+				atomic_inc(&dev->netpolicy->cur_rec_num);
+			}
 			if (!new_record->rx_obj) {
 				kfree(new_record);
 				goto err;
@@ -397,8 +402,10 @@ static int get_avail_queue(struct netpolicy_instance *instance, bool is_rx)
 			queue = new_record->rx_obj->queue;
 		} else {
 			new_record->tx_obj = get_avail_object(dev, new_record->policy, is_rx);
-			if (!new_record->dev)
+			if (!new_record->dev) {
 				new_record->dev = dev;
+				atomic_inc(&dev->netpolicy->cur_rec_num);
+			}
 			if (!new_record->tx_obj) {
 				kfree(new_record);
 				goto err;
@@ -638,6 +645,7 @@ int netpolicy_register(struct netpolicy_instance *instance,
 		       enum netpolicy_name policy)
 {
 	unsigned long ptr_id = (uintptr_t)instance->ptr;
+	struct net_device *dev = instance->dev;
 	struct netpolicy_record *new, *old;
 
 	if (!is_net_policy_valid(policy)) {
@@ -645,6 +653,10 @@ int netpolicy_register(struct netpolicy_instance *instance,
 		return -EINVAL;
 	}
 
+	if (dev && dev->netpolicy &&
+	    (atomic_read(&dev->netpolicy->cur_rec_num) > dev->netpolicy->max_rec_num))
+		return -ENOSPC;
+
 	new = kzalloc(sizeof(*new), GFP_KERNEL);
 	if (!new) {
 		instance->policy = NET_POLICY_INVALID;
@@ -668,6 +680,8 @@ int netpolicy_register(struct netpolicy_instance *instance,
 		new->dev = instance->dev;
 		new->policy = policy;
 		hash_add_rcu(np_record_hash, &new->hash_node, ptr_id);
+		if (dev && dev->netpolicy)
+			atomic_inc(&dev->netpolicy->cur_rec_num);
 	}
 	instance->policy = policy;
 	spin_unlock_bh(&np_hashtable_lock);
@@ -714,6 +728,7 @@ void netpolicy_unregister(struct netpolicy_instance *instance)
 		/* The record cannot be share. It can be safely free. */
 		put_queue(record->dev, record->rx_obj, record->tx_obj);
 		kfree(record);
+		atomic_dec(&dev->netpolicy->cur_rec_num);
 	}
 	instance->policy = NET_POLICY_INVALID;
 	spin_unlock_bh(&np_hashtable_lock);
@@ -1247,6 +1262,9 @@ int init_netpolicy(struct net_device *dev)
 		goto unlock;
 	}
 
+	if (!dev->netpolicy->max_rec_num)
+		dev->netpolicy->max_rec_num = NETPOLICY_MAX_RECORD_NUM;
+
 	spin_lock(&dev->np_ob_list_lock);
 	for (i = 0; i < NETPOLICY_RXTX; i++) {
 		for (j = NET_POLICY_NONE; j < NET_POLICY_MAX; j++)
-- 
2.5.5
