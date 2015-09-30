From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH 4/4] net: phy: Broadcom Cygnus internal Etherent PHY driver
Date: Wed, 30 Sep 2015 13:32:43 -0700
Message-ID: <1443645163-2822-5-git-send-email-arunp@broadcom.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:1094 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932867AbbI3Ucd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:32:33 -0400
In-Reply-To: <1443645163-2822-1-git-send-email-arunp@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the Broadcom Cygnus SoCs internal PHY's.
The PHYs are 1000M/100M/10M capable with support for 'EEE'
and 'APD' (Auto Power Down).

This driver supports the following Broadcom Cygnus SoCs:
 - BCM583XX (BCM58300, BCM58302, BCM58303, BCM58305)
 - BCM113XX (BCM11300, BCM11320, BCM11350, BCM11360)

The PHY's on these SoC's require some workarounds for
stable operation, both during configuration time and
during suspend/resume. This driver handles the
application of the workarounds.

Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
---
 drivers/net/phy/Kconfig      |  13 ++++
 drivers/net/phy/Makefile     |   1 +
 drivers/net/phy/bcm-cygnus.c | 162 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/brcmphy.h      |   2 +
 4 files changed, 178 insertions(+)
 create mode 100644 drivers/net/phy/bcm-cygnus.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 0c85a01..da979ec 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -79,6 +79,19 @@ config BROADCOM_PHY
 	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
 	  BCM5481 and BCM5482 PHYs.
 
+config BCM_CYGNUS_PHY
+	tristate "Drivers for Broadcom Cygnus SoC internal PHY"
+	depends on ARCH_BCM_CYGNUS || COMPILE_TEST
+	select BCM_NET_PHYLIB
+	select MDIO_BCM_IPROC
+	---help---
+	  This PHY driver is for the 1G internal PHYs of the Broadcom
+	  Cygnus Family SoC.
+
+	  Currently supports internal PHY's used in the BCM11300,
+	  BCM11320, BCM11350, BCM11360, BCM58300, BCM58302,
+	  BCM58303 & BCM58305 Broadcom Cygnus SoCs.
+
 config BCM63XX_PHY
 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
 	depends on BCM63XX
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 6932475..7655d47 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
 obj-$(CONFIG_BCM7XXX_PHY)	+= bcm7xxx.o
 obj-$(CONFIG_BCM87XX_PHY)	+= bcm87xx.o
