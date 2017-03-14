From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 02/12] net: phy: bcm7xxx: add support for 28nm EPHY
Date: Mon, 13 Mar 2017 17:41:32 -0700
Message-ID: <20170314004142.4746-3-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds support for the internal fast ethernet 10/100 PHY
found in the BCM7260, BCM7268, and BCM7271 devices.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 215 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/brcmphy.h   |   3 +
 2 files changed, 216 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index d1c2614dad3a..caa9f6e17f34 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -1,7 +1,7 @@
 /*
  * Broadcom BCM7xxx internal transceivers support.
  *
- * Copyright (C) 2014, Broadcom Corporation
+ * Copyright (C) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -19,7 +19,7 @@
 
 /* Broadcom BCM7xxx internal PHY registers */
 
-/* 40nm only register definitions */
+/* EPHY only register definitions */
 #define MII_BCM7XXX_100TX_AUX_CTL	0x10
 #define MII_BCM7XXX_100TX_FALSE_CAR	0x13
 #define MII_BCM7XXX_100TX_DISC		0x14
@@ -27,6 +27,19 @@
 #define  MII_BCM7XXX_64CLK_MDIO		BIT(12)
 #define MII_BCM7XXX_TEST		0x1f
 #define  MII_BCM7XXX_SHD_MODE_2		BIT(2)
+#define MII_BCM7XXX_SHD_2_ADDR_CTRL	0xe
+#define MII_BCM7XXX_SHD_2_CTRL_STAT	0xf
+#define MII_BCM7XXX_SHD_2_BIAS_TRIM	0x1a
+#define MII_BCM7XXX_SHD_3_AN_EEE_ADV	0x3
+#define MII_BCM7XXX_SHD_3_PCS_CTRL_2	0x6
+#define  MII_BCM7XXX_PCS_CTRL_2_DEF	0x4400
+#define MII_BCM7XXX_SHD_3_AN_STAT	0xb
+#define  MII_BCM7XXX_AN_NULL_MSG_EN	BIT(0)
+#define  MII_BCM7XXX_AN_EEE_EN		BIT(1)
+#define MII_BCM7XXX_SHD_3_EEE_THRESH	0xe
+#define  MII_BCM7XXX_EEE_THRESH_DEF	0x50
+#define MII_BCM7XXX_SHD_3_TL4		0x23
+#define  MII_BCM7XXX_TL4_RST_MSK	(BIT(2) | BIT(1))
 
 /* 28nm only register definitions */
 #define MISC_ADDR(base, channel)	base, channel
@@ -286,6 +299,181 @@ static int phy_set_clr_bits(struct phy_device *dev, int location,
 	return v;
 }
 
+static int bcm7xxx_28nm_ephy_01_afe_config_init(struct phy_device *phydev)
+{
+	int ret;
+
+	/* set shadow mode 2 */
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
+			       MII_BCM7XXX_SHD_MODE_2, 0);
+	if (ret < 0)
+		return ret;
+
+	/* Set current trim values INT_trim = -1, Ext_trim =0 */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+	/* Cal reset */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_TL4);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			       MII_BCM7XXX_TL4_RST_MSK, 0);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+	/* Cal reset disable */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_TL4);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			       0, MII_BCM7XXX_TL4_RST_MSK);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+reset_shadow_mode:
+	/* reset shadow mode 2 */
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
+			       MII_BCM7XXX_SHD_MODE_2);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+/* The 28nm EPHY does not support Clause 45 (MMD) used by bcm-phy-lib */
+static int bcm7xxx_28nm_ephy_apd_enable(struct phy_device *phydev)
+{
+	int ret;
+
+	/* set shadow mode 1 */
+	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST,
+			       MII_BRCM_FET_BT_SRE, 0);
+	if (ret < 0)
+		return ret;
+
+	/* Enable auto-power down */
+	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
+			       MII_BRCM_FET_SHDW_AS2_APDE, 0);
+	if (ret < 0)
+		return ret;
+
+	/* reset shadow mode 1 */
+	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST, 0,
+			       MII_BRCM_FET_BT_SRE);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int bcm7xxx_28nm_ephy_eee_enable(struct phy_device *phydev)
+{
+	int ret;
+
+	/* set shadow mode 2 */
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
+			       MII_BCM7XXX_SHD_MODE_2, 0);
+	if (ret < 0)
+		return ret;
+
+	/* Advertise supported modes */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_AN_EEE_ADV);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			MDIO_EEE_100TX);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+	/* Restore Defaults */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_PCS_CTRL_2);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			MII_BCM7XXX_PCS_CTRL_2_DEF);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_EEE_THRESH);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			MII_BCM7XXX_EEE_THRESH_DEF);
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+	/* Enable EEE autonegotiation */
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+			MII_BCM7XXX_SHD_3_AN_STAT);
+	if (ret < 0)
+		goto reset_shadow_mode;
+	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			(MII_BCM7XXX_AN_NULL_MSG_EN | MII_BCM7XXX_AN_EEE_EN));
+	if (ret < 0)
+		goto reset_shadow_mode;
+
+reset_shadow_mode:
+	/* reset shadow mode 2 */
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
+			       MII_BCM7XXX_SHD_MODE_2);
+	if (ret < 0)
+		return ret;
+
+	/* Restart autoneg */
+	phy_write(phydev, MII_BMCR,
+		  (BMCR_SPEED100 | BMCR_ANENABLE | BMCR_ANRESTART));
+
+	return 0;
+}
+
+static int bcm7xxx_28nm_ephy_config_init(struct phy_device *phydev)
+{
+	u8 rev = phydev->phy_id & ~phydev->drv->phy_id_mask;
+	int ret = 0;
+
+	pr_info_once("%s: %s PHY revision: 0x%02x\n",
+		     phydev_name(phydev), phydev->drv->name, rev);
+
+	/* Dummy read to a register to workaround a possible issue upon reset
+	 * where the internal inverter may not allow the first MDIO transaction
+	 * to pass the MDIO management controller and make us return 0xffff for
+	 * such reads.
+	 */
+	phy_read(phydev, MII_BMSR);
+
+	/* Apply AFE software work-around if necessary */
+	if (rev == 0x01) {
+		ret = bcm7xxx_28nm_ephy_01_afe_config_init(phydev);
+		if (ret)
+			return ret;
+	}
+
+	ret = bcm7xxx_28nm_ephy_eee_enable(phydev);
+	if (ret)
+		return ret;
+
+	return bcm7xxx_28nm_ephy_apd_enable(phydev);
+}
+
+static int bcm7xxx_28nm_ephy_resume(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Re-apply workarounds coming out suspend/resume */
+	ret = bcm7xxx_28nm_ephy_config_init(phydev);
+	if (ret)
+		return ret;
+
+	return genphy_config_aneg(phydev);
+}
+
 static int bcm7xxx_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -434,6 +622,23 @@ static int bcm7xxx_28nm_probe(struct phy_device *phydev)
 	.probe		= bcm7xxx_28nm_probe,				\
 }
 
