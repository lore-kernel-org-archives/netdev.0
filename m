From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 01/12] bonding: convert bond_main.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:35:58 +0200
Message-ID: <1405445769-15394-2-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557AbaGORkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:37 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converted only the parts where we've had a valid net_device, skipping the
init/deinit and options verification.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c | 342 +++++++++++++++++++---------------------
 1 file changed, 162 insertions(+), 180 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e0a33b5..b1a7a5c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -629,8 +629,8 @@ static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 static void bond_set_dev_addr(struct net_device *bond_dev,
 			      struct net_device *slave_dev)
 {
-	pr_debug("bond_dev=%p slave_dev=%p slave_dev->addr_len=%d\n",
-		 bond_dev, slave_dev, slave_dev->addr_len);
+	netdev_dbg(bond_dev, "bond_dev=%p slave_dev=%p slave_dev->addr_len=%d\n",
+		   bond_dev, slave_dev, slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
 	bond_dev->addr_assign_type = NET_ADDR_STOLEN;
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
@@ -684,8 +684,8 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 		rv = dev_set_mac_address(new_active->dev, &saddr);
 		if (rv) {
-			pr_err("%s: Error %d setting MAC of slave %s\n",
-			       bond->dev->name, -rv, new_active->dev->name);
+			netdev_err(bond->dev, "Error %d setting MAC of slave %s\n",
+				   -rv, new_active->dev->name);
 			goto out;
 		}
 
@@ -697,14 +697,14 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 		rv = dev_set_mac_address(old_active->dev, &saddr);
 		if (rv)
-			pr_err("%s: Error %d setting MAC of slave %s\n",
-			       bond->dev->name, -rv, new_active->dev->name);
+			netdev_err(bond->dev, "Error %d setting MAC of slave %s\n",
+				   -rv, new_active->dev->name);
 out:
 		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
-		pr_err("%s: bond_do_fail_over_mac impossible: bad policy %d\n",
-		       bond->dev->name, bond->params.fail_over_mac);
+		netdev_err(bond->dev, "bond_do_fail_over_mac impossible: bad policy %d\n",
+			   bond->params.fail_over_mac);
 		break;
 	}
 
@@ -765,8 +765,8 @@ static bool bond_should_notify_peers(struct bonding *bond)
 	slave = rcu_dereference(bond->curr_active_slave);
 	rcu_read_unlock();
 
-	pr_debug("bond_should_notify_peers: bond %s slave %s\n",
-		 bond->dev->name, slave ? slave->dev->name : "NULL");
+	netdev_dbg(bond->dev, "bond_should_notify_peers: slave %s\n",
+		   slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_peer_notif ||
 	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
@@ -802,9 +802,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 		if (new_active->link == BOND_LINK_BACK) {
 			if (bond_uses_primary(bond)) {
-				pr_info("%s: making interface %s the new active one %d ms earlier\n",
-					bond->dev->name, new_active->dev->name,
-					(bond->params.updelay - new_active->delay) * bond->params.miimon);
+				netdev_info(bond->dev, "making interface %s the new active one %d ms earlier\n",
+					    new_active->dev->name,
+					    (bond->params.updelay - new_active->delay) * bond->params.miimon);
 			}
 
 			new_active->delay = 0;
@@ -817,8 +817,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
 			if (bond_uses_primary(bond)) {
-				pr_info("%s: making interface %s the new active one\n",
-					bond->dev->name, new_active->dev->name);
+				netdev_info(bond->dev, "making interface %s the new active one\n",
+					    new_active->dev->name);
 			}
 		}
 	}
@@ -907,11 +907,9 @@ void bond_select_active_slave(struct bonding *bond)
 			return;
 
 		if (netif_carrier_ok(bond->dev)) {
-			pr_info("%s: first active interface up!\n",
-				bond->dev->name);
+			netdev_info(bond->dev, "first active interface up!\n");
 		} else {
-			pr_info("%s: now running without any active interface!\n",
-				bond->dev->name);
+			netdev_info(bond->dev, "now running without any active interface!\n");
 		}
 	}
 }
