From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc95xx: support PHY wakeup source
Date: Wed, 21 Nov 2012 13:29:37 +0000
Message-ID: <1353504577-5719-2-git-send-email-steve.glendinning@shawell.net>
References: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:48580 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab2KUN3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 08:29:48 -0500
In-Reply-To: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables LAN9500 family devices to wake from suspend
on either link up or link down events

It also adds _nopm versions of mdio access functions, so we can
safely call them from suspend and resume functions

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  161 +++++++++++++++++++++++++++++++++++++++-----
 drivers/net/usb/smsc95xx.h |   17 +++++
 2 files changed, 161 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 42fc1df..717e9ca 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -48,8 +48,10 @@
 #define SMSC95XX_INTERNAL_PHY_ID	(1)
 #define SMSC95XX_TX_OVERHEAD		(8)
 #define SMSC95XX_TX_OVERHEAD_CSUM	(12)
-#define SUPPORTED_WAKE			(WAKE_UCAST | WAKE_BCAST | \
+#define SUPPORTED_WAKE			(WAKE_PHY | WAKE_UCAST | WAKE_BCAST | \
 					 WAKE_MCAST | WAKE_ARP | WAKE_MAGIC)
+#define PHY_WAKE_INTS			(PHY_INT_MASK_ANEG_COMP_ | \
+					 PHY_INT_MASK_LINK_DOWN_)
 
 #define FEATURE_8_WAKEUP_FILTERS	(0x01)
 #define FEATURE_PHY_NLP_CROSSOVER	(0x02)
@@ -176,14 +178,15 @@ static int smsc95xx_clear_feature(struct usbnet *dev, u32 feature)
 
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
-static int __must_check smsc95xx_phy_wait_not_busy(struct usbnet *dev)
+static int __must_check __smsc95xx_phy_wait_not_busy(struct usbnet *dev,
+						     int in_pm)
 {
 	unsigned long start_time = jiffies;
 	u32 val;
 	int ret;
 
 	do {
-		ret = smsc95xx_read_reg(dev, MII_ADDR, &val);
+		ret = __smsc95xx_read_reg(dev, MII_ADDR, &val, in_pm);
 		check_warn_return(ret, "Error reading MII_ACCESS");
 		if (!(val & MII_BUSY_))
 			return 0;
@@ -192,7 +195,8 @@ static int __must_check smsc95xx_phy_wait_not_busy(struct usbnet *dev)
 	return -EIO;
 }
 
-static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+static int __smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
+				int in_pm)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
@@ -201,20 +205,20 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	ret = smsc95xx_phy_wait_not_busy(dev);
+	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_read");
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_READ_ | MII_BUSY_;
-	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
+	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_ADDR");
 
-	ret = smsc95xx_phy_wait_not_busy(dev);
+	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "Timed out reading MII reg %02X", idx);
 
-	ret = smsc95xx_read_reg(dev, MII_DATA, &val);
+	ret = __smsc95xx_read_reg(dev, MII_DATA, &val, in_pm);
 	check_warn_goto_done(ret, "Error reading MII_DATA");
 
 	ret = (u16)(val & 0xFFFF);
@@ -224,8 +228,8 @@ done:
 	return ret;
 }
 
-static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
-				int regval)
+static void __smsc95xx_mdio_write(struct net_device *netdev, int phy_id,
+				  int idx, int regval, int in_pm)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
@@ -234,27 +238,50 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	ret = smsc95xx_phy_wait_not_busy(dev);
+	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_write");
 
 	val = regval;
-	ret = smsc95xx_write_reg(dev, MII_DATA, val);
+	ret = __smsc95xx_write_reg(dev, MII_DATA, val, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_DATA");
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_ | MII_BUSY_;
-	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
+	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
 	check_warn_goto_done(ret, "Error writing MII_ADDR");
 
-	ret = smsc95xx_phy_wait_not_busy(dev);
+	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
 	check_warn_goto_done(ret, "Timed out writing MII reg %02X", idx);
 
 done:
 	mutex_unlock(&dev->phy_mutex);
 }
 
+static int smsc95xx_mdio_read_nopm(struct net_device *netdev, int phy_id,
+				   int idx)
+{
+	return __smsc95xx_mdio_read(netdev, phy_id, idx, 1);
+}
+
+static void smsc95xx_mdio_write_nopm(struct net_device *netdev, int phy_id,
+				     int idx, int regval)
+{
+	__smsc95xx_mdio_write(netdev, phy_id, idx, regval, 1);
+}
+
+static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+{
+	return __smsc95xx_mdio_read(netdev, phy_id, idx, 0);
+}
+
+static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
+				int regval)
+{
+	__smsc95xx_mdio_write(netdev, phy_id, idx, regval, 0);
+}
+
 static int __must_check smsc95xx_wait_eeprom(struct usbnet *dev)
 {
 	unsigned long start_time = jiffies;
@@ -1067,18 +1094,59 @@ static u16 smsc_crc(const u8 *buffer, size_t len, int filter)
 	return bitrev16(crc16(0xFFFF, buffer, len)) << ((filter % 2) * 16);
 }
 
