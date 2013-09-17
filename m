From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 01/27] net: add adj_list to save only neighbours
Date: Tue, 17 Sep 2013 02:46:26 +0200
Message-ID: <1379378812-18346-2-git-send-email-vfalico@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665Ab3IQAqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:46:55 -0400
In-Reply-To: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we distinguish neighbours (first-level linked devices) from
non-neighbours by the neighbour bool in the netdev_adjacent. This could be
quite time-consuming in case we would like to traverse *only* through
neighbours - cause we'd have to traverse through all devices and check for
this flag, and in a (quite common) scenario where we have lots of vlans on
top of bridge, which is on top of a bond - the bonding would have to go
through all those vlans to get its upper neighbour linked devices.

This situation is really unpleasant, cause there are already a lot of cases
when a device with slaves needs to go through them in hot path.

To fix this, introduce a new upper/lower device lists structure -
adj_list, which contains only the neighbours. It works always in
pair with the all_adj_list structure (renamed from upper/lower_dev_list),
i.e. both of them contain the same links, only that all_adj_list contains
also non-neighbour device links. It's really a small change visible,
currently, only for __netdev_adjacent_dev_insert/remove(), and doesn't
change the main linked logic at all.

Also, add some comments a fix a name collision in
netdev_for_each_upper_dev_rcu() and rework the naming by the following
rules:

netdev_(all_)(upper|lower)_*

If "all_" is present, then we work with the whole list of upper/lower
devices, otherwise - only with direct neighbours. Uninline functions - to
get better stack traces.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2  -> v3:
    No change.
    
    v1  -> v2:
    Fix a bug when we've tried to add a non-neighbour dev1 to dev2, while dev2
    already had dev1 as a neighbour - we shouldn't care about neighbour's
    ref_nr at all cause we can only add one - so just add/remove it via
    different functions. And it became more readable.
    
    RFC -> v1:
    rename neighbour_dev_list/all_dev_list to adj_list/all_adj_list and rework
    the naming of functions - to make the use the pattern
    netdev_(all_)(lower|upper)_* . Uninline functions to get better stack
    traces - inline doesn't give much speed improvement, but this way the stack
    traces are meaningful.

 drivers/net/bonding/bond_alb.c  |   2 +-
 drivers/net/bonding/bond_main.c |  10 +-
 include/linux/netdevice.h       |  28 +++--
 net/core/dev.c                  | 219 ++++++++++++++++++++++++++++------------
 4 files changed, 179 insertions(+), 80 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 91f179d..c3dcc6b 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1019,7 +1019,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 
 	/* loop through vlans and send one packet for each */
 	rcu_read_lock();
-	netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 		if (upper->priv_flags & IFF_802_1Q_VLAN)
 			alb_send_lp_vid(slave, mac_addr,
 					vlan_dev_vlan_id(upper));
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39e5b1c..72bdb8b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2267,7 +2267,7 @@ static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
 		return true;
 
 	rcu_read_lock();