@@ -1208,36 +1206,38 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (!bond->params.use_carrier &&
 	    slave_dev->ethtool_ops->get_link == NULL &&
 	    slave_ops->ndo_do_ioctl == NULL) {
-		pr_warn("%s: Warning: no link monitoring support for %s\n",
-			bond_dev->name, slave_dev->name);
+		netdev_warn(bond_dev, "no link monitoring support for %s\n",
+			    slave_dev->name);
 	}
 
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
-		pr_debug("Error: Device was already enslaved\n");
+		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
 		return -EBUSY;
 	}
 
 	if (bond_dev == slave_dev) {
-		pr_err("%s: cannot enslave bond to itself.\n", bond_dev->name);
+		netdev_err(bond_dev, "cannot enslave bond to itself.\n");
 		return -EPERM;
 	}
 
 	/* vlan challenged mutual exclusion */
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
-		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		netdev_dbg(bond_dev, "%s is NETIF_F_VLAN_CHALLENGED\n",
+			   slave_dev->name);
 		if (vlan_uses_dev(bond_dev)) {
-			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
-			       bond_dev->name, slave_dev->name, bond_dev->name);
+			netdev_err(bond_dev, "Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
+				   slave_dev->name, bond_dev->name);
 			return -EPERM;
 		} else {
-			pr_warn("%s: Warning: enslaved VLAN challenged slave %s. Adding VLANs will be blocked as long as %s is part of bond %s\n",
-				bond_dev->name, slave_dev->name,
-				slave_dev->name, bond_dev->name);
+			netdev_warn(bond_dev, "enslaved VLAN challenged slave %s. Adding VLANs will be blocked as long as %s is part of bond %s\n",
+				    slave_dev->name, slave_dev->name,
+				    bond_dev->name);
 		}
 	} else {
-		pr_debug("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		netdev_dbg(bond_dev, "%s is !NETIF_F_VLAN_CHALLENGED\n",
+			   slave_dev->name);
 	}
 
 	/*
@@ -1247,8 +1247,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * enslaving it; the old ifenslave will not.
 	 */
 	if ((slave_dev->flags & IFF_UP)) {
-		pr_err("%s is up - this may be due to an out of date ifenslave\n",
-		       slave_dev->name);
+		netdev_err(bond_dev, "%s is up - this may be due to an out of date ifenslave\n",
+			   slave_dev->name);
 		res = -EPERM;
 		goto err_undo_flags;
 	}
@@ -1262,16 +1262,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	if (!bond_has_slaves(bond)) {
 		if (bond_dev->type != slave_dev->type) {
-			pr_debug("%s: change device type from %d to %d\n",
-				 bond_dev->name,
-				 bond_dev->type, slave_dev->type);
+			netdev_dbg(bond_dev, "change device type from %d to %d\n",
+				   bond_dev->type, slave_dev->type);
 
 			res = call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE,
 						       bond_dev);
 			res = notifier_to_errno(res);
 			if (res) {
-				pr_err("%s: refused to change device type\n",
-				       bond_dev->name);
+				netdev_err(bond_dev, "refused to change device type\n");
 				res = -EBUSY;
 				goto err_undo_flags;
 			}
@@ -1291,24 +1289,21 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 						 bond_dev);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
-		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it\n",
-		       slave_dev->name, slave_dev->type, bond_dev->type);
+		netdev_err(bond_dev, "%s ether type (%d) is different from other slaves (%d), can not enslave it\n",
+			   slave_dev->name, slave_dev->type, bond_dev->type);
 		res = -EINVAL;
 		goto err_undo_flags;
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
-		pr_warn("%s: Warning: The slave device specified does not support setting the MAC address\n",
-			bond_dev->name);
+		netdev_warn(bond_dev, "The slave device specified does not support setting the MAC address\n");
 		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
 		    bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			if (!bond_has_slaves(bond)) {
 				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
-				pr_warn("%s: Setting fail_over_mac to active for active-backup mode\n",
-					bond_dev->name);
+				netdev_warn(bond_dev, "Setting fail_over_mac to active for active-backup mode\n");
 			} else {
-				pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
-				       bond_dev->name);
+				netdev_err(bond_dev, "The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n");
 				res = -EOPNOTSUPP;
 				goto err_undo_flags;
 			}
