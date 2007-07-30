From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V3 6/7] net/bonding: Handlle wrong assumptions
 that slave is always an Ethernet device
Date: Mon, 30 Jul 2007 15:54:59 +0300
Message-ID: <46ADDFA3.1000100@voltaire.com>
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


bonding sometimes uses Ethernet constants (such as MTU and address length) which
are not good when it enslaves non Ethernet devices (such as InfiniBand).

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_main.c  |    2 +-
 drivers/net/bonding/bond_sysfs.c |   10 ++++++++--
 drivers/net/bonding/bonding.h    |    1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-07-25 15:06:17.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-07-25 15:33:25.012883360 +0300
@@ -1255,7 +1255,7 @@ static int bond_compute_features(struct 
 	unsigned long features = BOND_INTERSECT_FEATURES;
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
-	unsigned short max_hard_header_len = ETH_HLEN;
+	u16 max_hard_header_len = max((u16)ETH_HLEN, bond_dev->hard_header_len);
 	int i;
 
 	bond_for_each_slave(bond, slave, i) {
Index: net-2.6/drivers/net/bonding/bond_sysfs.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_sysfs.c	2007-07-25 15:06:17.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_sysfs.c	2007-07-25 15:20:10.224527636 +0300
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
+				slave->original_mtu=original_mtu;
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
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-07-25 15:03:32.000000000 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-07-25 15:20:10.223527810 +0300
@@ -156,6 +156,7 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
+	u32    original_mtu;
 	u32    link_failure_count;
 	u16    speed;
 	u8     duplex;
