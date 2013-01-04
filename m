From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V6 01/15] net: introduce upper device lists
Date: Fri,  4 Jan 2013 09:48:49 +0100
Message-ID: <1357289343-817-2-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:36540 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3ADItQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 03:49:16 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so8060326eek.37
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 00:49:14 -0800 (PST)
In-Reply-To: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This lists are supposed to serve for storing pointers to all upper devices.
Eventually it will replace dev->master pointer which is used for
bonding, bridge, team but it cannot be used for vlan, macvlan where
there might be multiple upper present. In case the upper link is
replacement for dev->master, it is marked with "master" flag.

New upper device list resolves this limitation. Also, the information
stored in lists is used for preventing looping setups like
"bond->somethingelse->samebond"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  14 +++
 net/core/dev.c            | 239 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 249 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6835b58..52d1146 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1172,6 +1172,8 @@ struct net_device {
 					  * which this device is member of.
 					  */
 
+	struct list_head	upper_dev_list; /* List of upper devices */
+
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
 						   because most packets are
@@ -2634,6 +2636,18 @@ extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
+
+extern bool netdev_has_upper_dev(struct net_device *dev,
+				 struct net_device *upper_dev);
+extern bool netdev_has_any_upper_dev(struct net_device *dev);
+extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
+extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
+extern int netdev_upper_dev_link(struct net_device *dev,
+				 struct net_device *upper_dev);
+extern int netdev_master_upper_dev_link(struct net_device *dev,
+					struct net_device *upper_dev);
+extern void netdev_upper_dev_unlink(struct net_device *dev,
+				    struct net_device *upper_dev);
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
diff --git a/net/core/dev.c b/net/core/dev.c
index 21c5b97..3cd8424 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4600,6 +4600,232 @@ static int __init dev_proc_init(void)
 #endif	/* CONFIG_PROC_FS */
 
 
+struct netdev_upper {
+	struct net_device *dev;
+	bool master;
+	struct list_head list;
+	struct rcu_head rcu;
+	struct list_head search_list;
+};
+
+static void __append_search_uppers(struct list_head *search_list,
+				   struct net_device *dev)
+{
+	struct netdev_upper *upper;
+
+	list_for_each_entry(upper, &dev->upper_dev_list, list) {
+		/* check if this upper is not already in search list */
+		if (list_empty(&upper->search_list))
+			list_add_tail(&upper->search_list, search_list);
+	}
+}
+
+static bool __netdev_search_upper_dev(struct net_device *dev,
+				      struct net_device *upper_dev)
+{
+	LIST_HEAD(search_list);
+	struct netdev_upper *upper;
+	struct netdev_upper *tmp;
+	bool ret = false;
+
+	__append_search_uppers(&search_list, dev);
+	list_for_each_entry(upper, &search_list, search_list) {
+		if (upper->dev == upper_dev) {
+			ret = true;
+			break;
+		}
+		__append_search_uppers(&search_list, upper->dev);
+	}
+	list_for_each_entry_safe(upper, tmp, &search_list, search_list)
+		INIT_LIST_HEAD(&upper->search_list);
+	return ret;
+}
+
+static struct netdev_upper *__netdev_find_upper(struct net_device *dev,
+						struct net_device *upper_dev)
+{
+	struct netdev_upper *upper;
+
+	list_for_each_entry(upper, &dev->upper_dev_list, list) {
+		if (upper->dev == upper_dev)
+			return upper;
+	}
+	return NULL;
+}
+
+/**
+ * netdev_has_upper_dev - Check if device is linked to an upper device
+ * @dev: device
+ * @upper_dev: upper device to check
+ *
+ * Find out if a device is linked to specified upper device and return true
+ * in case it is. Note that this checks only immediate upper device,
+ * not through a complete stack of devices. The caller must hold the RTNL lock.
+ */
+bool netdev_has_upper_dev(struct net_device *dev,
+			  struct net_device *upper_dev)
+{
+	ASSERT_RTNL();
+
+	return __netdev_find_upper(dev, upper_dev);
+}
+EXPORT_SYMBOL(netdev_has_upper_dev);
+
+/**
+ * netdev_has_any_upper_dev - Check if device is linked to some device
+ * @dev: device
+ *
+ * Find out if a device is linked to an upper device and return true in case
+ * it is. The caller must hold the RTNL lock.
+ */
+bool netdev_has_any_upper_dev(struct net_device *dev)
+{
+	ASSERT_RTNL();
+
+	return !list_empty(&dev->upper_dev_list);
+}
+EXPORT_SYMBOL(netdev_has_any_upper_dev);
+
+/**
+ * netdev_master_upper_dev_get - Get master upper device
+ * @dev: device
+ *
+ * Find a master upper device and return pointer to it or NULL in case
+ * it's not there. The caller must hold the RTNL lock.
+ */
+struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
+{
+	struct netdev_upper *upper;
+
+	ASSERT_RTNL();
+
+	if (list_empty(&dev->upper_dev_list))
+		return NULL;
+
+	upper = list_first_entry(&dev->upper_dev_list,
+				 struct netdev_upper, list);
+	if (likely(upper->master))
+		return upper->dev;
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_master_upper_dev_get);
+
+/**
+ * netdev_master_upper_dev_get_rcu - Get master upper device
+ * @dev: device
+ *
+ * Find a master upper device and return pointer to it or NULL in case
+ * it's not there. The caller must hold the RCU read lock.
+ */
+struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
+{
+	struct netdev_upper *upper;
+
+	upper = list_first_or_null_rcu(&dev->upper_dev_list,
+				       struct netdev_upper, list);
+	if (upper && likely(upper->master))
+		return upper->dev;
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
+
+static int __netdev_upper_dev_link(struct net_device *dev,
+				   struct net_device *upper_dev, bool master)
+{
+	struct netdev_upper *upper;
+
+	ASSERT_RTNL();
+
+	if (dev == upper_dev)
+		return -EBUSY;
+
+	/* To prevent loops, check if dev is not upper device to upper_dev. */
+	if (__netdev_search_upper_dev(upper_dev, dev))
+		return -EBUSY;
+
+	if (__netdev_find_upper(dev, upper_dev))
+		return -EEXIST;
+
+	if (master && netdev_master_upper_dev_get(dev))
+		return -EBUSY;
+
+	upper = kmalloc(sizeof(*upper), GFP_KERNEL);
+	if (!upper)
+		return -ENOMEM;
+
+	upper->dev = upper_dev;
+	upper->master = master;
+	INIT_LIST_HEAD(&upper->search_list);
+
+	/* Ensure that master upper link is always the first item in list. */
+	if (master)
+		list_add_rcu(&upper->list, &dev->upper_dev_list);
+	else
+		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
+	dev_hold(upper_dev);
+
+	return 0;
+}
+
+/**
+ * netdev_upper_dev_link - Add a link to the upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Adds a link to device which is upper to this one. The caller must hold
+ * the RTNL lock. On a failure a negative errno code is returned.
+ * On success the reference counts are adjusted and the function
+ * returns zero.
+ */
+int netdev_upper_dev_link(struct net_device *dev,
+			  struct net_device *upper_dev)
+{
+	return __netdev_upper_dev_link(dev, upper_dev, false);
+}
+EXPORT_SYMBOL(netdev_upper_dev_link);
+
+/**
+ * netdev_master_upper_dev_link - Add a master link to the upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Adds a link to device which is upper to this one. In this case, only
+ * one master upper device can be linked, although other non-master devices
+ * might be linked as well. The caller must hold the RTNL lock.
+ * On a failure a negative errno code is returned. On success the reference
+ * counts are adjusted and the function returns zero.
+ */
+int netdev_master_upper_dev_link(struct net_device *dev,
+				 struct net_device *upper_dev)
+{
+	return __netdev_upper_dev_link(dev, upper_dev, true);
+}
+EXPORT_SYMBOL(netdev_master_upper_dev_link);
+
+/**
+ * netdev_upper_dev_unlink - Removes a link to upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Removes a link to device which is upper to this one. The caller must hold
+ * the RTNL lock.
+ */
+void netdev_upper_dev_unlink(struct net_device *dev,
+			     struct net_device *upper_dev)
+{
+	struct netdev_upper *upper;
+
+	ASSERT_RTNL();
+
+	upper = __netdev_find_upper(dev, upper_dev);
+	if (!upper)
+		return;
+	list_del_rcu(&upper->list);
+	dev_put(upper_dev);
+	kfree_rcu(upper, rcu);
+}
+EXPORT_SYMBOL(netdev_upper_dev_unlink);
+
 /**
  *	netdev_set_master	-	set up master pointer
  *	@slave: slave device
@@ -4613,19 +4839,23 @@ static int __init dev_proc_init(void)
 int netdev_set_master(struct net_device *slave, struct net_device *master)
 {
 	struct net_device *old = slave->master;
+	int err;
 
 	ASSERT_RTNL();
 
 	if (master) {
 		if (old)
 			return -EBUSY;
-		dev_hold(master);
+		err = netdev_master_upper_dev_link(slave, master);
+		if (err)
+			return err;
 	}
 
 	slave->master = master;
 
 	if (old)
-		dev_put(old);
+		netdev_upper_dev_unlink(slave, master);
+
 	return 0;
 }
 EXPORT_SYMBOL(netdev_set_master);
@@ -5501,8 +5731,8 @@ static void rollback_registered_many(struct list_head *head)
 		if (dev->netdev_ops->ndo_uninit)
 			dev->netdev_ops->ndo_uninit(dev);
 
-		/* Notifier chain MUST detach us from master device. */
-		WARN_ON(dev->master);
+		/* Notifier chain MUST detach us all upper devices. */
+		WARN_ON(netdev_has_any_upper_dev(dev));
 
 		/* Remove entries from kobject tree */
 		netdev_unregister_kobject(dev);
@@ -6210,6 +6440,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
+	INIT_LIST_HEAD(&dev->upper_dev_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 
-- 
1.8.0
