From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/33] bonding: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:19 -0800
Message-ID: <20081117234355.801893533@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55066 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbYKRAAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:08 -0500
Content-Disposition: inline; filename=bonding-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops table. 
Note: for some operations move error checking into generic networking
layer (rather than looking at pointers in bonding).

A couple of gratituous style cleanups to get rid of extra {}

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>



--- a/drivers/net/bonding/bond_alb.c	2008-11-17 13:02:53.000000000 -0800
+++ b/drivers/net/bonding/bond_alb.c	2008-11-17 13:02:59.000000000 -0800
@@ -1218,11 +1218,6 @@ static int alb_set_mac_address(struct bo
 	}
 
 	bond_for_each_slave(bond, slave, i) {
-		if (slave->dev->set_mac_address == NULL) {
-			res = -EOPNOTSUPP;
-			goto unwind;
-		}
-
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
@@ -1231,9 +1226,8 @@ static int alb_set_mac_address(struct bo
 		/* restore net_device's hw address */
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
 
-		if (res) {
+		if (res)
 			goto unwind;
-		}
 	}
 
 	return 0;
--- a/drivers/net/bonding/bond_main.c	2008-11-17 13:02:53.000000000 -0800
+++ b/drivers/net/bonding/bond_main.c	2008-11-17 13:02:59.000000000 -0800
@@ -462,10 +462,11 @@ static void bond_vlan_rx_register(struct
 
 	bond_for_each_slave(bond, slave, i) {
 		struct net_device *slave_dev = slave->dev;
+		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
 		if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-		    slave_dev->vlan_rx_register) {
-			slave_dev->vlan_rx_register(slave_dev, grp);
+		    slave_ops->vlan_rx_register) {
+			slave_ops->vlan_rx_register(slave_dev, grp);
 		}
 	}
 }
@@ -483,10 +484,11 @@ static void bond_vlan_rx_add_vid(struct 
 
 	bond_for_each_slave(bond, slave, i) {
 		struct net_device *slave_dev = slave->dev;
+		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
 		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-		    slave_dev->vlan_rx_add_vid) {
-			slave_dev->vlan_rx_add_vid(slave_dev, vid);
+		    slave_ops->vlan_rx_add_vid) {
+			slave_ops->vlan_rx_add_vid(slave_dev, vid);
 		}
 	}
 
@@ -512,14 +514,15 @@ static void bond_vlan_rx_kill_vid(struct
 
 	bond_for_each_slave(bond, slave, i) {
 		struct net_device *slave_dev = slave->dev;
+		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
 		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-		    slave_dev->vlan_rx_kill_vid) {
+		    slave_ops->vlan_rx_kill_vid) {
 			/* Save and then restore vlan_dev in the grp array,
 			 * since the slave's driver might clear it.
 			 */
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vid);
-			slave_dev->vlan_rx_kill_vid(slave_dev, vid);
+			slave_ops->vlan_rx_kill_vid(slave_dev, vid);
 			vlan_group_set_device(bond->vlgrp, vid, vlan_dev);
 		}
 	}
@@ -535,26 +538,23 @@ static void bond_vlan_rx_kill_vid(struct
 static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
 {
 	struct vlan_entry *vlan;
+	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
 	write_lock_bh(&bond->lock);
 
-	if (list_empty(&bond->vlan_list)) {
+	if (list_empty(&bond->vlan_list))
 		goto out;
-	}
 
 	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    slave_dev->vlan_rx_register) {
-		slave_dev->vlan_rx_register(slave_dev, bond->vlgrp);
-	}
+	    slave_ops->vlan_rx_register)
+		slave_ops->vlan_rx_register(slave_dev, bond->vlgrp);
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
-	    !(slave_dev->vlan_rx_add_vid)) {
+	    !(slave_ops->vlan_rx_add_vid))
 		goto out;
