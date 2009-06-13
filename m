From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] bonding: fix destructor
Date: Fri, 12 Jun 2009 22:02:47 -0700
Message-ID: <20090613050421.816186819@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49239 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbZFMFGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:19 -0400
Content-Disposition: inline; filename=bond-destruct.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not safe to use a network device destructor that is a function in
the module, since it can be called after module is unloaded if sysfs
handle is open.

When eventually using netlink, the device cleanup code needs to be donen
via uninit function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 12:02:45.186919049 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:44:52.148228948 -0700
@@ -127,7 +127,7 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_destroy(bond);
+				unregister_netdevice(bond->dev);
 				goto out_unlock;
 			}
 
--- a/drivers/net/bonding/bonding.h	2009-06-12 12:02:45.187973745 -0700
+++ b/drivers/net/bonding/bonding.h	2009-06-12 12:02:53.504241280 -0700
@@ -322,7 +322,6 @@ static inline void bond_unset_master_alb
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(const char *name);
-void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
--- a/drivers/net/bonding/bond_main.c	2009-06-12 12:03:10.776948783 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 21:45:37.932394640 -0700
@@ -1972,25 +1972,19 @@ int bond_release(struct net_device *bond
 * Destroy a bonding device.
 * Must be under rtnl_lock when this function is called.
 */
-void bond_destroy(struct bonding *bond)
-{
-	bond_deinit(bond->dev);
-	bond_destroy_sysfs_entry(bond);
-	unregister_netdevice(bond->dev);
-}
-
-static void bond_destructor(struct net_device *bond_dev)
+static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
+	bond_deinit(bond_dev);
+	bond_destroy_sysfs_entry(bond);
+
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
 
 	netif_addr_lock_bh(bond_dev);
 	bond_mc_list_destroy(bond);
 	netif_addr_unlock_bh(bond_dev);
-
-	free_netdev(bond_dev);
 }
 
 /*
@@ -2006,7 +2000,7 @@ int  bond_release_and_destroy(struct net
 	if ((ret == 0) && (bond->slave_cnt == 0)) {
 		printk(KERN_INFO DRV_NAME ": %s: destroying bond %s.\n",
 		       bond_dev->name, bond_dev->name);
-		bond_destroy(bond);
+		unregister_netdevice(bond_dev);
 	}
 	return ret;
 }
@@ -4572,6 +4566,7 @@ static const struct ethtool_ops bond_eth
 };
 
 static const struct net_device_ops bond_netdev_ops = {
+	.ndo_uninit		= bond_uninit,
 	.ndo_open		= bond_open,
 	.ndo_stop		= bond_close,
 	.ndo_start_xmit		= bond_start_xmit,
@@ -4622,7 +4617,7 @@ static int bond_init(struct net_device *
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = bond_destructor;
+	bond_dev->destructor = free_netdev;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4706,7 +4701,7 @@ static void bond_free_all(void)
 		bond_work_cancel_all(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_destroy(bond);
+		unregister_netdevice(bond_dev);
 	}
 
 	bond_destroy_proc_dir();

-- 