+obj-$(CONFIG_BCM_CYGNUS_PHY)	+= bcm-cygnus.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
diff --git a/drivers/net/phy/bcm-cygnus.c b/drivers/net/phy/bcm-cygnus.c
new file mode 100644
index 0000000..28bab20
--- /dev/null
+++ b/drivers/net/phy/bcm-cygnus.c
@@ -0,0 +1,162 @@
+/*
+ * Copyright (C) 2015 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+/* Broadcom Cygnus SoC internal transceivers support. */
+#include "bcm-phy-lib.h"
+#include <linux/brcmphy.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+/* Broadcom Cygnus Phy specific registers */
+#define MII_BCM_CORE_BASE1E       0x1E /* Core BASE1E register */
+#define MII_BCM_EXPB0             0xB0 /* EXPB0 register */
+#define MII_BCM_EXPB1             0xB1 /* EXPB1 register */
+
+#define MII_BCM_CYGNUS_AFE_VDAC_ICTRL_0  0x91E5 /* VDAL Control register */
+
+static int bcm_cygnus_afe_config(struct phy_device *phydev)
+{
+	int rc;
+
+	/* ensure smdspclk is enabled */
+	rc = phy_write(phydev, MII_BCM54XX_AUX_CTL, 0x0c30);
+	if (rc < 0)
+		return rc;
+
+	/* AFE_VDAC_ICTRL_0 bit 7:4 Iq=1100 for 1g 10bt, normal modes */
+	rc = bcm_phy_write_misc(phydev, 0x39, 0x01, 0xA7C8);
+	if (rc < 0)
+		return rc;
+
+	/* AFE_HPF_TRIM_OTHERS bit11=1, short cascode enable for all modes*/
+	rc = bcm_phy_write_misc(phydev, 0x3A, 0x00, 0x0803);
+	if (rc < 0)
+		return rc;
+
+	/* AFE_TX_CONFIG_1 bit 7:4 Iq=1100 for test modes */
+	rc = bcm_phy_write_misc(phydev, 0x3A, 0x01, 0xA740);
+	if (rc < 0)
+		return rc;
+
+	/* AFE TEMPSEN_OTHERS rcal_HT, rcal_LT 10000 */
+	rc = bcm_phy_write_misc(phydev, 0x3A, 0x03, 0x8400);
+	if (rc < 0)
+		return rc;
+
+	/* AFE_FUTURE_RSV bit 2:0 rccal <2:0>=100 */
+	rc = bcm_phy_write_misc(phydev, 0x3B, 0x00, 0x0004);
+	if (rc < 0)
+		return rc;
+
+	/* Adjust bias current trim to overcome digital offSet */
+	rc = phy_write(phydev, MII_BCM_CORE_BASE1E, 0x02);
+	if (rc < 0)
+		return rc;
+
+	/* make rcal=100, since rdb default is 000 */
+	rc = bcm_phy_write_exp(phydev, MII_BCM_EXPB1, 0x10);
+	if (rc < 0)
+		return rc;
+
+	/* CORE_EXPB0, Reset R_CAL/RC_CAL Engine */
+	rc = bcm_phy_write_exp(phydev, MII_BCM_EXPB0, 0x10);
+	if (rc < 0)
+		return rc;
+
+	/* CORE_EXPB0, Disable Reset R_CAL/RC_CAL Engine */
+	rc = bcm_phy_write_exp(phydev, MII_BCM_EXPB0, 0x00);
+
+	return 0;
+}
+
+static int bcm_cygnus_config_init(struct phy_device *phydev)
+{
+	int reg, rc;
+
+	reg = phy_read(phydev, MII_BCM54XX_ECR);
+	if (reg < 0)
+		return reg;
+
+	/* Mask interrupts globally. */
+	reg |= MII_BCM54XX_ECR_IM;
+	rc = phy_write(phydev, MII_BCM54XX_ECR, reg);
+	if (rc)
+		return rc;
+
+	/* Unmask events of interest */
+	reg = ~(MII_BCM54XX_INT_DUPLEX |
+		MII_BCM54XX_INT_SPEED |
+		MII_BCM54XX_INT_LINK);
+	rc = phy_write(phydev, MII_BCM54XX_IMR, reg);
+	if (rc)
+		return rc;
+
+	/* Apply AFE settings for the PHY */
+	rc = bcm_cygnus_afe_config(phydev);
+	if (rc)
+		return rc;
+
+	/* Advertise EEE */
+	rc = bcm_phy_enable_eee(phydev);
+	if (rc)
+		return rc;
+
+	/* Enable APD */
+	return bcm_phy_enable_apd(phydev, false);
+}
+
+static int bcm_cygnus_resume(struct phy_device *phydev)
+{
+	int rc;
+
+	genphy_resume(phydev);
+
+	/* Re-initialize the PHY to apply AFE work-arounds and
+	 * configurations when coming out of suspend.
+	 */
+	rc = bcm_cygnus_config_init(phydev);
+	if (rc)
+		return rc;
+
+	/* restart auto negotiation with the new settings */
+	return genphy_config_aneg(phydev);
+}
+
+static struct phy_driver bcm_cygnus_phy_driver[] = {
+{
+	.phy_id        = PHY_ID_BCM_CYGNUS,
+	.phy_id_mask   = 0xfffffff0,
+	.name          = "Broadcom Cygnus PHY",
+	.features      = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.config_init   = bcm_cygnus_config_init,
+	.config_aneg   = genphy_config_aneg,
+	.read_status   = genphy_read_status,
+	.ack_interrupt = bcm_phy_ack_intr,
+	.config_intr   = bcm_phy_config_intr,
+	.suspend       = genphy_suspend,
+	.resume        = bcm_cygnus_resume,
+} };
+
+static struct mdio_device_id __maybe_unused bcm_cygnus_phy_tbl[] = {
+	{ PHY_ID_BCM_CYGNUS, 0xfffffff0, },
+	{ }
+};
+MODULE_DEVICE_TABLE(mdio, bcm_cygnus_phy_tbl);
+
+module_phy_driver(bcm_cygnus_phy_driver);
+
+MODULE_DESCRIPTION("Broadcom Cygnus internal PHY driver");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Broadcom Corporation");
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 6a53ab9..34a8996 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -30,6 +30,8 @@
 #define PHY_ID_BCM7439_2		0xae025080
 #define PHY_ID_BCM7445			0x600d8510
 
+#define PHY_ID_BCM_CYGNUS		0xae025200
+
 #define PHY_BCM_OUI_MASK		0xfffffc00
 #define PHY_BCM_OUI_1			0x00206000
 #define PHY_BCM_OUI_2			0x0143bc00
-- 
2.5.2
