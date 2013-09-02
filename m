From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 12/21] net: add for_each iterators through neighbour lower link's private
Date: Mon,  2 Sep 2013 23:39:16 +0200
Message-ID: <1378157965-17537-13-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10558 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759065Ab3IBVj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:29 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can only iterate through the devices itself, however it'd be
really costy to first get the next device and then search for the link and
get its private - which is a common method to go through slaves of a
device.

Add both RCU and RTNL/other locking variants of iterators.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h | 17 ++++++++++++
 net/core/dev.c            | 66 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ef1ddee..1a149ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2788,6 +2788,23 @@ extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 	     updev; \
 	     updev = netdev_upper_get_next_dev_rcu(dev, &(iter)))
 
+extern void *netdev_lower_neigh_get_next_private(struct net_device *dev,
+						 struct list_head **iter);
+extern void *netdev_lower_neigh_get_next_private_rcu(struct net_device *dev,
+						     struct list_head **iter);
+
+#define netdev_for_each_lower_neigh_private(dev, priv, iter) \
+	for (iter = &(dev)->neighbour_dev_list.lower, \
+	     priv = netdev_lower_neigh_get_next_private(dev, &(iter)); \
+	     priv; \
+	     priv = netdev_lower_neigh_get_next_private(dev, &(iter)))
+
+#define netdev_for_each_lower_neigh_private_rcu(dev, priv, iter) \
+	for (iter = &(dev)->neighbour_dev_list.lower, \
+	     priv = netdev_lower_neigh_get_next_private_rcu(dev, &(iter)); \
+	     priv; \
+	     priv = netdev_lower_neigh_get_next_private_rcu(dev, &(iter)))
+
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1c3e98d..55f8ac4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4555,6 +4555,72 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_get_next_dev_rcu);
 
+/* netdev_lower_neigh_get_next_private - Get the next ->private from the
+ *					 lower neighbour list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold either hold the
+ * RTNL lock or its own locking that guarantees that the neighbour lower
+ * list will remain unchainged. If iter is NULL - return the first private.
+ */
+void *netdev_lower_neigh_get_next_private(struct net_device *dev,
+					  struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	if (iter)
+		lower = list_entry((*iter)->next, struct netdev_adjacent,
+				   list);
+	else
+		lower = list_entry(dev->neighbour_dev_list.lower.next,
+				   struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->neighbour_dev_list.lower)
+		return NULL;
+
+	if (iter)
+		*iter = &lower->list;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_neigh_get_next_private);
+
+/* netdev_lower_neigh_get_next_private_rcu - Get the next ->private from the
+ *					     lower neighbour list, RCU
+ *					     variant
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold RCU read lock.
+ * If iter is NULL - returns the first private.
+ */
+void *netdev_lower_neigh_get_next_private_rcu(struct net_device *dev,
+					      struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (iter)
+		lower = list_entry_rcu((*iter)->next, struct netdev_adjacent,
+				       list);
+	else
+		lower = list_entry_rcu(dev->neighbour_dev_list.lower.next,
+				       struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->neighbour_dev_list.lower)
+		return NULL;
+
+	if (iter)
+		*iter = &lower->list;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_neigh_get_next_private_rcu);
+
 /**
  * netdev_master_upper_dev_get_rcu - Get master upper device
  * @dev: device
-- 
1.8.4