@@ -1341,7 +1336,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	new_slave->original_mtu = slave_dev->mtu;
 	res = dev_set_mtu(slave_dev, bond->dev->mtu);
 	if (res) {
-		pr_debug("Error %d calling dev_set_mtu\n", res);
+		netdev_dbg(bond_dev, "Error %d calling dev_set_mtu\n", res);
 		goto err_free;
 	}
 
@@ -1362,7 +1357,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		addr.sa_family = slave_dev->type;
 		res = dev_set_mac_address(slave_dev, &addr);
 		if (res) {
-			pr_debug("Error %d calling set_mac_address\n", res);
+			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
 			goto err_restore_mtu;
 		}
 	}
@@ -1370,7 +1365,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
-		pr_debug("Opening slave %s failed\n", slave_dev->name);
+		netdev_dbg(bond_dev, "Opening slave %s failed\n", slave_dev->name);
 		goto err_restore_mac;
 	}
 
@@ -1420,8 +1415,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	res = vlan_vids_add_by_dev(slave_dev, bond_dev);
 	if (res) {
-		pr_err("%s: Error: Couldn't add bond vlan ids to %s\n",
-		       bond_dev->name, slave_dev->name);
+		netdev_err(bond_dev, "Couldn't add bond vlan ids to %s\n",
+			   slave_dev->name);
 		goto err_close;
 	}
 
@@ -1450,12 +1445,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			 * supported); thus, we don't need to change
 			 * the messages for netif_carrier.
 			 */
-			pr_warn("%s: Warning: MII and ETHTOOL support not available for interface %s, and arp_interval/arp_ip_target module parameters not specified, thus bonding will not detect link failures! see bonding.txt for details\n",
-				bond_dev->name, slave_dev->name);
+			netdev_warn(bond_dev, "MII and ETHTOOL support not available for interface %s, and arp_interval/arp_ip_target module parameters not specified, thus bonding will not detect link failures! see bonding.txt for details\n",
+				    slave_dev->name);
 		} else if (link_reporting == -1) {
 			/* unable get link status using mii/ethtool */
-			pr_warn("%s: Warning: can't get link status from interface %s; the network driver associated with this interface does not support MII or ETHTOOL link status reporting, thus miimon has no effect on this interface\n",
-				bond_dev->name, slave_dev->name);
+			netdev_warn(bond_dev, "can't get link status from interface %s; the network driver associated with this interface does not support MII or ETHTOOL link status reporting, thus miimon has no effect on this interface\n",
+				    slave_dev->name);
 		}
 	}
 
@@ -1480,9 +1475,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (new_slave->link != BOND_LINK_DOWN)
 		new_slave->last_link_up = jiffies;
