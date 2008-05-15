From: <glenn_engel@agilent.com>
Subject: natsemi.c ioctl fix or mii register access
Date: Thu, 15 May 2008 17:23:50 -0600
Message-ID: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglcosbs05.cos.agilent.com ([192.25.218.36]:35430 "EHLO
	aglsgpbs05.sgp.agilent.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750860AbYEOXfF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 19:35:05 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently discovered the ioctl implementation in natsemi.c had a few bugs in dealing with the user ioctls to send and receive MII commands (SIOCGMIIPHY and SIOCSMIIPHY).
 
The specific problems noted and fixed:

1. The if_mii macro casts it's return to be (struct mii_ioctl_data *) but in reality it returns a pointer to the user space pointer (struct mii_ioctl_data**).   This looks to be a problem with the mii_macro to me.  I changed this to use the ifr_data macro instead.

2. Since the mii_ioctl_data structure resides in user space, it must be copied into kernel space before access and copied back for read results.  References to the pointer were changed to point to the local copy (data-> changed to mii_data.)

--
Glenn

--- linux-2.6.25.4.orig/drivers/net/natsemi.c	2008-05-15 14:05:37.000000000 -0700
+++ linux-2.6.25.4/drivers/net/natsemi.c	2008-05-15 14:29:28.000000000 -0700
@@ -3043,13 +3043,18 @@
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct mii_ioctl_data *data = if_mii(rq);
+	struct mii_ioctl_data *data = (struct mii_ioctl_data*)rq->ifr_data;
 	struct netdev_private *np = netdev_priv(dev);
+	struct mii_ioctl_data mii_data;
+    
+	if (cmd == SIOCGMIIPHY || cmd == SIOCGMIIREG || cmd == SIOCSMIIREG) {
+		copy_from_user(&mii_data, data, sizeof(mii_data));
+	}
 
 	switch(cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
 	case SIOCDEVPRIVATE:		/* for binary compat, remove in 2.5 */
-		data->phy_id = np->phy_addr_external;
+		mii_data.phy_id = np->phy_addr_external;
 		/* Fall Through */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
@@ -3059,16 +3064,17 @@
 		 * the given mii on the current port.
 		 */
 		if (dev->if_port == PORT_TP) {
-			if ((data->phy_id & 0x1f) == np->phy_addr_external)
-				data->val_out = mdio_read(dev,
-							data->reg_num & 0x1f);
+			if ((mii_data.phy_id & 0x1f) == np->phy_addr_external)
+				mii_data.val_out = mdio_read(dev,
+							mii_data.reg_num & 0x1f);
 			else
-				data->val_out = 0;
+				mii_data.val_out = 0;
 		} else {
-			move_int_phy(dev, data->phy_id & 0x1f);
-			data->val_out = miiport_read(dev, data->phy_id & 0x1f,
-							data->reg_num & 0x1f);
+			move_int_phy(dev, mii_data.phy_id & 0x1f);
+			mii_data.val_out = miiport_read(dev, mii_data.phy_id & 0x1f,
+							mii_data.reg_num & 0x1f);
 		}
+		copy_to_user(data, &mii_data, sizeof(mii_data));
 		return 0;
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
@@ -3076,21 +3082,21 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		if (dev->if_port == PORT_TP) {
-			if ((data->phy_id & 0x1f) == np->phy_addr_external) {
- 				if ((data->reg_num & 0x1f) == MII_ADVERTISE)
-					np->advertising = data->val_in;
-				mdio_write(dev, data->reg_num & 0x1f,
-							data->val_in);
+			if ((mii_data.phy_id & 0x1f) == np->phy_addr_external) {
+ 				if ((mii_data.reg_num & 0x1f) == MII_ADVERTISE)
+					np->advertising = mii_data.val_in;
+				mdio_write(dev, mii_data.reg_num & 0x1f,
+							mii_data.val_in);
 			}
 		} else {
-			if ((data->phy_id & 0x1f) == np->phy_addr_external) {
- 				if ((data->reg_num & 0x1f) == MII_ADVERTISE)
-					np->advertising = data->val_in;
+			if ((mii_data.phy_id & 0x1f) == np->phy_addr_external) {
+ 				if ((mii_data.reg_num & 0x1f) == MII_ADVERTISE)
+					np->advertising = mii_data.val_in;
 			}
-			move_int_phy(dev, data->phy_id & 0x1f);
-			miiport_write(dev, data->phy_id & 0x1f,
-						data->reg_num & 0x1f,
-						data->val_in);
+			move_int_phy(dev, mii_data.phy_id & 0x1f);
+			miiport_write(dev, mii_data.phy_id & 0x1f,
+						mii_data.reg_num & 0x1f,
+						mii_data.val_in);
 		}
 		return 0;
 	default:





