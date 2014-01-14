From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 1/2] net: add sysfs helpers for netdev_adjacent logic
Date: Tue, 14 Jan 2014 21:58:50 +0100
Message-ID: <1389733131-15390-2-git-send-email-vfalico@redhat.com>
References: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbaANVDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 16:03:19 -0500
In-Reply-To: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They clean up the code a bit and can be used further.

CC: Ding Tianhong <dingtianhong@huawei.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c | 57 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 87312dc..c578d4e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4595,13 +4595,36 @@ struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
 
+int netdev_adjacent_sysfs_add(struct net_device *dev,
+			      struct net_device *adj_dev,
+			      struct list_head *dev_list)
+{
+	char linkname[IFNAMSIZ+7];
+	sprintf(linkname, dev_list == &dev->adj_list.upper ?
+		"upper_%s" : "lower_%s", adj_dev->name);
+	return sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
+				 linkname);
+}
+void netdev_adjacent_sysfs_del(struct net_device *dev,
+			       char *name,
+			       struct list_head *dev_list)
+{
+	char linkname[IFNAMSIZ+7];
+	sprintf(linkname, dev_list == &dev->adj_list.upper ?
+		"upper_%s" : "lower_%s", name);
+	sysfs_remove_link(&(dev->dev.kobj), linkname);
+}
+
+#define netdev_adjacent_is_neigh_list(dev, dev_list) \
+		(dev_list == &dev->adj_list.upper || \
+		 dev_list == &dev->adj_list.lower)
+
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
 					struct list_head *dev_list,
 					void *private, bool master)
 {
 	struct netdev_adjacent *adj;
-	char linkname[IFNAMSIZ+7];
 	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, dev_list);
@@ -4624,16 +4647,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
 
-	if (dev_list == &dev->adj_list.lower) {
-		sprintf(linkname, "lower_%s", adj_dev->name);
-		ret = sysfs_create_link(&(dev->dev.kobj),
-					&(adj_dev->dev.kobj), linkname);
-		if (ret)
-			goto free_adj;
-	} else if (dev_list == &dev->adj_list.upper) {
-		sprintf(linkname, "upper_%s", adj_dev->name);
-		ret = sysfs_create_link(&(dev->dev.kobj),
-					&(adj_dev->dev.kobj), linkname);
+	if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
+		ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
 		if (ret)
 			goto free_adj;
 	}
@@ -4653,14 +4668,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	return 0;
 
 remove_symlinks:
-	if (dev_list == &dev->adj_list.lower) {
-		sprintf(linkname, "lower_%s", adj_dev->name);
-		sysfs_remove_link(&(dev->dev.kobj), linkname);
-	} else if (dev_list == &dev->adj_list.upper) {
-		sprintf(linkname, "upper_%s", adj_dev->name);
-		sysfs_remove_link(&(dev->dev.kobj), linkname);
-	}
-
+	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 free_adj:
 	kfree(adj);
 	dev_put(adj_dev);
@@ -4673,7 +4682,6 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 					 struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
-	char linkname[IFNAMSIZ+7];
 
 	adj = __netdev_find_adj(dev, adj_dev, dev_list);
 
@@ -4693,13 +4701,8 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
-	if (dev_list == &dev->adj_list.lower) {
-		sprintf(linkname, "lower_%s", adj_dev->name);
-		sysfs_remove_link(&(dev->dev.kobj), linkname);
-	} else if (dev_list == &dev->adj_list.upper) {
-		sprintf(linkname, "upper_%s", adj_dev->name);
-		sysfs_remove_link(&(dev->dev.kobj), linkname);
-	}
+	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 
 	list_del_rcu(&adj->list);
 	pr_debug("dev_put for %s, because link removed from %s to %s\n",
-- 
1.8.4
