From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 15/20] tg3 / broadcom: Add PHY_BRCM_CLEAR_RGMII_MODE
 flag
Date: Mon, 2 Nov 2009 16:30:40 -0800
Message-ID: <1257212005.22025@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1278 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757595AbZKCBdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom 50610M parts changed the default definitions of the RGMII mode
shadow register.  The 5785 needs the RGMII mode selection bits [4:3]
cleared.

The default value of the remaining bits in this register are zero.
Rather than unnecessarily burn an extra bit in the dev_flags member in
an attempt to enumerate all possible combinations, this patch take a
more course grained approach and labels the option as "clear all bits".

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |    6 ++++++
 drivers/net/tg3.c          |    1 +
 include/linux/brcmphy.h    |    1 +
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index ace0ccc..5d2a2e9 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -105,6 +105,7 @@
 #define BCM5482_SHD_LEDS1_LED3(src)	((src & 0xf) << 4)
 					/* LED1 / ~LINKSPD[1] selector */
 #define BCM5482_SHD_LEDS1_LED1(src)	((src & 0xf) << 0)
+#define BCM54XX_SHD_RGMII_MODE	0x0b	/* 01011: RGMII Mode Selector */
 #define BCM5482_SHD_SSD		0x14	/* 10100: Secondary SerDes control */
 #define BCM5482_SHD_SSD_LEDM	0x0008	/* SSD LED Mode enable */
 #define BCM5482_SHD_SSD_EN	0x0001	/* SSD enable */
@@ -330,6 +331,11 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
+	if ((BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
+	     BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) &&
+	    (phydev->dev_flags & PHY_BRCM_CLEAR_RGMII_MODE))
+		bcm54xx_shadow_write(phydev, BCM54XX_SHD_RGMII_MODE, 0);
+
 	bcm54xx_phydsp_config(phydev);
 
 	return 0;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0aecd07..e7128f6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1100,6 +1100,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 		break;
 	case TG3_PHY_ID_BCM50610:
 	case TG3_PHY_ID_BCM50610M:
+		phydev->dev_flags |= PHY_BRCM_CLEAR_RGMII_MODE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index daa1480..6e7ffce 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -8,4 +8,5 @@
 #define PHY_BRCM_STD_IBND_DISABLE	0x00000800
 #define PHY_BRCM_EXT_IBND_RX_ENABLE	0x00001000
 #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
+#define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BCM_FLAGS_VALID		0x80000000
-- 
1.6.4.4