+#define BCM7XXX_28NM_EPHY(_oui, _name)					\
+{									\
+	.phy_id		= (_oui),					\
+	.phy_id_mask	= 0xfffffff0,					\
+	.name		= _name,					\
+	.features	= PHY_BASIC_FEATURES,				\
+	.flags		= PHY_IS_INTERNAL,				\
+	.config_init	= bcm7xxx_28nm_ephy_config_init,		\
+	.config_aneg	= genphy_config_aneg,				\
+	.read_status	= genphy_read_status,				\
+	.resume		= bcm7xxx_28nm_ephy_resume,			\
+	.get_sset_count	= bcm_phy_get_sset_count,			\
+	.get_strings	= bcm_phy_get_strings,				\
+	.get_stats	= bcm7xxx_28nm_get_phy_stats,			\
+	.probe		= bcm7xxx_28nm_probe,				\
+}
+
 #define BCM7XXX_40NM_EPHY(_oui, _name)					\
 {									\
 	.phy_id         = (_oui),					\
@@ -450,6 +655,9 @@ static int bcm7xxx_28nm_probe(struct phy_device *phydev)
 
 static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7250, "Broadcom BCM7250"),
+	BCM7XXX_28NM_EPHY(PHY_ID_BCM7260, "Broadcom BCM7260"),
+	BCM7XXX_28NM_EPHY(PHY_ID_BCM7268, "Broadcom BCM7268"),
+	BCM7XXX_28NM_EPHY(PHY_ID_BCM7271, "Broadcom BCM7271"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7278, "Broadcom BCM7278"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
@@ -466,6 +674,9 @@ static struct phy_driver bcm7xxx_driver[] = {
 
 static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7250, 0xfffffff0, },
+	{ PHY_ID_BCM7260, 0xfffffff0, },
+	{ PHY_ID_BCM7268, 0xfffffff0, },
+	{ PHY_ID_BCM7271, 0xfffffff0, },
 	{ PHY_ID_BCM7278, 0xfffffff0, },
 	{ PHY_ID_BCM7364, 0xfffffff0, },
 	{ PHY_ID_BCM7366, 0xfffffff0, },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 55e517130311..abcda9b458ab 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -25,6 +25,9 @@
 #define PHY_ID_BCM57780			0x03625d90
 
 #define PHY_ID_BCM7250			0xae025280
+#define PHY_ID_BCM7260			0xae025190
+#define PHY_ID_BCM7268			0xae025090
+#define PHY_ID_BCM7271			0xae0253b0
 #define PHY_ID_BCM7278			0xae0251a0
 #define PHY_ID_BCM7364			0xae025260
 #define PHY_ID_BCM7366			0x600d8490
-- 
2.11.1
