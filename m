From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 07/27] net: add for_each iterators through neighbour lower link's private
Date: Wed, 25 Sep 2013 09:20:12 +0200
Message-ID: <1380093632-1842-8-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab3IYHUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:20:41 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a possibility to iterate through netdev_adjacent's private, currently
only for lower neighbours.

Add both RCU and RTNL/other locking variants of iterators, and make the
non-rcu variant to be safe from removal.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    Make netdev_for_each_lower_private() be safe for the entry removal, by
    storing the ->next pointer in iter.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    rename neighbour_dev_list/all_dev_list to adj_list/all_adj_list and rework
    the naming of functions - to make the use the pattern
    netdev_(all_)(lower|upper)_* . Also reword the commit message - I had to
    read it three times to understand :-/, and move it closer to the beginning
    of the patchset.

 include/linux/netdevice.h | 17 ++++++++++++++
 net/core/dev.c            | 60 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 76 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75d5bea..168974e 100644
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
+	for (iter = (dev)->adj_list.lower.next, \
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
index c69ab74..0aa844a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4466,7 +4466,8 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get);
 
-/* netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
+/**
+ * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
  * @iter: list_head ** of the current position
  *
@@ -4492,6 +4493,63 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
 EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
 
 /**
+ * netdev_lower_get_next_private - Get the next ->private from the
+ *				   lower neighbour list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold either hold the
+ * RTNL lock or its own locking that guarantees that the neighbour lower
+ * list will remain unchainged.
+ */
+void *netdev_lower_get_next_private(struct net_device *dev,
+				    struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry(*iter, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	if (iter)
+		*iter = lower->list.next;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_get_next_private);
+
+/**
+ * netdev_lower_get_next_private_rcu - Get the next ->private from the
+ *				       lower neighbour list, RCU
+ *				       variant
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold RCU read lock.
+ */
+void *netdev_lower_get_next_private_rcu(struct net_device *dev,
+					struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
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
+/**
  * netdev_master_upper_dev_get_rcu - Get master upper device
  * @dev: device
  *
-- 
1.8.4