+static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev)
+{
+	struct mii_if_info *mii = &dev->mii;
+	int ret;
+
+	netdev_info(dev->net, "enabling PHY wakeup interrupts");
+
+	/* read to clear */
+	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
+	check_warn_return(ret, "Error reading PHY_INT_SRC");
+
+	/* enable interrupt source */
+	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
+	check_warn_return(ret, "Error reading PHY_INT_MASK");
+
+	ret |= PHY_WAKE_INTS;
+
+	smsc95xx_mdio_write_nopm(dev->net, mii->phy_id, PHY_INT_MASK, ret);
+
+	return 0;
+}
+
+static int smsc95xx_link_ok_nopm(struct usbnet *dev)
+{
+	struct mii_if_info *mii = &dev->mii;
+
+        /* first, a dummy read, needed to latch some MII phys */
+	int ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
+	check_warn_return(ret, "Error reading MII_BMSR");
+
+	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
+	check_warn_return(ret, "Error reading MII_BMSR");
+
+	return !!(ret & BMSR_LSTATUS);
+}
+
 static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int ret;
-	u32 val;
+	u32 val, link_up;
 
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error");
 
-	/* if no wol options set, enter lowest power SUSPEND2 mode */
-	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
+	/* determine if link is up using only _nopm functions */
+	link_up = smsc95xx_link_ok_nopm(dev);
+
+	/* if no wol options set, or if link is down and we're not waking on
+	 * PHY activity, enter lowest power SUSPEND2 mode */
+	if (!(pdata->wolopts & SUPPORTED_WAKE) ||
+		!(link_up || (pdata->wolopts & WAKE_PHY))) {
 		netdev_info(dev->net, "entering SUSPEND2 mode");
 
 		/* disable energy detect (link up) & wake up events */
@@ -1111,6 +1179,56 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		return 0;
 	}
 
+	if (pdata->wolopts & WAKE_PHY) {
+		ret = smsc95xx_enable_phy_wakeup_interrupts(dev);
+		check_warn_return(ret, "error enabling PHY wakeup ints");
+
+		/* if link is down then configure EDPD and enter SUSPEND1,
+		 * otherwise enter SUSPEND0 below */
+		if (!link_up) {
+			struct mii_if_info *mii = &dev->mii;
+			netdev_info(dev->net, "entering SUSPEND1 mode");
+
+			/* reconfigure link pulse detection timing for
+			 * compatibility with non-standard link partners */
+			if (pdata->features & FEATURE_PHY_NLP_CROSSOVER)
+				smsc95xx_mdio_write_nopm(dev->net, mii->phy_id,
+					PHY_EDPD_CONFIG,
+					PHY_EDPD_CONFIG_DEFAULT);
+
+			/* enable energy detect power-down mode */
+			ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id,
+				PHY_MODE_CTRL_STS);
+			check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS");
+
+			ret |= MODE_CTRL_STS_EDPWRDOWN_;
+
+			smsc95xx_mdio_write_nopm(dev->net, mii->phy_id,
+				PHY_MODE_CTRL_STS, ret);
+
+			/* enter SUSPEND1 mode */
+			ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+			check_warn_return(ret, "Error reading PM_CTRL");
+
+			val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+			val |= PM_CTL_SUS_MODE_1;
+
+			ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+			check_warn_return(ret, "Error writing PM_CTRL");
+
+			/* clear wol status, enable energy detection */
+			val &= ~PM_CTL_WUPS_;
+			val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
+
+			ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+			check_warn_return(ret, "Error writing PM_CTRL");
+
+			smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+			return 0;
+		}
+	}
+
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
 		u32 command[2];
@@ -1249,6 +1367,10 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	val |= PM_CTL_WOL_EN_;
 
+	/* phy energy detect wakeup source */
+	if (pdata->wolopts & WAKE_PHY)
+		val |= PM_CTL_ED_EN_;
+
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	check_warn_return(ret, "Error writing PM_CTRL");
 
@@ -1270,6 +1392,11 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	/* clear wol status */
 	val &= ~PM_CTL_WUPS_;
 	val |= PM_CTL_WUPS_WOL_;
+
+	/* enable energy detection */
+	if (pdata->wolopts & WAKE_PHY)
+		val |= PM_CTL_WUPS_ED_;
+
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	check_warn_return(ret, "Error writing PM_CTRL");
 
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 99f04a2..f360ee3 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -226,6 +226,23 @@
 
 /* Vendor-specific PHY Definitions */
 
+/* EDPD NLP / crossover time configuration (LAN9500A only) */
+#define PHY_EDPD_CONFIG			(16)
+#define PHY_EDPD_CONFIG_TX_NLP_EN_	((u16)0x8000)
+#define PHY_EDPD_CONFIG_TX_NLP_1000_	((u16)0x0000)
+#define PHY_EDPD_CONFIG_TX_NLP_768_	((u16)0x2000)
+#define PHY_EDPD_CONFIG_TX_NLP_512_	((u16)0x4000)
+#define PHY_EDPD_CONFIG_TX_NLP_256_	((u16)0x6000)
+#define PHY_EDPD_CONFIG_RX_1_NLP_	((u16)0x1000)
+#define PHY_EDPD_CONFIG_RX_NLP_64_	((u16)0x0000)
+#define PHY_EDPD_CONFIG_RX_NLP_256_	((u16)0x0400)
+#define PHY_EDPD_CONFIG_RX_NLP_512_	((u16)0x0800)
+#define PHY_EDPD_CONFIG_RX_NLP_1000_	((u16)0x0C00)
+#define PHY_EDPD_CONFIG_EXT_CROSSOVER_	((u16)0x0001)
+#define PHY_EDPD_CONFIG_DEFAULT		(PHY_EDPD_CONFIG_TX_NLP_EN_ | \
+					 PHY_EDPD_CONFIG_TX_NLP_768_ | \
+					 PHY_EDPD_CONFIG_RX_1_NLP_)
+
 /* Mode Control/Status Register */
 #define PHY_MODE_CTRL_STS		(17)
 #define MODE_CTRL_STS_EDPWRDOWN_	((u16)0x2000)
-- 
1.7.10.4
