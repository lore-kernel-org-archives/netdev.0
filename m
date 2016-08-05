From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Fri, 5 Aug 2016 17:54:21 +0530
Message-ID: <20160805122420.GA3184@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
 <20160729081736.GB13798@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0045.outbound.protection.outlook.com ([104.47.37.45]:7824
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934983AbcHEMYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 08:24:45 -0400
Content-Disposition: inline
In-Reply-To: <20160729081736.GB13798@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I added all review comments and re-sending for review.

>From a5017f5878a92d2acec86a6a29b1498c457cb73a Mon Sep 17 00:00:00 2001
From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date: Wed, 3 Aug 2016 18:28:24 +0530
Subject: [PATCH v2] net: phy: Add drivers for Microsemi PHYs

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/Kconfig  |   5 ++
 drivers/net/phy/Makefile |   1 +
 drivers/net/phy/mscc.c   | 161 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 167 insertions(+)
 create mode 100644 drivers/net/phy/mscc.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 47a6434..1b534ea 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -307,6 +307,11 @@ config MDIO_XGENE
          This module provides a driver for the MDIO busses found in the
          APM X-Gene SoC's.

+config MICROSEMI_PHY
+    tristate "Drivers for the Microsemi PHYs"
+    ---help---
+      Currently supports the VSC8531 and VSC8541 PHYs
+
 endif # PHYLIB

 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 534dfa7..a713bd4 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_CICADA_PHY)      += cicada.o
 obj-$(CONFIG_LXT_PHY)          += lxt.o
 obj-$(CONFIG_QSEMI_PHY)                += qsemi.o
 obj-$(CONFIG_SMSC_PHY)         += smsc.o
