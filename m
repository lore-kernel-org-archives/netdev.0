From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 1/4] net: Find the nesting level of a given device by type.
Date: Fri, 16 May 2014 17:04:53 -0400
Message-ID: <1400274296-14765-2-git-send-email-vyasevic@redhat.com>
References: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
Cc: dingtianhong@huawei.com, kaber@trash.net, vfalico@gmail.com,
	jiri@resnulli.us, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754419AbaEPVFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 17:05:17 -0400
In-Reply-To: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiple devices in the kernel can be stacked/nested and they
need to know their nesting level for the purposes of lockdep.
This patch provides a generic function that determines a nesting
level of a particular device by its type (ex: vlan, macvlan, etc).
We only care about nesting of the same type of devices.

For example:
  eth0 <- vlan0.10 <- macvlan0 <- vlan1.20

The nesting level of vlan1.20 would be 1, since there is another vlan
in the stack under it.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 10 ++++++++++
 net/core/dev.c            | 50 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 20e99ef..fb912e8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3077,6 +3077,14 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	     priv; \
 	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
 
+void *netdev_lower_get_next(struct net_device *dev,
+				struct list_head **iter);
+#define netdev_for_each_lower_dev(dev, ldev, iter) \
+	for (iter = &(dev)->adj_list.lower, \
+	     ldev = netdev_lower_get_next(dev, &(iter)); \
+	     ldev; \
+	     ldev = netdev_lower_get_next(dev, &(iter)))
+
 void *netdev_adjacent_get_private(struct list_head *adj_list);
 void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
@@ -3092,6 +3100,8 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
+int dev_get_nest_level(struct net_device *dev,
+		       bool (*type_check)(struct net_device *dev));
 int skb_checksum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6da649b..a9bfef6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4622,6 +4622,32 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 EXPORT_SYMBOL(netdev_lower_get_next_private_rcu);
 
 /**
+ * netdev_lower_get_next - Get the next device from the lower neighbour
+ *                         list
+ * @dev: device
+ * @iter: list_head ** of the current position
+ *
+ * Gets the next netdev_adjacent from the dev's lower neighbour
+ * list, starting from iter position. The caller must hold RTNL lock or
+ * its own locking that guarantees that the neighbour lower
+ * list will remain unchainged.
+ */
+void *netdev_lower_get_next(struct net_device *dev, struct list_head **iter)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_entry((*iter)->next, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->adj_list.lower)
+		return NULL;
+
+	*iter = &lower->list;
+
+	return lower->dev;
+}
+EXPORT_SYMBOL(netdev_lower_get_next);
+
+/**
  * netdev_lower_get_first_private_rcu - Get the first ->private from the
  *				       lower neighbour list, RCU
  *				       variant
@@ -5071,6 +5097,30 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
+
+int dev_get_nest_level(struct net_device *dev,
+		       bool (*type_check)(struct net_device *dev))
+{
+	struct net_device *lower = NULL;
+	struct list_head *iter;
+	int max_nest = -1;
+	int nest;
+
+	ASSERT_RTNL();
+
+	netdev_for_each_lower_dev(dev, lower, iter) {
+		nest = dev_get_nest_level(lower, type_check);
+		if (max_nest < nest)
+			max_nest = nest;
+	}
+
+	if (type_check(dev))
+		max_nest++;
+
+	return max_nest;
+}
+EXPORT_SYMBOL(dev_get_nest_level);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.9.0