-	netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 		if (ip == bond_confirm_addr(upper, 0, ip)) {
 			ret = true;
 			break;
@@ -2342,10 +2342,12 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		 *
 		 * TODO: QinQ?
 		 */
-		netdev_for_each_upper_dev_rcu(bond->dev, vlan_upper, vlan_iter) {
+		netdev_for_each_all_upper_dev_rcu(bond->dev, vlan_upper,
+						  vlan_iter) {
 			if (!is_vlan_dev(vlan_upper))
 				continue;
-			netdev_for_each_upper_dev_rcu(vlan_upper, upper, iter) {
+			netdev_for_each_all_upper_dev_rcu(vlan_upper, upper,
+							  iter) {
 				if (upper == rt->dst.dev) {
 					vlan_id = vlan_dev_vlan_id(vlan_upper);
 					rcu_read_unlock();
@@ -2358,7 +2360,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		 * our upper vlans, then just search for any dev that
 		 * matches, and in case it's a vlan - save the id
 		 */
-		netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+		netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 			if (upper == rt->dst.dev) {
 				/* if it's a vlan - get its VID */
 				if (is_vlan_dev(upper))
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 041b42a..2a944e5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1143,8 +1143,18 @@ struct net_device {
 	struct list_head	dev_list;
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
-	struct list_head	upper_dev_list; /* List of upper devices */
-	struct list_head	lower_dev_list;
+
+	/* directly linked devices, like slaves for bonding */
+	struct {
+		struct list_head upper;
+		struct list_head lower;
+	} adj_list;
+
+	/* all linked devices, *including* neighbours */
+	struct {
+		struct list_head upper;
+		struct list_head lower;
+	} all_adj_list;
 
 
 	/* currently active device features */
@@ -2813,15 +2823,15 @@ extern int		bpf_jit_enable;
 extern bool netdev_has_upper_dev(struct net_device *dev,
 				 struct net_device *upper_dev);
 extern bool netdev_has_any_upper_dev(struct net_device *dev);
-extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
-							struct list_head **iter);
+extern struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
+							    struct list_head **iter);
 
 /* iterate through upper list, must be called under RCU read lock */
-#define netdev_for_each_upper_dev_rcu(dev, upper, iter) \
-	for (iter = &(dev)->upper_dev_list, \
-	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)); \
-	     upper; \
-	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)))
+#define netdev_for_each_all_upper_dev_rcu(dev, updev, iter) \
+	for (iter = &(dev)->all_adj_list.upper, \
+	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)); \
+	     updev; \
+	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
 
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..f69a8ab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4373,9 +4373,6 @@ struct netdev_adjacent {
 	/* upper master flag, there can only be one master device per list */
 	bool master;
 
-	/* indicates that this dev is our first-level lower/upper device */
-	bool neighbour;
-
 	/* counter for the number of times this device was added to us */
 	u16 ref_nr;
 
@@ -4385,30 +4382,47 @@ struct netdev_adjacent {
 
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
-						 bool upper)
+						 bool upper, bool neighbour)
 {
 	struct netdev_adjacent *adj;
-	struct list_head *dev_list;
+	struct list_head *adj_list;
 
-	dev_list = upper ? &dev->upper_dev_list : &dev->lower_dev_list;
+	if (neighbour)
+		adj_list = upper ? &dev->adj_list.upper :
+				   &dev->adj_list.lower;
+	else
+		adj_list = upper ? &dev->all_adj_list.upper :
+				   &dev->all_adj_list.lower;
 
-	list_for_each_entry(adj, dev_list, list) {
+	list_for_each_entry(adj, adj_list, list) {
 		if (adj->dev == adj_dev)
 			return adj;
 	}
 	return NULL;
 }
 
-static inline struct netdev_adjacent *__netdev_find_upper(struct net_device *dev,
-							  struct net_device *udev)
+static struct netdev_adjacent *__netdev_all_upper_find(struct net_device *dev,
+						       struct net_device *udev)
+{
+	return __netdev_find_adj(dev, udev, true, false);
+}
+
+static struct netdev_adjacent *__netdev_all_lower_find(struct net_device *dev,
+						       struct net_device *ldev)
 {
-	return __netdev_find_adj(dev, udev, true);
+	return __netdev_find_adj(dev, ldev, false, false);
 }
 
-static inline struct netdev_adjacent *__netdev_find_lower(struct net_device *dev,
-							  struct net_device *ldev)
+static struct netdev_adjacent *__netdev_upper_find(struct net_device *dev,
+						   struct net_device *udev)
 {
-	return __netdev_find_adj(dev, ldev, false);
+	return __netdev_find_adj(dev, udev, true, true);
+}
+
+static struct netdev_adjacent *__netdev_lower_find(struct net_device *dev,
+						   struct net_device *ldev)
+{
+	return __netdev_find_adj(dev, ldev, false, true);
 }
 
 /**
@@ -4425,7 +4439,7 @@ bool netdev_has_upper_dev(struct net_device *dev,
 {
 	ASSERT_RTNL();
 
-	return __netdev_find_upper(dev, upper_dev);
+	return __netdev_all_upper_find(dev, upper_dev);
 }
 EXPORT_SYMBOL(netdev_has_upper_dev);
 
@@ -4440,7 +4454,7 @@ bool netdev_has_any_upper_dev(struct net_device *dev)
 {
 	ASSERT_RTNL();
 
-	return !list_empty(&dev->upper_dev_list);
+	return !list_empty(&dev->all_adj_list.upper);
 }
 EXPORT_SYMBOL(netdev_has_any_upper_dev);
 
@@ -4457,10 +4471,10 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if (list_empty(&dev->upper_dev_list))
+	if (list_empty(&dev->adj_list.upper))
 		return NULL;
 
-	upper = list_first_entry(&dev->upper_dev_list,
+	upper = list_first_entry(&dev->adj_list.upper,
 				 struct netdev_adjacent, list);
 	if (likely(upper->master))
 		return upper->dev;
@@ -4468,15 +4482,15 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get);
 
-/* netdev_upper_get_next_dev_rcu - Get the next dev from upper list
+/* netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
  * @iter: list_head ** of the current position
  *
  * Gets the next device from the dev's upper list, starting from iter
  * position. The caller must hold RCU read lock.
  */
-struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
-						 struct list_head **iter)
+struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
+						     struct list_head **iter)
 {
 	struct netdev_adjacent *upper;
 
@@ -4484,14 +4498,14 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 
 	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
 
-	if (&upper->list == &dev->upper_dev_list)
+	if (&upper->list == &dev->all_adj_list.upper)
 		return NULL;
 
 	*iter = &upper->list;
 
 	return upper->dev;
 }
