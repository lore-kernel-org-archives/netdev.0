From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next 01/16] net: introduce upper device lists
Date: Mon, 13 Aug 2012 17:27:00 +0200
Message-ID: <1344871635-1052-2-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344871635-1052-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This lists are supposed to serve for storing pointers to all upper devices.
Eventually it will replace dev->master pointer which is used for
bonding, bridge, team but it cannot be used for vlan, macvlan where
there might be multiple "masters" present.

New upper device list resolves this limitation. Also, the information
stored in lists is used for preventing looping setups like
"bond->somethingelse->samebond"

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/netdevice.h |   14 +++
 net/core/dev.c            |  232 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 244 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9db4f3..e7a07f8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1173,6 +1173,8 @@ struct net_device {
 					  * which this device is member of.
 					  */
 
+	struct list_head	upper_dev_list; /* List of upper devices */
+
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
 						   because most packets are
@@ -2611,6 +2613,18 @@ extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
+
+extern bool netdev_has_upper_dev(struct net_device *dev,
+				 struct net_device *upper_dev);
+extern bool netdev_has_any_upper_dev(struct net_device *dev);
+extern struct net_device *netdev_unique_upper_dev_get(struct net_device *dev);
+extern struct net_device *netdev_unique_upper_dev_get_rcu(struct net_device *dev);
+extern int netdev_upper_dev_link(struct net_device *dev,
+				 struct net_device *upper_dev);
+extern int netdev_unique_upper_dev_link(struct net_device *dev,
+					struct net_device *upper_dev);
+extern void netdev_upper_dev_unlink(struct net_device *dev,
+				    struct net_device *upper_dev);
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1f06df8..68db1ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4425,6 +4425,229 @@ static int __init dev_proc_init(void)
 #endif	/* CONFIG_PROC_FS */
 
 
+struct netdev_upper {
+	struct net_device *dev;
+	bool unique;
+	struct list_head list;
+	struct rcu_head rcu;
+};
+
+static bool __netdev_has_upper_dev(struct net_device *dev,
+				   struct net_device *upper_dev,
+				   bool deep)
+{
+	struct netdev_upper *upper;
+
+	list_for_each_entry(upper, &dev->upper_dev_list, list) {
+		if (upper->dev == upper_dev)
+			return true;
+		if (deep && __netdev_has_upper_dev(upper->dev, upper_dev, deep))
+			return true;
+	}
+	return false;
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
+ * in case it is. The caller must hold the RTNL semaphore.
+ */
+bool netdev_has_upper_dev(struct net_device *dev,
+			  struct net_device *upper_dev)
+{
+	ASSERT_RTNL();
+
+	return __netdev_has_upper_dev(dev, upper_dev, false);
+}
+EXPORT_SYMBOL(netdev_has_upper_dev);
+
+/**
+ * netdev_has_any_upper_dev - Check if device is linked to some device
+ * @dev: device
+ *
+ * Find out if a device is linked to an upper device and return true in case
+ * it is. The caller must hold the RTNL semaphore.
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
+ * netdev_unique_upper_dev_get - Get unique upper device
+ * @dev: device
+ *
+ * Find a unique upper device and return pointer to it or NULL in case
+ * it's not there. The caller must hold the RTNL semaphore.
+ */
+struct net_device *netdev_unique_upper_dev_get(struct net_device *dev)
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
+	if (likely(upper->unique))
+		return upper->dev;
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_unique_upper_dev_get);
+
+/**
+ * netdev_unique_upper_dev_get_rcu - Get unique upper device
+ * @dev: device
+ *
+ * Find a unique upper device and return pointer to it or NULL in case
+ * it's not there. The caller must hold the RCU read lock.
+ */
+struct net_device *netdev_unique_upper_dev_get_rcu(struct net_device *dev)
+{
+	struct netdev_upper *upper;
+
+	upper = list_first_or_null_rcu(&dev->upper_dev_list,
+				       struct netdev_upper, list);
+	if (likely(upper->unique))
+		return upper->dev;
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_unique_upper_dev_get_rcu);
+
+static int __netdev_upper_dev_link(struct net_device *dev,
+				   struct net_device *upper_dev, bool unique)
+{
+	struct netdev_upper *upper;
+
+	ASSERT_RTNL();
+
+	if (dev == upper_dev)
+		return -EBUSY;
+	/*
+	 * To prevent loops, check if dev is not upper device to upper_dev.
+	 */
+	if (__netdev_has_upper_dev(upper_dev, dev, true))
+		return -EBUSY;
+
+	if (__netdev_find_upper(dev, upper_dev))
+		return -EEXIST;
+
+	if (unique && netdev_unique_upper_dev_get(dev))
+		return -EBUSY;
+
+	upper = kmalloc(sizeof(*upper), GFP_KERNEL);
+	if (!upper)
+		return -ENOMEM;
+
+	upper->dev = upper_dev;
+	upper->unique = unique;
+
+	/*
+	 * Ensure that unique upper link is always the first item in the list.
+	 */
+	if (unique)
+		list_add_rcu(&upper->list, &dev->upper_dev_list);
+	else
+		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
+	dev_hold(upper_dev);
+
+	return 0;
+}
+/**
+ * netdev_upper_dev_link - Add a link to the upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Adds a link to device which is upper to this one. The caller must hold
+ * the RTNL semaphore. On a failure a negative errno code is returned.
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
+ * netdev_unique_upper_dev_link - Add a unique link to the upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Adds a link to device which is upper to this one. In this case, only
+ * one unique upper device can be linked, although other non-unique devices
+ * might be linked as well. The caller must hold the RTNL semaphore.
+ * On a failure a negative errno code is returned. On success the reference
+ * counts are adjusted and the function returns zero.
+ */
+int netdev_unique_upper_dev_link(struct net_device *dev,
+				 struct net_device *upper_dev)
+{
+	return __netdev_upper_dev_link(dev, upper_dev, true);
+}
+EXPORT_SYMBOL(netdev_unique_upper_dev_link);
+
+/**
+ * netdev_upper_free_rcu - Frees a upper device list item via the RCU pointer
+ * @entry: the entry's RCU field
+ *
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to the netdev upper device list item
+ * can be released safely.
+ */
+static void netdev_upper_free_rcu(struct rcu_head *entry)
+{
+	struct netdev_upper *upper;
+
+	upper = container_of(entry, struct netdev_upper, rcu);
+	kfree(upper);
+}
+
+/**
+ * netdev_upper_dev_unlink - Removes a link to upper device
+ * @dev: device
+ * @upper_dev: new upper device
+ *
+ * Removes a link to device which is upper to this one. The caller must hold
+ * the RTNL semaphore.
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
+	call_rcu(&upper->rcu, netdev_upper_free_rcu);
+}
+EXPORT_SYMBOL(netdev_upper_dev_unlink);
+
 /**
  *	netdev_set_master	-	set up master pointer
  *	@slave: slave device
@@ -4438,19 +4661,23 @@ static int __init dev_proc_init(void)
 int netdev_set_master(struct net_device *slave, struct net_device *master)
 {
 	struct net_device *old = slave->master;
+	int err;
 
 	ASSERT_RTNL();
 
 	if (master) {
 		if (old)
 			return -EBUSY;
-		dev_hold(master);
+		err = netdev_unique_upper_dev_link(slave, master);
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
@@ -5999,6 +6226,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
+	INIT_LIST_HEAD(&dev->upper_dev_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
