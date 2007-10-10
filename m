From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 6/9] net/bonding: Handlle wrong assumptions that slave is always an Ethernet device
Date: Tue,  9 Oct 2007 19:43:41 -0700
Message-ID: <11919842272176-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
 <1191984226411-git-send-email-fubar@us.ibm.com>
 <11919842273755-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55243 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbXJJCnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9A1ZBk7009785
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 21:35:11 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hmwe432012
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hmaL002077
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
In-Reply-To: <11919842273755-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

bonding sometimes uses Ethernet constants (such as MTU and address length) which
are not good when it enslaves non Ethernet devices (such as InfiniBand).

Signed-off-by: Moni Shoua <monis at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |    3 ++-
 drivers/net/bonding/bond_sysfs.c |   10 ++++++++--
 drivers/net/bonding/bonding.h    |    1 +
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3eebfe2..7be2336 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1225,7 +1225,8 @@ static int bond_compute_features(struct bonding *bond)
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
-	unsigned short max_hard_header_len = ETH_HLEN;
+	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
+						bond_dev->hard_header_len);
 	int i;
 
 	features &= ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ca4e429..583c568 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -260,6 +260,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
 	int i, res, found, ret = count;
+	u32 original_mtu;
 	struct slave *slave;
 	struct net_device *dev = NULL;
 	struct bonding *bond = to_bond(d);
@@ -325,6 +326,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 		}
 
 		/* Set the slave's MTU to match the bond */
+		original_mtu = dev->mtu;
 		if (dev->mtu != bond->dev->mtu) {
 			if (dev->change_mtu) {
 				res = dev->change_mtu(dev,
@@ -339,6 +341,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 		}
 		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
+		bond_for_each_slave(bond, slave, i)
+			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
+				slave->original_mtu = original_mtu;
 		rtnl_unlock();
 		if (res) {
 			ret = res;
@@ -351,6 +356,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				dev = slave->dev;
+				original_mtu = slave->original_mtu;
 				break;
 			}
 		if (dev) {
@@ -365,9 +371,9 @@ static ssize_t bonding_store_slaves(struct device *d,
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
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5011ba9..ad9c632 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -156,6 +156,7 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
+	u32    original_mtu;
 	u32    link_failure_count;
 	u16    speed;
 	u8     duplex;
-- 
1.5.3.1