-	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
-		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
-		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
+	netdev_dbg(bond_dev, "Initial state of slave_dev is BOND_LINK_%s\n",
+		   new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+		   (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
 	if (bond_uses_primary(bond) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
@@ -1523,7 +1518,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_set_slave_inactive_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
 		break;
 	default:
-		pr_debug("This slave is always active in trunk mode\n");
+		netdev_dbg(bond_dev, "This slave is always active in trunk mode\n");
 
 		/* always active in trunk mode */
 		bond_set_active_slave(new_slave);
@@ -1542,8 +1537,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	slave_dev->npinfo = bond->dev->npinfo;
 	if (slave_dev->npinfo) {
 		if (slave_enable_netpoll(new_slave)) {
-			pr_info("Error, %s: master_dev is using netpoll, but new slave device does not support netpoll\n",
-				bond_dev->name);
+			netdev_info(bond_dev, "master_dev is using netpoll, but new slave device does not support netpoll\n");
 			res = -EBUSY;
 			goto err_detach;
 		}
@@ -1553,19 +1547,19 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
 					 new_slave);
 	if (res) {
-		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
+		netdev_dbg(bond_dev, "Error %d calling netdev_rx_handler_register\n", res);
 		goto err_detach;
 	}
 
 	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
 	if (res) {
-		pr_debug("Error %d calling bond_master_upper_dev_link\n", res);
+		netdev_dbg(bond_dev, "Error %d calling bond_master_upper_dev_link\n", res);
 		goto err_unregister;
 	}
 
 	res = bond_sysfs_slave_add(new_slave);
 	if (res) {
-		pr_debug("Error %d calling bond_sysfs_slave_add\n", res);
+		netdev_dbg(bond_dev, "Error %d calling bond_sysfs_slave_add\n", res);
 		goto err_upper_unlink;
 	}
 
@@ -1581,10 +1575,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		unblock_netpoll_tx();
 	}
 
-	pr_info("%s: Enslaving %s as %s interface with %s link\n",
-		bond_dev->name, slave_dev->name,
-		bond_is_active_slave(new_slave) ? "an active" : "a backup",
-		new_slave->link != BOND_LINK_DOWN ? "an up" : "a down");
+	netdev_info(bond_dev, "Enslaving %s as %s interface with %s link\n",
+		    slave_dev->name,
+		    bond_is_active_slave(new_slave) ? "an active" : "a backup",
+		    new_slave->link != BOND_LINK_DOWN ? "an up" : "a down");
 
 	/* enslave is successful */
 	return 0;
@@ -1669,8 +1663,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    !netdev_has_upper_dev(slave_dev, bond_dev)) {
-		pr_err("%s: Error: cannot release %s\n",
-		       bond_dev->name, slave_dev->name);
+		netdev_err(bond_dev, "cannot release %s\n",
+			   slave_dev->name);
 		return -EINVAL;
 	}
 
@@ -1679,8 +1673,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	slave = bond_get_slave_by_dev(bond, slave_dev);
 	if (!slave) {
 		/* not a slave of this bond */
-		pr_info("%s: %s not enslaved\n",
-			bond_dev->name, slave_dev->name);
+		netdev_info(bond_dev, "%s not enslaved\n",
+			    slave_dev->name);
 		unblock_netpoll_tx();
 		return -EINVAL;
 	}
@@ -1700,10 +1694,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	write_unlock_bh(&bond->lock);
 
-	pr_info("%s: Releasing %s interface %s\n",
-		bond_dev->name,
-		bond_is_active_slave(slave) ? "active" : "backup",
-		slave_dev->name);
+	netdev_info(bond_dev, "Releasing %s interface %s\n",
+		    bond_is_active_slave(slave) ? "active" : "backup",
+		    slave_dev->name);
 
 	oldcurrent = bond->curr_active_slave;
 
@@ -1713,10 +1706,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 		     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond_has_slaves(bond))
-			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
-				bond_dev->name, slave_dev->name,
-				slave->perm_hwaddr,
-				bond_dev->name, slave_dev->name);
+			netdev_warn(bond_dev, "the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
+				    slave_dev->name, slave->perm_hwaddr,
+				    bond_dev->name, slave_dev->name);
 	}
 
 	if (bond->primary_slave == slave)
@@ -1769,8 +1761,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	bond_compute_features(bond);
 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
 	    (old_features & NETIF_F_VLAN_CHALLENGED))
-		pr_info("%s: last VLAN challenged slave %s left bond %s - VLAN blocking is removed\n",
-			bond_dev->name, slave_dev->name, bond_dev->name);
+		netdev_info(bond_dev, "last VLAN challenged slave %s left bond %s - VLAN blocking is removed\n",
+			    slave_dev->name, bond_dev->name);
 
 	/* must do this from outside any spinlocks */
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
@@ -1837,8 +1829,8 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	ret = bond_release(bond_dev, slave_dev);
 	if (ret == 0 && !bond_has_slaves(bond)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		pr_info("%s: Destroying bond %s\n",
-			bond_dev->name, bond_dev->name);
+		netdev_info(bond_dev, "Destroying bond %s\n",
+			    bond_dev->name);
 		unregister_netdevice(bond_dev);
 	}
 	return ret;
@@ -1902,14 +1894,13 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
-				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms\n",
-					bond->dev->name,
-					(BOND_MODE(bond) ==
-					 BOND_MODE_ACTIVEBACKUP) ?
-					(bond_is_active_slave(slave) ?
-					 "active " : "backup ") : "",
-					slave->dev->name,
-					bond->params.downdelay * bond->params.miimon);
+				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
+					    (BOND_MODE(bond) ==
+					     BOND_MODE_ACTIVEBACKUP) ?
+					     (bond_is_active_slave(slave) ?
+					      "active " : "backup ") : "",
+					    slave->dev->name,
+					    bond->params.downdelay * bond->params.miimon);
 			}
 			/*FALLTHRU*/
 		case BOND_LINK_FAIL:
