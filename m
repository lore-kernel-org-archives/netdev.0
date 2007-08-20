From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V4 8/10] net/bonding: Handlle wrong assumptions that slave
 is always an Ethernet device
Date: Mon, 20 Aug 2007 18:52:57 +0300
Message-ID: <46C9B8D9.5060508@voltaire.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:30851 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759485AbXHTPw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 11:52:59 -0400
In-Reply-To: <46C9B474.5020202@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bonding sometimes uses Ethernet constants (such as MTU and address length) which
are not good when it enslaves non Ethernet devices (such as InfiniBand).

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_main.c  |    3 ++-
 drivers/net/bonding/bond_sysfs.c |   19 +++++++++++++------
 drivers/net/bonding/bonding.h    |    1 +
 3 files changed, 16 insertions(+), 7 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:55:48.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-20 14:29:11.911298577 +0300
@@ -1224,7 +1224,8 @@ static int bond_compute_features(struct 
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
-	unsigned short max_hard_header_len = ETH_HLEN;
+	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
+						bond_dev->hard_header_len);
 	int i;
 
 	features &= ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
Index: net-2.6/drivers/net/bonding/bond_sysfs.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_sysfs.c	2007-08-15 10:55:48.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_sysfs.c	2007-08-15 12:14:41.152469089 +0300
@@ -164,9 +164,7 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_deinit(bond->dev);
-		        	bond_destroy_sysfs_entry(bond);
-				unregister_netdevice(bond->dev);
+				bond_destroy(bond);
 				rtnl_unlock();
 				goto out;
 			}
@@ -260,6 +258,7 @@ static ssize_t bonding_store_slaves(stru
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
 	int i, res, found, ret = count;
+	u32 original_mtu;
 	struct slave *slave;
 	struct net_device *dev = NULL;
 	struct bonding *bond = to_bond(d);
@@ -325,6 +324,7 @@ static ssize_t bonding_store_slaves(stru
 		}
 
 		/* Set the slave's MTU to match the bond */
+		original_mtu = dev->mtu;
 		if (dev->mtu != bond->dev->mtu) {
 			if (dev->change_mtu) {
 				res = dev->change_mtu(dev,
@@ -339,6 +339,9 @@ static ssize_t bonding_store_slaves(stru
 		}
 		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
+		bond_for_each_slave(bond, slave, i)
+			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
+				slave->original_mtu = original_mtu;
 		rtnl_unlock();
 		if (res) {
 			ret = res;
@@ -351,13 +354,17 @@ static ssize_t bonding_store_slaves(stru
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				dev = slave->dev;
+				original_mtu = slave->original_mtu;
 				break;
 			}
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
 			rtnl_lock();
-			res = bond_release(bond->dev, dev);
+			if (bond->setup_by_slave)
+				res = bond_release_and_destroy(bond->dev, dev);
+			else
+				res = bond_release(bond->dev, dev);
 			rtnl_unlock();
 			if (res) {
 				ret = res;
@@ -365,9 +372,9 @@ static ssize_t bonding_store_slaves(stru
 			}
 			/* set the slave MTU to the default */
 			if (dev->change_mtu) {
-				dev->change_mtu(dev, 1500);
+				dev->change_mtu(dev, original_mtu);
 			} else {
-				dev->mtu = 1500;
+				dev->mtu = original_mtu;
 			}
 		}
 		else {
Index: net-2.6/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-08-15 10:55:34.000000000 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-08-20 14:29:11.912298402 +0300
@@ -156,6 +156,7 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
+	u32    original_mtu;
 	u32    link_failure_count;
 	u16    speed;
 	u8     duplex;

