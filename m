From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 06/11] net/bonding: Enable bonding to enslave netdevices not supporting set_mac_address()
Date: Fri, 14 Sep 2007 16:40:25 -0700
Message-ID: <1189813242354-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
 <11898132372856-git-send-email-fubar@us.ibm.com>
 <11898132411426-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52657 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757981AbXINXkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENejG2015273
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENejT0676190
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENeiSF008757
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:45 -0400
In-Reply-To: <11898132411426-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

This patch allows for enslaving netdevices which do not support
the set_mac_address() function. In that case the bond mac address is the one
of the active slave, where remote peers are notified on the mac address
(neighbour) change by Gratuitous ARP sent by bonding when fail-over occurs
(this is already done by the bonding code).

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   87 ++++++++++++++++++++++++++------------
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 60 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 13ec73d..d937bae 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1095,6 +1095,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
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
@@ -1351,13 +1359,22 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1378,16 +1395,18 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1792,10 +1813,12 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1882,10 +1905,12 @@ static int bond_release_all(struct net_device *bond_dev)
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
@@ -3922,6 +3947,9 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
+	if (!bond->do_set_mac_addr)
+		return -EOPNOTSUPP;
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4312,6 +4340,9 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond_create_proc_entry(bond);
 #endif
 
+	/* set do_set_mac_addr to true on startup */
+	bond->do_set_mac_addr = 1;
+
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6dcbd25..700d40a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -185,6 +185,7 @@ struct bonding {
 	struct   timer_list mii_timer;
 	struct   timer_list arp_timer;
 	s8       kill_timers;
+	s8       do_set_mac_addr;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
-- 
1.5.2-rc2.GIT

