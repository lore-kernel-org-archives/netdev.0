From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/11] net: Remove all_adj_list and its references
Date: Wed, 12 Oct 2016 13:51:57 -0700
Message-ID: <1476305519-28833-10-git-send-email-dsa@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33184 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934182AbcJLUwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 16:52:19 -0400
Received: by mail-pf0-f171.google.com with SMTP id 128so23974005pfz.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 13:52:18 -0700 (PDT)
In-Reply-To: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only direct adjacencies are maintained. All upper or lower devices can
be learned via the new walk API which recursively walks the adj_list for
upper devices or lower devices.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h |  25 -----
 net/core/dev.c            | 229 +++++-----------------------------------------
 2 files changed, 21 insertions(+), 233 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 053f6f75f26a..8215908556ec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1456,7 +1456,6 @@ enum netdev_priv_flags {
  *	@ptype_specific: Device-specific, protocol-specific packet handlers
  *
  *	@adj_list:	Directly linked devices, like slaves for bonding
- *	@all_adj_list:	All linked devices, *including* neighbours
  *	@features:	Currently active device features
  *	@hw_features:	User-changeable features
  *
@@ -1673,11 +1672,6 @@ struct net_device {
 		struct list_head lower;
 	} adj_list;
 
-	struct {
-		struct list_head upper;
-		struct list_head lower;
-	} all_adj_list;
-
 	netdev_features_t	features;
 	netdev_features_t	hw_features;
 	netdev_features_t	wanted_features;
@@ -3832,13 +3826,6 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 	     updev; \
 	     updev = netdev_upper_get_next_dev_rcu(dev, &(iter)))
 
-/* iterate through upper list, must be called under RCU read lock */
-#define netdev_for_each_all_upper_dev_rcu(dev, updev, iter) \
-	for (iter = &(dev)->all_adj_list.upper, \
-	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)); \
-	     updev; \
-	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
-
 int netdev_walk_all_upper_dev_rcu(struct net_device *dev,
 				  int (*fn)(struct net_device *lower_dev,
 					    void *data),
@@ -3878,18 +3865,6 @@ struct net_device *netdev_all_lower_get_next(struct net_device *dev,
 struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
 						 struct list_head **iter);
 
-#define netdev_for_each_all_lower_dev(dev, ldev, iter) \
-	for (iter = (dev)->all_adj_list.lower.next, \
-	     ldev = netdev_all_lower_get_next(dev, &(iter)); \
-	     ldev; \
-	     ldev = netdev_all_lower_get_next(dev, &(iter)))
-
-#define netdev_for_each_all_lower_dev_rcu(dev, ldev, iter) \
-	for (iter = (dev)->all_adj_list.lower.next, \
-	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)); \
-	     ldev; \
-	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)))
-
 int netdev_walk_all_lower_dev(struct net_device *dev,
 			      int (*fn)(struct net_device *lower_dev,
 					void *data),
diff --git a/net/core/dev.c b/net/core/dev.c
index fcf3641db783..0f9b0985a84c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5273,6 +5273,16 @@ static struct netdev_adjacent *__netdev_find_adj(struct net_device *adj_dev,
 	return NULL;
 }
 
+static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+
+	if (upper_dev == dev)
+		return 1;
+
+	return 0;
+}
+
 /**
  * netdev_has_upper_dev - Check if device is linked to an upper device
  * @dev: device
@@ -5287,7 +5297,8 @@ bool netdev_has_upper_dev(struct net_device *dev,
 {
 	ASSERT_RTNL();
 
-	return __netdev_find_adj(upper_dev, &dev->all_adj_list.upper);
+	return netdev_walk_all_upper_dev_rcu(dev, __netdev_has_upper_dev,
+					     upper_dev);
 }
 EXPORT_SYMBOL(netdev_has_upper_dev);
 
@@ -5301,16 +5312,6 @@ EXPORT_SYMBOL(netdev_has_upper_dev);
  * The caller must hold rcu lock.
  */
 
