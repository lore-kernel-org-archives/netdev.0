From: Stephane Fillod <fillods@users.sf.net>
Subject: [PATCH] net: smsc75xx: fix MDIO access
Date: Thu, 26 Apr 2012 21:55:17 +0200
Message-ID: <20120426195517.GU5277@charybde.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@shawell.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.13]:33347 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759064Ab2DZTzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 15:55:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* make MDIO read/write to work, the MII_ACCESS_BUSY bit was missing
  to actually trigger the I/O. Rem: the smsc75xx is different from
  the smsc95xx in that regard.
* fix PHY interrupt acknowledge, which needs a mdio_write
  to clear PHY_INT_SRC instead of a usual read like in smsc95xx.
* fix bug in phy_init loop that was ignoring BMCR reset bit,
  akin to smsc95xx's d946092000698fd204d82a9d239103c656fb63bf
* mark link down on startup and let PHY interrupt deal with carrier
  changes, akin to 07d69d4238418746a7b85c5d05ec17c658a2a390
* declare the smsc75xx's MII as GMII capable

Tested on ARM/Omap3 with LAN7500-CEB.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
---

--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -32,7 +32,7 @@
 #include "smsc75xx.h"
 
 #define SMSC_CHIPNAME			"smsc75xx"
-#define SMSC_DRIVER_VERSION		"1.0.0"
+#define SMSC_DRIVER_VERSION		"1.1.0"
 #define HS_USB_PKT_SIZE			(512)
 #define FS_USB_PKT_SIZE			(64)
 #define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
@@ -98,7 +98,7 @@ static int __must_check smsc75xx_read_re
 
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
-			"Failed to read register index 0x%08x", index);
+			"Failed to read register index 0x%08x: %d", index, ret);
 
 	le32_to_cpus(buf);
 	*data = *buf;
@@ -128,7 +128,7 @@ static int __must_check smsc75xx_write_r
 
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
-			"Failed to write register index 0x%08x", index);
+			"Failed to write register index 0x%08x: %d", index, ret);
 
 	kfree(buf);
 
@@ -171,7 +171,7 @@ static int smsc75xx_mdio_read(struct net
 	idx &= dev->mii.reg_num_mask;
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
-		| MII_ACCESS_READ;
+		| MII_ACCESS_READ | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
@@ -185,6 +185,8 @@ static int smsc75xx_mdio_read(struct net
 
 done:
 	mutex_unlock(&dev->phy_mutex);
+	netif_dbg(dev, drv, dev->net, "%s: id %x, idx %d, val=%04x",
+					__func__, phy_id, idx, ret);
 	return ret;
 }
 
@@ -195,6 +197,9 @@ static void smsc75xx_mdio_write(struct n
 	u32 val, addr;
 	int ret;
 
+	netif_dbg(dev, drv, dev->net, "%s: id %x, idx %d, val=%04x",
+					__func__, phy_id, idx, regval);
+
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
@@ -210,7 +215,7 @@ static void smsc75xx_mdio_write(struct n
 	idx &= dev->mii.reg_num_mask;
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
-		| MII_ACCESS_WRITE;
+		| MII_ACCESS_WRITE | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
@@ -511,7 +516,11 @@ static int smsc75xx_link_reset(struct us
 	/* clear interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
 	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	smsc75xx_mdio_write(dev->net, mii->phy_id, PHY_INT_SRC, 0xffff);
 
+	if (!ret)
+		netif_dbg(dev, link, dev->net, "%s: spurious interrupt", __func__);
+
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	check_warn_return(ret, "Error writing INT_STS");
 
@@ -643,7 +643,8 @@ static int smsc75xx_phy_initialize(struc
 
 static int smsc75xx_phy_initialize(struct usbnet *dev)
 {
-	int bmcr, timeout = 0;
+	int bmcr, ret, timeout = 0;
+	u32 buf;
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -651,17 +662,19 @@ static int smsc75xx_phy_initialize(struc
 	dev->mii.mdio_write = smsc75xx_mdio_write;
 	dev->mii.phy_id_mask = 0x1f;
 	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.supports_gmii = 1;
 	dev->mii.phy_id = SMSC75XX_INTERNAL_PHY_ID;
 
 	/* reset phy and wait for reset to complete */
-	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
+		BMCR_RESET | BMCR_ANENABLE);
 
 	do {
 		msleep(10);
 		bmcr = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
 		check_warn_return(bmcr, "Error reading MII_BMCR");
 		timeout++;
-	} while ((bmcr & MII_BMCR) && (timeout < 100));
+	} while ((bmcr & BMCR_RESET) && (timeout < 100));
 
 	if (timeout >= 100) {
 		netdev_warn(dev->net, "timeout on PHY Reset");
@@ -671,10 +684,17 @@ static int smsc75xx_phy_initialize(struc
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
 		ADVERTISE_PAUSE_ASYM);
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
+		ADVERTISE_1000FULL);
+	/* write to clear */
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_SRC, 0xffff);
 
+	ret = smsc75xx_read_reg(dev, MAC_CR, &buf);
+	check_warn_return(ret, "Failed to read MAC_CR: %d", ret);
+
+	buf |= (MAC_CR_ADD | MAC_CR_ASD);
+	ret = smsc75xx_write_reg(dev, MAC_CR, buf);
+	check_warn_return(ret, "Failed to write MAC_CR: %d", ret);
-	/* read to clear */
-	smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(bmcr, "Error reading PHY_INT_SRC");

 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
 		PHY_INT_MASK_DEFAULT);
@@ -1211,7 +1211,7 @@ static const struct driver_info smsc75xx
 	.rx_fixup	= smsc75xx_rx_fixup,
 	.tx_fixup	= smsc75xx_tx_fixup,
 	.status		= smsc75xx_status,
-	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
+	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
 };
 
 static const struct usb_device_id products[] = {
