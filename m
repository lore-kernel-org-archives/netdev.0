From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 3/3] smsc95xx: Add mdix control via ethtool
Date: Fri, 2 Sep 2016 20:34:22 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D409100AE@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:8970 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754011AbcIBUeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:34:24 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add mdix control through ethtool.

Signed-off-by: Woojung Huh <Woojung.huh@gmail.com>
---
 drivers/net/usb/smsc95xx.c | 109 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 106 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index dc989a8..831aa33 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -33,7 +33,7 @@
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
-#define SMSC_DRIVER_VERSION		"1.0.4"
+#define SMSC_DRIVER_VERSION		"1.0.5"
 #define HS_USB_PKT_SIZE			(512)
 #define FS_USB_PKT_SIZE			(64)
 #define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
@@ -64,6 +64,7 @@
 #define CARRIER_CHECK_DELAY (2 * HZ)
 
 struct smsc95xx_priv {
+	u32 chip_id;
 	u32 mac_cr;
 	u32 hash_hi;
 	u32 hash_lo;
@@ -71,6 +72,7 @@ struct smsc95xx_priv {
 	spinlock_t mac_cr_lock;
 	u8 features;
 	u8 suspend_flags;
+	u8 mdix_ctrl;
 	bool link_ok;
 	struct delayed_work carrier_check;
 	struct usbnet *dev;
@@ -782,14 +784,113 @@ static int smsc95xx_ethtool_set_wol(struct net_device *net,
 	return ret;
 }
 
+static int get_mdix_status(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u32 val;
+	int buf;
+
+	buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, SPECIAL_CTRL_STS);
+	if (buf & SPECIAL_CTRL_STS_OVRRD_AMDIX_) {
+		if (buf & SPECIAL_CTRL_STS_AMDIX_ENABLE_)
+			return ETH_TP_MDI_AUTO;
+		else if (buf & SPECIAL_CTRL_STS_AMDIX_STATE_)
+			return ETH_TP_MDI_X;
+	} else {
+		buf = smsc95xx_read_reg(dev, STRAP_STATUS, &val);
+		if (val & STRAP_STATUS_AMDIX_EN_)
+			return ETH_TP_MDI_AUTO;
+	}
+
+	return ETH_TP_MDI;
+}
+
+static void set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	int buf;
+
+	if ((pdata->chip_id == ID_REV_CHIP_ID_9500A_) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_9530_) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_89530_) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_9730_)) {
+		/* Extend Manual AutoMDIX timer for 9500A/9500Ai */
+		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
+					 PHY_EDPD_CONFIG);
+		buf |= PHY_EDPD_CONFIG_EXT_CROSSOVER_;
+		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
+				    PHY_EDPD_CONFIG, buf);
+	}
+
+	if (mdix_ctrl == ETH_TP_MDI) {
+		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
+					 SPECIAL_CTRL_STS);
+		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX_;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
+			 SPECIAL_CTRL_STS_AMDIX_STATE_);
+		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
+				    SPECIAL_CTRL_STS, buf);
+	} else if (mdix_ctrl == ETH_TP_MDI_X) {
+		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
+					 SPECIAL_CTRL_STS);
+		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX_;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
+			 SPECIAL_CTRL_STS_AMDIX_STATE_);
+		buf |= SPECIAL_CTRL_STS_AMDIX_STATE_;
+		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
+				    SPECIAL_CTRL_STS, buf);
+	} else if (mdix_ctrl == ETH_TP_MDI_AUTO) {
+		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
+					 SPECIAL_CTRL_STS);
+		buf &= ~SPECIAL_CTRL_STS_OVRRD_AMDIX_;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
+			 SPECIAL_CTRL_STS_AMDIX_STATE_);
+		buf |= SPECIAL_CTRL_STS_AMDIX_ENABLE_;
+		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
+				    SPECIAL_CTRL_STS, buf);
+	}
+	pdata->mdix_ctrl = mdix_ctrl;
+}
+
+static int smsc95xx_get_settings(struct net_device *net,
+				 struct ethtool_cmd *cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	int retval;
+
+	retval = usbnet_get_settings(net, cmd);
+
+	cmd->eth_tp_mdix = pdata->mdix_ctrl;
+	cmd->eth_tp_mdix_ctrl = pdata->mdix_ctrl;
+
+	return retval;
+}
+
+static int smsc95xx_set_settings(struct net_device *net,
+				 struct ethtool_cmd *cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	int retval;
+
+	if (pdata->mdix_ctrl != cmd->eth_tp_mdix_ctrl)
+		set_mdix_status(net, cmd->eth_tp_mdix_ctrl);
+
+	retval = usbnet_set_settings(net, cmd);
+
+	return retval;
+}
+
 static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
 	.get_drvinfo	= usbnet_get_drvinfo,
 	.get_msglevel	= usbnet_get_msglevel,
 	.set_msglevel	= usbnet_set_msglevel,
-	.get_settings	= usbnet_get_settings,
-	.set_settings	= usbnet_set_settings,
+	.get_settings	= smsc95xx_get_settings,
+	.set_settings	= smsc95xx_set_settings,
 	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
@@ -1194,6 +1295,8 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (ret < 0)
 		return ret;
 	val >>= 16;
+	pdata->chip_id = val;
+	pdata->mdix_ctrl = get_mdix_status(dev->net);
 
 	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
 	    (val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
-- 
2.7.4