-static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
-{
-	struct net_device *dev = (struct net_device *)data;
-
-	if (upper_dev == dev)
-		return 1;
-
-	return 0;
-}
-
 bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
 				  struct net_device *upper_dev)
 {
@@ -5333,7 +5334,7 @@ static bool netdev_has_any_upper_dev(struct net_device *dev)
 {
 	ASSERT_RTNL();
 
-	return !list_empty(&dev->all_adj_list.upper);
+	return !list_empty(&dev->adj_list.upper);
 }
 
 /**
@@ -5396,32 +5397,6 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_get_next_dev_rcu);
 
-/**
- * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
- * @dev: device
- * @iter: list_head ** of the current position
- *
- * Gets the next device from the dev's upper list, starting from iter
- * position. The caller must hold RCU read lock.
- */
-struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
-						     struct list_head **iter)
-{
-	struct netdev_adjacent *upper;
-
-	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
-
-	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
-
-	if (&upper->list == &dev->all_adj_list.upper)
-		return NULL;
-
-	*iter = &upper->list;
-
-	return upper->dev;
-}
-EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
-
 static struct net_device *netdev_next_upper_dev_rcu(struct net_device *dev,
 						    struct list_head **iter)
 {
@@ -5548,31 +5523,6 @@ void *netdev_lower_get_next(struct net_device *dev, struct list_head **iter)
 }
 EXPORT_SYMBOL(netdev_lower_get_next);
 
-/**
- * netdev_all_lower_get_next - Get the next device from all lower neighbour list
- * @dev: device
- * @iter: list_head ** of the current position
- *
- * Gets the next netdev_adjacent from the dev's all lower neighbour
- * list, starting from iter position. The caller must hold RTNL lock or
- * its own locking that guarantees that the neighbour all lower
- * list will remain unchanged.
- */
-struct net_device *netdev_all_lower_get_next(struct net_device *dev, struct list_head **iter)
-{
-	struct netdev_adjacent *lower;
-
-	lower = list_entry(*iter, struct netdev_adjacent, list);
-
-	if (&lower->list == &dev->all_adj_list.lower)
-		return NULL;
-
-	*iter = lower->list.next;
-
-	return lower->dev;
-}
-EXPORT_SYMBOL(netdev_all_lower_get_next);
-
 static struct net_device *netdev_next_lower_dev(struct net_device *dev,
 						struct list_head **iter)
 {
@@ -5616,27 +5566,6 @@ int netdev_walk_all_lower_dev(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(netdev_walk_all_lower_dev);
 
-/**
- * netdev_all_lower_get_next_rcu - Get the next device from all
- *				   lower neighbour list, RCU variant
- * @dev: device
- * @iter: list_head ** of the current position
- *
- * Gets the next netdev_adjacent from the dev's all lower neighbour
- * list, starting from iter position. The caller must hold RCU read lock.
- */
-struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
-						 struct list_head **iter)
-{
-	struct netdev_adjacent *lower;
-
-	lower = list_first_or_null_rcu(&dev->all_adj_list.lower,
-				       struct netdev_adjacent, list);
-
-	return lower ? lower->dev : NULL;
-}
-EXPORT_SYMBOL(netdev_all_lower_get_next_rcu);
-
 static struct net_device *netdev_next_lower_dev_rcu(struct net_device *dev,
 						    struct list_head **iter)
 {
@@ -5861,15 +5790,6 @@ static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 	return 0;
 }
 
-static int __netdev_adjacent_dev_link(struct net_device *dev,
-				      struct net_device *upper_dev)
-{
-	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
-						&dev->all_adj_list.upper,
-						&upper_dev->all_adj_list.lower,
-						NULL, false);
-}
-
 static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
 					       struct net_device *upper_dev,
 					       u16 ref_nr,
@@ -5880,40 +5800,19 @@ static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
 	__netdev_adjacent_dev_remove(upper_dev, dev, ref_nr, down_list);
 }
 
-static void __netdev_adjacent_dev_unlink(struct net_device *dev,
-					 struct net_device *upper_dev,
-					 u16 ref_nr)
-{
-	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, ref_nr,
-					   &dev->all_adj_list.upper,
-					   &upper_dev->all_adj_list.lower);
-}
-
 static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 						struct net_device *upper_dev,
 						void *private, bool master)
 {
-	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
-
-	if (ret)
-		return ret;
-
-	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev,
-					       &dev->adj_list.upper,
-					       &upper_dev->adj_list.lower,
-					       private, master);
-	if (ret) {
-		__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
-		return ret;
-	}
-
-	return 0;
+	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
+						&dev->adj_list.upper,
+						&upper_dev->adj_list.lower,
+						private, master);
 }
 
 static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 						   struct net_device *upper_dev)
 {
-	__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
 	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, 1,
 					   &dev->adj_list.upper,
 					   &upper_dev->adj_list.lower);
