From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bonding: initialization rework
Date: Wed, 10 Jun 2009 09:39:57 -0700
Message-ID: <20090610164258.160699757@vyatta.com>
References: <20090610163955.266850193@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34297 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774AbZFJRfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 13:35:14 -0400
Content-Disposition: inline; filename=bond-setup-work.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to rework how bonding devices are initialized to make it more
amenable to creating bonding devices via netlink.

The changes are:
   * bond_setup - callback from alloc_netdev
   * bond_init  - callback from register_netdevice
   * bond_uninit - callback from unregister_netdevice
Sysfs entries are now created/removed via workqueue.

Resolves possible race conditions with module removal and bond_destructor
through sysfs.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/bonding/bond_main.c  |  222 ++++++++++++++++++---------------------
 drivers/net/bonding/bond_sysfs.c |    2 
 drivers/net/bonding/bonding.h    |    3 
 3 files changed, 107 insertions(+), 120 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2009-06-10 09:23:14.691057890 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-10 09:30:51.753059292 -0700
@@ -1971,31 +1971,6 @@ int bond_release(struct net_device *bond
 }
 
 /*
-* Destroy a bonding device.
-* Must be under rtnl_lock when this function is called.
-*/
-void bond_destroy(struct bonding *bond)
-{
-	bond_deinit(bond->dev);
-	bond_destroy_sysfs_entry(bond);
-	unregister_netdevice(bond->dev);
-}
-
-static void bond_destructor(struct net_device *bond_dev)
-{
-	struct bonding *bond = netdev_priv(bond_dev);
-
-	if (bond->wq)
-		destroy_workqueue(bond->wq);
-
-	netif_addr_lock_bh(bond_dev);
-	bond_mc_list_destroy(bond);
-	netif_addr_unlock_bh(bond_dev);
-
-	free_netdev(bond_dev);
-}
-
-/*
 * First release a slave and than destroy the bond if no more slaves iare left.
 * Must be under rtnl_lock when this function is called.
 */
@@ -2008,7 +1983,7 @@ int  bond_release_and_destroy(struct net
 	if ((ret == 0) && (bond->slave_cnt == 0)) {
 		printk(KERN_INFO DRV_NAME ": %s: destroying bond %s.\n",
 		       bond_dev->name, bond_dev->name);
-		bond_destroy(bond);
+		unregister_netdevice(bond_dev);
 	}
 	return ret;
 }
@@ -4550,95 +4525,75 @@ static const struct ethtool_ops bond_eth
 	.get_flags		= ethtool_op_get_flags,
 };
 
-static const struct net_device_ops bond_netdev_ops = {
-	.ndo_open		= bond_open,
-	.ndo_stop		= bond_close,
-	.ndo_start_xmit		= bond_start_xmit,
-	.ndo_get_stats		= bond_get_stats,
-	.ndo_do_ioctl		= bond_do_ioctl,
-	.ndo_set_multicast_list	= bond_set_multicast_list,
-	.ndo_change_mtu		= bond_change_mtu,
-	.ndo_set_mac_address 	= bond_set_mac_address,
-	.ndo_neigh_setup	= bond_neigh_setup,
-	.ndo_vlan_rx_register	= bond_vlan_rx_register,
-	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
-};
+static void bond_sysfs_init(struct work_struct *work)
+{
+	bond_create_sysfs_entry(container_of(work, struct bonding, sysfs_work));
+}
 