@@ -1919,11 +1910,10 @@ static int bond_miimon_inspect(struct bonding *bond)
 				 */
 				slave->link = BOND_LINK_UP;
 				slave->last_link_up = jiffies;
-				pr_info("%s: link status up again after %d ms for interface %s\n",
-					bond->dev->name,
-					(bond->params.downdelay - slave->delay) *
-					bond->params.miimon,
-					slave->dev->name);
+				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
+					    (bond->params.downdelay - slave->delay) *
+					    bond->params.miimon,
+					    slave->dev->name);
 				continue;
 			}
 
@@ -1944,21 +1934,20 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
-				pr_info("%s: link status up for interface %s, enabling it in %d ms\n",
-					bond->dev->name, slave->dev->name,
-					ignore_updelay ? 0 :
-					bond->params.updelay *
-					bond->params.miimon);
+				netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
+					    slave->dev->name,
+					    ignore_updelay ? 0 :
+					    bond->params.updelay *
+					    bond->params.miimon);
 			}
 			/*FALLTHRU*/
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				slave->link = BOND_LINK_DOWN;
-				pr_info("%s: link status down again after %d ms for interface %s\n",
-					bond->dev->name,
-					(bond->params.updelay - slave->delay) *
-					bond->params.miimon,
-					slave->dev->name);
+				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
+					    (bond->params.updelay - slave->delay) *
+					    bond->params.miimon,
+					    slave->dev->name);
 
 				continue;
 			}
@@ -2006,10 +1995,10 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_set_backup_slave(slave);
 			}
 
-			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex\n",
-				bond->dev->name, slave->dev->name,
-				slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
-				slave->duplex ? "full" : "half");
+			netdev_info(bond->dev, "link status definitely up for interface %s, %u Mbps %s duplex\n",
+				    slave->dev->name,
+				    slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
+				    slave->duplex ? "full" : "half");
 
 			/* notify ad that the link status has changed */
 			if (BOND_MODE(bond) == BOND_MODE_8023AD)
@@ -2036,8 +2025,8 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
 
-			pr_info("%s: link status definitely down for interface %s, disabling it\n",
-				bond->dev->name, slave->dev->name);
+			netdev_info(bond->dev, "link status definitely down for interface %s, disabling it\n",
+				    slave->dev->name);
 
 			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave,
@@ -2053,9 +2042,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		default:
-			pr_err("%s: invalid new link %d on slave %s\n",
-			       bond->dev->name, slave->new_link,
-			       slave->dev->name);
+			netdev_err(bond->dev, "invalid new link %d on slave %s\n",
+				   slave->new_link, slave->dev->name);
 			slave->new_link = BOND_LINK_NOCHANGE;
 
 			continue;
@@ -2158,8 +2146,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 	struct sk_buff *skb;
 	int i;
 
-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
-		 arp_op, slave_dev->name, &dest_ip, &src_ip);
+	netdev_dbg(slave_dev, "arp %d on slave %s: dst %pI4 src %pI4\n",
+		   arp_op, slave_dev->name, &dest_ip, &src_ip);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
@@ -2174,8 +2162,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 		if (!tags[i].vlan_id)
 			continue;
 