@@ -5924,7 +5823,6 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 				   void *upper_priv, void *upper_info)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
-	struct netdev_adjacent *i, *j, *to_i, *to_j;
 	int ret = 0;
 
 	ASSERT_RTNL();
@@ -5933,10 +5831,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return -EBUSY;
 
 	/* To prevent loops, check if dev is not upper device to upper_dev. */
-	if (__netdev_find_adj(dev, &upper_dev->all_adj_list.upper))
+	if (netdev_has_upper_dev(upper_dev, dev))
 		return -EBUSY;
 
-	if (__netdev_find_adj(upper_dev, &dev->adj_list.upper))
+	if (netdev_has_upper_dev(dev, upper_dev))
 		return -EEXIST;
 
 	if (master && netdev_master_upper_dev_get(dev))
@@ -5958,80 +5856,15 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (ret)
 		return ret;
 
-	/* Now that we linked these devs, make all the upper_dev's
-	 * all_adj_list.upper visible to every dev's all_adj_list.lower an
-	 * versa, and don't forget the devices itself. All of these
-	 * links are non-neighbours.
-	 */
-	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
-		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
-			pr_debug("Interlinking %s with %s, non-neighbour\n",
-				 i->dev->name, j->dev->name);
-			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
-			if (ret)
-				goto rollback_mesh;
-		}
-	}
-
-	/* add dev to every upper_dev's upper device */
-	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
-		pr_debug("linking %s's upper device %s with %s\n",
-			 upper_dev->name, i->dev->name, dev->name);
-		ret = __netdev_adjacent_dev_link(dev, i->dev);
-		if (ret)
-			goto rollback_upper_mesh;
-	}
-
-	/* add upper_dev to every dev's lower device */
-	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
-		pr_debug("linking %s's lower device %s with %s\n", dev->name,
-			 i->dev->name, upper_dev->name);
-		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
-		if (ret)
-			goto rollback_lower_mesh;
-	}
-
 	ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
 					    &changeupper_info.info);
 	ret = notifier_to_errno(ret);
 	if (ret)
-		goto rollback_lower_mesh;
+		goto rollback;
 
 	return 0;
 
-rollback_lower_mesh:
-	to_i = i;
-	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
-		if (i == to_i)
-			break;
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
-	}
-
-	i = NULL;
-
-rollback_upper_mesh:
-	to_i = i;
-	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
-		if (i == to_i)
-			break;
-		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
-	}
-
-	i = j = NULL;
-
-rollback_mesh:
-	to_i = i;
-	to_j = j;
-	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
-		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
-			if (i == to_i && j == to_j)
-				break;
-			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
-		}
-		if (i == to_i)
-			break;
-	}
-
+rollback:
 	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
 	return ret;
@@ -6088,7 +5921,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
-	struct netdev_adjacent *i, *j;
 	ASSERT_RTNL();
 
 	changeupper_info.upper_dev = upper_dev;
@@ -6100,23 +5932,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 
 	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
-	/* Here is the tricky part. We must remove all dev's lower
-	 * devices from all upper_dev's upper devices and vice
-	 * versa, to maintain the graph relationship.
-	 */
-	list_for_each_entry(i, &dev->all_adj_list.lower, list)
-		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list)
-			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
-
-	/* remove also the devices itself from lower/upper device
-	 * list
-	 */
-	list_for_each_entry(i, &dev->all_adj_list.lower, list)
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
-
-	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
-		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
-
 	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
 				      &changeupper_info.info);
 }
@@ -7809,8 +7624,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->link_watch_list);
 	INIT_LIST_HEAD(&dev->adj_list.upper);
 	INIT_LIST_HEAD(&dev->adj_list.lower);
-	INIT_LIST_HEAD(&dev->all_adj_list.upper);
-	INIT_LIST_HEAD(&dev->all_adj_list.lower);
 	INIT_LIST_HEAD(&dev->ptype_all);
 	INIT_LIST_HEAD(&dev->ptype_specific);
 #ifdef CONFIG_NET_SCHED
-- 
2.1.4
