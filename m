From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 3/3] lan78xx: add ethtool set & get pause functions
Date: Wed, 10 Feb 2016 21:13:40 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404ABA00@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:64144 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbcBJVNl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 16:13:41 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add ethtool operations of set_pauseram and get_pauseparm.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 88 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 83 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 1fd8072..e1e2d8b 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -36,7 +36,7 @@
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
 #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
 #define DRIVER_NAME	"lan78xx"
-#define DRIVER_VERSION	"1.0.2"
+#define DRIVER_VERSION	"1.0.3"
 
 #define TX_TIMEOUT_JIFFIES		(5 * HZ)
 #define THROTTLE_JIFFIES		(HZ / 8)
@@ -281,6 +281,10 @@ struct lan78xx_net {
 	u32			chipid;
 	u32			chiprev;
 	struct mii_bus		*mdiobus;
+
+	int			fc_autoneg;
+	u8			fc_autoneg_control;
+	u8			fc_request_control;
 };
 
 /* use ethtool to change the level for any given device */
@@ -902,11 +906,17 @@ static int lan78xx_update_flowcontrol(struct lan78xx_net *dev, u8 duplex,
 {
 	u32 flow = 0, fct_flow = 0;
 	int ret;
+	u8 cap;
 
-	u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
+	if (dev->fc_autoneg) {
+		cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
+		dev->fc_autoneg_control = cap;
+	} else {
+		cap = dev->fc_request_control;
+	}
 
 	if (cap & FLOW_CTRL_TX)
-		flow = (FLOW_CR_TX_FCEN_ | 0xFFFF);
+		flow |= (FLOW_CR_TX_FCEN_ | 0xFFFF);
 
 	if (cap & FLOW_CTRL_RX)
 		flow |= FLOW_CR_RX_FCEN_;
@@ -916,12 +926,12 @@ static int lan78xx_update_flowcontrol(struct lan78xx_net *dev, u8 duplex,
 	else if (dev->udev->speed == USB_SPEED_HIGH)
 		fct_flow = 0x211;
 
+	ret = lan78xx_write_reg(dev, FCT_FLOW, fct_flow);
+
 	netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s",
 		  (cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
 		  (cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
 
-	ret = lan78xx_write_reg(dev, FCT_FLOW, fct_flow);
-
 	/* threshold value should be set before enabling flow */
 	ret = lan78xx_write_reg(dev, FLOW, flow);
 
@@ -1386,6 +1396,70 @@ static int lan78xx_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 	return ret;
 }
 
+static void lan78xx_get_pause(struct net_device *net,
+			      struct ethtool_pauseparam *pause)
+{
+	struct lan78xx_net *dev = netdev_priv(net);
+	struct phy_device *phydev = net->phydev;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+
+	phy_ethtool_gset(phydev, &ecmd);
+
+	pause->autoneg = dev->fc_autoneg;
+
+	if (dev->fc_autoneg) {
+		if (dev->fc_autoneg_control & FLOW_CTRL_TX)
+			pause->tx_pause = 1;
+
+		if (dev->fc_autoneg_control & FLOW_CTRL_RX)
+			pause->rx_pause = 1;
+	} else {
+		if (dev->fc_request_control & FLOW_CTRL_TX)
+			pause->tx_pause = 1;
+
+		if (dev->fc_request_control & FLOW_CTRL_RX)
+			pause->rx_pause = 1;
+	}
+}
+
+static int lan78xx_set_pause(struct net_device *net,
+			     struct ethtool_pauseparam *pause)
+{
+	struct lan78xx_net *dev = netdev_priv(net);
+	struct phy_device *phydev = net->phydev;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	int ret;
+
+	phy_ethtool_gset(phydev, &ecmd);
+
+	if (pause->autoneg && !ecmd.autoneg) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	dev->fc_request_control = 0;
+	if (pause->rx_pause)
+		dev->fc_request_control |= FLOW_CTRL_RX;
+
+	if (pause->tx_pause)
+		dev->fc_request_control |= FLOW_CTRL_TX;
+
+	if (ecmd.autoneg) {
+		u32 mii_adv;
+
+		ecmd.advertising &= ~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+		mii_adv = (u32)mii_advertise_flowctrl(dev->fc_request_control);
+		ecmd.advertising |= mii_adv_to_ethtool_adv_t(mii_adv);
+		phy_ethtool_sset(phydev, &ecmd);
+	}
+
+	dev->fc_autoneg = pause->autoneg;
+
+	ret = 0;
+exit:
+	return ret;
+}
+
 static const struct ethtool_ops lan78xx_ethtool_ops = {
 	.get_link	= lan78xx_get_link,
 	.nway_reset	= lan78xx_nway_reset,
@@ -1404,6 +1478,8 @@ static const struct ethtool_ops lan78xx_ethtool_ops = {
 	.set_wol	= lan78xx_set_wol,
 	.get_eee	= lan78xx_get_eee,
 	.set_eee	= lan78xx_set_eee,
+	.get_pauseparam	= lan78xx_get_pause,
+	.set_pauseparam	= lan78xx_set_pause,
 };
 
 static int lan78xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -1626,6 +1702,8 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 
 	genphy_config_aneg(phydev);
 
+	dev->fc_autoneg = phydev->autoneg;
+
 	phy_start(phydev);
 
 	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
-- 
2.7.0
