From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 19/20] tg3 / broadcom: Optionally disable TXC if no link
Date: Mon, 2 Nov 2009 16:32:38 -0800
Message-ID: <1257212010.22037@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3429 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757617AbZKCBdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to disable the TXC and RXC reference clocks if link
is not available.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |    5 +++++
 drivers/net/tg3.c          |    1 +
 include/linux/brcmphy.h    |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 7b10495..f63c96a 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -108,6 +108,7 @@
 #define BCM54XX_SHD_SCR3		0x05
 #define  BCM54XX_SHD_SCR3_DEF_CLK125	0x0001
 #define  BCM54XX_SHD_SCR3_DLLAPD_DIS	0x0002
+#define  BCM54XX_SHD_SCR3_TRDDAPD	0x0004
 
 /* 01010: Auto Power-Down */
 #define BCM54XX_SHD_APD			0x0a
@@ -362,6 +363,9 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 	else
 		val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
 
+	if (phydev->dev_flags & PHY_BRCM_DIS_TXCRXC_NOENRGY)
+		val |= BCM54XX_SHD_SCR3_TRDDAPD;
+
 	if (orig != val)
 		bcm54xx_shadow_write(phydev, BCM54XX_SHD_SCR3, val);
 
@@ -409,6 +413,7 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 		bcm54xx_shadow_write(phydev, BCM54XX_SHD_RGMII_MODE, 0);
 
 	if ((phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED) ||
+	    (phydev->dev_flags & PHY_BRCM_DIS_TXCRXC_NOENRGY) ||
 	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		bcm54xx_adjust_rxrefclk(phydev);
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f74bf91..50bb53d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1103,6 +1103,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	case TG3_PHY_ID_BCM50610M:
 		phydev->dev_flags |= PHY_BRCM_CLEAR_RGMII_MODE |
 				     PHY_BRCM_RX_REFCLK_UNUSED |
+				     PHY_BRCM_DIS_TXCRXC_NOENRGY |
 				     PHY_BRCM_AUTO_PWRDWN_ENABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 5943227..2b31b91 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -9,4 +9,5 @@
 #define PHY_BRCM_EXT_IBND_RX_ENABLE	0x00001000
 #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
+#define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
 #define PHY_BCM_FLAGS_VALID		0x80000000
-- 
1.6.4.4