-	}
 
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		slave_dev->vlan_rx_add_vid(slave_dev, vlan->vlan_id);
-	}
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list)
+		slave_ops->vlan_rx_add_vid(slave_dev, vlan->vlan_id);
 
 out:
 	write_unlock_bh(&bond->lock);
@@ -562,34 +562,32 @@ out:
 
 static void bond_del_vlans_from_slave(struct bonding *bond, struct net_device *slave_dev)
 {
+	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 
 	write_lock_bh(&bond->lock);
 
-	if (list_empty(&bond->vlan_list)) {
+	if (list_empty(&bond->vlan_list))
 		goto out;
-	}
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
-	    !(slave_dev->vlan_rx_kill_vid)) {
+	    !(slave_ops->vlan_rx_kill_vid))
 		goto unreg;
-	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		/* Save and then restore vlan_dev in the grp array,
 		 * since the slave's driver might clear it.
 		 */
 		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
-		slave_dev->vlan_rx_kill_vid(slave_dev, vlan->vlan_id);
+		slave_ops->vlan_rx_kill_vid(slave_dev, vlan->vlan_id);
 		vlan_group_set_device(bond->vlgrp, vlan->vlan_id, vlan_dev);
 	}
 
 unreg:
 	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    slave_dev->vlan_rx_register) {
-		slave_dev->vlan_rx_register(slave_dev, NULL);
-	}
+	    slave_ops->vlan_rx_register)
+		slave_ops->vlan_rx_register(slave_dev, NULL);
 
 out:
 	write_unlock_bh(&bond->lock);
