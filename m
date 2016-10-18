From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 02/11] net: Introduce new api for walking upper and lower devices
Date: Mon, 17 Oct 2016 19:15:44 -0700
Message-ID: <1476756953-30923-3-git-send-email-dsa@cumulusnetworks.com>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35669 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755343AbcJRCQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 22:16:58 -0400
Received: by mail-pf0-f169.google.com with SMTP id s8so86149980pfj.2
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 19:16:57 -0700 (PDT)
In-Reply-To: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces netdev_walk_all_upper_dev_rcu,
netdev_walk_all_lower_dev and netdev_walk_all_lower_dev_rcu. These
functions recursively walk the adj_list of devices to determine all upper
and lower devices.

The functions take a callback function that is invoked for each device
in the list. If the callback returns non-0, the walk is terminated and
the functions return that code back to callers.

v3
- simplified netdev_has_upper_dev_all_rcu and __netdev_has_upper_dev and
  removed typecast as suggested by Stephen

v2
- fixed definition of netdev_next_lower_dev_rcu to mirror the upper_dev
  version.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h |  17 +++++
 net/core/dev.c            | 155 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 172 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bf341b65ca5e..a5902d995907 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3778,6 +3778,14 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 	     updev; \
 	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
 
+int netdev_walk_all_upper_dev_rcu(struct net_device *dev,
+				  int (*fn)(struct net_device *upper_dev,
+					    void *data),
+				  void *data);
+
+bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
+				  struct net_device *upper_dev);
+
 void *netdev_lower_get_next_private(struct net_device *dev,
 				    struct list_head **iter);
 void *netdev_lower_get_next_private_rcu(struct net_device *dev,
@@ -3821,6 +3829,15 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
 	     ldev; \
 	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)))
 
+int netdev_walk_all_lower_dev(struct net_device *dev,
+			      int (*fn)(struct net_device *lower_dev,
+					void *data),
+			      void *data);
+int netdev_walk_all_lower_dev_rcu(struct net_device *dev,
+				  int (*fn)(struct net_device *lower_dev,
+					    void *data),
+				  void *data);
+
 void *netdev_adjacent_get_private(struct list_head *adj_list);
 void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index f67fd16615bb..fc48337cfab8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5156,6 +5156,31 @@ bool netdev_has_upper_dev(struct net_device *dev,
 EXPORT_SYMBOL(netdev_has_upper_dev);
 
 /**
+ * netdev_has_upper_dev_all - Check if device is linked to an upper device
+ * @dev: device
+ * @upper_dev: upper device to check
+ *
+ * Find out if a device is linked to specified upper device and return true
+ * in case it is. Note that this checks the entire upper device chain.
+ * The caller must hold rcu lock.
+ */
+
+static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
+{
+	struct net_device *dev = data;
+
+	return upper_dev == dev;
+}
+
+bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
+				  struct net_device *upper_dev)
+{
+	return !!netdev_walk_all_upper_dev_rcu(dev, __netdev_has_upper_dev,
+					       upper_dev);
+}
+EXPORT_SYMBOL(netdev_has_upper_dev_all_rcu);
+
+/**
  * netdev_has_any_upper_dev - Check if device is linked to some device
  * @dev: device
  *
@@ -5255,6 +5280,51 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
 
+static struct net_device *netdev_next_upper_dev_rcu(struct net_device *dev,
+						    struct list_head **iter)
+{
+	struct netdev_adjacent *upper;
+
+	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
+
+	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+
+	if (&upper->list == &dev->adj_list.upper)
+		return NULL;
+
+	*iter = &upper->list;
+
+	return upper->dev;
+}
+
+int netdev_walk_all_upper_dev_rcu(struct net_device *dev,
+				  int (*fn)(struct net_device *dev,
+					    void *data),
+				  void *data)
+{
+	struct net_device *udev;
+	struct list_head *iter;
+	int ret;
+
+	for (iter = &dev->adj_list.upper,
+	     udev = netdev_next_upper_dev_rcu(dev, &iter);
+	     udev;
+	     udev = netdev_next_upper_dev_rcu(dev, &iter)) {
+		/* first is the upper device itself */
+		ret = fn(udev, data);
+		if (ret)
+			return ret;
+
+		/* then look at all of its upper devices */
+		ret = netdev_walk_all_upper_dev_rcu(udev, fn, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netdev_walk_all_upper_dev_rcu);
+
 /**
  * netdev_lower_get_next_private - Get the next ->private from the
  *				   lower neighbour list
@@ -5361,6 +5431,49 @@ struct net_device *netdev_all_lower_get_next(struct net_device *dev, struct list
 }
 EXPORT_SYMBOL(netdev_all_lower_get_next);
 
+static struct net_device *netdev_next_lower_dev(struct net_device *dev,
+						struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry(*iter, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	*iter = lower->list.next;
+
+	return lower->dev;
+}
+
+int netdev_walk_all_lower_dev(struct net_device *dev,
+			      int (*fn)(struct net_device *dev,
+					void *data),
+			      void *data)
+{
+	struct net_device *ldev;
+	struct list_head *iter;
+	int ret;
+
+	for (iter = &dev->adj_list.lower,
+	     ldev = netdev_next_lower_dev(dev, &iter);
+	     ldev;
+	     ldev = netdev_next_lower_dev(dev, &iter)) {
+		/* first is the lower device itself */
+		ret = fn(ldev, data);
+		if (ret)
+			return ret;
+
+		/* then look at all of its lower devices */
+		ret = netdev_walk_all_lower_dev(ldev, fn, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netdev_walk_all_lower_dev);
+
 /**
  * netdev_all_lower_get_next_rcu - Get the next device from all
  *				   lower neighbour list, RCU variant
@@ -5382,6 +5495,48 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_all_lower_get_next_rcu);
 
+static struct net_device *netdev_next_lower_dev_rcu(struct net_device *dev,
+						    struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	*iter = &lower->list;
+
+	return lower->dev;
+}
+
+int netdev_walk_all_lower_dev_rcu(struct net_device *dev,
+				  int (*fn)(struct net_device *dev,
+					    void *data),
+				  void *data)
+{
+	struct net_device *ldev;
+	struct list_head *iter;
+	int ret;
+
+	for (iter = &dev->adj_list.lower,
+	     ldev = netdev_next_lower_dev_rcu(dev, &iter);
+	     ldev;
+	     ldev = netdev_next_lower_dev_rcu(dev, &iter)) {
+		/* first is the lower device itself */
+		ret = fn(ldev, data);
+		if (ret)
+			return ret;
+
+		/* then look at all of its lower devices */
+		ret = netdev_walk_all_lower_dev_rcu(ldev, fn, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netdev_walk_all_lower_dev_rcu);
+
 /**
  * netdev_lower_get_first_private_rcu - Get the first ->private from the
  *				       lower neighbour list, RCU
-- 
2.1.4
