From: Moni Shoua <monisonlists@gmail.com>
Subject: [PATCH V6 6/9] net/bonding: Handlle wrong assumptions that slave
 is always an Ethernet device
Date: Mon, 24 Sep 2007 17:40:57 +0200
Message-ID: <46F7DA89.1050403@gmail.com>
References: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:15721 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754948AbXIXPk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 11:40:59 -0400
In-Reply-To: <46F7D770.4090500@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bonding sometimes uses Ethernet constants (such as MTU and address length) which
are not good when it enslaves non Ethernet devices (such as InfiniBand).

Signed-off-by: Moni Shoua <monis at voltaire.com>
---
 drivers/net/bonding/bond_main.c  |    3 ++-
 drivers/net/bonding/bond_sysfs.c |   10 ++++++++--
 drivers/net/bonding/bonding.h    |    1 +
 3 files changed, 11 insertions(+), 3 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-09-24 12:52:33.000000000 +0200
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-09-24 12:57:33.411459811 +0200
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
--- net-2.6.orig/drivers/net/bonding/bond_sysfs.c	2007-09-24 12:55:09.000000000 +0200
+++ net-2.6/drivers/net/bonding/bond_sysfs.c	2007-09-24 13:00:23.752680721 +0200
@@ -260,6 +260,7 @@ static ssize_t bonding_store_slaves(stru
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
 	int i, res, found, ret = count;
+	u32 original_mtu;
 	struct slave *slave;
 	struct net_device *dev = NULL;
 	struct bonding *bond = to_bond(d);
@@ -325,6 +326,7 @@ static ssize_t bonding_store_slaves(stru
 		}
 
 		/* Set the slave's MTU to match the bond */
+		original_mtu = dev->mtu;
 		if (dev->mtu != bond->dev->mtu) {
 			if (dev->change_mtu) {
 				res = dev->change_mtu(dev,
@@ -339,6 +341,9 @@ static ssize_t bonding_store_slaves(stru
 		}
 		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
+		bond_for_each_slave(bond, slave, i)
+			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
+				slave->original_mtu = original_mtu;
 		rtnl_unlock();
 		if (res) {
 			ret = res;
@@ -351,6 +356,7 @@ static ssize_t bonding_store_slaves(stru
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				dev = slave->dev;
+				original_mtu = slave->original_mtu;
 				break;
 			}
 		if (dev) {
@@ -365,9 +371,9 @@ static ssize_t bonding_store_slaves(stru
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
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-09-24 12:55:09.000000000 +0200
+++ net-2.6/drivers/net/bonding/bonding.h	2007-09-24 12:57:33.412459636 +0200
@@ -156,6 +156,7 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
+	u32    original_mtu;
 	u32    link_failure_count;
 	u16    speed;
 	u8     duplex;

