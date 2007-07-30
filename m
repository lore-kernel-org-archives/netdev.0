From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V3 4/7] net/bonding: Enable bonding to enslave
 netdevices not supporting set_mac_address()
Date: Mon, 30 Jul 2007 15:52:50 +0300
Message-ID: <46ADDF22.3090604@voltaire.com>
References: <46ADDB89.5030601@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com,  davem@davemloft.net,  fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46ADDB89.5030601@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This patch allows for enslaving netdevices which do not support
the set_mac_address() function. In that case the bond mac address is the one
of the active slave, where remote peers are notified on the mac address
(neighbour) change by Gratuitous ARP sent by bonding when fail-over occurs
(this is already done by the bonding code).

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
---
 drivers/net/bonding/bond_main.c |   88 +++++++++++++++++++++++++++-------------
 drivers/net/bonding/bonding.h   |    1 

 2 files changed, 61 insertions(+), 28 deletions(-)
Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-07-29 16:24:30.913343981 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-07-29 16:36:53.234602471 +0300
@@ -1127,6 +1127,14 @@ void bond_change_active_slave(struct bon
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
 		}
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
@@ -1390,13 +1398,22 @@ int bond_enslave(struct net_device *bond
 	}
 
 	if (slave_dev->set_mac_address == NULL) {
-		printk(KERN_ERR DRV_NAME
-			": %s: Error: The slave device you specified does "
-			"not support setting the MAC address. "
-			"Your kernel likely does not support slave "
-			"devices.\n", bond_dev->name);
-  		res = -EOPNOTSUPP;
-		goto err_undo_flags;
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
 	}
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
@@ -1417,16 +1434,18 @@ int bond_enslave(struct net_device *bond
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
 
 	res = netdev_set_master(slave_dev, bond_dev);
@@ -1651,9 +1670,11 @@ err_close:
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
@@ -1831,10 +1852,12 @@ int bond_release(struct net_device *bond
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
 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
@@ -1921,10 +1944,12 @@ static int bond_release_all(struct net_d
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
@@ -3961,6 +3986,10 @@ static int bond_set_mac_address(struct n
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
+	if (!bond->do_set_mac_addr) {
+		return -EOPNOTSUPP;
+	}
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4351,6 +4380,9 @@ static int bond_init(struct net_device *
 	bond_create_proc_entry(bond);
 #endif
 
+	/* set do_set_mac_addr to true on startup */
+	bond->do_set_mac_addr = 1;
+
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
Index: net-2.6/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-07-29 16:25:22.000000000 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-07-29 16:37:13.163056181 +0300
@@ -201,6 +201,7 @@ struct bonding {
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
+	s8       do_set_mac_addr;
 };
 
 /**
