From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: [PATCH] netdev_adjacent_sysfs_*: fix cross-namespace symlinks
Date: Fri, 22 Aug 2014 12:53:33 +0400
Message-ID: <E1XKlLE-0006GZ-FP@relay.e5.ru>
References: <20140821143816.48c5ad08@mad-cat.int.e5.ru>
 <20140821121205.GR9476@redhat.com>
  <20140821191316.27807ef7@mad-cat.int.e5.ru>
  <20140821152940.GT9476@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.e5.ru ([62.141.72.241]:46853 "EHLO mx0.e5.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaHVKBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2014 06:01:11 -0400
Received: from gluk by relay.e5.ru with local (Exim 4.80)
	(envelope-from <git.user@gmail.com>)
	id 1XKlLE-0006GZ-FP
	for netdev@vger.kernel.org; Fri, 22 Aug 2014 13:41:04 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix code manipulating symlinks of adjacent net devices.
- prevent creation of sysfs symlink to / from adjacent device on
  another net_ns.
- Drop all existing symlinks from / to all adj_dev(s) on the current
  namespace before switching net_ns and recreate them just after.
---
 net/core/dev.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 61 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..683cedf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4889,7 +4889,8 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+		net_eq(dev_net(dev),dev_net(adj_dev)))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 
 	list_del_rcu(&adj->list);
@@ -5159,11 +5160,65 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+void netdev_adjacent_add_links(struct net_device *dev)
+{
+	struct netdev_adjacent *iter;
+
+	struct net *net = dev_net(dev);
+
+	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.lower);
+		netdev_adjacent_sysfs_add(dev, iter->dev,
+					  &dev->adj_list.upper);
+	}
+
+	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.upper);
+		netdev_adjacent_sysfs_add(dev, iter->dev,
+					  &dev->adj_list.lower);
+	}
+}
+
+void netdev_adjacent_del_links(struct net_device *dev)
+{
+	struct netdev_adjacent *iter;
+
+	struct net *net = dev_net(dev);
+
+	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_del(iter->dev, dev->name,
+					  &iter->dev->adj_list.lower);
+		netdev_adjacent_sysfs_del(dev, iter->dev->name,
+					  &dev->adj_list.upper);
+	}
+
+	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_del(iter->dev, dev->name,
+					  &iter->dev->adj_list.upper);
+		netdev_adjacent_sysfs_del(dev, iter->dev->name,
+					  &dev->adj_list.lower);
+	}
+}
+
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 {
 	struct netdev_adjacent *iter;
 
+	struct net *net = dev_net(dev);
+
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.lower);
 		netdev_adjacent_sysfs_add(iter->dev, dev,
@@ -5171,6 +5226,8 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.upper);
 		netdev_adjacent_sysfs_add(iter->dev, dev,
@@ -6771,8 +6828,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_uc_flush(dev);
 	dev_mc_flush(dev);
 
+
 	/* Send a netdev-removed uevent to the old namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+	netdev_adjacent_del_links(dev);
 
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
@@ -6787,6 +6846,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+	netdev_adjacent_add_links(dev);
 
 	/* Fixup kobjects */
 	err = device_rename(&dev->dev, dev->name);
-- 
2.0.4
