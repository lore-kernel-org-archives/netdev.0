From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 02/13] net: add lower_dev_list to net_device
 and make a full mesh
Date: Wed, 28 Aug 2013 15:59:26 +0200
Message-ID: <20130828135926.GA1403@minipsycho.brq.redhat.com>
References: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
 <1377691352-4146-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:58465 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab3H1N7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 09:59:30 -0400
Received: by mail-ea0-f180.google.com with SMTP id h10so3005753eaj.11
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 06:59:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377691352-4146-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 28, 2013 at 02:02:21PM CEST, vfalico@redhat.com wrote:
>This patch adds lower_dev_list list_head to net_device, which is the same
>as upper_dev_list, only for lower devices, and begins to use it in the same
>way as the upper list.
>
>It also changes the way the whole adjacent device lists work - now they
>contain *all* of upper/lower devices, not only the first level. The first
>level devices are distinguished by the bool neighbour field in
>netdev_adjacent, also added by this patch.
>
>There are cases when a device can be added several times to the adjacent
>list, the simplest would be:
>
>     /---- eth0.10 ---\
>eth0-		       --- bond0
>     \---- eth0.20 ---/
>
>where both bond0 and eth0 'see' each other in the adjacent lists two times.
>To avoid duplication of netdev_adjacent structures ref_nr is being kept as
>the number of times the device was added to the list.
>
>The 'full view' is achieved by adding, on link creation, all of the
>upper_dev's upper_dev_list devices as upper devices to all of the
>lower_dev's lower_dev_list devices (and to the lower_dev itself), and vice
>versa. On unlink they are removed using the same logic.
>
>I've tested it with thousands vlans/bonds/bridges, everything works ok and
>no observable lags even on a huge number of interfaces.
>
>Memory footprint for 128 devices interconnected with each other via both
>upper and lower (which is impossible, but for the comparison) lists would be:
>
>128*128*2*sizeof(netdev_adjacent) = 1.5MB
>
>but in the real world we usualy have at most several devices with slaves
>and a lot of vlans, so the footprint will be much lower.
>
>v2: new patch


Hmm. I'm not sure if recursive searches in read paths wouldn't be better
afterall. This looks a bit too complex

