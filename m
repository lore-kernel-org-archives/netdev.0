From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc75xx: support PHY wakeup source
Date: Tue, 27 Nov 2012 14:28:02 +0000
Message-ID: <1354026482-10443-3-git-send-email-steve.glendinning@shawell.net>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47517 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab2K0O2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 09:28:11 -0500
In-Reply-To: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables LAN7500 family devices to wake from suspend
on either link up or link down events.

It also adds _nopm versions of mdio access functions, so we can
safely call them from suspend and resume functions

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |  168 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 151 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 4655c01..8f92d81 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -54,7 +54,7 @@
 #define USB_PRODUCT_ID_LAN7500		(0x7500)
 #define USB_PRODUCT_ID_LAN7505		(0x7505)
 #define RXW_PADDING			2
-#define SUPPORTED_WAKE			(WAKE_UCAST | WAKE_BCAST | \
+#define SUPPORTED_WAKE			(WAKE_PHY | WAKE_UCAST | WAKE_BCAST | \
 					 WAKE_MCAST | WAKE_ARP | WAKE_MAGIC)
 
 #define check_warn(ret, fmt, args...) \
@@ -185,14 +185,15 @@ static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
 
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
-static int smsc75xx_phy_wait_not_busy(struct usbnet *dev)
+static __must_check int __smsc75xx_phy_wait_not_busy(struct usbnet *dev,
+						     int in_pm)
 {
 	unsigned long start_time = jiffies;
 	u32 val;
 	int ret;
 
 	do {
-		ret = smsc75xx_read_reg(dev, MII_ACCESS, &val);
+		ret = __smsc75xx_read_reg(dev, MII_ACCESS, &val, in_pm);
 		check_warn_return(ret, "Error reading MII_ACCESS\n");
 
 		if (!(val & MII_ACCESS_BUSY))
@@ -202,7 +203,8 @@ static int smsc75xx_phy_wait_not_busy(struct usbnet *dev)
 	return -EIO;
 }
 
-static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+static int __smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
+				int in_pm)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
@@ -211,7 +213,7 @@ static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	ret = smsc75xx_phy_wait_not_busy(dev);
+	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_read\n");
 
 	/* set the address, index & direction (read from PHY) */
@@ -220,13 +222,13 @@ static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_READ | MII_ACCESS_BUSY;
-	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
+	ret = __smsc75xx_write_reg(dev, MII_ACCESS, addr, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
 
-	ret = smsc75xx_phy_wait_not_busy(dev);
+	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "Timed out reading MII reg %02X\n", idx);
 
-	ret = smsc75xx_read_reg(dev, MII_DATA, &val);
+	ret = __smsc75xx_read_reg(dev, MII_DATA, &val, in_pm);
 	check_warn_goto_done(ret, "Error reading MII_DATA\n");
 
 	ret = (u16)(val & 0xFFFF);
@@ -236,8 +238,8 @@ done:
 	return ret;
 }
 
-static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
-				int regval)
+static void __smsc75xx_mdio_write(struct net_device *netdev, int phy_id,
+				  int idx, int regval, int in_pm)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
@@ -246,11 +248,11 @@ static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	ret = smsc75xx_phy_wait_not_busy(dev);
+	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_write\n");
 
 	val = regval;
-	ret = smsc75xx_write_reg(dev, MII_DATA, val);
+	ret = __smsc75xx_write_reg(dev, MII_DATA, val, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_DATA\n");
 
 	/* set the address, index & direction (write to PHY) */
@@ -259,16 +261,39 @@ static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_WRITE | MII_ACCESS_BUSY;
-	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
+	ret = __smsc75xx_write_reg(dev, MII_ACCESS, addr, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
 
-	ret = smsc75xx_phy_wait_not_busy(dev);
+	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "Timed out writing MII reg %02X\n", idx);
 
 done:
 	mutex_unlock(&dev->phy_mutex);
 }
 
+static int smsc75xx_mdio_read_nopm(struct net_device *netdev, int phy_id,
+				   int idx)
+{
+	return __smsc75xx_mdio_read(netdev, phy_id, idx, 1);
+}
+
+static void smsc75xx_mdio_write_nopm(struct net_device *netdev, int phy_id,
+				     int idx, int regval)
+{
+	__smsc75xx_mdio_write(netdev, phy_id, idx, regval, 1);
+}
+
+static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+{
+	return __smsc75xx_mdio_read(netdev, phy_id, idx, 0);
+}
+
+static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
+				int regval)
+{
+	__smsc75xx_mdio_write(netdev, phy_id, idx, regval, 0);
+}
+
 static int smsc75xx_wait_eeprom(struct usbnet *dev)
 {
 	unsigned long start_time = jiffies;
@@ -1232,6 +1257,32 @@ static int smsc75xx_enter_suspend0(struct usbnet *dev)
 	return 0;
 }
 
