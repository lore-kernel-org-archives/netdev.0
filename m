From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH] net: phy: dp83848: Add TI DP83848 Ethernet PHY
Date: Tue, 20 Oct 2015 16:28:57 -0500
Message-ID: <1445376537-9291-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>, Dan Murphy <dmurphy@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the TI DP83848 Ethernet PHY device.

The DP83848 is a highly reliable, feature rich, IEEE 802.3 compliant
single port 10/100 Mb/s Ethernet Physical Layer Transceiver supporting
the MII and RMII interfaces.

Signed-off-by: Andrew F. Davis <afd@ti.com>
Signed-off-by: Dan Murphy <dmurphy@ti.com>
---
 drivers/net/phy/Kconfig   |  5 +++
 drivers/net/phy/Makefile  |  1 +
 drivers/net/phy/dp83848.c | 99 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+)
 create mode 100644 drivers/net/phy/dp83848.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index c5ad98a..12fa29a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -122,6 +122,11 @@ config MICREL_PHY
 	---help---
 	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
 
+config DP83848_PHY
+	tristate "Driver for Texas Instruments DP83848 PHY"
+	---help---
+	  Supports the DP83848 PHY.
+
 config DP83867_PHY
 	tristate "Drivers for Texas Instruments DP83867 Gigabit PHY"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 87f079c..b748224 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
+obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
 obj-$(CONFIG_DP83867_PHY)	+= dp83867.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
new file mode 100644
index 0000000..5ce9bef
--- /dev/null
+++ b/drivers/net/phy/dp83848.c
@@ -0,0 +1,99 @@
+/*
+ * Driver for the Texas Instruments DP83848 PHY
+ *
+ * Copyright (C) 2015 Texas Instruments Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/phy.h>
+
+#define DP83848_PHY_ID			0x20005c90
+
+/* Registers */
+#define DP83848_MICR			0x11
+#define DP83848_MISR			0x12
+
+/* MICR Register Fields */
+#define DP83848_MICR_INT_OE		BIT(0) /* Interrupt Output Enable */
+#define DP83848_MICR_INTEN		BIT(1) /* Interrupt Enable */
+
+/* MISR Register Fields */
+#define DP83848_MISR_RHF_INT_EN		BIT(0) /* Receive Error Counter */
+#define DP83848_MISR_FHF_INT_EN		BIT(1) /* False Carrier Counter */
+#define DP83848_MISR_ANC_INT_EN		BIT(2) /* Auto-negotiation complete */
+#define DP83848_MISR_DUP_INT_EN		BIT(3) /* Duplex Status */
+#define DP83848_MISR_SPD_INT_EN		BIT(4) /* Speed status */
+#define DP83848_MISR_LINK_INT_EN	BIT(5) /* Link status */
+#define DP83848_MISR_ED_INT_EN		BIT(6) /* Energy detect */
+#define DP83848_MISR_LQM_INT_EN		BIT(7) /* Link Quality Monitor */
+
+static int dp83848_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, DP83848_MISR);
+
+	return err < 0 ? err : 0;
+}
+
+static int dp83848_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		err = phy_write(phydev, DP83848_MICR,
+				DP83848_MICR_INT_OE |
+				DP83848_MICR_INTEN);
+		if (err < 0)
+			return err;
+
+		return phy_write(phydev, DP83848_MISR,
+				 DP83848_MISR_ANC_INT_EN |
+				 DP83848_MISR_DUP_INT_EN |
+				 DP83848_MISR_SPD_INT_EN |
+				 DP83848_MISR_LINK_INT_EN);
+	}
+
+	return phy_write(phydev, DP83848_MICR, 0x0);
+}
+
+static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
+	{ DP83848_PHY_ID, 0xfffffff0 },
+	{ }
+};
+MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
+
+static struct phy_driver dp83848_driver[] = {
+	{
+		.phy_id		= DP83848_PHY_ID,
+		.phy_id_mask	= 0xfffffff0,
+		.name		= "TI DP83848",
+		.features	= PHY_BASIC_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+
+		.soft_reset	= genphy_soft_reset,
+		.config_init	= genphy_config_init,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+
+		/* IRQ related */
+		.ack_interrupt	= dp83848_ack_interrupt,
+		.config_intr	= dp83848_config_intr,
+
+		.driver		= { .owner = THIS_MODULE, },
+	},
+};
+module_phy_driver(dp83848_driver);
+
+MODULE_DESCRIPTION("Texas Instruments DP83848 PHY driver");
+MODULE_AUTHOR("Andrew F. Davis <afd@ti.com");
+MODULE_LICENSE("GPL");
-- 
1.9.1
