From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Thu, 07 Apr 2005 12:59:35 -0700
Message-ID: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	This patch backs out some of the calls to dev_set_mac_address
and replaces them with calls to a similar function that does not call
notifier_call_chain.

	The reason for this is that the rtnetlink event handler and its
descendents make GFP_KERNEL memory allocation requests, and the bonding
driver makes some of its MAC address change calls from timer context
with a lock held (notably the ALB mode).

	Rearranging the bonding driver to not call this way is a fairly
involved change; this patch merely reverts one part of bonding to the
way it used to be.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff -ur linux-2.6.12-rc2-virgin/drivers/net/bonding/bond_alb.c linux-2.6.12-rc2-setmac/drivers/net/bonding/bond_alb.c
--- linux-2.6.12-rc2-virgin/drivers/net/bonding/bond_alb.c	2005-04-05 22:04:27.000000000 -0700
+++ linux-2.6.12-rc2-setmac/drivers/net/bonding/bond_alb.c	2005-04-07 12:25:02.000000000 -0700
@@ -138,6 +138,23 @@
 	return hash;
 }
 
+/*
+ * Stopgap that doesn't notifier_call_chain like real dev_set_mac_address,
+ * as rtnetlink event notifier makes sleepable memory allocations, and we
+ * call this with a lock held.
+ */
+static int bond_dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
+{
+	if (!dev->set_mac_address)
+		return -EOPNOTSUPP;
+	if (sa->sa_family != dev->type)
+		return -EINVAL;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+	return dev->set_mac_address(dev, sa);
+}
+
+
 /*********************** tlb specific functions ***************************/
 
 static inline void _lock_tx_hashtbl(struct bonding *bond)
@@ -955,7 +972,7 @@
 	/* each slave will receive packets destined to a different mac */
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
-	if (dev_set_mac_address(dev, &s_addr)) {
+	if (bond_dev_set_mac_address(dev, &s_addr)) {
 		printk(KERN_ERR DRV_NAME
 		       ": Error: dev_set_mac_address of dev %s failed! ALB "
 		       "mode requires that the base driver support setting "
@@ -1210,7 +1227,7 @@
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
-		res = dev_set_mac_address(slave->dev, addr);
+		res = bond_dev_set_mac_address(slave->dev, addr);
 
 		/* restore net_device's hw address */
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
@@ -1230,7 +1247,7 @@
 	stop_at = slave;
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
-		dev_set_mac_address(slave->dev, &sa);
+		bond_dev_set_mac_address(slave->dev, &sa);
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
 	}
 
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bond_alb.o
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bond_main.o
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bonding.ko
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bonding.mod.c
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bonding.mod.o
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: bonding.o
Only in linux-2.6.12-rc2-setmac/drivers/net/bonding/: built-in.o