-		pr_debug("inner tag: proto %X vid %X\n",
-			 ntohs(tags[i].vlan_proto), tags[i].vlan_id);
+		netdev_dbg(slave_dev, "inner tag: proto %X vid %X\n",
+			   ntohs(tags[i].vlan_proto), tags[i].vlan_id);
 		skb = __vlan_put_tag(skb, tags[i].vlan_proto,
 				     tags[i].vlan_id);
 		if (!skb) {
@@ -2185,8 +2173,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 	}
 	/* Set the outer tag */
 	if (tags[0].vlan_id) {
-		pr_debug("outer tag: proto %X vid %X\n",
-			 ntohs(tags[0].vlan_proto), tags[0].vlan_id);
+		netdev_dbg(slave_dev, "outer tag: proto %X vid %X\n",
+			   ntohs(tags[0].vlan_proto), tags[0].vlan_id);
 		skb = vlan_put_tag(skb, tags[0].vlan_proto, tags[0].vlan_id);
 		if (!skb) {
 			net_err_ratelimited("failed to insert outer VLAN tag\n");
@@ -2240,7 +2228,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	bool ret;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
-		pr_debug("basa: target %pI4\n", &targets[i]);
+		netdev_dbg(bond->dev, "basa: target %pI4\n", &targets[i]);
 		memset(tags, 0, sizeof(tags));
 
 		/* Find out through which dev should the packet go */
@@ -2271,9 +2259,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			goto found;
 
 		/* Not our device - skip */
-		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-			 bond->dev->name, &targets[i],
-			 rt->dst.dev ? rt->dst.dev->name : "NULL");
+		netdev_dbg(bond->dev, "no path to arp_ip_target %pI4 via rt.dev %s\n",
+			   &targets[i], rt->dst.dev ? rt->dst.dev->name : "NULL");
 
 		ip_rt_put(rt);
 		continue;
@@ -2291,13 +2278,15 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 	int i;
 
 	if (!sip || !bond_has_this_ip(bond, tip)) {
-		pr_debug("bva: sip %pI4 tip %pI4 not found\n", &sip, &tip);
+		netdev_dbg(bond->dev, "bva: sip %pI4 tip %pI4 not found\n",
+			   &sip, &tip);
 		return;
 	}
 
 	i = bond_get_targets_ip(bond->params.arp_targets, sip);
 	if (i == -1) {
-		pr_debug("bva: sip %pI4 not found in targets\n", &sip);
+		netdev_dbg(bond->dev, "bva: sip %pI4 not found in targets\n",
+			   &sip);
 		return;
 	}
 	slave->last_rx = jiffies;
@@ -2324,8 +2313,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 
 	alen = arp_hdr_len(bond->dev);
 
-	pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
-		 bond->dev->name, skb->dev->name);
+	netdev_dbg(bond->dev, "bond_arp_rcv: skb->dev %s\n",
+		   skb->dev->name);
 
 	if (alen > skb_headlen(skb)) {
 		arp = kmalloc(alen, GFP_ATOMIC);
@@ -2349,10 +2338,10 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	arp_ptr += 4 + bond->dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
 
-	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
-		 bond->dev->name, slave->dev->name, bond_slave_state(slave),
-		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
-		 &sip, &tip);
+	netdev_dbg(bond->dev, "bond_arp_rcv: %s/%d av %d sv %d sip %pI4 tip %pI4\n",
+		   slave->dev->name, bond_slave_state(slave),
+		     bond->params.arp_validate, slave_do_arp_validate(bond, slave),
+		     &sip, &tip);
 
 	curr_active_slave = rcu_dereference(bond->curr_active_slave);
 
@@ -2442,14 +2431,12 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 				 * is closed.
 				 */
 				if (!oldcurrent) {
-					pr_info("%s: link status definitely up for interface %s\n",
-						bond->dev->name,
-						slave->dev->name);
+					netdev_info(bond->dev, "link status definitely up for interface %s\n",
+						    slave->dev->name);
 					do_failover = 1;
 				} else {
-					pr_info("%s: interface %s is now up\n",
-						bond->dev->name,
-						slave->dev->name);
+					netdev_info(bond->dev, "interface %s is now up\n",
+						    slave->dev->name);
 				}
 			}
 		} else {
@@ -2468,8 +2455,8 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
 
-				pr_info("%s: interface %s is now down\n",
-					bond->dev->name, slave->dev->name);
+				netdev_info(bond->dev, "interface %s is now down\n",
+					    slave->dev->name);
 
 				if (slave == oldcurrent)
 					do_failover = 1;
@@ -2619,8 +2606,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 					bond->current_arp_slave = NULL;
 				}
 
-				pr_info("%s: link status definitely up for interface %s\n",
-					bond->dev->name, slave->dev->name);
+				netdev_info(bond->dev, "link status definitely up for interface %s\n",
+					    slave->dev->name);
 
 				if (!bond->curr_active_slave ||
 				    (slave == bond->primary_slave))
