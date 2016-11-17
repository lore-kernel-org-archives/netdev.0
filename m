From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net-next] lan78xx: relocate mdix setting to phy driver
Date: Thu, 17 Nov 2016 22:10:02 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40966AA4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:31799 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752315AbcKQWKE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:10:04 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Relocate mdix code to phy driver to be called at config_init().

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/microchip.c | 36 +++++++++++++++++++++-
 drivers/net/usb/lan78xx.c   | 73 ++-------------------------------------------
 2 files changed, 38 insertions(+), 71 deletions(-)

diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 7c00e50..eb4db22 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -106,6 +106,40 @@ static int lan88xx_set_wol(struct phy_device *phydev,
 	return 0;
 }
 
+static void lan88xx_set_mdix(struct phy_device *phydev)
+{
+	int buf;
+	int val;
+
+	switch (phydev->mdix) {
+	case ETH_TP_MDI:
+		val = LAN88XX_EXT_MODE_CTRL_MDI_;
+		break;
+	case ETH_TP_MDI_X:
+		val = LAN88XX_EXT_MODE_CTRL_MDI_X_;
+		break;
+	case ETH_TP_MDI_AUTO:
+		val = LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_;
+		break;
+	default:
+		return;
+	}
+
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
+	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+	buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+	buf |= val;
+	phy_write(phydev, LAN88XX_EXT_MODE_CTRL, buf);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
+}
+
+static int lan88xx_config_aneg(struct phy_device *phydev)
+{
+	lan88xx_set_mdix(phydev);
+
+	return genphy_config_aneg(phydev);
+}
+
 static struct phy_driver microchip_phy_driver[] = {
 {
 	.phy_id		= 0x0007c130,
@@ -120,7 +154,7 @@ static struct phy_driver microchip_phy_driver[] = {
 	.remove		= lan88xx_remove,
 
 	.config_init	= genphy_config_init,
-	.config_aneg	= genphy_config_aneg,
+	.config_aneg	= lan88xx_config_aneg,
 	.read_status	= genphy_read_status,
 
 	.ack_interrupt	= lan88xx_phy_ack_interrupt,
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index cf2857f..0c459e9 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1471,62 +1471,12 @@ static void lan78xx_set_msglevel(struct net_device *net, u32 level)
 	dev->msg_enable = level;
 }
 
-static int lan78xx_get_mdix_status(struct net_device *net)
-{
-	struct phy_device *phydev = net->phydev;
-	int buf;
-
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
-	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
-
-	return buf;
-}
-
-static void lan78xx_set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
-{
-	struct lan78xx_net *dev = netdev_priv(net);
-	struct phy_device *phydev = net->phydev;
-	int buf;
-
-	if (mdix_ctrl == ETH_TP_MDI) {
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_1);
-		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_MDI_);
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_0);
-	} else if (mdix_ctrl == ETH_TP_MDI_X) {
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_1);
-		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_MDI_X_);
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_0);
-	} else if (mdix_ctrl == ETH_TP_MDI_AUTO) {
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_1);
-		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
-		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-			  LAN88XX_EXT_PAGE_SPACE_0);
-	}
-	dev->mdix_ctrl = mdix_ctrl;
-}
-
 static int lan78xx_get_link_ksettings(struct net_device *net,
 				      struct ethtool_link_ksettings *cmd)
 {
 	struct lan78xx_net *dev = netdev_priv(net);
 	struct phy_device *phydev = net->phydev;
 	int ret;
-	int buf;
 
 	ret = usb_autopm_get_interface(dev->intf);
 	if (ret < 0)
@@ -1534,20 +1484,6 @@ static int lan78xx_get_link_ksettings(struct net_device *net,
 
 	ret = phy_ethtool_ksettings_get(phydev, cmd);
 
-	buf = lan78xx_get_mdix_status(net);
-
-	buf &= LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-	if (buf == LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_) {
-		cmd->base.eth_tp_mdix = ETH_TP_MDI_AUTO;
-		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
-	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_) {
-		cmd->base.eth_tp_mdix = ETH_TP_MDI;
-		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI;
-	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_X_) {
-		cmd->base.eth_tp_mdix = ETH_TP_MDI_X;
-		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_X;
-	}
-
 	usb_autopm_put_interface(dev->intf);
 
 	return ret;
@@ -1565,9 +1501,6 @@ static int lan78xx_set_link_ksettings(struct net_device *net,
 	if (ret < 0)
 		return ret;
 
-	if (dev->mdix_ctrl != cmd->base.eth_tp_mdix_ctrl)
-		lan78xx_set_mdix_status(net, cmd->base.eth_tp_mdix_ctrl);
-
 	/* change speed & duplex */
 	ret = phy_ethtool_ksettings_set(phydev, cmd);
 
@@ -2019,6 +1952,9 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		phydev->irq = 0;
 	netdev_dbg(dev->net, "phydev->irq = %d\n", phydev->irq);
 
+	/* set to AUTOMDIX */
+	phydev->mdix = ETH_TP_MDI_AUTO;
+
 	ret = phy_connect_direct(dev->net, phydev,
 				 lan78xx_link_status_change,
 				 PHY_INTERFACE_MODE_GMII);
@@ -2028,9 +1964,6 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		return -EIO;
 	}
 
-	/* set to AUTOMDIX */
-	lan78xx_set_mdix_status(dev->net, ETH_TP_MDI_AUTO);
-
 	/* MAC doesn't support 1000T Half */
 	phydev->supported &= ~SUPPORTED_1000baseT_Half;
 
-- 
2.7.4