-/*
- * Does not allocate but creates a /proc entry.
- * Allowed to fail.
- */
-static int bond_init(struct net_device *bond_dev, struct bond_params *params)
+static int bond_init(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
 	pr_debug("Begin bond_init for %s\n", bond_dev->name);
-
-	/* initialize rwlocks */
-	rwlock_init(&bond->lock);
-	rwlock_init(&bond->curr_slave_lock);
-
-	bond->params = *params; /* copy params struct */
-
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
 		return -ENOMEM;
 
-	/* Initialize pointers */
-	bond->first_slave = NULL;
-	bond->curr_active_slave = NULL;
-	bond->current_arp_slave = NULL;
-	bond->primary_slave = NULL;
-	bond->dev = bond_dev;
-	bond->send_grat_arp = 0;
-	bond->send_unsol_na = 0;
-	bond->setup_by_slave = 0;
-	INIT_LIST_HEAD(&bond->vlan_list);
+#ifdef CONFIG_PROC_FS
+	bond_create_proc_entry(bond);
+#endif
+	list_add_tail(&bond->bond_list, &bond_dev_list);
 
-	/* Initialize the device entry points */
-	bond_dev->netdev_ops = &bond_netdev_ops;
-	bond_dev->ethtool_ops = &bond_ethtool_ops;
-	bond_set_mode_ops(bond, bond->params.mode);
+	/* Can't create sysfs entries now since RTNL held. */
+	INIT_WORK(&bond->sysfs_work, bond_sysfs_init);
+	schedule_work(&bond->sysfs_work);
 
-	bond_dev->destructor = bond_destructor;
+	return 0;
+}
 
-	/* Initialize the device options */
-	bond_dev->tx_queue_len = 0;
-	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
-	bond_dev->priv_flags |= IFF_BONDING;
-	if (bond->params.arp_interval)
-		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
+static void bond_sysfs_uninit(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding, sysfs_work);
+	bond_destroy_sysfs_entry(bond);
+	dev_put(bond->dev);
+}
 
-	/* At first, we block adding VLANs. That's the only way to
-	 * prevent problems that occur when adding VLANs over an
-	 * empty bond. The block will be removed once non-challenged
-	 * slaves are enslaved.
-	 */
-	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+static void bond_uninit(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
 
-	/* don't acquire bond device's netif_tx_lock when
-	 * transmitting */
-	bond_dev->features |= NETIF_F_LLTX;
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
 
-	/* By default, we declare the bond to be fully
-	 * VLAN hardware accelerated capable. Special
-	 * care is taken in the various xmit functions
-	 * when there are slaves that are not hw accel
-	 * capable
-	 */
-	bond_dev->features |= (NETIF_F_HW_VLAN_TX |
-			       NETIF_F_HW_VLAN_RX |
-			       NETIF_F_HW_VLAN_FILTER);
+	netif_addr_lock_bh(bond_dev);
+	bond_mc_list_destroy(bond);
+	netif_addr_unlock_bh(bond_dev);
 
-#ifdef CONFIG_PROC_FS
-	bond_create_proc_entry(bond);
-#endif
-	list_add_tail(&bond->bond_list, &bond_dev_list);
+	dev_hold(bond_dev);
+	INIT_WORK(&bond->sysfs_work, bond_sysfs_uninit);
+	schedule_work(&bond->sysfs_work);
 
-	return 0;
+	bond_deinit(bond->dev);
 }
 
