From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 01/11] net: phy: Add rockchip PHY driver support
Date: Thu, 10 Aug 2017 21:56:40 +0800
Message-ID: <1502373410-2423-2-git-send-email-david.wu@rock-chips.com>
References: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support integrated ethernet PHY currently.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
changes in v4:
 - Remove SUPPORTED_[Asym_]Pause.
 - Some minor fix like defines.

changes in v5:
 - Rename internal to integrated.
 - Remove PHY_IS_INTERNAL flag.

 drivers/net/phy/Kconfig    |   5 +
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/rockchip.c | 233 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+)
 create mode 100644 drivers/net/phy/rockchip.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2dda720..255ac3a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -334,6 +334,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config ROCKCHIP_PHY
+        tristate "Driver for Rockchip Ethernet PHYs"
+        ---help---
+          Currently supports the integrated Ethernet PHY.
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
index 0000000..c092af1
--- /dev/null
+++ b/drivers/net/phy/rockchip.c
@@ -0,0 +1,233 @@
+/**
+ * drivers/net/phy/rockchip.c
+ *
+ * Driver for ROCKCHIP Ethernet PHYs
+ *
+ * Copyright (c) 2017, Fuzhou Rockchip Electronics Co., Ltd
+ *
+ * David Wu <david.wu@rock-chips.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#define INTERNAL_EPHY_ID			0x1234d400
+
+#define MII_INTERNAL_CTRL_STATUS		17
+#define SMI_ADDR_TSTCNTL			20
+#define SMI_ADDR_TSTREAD1			21
+#define SMI_ADDR_TSTREAD2			22
+#define SMI_ADDR_TSTWRITE			23
+#define MII_SPECIAL_CONTROL_STATUS		31
+
+#define MII_AUTO_MDIX_EN			BIT(7)
+#define MII_MDIX_EN				BIT(6)
+
+#define MII_SPEED_10				BIT(2)
+#define MII_SPEED_100				BIT(3)
+
+#define TSTCNTL_RD				(BIT(15) | BIT(10))
+#define TSTCNTL_WR				(BIT(14) | BIT(10))
+
+#define TSTMODE_ENABLE				0x400
+#define TSTMODE_DISABLE				0x0
+
+#define WR_ADDR_A7CFG				0x18
+
+static int rockchip_init_tstmode(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Enable access to Analog and DSP register banks */
+	ret = phy_write(phydev, SMI_ADDR_TSTCNTL, TSTMODE_ENABLE);
+	if (ret)
+		return ret;
+
+	ret = phy_write(phydev, SMI_ADDR_TSTCNTL, TSTMODE_DISABLE);
+	if (ret)
+		return ret;
+
+	return phy_write(phydev, SMI_ADDR_TSTCNTL, TSTMODE_ENABLE);
+}
+
+static int rockchip_close_tstmode(struct phy_device *phydev)
+{
+	/* Back to basic register bank */
+	return phy_write(phydev, SMI_ADDR_TSTCNTL, TSTMODE_DISABLE);
+}
+
+static int rockchip_integrated_phy_analog_init(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = rockchip_init_tstmode(phydev);
+	if (ret)
+		return ret;
+
+	/*
+	 * Adjust tx amplitude to make sginal better,
+	 * the default value is 0x8.
+	 */
+	ret = phy_write(phydev, SMI_ADDR_TSTWRITE, 0xB);
+	if (ret)
+		return ret;
+	ret = phy_write(phydev, SMI_ADDR_TSTCNTL, TSTCNTL_WR | WR_ADDR_A7CFG);
+	if (ret)
+		return ret;
+
+	return rockchip_close_tstmode(phydev);
+}
+
+static int rockchip_integrated_phy_config_init(struct phy_device *phydev)
+{
+	int val, ret;
+
+	/*
+	 * The auto MIDX has linked problem on some board,
+	 * workround to disable auto MDIX.
+	 */
+	val = phy_read(phydev, MII_INTERNAL_CTRL_STATUS);
+	if (val < 0)
+		return val;
+	val &= ~MII_AUTO_MDIX_EN;
+	ret = phy_write(phydev, MII_INTERNAL_CTRL_STATUS, val);
+	if (ret)
+		return ret;
+
+	return rockchip_integrated_phy_analog_init(phydev);
+}
+
+static void rockchip_link_change_notify(struct phy_device *phydev)
+{
+	int speed = SPEED_10;
+
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		int reg = phy_read(phydev, MII_SPECIAL_CONTROL_STATUS);
+
+		if (reg < 0) {
+			phydev_err(phydev, "phy_read err: %d.\n", reg);
+			return;
+		}
+
+		if (reg & MII_SPEED_100)
+			speed = SPEED_100;
+		else if (reg & MII_SPEED_10)
+			speed = SPEED_10;
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+
+		if (bmcr < 0) {
+			phydev_err(phydev, "phy_read err: %d.\n", bmcr);
+			return;
+		}
+
+		if (bmcr & BMCR_SPEED100)
+			speed = SPEED_100;
+		else
+			speed = SPEED_10;
+	}
+
+	/*
+	 * If mode switch happens from 10BT to 100BT, all DSP/AFE
+	 * registers are set to default values. So any AFE/DSP
+	 * registers have to be re-initialized in this case.
+	 */
+	if ((phydev->speed == SPEED_10) && (speed == SPEED_100)) {
+		int ret = rockchip_integrated_phy_analog_init(phydev);
+		if (ret)
+			phydev_err(phydev, "rockchip_integrated_phy_analog_init err: %d.\n",
+				   ret);
+	}
+}
+
+static int rockchip_set_polarity(struct phy_device *phydev, int polarity)
+{
+	int reg, err, val;
+
+	/* get the current settings */
+	reg = phy_read(phydev, MII_INTERNAL_CTRL_STATUS);
+	if (reg < 0)
+		return reg;
+
+	reg &= ~MII_AUTO_MDIX_EN;
+	val = reg;
+	switch (polarity) {
+	case ETH_TP_MDI:
+		val &= ~MII_MDIX_EN;
+		break;
+	case ETH_TP_MDI_X:
+		val |= MII_MDIX_EN;
+		break;
+	case ETH_TP_MDI_AUTO:
+	case ETH_TP_MDI_INVALID:
+	default:
+		return 0;
+	}
+
+	if (val != reg) {
+		/* Set the new polarity value in the register */
+		err = phy_write(phydev, MII_INTERNAL_CTRL_STATUS, val);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int rockchip_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	err = rockchip_set_polarity(phydev, phydev->mdix);
+	if (err < 0)
+		return err;
+
+	return genphy_config_aneg(phydev);
+}
+
+static int rockchip_phy_resume(struct phy_device *phydev)
+{
+	genphy_resume(phydev);
+
+	return rockchip_integrated_phy_config_init(phydev);
+}
+
+static struct phy_driver rockchip_phy_driver[] = {
+{
+	.phy_id			= INTERNAL_EPHY_ID,
+	.phy_id_mask		= 0xfffffff0,
+	.name			= "Rockchip integrated EPHY",
+	.features		= PHY_BASIC_FEATURES,
+	.flags			= 0,
+	.link_change_notify	= rockchip_link_change_notify,
+	.soft_reset		= genphy_soft_reset,
+	.config_init		= rockchip_integrated_phy_config_init,
+	.config_aneg		= rockchip_config_aneg,
+	.read_status		= genphy_read_status,
+	.suspend		= genphy_suspend,
+	.resume			= rockchip_phy_resume,
+},
+};
+
+module_phy_driver(rockchip_phy_driver);
+
+static struct mdio_device_id __maybe_unused rockchip_phy_tbl[] = {
+	{ INTERNAL_EPHY_ID, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, rockchip_phy_tbl);
+
+MODULE_AUTHOR("David Wu <david.wu@rock-chips.com>");
+MODULE_DESCRIPTION("Rockchip Ethernet PHY driver");
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