+static int smsc75xx_enter_suspend1(struct usbnet *dev)
+{
+	u32 val;
+	int ret;
+
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL");
+
+	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
+	val |= PMT_CTL_SUS_MODE_1;
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
+
+	/* clear wol status, enable energy detection */
+	val &= ~PMT_CTL_WUPS;
+	val |= (PMT_CTL_WUPS_ED | PMT_CTL_ED_EN);
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
+
+	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	return 0;
+}
+
 static int smsc75xx_enter_suspend2(struct usbnet *dev)
 {
 	u32 val;
@@ -1249,18 +1300,61 @@ static int smsc75xx_enter_suspend2(struct usbnet *dev)
 	return 0;
 }
 
+static int smsc75xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
+{
+	struct mii_if_info *mii = &dev->mii;
+	int ret;
+
+	netdev_dbg(dev->net, "enabling PHY wakeup interrupts");
+
+	/* read to clear */
+	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
+	check_warn_return(ret, "Error reading PHY_INT_SRC");
+
+	/* enable interrupt source */
+	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
+	check_warn_return(ret, "Error reading PHY_INT_MASK");
+
+	ret |= mask;
+
+	smsc75xx_mdio_write_nopm(dev->net, mii->phy_id, PHY_INT_MASK, ret);
+
+	return 0;
+}
+
+static int smsc75xx_link_ok_nopm(struct usbnet *dev)
+{
+	struct mii_if_info *mii = &dev->mii;
+	int ret;
+
+	/* first, a dummy read, needed to latch some MII phys */
+	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
+	check_warn_return(ret, "Error reading MII_BMSR");
+
+	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
+	check_warn_return(ret, "Error reading MII_BMSR");
+
+	return !!(ret & BMSR_LSTATUS);
+}
+
 static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
 	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	u32 val, link_up;
 	int ret;
-	u32 val;
 
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error\n");
 
-	/* if no wol options set, enter lowest power SUSPEND2 mode */
-	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
+	/* determine if link is up using only _nopm functions */
+	link_up = smsc75xx_link_ok_nopm(dev);
+
+	/* if no wol options set, or if link is down and we're not waking on
+	 * PHY activity, enter lowest power SUSPEND2 mode
+	 */
+	if (!(pdata->wolopts & SUPPORTED_WAKE) ||
+		!(link_up || (pdata->wolopts & WAKE_PHY))) {
 		netdev_info(dev->net, "entering SUSPEND2 mode\n");
 
 		/* disable energy detect (link up) & wake up events */
@@ -1283,6 +1377,33 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		return smsc75xx_enter_suspend2(dev);
 	}
 
+	if (pdata->wolopts & WAKE_PHY) {
+		ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
+			(PHY_INT_MASK_ANEG_COMP | PHY_INT_MASK_LINK_DOWN));
+		check_warn_return(ret, "error enabling PHY wakeup ints");
+
+		/* if link is down then configure EDPD and enter SUSPEND1,
+		 * otherwise enter SUSPEND0 below
+		 */
+		if (!link_up) {
+			struct mii_if_info *mii = &dev->mii;
+			netdev_info(dev->net, "entering SUSPEND1 mode");
+
+			/* enable energy detect power-down mode */
+			ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id,
+				PHY_MODE_CTRL_STS);
+			check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS");
+
+			ret |= MODE_CTRL_STS_EDPWRDOWN;
+
+			smsc75xx_mdio_write_nopm(dev->net, mii->phy_id,
+				PHY_MODE_CTRL_STS, ret);
+
+			/* enter SUSPEND1 mode */
+			return smsc75xx_enter_suspend1(dev);
+		}
+	}
+
 	if (pdata->wolopts & (WAKE_MCAST | WAKE_ARP)) {
 		int i, filter = 0;
 
@@ -1349,6 +1470,19 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
 	check_warn_return(ret, "Error writing WUCSR\n");
 
+	if (pdata->wolopts & WAKE_PHY) {
+		netdev_info(dev->net, "enabling PHY wakeup\n");
+		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
+		check_warn_return(ret, "Error reading PMT_CTL");
+
+		/* clear wol status, enable energy detection */
+		val &= ~PMT_CTL_WUPS;
+		val |= (PMT_CTL_WUPS_ED | PMT_CTL_ED_EN);
+
+		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+		check_warn_return(ret, "Error writing PMT_CTL");
+	}
+
 	if (pdata->wolopts & WAKE_MAGIC) {
 		netdev_info(dev->net, "enabling magic packet wakeup\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-- 
1.7.10.4
