From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 02/11] net: Introduce new api for walking upper and lower devices
Date: Fri, 14 Oct 2016 18:28:42 -0700
Message-ID: <1476494931-31813-3-git-send-email-dsa@cumulusnetworks.com>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476494931-31813-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch introduces netdev_walk_all_upper_dev_rcu,
netdev_walk_all_lower_dev and netdev_walk_all_lower_dev_rcu. These
functions recursively walk the adj_list of devices to determine all upper
and lower devices.

The functions take a callback function that is invoked for each device
in the list. If the callback returns non-0, the walk is terminated and
the functions return that code back to callers.

v2
- fixed definition of netdev_next_lower_dev_rcu to mirror the upper_dev
  version.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 include/linux/netdevice.h |  17 +++++
 net/core/dev.c            | 161 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 178 insertions(+)

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
index 5399af8fdac0..1780f94ed25f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5156,6 +5156,37 @@ bool netdev_has_upper_dev(struct net_device *dev,
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
+	struct net_device *dev = (struct net_device *)data;
+
+	if (upper_dev == dev)
+		return 1;
+
+	return 0;
+}
+
+bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
+				  struct net_device *upper_dev)
+{
+	if (netdev_walk_all_upper_dev_rcu(dev, __netdev_has_upper_dev,
+					  upper_dev))
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(netdev_has_upper_dev_all_rcu);
+
+/**
  * netdev_has_any_upper_dev - Check if device is linked to some device
  * @dev: device
  *
@@ -5255,6 +5286,51 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
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
@@ -5361,6 +5437,49 @@ struct net_device *netdev_all_lower_get_next(struct net_device *dev, struct list
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
@@ -5382,6 +5501,48 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
