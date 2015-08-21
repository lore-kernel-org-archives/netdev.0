From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 2/2] lan78xx: update eee code
Date: Fri, 21 Aug 2015 21:41:00 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D5480D9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:35956 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752488AbbHUVlB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 17:41:01 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch to pdate EEE code.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 44 ++++++++++++++++++++++++--------------------
 drivers/net/usb/lan78xx.h | 22 +++++++++++-----------
 2 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 4bcbf28..af102b0 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1296,38 +1296,37 @@ static int lan78xx_get_eee(struct net_device *net, struct ethtool_eee *edata)
 	if (ret < 0)
 		return ret;
 
+	buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
+			       PHY_MMD_DEV_7, PHY_EEE_ADVERTISEMENT);
+	adv = mmd_eee_adv_to_ethtool_adv_t(buf);
+	buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
+			       PHY_MMD_DEV_7, PHY_EEE_LP_ADVERTISEMENT);
+	lpadv = mmd_eee_adv_to_ethtool_adv_t(buf);
+
 	ret = lan78xx_read_reg(dev, MAC_CR, &buf);
 	if (buf & MAC_CR_EEE_EN_) {
-		buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
-				       PHY_MMD_DEV_7, PHY_EEE_ADVERTISEMENT);
-		adv = mmd_eee_adv_to_ethtool_adv_t(buf);
-		buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
-				       PHY_MMD_DEV_7, PHY_EEE_LP_ADVERTISEMENT);
-		lpadv = mmd_eee_adv_to_ethtool_adv_t(buf);
-
 		edata->eee_enabled = true;
-		edata->supported = true;
 		edata->eee_active = !!(adv & lpadv);
-		edata->advertised = adv;
-		edata->lp_advertised = lpadv;
 		edata->tx_lpi_enabled = true;
 		/* EEE_TX_LPI_REQ_DLY & tx_lpi_timer are same uSec unit */
 		ret = lan78xx_read_reg(dev, EEE_TX_LPI_REQ_DLY, &buf);
 		edata->tx_lpi_timer = buf;
 	} else {
-		buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
-				       PHY_MMD_DEV_7, PHY_EEE_LP_ADVERTISEMENT);
-		lpadv = mmd_eee_adv_to_ethtool_adv_t(buf);
 
 		edata->eee_enabled = false;
 		edata->eee_active = false;
-		edata->supported = false;
-		edata->advertised = 0;
-		edata->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(lpadv);
 		edata->tx_lpi_enabled = false;
 		edata->tx_lpi_timer = 0;
 	}
 
+	edata->supported = ADVERTISED_100baseT_Full |
+			   ADVERTISED_1000baseT_Full;
+
+	edata->advertised = ADVERTISED_100baseT_Full |
+			    ADVERTISED_1000baseT_Full;
+
+	edata->lp_advertised = lpadv;
+
 	usb_autopm_put_interface(dev->intf);
 
 	return 0;
@@ -1351,6 +1350,9 @@ static int lan78xx_set_eee(struct net_device *net, struct ethtool_eee *edata)
 		buf = ethtool_adv_to_mmd_eee_adv_t(edata->advertised);
 		lan78xx_mmd_write(dev->net, dev->mii.phy_id,
 				  PHY_MMD_DEV_7, PHY_EEE_ADVERTISEMENT, buf);
+
+		buf = (u32)edata->tx_lpi_timer;
+		ret = lan78xx_write_reg(dev, EEE_TX_LPI_REQ_DLY, buf);
 	} else {
 		ret = lan78xx_read_reg(dev, MAC_CR, &buf);
 		buf &= ~MAC_CR_EEE_EN_;
@@ -1641,6 +1643,12 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	mii->mdio_write(mii->dev, mii->phy_id, MII_CTRL1000,
 			temp & ~ADVERTISE_1000HALF);
 
+	/* Set EEE advertise */
+	lan78xx_mmd_write(dev->net, dev->mii.phy_id,
+			  PHY_MMD_DEV_7, PHY_EEE_ADVERTISEMENT,
+			  PHY_EEE_ADVERTISEMENT_1000BT_EEE_ |
+			  PHY_EEE_ADVERTISEMENT_100BT_EEE_);
+
 	/* clear interrupt */
 	mii->mdio_read(mii->dev, mii->phy_id, PHY_VTSE_INT_STS);
 	mii->mdio_write(mii->dev, mii->phy_id, PHY_VTSE_INT_MASK,
@@ -2016,10 +2024,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
-	/* enable on PHY */
-	if (buf & MAC_CR_EEE_EN_)
-		lan78xx_mmd_write(dev->net, dev->mii.phy_id, 0x07, 0x3C, 0x06);
-
 	/* enable PHY interrupts */
 	ret = lan78xx_read_reg(dev, INT_EP_CTL, &buf);
 	buf |= INT_ENP_PHY_INT;
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index ae7562e..95e721b 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -1047,23 +1047,23 @@
 #define PHY_MMD_DEV_3				3
 
 #define PHY_EEE_PCS_STATUS			(0x1)
-#define PHY_EEE_PCS_STATUS_TX_LPI_RCVD_		((WORD)0x0800)
-#define PHY_EEE_PCS_STATUS_RX_LPI_RCVD_		((WORD)0x0400)
-#define PHY_EEE_PCS_STATUS_TX_LPI_IND_		((WORD)0x0200)
-#define PHY_EEE_PCS_STATUS_RX_LPI_IND_		((WORD)0x0100)
-#define PHY_EEE_PCS_STATUS_PCS_RCV_LNK_STS_	((WORD)0x0004)
+#define PHY_EEE_PCS_STATUS_TX_LPI_RCVD_		(0x0800)
+#define PHY_EEE_PCS_STATUS_RX_LPI_RCVD_		(0x0400)
+#define PHY_EEE_PCS_STATUS_TX_LPI_IND_		(0x0200)
+#define PHY_EEE_PCS_STATUS_RX_LPI_IND_		(0x0100)
+#define PHY_EEE_PCS_STATUS_PCS_RCV_LNK_STS_	(0x0004)
 
 #define PHY_EEE_CAPABILITIES			(0x14)
-#define PHY_EEE_CAPABILITIES_1000BT_EEE_	((WORD)0x0004)
-#define PHY_EEE_CAPABILITIES_100BT_EEE_		((WORD)0x0002)
+#define PHY_EEE_CAPABILITIES_1000BT_EEE_	(0x0004)
+#define PHY_EEE_CAPABILITIES_100BT_EEE_		(0x0002)
 
 #define PHY_MMD_DEV_7				7
 
 #define PHY_EEE_ADVERTISEMENT			(0x3C)
-#define PHY_EEE_ADVERTISEMENT_1000BT_EEE_	((WORD)0x0004)
-#define PHY_EEE_ADVERTISEMENT_100BT_EEE_	((WORD)0x0002)
+#define PHY_EEE_ADVERTISEMENT_1000BT_EEE_	(0x0004)
+#define PHY_EEE_ADVERTISEMENT_100BT_EEE_	(0x0002)
 
 #define PHY_EEE_LP_ADVERTISEMENT		(0x3D)
-#define PHY_EEE_1000BT_EEE_CAPABLE_		((WORD)0x0004)
-#define PHY_EEE_100BT_EEE_CAPABLE_		((WORD)0x0002)
+#define PHY_EEE_1000BT_EEE_CAPABLE_		(0x0004)
+#define PHY_EEE_100BT_EEE_CAPABLE_		(0x0002)
 #endif /* _LAN78XX_H */
-- 
2.1.4
