From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 01/17] et1011c: Replaced PHY driver by a small dm646x
	board fixup
Date: Thu, 20 Oct 2011 17:00:08 -0400
Message-ID: <1319144425-15547-2-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@ti.com>, Russell King <linux@arm.linux.org.uk>,
	Sekhar Nori <nsekhar@ti.com>,
	"David S. Miller" <davem@conan.davemloft.net>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	John Stultz <john.stultz@linaro.org>,
	Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Florian Fainelli <ffainelli@freebox.fr>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Richard Cochran <richard.cochran@omicron.at>,
	linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The et1011c PHY driver has several noticeable code smells:

  (1) It uses a "static int speed" variable to see if the speed changed
      between calls to et1011c_read_status().  This obviously breaks if
      more than one PHY is present in a system.

  (2) The "GMII_INTERFACE" and "SYS_CLK_EN" bits should be properly set
      at reset-time by hardwired pins on the ET1011C chip, as they are
      specific to the wiring on the board.  They should NOT be set by a
      generic PHY driver, and at best belong in a board-specific fixup.

  (3) The FIFO bits are "changed" to the default reset value specified
      in the datasheet.

  (4) The driver does not appear to contain code anywhere which undoes
      any of the above changes if the interface drops from 1000BaseT to
      100BaseTX without a chip reset.  Instead it appears to perform an
      extraneous BMCR_RESET in its ->config_aneg() method, which would
      wipe out any settings applied by phy_register_fixup() and friends.

This PHY should be handled entirely by the genphy driver with only a
minimal board-specific "phy_register_fixup()" in the DM646x code.

NOTE: Completely untested. Needs somebody with hardware to try it out.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 arch/arm/mach-davinci/dm646x.c |   24 ++++++++
 drivers/net/phy/Kconfig        |    5 --
 drivers/net/phy/Makefile       |    1 -
 drivers/net/phy/et1011c.c      |  119 ----------------------------------------
 4 files changed, 24 insertions(+), 125 deletions(-)
 delete mode 100644 drivers/net/phy/et1011c.c

diff --git a/arch/arm/mach-davinci/dm646x.c b/arch/arm/mach-davinci/dm646x.c
index 1802e71..afcdf37 100644
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -14,6 +14,7 @@
 #include <linux/serial_8250.h>
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
+#include <linux/phy.h>
 
 #include <asm/mach/map.h>
 
@@ -908,6 +909,27 @@ void __init dm646x_init(void)
 	davinci_common_init(&davinci_soc_info_dm646x);
 }
 
+/* Apparently the PHY bootstrap pin wiring on the board is wrong */
+#define ET1011C_CONFIG_REG (0x16)
+#define ET1011C_TX_FIFO_MASK		(0x3000)
+#define ET1011C_TX_FIFO_DEPTH_16	(0x1000)
+#define ET1011C_SYS_CLK_EN		(0x0010)
+#define ET1011C_INTERFACE_MASK		(0x0007)
+#define ET1011C_INTERFACE_GMII_GTX_CLK	(0x0002)
+static int dm646x_et1011c_phy_fixup(struct phy_device *phydev)
+{
+	int val = phy_read(phydev, ET1011C_CONFIG_REG);
+	if (val < 0)
+		return val;
+
+	val &= ~ET1011C_TX_FIFO_MASK;
+	val |=  ET1011C_TX_FIFO_DEPTH_16;
+	val |=  ET1011C_SYS_CLK_EN;
+	val &= ~ET1011C_INTERFACE_MASK
+	val |=  ET1011C_INTERFACE_GMII_GTX_CLK;
+	return phy_write(phydev, ET1011C_CONFIG_REG, val);
+}
+
 static int __init dm646x_init_devices(void)
 {
 	if (!cpu_is_davinci_dm646x())
@@ -917,6 +939,8 @@ static int __init dm646x_init_devices(void)
 	platform_device_register(&dm646x_emac_device);
 	clk_add_alias(NULL, dev_name(&dm646x_mdio_device.dev),
 		      NULL, &dm646x_emac_device.dev);
+	phy_register_fixup_for_uid(0x0282f014, 0xfffffff0,
+			&dm646x_et1011c_phy_fixup);
 
 	return 0;
 }
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a702443..fdd2ace 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -82,11 +82,6 @@ config STE10XP
 	---help---
 	  This is the driver for the STe100p and STe101p PHYs.
 