-EXPORT_SYMBOL(netdev_upper_get_next_dev_rcu);
+EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
 
 /**
  * netdev_master_upper_dev_get_rcu - Get master upper device
@@ -4504,7 +4518,7 @@ struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
 {
 	struct netdev_adjacent *upper;
 
-	upper = list_first_or_null_rcu(&dev->upper_dev_list,
+	upper = list_first_or_null_rcu(&dev->adj_list.upper,
 				       struct netdev_adjacent, list);
 	if (upper && likely(upper->master))
 		return upper->dev;
@@ -4517,11 +4531,12 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					bool neighbour, bool master,
 					bool upper)
 {
-	struct netdev_adjacent *adj;
+	struct netdev_adjacent *adj, *neigh = NULL;
 
-	adj = __netdev_find_adj(dev, adj_dev, upper);
+	adj = __netdev_find_adj(dev, adj_dev, upper, false);
 
 	if (adj) {
+		/* we cannot insert a neighbour device twice */
 		BUG_ON(neighbour);
 		adj->ref_nr++;
 		return 0;
@@ -4533,58 +4548,103 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	adj->dev = adj_dev;
 	adj->master = master;
-	adj->neighbour = neighbour;
 	adj->ref_nr = 1;
-
 	dev_hold(adj_dev);
+
+	if (neighbour) {
+		neigh = kmalloc(sizeof(*neigh), GFP_KERNEL);
+		if (!neigh) {
+			kfree(adj);
+			return -ENOMEM;
+		}
+		neigh->dev = adj_dev;
+		neigh->master = master;
+		neigh->ref_nr = 1;
+		dev_hold(adj_dev);
+	}
+
 	pr_debug("dev_hold for %s, because of %s link added from %s to %s\n",
 		 adj_dev->name, upper ? "upper" : "lower", dev->name,
 		 adj_dev->name);
+	if (neigh)
+		pr_debug("dev_hold for %s, because of %s link added from %s to %s (neighbour)\n",
+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
+			 adj_dev->name);
 
 	if (!upper) {
-		list_add_tail_rcu(&adj->list, &dev->lower_dev_list);
+		if (neigh)
+			list_add_tail_rcu(&neigh->list,
+					  &dev->adj_list.lower);
+		list_add_tail_rcu(&adj->list, &dev->all_adj_list.lower);
 		return 0;
 	}
 
 	/* Ensure that master upper link is always the first item in list. */
-	if (master)
-		list_add_rcu(&adj->list, &dev->upper_dev_list);
-	else
-		list_add_tail_rcu(&adj->list, &dev->upper_dev_list);
+	if (master) {
+		if (neigh)
+			list_add_rcu(&neigh->list,
+				     &dev->adj_list.upper);
+		list_add_rcu(&adj->list, &dev->all_adj_list.upper);
+	} else {
+		if (neigh)
+			list_add_tail_rcu(&neigh->list,
+					  &dev->adj_list.upper);
+		list_add_tail_rcu(&adj->list, &dev->all_adj_list.upper);
+	}
 
 	return 0;
 }
 
-static inline int __netdev_upper_dev_insert(struct net_device *dev,
-					    struct net_device *udev,
-					    bool master, bool neighbour)
+static int __netdev_upper_dev_insert(struct net_device *dev,
+				     struct net_device *udev,
+				     bool master, bool neighbour)
 {
 	return __netdev_adjacent_dev_insert(dev, udev, neighbour, master,
 					    true);
 }
 
-static inline int __netdev_lower_dev_insert(struct net_device *dev,
-					    struct net_device *ldev,
-					    bool neighbour)
+static int __netdev_lower_dev_insert(struct net_device *dev,
+				     struct net_device *ldev,
+				     bool neighbour)
 {
 	return __netdev_adjacent_dev_insert(dev, ldev, neighbour, false,
 					    false);
 }
 
 void __netdev_adjacent_dev_remove(struct net_device *dev,
-				  struct net_device *adj_dev, bool upper)
+				  struct net_device *adj_dev, bool upper,
+				  bool is_neigh)
 {
-	struct netdev_adjacent *adj;
+	struct netdev_adjacent *adj, *neighbour;
 
-	if (upper)
-		adj = __netdev_find_upper(dev, adj_dev);
-	else
-		adj = __netdev_find_lower(dev, adj_dev);
+	if (upper) {
+		adj = __netdev_all_upper_find(dev, adj_dev);
+		neighbour = __netdev_upper_find(dev, adj_dev);
+	} else {
+		adj = __netdev_all_lower_find(dev, adj_dev);
+		neighbour = __netdev_lower_find(dev, adj_dev);
+	}
 
-	if (!adj)
+	if (!adj) {
+		pr_err("tried to remove %s device %s from %s\n",
+		       upper ? "upper" : "lower", dev->name, adj_dev->name);
 		BUG();
+	}
+
+	if (is_neigh) {
+		BUG_ON(!neighbour || neighbour->ref_nr > 1);
+		pr_debug("dev_put for %s, because of %s link removed from %s to %s (neighbour)\n",
+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
+			 adj_dev->name);
+		list_del_rcu(&neighbour->list);
+		dev_put(adj_dev);
+		kfree_rcu(neighbour, rcu);
+	}
 
 	if (adj->ref_nr > 1) {
+		pr_debug("rec_cnt-- for link to %s, because of %s link removed from %s to %s, remains %d\n",
+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
+			 adj_dev->name, adj->ref_nr-1);
 		adj->ref_nr--;
 		return;
 	}
@@ -4600,13 +4660,25 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 static inline void __netdev_upper_dev_remove(struct net_device *dev,
 					     struct net_device *udev)
 {
-	return __netdev_adjacent_dev_remove(dev, udev, true);
+	return __netdev_adjacent_dev_remove(dev, udev, true, false);
+}
+
+static inline void __netdev_upper_dev_remove_neighbour(struct net_device *dev,
+						struct net_device *udev)
+{
+	return __netdev_adjacent_dev_remove(dev, udev, true, true);
 }
 
 static inline void __netdev_lower_dev_remove(struct net_device *dev,
 					     struct net_device *ldev)
 {
-	return __netdev_adjacent_dev_remove(dev, ldev, false);
+	return __netdev_adjacent_dev_remove(dev, ldev, false, false);
+}
+
+static inline void __netdev_lower_dev_remove_neighbour(struct net_device *dev,
+						struct net_device *ldev)
+{
+	return __netdev_adjacent_dev_remove(dev, ldev, false, true);
 }
 
 int __netdev_adjacent_dev_insert_link(struct net_device *dev,
@@ -4648,6 +4720,13 @@ void __netdev_adjacent_dev_unlink(struct net_device *dev,
 	__netdev_lower_dev_remove(upper_dev, dev);
 }
 
+void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
+					    struct net_device *upper_dev)
+{
+	__netdev_upper_dev_remove_neighbour(dev, upper_dev);
+	__netdev_lower_dev_remove_neighbour(upper_dev, dev);
+}
+
 
 static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master)
@@ -4661,10 +4740,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return -EBUSY;
 
 	/* To prevent loops, check if dev is not upper device to upper_dev. */
-	if (__netdev_find_upper(upper_dev, dev))
+	if (__netdev_all_upper_find(upper_dev, dev))
 		return -EBUSY;
 
