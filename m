From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: phy: broadcom: Add support code for downshift/Wirespeed
Date: Tue, 22 Nov 2016 11:40:55 -0800
Message-ID: <20161122194058.29820-3-f.fainelli@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36411 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933857AbcKVTlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so2891971pgx.3
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:11 -0800 (PST)
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom's Wirespeed feature allows us to configure how auto-negotiation
should behave with fewer working pairs of wires on a cable. Add support
code for retrieving and setting such downshift counters using the
recently added ethtool downshift tunables.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm-phy-lib.c | 86 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h |  5 +++
 include/linux/brcmphy.h       | 10 +++++
 3 files changed, 101 insertions(+)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index 18e11b3a0f41..d742894816f6 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -225,6 +225,92 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
 }
 EXPORT_SYMBOL_GPL(bcm_phy_enable_eee);
 
+int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count)
+{
+	int val;
+
+	val = bcm54xx_auxctl_read(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
+	if (val < 0)
+		return val;
+
+	/* Check if wirespeed is enabled or not */
+	if (!(val & MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN)) {
+		*count = DOWNSHIFT_DEV_DISABLE;
+		return 0;
+	}
+
+	val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_SCR2);
+	if (val < 0)
+		return val;
+
+	/* Downgrade after one link attempt */
+	if (val & BCM54XX_SHD_SCR2_WSPD_RTRY_DIS) {
+		*count = 1;
+	} else {
+		/* Downgrade after configured retry count */
+		val >>= BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_SHIFT;
+		val &= BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_MASK;
+		*count = val + BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_OFFSET;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bcm_phy_downshift_get);
+
+int bcm_phy_downshift_set(struct phy_device *phydev, u8 count)
+{
+	int val = 0, ret = 0;
+
+	/* Range check the number given */
+	if (count - BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_OFFSET >
+	    BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_MASK &&
+	    count != DOWNSHIFT_DEV_DEFAULT_COUNT) {
+		return -ERANGE;
+	}
+
+	val = bcm54xx_auxctl_read(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
+	if (val < 0)
+		return val;
+
+	/* Se the write enable bit */
+	val |= MII_BCM54XX_AUXCTL_MISC_WREN;
+
+	if (count == DOWNSHIFT_DEV_DISABLE) {
+		val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN;
+		return bcm54xx_auxctl_write(phydev,
+					    MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+					    val);
+	} else {
+		val |= MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN;
+		ret = bcm54xx_auxctl_write(phydev,
+					   MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+					   val);
+		if (ret < 0)
+			return ret;
+	}
+
+	val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_SCR2);
+	val &= ~(BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_MASK <<
+		 BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_SHIFT |
+		 BCM54XX_SHD_SCR2_WSPD_RTRY_DIS);
+
+	switch (count) {
+	case 1:
+		val |= BCM54XX_SHD_SCR2_WSPD_RTRY_DIS;
+		break;
+	case DOWNSHIFT_DEV_DEFAULT_COUNT:
+		val |= 1 << BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_SHIFT;
+		break;
+	default:
+		val |= (count - BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_OFFSET) <<
+			BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_SHIFT;
+		break;
+	}
+
+	return bcm_phy_write_shadow(phydev, BCM54XX_SHD_SCR2, val);
+}
+EXPORT_SYMBOL_GPL(bcm_phy_downshift_set);
+
 MODULE_DESCRIPTION("Broadcom PHY Library");
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Broadcom Corporation");
diff --git a/drivers/net/phy/bcm-phy-lib.h b/drivers/net/phy/bcm-phy-lib.h
index 31cb4fdf5d5a..3f492e629094 100644
--- a/drivers/net/phy/bcm-phy-lib.h
+++ b/drivers/net/phy/bcm-phy-lib.h
@@ -37,4 +37,9 @@ int bcm_phy_config_intr(struct phy_device *phydev);
 int bcm_phy_enable_apd(struct phy_device *phydev, bool dll_pwr_down);
 
 int bcm_phy_enable_eee(struct phy_device *phydev);
+
+int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count);
+
+int bcm_phy_downshift_set(struct phy_device *phydev, u8 count);
+
 #endif /* _LINUX_BCM_PHY_LIB_H */
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 848dc508ef57..f9f8aaf9c943 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -114,6 +114,7 @@
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
 #define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN	(1 << 8)
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN	(1 << 4)
 
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MASK	0x0007
 
@@ -130,6 +131,7 @@
 #define BCM_LED_SRC_INTR	0x6
 #define BCM_LED_SRC_QUALITY	0x7
 #define BCM_LED_SRC_RCVLED	0x8
+#define BCM_LED_SRC_WIRESPEED	0x9
 #define BCM_LED_SRC_MULTICOLOR1	0xa
 #define BCM_LED_SRC_OPENSHORT	0xb
 #define BCM_LED_SRC_OFF		0xe	/* Tied high */
@@ -141,6 +143,14 @@
  * Shadow values go into bits [14:10] of register 0x1c to select a shadow
  * register to access.
  */
+
+/* 00100: Reserved control register 2 */
+#define BCM54XX_SHD_SCR2		0x04
+#define  BCM54XX_SHD_SCR2_WSPD_RTRY_DIS	0x100
+#define  BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_SHIFT	2
+#define  BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_OFFSET	2
+#define  BCM54XX_SHD_SCR2_WSPD_RTRY_LMT_MASK	0x7
+
 /* 00101: Spare Control Register 3 */
 #define BCM54XX_SHD_SCR3		0x05
 #define  BCM54XX_SHD_SCR3_DEF_CLK125	0x0001
-- 
2.9.3