@@ -698,15 +696,15 @@ static int bond_update_speed_duplex(stru
  */
 static int bond_check_dev_link(struct bonding *bond, struct net_device *slave_dev, int reporting)
 {
+	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	static int (* ioctl)(struct net_device *, struct ifreq *, int);
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 
-	if (bond->params.use_carrier) {
+	if (bond->params.use_carrier)
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
-	}
 
-	ioctl = slave_dev->do_ioctl;
+	ioctl = slave_ops->do_ioctl;
 	if (ioctl) {
 		/* TODO: set pointer to correct ioctl on a per team member */
 		/*       bases to make this more efficient. that is, once  */
@@ -1401,6 +1398,7 @@ static void bond_setup_by_slave(struct n
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct slave *new_slave = NULL;
 	struct dev_mc_list *dmi;
 	struct sockaddr addr;
@@ -1409,7 +1407,7 @@ int bond_enslave(struct net_device *bond
 	int res = 0;
 
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
-		slave_dev->do_ioctl == NULL) {
+		slave_ops->do_ioctl == NULL) {
 		printk(KERN_WARNING DRV_NAME
 		       ": %s: Warning: no link monitoring support for %s\n",
 		       bond_dev->name, slave_dev->name);
@@ -1491,7 +1489,7 @@ int bond_enslave(struct net_device *bond
 			goto err_undo_flags;
 	}
 
-	if (slave_dev->set_mac_address == NULL) {
+	if (slave_ops->set_mac_address == NULL) {
 		if (bond->slave_cnt == 0) {
 			printk(KERN_WARNING DRV_NAME
 			       ": %s: Warning: The first slave device "
@@ -4208,6 +4206,10 @@ static int bond_set_mac_address(struct n
 	int res = 0;
 	int i;
 
+	if (bond->params.mode == BOND_MODE_ALB)
+		return bond_alb_set_mac_address(bond_dev, addr);
+
+
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
 	/*
@@ -4237,9 +4239,10 @@ static int bond_set_mac_address(struct n
 	 */
 
 	bond_for_each_slave(bond, slave, i) {
+		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
 		dprintk("slave %p %s\n", slave, slave->dev->name);
 
-		if (slave->dev->set_mac_address == NULL) {
+		if (slave_ops->set_mac_address == NULL) {
 			res = -EOPNOTSUPP;
 			dprintk("EOPNOTSUPP %s\n", slave->dev->name);
 			goto unwind;
@@ -4517,7 +4520,6 @@ void bond_set_mode_ops(struct bonding *b
 		/* FALLTHRU */
 	case BOND_MODE_TLB:
 		bond_dev->hard_start_xmit = bond_alb_xmit;
-		bond_dev->set_mac_address = bond_alb_set_mac_address;
 		break;
 	default:
 		/* Should never happen, mode already checked */
@@ -4547,6 +4549,20 @@ static const struct ethtool_ops bond_eth
 	.get_flags		= ethtool_op_get_flags,
 };
 
+static const struct net_device_ops bond_netdev_ops = {
+	.open			= bond_open,
+	.stop			= bond_close,
+	.get_stats		= bond_get_stats,
+	.do_ioctl		= bond_do_ioctl,
+	.set_multicast_list	= bond_set_multicast_list,
+	.change_mtu		= bond_change_mtu,
+	.validate_addr		= NULL,
+	.set_mac_address 	= bond_set_mac_address,
+	.vlan_rx_register	= bond_vlan_rx_register,
+	.vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
+	.vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
+};
+
 /*
  * Does not allocate but creates a /proc entry.
  * Allowed to fail.
@@ -4579,16 +4595,8 @@ static int bond_init(struct net_device *
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
-	bond_dev->open = bond_open;
-	bond_dev->stop = bond_close;
-	bond_dev->get_stats = bond_get_stats;
-	bond_dev->do_ioctl = bond_do_ioctl;
+	bond_dev->netdev_ops = &bond_netdev_ops;
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
-	bond_dev->set_multicast_list = bond_set_multicast_list;
-	bond_dev->change_mtu = bond_change_mtu;
-	bond_dev->set_mac_address = bond_set_mac_address;
-	bond_dev->validate_addr = NULL;
-
 	bond_set_mode_ops(bond, bond->params.mode);
 
 	bond_dev->destructor = bond_destructor;
@@ -4617,9 +4625,6 @@ static int bond_init(struct net_device *
 	 * when there are slaves that are not hw accel
 	 * capable
 	 */
-	bond_dev->vlan_rx_register = bond_vlan_rx_register;
-	bond_dev->vlan_rx_add_vid  = bond_vlan_rx_add_vid;
-	bond_dev->vlan_rx_kill_vid = bond_vlan_rx_kill_vid;
 	bond_dev->features |= (NETIF_F_HW_VLAN_TX |
 			       NETIF_F_HW_VLAN_RX |
 			       NETIF_F_HW_VLAN_FILTER);
--- a/drivers/net/bonding/bond_sysfs.c	2008-11-17 13:02:53.000000000 -0800
+++ b/drivers/net/bonding/bond_sysfs.c	2008-11-17 13:04:05.000000000 -0800
@@ -317,18 +317,12 @@ static ssize_t bonding_store_slaves(stru
 
 		/* Set the slave's MTU to match the bond */
 		original_mtu = dev->mtu;
-		if (dev->mtu != bond->dev->mtu) {
-			if (dev->change_mtu) {
-				res = dev->change_mtu(dev,
-						      bond->dev->mtu);
-				if (res) {
-					ret = res;
-					goto out;
-				}
-			} else {
-				dev->mtu = bond->dev->mtu;
-			}
+		res = dev_set_mtu(dev, bond->dev->mtu);
+		if (res) {
+			ret = res;
+			goto out;
 		}
+
 		res = bond_enslave(bond->dev, dev);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
@@ -357,11 +351,7 @@ static ssize_t bonding_store_slaves(stru
 				goto out;
 			}
 			/* set the slave MTU to the default */
-			if (dev->change_mtu) {
-				dev->change_mtu(dev, original_mtu);
-			} else {
-				dev->mtu = original_mtu;
-			}
+			dev_set_mtu(dev, original_mtu);
 		}
 		else {
 			printk(KERN_ERR DRV_NAME ": unable to remove non-existent slave %s for bond %s.\n",

-- 

