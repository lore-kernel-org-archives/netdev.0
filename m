From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/3][bonding 2.6] Add support for slaves that use ethtool_ops
Date: Thu, 25 Dec 2003 17:05:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312251705.36958.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When collecting link information from slaves via ETHTOOL, first try
using the relevant ethtool_ops functions.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Dec 25 15:31:08 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Dec 25 15:31:10 2003
@@ -623,44 +623,55 @@ static int bond_update_speed_duplex(stru
 	struct ifreq ifr;
 	struct ethtool_cmd etool;
 
-	ioctl = slave_dev->do_ioctl;
-	if (ioctl) {
-		etool.cmd = ETHTOOL_GSET;
-		ifr.ifr_data = (char*)&etool;
-		if (IOCTL(slave_dev, &ifr, SIOCETHTOOL) == 0) {
-			slave->speed = etool.speed;
-			slave->duplex = etool.duplex;
-		} else {
-			goto err_out;
+	/* Fake speed and duplex */
+	slave->speed = SPEED_100;
+	slave->duplex = DUPLEX_FULL;
+
+	if (slave_dev->ethtool_ops) {
+		u32 res;
+
+		if (!slave_dev->ethtool_ops->get_settings) {
+			return -1;
+		}
+
+		res = slave_dev->ethtool_ops->get_settings(slave_dev, &etool);
+		if (res < 0) {
+			return -1;
 		}
-	} else {
-		goto err_out;
+
+		goto verify;
 	}
 
-	switch (slave->speed) {
+	ioctl = slave_dev->do_ioctl;
+	strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
+	etool.cmd = ETHTOOL_GSET;
+	ifr.ifr_data = (char*)&etool;
+	if (!ioctl || (IOCTL(slave_dev, &ifr, SIOCETHTOOL) < 0)) {
+		return -1;
+	}
+
+verify:
+	switch (etool.speed) {
 	case SPEED_10:
 	case SPEED_100:
 	case SPEED_1000:
 		break;
 	default:
-		goto err_out;
+		return -1;
 	}
 
-	switch (slave->duplex) {
+	switch (etool.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
 	default:
-		goto err_out;
+		return -1;
 	}
 
-	return 0;
+	slave->speed = etool.speed;
+	slave->duplex = etool.duplex;
 
-err_out:
-	/* Fake speed and duplex */
-	slave->speed = SPEED_100;
-	slave->duplex = DUPLEX_FULL;
-	return -1;
+	return 0;
 }
 
 /*
@@ -705,6 +716,7 @@ static int bond_check_dev_link(struct ne
 		 */
 
 		/* Yes, the mii is overlaid on the ifreq.ifr_ifru */
+		strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
 		mii = (struct mii_ioctl_data *)&ifr.ifr_data;
 		if (IOCTL(slave_dev, &ifr, SIOCGMIIPHY) == 0) {
 			mii->reg_num = MII_BMSR;
@@ -712,10 +724,23 @@ static int bond_check_dev_link(struct ne
 				return (mii->val_out & BMSR_LSTATUS);
 			}
 		}
+	}
 
-		/* try SIOCETHTOOL ioctl, some drivers cache ETHTOOL_GLINK */
-		/* for a period of time so we attempt to get link status   */
-		/* from it last if the above MII ioctls fail...            */
+	/* try SIOCETHTOOL ioctl, some drivers cache ETHTOOL_GLINK */
+	/* for a period of time so we attempt to get link status   */
+	/* from it last if the above MII ioctls fail...            */
+	if (slave_dev->ethtool_ops) {
+		if (slave_dev->ethtool_ops->get_link) {
+			u32 link;
+
+			link = slave_dev->ethtool_ops->get_link(slave_dev);
+
+			return link ? BMSR_LSTATUS : 0;
+		}
+	}
+
+	if (ioctl) {
+		strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
 		etool.cmd = ETHTOOL_GLINK;
 		ifr.ifr_data = (char*)&etool;
 		if (IOCTL(slave_dev, &ifr, SIOCETHTOOL) == 0) {