-	if (__netdev_find_upper(dev, upper_dev))
+	if (__netdev_all_upper_find(dev, upper_dev))
 		return -EEXIST;
 
 	if (master && netdev_master_upper_dev_get(dev))
@@ -4675,12 +4754,14 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return ret;
 
 	/* Now that we linked these devs, make all the upper_dev's
-	 * upper_dev_list visible to every dev's lower_dev_list and vice
+	 * all_adj_list.upper visible to every dev's all_adj_list.lower an
 	 * versa, and don't forget the devices itself. All of these
 	 * links are non-neighbours.
 	 */
-	list_for_each_entry(i, &dev->lower_dev_list, list) {
-		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
+		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
+			pr_debug("Interlinking %s with %s, non-neighbour\n",
+				 i->dev->name, j->dev->name);
 			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
 			if (ret)
 				goto rollback_mesh;
@@ -4688,14 +4769,18 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	}
 
 	/* add dev to every upper_dev's upper device */
-	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
+	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
+		pr_debug("linking %s's upper device %s with %s\n",
+			 upper_dev->name, i->dev->name, dev->name);
 		ret = __netdev_adjacent_dev_link(dev, i->dev);
 		if (ret)
 			goto rollback_upper_mesh;
 	}
 
 	/* add upper_dev to every dev's lower device */
-	list_for_each_entry(i, &dev->lower_dev_list, list) {
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
+		pr_debug("linking %s's lower device %s with %s\n", dev->name,
+			 i->dev->name, upper_dev->name);
 		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
 		if (ret)
 			goto rollback_lower_mesh;
@@ -4706,7 +4791,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 
 rollback_lower_mesh:
 	to_i = i;
-	list_for_each_entry(i, &dev->lower_dev_list, list) {
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		if (i == to_i)
 			break;
 		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
@@ -4716,7 +4801,7 @@ rollback_lower_mesh:
 
 rollback_upper_mesh:
 	to_i = i;
-	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
+	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		if (i == to_i)
 			break;
 		__netdev_adjacent_dev_unlink(dev, i->dev);
@@ -4727,8 +4812,8 @@ rollback_upper_mesh:
 rollback_mesh:
 	to_i = i;
 	to_j = j;
-	list_for_each_entry(i, &dev->lower_dev_list, list) {
-		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
+		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			if (i == to_i && j == to_j)
 				break;
 			__netdev_adjacent_dev_unlink(i->dev, j->dev);
@@ -4737,7 +4822,7 @@ rollback_mesh:
 			break;
 	}
 
-	__netdev_adjacent_dev_unlink(dev, upper_dev);
+	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
 	return ret;
 }
@@ -4791,23 +4876,23 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	struct netdev_adjacent *i, *j;
 	ASSERT_RTNL();
 
-	__netdev_adjacent_dev_unlink(dev, upper_dev);
+	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
 	/* Here is the tricky part. We must remove all dev's lower
 	 * devices from all upper_dev's upper devices and vice
 	 * versa, to maintain the graph relationship.
 	 */
-	list_for_each_entry(i, &dev->lower_dev_list, list)
-		list_for_each_entry(j, &upper_dev->upper_dev_list, list)
+	list_for_each_entry(i, &dev->all_adj_list.lower, list)
+		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list)
 			__netdev_adjacent_dev_unlink(i->dev, j->dev);
 
 	/* remove also the devices itself from lower/upper device
 	 * list
 	 */
-	list_for_each_entry(i, &dev->lower_dev_list, list)
+	list_for_each_entry(i, &dev->all_adj_list.lower, list)
 		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
 
-	list_for_each_entry(i, &upper_dev->upper_dev_list, list)
+	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
 		__netdev_adjacent_dev_unlink(dev, i->dev);
 
 	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
@@ -6069,8 +6154,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
-	INIT_LIST_HEAD(&dev->upper_dev_list);
-	INIT_LIST_HEAD(&dev->lower_dev_list);
+	INIT_LIST_HEAD(&dev->adj_list.upper);
+	INIT_LIST_HEAD(&dev->adj_list.lower);
+	INIT_LIST_HEAD(&dev->all_adj_list.upper);
+	INIT_LIST_HEAD(&dev->all_adj_list.lower);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 
-- 
1.8.4
