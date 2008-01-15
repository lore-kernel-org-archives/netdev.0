From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: [PATCH 2/4] bonding: Add destroy_workqueue() to bond device destroying process
Date: Tue, 15 Jan 2008 15:36:06 +0900
Message-ID: <20080115063650.069322000@miraclelinux.com>
References: <20080115063604.577118000@miraclelinux.com>
Cc: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:9817 "EHLO
	dhcp-0021.miraclelinux.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751318AbYAOGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:34:25 -0500
Content-Disposition: inline; filename=bonding-guarantee-destroy-work.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no destroy_workqueue() in bond device destroying process, therefore
worker thread will remain even if bond device is destroyed. So add
destroy_workqueue(), and also, ensure all works are canceled before
destroy_workqueue() is called.

Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
---

 drivers/net/bonding/bond_main.c  |   72 +++++++++++++++++++-------------------
 drivers/net/bonding/bond_sysfs.c |    9 ++++
 drivers/net/bonding/bonding.h    |    5 ++
 3 files changed, 48 insertions(+), 38 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -190,7 +190,6 @@ struct bond_parm_tbl arp_validate_tbl[] 
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
-static void bond_deinit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -862,7 +861,7 @@ static void bond_resend_igmp_join_reques
 /*
  * Totally destroys the mc_list in bond
  */
-static void bond_mc_list_destroy(struct bonding *bond)
+void bond_mc_list_destroy(struct bonding *bond)
 {
 	struct dev_mc_list *dmi;
 
@@ -1875,7 +1874,7 @@ int  bond_release_and_destroy(struct net
 /*
  * This function releases all slaves.
  */
-static int bond_release_all(struct net_device *bond_dev)
+int bond_release_all(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave;
@@ -4392,6 +4391,25 @@ static const struct ethtool_ops bond_eth
 	.get_drvinfo		= bond_ethtool_get_drvinfo,
 };
 
+/* Caller must not hold rtnl_lock */
+void bond_work_cancel_all(struct bonding *bond)
+{
+	/* ensure all works are stopped */
+	cancel_delayed_work_sync(&bond->alb_work);
+	cancel_delayed_work_sync(&bond->mii_work);
+	cancel_delayed_work_sync(&bond->ab_arp_work);
+	cancel_delayed_work_sync(&bond->lb_arp_work);
+	cancel_delayed_work_sync(&bond->ad_work);
+}
+
+static void bond_free_netdev(struct net_device *dev)
+{
+	struct bonding *bond = netdev_priv(dev);
+
+	destroy_workqueue(bond->wq);
+	free_netdev(dev);
+}
+
 /*
  * Does not allocate but creates a /proc entry.
  * Allowed to fail.
@@ -4441,7 +4459,7 @@ static int bond_init(struct net_device *
 
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = free_netdev;
+	bond_dev->destructor = bond_free_netdev;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4483,7 +4501,7 @@ static int bond_init(struct net_device *
 /* De-initialize device specific data.
  * Caller must hold rtnl_lock.
  */
-static void bond_deinit(struct net_device *bond_dev)
+void bond_deinit(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 
@@ -4494,29 +4512,6 @@ static void bond_deinit(struct net_devic
 #endif
 }
 
-static void bond_work_cancel_all(struct bonding *bond)
-{
-	write_lock_bh(&bond->lock);
-	bond->kill_timers = 1;
-	write_unlock_bh(&bond->lock);
-
-	if (bond->params.miimon)
-		cancel_delayed_work(&bond->mii_work);
-
-	if (bond->params.arp_interval) {
-		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
-			cancel_delayed_work(&bond->ab_arp_work);
-		else
-			cancel_delayed_work(&bond->lb_arp_work);
-	}
-
-	if (bond->params.mode == BOND_MODE_ALB)
-		cancel_delayed_work(&bond->alb_work);
-
-	if (bond->params.mode == BOND_MODE_8023AD)
-		cancel_delayed_work(&bond->ad_work);
-}
-
 /* Unregister and free all bond devices.
  * Caller must hold rtnl_lock.
  */
@@ -4527,11 +4522,14 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
+		bond_deinit(bond_dev);
+		rtnl_unlock();
 		bond_work_cancel_all(bond);
+		rtnl_lock();
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
+		bond_destroy_sysfs_entry(bond);
 		unregister_netdevice(bond_dev);
 	}
 
@@ -4921,8 +4919,16 @@ int bond_create(char *name, struct bond_
 
 out_bond:
 	bond_deinit(bond_dev);
+	if (*newbond)
+		unregister_netdevice(bond_dev);
+	else {
+		rtnl_unlock();
+		bond_work_cancel_all(netdev_priv(bond_dev));
+		rtnl_lock();
+		destroy_workqueue(((struct bonding *)netdev_priv(bond_dev))->wq);
 out_netdev:
-	free_netdev(bond_dev);
+		free_netdev(bond_dev);
+	}
 out_rtnl:
 	rtnl_unlock();
 	return res;
@@ -4932,7 +4938,6 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	struct bonding *bond, *nxt;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4959,11 +4964,6 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
-		bond_work_cancel_all(bond);
-		destroy_workqueue(bond->wq);
-	}
-
 	rtnl_lock();
 	bond_free_all();
 	bond_destroy_sysfs();
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -163,7 +163,14 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_destroy(bond);
+ 				bond_deinit(bond->dev);
+				rtnl_unlock();
+				bond_work_cancel_all(bond);
+				rtnl_lock();
+				bond_mc_list_destroy(bond);
+				bond_release_all(bond->dev);
+ 		        	bond_destroy_sysfs_entry(bond);
+ 				unregister_netdevice(bond->dev);
 				rtnl_unlock();
 				goto out;
 			}
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -301,7 +301,10 @@ static inline void bond_unset_master_alb
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
-void bond_destroy(struct bonding *bond);
+void bond_deinit(struct net_device *bond_dev);
+void bond_work_cancel_all(struct bonding *bond);
+void bond_mc_list_destroy(struct bonding *bond);
+int bond_release_all(struct net_device *bond_dev);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION 
