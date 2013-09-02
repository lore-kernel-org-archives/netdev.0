From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 14/21] net: add netdev_for_each_lower_neigh_private_continue()
Date: Mon,  2 Sep 2013 23:39:18 +0200
Message-ID: <1378157965-17537-15-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab3IBVjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:32 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro allows going through the neighbour lower list private's from a
specific position and till it doesn't hit the same position again.

For that, two functions are needed:

netdev_lower_neigh_set_iter_per_private(dev, iter, from_priv) - which
searches for from_priv and, if found, sets the iter to the correct
position, returning from_priv.

netdev_lower_neigh_get_next_private_to(dev, iter, from_priv) - gets the
next ->private (and skips the list head), or if the next private equals
from_priv - returns NULL. Also returns NULL if the ->private is NULL, to
catch the case if the list doesn't have any elements.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h | 14 +++++++++++
 net/core/dev.c            | 62 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1a149ef..20afdf98 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2788,6 +2788,20 @@ extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 	     updev; \
 	     updev = netdev_upper_get_next_dev_rcu(dev, &(iter)))
 
+extern void *netdev_lower_neigh_set_iter_per_private(struct net_device *dev,
+						     struct list_head **iter,
+						     void *private);
+extern void *netdev_lower_neigh_get_next_private_to(struct net_device *dev,
+						    struct list_head **iter,
+						    void *to);
+
+#define netdev_for_each_lower_neigh_private_continue(dev, priv, from_priv, iter) \
+	for (priv = netdev_lower_neigh_set_iter_per_private(dev, &(iter), \
+							    from_priv);   \
+	     priv; \
+	     priv = netdev_lower_neigh_get_next_private_to(dev, &(iter),  \
+							   from_priv))
+
 extern void *netdev_lower_neigh_get_next_private(struct net_device *dev,
 						 struct list_head **iter);
 extern void *netdev_lower_neigh_get_next_private_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 55f8ac4..1b9862b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4555,6 +4555,68 @@ struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_get_next_dev_rcu);
 
+/* netdev_lower_neigh_set_iter_per_private - Set the iter to reflect the
+ *					     position of the ->private
+ * @dev: device
+ * @iter: iter to be set
+ * @private: private to be found
+ *
+ * Iterates through lower neighbours, searching for private. When found,
+ * sets the iter to the ->list. Returns private or NULL if not found. User
+ * must hold RTNL lock or make sure that the list isn't modified.
+ */
+void *netdev_lower_neigh_set_iter_per_private(struct net_device *dev,
+					      struct list_head **iter,
+					      void *private)
+{
+	struct netdev_adjacent *lower;
+
+	list_for_each_entry(lower, &dev->neighbour_dev_list.lower, list)
+		if (lower->private == private)
+			break;
+
+	if (&lower->list == &dev->neighbour_dev_list.lower)
+		return NULL;
+
+	*iter = &lower->list;
+
+	return private;
+}
+EXPORT_SYMBOL(netdev_lower_neigh_set_iter_per_private);
+
+/* netdev_lower_neigh_get_next_private_to - Get the next ->private from the
+ *					    lower neighbour list, stop at to
+ * @dev: device
+ * @iter: list_head ** of the current position
+ * @to: if private == to then stop
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold either hold the
+ * RTNL lock or its own locking that guarantees that the neighbour lower
+ * list will remain unchainged. Stops when private == to or when it hits a
+ * NULL private.
+ */
+void *netdev_lower_neigh_get_next_private_to(struct net_device *dev,
+					     struct list_head **iter,
+					     void *to)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry((*iter)->next, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->neighbour_dev_list.lower)
+		lower = list_entry(lower->list.next, struct netdev_adjacent,
+				   list);
+
+	if (lower->private == to || !lower->private)
+		return NULL;
+
+	*iter = &lower->list;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_neigh_get_next_private_to);
+
 /* netdev_lower_neigh_get_next_private - Get the next ->private from the
  *					 lower neighbour list
  * @dev: device
-- 
1.8.4
