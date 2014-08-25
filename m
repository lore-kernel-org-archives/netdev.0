From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: [PATCH] net: prevent of emerging cross-namespace symlinks
Date: Mon, 25 Aug 2014 16:26:45 +0400
Message-ID: <1408969605-5800-1-git-send-email-git.user@gmail.com>
References: <20140821143816.48c5ad08@mad-cat.int.e5.ru> <20140821121205.GR9476@redhat.com> <20140821191316.27807ef7@mad-cat.int.e5.ru> <20140821152940.GT9476@redhat.com> <1408703693-6265-1-git-send-email-git.user@gmail.com> <20140822.113039.520798752693024139.davem@davemloft.net> <20140824.182842.1083967994418672720.davem@davemloft.net>
Cc: "Alexander Y. Fomichev" <git.user@gmail.com>, vfalico@redhat.com,
	"David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:58629 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbaHYM0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 08:26:53 -0400
Received: by mail-la0-f46.google.com with SMTP id b8so12890471lan.33
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 05:26:52 -0700 (PDT)
In-Reply-To: <20140824.182842.1083967994418672720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code manipulating sysfs symlinks on adjacent net_devices(s)
currently doesn't take into account that devices potentially
belong to different namespaces.

This patch trying to fix an issue as follows:
- check for net_ns before creating / deleting symlink.
  for now only netdev_adjacent_rename_links and
  __netdev_adjacent_dev_remove are affected, afaics
  __netdev_adjacent_dev_insert implies both net_devs
  belong to the same namespace.
- Drop all existing symlinks to / from all adj_devs before
  switching namespace and recreate them just after.

Signed-off-by: Alexander Y. Fomichev <git.user@gmail.com>
---
 net/core/dev.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b65a5051361f..66738e9d66e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4889,7 +4889,8 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+	    net_eq(dev_net(dev),dev_net(adj_dev)))
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
@@ -6773,6 +6830,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Send a netdev-removed uevent to the old namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+	netdev_adjacent_del_links(dev);
 
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
@@ -6787,6 +6845,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+	netdev_adjacent_add_links(dev);
 
 	/* Fixup kobjects */
 	err = device_rename(&dev->dev, dev->name);
-- 
2.0.4
