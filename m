From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held
Date: Tue, 19 Nov 2013 07:40:52 -0800
Message-ID: <1384875654-7795-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11437 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730Ab3KSPk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 10:40:58 -0500
In-Reply-To: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

It is useful to be able to walk all upper devices when bringing
a device online where the RTNL lock is held. In this case it
is safe to walk the all_adj_list because the RTNL lock is used
to protect the write side as well.

Here we rearrange the netdev_all_upper_get_next_dev_rcu into three
routines:

	netdev_all_upper_get_next_dev_rcu()
	netdev_all_upper_get_next_dev_rtnl()
	netdev_all_upper_get_next_dev()

One for RCU callers, one for RTNL callers and a final routine
to implement the work. Both the _rcu and _rtnl variants are
exposed. Where the net/ethernet/intel/ixgbe driver is a consumer
of the _rtnl variant. netdev_all_upper_get_next_dev() is static.

CC: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  6 ++--
 include/linux/netdevice.h                     |  9 ++++++
 net/core/dev.c                                | 43 ++++++++++++++++++++-------
 3 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bd8f523..9eeb6f0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4336,7 +4336,7 @@ static void ixgbe_configure_dfwd(struct ixgbe_adapter *adapter)
 	struct list_head *iter;
 	int err;
 
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+	netdev_for_each_all_upper_dev_rtnl(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *dfwd = netdev_priv(upper);
 			struct ixgbe_fwd_adapter *vadapter = dfwd->fwd_priv;
@@ -4601,7 +4601,7 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	netif_tx_start_all_queues(adapter->netdev);
 
 	/* enable any upper devices */
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+	netdev_for_each_all_upper_dev_rtnl(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *vlan = netdev_priv(upper);
 
@@ -4803,7 +4803,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_tx_disable(netdev);
 
 	/* disable any upper devices */
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+	netdev_for_each_all_upper_dev_rtnl(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *vlan = netdev_priv(upper);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b3de7c..59872b2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2843,6 +2843,8 @@ bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 bool netdev_has_any_upper_dev(struct net_device *dev);
 struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 						     struct list_head **iter);
+struct net_device *netdev_all_upper_get_next_dev_rtnl(struct net_device *dev,
+						      struct list_head **iter);
 
 /* iterate through upper list, must be called under RCU read lock */
 #define netdev_for_each_all_upper_dev_rcu(dev, updev, iter) \
@@ -2851,6 +2853,13 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 	     updev; \
 	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
 
+/* iterate through upper list, must be called under RTNL */
+#define netdev_for_each_all_upper_dev_rtnl(dev, updev, iter) \
+	for (iter = &(dev)->all_adj_list.upper, \
+	     updev = netdev_all_upper_get_next_dev_rtnl(dev, &(iter)); \
+	     updev; \
+	     updev = netdev_all_upper_get_next_dev_rtnl(dev, &(iter)))
+
 void *netdev_lower_get_next_private(struct net_device *dev,
 				    struct list_head **iter);
 void *netdev_lower_get_next_private_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 7e00a73..79c4c1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4487,6 +4487,21 @@ void *netdev_adjacent_get_private(struct list_head *adj_list)
 }
 EXPORT_SYMBOL(netdev_adjacent_get_private);
 
+static struct net_device *netdev_all_upper_get_next_dev(struct net_device *dev,
+							struct list_head **iter)
+{
+	struct netdev_adjacent *upper;
+
+	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+
+	if (&upper->list == &dev->all_adj_list.upper)
+		return NULL;
+
+	*iter = &upper->list;
+
+	return upper->dev;
+}
+
 /**
  * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
@@ -4498,22 +4513,28 @@ EXPORT_SYMBOL(netdev_adjacent_get_private);
 struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 						     struct list_head **iter)
 {
-	struct netdev_adjacent *upper;
-
 	WARN_ON_ONCE(!rcu_read_lock_held());
-
-	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
-
-	if (&upper->list == &dev->all_adj_list.upper)
-		return NULL;
-
-	*iter = &upper->list;
-
-	return upper->dev;
+	return netdev_all_upper_get_next_dev(dev, iter);
 }
 EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
 
 /**
+ * netdev_all_upper_get_next_dev_rtnl - Get the next dev from upper list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next device from the dev's upper list, starting from iter
+ * position. The caller must hold RTNL.
+ */
+struct net_device *netdev_all_upper_get_next_dev_rtnl(struct net_device *dev,
+						      struct list_head **iter)
+{
+	WARN_ON_ONCE(!lockdep_rtnl_is_held());
+	return netdev_all_upper_get_next_dev(dev, iter);
+}
+EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rtnl);
+
+/**
  * netdev_lower_get_next_private - Get the next ->private from the
  *				   lower neighbour list
  * @dev: device
-- 
1.8.3.1
