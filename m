From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bond: have random dev address by default instead of zeroes
Date: Thu, 24 Jan 2013 11:12:09 +0100
Message-ID: <1359022329-6919-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:60053 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab3AXKMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 05:12:15 -0500
Received: by mail-wg0-f52.google.com with SMTP id 12so3536175wgh.7
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 02:12:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes more sense to have randomly generated address by default than to
have all zeroes. It also allows user to for example put the bond into
bridge without need to have any slaves in it.

Also, fix dev_assign_type values on the way.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 564cf42..af3a777 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-static int bond_sethwaddr(struct net_device *bond_dev,
-			  struct net_device *slave_dev)
+static void bond_set_dev_addr(struct net_device *bond_dev,
+			      struct net_device *slave_dev)
 {
 	pr_debug("bond_dev=%p\n", bond_dev);
 	pr_debug("slave_dev=%p\n", slave_dev);
 	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
-	return 0;
+	bond_dev->addr_assign_type |= NET_ADDR_SET;
 }
 
 static netdev_features_t bond_fix_features(struct net_device *dev,
@@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (is_zero_ether_addr(bond->dev->dev_addr))
-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
-		       slave_dev->addr_len);
-
+	if (bond->dev->addr_assign_type != NET_ADDR_SET)
+		bond_set_dev_addr(bond->dev, slave_dev);
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
@@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (bond->slave_cnt == 0) {
 		bond_set_carrier(bond);
 
-		/* if the last slave was removed, zero the mac address
-		 * of the master so it will be set by the application
-		 * to the mac address of the first slave
+		/* If the last slave was removed, set random mac address
+		 * of the master so it will be set by bond_enslave()
+		 * to the mac address of the first slave.
 		 */
-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+		eth_hw_addr_random(bond_dev);
 
 		if (bond_vlan_used(bond)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
@@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 			break;
 		case BOND_SETHWADDR_OLD:
 		case SIOCBONDSETHWADDR:
-			res = bond_sethwaddr(bond_dev, slave_dev);
+			bond_set_dev_addr(bond_dev, slave_dev);
+			res = 0;
 			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
@@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_dev)
 
 	bond_debug_register(bond);
 
+	/* Ensure valid dev_addr */
+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
+	    bond_dev->addr_assign_type == NET_ADDR_PERM)
+		eth_hw_addr_random(bond_dev);
+
 	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
-- 
1.8.1
