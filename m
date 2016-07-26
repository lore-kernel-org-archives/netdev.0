From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: RE: Microsemi VSC 8531/41 PHY Driver
Date: Tue, 26 Jul 2016 12:20:40 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0087.outbound.protection.outlook.com ([104.47.32.87]:30240
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756133AbcGZMUp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 08:20:45 -0400
In-Reply-To: <20160726115556.GC11538@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew,

VSC 8531 / 8541 is not yet release to Public. Now It's in draft version.
After commit the VSC 8531 PHY drivers in Linux Kernel Open source, Microsemi will release the VSC 8531/8541 data sheet to Public.
My apologies. I missed instructions about attachments in SubmittingPathes document.

VSC 8531/8541 PHY Driver code patch inline.

>From d75dce082d229595211e8e7106a19c967e5ce07f Mon Sep 17 00:00:00 2001
From: "Nagaraju Lakkaraju" <raju.lakkaraju@microsemi.com>
Date: Thu, 21 Jul 2016 12:47:54 +0200
Subject: [PATCH] net: phy: Add drivers for Microsemi PHYs

Adding support for Microsemi PHYs: VSC8531 and VSC8541.

Signed-off-by: Nagaraju Lakkaraju <raju.lakkaraju@microsemi.com>
---
 drivers/net/phy/Kconfig  |   5 ++
 drivers/net/phy/Makefile |   1 +
 drivers/net/phy/mscc.c   | 183 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 189 insertions(+)
 create mode 100644 drivers/net/phy/mscc.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..9d1bd0e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -271,6 +271,11 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config MICROSEMI_PHY
+        tristate "Drivers for the Microsemi PHYs"
+        ---help---
+          Currently supports the VSC8531 and VSC8541 PHYs
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcdbb92..f98ac90 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_CICADA_PHY)	+= cicada.o
 obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
+obj-$(CONFIG_MICROSEMI_PHY)     += mscc.o
 obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BCM_NET_PHYLIB)	+= bcm-phy-lib.o
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
new file mode 100644
index 0000000..605e91c
--- /dev/null
+++ b/drivers/net/phy/mscc.c
@@ -0,0 +1,183 @@
+/*
+ * Driver for Microsemi VSC85xx PHYs
+ *
+ * Author: Nagaraju Lakkaraju
+ * License: Dual MIT/GPL
+ * Copyright (c) 2016 Microsemi Corporation
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mdio.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+enum rgmii_rx_clock_delay {
+	RGMII_RX_CLK_DELAY_0_2_NS = 0,
+	RGMII_RX_CLK_DELAY_0_8_NS = 1,
+	RGMII_RX_CLK_DELAY_1_1_NS = 2,
+	RGMII_RX_CLK_DELAY_1_7_NS = 3,
+	RGMII_RX_CLK_DELAY_2_0_NS = 4,
+	RGMII_RX_CLK_DELAY_2_3_NS = 5,
+	RGMII_RX_CLK_DELAY_2_6_NS = 6,
+	RGMII_RX_CLK_DELAY_3_4_NS = 7
+};
+
+#define MII_VSC85XX_INT_MASK           25
+#define MII_VSC85XX_INT_MASK_MASK      0xa000
+#define MII_VSC85XX_INT_STATUS         26
+
+#define MSCC_EXT_PAGE_ACCESS           31
+#define MSCC_PHY_PAGE_STANDARD         0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED_2       0x0002 /* Extended registers - page 2 */
+
+/* Extended Page 2 Registers */
+#define MSCC_PHY_RGMII_CNTL            20
+#define RGMII_RX_CLK_DELAY_MASK        0x0070
+#define RGMII_RX_CLK_DELAY_POS         4
+
+/* Microsemi PHY ID's */
+#define PHY_ID_VSC8531                 0x00070570
+#define PHY_ID_VSC8541                 0x00070770
+
+/* RGMII Rx Clock delay value change with board lay-out */
+static u8 rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;
+
+static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
+{
+	int rc = 0;
+
+	rc = phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);
+	return rc;
+}
+
+static int vsc85xx_default_config(struct phy_device *phydev)
+{
+	int rc = 0;
+	u16 reg_val = 0;
+
+	phydev->supported = (SUPPORTED_1000baseT_Full |
+			     SUPPORTED_1000baseT_Half |
+			     SUPPORTED_100baseT_Full  |
+			     SUPPORTED_100baseT_Half  |
+			     SUPPORTED_10baseT_Full   |
+			     SUPPORTED_10baseT_Half   |
+			     SUPPORTED_Autoneg        |
+			     SUPPORTED_Pause          |
+			     SUPPORTED_Asym_Pause     |
+			     SUPPORTED_TP);
+
+	phydev->speed = SPEED_1000;
+	phydev->duplex = DUPLEX_FULL;
+	phydev->pause = 0;
+	phydev->asym_pause = 0;
+	phydev->interface = PHY_INTERFACE_MODE_RGMII;
+	phydev->mdix = ETH_TP_MDI_AUTO;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0) {
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
+	reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
+	reg_val |= (rgmii_rx_clk_delay << RGMII_RX_CLK_DELAY_POS);
+	phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+	if (rc != 0)
+		rc = -EINVAL;
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
+static int vsc85xx_config_init(struct phy_device *phydev)
+{
+	int rc = 0;
+
+	rc = vsc85xx_default_config(phydev);
+	rc = genphy_config_init(phydev);
+
+	return rc;
+}
+
+static int vsc85xx_ack_interrupt(struct phy_device *phydev)
+{
+	int rc = 0;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+
+	return (rc < 0) ? rc : 0;
+}
+
+static int vsc85xx_config_intr(struct phy_device *phydev)
+{
+	int rc;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
+			       MII_VSC85XX_INT_MASK_MASK);
+	} else {
+		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+		if (rc < 0)
+			return rc;
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
+	}
+
+	return rc;
+}
+
+/* Microsemi VSC85xx PHYs */
+static struct phy_driver vsc85xx_driver[] = {
+{
+	.phy_id         = PHY_ID_VSC8531,
+	.name           = "Microsemi VSC8531",
+	.phy_id_mask    = 0xfffffff0,
+	.features       = PHY_GBIT_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.soft_reset     = &genphy_soft_reset,
+	.config_init    = &vsc85xx_config_init,
+	.config_aneg    = &genphy_config_aneg,
+	.aneg_done      = &genphy_aneg_done,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc85xx_ack_interrupt,
+	.config_intr    = &vsc85xx_config_intr,
+	.suspend        = &genphy_suspend,
+	.resume         = &genphy_resume,
+},
+{
+	.phy_id         = PHY_ID_VSC8541,
+	.name           = "Microsemi VSC8541 SyncE",
+	.phy_id_mask    = 0xfffffff0,
+	.features       = PHY_GBIT_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.soft_reset     = &genphy_soft_reset,
+	.config_init    = &vsc85xx_config_init,
+	.config_aneg    = &genphy_config_aneg,
+	.aneg_done      = &genphy_aneg_done,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc85xx_ack_interrupt,
+	.config_intr    = &vsc85xx_config_intr,
+	.suspend        = &genphy_suspend,
+	.resume         = &genphy_resume,
+}
+
+};
+
+module_phy_driver(vsc85xx_driver);
+
+static struct mdio_device_id __maybe_unused vsc85xx_tbl[] = {
+	{ PHY_ID_VSC8531, 0xfffffff0, },
+	{ PHY_ID_VSC8541, 0xfffffff0, },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, vsc85xx_tbl);
+
+MODULE_DESCRIPTION("Microsemi VSC85xx PHY driver");
+MODULE_AUTHOR("Nagaraju Lakkaraju");
+MODULE_LICENSE("Dual MIT/GPL");
-- 
2.7.3


