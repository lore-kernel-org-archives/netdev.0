From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 2/5]: bonding: use wrappers to change mtu and MAC
Date: Fri, 11 Feb 2005 01:16:31 -0800
Message-ID: <200502110916.j1B9GV6q003659@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	This updates the bonding driver to use the dev_set_mtu() and
dev_set_mac_address() wrapper functions.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Index: linux-2611-rc3/drivers/net/bonding/bond_main.c
===================================================================
RCS file: /sda7/CVS/linux-2611-rc3/linux-2611-rc3/drivers/net/bonding/bond_main.c,v
retrieving revision 1.1.1.1
diff -u -u -r1.1.1.1 bond_main.c
--- linux-2611-rc3/drivers/net/bonding/bond_main.c	11 Feb 2005 04:50:54 -0000	1.1.1.1
+++ linux-2611-rc3/drivers/net/bonding/bond_main.c	11 Feb 2005 06:20:08 -0000
@@ -1719,7 +1719,7 @@
 		 */
 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
 		addr.sa_family = slave_dev->type;
-		res = slave_dev->set_mac_address(slave_dev, &addr);
+		res = dev_set_mac_address(slave_dev, &addr);
 		if (res) {
 			dprintk("Error %d calling set_mac_address\n", res);
 			goto err_free;
@@ -1991,7 +1991,7 @@
 err_restore_mac:
 	memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
 	addr.sa_family = slave_dev->type;
-	slave_dev->set_mac_address(slave_dev, &addr);
+	dev_set_mac_address(slave_dev, &addr);
 
 err_free:
 	kfree(new_slave);
@@ -2171,7 +2171,7 @@
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
-		slave_dev->set_mac_address(slave_dev, &addr);
+		dev_set_mac_address(slave_dev, &addr);
 	}
 
 	/* restore the original state of the
@@ -2262,7 +2262,7 @@
 			/* restore original ("permanent") mac address*/
 			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 			addr.sa_family = slave_dev->type;
-			slave_dev->set_mac_address(slave_dev, &addr);
+			dev_set_mac_address(slave_dev, &addr);
 		}
 
 		/* restore the original state of the IFF_NOARP flag that might have
@@ -3898,12 +3898,7 @@
 	bond_for_each_slave(bond, slave, i) {
 		dprintk("s %p s->p %p c_m %p\n", slave,
 			slave->prev, slave->dev->change_mtu);
-		if (slave->dev->change_mtu) {
-			res = slave->dev->change_mtu(slave->dev, new_mtu);
-		} else {
-			slave->dev->mtu = new_mtu;
-			res = 0;
-		}
+		res = dev_set_mtu(slave->dev, new_mtu);
 
 		if (res) {
 			/* If we failed to set the slave's mtu to the new value
@@ -3929,14 +3924,10 @@
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		int tmp_res;
 
-		if (slave->dev->change_mtu) {
-			tmp_res = slave->dev->change_mtu(slave->dev, bond_dev->mtu);
-			if (tmp_res) {
-				dprintk("unwind err %d dev %s\n", tmp_res,
-					slave->dev->name);
-			}
-		} else {
-			slave->dev->mtu = bond_dev->mtu;
+		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
+		if (tmp_res) {
+			dprintk("unwind err %d dev %s\n", tmp_res,
+				slave->dev->name);
 		}
 	}
 
@@ -3988,7 +3979,7 @@
 			goto unwind;
 		}
 
-		res = slave->dev->set_mac_address(slave->dev, addr);
+		res = dev_set_mac_address(slave->dev, addr);
 		if (res) {
 			/* TODO: consider downing the slave
 			 * and retry ?
@@ -4014,7 +4005,7 @@
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		int tmp_res;
 
-		tmp_res = slave->dev->set_mac_address(slave->dev, &tmp_sa);
+		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
 		if (tmp_res) {
 			dprintk("unwind err %d dev %s\n", tmp_res,
 				slave->dev->name);
Index: linux-2611-rc3/drivers/net/bonding/bond_alb.c
===================================================================
RCS file: /sda7/CVS/linux-2611-rc3/linux-2611-rc3/drivers/net/bonding/bond_alb.c,v
retrieving revision 1.1.1.1
diff -u -u -r1.1.1.1 bond_alb.c
--- linux-2611-rc3/drivers/net/bonding/bond_alb.c	11 Feb 2005 04:50:54 -0000	1.1.1.1
+++ linux-2611-rc3/drivers/net/bonding/bond_alb.c	11 Feb 2005 06:16:32 -0000
@@ -954,9 +954,9 @@
 	/* each slave will receive packets destined to a different mac */
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
-	if (dev->set_mac_address(dev, &s_addr)) {
+	if (dev_set_mac_address(dev, &s_addr)) {
 		printk(KERN_ERR DRV_NAME
-		       ": Error: dev->set_mac_address of dev %s failed! ALB "
+		       ": Error: dev_set_mac_address of dev %s failed! ALB "
 		       "mode requires that the base driver support setting "
 		       "the hw address also when the network device's "
 		       "interface is open\n",
@@ -1209,7 +1209,7 @@
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
-		res = slave->dev->set_mac_address(slave->dev, addr);
+		res = dev_set_mac_address(slave->dev, addr);
 
 		/* restore net_device's hw address */
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
@@ -1229,7 +1229,7 @@
 	stop_at = slave;
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
-		slave->dev->set_mac_address(slave->dev, &sa);
+		dev_set_mac_address(slave->dev, &sa);
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
 	}
 