>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Cong Wang <amwang@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> include/linux/netdevice.h |    1 +
> net/core/dev.c            |  256 +++++++++++++++++++++++++++++++++++++++-----
> 2 files changed, 228 insertions(+), 29 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 077363d..5ccf5b7 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1125,6 +1125,7 @@ struct net_device {
> 	struct list_head	napi_list;
> 	struct list_head	unreg_list;
> 	struct list_head	upper_dev_list; /* List of upper devices */
>+	struct list_head	lower_dev_list;
> 
> 
> 	/* currently active device features */
>diff --git a/net/core/dev.c b/net/core/dev.c
>index c2ac3b8..5d73f9f 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4369,7 +4369,15 @@ softnet_break:
> 
> struct netdev_adjacent {
> 	struct net_device *dev;
>+	/* master device, we can only have one */
> 	bool master;
>+	/* is it first-level lower/upper or not */
>+	bool neighbour;
>+	/* how many times we've tried added this link. if it becomes 0 -
>+	 * we can remove the link and free the structure. For neighbour
>+	 * links it should always be 1.

	From this comment, I'm do not understand what is going on.
	Also for bool use "false" and "true" instead of "0" and "1".

>+	 */
>+	u16 ref_nr;
> 	struct list_head list;
> 	struct rcu_head rcu;
> 	struct list_head search_list;
>@@ -4408,18 +4416,25 @@ static bool __netdev_search_upper_dev(struct net_device *dev,
> 	return ret;
> }
> 
>-static struct netdev_adjacent *__netdev_find_upper(struct net_device *dev,
>-						struct net_device *upper_dev)
>+static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
>+						 struct net_device *adj_dev,
>+						 bool upper)
> {
>-	struct netdev_adjacent *upper;
>+	struct netdev_adjacent *adj;
>+	struct list_head *dev_list;
> 
>-	list_for_each_entry(upper, &dev->upper_dev_list, list) {
>-		if (upper->dev == upper_dev)
>-			return upper;
>+	dev_list = upper ? &dev->upper_dev_list : &dev->lower_dev_list;
>+
>+	list_for_each_entry(adj, dev_list, list) {
>+		if (adj->dev == adj_dev)
>+			return adj;
> 	}
> 	return NULL;
> }
> 
>+#define __netdev_find_upper(d, ud) __netdev_find_adj(d, ud, true)
>+#define __netdev_find_lower(d, ld) __netdev_find_adj(d, ld, false)

Please make these 2 simple functions.


>+
> /**
>  * netdev_has_upper_dev - Check if device is linked to an upper device
>  * @dev: device
>@@ -4470,7 +4485,7 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
> 		return NULL;
> 
> 	upper = list_first_entry(&dev->upper_dev_list,
>-				 struct netdev_upper, list);
>+				 struct netdev_adjacent, list);

I believe this should be part of previous patch. Just to be save, try to
compile in between the patch application in series.


> 	if (likely(upper->master))
> 		return upper->dev;
> 	return NULL;
>@@ -4489,17 +4504,133 @@ struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
> 	struct netdev_adjacent *upper;
> 
> 	upper = list_first_or_null_rcu(&dev->upper_dev_list,
>-				       struct netdev_upper, list);
>+				       struct netdev_adjacent, list);

Same as previous

> 	if (upper && likely(upper->master))
> 		return upper->dev;
> 	return NULL;
> }
> EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
> 
>+static int __netdev_adjacent_dev_insert(struct net_device *dev,
>+					struct net_device *adj_dev,
>+					bool neighbour, bool master,
>+					bool upper)
>+{
>+	struct netdev_adjacent *adj;
>+
>+	adj = __netdev_find_adj(dev, adj_dev, upper);
>+
>+	if (adj) {
>+		BUG_ON(neighbour);
>+		adj->ref_nr++;
>+		return 0;
>+	}
>+
>+	adj = kmalloc(sizeof(*adj), GFP_KERNEL);
>+	if (!adj)
>+		return -ENOMEM;
>+
>+	adj->dev = adj_dev;
>+	adj->master = master;
>+	adj->neighbour = neighbour;
>+	adj->ref_nr = 1;
>+	INIT_LIST_HEAD(&adj->search_list);
>+
>+	dev_hold(adj_dev);
>+	pr_debug("dev_hold for %s, because of %s link added from %s to %s\n",
>+		 adj_dev->name, upper ? "upper" : "lower", dev->name,
>+		 adj_dev->name);
>+
>+	if (!upper) {
>+		list_add_tail_rcu(&adj->list, &dev->lower_dev_list);
>+		return 0;
>+	}
>+
>+	/* Ensure that master upper link is always the first item in list. */
>+	if (master)
>+		list_add_rcu(&adj->list, &dev->upper_dev_list);
>+	else
>+		list_add_tail_rcu(&adj->list, &dev->upper_dev_list);
>+
>+	return 0;
>+}
>+
>+#define __netdev_upper_dev_insert(dev, adev, m, d) \
>+		__netdev_adjacent_dev_insert(dev, adev, d, m, true)
>+#define __netdev_lower_dev_insert(dev, adev, d) \
>+		__netdev_adjacent_dev_insert(dev, adev, d, false, false)

Also, make these functions.


>+
>+void __netdev_adjacent_dev_remove(struct net_device *dev,
>+				 struct net_device *adj_dev, bool upper)
>+{
>+	struct netdev_adjacent *adj;
>+
>+	if (upper)
>+		adj = __netdev_find_upper(dev, adj_dev);
>+	else
>+		adj = __netdev_find_lower(dev, adj_dev);
>+
>+	/* try to maintain the mesh, sorry people, if you've paniced here -
>+	 * you've tried to remove an unexisting link, and that is bad.
>+	 */

Unnecessary comment


>+	if (!adj)
>+		BUG();
>+
>+	if (adj->ref_nr > 1) {
>+		adj->ref_nr--;
>+		return;
>+	}
>+
>+	list_del_rcu(&adj->list);
>+	pr_debug("dev_put for %s, because of %s link removed from %s to %s\n",
>+		 adj_dev->name, upper ? "upper" : "lower", dev->name,
>+		 adj_dev->name);
>+	dev_put(adj_dev);
>+	kfree_rcu(adj, rcu);
>+}
>+
>+#define __netdev_upper_dev_remove(d, ud) \
>+		__netdev_adjacent_dev_remove(d, ud, true)
>+#define __netdev_lower_dev_remove(d, ld) \
>+		__netdev_adjacent_dev_remove(d, ld, false)

Also, make these functions.


>+
>+int __netdev_adjacent_dev_insert_link(struct net_device *dev,
>+				      struct net_device *upper_dev,
>+				      bool master, bool neighbour)
>+{
>+	int ret;
>+
>+	ret = __netdev_upper_dev_insert(dev, upper_dev, master, neighbour);
>+	if (ret)
>+		return ret;
>+
>+	ret = __netdev_lower_dev_insert(upper_dev, dev, neighbour);
>+	if (ret) {
>+		__netdev_upper_dev_remove(dev, upper_dev);
>+		return ret;
>+	}
>+
>+	return 0;
>+}
>+
>+#define __netdev_adjacent_dev_link(d, ud) \
>+		__netdev_adjacent_dev_insert_link(d, ud, false, false)
>+#define __netdev_adjacent_dev_link_neighbour(d, ud, m) \
>+		__netdev_adjacent_dev_insert_link(d, ud, m, true)

Also, make these functions.

>+
>+void __netdev_adjacent_dev_unlink(struct net_device *dev,
>+				 struct net_device *upper_dev)
>+{
>+	__netdev_upper_dev_remove(dev, upper_dev);
>+	__netdev_lower_dev_remove(upper_dev, dev);
>+}
>+
>+
> static int __netdev_upper_dev_link(struct net_device *dev,
> 				   struct net_device *upper_dev, bool master)
> {
>-	struct netdev_adjacent *upper;
>+	struct netdev_adjacent *i, *j, *to_i, *to_j;
>+	int ret = 0;
> 
> 	ASSERT_RTNL();
> 
>@@ -4516,22 +4647,76 @@ static int __netdev_upper_dev_link(struct net_device *dev,
> 	if (master && netdev_master_upper_dev_get(dev))
> 		return -EBUSY;
> 
>-	upper = kmalloc(sizeof(*upper), GFP_KERNEL);
>-	if (!upper)
>-		return -ENOMEM;
>+	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, master);
>+	if (ret)
>+		return ret;
> 
>-	upper->dev = upper_dev;
>-	upper->master = master;
>-	INIT_LIST_HEAD(&upper->search_list);
>+	/* Now that we interconnected these devs, make all the upper_dev's
>+	 * upper_dev_list visible to every dev's lower_dev_list and vice
>+	 * versa, and don't forget the devices itself. All of these
>+	 * connections are non-neighbours.

	Please use same terms. ConnectionsXlinks


>+	 */
>+	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
>+		list_for_each_entry(j, &dev->lower_dev_list, list) {
>+			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
>+			if (ret)
>+				goto rollback_mesh;
>+		}
>+	}
>+
>+	/* add dev to every upper_dev's upper device */
>+	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
>+		ret = __netdev_adjacent_dev_link(dev, i->dev);
>+		if (ret)
>+			goto rollback_upper_mesh;
>+	}
>+
>+	/* add upper_dev to every dev's lower device */
>+	list_for_each_entry(i, &dev->lower_dev_list, list) {
>+		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
>+		if (ret)
>+			goto rollback_lower_mesh;
>+	}
> 
>-	/* Ensure that master upper link is always the first item in list. */
>-	if (master)
>-		list_add_rcu(&upper->list, &dev->upper_dev_list);
>-	else
>-		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
>-	dev_hold(upper_dev);
> 	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
> 	return 0;
>+
>+rollback_lower_mesh:
>+	to_i = i;
>+	list_for_each_entry(i, &dev->lower_dev_list, list) {
>+		if (i == to_i)
>+			break;
>+		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
>+	}
>+
>+	i = NULL;
>+
>+rollback_upper_mesh:
>+	to_i = i;
>+	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
>+		if (i == to_i)
>+			break;
>+		__netdev_adjacent_dev_unlink(dev, i->dev);
>+	}
>+
>+	i = j = NULL;
>+
>+rollback_mesh:
>+	to_i = i;
>+	to_j = j;
>+	list_for_each_entry(i, &dev->lower_dev_list, list) {
>+		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
>+			if (i == to_i && j == to_j)
>+				break;
>+			__netdev_adjacent_dev_unlink(i->dev, j->dev);
>+		}
>+		if (i == to_i)
>+			break;
>+	}
>+
>+	__netdev_adjacent_dev_unlink(dev, upper_dev);
>+
>+	return ret;
> }
> 
> /**
>@@ -4580,16 +4765,28 @@ EXPORT_SYMBOL(netdev_master_upper_dev_link);
> void netdev_upper_dev_unlink(struct net_device *dev,
> 			     struct net_device *upper_dev)
> {
>-	struct netdev_adjacent *upper;
>-
>+	struct netdev_adjacent *i, *j;
> 	ASSERT_RTNL();
> 
>-	upper = __netdev_find_upper(dev, upper_dev);
>-	if (!upper)
>-		return;
>-	list_del_rcu(&upper->list);
>-	dev_put(upper_dev);
>-	kfree_rcu(upper, rcu);
>+	__netdev_adjacent_dev_unlink(dev, upper_dev);
>+
>+	/* Here is the tricky part. We must remove all dev's lower
>+	 * devices from all upper_dev's upper devices and vice
>+	 * versa, to maintain the graph relationship.
>+	 */
>+	list_for_each_entry(i, &dev->lower_dev_list, list)
>+		list_for_each_entry(j, &upper_dev->upper_dev_list, list)
>+			__netdev_adjacent_dev_unlink(i->dev, j->dev);
>+
>+	/* remove also the devices itself from lower/upper device
>+	 * list
>+	 */
>+	list_for_each_entry(i, &dev->lower_dev_list, list)
>+		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
>+
>+	list_for_each_entry(i, &upper_dev->upper_dev_list, list)
>+		__netdev_adjacent_dev_unlink(dev, i->dev);
>+
> 	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
> }
> EXPORT_SYMBOL(netdev_upper_dev_unlink);
>@@ -5850,6 +6047,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
> 	INIT_LIST_HEAD(&dev->unreg_list);
> 	INIT_LIST_HEAD(&dev->link_watch_list);
> 	INIT_LIST_HEAD(&dev->upper_dev_list);
>+	INIT_LIST_HEAD(&dev->lower_dev_list);
> 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
> 	setup(dev);
> 
>-- 
>1.7.1
>
