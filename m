From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 27/27] net: create sysfs symlinks for neighbour devices
Date: Wed, 25 Sep 2013 09:20:32 +0200
Message-ID: <1380093632-1842-28-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab3IYHVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:20 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, remove the same functionality from bonding - it will be already done
for any device that links to its lower/upper neighbour.

The links will be created for dev's kobject, and will look like
lower_eth0 for lower device eth0 and upper_bridge0 for upper device
bridge0.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
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
    Convert the logic to the new functions, which don't have the bool upper
    argument.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Rename lower devices from slave_eth0 to lower_eth0, so that it meets
    the lower/upper naming. I've searched for any active users of bonding's
    slave_eth0, and seems that nobody's actively using it or relying on it.

 drivers/net/bonding/bond_main.c  | 11 +----------
 drivers/net/bonding/bond_sysfs.c | 21 ---------------------
 drivers/net/bonding/bonding.h    |  2 --
 net/core/dev.c                   | 35 ++++++++++++++++++++++++++++++++++-
 4 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d494045..d5c3153 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1612,15 +1612,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	read_unlock(&bond->lock);
 
-	res = bond_create_slave_symlinks(bond_dev, slave_dev);
-	if (res)
-		goto err_detach;
-
 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
 					 new_slave);
 	if (res) {
 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
-		goto err_dest_symlinks;
+		goto err_detach;
 	}
 
 	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
@@ -1642,9 +1638,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 err_unregister:
 	netdev_rx_handler_unregister(slave_dev);
 
-err_dest_symlinks:
-	bond_destroy_slave_symlinks(bond_dev, slave_dev);
-
 err_detach:
 	if (!USES_PRIMARY(bond->params.mode))
 		bond_hw_addr_flush(bond_dev, slave_dev);
@@ -1842,8 +1835,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 			bond_dev->name, slave_dev->name, bond_dev->name);
 
 	/* must do this from outside any spinlocks */
-	bond_destroy_slave_symlinks(bond_dev, slave_dev);
-
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
 
 	/* If the mode USES_PRIMARY, then this cases was handled above by
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1c57246..e06c644 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -168,27 +168,6 @@ static const struct class_attribute class_attr_bonding_masters = {
 	.namespace = bonding_namespace,
 };
 
-int bond_create_slave_symlinks(struct net_device *master,
-			       struct net_device *slave)
-{
-	char linkname[IFNAMSIZ+7];
-
-	/* create a link from the master to the slave */
-	sprintf(linkname, "slave_%s", slave->name);
-	return sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
-				 linkname);
-}
-
-void bond_destroy_slave_symlinks(struct net_device *master,
-				 struct net_device *slave)
-{
-	char linkname[IFNAMSIZ+7];
-
-	sprintf(linkname, "slave_%s", slave->name);
-	sysfs_remove_link(&(master->dev.kobj), linkname);
-}
-
-
 /*
  * Show the slaves in the current bond.
  */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e5c32a6..5b71601 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -436,8 +436,6 @@ int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
-int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave);
-void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_mii_monitor(struct work_struct *);
diff --git a/net/core/dev.c b/net/core/dev.c
index de443ee..25ab6fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4584,6 +4584,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					void *private, bool master)
 {
 	struct netdev_adjacent *adj;
+	char linkname[IFNAMSIZ+7];
 	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, dev_list);
@@ -4606,12 +4607,26 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
 
+	if (dev_list == &dev->adj_list.lower) {
+		sprintf(linkname, "lower_%s", adj_dev->name);
+		ret = sysfs_create_link(&(dev->dev.kobj),
+					&(adj_dev->dev.kobj), linkname);
+		if (ret)
+			goto free_adj;
+	} else if (dev_list == &dev->adj_list.upper) {
+		sprintf(linkname, "upper_%s", adj_dev->name);
+		ret = sysfs_create_link(&(dev->dev.kobj),
+					&(adj_dev->dev.kobj), linkname);
+		if (ret)
+			goto free_adj;
+	}
+
 	/* Ensure that master link is always the first item in list. */
 	if (master) {
 		ret = sysfs_create_link(&(dev->dev.kobj),
 					&(adj_dev->dev.kobj), "master");
 		if (ret)
-			goto free_adj;
+			goto remove_symlinks;
 
 		list_add_rcu(&adj->list, dev_list);
 	} else {
@@ -4620,6 +4635,15 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	return 0;
 
+remove_symlinks:
+	if (dev_list == &dev->adj_list.lower) {
+		sprintf(linkname, "lower_%s", adj_dev->name);
+		sysfs_remove_link(&(dev->dev.kobj), linkname);
+	} else if (dev_list == &dev->adj_list.upper) {
+		sprintf(linkname, "upper_%s", adj_dev->name);
+		sysfs_remove_link(&(dev->dev.kobj), linkname);
+	}
+
 free_adj:
 	kfree(adj);
 
@@ -4631,6 +4655,7 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 				  struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
+	char linkname[IFNAMSIZ+7];
 
 	adj = __netdev_find_adj(dev, adj_dev, dev_list);
 
@@ -4650,6 +4675,14 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
+	if (dev_list == &dev->adj_list.lower) {
+		sprintf(linkname, "lower_%s", adj_dev->name);
+		sysfs_remove_link(&(dev->dev.kobj), linkname);
+	} else if (dev_list == &dev->adj_list.upper) {
+		sprintf(linkname, "upper_%s", adj_dev->name);
+		sysfs_remove_link(&(dev->dev.kobj), linkname);
+	}
+
 	list_del_rcu(&adj->list);
 	pr_debug("dev_put for %s, because link removed from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
-- 
1.8.4
