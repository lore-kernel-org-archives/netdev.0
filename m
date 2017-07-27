From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v2 01/11] net: phy: Add rockchip phy driver support
Date: Thu, 27 Jul 2017 20:55:46 +0800
Message-ID: <1501160156-30328-2-git-send-email-david.wu@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: huangtao@rock-chips.com, hwg@rock-chips.com, alexandre.torgue@st.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
 David Wu <david.wu@rock-chips.com>, peppe.cavallaro@st.com,
 linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch, f.fainelli@gmail.com,
 robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
 will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Support internal ephy currently.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
changes in v2:
 - Alphabetic order for Kconfig and Makefile.
 - Add analog register init.
 - Disable auto-mdix for workround.
 - Rename config

 drivers/net/phy/Kconfig    |   5 ++
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/rockchip.c | 128 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 134 insertions(+)
 create mode 100644 drivers/net/phy/rockchip.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2dda720..8dc6cd7 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -334,6 +334,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config ROCKCHIP_PHY
+        tristate "Drivers for ROCKCHIP PHYs"
+        ---help---
+          Currently supports the internal ephy.
+
 config SMSC_PHY
 	tristate "SMSC PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 8e9b9f3..350520e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -66,6 +66,7 @@ obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
+obj-$(CONFIG_ROCKCHIP_PHY)	+= rockchip.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
diff --git a/drivers/net/phy/rockchip.c b/drivers/net/phy/rockchip.c
new file mode 100644
index 0000000..3f74658
--- /dev/null
+++ b/drivers/net/phy/rockchip.c
@@ -0,0 +1,128 @@
+/**
+ * drivers/net/phy/rockchip.c
+ *
+ * Driver for ROCKCHIP PHY
+ *
+ * Copyright (c) 2017, Fuzhou Rockchip Electronics Co., Ltd
+ *
+ * David Wu<david.wu@rock-chips.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+#define MII_INTERNAL_CTRL_STATUS	17
+#define SMI_ADDR_TSTCNTL		20
+#define SMI_ADDR_TSTREAD1		21
+#define SMI_ADDR_TSTREAD2		22
+#define SMI_ADDR_TSTWRITE		23
+
+#define AUTOMDIX_EN			BIT(7)
+#define TSTCNTL_RD			(BIT(15) | BIT(10))
+#define TSTCNTL_WR          		(BIT(14) | BIT(10))
+
+#define WR_ADDR_A7CFG			0x18
+
+static void rockchip_init_tstmode(struct phy_device *phydev)
+{
+	/* Enable access to Analog and DSP register banks */
+	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
+	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);
+	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
+}
+
+static void  rockchip_close_tstmode(struct phy_device *phydev)
+{
+	/* Back to basic register bank */
+	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);
+}
+
+static void rockchip_internal_phy_analog_init(struct phy_device *phydev)
+{
+	rockchip_init_tstmode(phydev);
+
+	/*
+	 * Adjust tx amplitude to make sginal better,
+	 * the default value is 0x8.
+	 */
+	phy_write(phydev, SMI_ADDR_TSTWRITE, 0xB);
+	phy_write(phydev, SMI_ADDR_TSTCNTL, TSTCNTL_WR | WR_ADDR_A7CFG);
+
+	rockchip_close_tstmode(phydev);
+}
+
+static int rockchip_internal_phy_config_init(struct phy_device *phydev)
+{
+	int val;
+
+	/*
+	 * The auto MIDX has linked problem on some board,
+	 * workround to disable auto MDIX.
+	 */
+	val = phy_read(phydev, MII_INTERNAL_CTRL_STATUS);
+	val &= ~AUTOMDIX_EN;
+	phy_write(phydev, MII_INTERNAL_CTRL_STATUS, val);
+
+	rockchip_internal_phy_analog_init(phydev);
+
+	return 0;
+}
+
+static int rockchip_internal_phy_read_status(struct phy_device *phydev)
+{
+	int ret, old_speed;
+
+	old_speed = phydev->speed;
+	ret = genphy_read_status(phydev);
+	if (ret)
+		return ret;
+
+	/*
+	 * If mode switch happens from 10BT to 100BT, all DSP/AFE
+	 * registers are set to default values. So any AFE/DSP
+	 * registers have to be re-initialized in this case.
+	 */
+	if ((old_speed == SPEED_10) && (phydev->speed == SPEED_100))
+		rockchip_internal_phy_analog_init(phydev);
+
+	return ret;
+}
+
+static struct phy_driver rockchip_phy_driver[] = {
+{
+	.phy_id 	= 0x1234d400,
+	.phy_id_mask	= 0xffff0000,
+	.name		= "rockchip internal ephy",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+			  | SUPPORTED_Asym_Pause),
+	.soft_reset 	= genphy_soft_reset,
+	.config_init	= rockchip_internal_phy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= rockchip_internal_phy_read_status,
+	.suspend	= genphy_suspend,
+	.resume 	= genphy_resume,
+},
+};
+
+module_phy_driver(rockchip_phy_driver);
+
+static struct mdio_device_id __maybe_unused rockchip_phy_tbl[] = {
+	{ 0x1234d400, 0xffff0000 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, rockchip_phy_tbl);
+
+MODULE_AUTHOR("David Wu<david.wu@rock-chips.com>");
+MODULE_DESCRIPTION("Rockchip phy driver");
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
