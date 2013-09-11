From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 2/4] net: Add lower dev list helpers
Date: Wed, 11 Sep 2013 11:46:49 -0700
Message-ID: <20130911184647.26914.40440.stgit@nitbit.x32>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:49408 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311Ab3IKSrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:47:12 -0400
Received: by mail-oa0-f45.google.com with SMTP id m6so9713931oag.32
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:47:11 -0700 (PDT)
In-Reply-To: <20130911184441.26914.10336.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds helpers to traverse the lower dev lists, these
helpers match the upper dev list implementation.

VSI implementers may use these to track a list of connected netdevs.
This is easier then having drivers do their own accounting.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h |    8 ++++++++
 net/core/dev.c            |   25 +++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 041b42a..4d24b38 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2813,6 +2813,8 @@ extern int		bpf_jit_enable;
 extern bool netdev_has_upper_dev(struct net_device *dev,
 				 struct net_device *upper_dev);
 extern bool netdev_has_any_upper_dev(struct net_device *dev);
+extern struct net_device *netdev_lower_get_next_dev_rcu(struct net_device *dev,
+							struct list_head **iter);
 extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 							struct list_head **iter);
 
@@ -2823,6 +2825,12 @@ extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 	     upper; \
 	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)))
 
+#define netdev_for_each_lower_dev_rcu(dev, lower, iter) \
+	for (iter = &(dev)->lower_dev_list, \
+	     lower = netdev_lower_get_next_dev_rcu(dev, &(iter)); \
+	     lower; \
+	     lower = netdev_lower_get_next_dev_rcu(dev, &(iter)))
+
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..65ed610 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4468,6 +4468,31 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get);
 
+/* netdev_lower_get_next_dev_rcu - Get the next dev from lower list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next device from the dev's lower list, starting from iter
+ * position. The caller must hold RTNL/RCU read lock.
+ */
+struct net_device *netdev_lower_get_next_dev_rcu(struct net_device *dev,
+						 struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->lower_dev_list)
+		return NULL;
+
+	*iter = &lower->list;
+
+	return lower->dev;
+}
+EXPORT_SYMBOL(netdev_lower_get_next_dev_rcu);
+
 /* netdev_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
  * @iter: list_head ** of the current position
