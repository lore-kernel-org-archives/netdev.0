From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2] net: core functions cleanup
Date: Sun, 29 Dec 2013 14:01:29 -0800
Message-ID: <20131229140129.48d941ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:59941 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab3L2WBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 17:01:33 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so10697969pde.21
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:01:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following functions are not used outside of net/core/dev.c
and should be declared static.

  call_netdevice_notifiers_info
  __dev_remove_offload
  netdev_has_any_upper_dev
  __netdev_adjacent_dev_remove
  __netdev_adjacent_dev_link_lists
  __netdev_adjacent_dev_unlink_lists
  __netdev_adjacent_dev_unlink
  __netdev_adjacent_dev_link_neighbour
  __netdev_adjacent_dev_unlink_neighbour


And the following are never used and should be deleted
  netdev_lower_dev_get_private_rcu
  __netdev_find_adj_rcu


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 - reindent call_netdevice_notifiers_info

 include/linux/netdevice.h |    6 ---
 net/core/dev.c            |   79 +++++++++++++---------------------------------
 2 files changed, 24 insertions(+), 61 deletions(-)

--- a/include/linux/netdevice.h	2013-12-29 13:53:00.328487022 -0800
+++ b/include/linux/netdevice.h	2013-12-29 13:54:06.351415257 -0800
@@ -1741,8 +1741,6 @@ netdev_notifier_info_to_dev(const struct
 	return info->dev;
 }
 
-int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
-				  struct netdev_notifier_info *info);
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 
@@ -1809,7 +1807,6 @@ void dev_remove_pack(struct packet_type
 void __dev_remove_pack(struct packet_type *pt);
 void dev_add_offload(struct packet_offload *po);
 void dev_remove_offload(struct packet_offload *po);
-void __dev_remove_offload(struct packet_offload *po);
 
 struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short flags,
 					unsigned short mask);
@@ -2867,7 +2864,6 @@ extern int		weight_p;
 extern int		bpf_jit_enable;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
-bool netdev_has_any_upper_dev(struct net_device *dev);
 struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 						     struct list_head **iter);
 
@@ -2907,8 +2903,6 @@ int netdev_master_upper_dev_link_private
 					 void *private);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev);
-void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
-				       struct net_device *lower_dev);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
 int skb_checksum_help(struct sk_buff *skb);
--- a/net/core/dev.c	2013-12-29 13:53:00.328487022 -0800
+++ b/net/core/dev.c	2013-12-29 13:54:36.994908644 -0800
@@ -480,7 +480,7 @@ EXPORT_SYMBOL(dev_add_offload);
  *	and must not be freed until after all the CPU's have gone
  *	through a quiescent state.
  */
-void __dev_remove_offload(struct packet_offload *po)
+static void __dev_remove_offload(struct packet_offload *po)
 {
 	struct list_head *head = &offload_base;
 	struct packet_offload *po1;
@@ -498,7 +498,6 @@ void __dev_remove_offload(struct packet_
 out:
 	spin_unlock(&offload_lock);
 }
-EXPORT_SYMBOL(__dev_remove_offload);
 
 /**
  *	dev_remove_offload	 - remove packet offload handler
@@ -1566,14 +1565,14 @@ EXPORT_SYMBOL(unregister_netdevice_notif
  *	are as for raw_notifier_call_chain().
  */
 
-int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
-				  struct netdev_notifier_info *info)
+static int call_netdevice_notifiers_info(unsigned long val,
+					 struct net_device *dev,
+					 struct netdev_notifier_info *info)
 {
 	ASSERT_RTNL();
 	netdev_notifier_info_init(info, dev);
 	return raw_notifier_call_chain(&netdev_chain, val, info);
 }
