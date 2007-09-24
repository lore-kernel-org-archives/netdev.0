From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V6 4/9] net/bonding: Enable bonding to enslave
 netdevices not supporting set_mac_address()
Date: Mon, 24 Sep 2007 17:36:12 +0200
Message-ID: <46F7D96C.1020503@voltaire.com>
References: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F7D770.4090500@voltaire.com>
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

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
---
 drivers/net/bonding/bond_main.c |   87 +++++++++++++++++++++++++++-------------
 drivers/net/bonding/bonding.h   |    1 
 2 files changed, 60 insertions(+), 28 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:54:13.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-15 10:54:41.971632881 +0300
@@ -1095,6 +1095,14 @@ void bond_change_active_slave(struct bon
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
@@ -1351,13 +1359,22 @@ int bond_enslave(struct net_device *bond
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
@@ -1378,16 +1395,18 @@ int bond_enslave(struct net_device *bond
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
@@ -1612,9 +1631,11 @@ err_close:
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
@@ -1792,10 +1813,12 @@ int bond_release(struct net_device *bond
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
@@ -1882,10 +1905,12 @@ static int bond_release_all(struct net_d
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
@@ -3922,6 +3947,9 @@ static int bond_set_mac_address(struct n
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
+	if (!bond->do_set_mac_addr)
+		return -EOPNOTSUPP;
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4312,6 +4340,9 @@ static int bond_init(struct net_device *
 	bond_create_proc_entry(bond);
 #endif
 
+	/* set do_set_mac_addr to true on startup */
+	bond->do_set_mac_addr = 1;
+
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
Index: net-2.6/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-08-15 10:08:58.000000000 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-08-15 10:55:34.359354833 +0300
@@ -185,6 +185,7 @@ struct bonding {
 	struct   timer_list mii_timer;
 	struct   timer_list arp_timer;
 	s8       kill_timers;
+	s8       do_set_mac_addr;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
