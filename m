From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/9] net/bonding: Enable bonding to enslave netdevices not supporting set_mac_address()
Date: Tue,  9 Oct 2007 19:43:39 -0700
Message-ID: <1191984226411-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57493 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbXJJCnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hl8E024668
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hla2487546
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hld0002029
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:47 -0600
In-Reply-To: <11919842263810-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

This patch allows for enslaving netdevices which do not support
the set_mac_address() function. In that case the bond mac address is the one
of the active slave, where remote peers are notified on the mac address
(neighbour) change by Gratuitous ARP sent by bonding when fail-over occurs
(this is already done by the bonding code).

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   87 ++++++++++++++++++++++++++------------
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 60 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6ae4593..6508e0b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1096,6 +1096,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
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
@@ -1346,13 +1354,22 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1373,16 +1390,18 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1607,9 +1626,11 @@ err_close:
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
@@ -1782,10 +1803,12 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1872,10 +1895,12 @@ static int bond_release_all(struct net_device *bond_dev)
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
@@ -3913,6 +3938,9 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
+	if (!bond->do_set_mac_addr)
+		return -EOPNOTSUPP;
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4299,6 +4327,9 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond_create_proc_entry(bond);
 #endif
 
+	/* set do_set_mac_addr to true on startup */
+	bond->do_set_mac_addr = 1;
+
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2a6af7d..5011ba9 100644
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
1.5.3.1