-EXPORT_SYMBOL(call_netdevice_notifiers_info);
 
 /**
  *	call_netdevice_notifiers - call all network notifier blocks
@@ -4355,19 +4354,6 @@ struct netdev_adjacent {
 	struct rcu_head rcu;
 };
 
-static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
-						     struct net_device *adj_dev,
-						     struct list_head *adj_list)
-{
-	struct netdev_adjacent *adj;
-
-	list_for_each_entry_rcu(adj, adj_list, list) {
-		if (adj->dev == adj_dev)
-			return adj;
-	}
-	return NULL;
-}
-
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
 						 struct list_head *adj_list)
@@ -4406,13 +4392,12 @@ EXPORT_SYMBOL(netdev_has_upper_dev);
  * Find out if a device is linked to an upper device and return true in case
  * it is. The caller must hold the RTNL lock.
  */
-bool netdev_has_any_upper_dev(struct net_device *dev)
+static bool netdev_has_any_upper_dev(struct net_device *dev)
 {
 	ASSERT_RTNL();
 
 	return !list_empty(&dev->all_adj_list.upper);
 }
-EXPORT_SYMBOL(netdev_has_any_upper_dev);
 
 /**
  * netdev_master_upper_dev_get - Get master upper device
@@ -4644,9 +4629,9 @@ free_adj:
 	return ret;
 }
 
-void __netdev_adjacent_dev_remove(struct net_device *dev,
-				  struct net_device *adj_dev,
-				  struct list_head *dev_list)
+static void __netdev_adjacent_dev_remove(struct net_device *dev,
+					 struct net_device *adj_dev,
+					 struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
 	char linkname[IFNAMSIZ+7];
@@ -4684,11 +4669,11 @@ void __netdev_adjacent_dev_remove(struct
 	kfree_rcu(adj, rcu);
 }
 
-int __netdev_adjacent_dev_link_lists(struct net_device *dev,
-				     struct net_device *upper_dev,
-				     struct list_head *up_list,
-				     struct list_head *down_list,
-				     void *private, bool master)
+static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
+					    struct net_device *upper_dev,
+					    struct list_head *up_list,
+					    struct list_head *down_list,
+					    void *private, bool master)
 {
 	int ret;
 
@@ -4707,8 +4692,8 @@ int __netdev_adjacent_dev_link_lists(str
 	return 0;
 }
 
-int __netdev_adjacent_dev_link(struct net_device *dev,
-			       struct net_device *upper_dev)
+static int __netdev_adjacent_dev_link(struct net_device *dev,
+				      struct net_device *upper_dev)
 {
 	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
 						&dev->all_adj_list.upper,
@@ -4716,26 +4701,26 @@ int __netdev_adjacent_dev_link(struct ne
 						NULL, false);
 }
 
-void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
-					struct net_device *upper_dev,
-					struct list_head *up_list,
-					struct list_head *down_list)
+static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
+					       struct net_device *upper_dev,
+					       struct list_head *up_list,
+					       struct list_head *down_list)
 {
 	__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
 	__netdev_adjacent_dev_remove(upper_dev, dev, down_list);
 }
 
-void __netdev_adjacent_dev_unlink(struct net_device *dev,
-				  struct net_device *upper_dev)
+static void __netdev_adjacent_dev_unlink(struct net_device *dev,
+					 struct net_device *upper_dev)
 {
 	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
 					   &dev->all_adj_list.upper,
 					   &upper_dev->all_adj_list.lower);
 }
 
-int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
-					 struct net_device *upper_dev,
-					 void *private, bool master)
+static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
+						struct net_device *upper_dev,
+						void *private, bool master)
 {
 	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
 
@@ -4754,8 +4739,8 @@ int __netdev_adjacent_dev_link_neighbour
 	return 0;
 }
 
-void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
-					    struct net_device *upper_dev)
+static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
+						   struct net_device *upper_dev)
 {
 	__netdev_adjacent_dev_unlink(dev, upper_dev);
 	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
@@ -4944,21 +4929,6 @@ void netdev_upper_dev_unlink(struct net_
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
-				       struct net_device *lower_dev)
-{
-	struct netdev_adjacent *lower;
-
-	if (!lower_dev)
-		return NULL;
-	lower = __netdev_find_adj_rcu(dev, lower_dev, &dev->adj_list.lower);
-	if (!lower)
-		return NULL;
-
-	return lower->private;
-}
-EXPORT_SYMBOL(netdev_lower_dev_get_private_rcu);
-
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev)
 {
