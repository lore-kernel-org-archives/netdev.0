From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH RFC net-next 01/21] net: add neighbour_dev_list to save
 only neighbours
Date: Tue, 3 Sep 2013 10:29:43 +0200
Message-ID: <20130903082943.GD1437@minipsycho.brq.redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
 <1378157965-17537-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:49530 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759652Ab3ICI3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 04:29:47 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so2786947eek.20
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 01:29:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1378157965-17537-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 02, 2013 at 11:39:05PM CEST, vfalico@redhat.com wrote:
>Currently, we distinguish neighbours (first-level linked devices) from
>non-neighbours by the neighbour bool in the netdev_adjacent. This could be
>quite time-consuming in case we would like to traverse *only* through
>neighbours - cause we'd have to traverse through all devices and check for
>this flag, and in a (quite common) scenario where we have lots of vlans on
>top of bridge, which is on top of a bond - the bonding would have to go
>through all those vlans to get its upper neighbour linked devices.
>
>This situation is really unpleasant, cause there are already a lot of cases
>when a device with slaves needs to go through them in hot path.
>
>To fix this, introduce a new upper/lower device lists structure -
>neighbour_dev_list, which contains only the neighbours. It works always in
>pair with the all_device_list structure (renamed from upper/lower_dev_list),
>i.e. both of them contain the same links, only that all_dev_list contains
>also non-neighbour device links. It's really a small change visible,
>currently, only for __netdev_adjacent_dev_insert/remove(), and doesn't
>change the main linked logic at all.
>
>Also, add some comments a fix a name collision in
>netdev_for_each_upper_dev_rcu().
>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Cong Wang <amwang@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> include/linux/netdevice.h |  24 ++++---
> net/core/dev.c            | 157 ++++++++++++++++++++++++++++++++++------------
> 2 files changed, 134 insertions(+), 47 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 3ad49b8..df50548 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1124,8 +1124,18 @@ struct net_device {
> 	struct list_head	dev_list;
> 	struct list_head	napi_list;
> 	struct list_head	unreg_list;
>-	struct list_head	upper_dev_list; /* List of upper devices */
>-	struct list_head	lower_dev_list;
>+
>+	/* directly linked devices, like slaves for bonding */
>+	struct {
>+		struct list_head upper;
>+		struct list_head lower;
>+	} neighbour_dev_list ;
>+
>+	/* all linked devices, *including* neighbours */
>+	struct {
>+		struct list_head upper;
>+		struct list_head lower;
>+	} all_dev_list ;


I think there is need for some naming consistency for functions and
macros handling these lists.

I propose:
dev_list (drop the "neighbour") and all_dev_list

and exported functions and macros called like:
netdev_lower_get_next_priv()
netdev_lower_for_each_priv()
netdev_all_upper_get_next_rcu()
etc...

> 
> 
> 	/* currently active device features */
>@@ -2772,11 +2782,11 @@ extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
> 							struct list_head **iter);
> 
> /* iterate through upper list, must be called under RCU read lock */
>-#define netdev_for_each_upper_dev_rcu(dev, upper, iter) \
>-	for (iter = &(dev)->upper_dev_list, \
>-	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)); \
>-	     upper; \
>-	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)))
>+#define netdev_for_each_upper_dev_rcu(dev, updev, iter) \
>+	for (iter = &(dev)->all_dev_list.upper, \
>+	     updev= netdev_upper_get_next_dev_rcu(dev, &(iter)); \
>+	     updev; \
>+	     updev = netdev_upper_get_next_dev_rcu(dev, &(iter)))
> 
> extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
> extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 743620e..9e4eb40 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4373,9 +4373,6 @@ struct netdev_adjacent {
> 	/* upper master flag, there can only be one master device per list */
> 	bool master;
> 
>-	/* indicates that this dev is our first-level lower/upper device */
>-	bool neighbour;
>-
> 	/* counter for the number of times this device was added to us */
> 	u16 ref_nr;
> 
>@@ -4385,12 +4382,17 @@ struct netdev_adjacent {
> 
> static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
> 						 struct net_device *adj_dev,
>-						 bool upper)
>+						 bool upper, bool neighbour)
> {
> 	struct netdev_adjacent *adj;
> 	struct list_head *dev_list;
> 
>-	dev_list = upper ? &dev->upper_dev_list : &dev->lower_dev_list;
>+	if (neighbour)
>+		dev_list = upper ? &dev->neighbour_dev_list.upper :
>+				   &dev->neighbour_dev_list.lower;
>+	else
>+		dev_list = upper ? &dev->all_dev_list.upper :
>+				   &dev->all_dev_list.lower;
> 
> 	list_for_each_entry(adj, dev_list, list) {
> 		if (adj->dev == adj_dev)
>@@ -4402,13 +4404,25 @@ static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
> static inline struct netdev_adjacent *__netdev_find_upper(struct net_device *dev,
> 							  struct net_device *udev)
> {
>-	return __netdev_find_adj(dev, udev, true);
>+	return __netdev_find_adj(dev, udev, true, false);
> }
> 
> static inline struct netdev_adjacent *__netdev_find_lower(struct net_device *dev,
> 							  struct net_device *ldev)
> {
>-	return __netdev_find_adj(dev, ldev, false);
>+	return __netdev_find_adj(dev, ldev, false, false);
>+}
>+
>+static inline struct netdev_adjacent *__netdev_find_upper_neighbour(struct net_device *dev,
>+								    struct net_device *udev)
>+{
>+	return __netdev_find_adj(dev, udev, true, true);
>+}
>+
>+static inline struct netdev_adjacent *__netdev_find_lower_neighbour(struct net_device *dev,
>+								    struct net_device *ldev)
>+{
>+	return __netdev_find_adj(dev, ldev, false, true);
> }
> 
> /**
>@@ -4440,7 +4454,7 @@ bool netdev_has_any_upper_dev(struct net_device *dev)
> {
> 	ASSERT_RTNL();
> 
>-	return !list_empty(&dev->upper_dev_list);
>+	return !list_empty(&dev->all_dev_list.upper);
> }
> EXPORT_SYMBOL(netdev_has_any_upper_dev);
> 
>@@ -4457,10 +4471,10 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
> 
> 	ASSERT_RTNL();
> 
>-	if (list_empty(&dev->upper_dev_list))
>+	if (list_empty(&dev->neighbour_dev_list.upper))
> 		return NULL;
> 
>-	upper = list_first_entry(&dev->upper_dev_list,
>+	upper = list_first_entry(&dev->neighbour_dev_list.upper,
> 				 struct netdev_adjacent, list);
> 	if (likely(upper->master))
> 		return upper->dev;
>@@ -4484,7 +4498,7 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
> 
> 	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
> 
>-	if (&upper->list == &dev->upper_dev_list)
>+	if (&upper->list == &dev->all_dev_list.upper)
> 		return NULL;
> 
> 	*iter = &upper->list;
>@@ -4504,7 +4518,7 @@ struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
> {
> 	struct netdev_adjacent *upper;
> 
>-	upper = list_first_or_null_rcu(&dev->upper_dev_list,
>+	upper = list_first_or_null_rcu(&dev->neighbour_dev_list.upper,
> 				       struct netdev_adjacent, list);
> 	if (upper && likely(upper->master))
> 		return upper->dev;
>@@ -4517,11 +4531,12 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
> 					bool neighbour, bool master,
> 					bool upper)
> {
>-	struct netdev_adjacent *adj;
>+	struct netdev_adjacent *adj, *neigh = NULL;
> 
>-	adj = __netdev_find_adj(dev, adj_dev, upper);
>+	adj = __netdev_find_adj(dev, adj_dev, upper, false);
> 
> 	if (adj) {
>+		/* we cannot insert a neighbour device twice */
> 		BUG_ON(neighbour);
> 		adj->ref_nr++;
> 		return 0;
>@@ -4533,24 +4548,50 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
> 
> 	adj->dev = adj_dev;
> 	adj->master = master;
>-	adj->neighbour = neighbour;
> 	adj->ref_nr = 1;
>-
> 	dev_hold(adj_dev);
>+
>+	if (neighbour) {
>+		neigh = kmalloc(sizeof(*neigh), GFP_KERNEL);
>+		if (!neigh) {
>+			kfree(adj);
>+			return -ENOMEM;
>+		}
>+		neigh->dev = adj_dev;
>+		neigh->master = master;
>+		neigh->ref_nr = 1;
>+		dev_hold(adj_dev);
>+	}
>+
> 	pr_debug("dev_hold for %s, because of %s link added from %s to %s\n",
> 		 adj_dev->name, upper ? "upper" : "lower", dev->name,
> 		 adj_dev->name);
>+	if (neigh)
>+		pr_debug("dev_hold for %s, because of %s link added from %s"
>+			 " to %s (neighbour)\n",
>+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
>+			 adj_dev->name);
> 
> 	if (!upper) {
>-		list_add_tail_rcu(&adj->list, &dev->lower_dev_list);
>+		if (neigh)
>+			list_add_tail_rcu(&neigh->list,
>+					  &dev->neighbour_dev_list.lower);
>+		list_add_tail_rcu(&adj->list, &dev->all_dev_list.lower);
> 		return 0;
> 	}
> 
> 	/* Ensure that master upper link is always the first item in list. */
>-	if (master)
>-		list_add_rcu(&adj->list, &dev->upper_dev_list);
>-	else
>-		list_add_tail_rcu(&adj->list, &dev->upper_dev_list);
>+	if (master) {
>+		if (neigh)
>+			list_add_rcu(&neigh->list,
>+				     &dev->neighbour_dev_list.upper);
>+		list_add_rcu(&adj->list, &dev->all_dev_list.upper);
>+	} else {
>+		if (neigh)
>+			list_add_tail_rcu(&neigh->list,
>+					  &dev->neighbour_dev_list.upper);
>+		list_add_tail_rcu(&adj->list, &dev->all_dev_list.upper);
>+	}
> 
> 	return 0;
> }
>@@ -4574,17 +4615,36 @@ static inline int __netdev_lower_dev_insert(struct net_device *dev,
> void __netdev_adjacent_dev_remove(struct net_device *dev,
> 				  struct net_device *adj_dev, bool upper)
> {
>-	struct netdev_adjacent *adj;
>+	struct netdev_adjacent *adj, *neighbour;
> 
>-	if (upper)
>+	if (upper) {
> 		adj = __netdev_find_upper(dev, adj_dev);
>-	else
>+		neighbour = __netdev_find_upper_neighbour(dev, adj_dev);
>+	} else {
> 		adj = __netdev_find_lower(dev, adj_dev);
>+		neighbour = __netdev_find_lower_neighbour(dev, adj_dev);
>+	}
> 
>-	if (!adj)
>+	if (!adj) {
>+		pr_err("tried to remove %s device %s from %s\n",
>+		       upper ? "upper" : "lower", dev->name, adj_dev->name);
> 		BUG();
>+	}
> 
> 	if (adj->ref_nr > 1) {
>+		pr_debug("rec_cnt-- for link to %s, because of %s link removed"
>+			 " from %s to %s, remains %d\n",
>+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
>+			 adj_dev->name, adj->ref_nr-1);
>+		if (neighbour) {
>+			pr_debug("rec_cnt-- for link to %s, because of %s link"
>+				 " removed from %s to %s, remain %d (neigh)\n",
>+				 adj_dev->name, upper ? "upper" : "lower",
>+				 dev->name, adj_dev->name,
>+				 neighbour->ref_nr-1);
>+			BUG_ON(adj->ref_nr != neighbour->ref_nr);
>+			neighbour->ref_nr--;
>+		}
> 		adj->ref_nr--;
> 		return;
> 	}
>@@ -4595,6 +4655,15 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
> 		 adj_dev->name);
> 	dev_put(adj_dev);
> 	kfree_rcu(adj, rcu);
>+	if (neighbour) {
>+		pr_debug("dev_put for %s, because of %s link removed from %s"
>+			 " to %s (neighbour)\n",
>+			 adj_dev->name, upper ? "upper" : "lower", dev->name,
>+			 adj_dev->name);
>+		list_del_rcu(&neighbour->list);
>+		dev_put(adj_dev);
>+		kfree_rcu(neighbour, rcu);
>+	}
> }
> 
> static inline void __netdev_upper_dev_remove(struct net_device *dev,
>@@ -4675,12 +4744,14 @@ static int __netdev_upper_dev_link(struct net_device *dev,
> 		return ret;
> 
> 	/* Now that we linked these devs, make all the upper_dev's
>-	 * upper_dev_list visible to every dev's lower_dev_list and vice
>+	 * all_dev_list.upper visible to every dev's all_dev_list.lower an
> 	 * versa, and don't forget the devices itself. All of these
> 	 * links are non-neighbours.
> 	 */
>-	list_for_each_entry(i, &dev->lower_dev_list, list) {
>-		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list) {
>+		list_for_each_entry(j, &upper_dev->all_dev_list.upper, list) {
>+			pr_debug("Interlinking %s with %s, non-neighbour\n",
>+				 i->dev->name, j->dev->name);
> 			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
> 			if (ret)
> 				goto rollback_mesh;
>@@ -4688,14 +4759,18 @@ static int __netdev_upper_dev_link(struct net_device *dev,
> 	}
> 
> 	/* add dev to every upper_dev's upper device */
>-	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
>+	list_for_each_entry(i, &upper_dev->all_dev_list.upper, list) {
>+		pr_debug("linking %s's upper device %s with %s\n", upper_dev->name,
>+			 i->dev->name, dev->name);
> 		ret = __netdev_adjacent_dev_link(dev, i->dev);
> 		if (ret)
> 			goto rollback_upper_mesh;
> 	}
> 
> 	/* add upper_dev to every dev's lower device */
>-	list_for_each_entry(i, &dev->lower_dev_list, list) {
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list) {
>+		pr_debug("linking %s's lower device %s with %s\n", dev->name,
>+			 i->dev->name, upper_dev->name);
> 		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
> 		if (ret)
> 			goto rollback_lower_mesh;
>@@ -4706,7 +4781,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
> 
> rollback_lower_mesh:
> 	to_i = i;
>-	list_for_each_entry(i, &dev->lower_dev_list, list) {
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list) {
> 		if (i == to_i)
> 			break;
> 		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
>@@ -4716,7 +4791,7 @@ rollback_lower_mesh:
> 
> rollback_upper_mesh:
> 	to_i = i;
>-	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
>+	list_for_each_entry(i, &upper_dev->all_dev_list.upper, list) {
> 		if (i == to_i)
> 			break;
> 		__netdev_adjacent_dev_unlink(dev, i->dev);
>@@ -4727,8 +4802,8 @@ rollback_upper_mesh:
> rollback_mesh:
> 	to_i = i;
> 	to_j = j;
>-	list_for_each_entry(i, &dev->lower_dev_list, list) {
>-		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list) {
>+		list_for_each_entry(j, &upper_dev->all_dev_list.upper, list) {
> 			if (i == to_i && j == to_j)
> 				break;
> 			__netdev_adjacent_dev_unlink(i->dev, j->dev);
>@@ -4797,17 +4872,17 @@ void netdev_upper_dev_unlink(struct net_device *dev,
> 	 * devices from all upper_dev's upper devices and vice
> 	 * versa, to maintain the graph relationship.
> 	 */
>-	list_for_each_entry(i, &dev->lower_dev_list, list)
>-		list_for_each_entry(j, &upper_dev->upper_dev_list, list)
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list)
>+		list_for_each_entry(j, &upper_dev->all_dev_list.upper, list)
> 			__netdev_adjacent_dev_unlink(i->dev, j->dev);
> 
> 	/* remove also the devices itself from lower/upper device
> 	 * list
> 	 */
>-	list_for_each_entry(i, &dev->lower_dev_list, list)
>+	list_for_each_entry(i, &dev->all_dev_list.lower, list)
> 		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
> 
>-	list_for_each_entry(i, &upper_dev->upper_dev_list, list)
>+	list_for_each_entry(i, &upper_dev->all_dev_list.upper, list)
> 		__netdev_adjacent_dev_unlink(dev, i->dev);
> 
> 	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
>@@ -6069,8 +6144,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
> 	INIT_LIST_HEAD(&dev->napi_list);
> 	INIT_LIST_HEAD(&dev->unreg_list);
> 	INIT_LIST_HEAD(&dev->link_watch_list);
>-	INIT_LIST_HEAD(&dev->upper_dev_list);
>-	INIT_LIST_HEAD(&dev->lower_dev_list);
>+	INIT_LIST_HEAD(&dev->neighbour_dev_list.upper);
>+	INIT_LIST_HEAD(&dev->neighbour_dev_list.lower);
>+	INIT_LIST_HEAD(&dev->all_dev_list.upper);
>+	INIT_LIST_HEAD(&dev->all_dev_list.lower);
> 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
> 	setup(dev);
> 
>-- 
>1.8.4
>
