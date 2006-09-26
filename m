From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC][PATCH 2/3] enable bonding to enslave netdevices not supporting
 set_mac_address()
Date: Tue, 26 Sep 2006 13:17:36 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0609261317100.24189@zuben>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:63549 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1751083AbWIZKRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:17:38 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609261309540.24189@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-2.6.19/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.19.orig/drivers/net/bonding/bond_main.c	2006-09-25 11:43:52.000000000 +0300
+++ net-2.6.19/drivers/net/bonding/bond_main.c	2006-09-25 11:46:35.000000000 +0300
@@ -1115,7 +1115,14 @@ void bond_change_active_slave(struct bon
 		 */
 		if (new_active && new_active->dev->type != ARPHRD_ETHER)
 			bond_setup_by_slave(bond, new_active);
-
+
+		/* when bonding does not set the slave MAC address, the bond MAC
+		 * address is the one of the active slave.
+		 */
+		if (new_active && !bond->do_set_mac_addr)
+			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
+				new_active->dev->addr_len);
+
 		bond_send_gratuitous_arp(bond);
 	}
 }
@@ -1335,14 +1342,23 @@ int bond_enslave(struct net_device *bond
 	}

 	if (slave_dev->set_mac_address == NULL) {
-		printk(KERN_ERR DRV_NAME
-			": %s: Error: The slave device you specified does "
-			"not support setting the MAC address. "
-			"Your kernel likely does not support slave "
-			"devices.\n", bond_dev->name);
-  		res = -EOPNOTSUPP;
-		goto err_undo_flags;
-	}
+		if (bond->slave_cnt == 0) {
+			printk(KERN_WARNING DRV_NAME
+				": %s: Warning: The first slave device you "
+				"specified does not support setting the MAC "
+				"address. This bond MAC address would be that "
+				"of the active slave.\n", bond_dev->name);
+			bond->do_set_mac_addr = 0;
+		} else if (bond->do_set_mac_addr) {
+			printk(KERN_ERR DRV_NAME
+				": %s: Error: The slave device you specified "
+				"does not support setting the MAC addres,."
+				"but this bond uses this practice. \n"
+				, bond_dev->name);
+			res = -EOPNOTSUPP;
+			goto err_undo_flags;
+		}
+	}

 	new_slave = kmalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
@@ -1364,16 +1380,18 @@ int bond_enslave(struct net_device *bond
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);

-	/*
-	 * Set slave to master's mac address.  The application already
-	 * set the master's mac address to that of the first slave
-	 */
-	memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-	addr.sa_family = slave_dev->type;
-	res = dev_set_mac_address(slave_dev, &addr);
-	if (res) {
-		dprintk("Error %d calling set_mac_address\n", res);
-		goto err_free;
+	if (bond->do_set_mac_addr) {
+		/*
+		 * Set slave to master's mac address.  The application already
+		 * set the master's mac address to that of the first slave
+		 */
+		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
+		addr.sa_family = slave_dev->type;
+		res = dev_set_mac_address(slave_dev, &addr);
+		if (res) {
+			dprintk("Error %d calling set_mac_address\n", res);
+			goto err_free;
+		}
 	}

 	/* open the slave since the application closed it */
@@ -1617,9 +1635,11 @@ err_close:
 	dev_close(slave_dev);

 err_restore_mac:
-	memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
-	addr.sa_family = slave_dev->type;
-	dev_set_mac_address(slave_dev, &addr);
+	if (bond->do_set_mac_addr) {
+		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
+		addr.sa_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, &addr);
+	}

 err_free:
 	kfree(new_slave);
@@ -1797,10 +1817,12 @@ int bond_release(struct net_device *bond
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);

-	/* restore original ("permanent") mac address */
-	memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-	addr.sa_family = slave_dev->type;
-	dev_set_mac_address(slave_dev, &addr);
+	if (bond->do_set_mac_addr) {
+		/* restore original ("permanent") mac address */
+		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+		addr.sa_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, &addr);
+	}

 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
 				   IFF_SLAVE_INACTIVE);
@@ -1886,10 +1908,12 @@ static int bond_release_all(struct net_d
 		/* close slave before restoring its mac address */
 		dev_close(slave_dev);

-		/* restore original ("permanent") mac address*/
-		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-		addr.sa_family = slave_dev->type;
-		dev_set_mac_address(slave_dev, &addr);
+		if (bond->do_set_mac_addr) {
+			/* restore original ("permanent") mac address*/
+			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+			addr.sa_family = slave_dev->type;
+			dev_set_mac_address(slave_dev, &addr);
+		}

 		slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
 					   IFF_SLAVE_INACTIVE);
@@ -3793,6 +3817,10 @@ static int bond_set_mac_address(struct n

 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));

+	if (!bond->do_set_mac_addr) {
+		return -EOPNOTSUPP;
+	}
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4233,6 +4261,9 @@ static int bond_init(struct net_device *
 	bond_create_proc_entry(bond);
 #endif

+	/* set do_set_mac_addr to true on startup */
+	bond->do_set_mac_addr = 1;
+
 	list_add_tail(&bond->bond_list, &bond_dev_list);

 	return 0;
Index: net-2.6.19/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.19.orig/drivers/net/bonding/bonding.h	2006-09-25 11:42:28.000000000 +0300
+++ net-2.6.19/drivers/net/bonding/bonding.h	2006-09-25 11:46:35.000000000 +0300
@@ -198,6 +198,7 @@ struct bonding {
 	struct   bond_params params;
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
+	s8       do_set_mac_addr;
 };

 /**

