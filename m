From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 09/11] net: Remove all_adj_list and its references
Date: Mon, 17 Oct 2016 19:15:51 -0700
Message-ID: <1476756953-30923-10-git-send-email-dsa@cumulusnetworks.com>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476756953-30923-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Only direct adjacencies are maintained. All upper or lower devices can
be learned via the new walk API which recursively walks the adj_list for
upper devices or lower devices.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 include/linux/netdevice.h |  25 ------
 net/core/dev.c            | 223 ++++------------------------------------------
 2 files changed, 18 insertions(+), 230 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a5902d995907..458c87631e7f 100644
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
@@ -1675,11 +1674,6 @@ struct net_device {
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
@@ -3771,13 +3765,6 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
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
 				  int (*fn)(struct net_device *upper_dev,
 					    void *data),
@@ -3817,18 +3804,6 @@ struct net_device *netdev_all_lower_get_next(struct net_device *dev,
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
index fc48337cfab8..a9fe14908b44 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5137,6 +5137,13 @@ static struct netdev_adjacent *__netdev_find_adj(struct net_device *adj_dev,
 	return NULL;
 }
 
+static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
+{
+	struct net_device *dev = data;
+
+	return upper_dev == dev;
+}
+
 /**
  * netdev_has_upper_dev - Check if device is linked to an upper device
  * @dev: device
@@ -5151,7 +5158,8 @@ bool netdev_has_upper_dev(struct net_device *dev,
 {
 	ASSERT_RTNL();
 
-	return __netdev_find_adj(upper_dev, &dev->all_adj_list.upper);
+	return netdev_walk_all_upper_dev_rcu(dev, __netdev_has_upper_dev,
+					     upper_dev);
 }
 EXPORT_SYMBOL(netdev_has_upper_dev);
 
@@ -5165,13 +5173,6 @@ EXPORT_SYMBOL(netdev_has_upper_dev);
  * The caller must hold rcu lock.
  */
 
-static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
-{
-	struct net_device *dev = data;
-
-	return upper_dev == dev;
-}
-
 bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
 				  struct net_device *upper_dev)
 {
@@ -5191,7 +5192,7 @@ static bool netdev_has_any_upper_dev(struct net_device *dev)
 {
 	ASSERT_RTNL();
 
-	return !list_empty(&dev->all_adj_list.upper);
+	return !list_empty(&dev->adj_list.upper);
 }
 
 /**
@@ -5254,32 +5255,6 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
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
@@ -5406,31 +5381,6 @@ void *netdev_lower_get_next(struct net_device *dev, struct list_head **iter)
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
@@ -5474,27 +5424,6 @@ int netdev_walk_all_lower_dev(struct net_device *dev,
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
@@ -5722,15 +5651,6 @@ static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
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
@@ -5741,40 +5661,19 @@ static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
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
@@ -5785,7 +5684,6 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 				   void *upper_priv, void *upper_info)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
-	struct netdev_adjacent *i, *j, *to_i, *to_j;
 	int ret = 0;
 
 	ASSERT_RTNL();
@@ -5794,10 +5692,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return -EBUSY;
 
 	/* To prevent loops, check if dev is not upper device to upper_dev. */
-	if (__netdev_find_adj(dev, &upper_dev->all_adj_list.upper))
+	if (netdev_has_upper_dev(upper_dev, dev))
 		return -EBUSY;
 
-	if (__netdev_find_adj(upper_dev, &dev->adj_list.upper))
+	if (netdev_has_upper_dev(dev, upper_dev))
 		return -EEXIST;
 
 	if (master && netdev_master_upper_dev_get(dev))
@@ -5819,80 +5717,15 @@ static int __netdev_upper_dev_link(struct net_device *dev,
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
@@ -5949,7 +5782,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
-	struct netdev_adjacent *i, *j;
 	ASSERT_RTNL();
 
 	changeupper_info.upper_dev = upper_dev;
@@ -5961,23 +5793,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 
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
@@ -7679,8 +7494,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
