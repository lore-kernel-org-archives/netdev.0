From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 5/6] lan78xx: Create lan78xx_get_mdix_status() and
 lan78xx_set_mdix_status() for MDIX control.
Date: Wed, 16 Sep 2015 23:41:14 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D55C6AF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:17164 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753034AbbIPXlP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:41:15 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create lan78xx_get_mdix_status() and lan78xx_set_mdix_status() for MDIX control.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 90 +++++++++++++++++++++++++++--------------------
 1 file changed, 52 insertions(+), 38 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 517264d..9102c71 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1175,6 +1175,55 @@ static void lan78xx_set_msglevel(struct net_device *net, u32 level)
 	dev->msg_enable = level;
 }
 
+static int lan78xx_get_mdix_status(struct net_device *net)
+{
+	struct phy_device *phydev = net->phydev;
+	int buf;
+
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
+	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
+
+	return buf;
+}
+
+static void lan78xx_set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
+{
+	struct lan78xx_net *dev = netdev_priv(net);
+	struct phy_device *phydev = net->phydev;
+	int buf;
+
+	if (mdix_ctrl == ETH_TP_MDI) {
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_1);
+		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+			  buf | LAN88XX_EXT_MODE_CTRL_MDI_);
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_0);
+	} else if (mdix_ctrl == ETH_TP_MDI_X) {
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_1);
+		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+			  buf | LAN88XX_EXT_MODE_CTRL_MDI_X_);
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_0);
+	} else if (mdix_ctrl == ETH_TP_MDI_AUTO) {
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_1);
+		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+			  buf | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
+		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+			  LAN88XX_EXT_PAGE_SPACE_0);
+	}
+	dev->mdix_ctrl = mdix_ctrl;
+}
+
 static int lan78xx_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct lan78xx_net *dev = netdev_priv(net);
@@ -1188,9 +1237,7 @@ static int lan78xx_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 
 	ret = phy_ethtool_gset(phydev, cmd);
 
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
-	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
+	buf = lan78xx_get_mdix_status(net);
 
 	buf &= LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
 	if (buf == LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_) {
@@ -1221,34 +1268,7 @@ static int lan78xx_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 		return ret;
 
 	if (dev->mdix_ctrl != cmd->eth_tp_mdix_ctrl) {
-		if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI) {
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_1);
-			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-				  temp | LAN88XX_EXT_MODE_CTRL_MDI_);
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_0);
-		} else if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_1);
-			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-				  temp | LAN88XX_EXT_MODE_CTRL_MDI_X_);
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_0);
-		} else if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO) {
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_1);
-			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-				  temp | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
-			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
-				  LAN88XX_EXT_PAGE_SPACE_0);
-		}
+		lan78xx_set_mdix_status(net, cmd->eth_tp_mdix_ctrl);
 	}
 
 	/* change speed & duplex */
@@ -1504,13 +1524,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	}
 
 	/* set to AUTOMDIX */
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
-	ret = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-	ret &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-	phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-		  ret | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
-	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
-	dev->mdix_ctrl = ETH_TP_MDI_AUTO;
+	lan78xx_set_mdix_status(dev->net, ETH_TP_MDI_AUTO);
 
 	/* MAC doesn't support 1000T Half */
 	phydev->supported &= ~SUPPORTED_1000baseT_Half;
-- 
2.1.4
