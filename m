From: kan.liang@intel.com
Subject: [RFC PATCH 29/30] net/netpolicy: limit the total record number
Date: Sun, 17 Jul 2016 23:56:23 -0700
Message-ID: <1468824984-65318-30-git-send-email-kan.liang@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64845 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091AbcGROXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:23:37 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/ethernet/intel/i40e/i40e_main.c |  6 ++++++
 include/linux/netpolicy.h                   |  4 ++++
 net/core/netpolicy.c                        | 22 ++++++++++++++++++++--
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f03d9f6..db03f5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8994,6 +8994,9 @@ static int policy_param[NET_POLICY_MAX + 1][2] = {
 static int i40e_ndo_netpolicy_init(struct net_device *dev,
 				   struct netpolicy_info *info)
 {
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
 	int i;
 
 	for (i = 0; i < NET_POLICY_MAX; i++) {
@@ -9012,6 +9015,9 @@ static int i40e_ndo_netpolicy_init(struct net_device *dev,
 	/* support queue pair */
 	info->queue_pair = true;
 
+	/* limit the record number to flow director rules number */
+	info->max_rec_num = i40e_get_fd_cnt_all(pf);
+
 	return 0;
 }
 
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 2de59a6..1307363 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -38,6 +38,7 @@ enum netpolicy_traffic {
 };
 
 #define POLICY_NAME_LEN_MAX	64
+#define NETPOLICY_MAX_RECORD_NUM	7000
 extern const char *policy_name[];
 extern int netpolicy_sys_map_version __read_mostly;
 
@@ -80,6 +81,9 @@ struct netpolicy_info {
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
 	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
+	/* for record number limitation */
+	int				max_rec_num;
+	atomic_t			cur_rec_num;
 };
 
 struct netpolicy_reg {
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 83242d3..5e9c9b8 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -380,6 +380,9 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	if (!dev || !dev->netpolicy)
 		goto err;
 
+	if (atomic_read(&dev->netpolicy->cur_rec_num) > dev->netpolicy->max_rec_num)
+		goto err;
+
 	cur_policy = dev->netpolicy->cur_policy;
 	if ((reg->policy == NET_POLICY_NONE) ||
 	    (cur_policy == NET_POLICY_NONE))
@@ -433,8 +436,10 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	if (is_rx) {
 		if (!new_record->rx_obj) {
 			new_record->rx_obj = get_avail_queue(dev, new_record->policy, is_rx);
-			if (!new_record->dev)
+			if (!new_record->dev) {
 				new_record->dev = dev;
+				atomic_inc(&dev->netpolicy->cur_rec_num);
+			}
 			if (!new_record->rx_obj) {
 				kfree(new_record);
 				return -ENOTSUPP;
@@ -444,8 +449,10 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	} else {
 		if (!new_record->tx_obj) {
 			new_record->tx_obj = get_avail_queue(dev, new_record->policy, is_rx);
-			if (!new_record->dev)
+			if (!new_record->dev) {
 				new_record->dev = dev;
+				atomic_inc(&dev->netpolicy->cur_rec_num);
+			}
 			if (!new_record->tx_obj) {
 				kfree(new_record);
 				return -ENOTSUPP;
@@ -493,12 +500,17 @@ int netpolicy_register(struct netpolicy_reg *reg,
 {
 	unsigned long ptr_id = (uintptr_t)reg->ptr;
 	struct netpolicy_record *new, *old;
+	struct net_device *dev = reg->dev;
 
 	if (!is_net_policy_valid(policy)) {
 		reg->policy = NET_POLICY_INVALID;
 		return -EINVAL;
 	}
 
+	if (dev && dev->netpolicy &&
+	    (atomic_read(&dev->netpolicy->cur_rec_num) > dev->netpolicy->max_rec_num))
+		return -ENOSPC;
+
 	new = kzalloc(sizeof(*new), GFP_KERNEL);
 	if (!new) {
 		reg->policy = NET_POLICY_INVALID;
@@ -519,6 +531,8 @@ int netpolicy_register(struct netpolicy_reg *reg,
 		new->dev = reg->dev;
 		new->policy = policy;
 		hash_add_rcu(np_record_hash, &new->hash_node, ptr_id);
+		if (dev && dev->netpolicy)
+			atomic_inc(&dev->netpolicy->cur_rec_num);
 	}
 	reg->policy = policy;
 	spin_unlock_bh(&np_hashtable_lock);
@@ -565,6 +579,7 @@ void netpolicy_unregister(struct netpolicy_reg *reg)
 		/* The record cannot be share. It can be safely free. */
 		put_queue(record->dev, record->rx_obj, record->tx_obj);
 		kfree(record);
+		atomic_dec(&dev->netpolicy->cur_rec_num);
 	}
 	reg->policy = NET_POLICY_INVALID;
 	spin_unlock_bh(&np_hashtable_lock);
@@ -1152,6 +1167,9 @@ int init_netpolicy(struct net_device *dev)
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
