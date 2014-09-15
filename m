From: Alexander Fomichev <git.user@gmail.com>
Subject: [PATCH net] net: fix creation adjacent device symlinks
Date: Mon, 15 Sep 2014 14:22:35 +0400
Message-ID: <1410776555-29983-1-git-send-email-git.user@gmail.com>
References: <20140914.174507.2303420279405209295.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Alexander Fomichev <git.user@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:41535 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbaIOKWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:22:49 -0400
Received: by mail-lb0-f181.google.com with SMTP id z11so4115581lbi.40
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:22:45 -0700 (PDT)
In-Reply-To: <20140914.174507.2303420279405209295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netdev_adjacent_dev_insert may add adjust device of different net
namespace, without proper check it leads to emergence of broken
sysfs links from/to devices in another namespace.
Fix: rewrite netdev_adjacent_is_neigh_list macro as a function,
     move net_eq check into netdev_adjacent_is_neigh_list.
     (thanks David)
     related to: 4c75431ac3520631f1d9e74aa88407e6374dbbc4

Signed-off-by: Alexander Fomichev <git.user@gmail.com>
---
 net/core/dev.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9a16530c36..00f15bc0a2ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4809,9 +4809,14 @@ static void netdev_adjacent_sysfs_del(struct net_device *dev,
 	sysfs_remove_link(&(dev->dev.kobj), linkname);
 }
 
-#define netdev_adjacent_is_neigh_list(dev, dev_list) \
-		(dev_list == &dev->adj_list.upper || \
-		 dev_list == &dev->adj_list.lower)
+static inline bool netdev_adjacent_is_neigh_list(struct net_device *dev,
+						 struct net_device *adj_dev,
+						 struct list_head *dev_list)
+{
+	return (dev_list == &dev->adj_list.upper ||
+		dev_list == &dev->adj_list.lower) &&
+		net_eq(dev_net(dev), dev_net(adj_dev));
+}
 
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
@@ -4841,7 +4846,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
+	if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list)) {
 		ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
 		if (ret)
 			goto free_adj;
@@ -4862,7 +4867,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	return 0;
 
 remove_symlinks:
-	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+	if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 free_adj:
 	kfree(adj);
@@ -4895,8 +4900,7 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
-	    net_eq(dev_net(dev),dev_net(adj_dev)))
+	if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 
 	list_del_rcu(&adj->list);
-- 
2.1.0
