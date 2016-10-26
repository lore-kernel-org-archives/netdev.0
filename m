From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 1/5] net: phy: broadcom: Add BCM54810 phy entry
Date: Wed, 26 Oct 2016 15:35:57 -0400
Message-ID: <1477510561-17035-2-git-send-email-jon.mason@broadcom.com>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Vikas Soni <vsoni@broadcom.com>
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36029 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755222AbcJZTgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 15:36:16 -0400
Received: by mail-pf0-f181.google.com with SMTP id e6so1999437pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:36:16 -0700 (PDT)
In-Reply-To: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vikas Soni <vsoni@broadcom.com>

Add BCM54810 phy entry

Signed-off-by: Vikas Soni <vsoni@broadcom.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/phy/Kconfig    |  2 +-
 drivers/net/phy/broadcom.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/brcmphy.h    |  7 +++++
 3 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 45f68ea..31967ca 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -217,7 +217,7 @@ config BROADCOM_PHY
 	select BCM_NET_PHYLIB
 	---help---
 	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
-	  BCM5481 and BCM5482 PHYs.
+	  BCM5481, BCM54810 and BCM5482 PHYs.
 
 config CICADA_PHY
 	tristate "Cicada PHYs"
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 870327e..cdce761 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -35,6 +35,35 @@ static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
 	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
 }
 
+static int bcm54810_config(struct phy_device *phydev)
+{
+	int rc;
+
+	/* Disable BroadR-Reach */
+	rc = bcm_phy_write_exp(phydev, BCM54810_EXP_BROADREACH_LRE_MISC_CTL, 0);
+	if (rc < 0)
+		return rc;
+
+	/* SKEW DISABLE */
+	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+				  0xF0E0);
+	if (rc < 0)
+		return rc;
+
+	/* DELAY DISABLE */
+	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+				  0x7000);
+	if (rc < 0)
+		return rc;
+
+	/* DELAY DISABLE */
+	rc = bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, 0);
+	if (rc < 0)
+		return rc;
+
+	return 0;
+}
+
 /* Needs SMDSP clock enabled via bcm54xx_phydsp_config() */
 static int bcm50610_a0_workaround(struct phy_device *phydev)
 {
@@ -207,6 +236,20 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		bcm54xx_adjust_rxrefclk(phydev);
 
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
+		err = bcm54810_config(phydev);
+		if (err)
+			return err;
+
+		reg = phy_read(phydev, MII_BMCR);
+		if (reg < 0)
+			return reg;
+
+		err = phy_write(phydev, MII_BMCR, reg & ~BMCR_PDOWN);
+		if (err)
+			return err;
+	}
+
 	bcm54xx_phydsp_config(phydev);
 
 	return 0;
@@ -334,6 +377,15 @@ static int bcm5481_config_aneg(struct phy_device *phydev)
 		phy_write(phydev, 0x18, reg);
 	}
 
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810 &&
+	    phydev->dev_flags & PHY_BRCM_EXP_LANE_SWAP) {
+		/* LANE SWAP */
+		ret = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_SEL_ER + 0x9,
+					0x11B);
+		if (ret < 0)
+			return ret;
+	}
+
 	return ret;
 }
 
@@ -521,6 +573,18 @@ static struct phy_driver broadcom_drivers[] = {
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
 }, {
+	.phy_id         = PHY_ID_BCM54810,
+	.phy_id_mask    = 0xfffffff0,
+	.name           = "Broadcom BCM54810",
+	.features       = PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init    = bcm54xx_config_init,
+	.config_aneg    = bcm5481_config_aneg,
+	.read_status    = genphy_read_status,
+	.ack_interrupt  = bcm_phy_ack_intr,
+	.config_intr    = bcm_phy_config_intr,
+}, {
 	.phy_id		= PHY_ID_BCM5482,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
@@ -603,6 +667,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM54616S, 0xfffffff0 },
 	{ PHY_ID_BCM5464, 0xfffffff0 },
 	{ PHY_ID_BCM5481, 0xfffffff0 },
+	{ PHY_ID_BCM54810, 0xfffffff0 },
 	{ PHY_ID_BCM5482, 0xfffffff0 },
 	{ PHY_ID_BCM50610, 0xfffffff0 },
 	{ PHY_ID_BCM50610M, 0xfffffff0 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index e7a3d9d..40e6ead 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -13,6 +13,7 @@
 #define PHY_ID_BCM5241			0x0143bc30
 #define PHY_ID_BCMAC131			0x0143bc70
 #define PHY_ID_BCM5481			0x0143bca0
+#define PHY_ID_BCM54810			0x03625d00
 #define PHY_ID_BCM5482			0x0143bcb0
 #define PHY_ID_BCM5411			0x00206070
 #define PHY_ID_BCM5421			0x002060e0
@@ -55,6 +56,8 @@
 #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
+#define PHY_BRCM_EXP_LANE_SWAP		0x00010000
+
 /* Broadcom BCM7xxx specific workarounds */
 #define PHY_BRCM_7XXX_REV(x)		(((x) >> 8) & 0xff)
 #define PHY_BRCM_7XXX_PATCH(x)		((x) & 0xff)
@@ -187,6 +190,10 @@
 #define BCM5482_SSD_SGMII_SLAVE_EN	0x0002	/* Slave mode enable */
 #define BCM5482_SSD_SGMII_SLAVE_AD	0x0001	/* Slave auto-detection */
 
+/* BCM54810 Registers */
+#define BCM54810_EXP_BROADREACH_LRE_MISC_CTL	(MII_BCM54XX_EXP_SEL_ER + 0x90)
+#define BCM54810_SHD_CLK_CTL			0x3
+
 
 /*****************************************************************************/
 /* Fast Ethernet Transceiver definitions. */
-- 
2.7.4
