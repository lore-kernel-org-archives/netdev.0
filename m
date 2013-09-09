From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 07/26] net: add for_each iterators through neighbour lower link's private
Date: Mon,  9 Sep 2013 22:16:25 +0200
Message-ID: <1378757804-3159-8-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968Ab3IIUQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:16:43 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a possibility to iterate through netdev_adjacent's private, currently
only for lower neighbours.

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
index eab8e36..48431f0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2833,6 +2833,23 @@ extern struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *d
 	     updev; \
 	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
 
+extern void *netdev_lower_get_next_private(struct net_device *dev,
+					   struct list_head **iter);
+extern void *netdev_lower_get_next_private_rcu(struct net_device *dev,
+					       struct list_head **iter);
+
+#define netdev_for_each_lower_private(dev, priv, iter) \
+	for (iter = &(dev)->adj_list.lower, \
+	     priv = netdev_lower_get_next_private(dev, &(iter)); \
+	     priv; \
+	     priv = netdev_lower_get_next_private(dev, &(iter)))
+
+#define netdev_for_each_lower_private_rcu(dev, priv, iter) \
+	for (iter = &(dev)->adj_list.lower, \
+	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)); \
+	     priv; \
+	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
+
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 9528e8f..ebf8182 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4537,6 +4537,72 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
 
+/* netdev_lower_get_next_private - Get the next ->private from the
+ *				   lower neighbour list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold either hold the
+ * RTNL lock or its own locking that guarantees that the neighbour lower
+ * list will remain unchainged. If iter is NULL - return the first private.
+ */
+void *netdev_lower_get_next_private(struct net_device *dev,
+				    struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	if (iter)
+		lower = list_entry((*iter)->next, struct netdev_adjacent,
+				   list);
+	else
+		lower = list_entry(dev->adj_list.lower.next,
+				   struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	if (iter)
+		*iter = &lower->list;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_get_next_private);
+
+/* netdev_lower_get_next_private_rcu - Get the next ->private from the
+ *				       lower neighbour list, RCU
+ *				       variant
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold RCU read lock.
+ * If iter is NULL - returns the first private.
+ */
+void *netdev_lower_get_next_private_rcu(struct net_device *dev,
+					struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (iter)
+		lower = list_entry_rcu((*iter)->next, struct netdev_adjacent,
+				       list);
+	else
+		lower = list_entry_rcu(dev->adj_list.lower.next,
+				       struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	if (iter)
+		*iter = &lower->list;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_get_next_private_rcu);
+
 /**
  * netdev_master_upper_dev_get_rcu - Get master upper device
  * @dev: device
-- 
1.8.4