-config LSI_ET1011C_PHY
-	tristate "Driver for LSI ET1011C PHY"
-	---help---
-	  Supports the LSI ET1011C PHY.
-
 config MICREL_PHY
 	tristate "Driver for Micrel PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 2333215..d4c0bd0 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -14,7 +14,6 @@ obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
-obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
deleted file mode 100644
index a8eb19e..0000000
--- a/drivers/net/phy/et1011c.c
+++ /dev/null
@@ -1,119 +0,0 @@
-/*
- * drivers/net/phy/et1011c.c
- *
- * Driver for LSI ET1011C PHYs
- *
- * Author: Chaithrika U S
- *
- * Copyright (c) 2008 Texas Instruments
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/unistd.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/mii.h>
-#include <linux/ethtool.h>
-#include <linux/phy.h>
-#include <linux/io.h>
-#include <linux/uaccess.h>
-#include <asm/irq.h>
-
-#define ET1011C_STATUS_REG	(0x1A)
-#define ET1011C_CONFIG_REG	(0x16)
-#define ET1011C_SPEED_MASK		(0x0300)
-#define ET1011C_GIGABIT_SPEED		(0x0200)
-#define ET1011C_TX_FIFO_MASK		(0x3000)
-#define ET1011C_TX_FIFO_DEPTH_8		(0x0000)
-#define ET1011C_TX_FIFO_DEPTH_16	(0x1000)
-#define ET1011C_INTERFACE_MASK		(0x0007)
-#define ET1011C_GMII_INTERFACE		(0x0002)
-#define ET1011C_SYS_CLK_EN		(0x01 << 4)
-
-
-MODULE_DESCRIPTION("LSI ET1011C PHY driver");
-MODULE_AUTHOR("Chaithrika U S");
-MODULE_LICENSE("GPL");
-
-static int et1011c_config_aneg(struct phy_device *phydev)
-{
-	int ctl = 0;
-	ctl = phy_read(phydev, MII_BMCR);
-	if (ctl < 0)
-		return ctl;
-	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 |
-		 BMCR_ANENABLE);
-	/* First clear the PHY */
-	phy_write(phydev, MII_BMCR, ctl | BMCR_RESET);
-
-	return genphy_config_aneg(phydev);
-}
-
-static int et1011c_read_status(struct phy_device *phydev)
-{
-	int ret;
-	u32 val;
-	static int speed;
-	ret = genphy_read_status(phydev);
-
-	if (speed != phydev->speed) {
-		speed = phydev->speed;
-		val = phy_read(phydev, ET1011C_STATUS_REG);
-		if ((val & ET1011C_SPEED_MASK) ==
-					ET1011C_GIGABIT_SPEED) {
-			val = phy_read(phydev, ET1011C_CONFIG_REG);
-			val &= ~ET1011C_TX_FIFO_MASK;
-			phy_write(phydev, ET1011C_CONFIG_REG, val\
-					| ET1011C_GMII_INTERFACE\
-					| ET1011C_SYS_CLK_EN\
-					| ET1011C_TX_FIFO_DEPTH_16);
-
-		}
-	}
-	return ret;
-}
-
-static struct phy_driver et1011c_driver = {
-	.phy_id		= 0x0282f014,
-	.name		= "ET1011C",
-	.phy_id_mask	= 0xfffffff0,
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_1000baseT_Full),
-	.flags		= PHY_POLL,
-	.config_aneg	= et1011c_config_aneg,
-	.read_status	= et1011c_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static int __init et1011c_init(void)
-{
-	return phy_driver_register(&et1011c_driver);
-}
-
-static void __exit et1011c_exit(void)
-{
-	phy_driver_unregister(&et1011c_driver);
-}
-
-module_init(et1011c_init);
-module_exit(et1011c_exit);
-
-static struct mdio_device_id __maybe_unused et1011c_tbl[] = {
-	{ 0x0282f014, 0xfffffff0 },
-	{ }
-};
-
-MODULE_DEVICE_TABLE(mdio, et1011c_tbl);
-- 
1.7.2.5