Thanks and regards,
Raju
(Nagaraju Lakkaraju)
Sr. Staff Engg.
Microsemi Communications India Pvt Ltd.
Ph: +91 040 6686 0132

-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Tuesday, July 26, 2016 5:26 PM
To: Raju Lakkaraju
Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Allan Nielsen
Subject: Re: Microsemi VSC 8531/41 PHY Driver

EXTERNAL EMAIL


On Tue, Jul 26, 2016 at 09:49:53AM +0000, Raju Lakkaraju wrote:
> Hello All,
>
> I would like to introduce myself as Nagaraju Lakkaraju (Raju), is working in Microsemi Communications India Pvt. Ltd (Formerly known as Vitesse Semiconductors Limited) - Hyderabad as Sr. Staff Engineer.
> I do work on Microsemi PHY drivers development.
> Microsemi is developing the new Physical Layer (PHY) chips for Internet Of Things (IoT) products with 1 Gbps link speed.
> As part of the development, Microsemi would like to contribute the new PHYs (i.e. VSC 8531 / VSC 8541) chip drivers in Linux Kernel Open source.
> VSC 8531 / 8541 PHYs will have the following features a part of the basic features like Auto-neg, Speed, Duplex etc.
> 1. Wake on LAN
> 2. Auto MDIX/MDI
> 3. Link Speed Down shift
> 4. Fast Link Failure-2
> 5. Loopbacks (FAR-END, NEAR-END and Connector) 6. Ethernet Packet 
> Generator (EPG) 7. Serial Management Interface (SMI) Interrupt 8. 
> Clock Squelch configuration (SyncE) 9. Jumbo Frame Support 10. In-line 
> Power On Ethernet (PoE) status 11. Acti PHY power Management 12. 
> Energy Efficiency Ethenet (EEE) 13. VeriPHY (Cable Diagnostics) 14. 
> LED configuration 15. Ring Resiliency 16. Start Of Frame Detection 
> (SOF) 17. COMA mode

Some interesting features. Is the datasheet publicly available?

> As part of Initial submission of the Linux Kernel Open source drivers, 
> I developed the VSC 8531 driver basic features and built the Linux Kernel image for Beaglebone Black hardware.
> Also developed Ethtool enhancement for VSC 8531 register access 
> functionality to test the VSC 8531
>
> Test Setup:
> -------------
> Hardware Details: Beaglebone Black with VSC 8531 PHY Software Linux 
> Kernel version: 4.6.4
>
> Microsemi VSC 8531 chip is mount on Beaglebone Black hardware (replaced the Microchip PHY) and tested the following features.
> 1. Auto negotiation
> 2. Speed change ( 10 Mbps, 100 Mbps and 1 Gbps) 3. Full/Half Duplex 4. 
> Ping 5. Line rate traffic with Test center
>
> I would like you to review my code and provide me the valuable comments.
> Please find the attached git code diff patch.

I would like to review your code, but please read the SubmittingPathes document and in particularly, the bit about attachments.

         Andrew