+static const struct net_device_ops bond_netdev_ops = {
+	.ndo_open		= bond_open,
+	.ndo_stop		= bond_close,
+	.ndo_init		= bond_init,
+	.ndo_uninit		= bond_uninit,
+	.ndo_start_xmit		= bond_start_xmit,
+	.ndo_get_stats		= bond_get_stats,
+	.ndo_do_ioctl		= bond_do_ioctl,
+	.ndo_set_multicast_list	= bond_set_multicast_list,
+	.ndo_change_mtu		= bond_change_mtu,
+	.ndo_set_mac_address 	= bond_set_mac_address,
+	.ndo_neigh_setup	= bond_neigh_setup,
+	.ndo_vlan_rx_register	= bond_vlan_rx_register,
+	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
+};
+
+
 static void bond_work_cancel_all(struct bonding *bond)
 {
 	write_lock_bh(&bond->lock);
@@ -4689,7 +4644,7 @@ static void bond_free_all(void)
 		bond_work_cancel_all(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_destroy(bond);
+		unregister_netdevice(bond->dev);
 	}
 
 #ifdef CONFIG_PROC_FS
@@ -5094,6 +5049,57 @@ static void bond_set_lockdep_class(struc
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 }
 
+/* Initialize bonding device structure */
+void bond_setup(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	rwlock_init(&bond->lock);
+	rwlock_init(&bond->curr_slave_lock);
+
+	INIT_LIST_HEAD(&bond->vlan_list);
+
+	/* Initialize the device entry points */
+	ether_setup(bond_dev);
+	bond_dev->netdev_ops = &bond_netdev_ops;
+	bond_dev->ethtool_ops = &bond_ethtool_ops;
+	bond_dev->destructor = free_netdev;
+
+	bond_dev->tx_queue_len = 0;
+	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
+	bond_dev->priv_flags |= IFF_BONDING;
+	if (bond->params.arp_interval)
+		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
+
+	/* At first, we block adding VLANs. That's the only way to
+	 * prevent problems that occur when adding VLANs over an
+	 * empty bond. The block will be removed once non-challenged
+	 * slaves are enslaved.
+	 */
+	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+
+	/* don't acquire bond device's netif_tx_lock when
+	 * transmitting */
+	bond_dev->features |= NETIF_F_LLTX;
+
+	/* By default, we declare the bond to be fully
+	 * VLAN hardware accelerated capable. Special
+	 * care is taken in the various xmit functions
+	 * when there are slaves that are not hw accel
+	 * capable
+	 */
+	bond_dev->features |= (NETIF_F_HW_VLAN_TX |
+			       NETIF_F_HW_VLAN_RX |
+			       NETIF_F_HW_VLAN_FILTER);
+
+	netif_carrier_off(bond_dev);
+	bond_set_lockdep_class(bond_dev);
+
+	/* Bonding specific parameters */
+	bond->params = bonding_defaults;
+	bond_set_mode_ops(bond, bond->params.mode);
+}
+
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5121,7 +5127,7 @@ int bond_create(const char *name)
 	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				ether_setup);
+				bond_setup);
 	if (!bond_dev) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: eek! can't alloc netdev!\n",
@@ -5136,37 +5142,17 @@ int bond_create(const char *name)
 			goto out_netdev;
 	}
 
-	/* bond_init() must be called after dev_alloc_name() (for the
-	 * /proc files), but before register_netdevice(), because we
-	 * need to set function pointers.
-	 */
-
-	res = bond_init(bond_dev, &bonding_defaults);
-	if (res < 0) {
-		goto out_netdev;
-	}
 
 	res = register_netdevice(bond_dev);
 	if (res < 0) {
 		goto out_bond;
 	}
 
-	bond_set_lockdep_class(bond_dev);
-
-	netif_carrier_off(bond_dev);
-
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
-	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
-	if (res < 0)
-		goto out_unreg;
 
 	return 0;
 
-out_unreg:
-	rtnl_lock();
-	down_write(&bonding_rwsem);
-	unregister_netdevice(bond_dev);
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-10 09:22:20.236043038 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-10 09:30:59.199039671 -0700
@@ -141,7 +141,7 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_destroy(bond);
+				unregister_netdevice(bond->dev);
 				goto out_unlock;
 			}
 
--- a/drivers/net/bonding/bonding.h	2009-06-10 09:21:04.103501875 -0700
+++ b/drivers/net/bonding/bonding.h	2009-06-10 09:28:46.055286284 -0700
@@ -215,6 +215,7 @@ struct bonding {
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
 	struct   workqueue_struct *wq;
+	struct   work_struct  sysfs_work;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
@@ -323,7 +324,7 @@ static inline void bond_unset_master_alb
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(const char *name);
-void bond_destroy(struct bonding *bond);
+
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);

-- 