@@ -2638,8 +2625,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			bond_set_slave_inactive_flags(slave,
 						      BOND_SLAVE_NOTIFY_NOW);
 
-			pr_info("%s: link status definitely down for interface %s, disabling it\n",
-				bond->dev->name, slave->dev->name);
+			netdev_info(bond->dev, "link status definitely down for interface %s, disabling it\n",
+				    slave->dev->name);
 
 			if (slave == bond->curr_active_slave) {
 				bond->current_arp_slave = NULL;
@@ -2649,9 +2636,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			continue;
 
 		default:
-			pr_err("%s: impossible: new_link %d on slave %s\n",
-			       bond->dev->name, slave->new_link,
-			       slave->dev->name);
+			netdev_err(bond->dev, "impossible: new_link %d on slave %s\n",
+				   slave->new_link, slave->dev->name);
 			continue;
 		}
 
@@ -2682,9 +2668,9 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 
 	if (curr_arp_slave && curr_active_slave)
-		pr_info("PROBE: c_arp %s && cas %s BAD\n",
-			curr_arp_slave->dev->name,
-			curr_active_slave->dev->name);
+		netdev_info(bond->dev, "PROBE: c_arp %s && cas %s BAD\n",
+			    curr_arp_slave->dev->name,
+			    curr_active_slave->dev->name);
 
 	if (curr_active_slave) {
 		bond_arp_send_all(bond, curr_active_slave);
@@ -2725,8 +2711,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 			bond_set_slave_inactive_flags(slave,
 						      BOND_SLAVE_NOTIFY_LATER);
 
-			pr_info("%s: backup interface %s is now down\n",
-				bond->dev->name, slave->dev->name);
+			netdev_info(bond->dev, "backup interface %s is now down\n",
+				    slave->dev->name);
 		}
 		if (slave == curr_arp_slave)
 			found = true;
@@ -2922,9 +2908,8 @@ static int bond_slave_netdev_event(unsigned long event,
 			break;
 		}
 
-		pr_info("%s: Primary slave changed to %s, reselecting active slave\n",
-			bond->dev->name,
-			bond->primary_slave ? slave_dev->name : "none");
+		netdev_info(bond->dev, "Primary slave changed to %s, reselecting active slave\n",
+			    bond->primary_slave ? slave_dev->name : "none");
 
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
@@ -2959,19 +2944,18 @@ static int bond_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
-	pr_debug("event_dev: %s, event: %lx\n",
-		 event_dev ? event_dev->name : "None", event);
+	netdev_dbg(event_dev, "event: %lx\n", event);
 
 	if (!(event_dev->priv_flags & IFF_BONDING))
 		return NOTIFY_DONE;
 
 	if (event_dev->flags & IFF_MASTER) {
-		pr_debug("IFF_MASTER\n");
+		netdev_dbg(event_dev, "IFF_MASTER\n");
 		return bond_master_netdev_event(event, event_dev);
 	}
 
 	if (event_dev->flags & IFF_SLAVE) {
-		pr_debug("IFF_SLAVE\n");
+		netdev_dbg(event_dev, "IFF_SLAVE\n");
 		return bond_slave_netdev_event(event, event_dev);
 	}
 
@@ -3213,7 +3197,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	struct net *net;
 	int res = 0;
 
-	pr_debug("bond_ioctl: master=%s, cmd=%d\n", bond_dev->name, cmd);
+	netdev_dbg(bond_dev, "bond_ioctl: cmd=%d\n", cmd);
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -3283,12 +3267,12 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 	slave_dev = __dev_get_by_name(net, ifr->ifr_slave);
 
-	pr_debug("slave_dev=%p:\n", slave_dev);
+	netdev_dbg(bond_dev, "slave_dev=%p:\n", slave_dev);
 
 	if (!slave_dev)
 		return -ENODEV;
 