+obj-$(CONFIG_MICROSEMI_PHY) += mscc.o
 obj-$(CONFIG_TERANETICS_PHY)   += teranetics.o
 obj-$(CONFIG_VITESSE_PHY)      += vitesse.o
 obj-$(CONFIG_BCM_NET_PHYLIB)   += bcm-phy-lib.o
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
new file mode 100644
index 0000000..49c7506
--- /dev/null
+++ b/drivers/net/phy/mscc.c
@@ -0,0 +1,161 @@
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
+       RGMII_RX_CLK_DELAY_0_2_NS = 0,
+       RGMII_RX_CLK_DELAY_0_8_NS = 1,
+       RGMII_RX_CLK_DELAY_1_1_NS = 2,
+       RGMII_RX_CLK_DELAY_1_7_NS = 3,
+       RGMII_RX_CLK_DELAY_2_0_NS = 4,
+       RGMII_RX_CLK_DELAY_2_3_NS = 5,
+       RGMII_RX_CLK_DELAY_2_6_NS = 6,
+       RGMII_RX_CLK_DELAY_3_4_NS = 7
+};
+
+#define MII_VSC85XX_INT_MASK              25
+#define MII_VSC85XX_INT_MASK_MASK         0xa000
+#define MII_VSC85XX_INT_STATUS            26
+
+#define MSCC_EXT_PAGE_ACCESS              31
+#define MSCC_PHY_PAGE_STANDARD            0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED_2          0x0002 /* Extended reg - page 2 */
+
+/* Extended Page 2 Registers */
+#define MSCC_PHY_RGMII_CNTL                       20
+#define RGMII_RX_CLK_DELAY_MASK                   0x0070
+#define RGMII_RX_CLK_DELAY_POS            4
+
+/* Microsemi PHY ID's */
+#define PHY_ID_VSC8531                            0x00070570
+#define PHY_ID_VSC8541                            0x00070770
+
+static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
+{
+       int rc;
+
+       rc = phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);
+       return rc;
+}
+
+static int vsc85xx_default_config(struct phy_device *phydev)
+{
+       int rc;
+       u16 reg_val;
+
+       mutex_lock(&phydev->lock);
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+       if (rc != 0)
+               goto out_unlock;
+
+       reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
+       reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
+       reg_val |= (RGMII_RX_CLK_DELAY_1_1_NS << RGMII_RX_CLK_DELAY_POS);
+       phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+       mutex_unlock(&phydev->lock);
+
+       return rc;
+}
+
+static int vsc85xx_config_init(struct phy_device *phydev)
+{
+       int rc;
+
+       rc = vsc85xx_default_config(phydev);
+       if (rc)
+               return rc;
+       rc = genphy_config_init(phydev);
+
+       return rc;
+}
+
+static int vsc85xx_ack_interrupt(struct phy_device *phydev)
+{
+       int rc;
+
+       if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+               rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+
+       return (rc < 0) ? rc : 0;
+}
+
+static int vsc85xx_config_intr(struct phy_device *phydev)
+{
+       int rc;
+
+       if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+               rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
+                                  MII_VSC85XX_INT_MASK_MASK);
+       } else {
+               rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
+               if (rc < 0)
+                       return rc;
+               rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+       }
+
+       return rc;
+}
+
+/* Microsemi VSC85xx PHYs */
+static struct phy_driver vsc85xx_driver[] = {
+{
+       .phy_id                 = PHY_ID_VSC8531,
+       .name                   = "Microsemi VSC8531",
+       .phy_id_mask    = 0xfffffff0,
+       .features               = PHY_GBIT_FEATURES,
+       .flags                  = PHY_HAS_INTERRUPT,
+       .soft_reset             = &genphy_soft_reset,
+       .config_init    = &vsc85xx_config_init,
+       .config_aneg    = &genphy_config_aneg,
+       .aneg_done              = &genphy_aneg_done,
+       .read_status    = &genphy_read_status,
+       .ack_interrupt  = &vsc85xx_ack_interrupt,
+       .config_intr    = &vsc85xx_config_intr,
+       .suspend                = &genphy_suspend,
+       .resume                 = &genphy_resume,
+},
+{
+       .phy_id                 = PHY_ID_VSC8541,
+       .name                   = "Microsemi VSC8541 SyncE",
+       .phy_id_mask    = 0xfffffff0,
+       .features               = PHY_GBIT_FEATURES,
+       .flags                  = PHY_HAS_INTERRUPT,
+       .soft_reset             = &genphy_soft_reset,
+       .config_init    = &vsc85xx_config_init,
+       .config_aneg    = &genphy_config_aneg,
+       .aneg_done              = &genphy_aneg_done,
+       .read_status    = &genphy_read_status,
+       .ack_interrupt  = &vsc85xx_ack_interrupt,
+       .config_intr    = &vsc85xx_config_intr,
+       .suspend                = &genphy_suspend,
+       .resume                 = &genphy_resume,
+}
+
+};
+
+module_phy_driver(vsc85xx_driver);
+
+static struct mdio_device_id __maybe_unused vsc85xx_tbl[] = {
+       { PHY_ID_VSC8531, 0xfffffff0, },
+       { PHY_ID_VSC8541, 0xfffffff0, },
+       { }
+};
+
+MODULE_DEVICE_TABLE(mdio, vsc85xx_tbl);
+
+MODULE_DESCRIPTION("Microsemi VSC85xx PHY driver");
+MODULE_AUTHOR("Nagaraju Lakkaraju");
+MODULE_LICENSE("Dual MIT/GPL");
-- 
2.1.0

--

Thanks,
Raju
On Fri, Jul 29, 2016 at 10:17:36AM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > > +/* RGMII Rx Clock delay value change with board lay-out */ static u8
> > > +rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;
> >
> > Doesn't this stop you from having a board with two PHYs with different layouts? You should be getting this value from the device tree.
> >
> > Raju: As of now, RGMII Rx clock delay value should be 1.1 nsec as optimized/recommended value.
> > We tested on Beaglebone Black with VSC 8531 PHY.
> > We would like to provide new function to configure correct/require value based on PHY layouts
> > alone with other RGMII configuration parameters as part of our next implementation.
> 
> Please either do it properly now or hard code it as the default, and
> then later replace it with device tree, etc. We don't like to see half
> finished features.
> 
> > What are you locking against?
> >
> > Raju: VSC 8531 has different PAGEs. Whenever MDC/MDIO access the PHY control registers,
> > first set the page number then read/write the register address. Default page should be Page 0.
> > When I want to access not default page register, I have to lock phy device access and change
> > the page number and register access as atomic operation.
> 
> I understand all that, which is why i asked, "what are you locking
> against?", not "why are you locking?" What are the other call paths? I
> don't see you taking this lock anywhere else? Should you be? I would
> just like to see a comment which suggests you understand when this
> lock is needed, and when not.
> 
>      Andrew
