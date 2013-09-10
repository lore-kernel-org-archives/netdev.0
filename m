From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 27/27] net: create sysfs symlinks for neighbour devices
Date: Tue, 10 Sep 2013 22:58:11 +0200
Message-ID: <1378846691-9717-28-git-send-email-vfalico@redhat.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab3IJU65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:58:57 -0400
In-Reply-To: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
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
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Rename lower devices from slave_eth0 to lower_eth0, so that it meets
    the lower/upper naming. I've searched for any active users of bonding's
    slave_eth0, and seems that nobody's actively using it or relying on it.

 drivers/net/bonding/bond_main.c  | 11 +----------
 drivers/net/bonding/bond_sysfs.c | 25 -------------------------
 drivers/net/bonding/bonding.h    |  2 --
 net/core/dev.c                   | 29 +++++++++++++++++++++++++++++
 4 files changed, 30 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 707b0bc..2c0e4a5 100644
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
index fd178a4..ef75471 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -168,31 +168,6 @@ static const struct class_attribute class_attr_bonding_masters = {
 	.namespace = bonding_namespace,
 };
 
-int bond_create_slave_symlinks(struct net_device *master,
-			       struct net_device *slave)
-{
-	char linkname[IFNAMSIZ+7];
-	int ret = 0;
-
-	/* create a link from the master to the slave */
-	sprintf(linkname, "slave_%s", slave->name);
-	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
-				linkname);
-
-	return ret;
-
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
index 0e8e00e..74efa45 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -410,8 +410,6 @@ int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
-int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave);
-void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_mii_monitor(struct work_struct *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 27ca03f..5fe2dd0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4638,6 +4638,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					bool upper, void *private)
 {
 	struct netdev_adjacent *adj, *neigh = NULL;
+	char linkname[IFNAMSIZ+7];
 	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, upper, false);
@@ -4685,6 +4686,16 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 			 */
 			if (master)
 				neigh->private = private;
+
+			sprintf(linkname, "lower_%s", adj_dev->name);
+			ret = sysfs_create_link(&(dev->dev.kobj),
+						&(adj_dev->dev.kobj),
+						linkname);
+			if (ret) {
+				kfree(neigh);
+				kfree(adj);
+				return ret;
+			}
 			list_add_tail_rcu(&neigh->list,
 					  &dev->adj_list.lower);
 		}
@@ -4692,10 +4703,24 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 		return 0;
 	}
 
+	/* it's upper neighbour, we don't care if it's master or not */
+	if (neigh) {
+		sprintf(linkname, "upper_%s", adj_dev->name);
+		ret = sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
+					linkname);
+		if (ret) {
+			kfree(neigh);
+			kfree(adj);
+			return ret;
+		}
+	}
+
 	/* Ensure that master upper link is always the first item in list. */
 	if (master) {
 		ret = sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj), "master");
 		if (ret) {
+			if (neigh)
+				sysfs_remove_link(&(dev->dev.kobj), linkname);
 			kfree(neigh);
 			kfree(adj);
 			return ret;
@@ -4736,6 +4761,7 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 				  bool is_neigh)
 {
 	struct netdev_adjacent *adj, *neighbour;
+	char linkname[IFNAMSIZ+7];
 
 	if (upper) {
 		adj = __netdev_all_upper_find(dev, adj_dev);
@@ -4758,6 +4784,9 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 			 adj_dev->name);
 		if (neighbour->master && upper)
 			sysfs_remove_link(&(dev->dev.kobj), "master");
+		sprintf(linkname, "%s_%s", upper ? "upper" : "lower",
+			adj_dev->name);
+		sysfs_remove_link(&(dev->dev.kobj), linkname);
 		list_del_rcu(&neighbour->list);
 		dev_put(adj_dev);
 		kfree_rcu(neighbour, rcu);
-- 
1.8.4