-	pr_debug("slave_dev->name=%s:\n", slave_dev->name);
+	netdev_dbg(bond_dev, "slave_dev->name=%s:\n", slave_dev->name);
 	switch (cmd) {
 	case BOND_ENSLAVE_OLD:
 	case SIOCBONDENSLAVE:
@@ -3415,8 +3399,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	struct list_head *iter;
 	int res = 0;
 
-	pr_debug("bond=%p, name=%s, new_mtu=%d\n",
-		 bond, bond_dev ? bond_dev->name : "None", new_mtu);
+	netdev_dbg(bond_dev, "bond=%p, new_mtu=%d\n", bond, new_mtu);
 
 	/* Can't hold bond->lock with bh disabled here since
 	 * some base drivers panic. On the other hand we can't
@@ -3434,8 +3417,8 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	 */
 
 	bond_for_each_slave(bond, slave, iter) {
-		pr_debug("s %p c_m %p\n",
-			 slave, slave->dev->netdev_ops->ndo_change_mtu);
+		netdev_dbg(bond_dev, "s %p c_m %p\n",
+			   slave, slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
 
@@ -3448,7 +3431,8 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 			 * means changing their mtu from timer context, which
 			 * is probably not a good idea.
 			 */
-			pr_debug("err %d %s\n", res, slave->dev->name);
+			netdev_dbg(bond_dev, "err %d %s\n", res,
+				   slave->dev->name);
 			goto unwind;
 		}
 	}
@@ -3467,8 +3451,8 @@ unwind:
 
 		tmp_res = dev_set_mtu(rollback_slave->dev, bond_dev->mtu);
 		if (tmp_res) {
-			pr_debug("unwind err %d dev %s\n",
-				 tmp_res, rollback_slave->dev->name);
+			netdev_dbg(bond_dev, "unwind err %d dev %s\n",
+				   tmp_res, rollback_slave->dev->name);
 		}
 	}
 
@@ -3494,8 +3478,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 		return bond_alb_set_mac_address(bond_dev, addr);
 
 
-	pr_debug("bond=%p, name=%s\n",
-		 bond, bond_dev ? bond_dev->name : "None");
+	netdev_dbg(bond_dev, "bond=%p\n", bond);
 
 	/* If fail_over_mac is enabled, do nothing and return success.
 	 * Returning an error causes ifenslave to fail.
@@ -3523,7 +3506,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	 */
 
 	bond_for_each_slave(bond, slave, iter) {
-		pr_debug("slave %p %s\n", slave, slave->dev->name);
+		netdev_dbg(bond_dev, "slave %p %s\n", slave, slave->dev->name);
 		res = dev_set_mac_address(slave->dev, addr);
 		if (res) {
 			/* TODO: consider downing the slave
@@ -3532,7 +3515,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 			 * breakage anyway until ARP finish
 			 * updating, so...
 			 */
-			pr_debug("err %d %s\n", res, slave->dev->name);
+			netdev_dbg(bond_dev, "err %d %s\n", res, slave->dev->name);
 			goto unwind;
 		}
 	}
@@ -3554,8 +3537,8 @@ unwind:
 
 		tmp_res = dev_set_mac_address(rollback_slave->dev, &tmp_sa);
 		if (tmp_res) {
-			pr_debug("unwind err %d dev %s\n",
-				 tmp_res, rollback_slave->dev->name);
+			netdev_dbg(bond_dev, "unwind err %d dev %s\n",
+				   tmp_res, rollback_slave->dev->name);
 		}
 	}
 
@@ -3802,8 +3785,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 		return bond_tlb_xmit(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
-		pr_err("%s: Error: Unknown bonding mode %d\n",
-		       dev->name, BOND_MODE(bond));
+		netdev_err(dev, "Unknown bonding mode %d\n", BOND_MODE(bond));
 		WARN_ON_ONCE(1);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -3983,7 +3965,7 @@ static void bond_uninit(struct net_device *bond_dev)
 	/* Release the bonded slaves */
 	bond_for_each_slave(bond, slave, iter)
 		__bond_release_one(bond_dev, slave->dev, true);
-	pr_info("%s: Released all slaves\n", bond_dev->name);
+	netdev_info(bond_dev, "Released all slaves\n");
 
 	list_del(&bond->bond_list);
 
@@ -4372,7 +4354,7 @@ static int bond_init(struct net_device *bond_dev)
 	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 
-	pr_debug("Begin bond_init for %s\n", bond_dev->name);
+	netdev_dbg(bond_dev, "Begin bond_init\n");
 
 	/*
 	 * Initialize locks that may be required during
-- 
1.8.4
