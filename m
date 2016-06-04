From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: [RFC v3 1/3] NET: PHY: adds driver for Intel XWAY PHY
Date: Sat,  4 Jun 2016 13:45:26 +0200
Message-ID: <1465040728-4904-2-git-send-email-hauke@hauke-m.de>
References: <1465040728-4904-1-git-send-email-hauke@hauke-m.de>
Cc: alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, openwrt-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org,
	hauke.mehrtens-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, daniel.schwierzeck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	eckert.florian-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465040728-4904-1-git-send-email-hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds support for the Intel (former Lantiq) XWAY 11G and 22E PHYs.
These PHYs are also named PEF 7061, PEF 7071, PEF 7072.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Signed-off-by: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
---
 drivers/net/phy/Kconfig      |   6 +
 drivers/net/phy/Makefile     |   1 +
 drivers/net/phy/intel-xway.c | 389 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 396 insertions(+)
 create mode 100644 drivers/net/phy/intel-xway.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..9efe399 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -271,6 +271,12 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config INTEL_XWAY_PHY
+	tristate "Driver for Intel XWAY PHYs"
+	---help---
+	  Supports the Intel XWAY (former Lantiq) 11G and 22E PHYs.
+	  These PHYs are also named PEF 7061, PEF 7071 and PEF 7072
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcdbb92..c26b651 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
diff --git a/drivers/net/phy/intel-xway.c b/drivers/net/phy/intel-xway.c
new file mode 100644
index 0000000..c789462
--- /dev/null
+++ b/drivers/net/phy/intel-xway.c
@@ -0,0 +1,389 @@
+/*
+ * Copyright (C) 2012 Daniel Schwierzeck <daniel.schwierzeck-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
+ * Copyright (C) 2016 Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/mdio.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+
+#define XWAY_MDIO_IMASK			0x19	/* interrupt mask */
+#define XWAY_MDIO_ISTAT			0x1A	/* interrupt status */
+
+#define XWAY_MDIO_INIT_WOL		BIT(15)	/* Wake-On-LAN */
+#define XWAY_MDIO_INIT_MSRE		BIT(14)
+#define XWAY_MDIO_INIT_NPRX		BIT(13)
+#define XWAY_MDIO_INIT_NPTX		BIT(12)
+#define XWAY_MDIO_INIT_ANE		BIT(11)	/* Auto-Neg error */
+#define XWAY_MDIO_INIT_ANC		BIT(10)	/* Auto-Neg complete */
+#define XWAY_MDIO_INIT_ADSC		BIT(5)	/* Link auto-downspeed detect */
+#define XWAY_MDIO_INIT_MPIPC		BIT(4)
+#define XWAY_MDIO_INIT_MDIXC		BIT(3)
+#define XWAY_MDIO_INIT_DXMC		BIT(2)	/* Duplex mode change */
+#define XWAY_MDIO_INIT_LSPC		BIT(1)	/* Link speed change */
+#define XWAY_MDIO_INIT_LSTC		BIT(0)	/* Link state change */
+#define XWAY_MDIO_INIT_MASK		(XWAY_MDIO_INIT_LSTC | \
+					 XWAY_MDIO_INIT_ADSC)
+
+#define ADVERTISED_MPD			BIT(10)	/* Multi-port device */
+
+/* LED Configuration */
+#define XWAY_MMD_LEDCH			0x01E0
+/* Inverse of SCAN Function */
+#define  XWAY_MMD_LEDCH_NACS_NONE	0x0000
+#define  XWAY_MMD_LEDCH_NACS_LINK	0x0001
+#define  XWAY_MMD_LEDCH_NACS_PDOWN	0x0002
+#define  XWAY_MMD_LEDCH_NACS_EEE	0x0003
+#define  XWAY_MMD_LEDCH_NACS_ANEG	0x0004
+#define  XWAY_MMD_LEDCH_NACS_ABIST	0x0005
+#define  XWAY_MMD_LEDCH_NACS_CDIAG	0x0006
+#define  XWAY_MMD_LEDCH_NACS_TEST	0x0007
+/* Slow Blink Frequency */
+#define  XWAY_MMD_LEDCH_SBF_F02HZ	0x0000
+#define  XWAY_MMD_LEDCH_SBF_F04HZ	0x0010
+#define  XWAY_MMD_LEDCH_SBF_F08HZ	0x0020
+#define  XWAY_MMD_LEDCH_SBF_F16HZ	0x0030
+/* Fast Blink Frequency */
+#define  XWAY_MMD_LEDCH_FBF_F02HZ	0x0000
+#define  XWAY_MMD_LEDCH_FBF_F04HZ	0x0040
+#define  XWAY_MMD_LEDCH_FBF_F08HZ	0x0080
+#define  XWAY_MMD_LEDCH_FBF_F16HZ	0x00C0
+/* LED Configuration */
+#define XWAY_MMD_LEDCL			0x01E1
+/* Complex Blinking Configuration */
+#define  XWAY_MMD_LEDCH_CBLINK_NONE	0x0000
+#define  XWAY_MMD_LEDCH_CBLINK_LINK	0x0001
+#define  XWAY_MMD_LEDCH_CBLINK_PDOWN	0x0002
+#define  XWAY_MMD_LEDCH_CBLINK_EEE	0x0003
+#define  XWAY_MMD_LEDCH_CBLINK_ANEG	0x0004
+#define  XWAY_MMD_LEDCH_CBLINK_ABIST	0x0005
+#define  XWAY_MMD_LEDCH_CBLINK_CDIAG	0x0006
+#define  XWAY_MMD_LEDCH_CBLINK_TEST	0x0007
+/* Complex SCAN Configuration */
+#define  XWAY_MMD_LEDCH_SCAN_NONE	0x0000
+#define  XWAY_MMD_LEDCH_SCAN_LINK	0x0010
+#define  XWAY_MMD_LEDCH_SCAN_PDOWN	0x0020
+#define  XWAY_MMD_LEDCH_SCAN_EEE	0x0030
+#define  XWAY_MMD_LEDCH_SCAN_ANEG	0x0040
+#define  XWAY_MMD_LEDCH_SCAN_ABIST	0x0050
+#define  XWAY_MMD_LEDCH_SCAN_CDIAG	0x0060
+#define  XWAY_MMD_LEDCH_SCAN_TEST	0x0070
+/* Configuration for LED Pin x */
+#define XWAY_MMD_LED0H			0x01E2
+/* Fast Blinking Configuration */
+#define  XWAY_MMD_LEDxH_BLINKF_MASK	0x000F
+#define  XWAY_MMD_LEDxH_BLINKF_NONE	0x0000
+#define  XWAY_MMD_LEDxH_BLINKF_LINK10	0x0001
+#define  XWAY_MMD_LEDxH_BLINKF_LINK100	0x0002
+#define  XWAY_MMD_LEDxH_BLINKF_LINK10X	0x0003
+#define  XWAY_MMD_LEDxH_BLINKF_LINK1000	0x0004
+#define  XWAY_MMD_LEDxH_BLINKF_LINK10_0	0x0005
+#define  XWAY_MMD_LEDxH_BLINKF_LINK100X	0x0006
+#define  XWAY_MMD_LEDxH_BLINKF_LINK10XX	0x0007
+#define  XWAY_MMD_LEDxH_BLINKF_PDOWN	0x0008
+#define  XWAY_MMD_LEDxH_BLINKF_EEE	0x0009
+#define  XWAY_MMD_LEDxH_BLINKF_ANEG	0x000A
+#define  XWAY_MMD_LEDxH_BLINKF_ABIST	0x000B
+#define  XWAY_MMD_LEDxH_BLINKF_CDIAG	0x000C
+/* Constant On Configuration */
+#define  XWAY_MMD_LEDxH_CON_MASK	0x00F0
+#define  XWAY_MMD_LEDxH_CON_NONE	0x0000
+#define  XWAY_MMD_LEDxH_CON_LINK10	0x0010
+#define  XWAY_MMD_LEDxH_CON_LINK100	0x0020
+#define  XWAY_MMD_LEDxH_CON_LINK10X	0x0030
+#define  XWAY_MMD_LEDxH_CON_LINK1000	0x0040
+#define  XWAY_MMD_LEDxH_CON_LINK10_0	0x0050
+#define  XWAY_MMD_LEDxH_CON_LINK100X	0x0060
+#define  XWAY_MMD_LEDxH_CON_LINK10XX	0x0070
+#define  XWAY_MMD_LEDxH_CON_PDOWN	0x0080
+#define  XWAY_MMD_LEDxH_CON_EEE		0x0090
+#define  XWAY_MMD_LEDxH_CON_ANEG	0x00A0
+#define  XWAY_MMD_LEDxH_CON_ABIST	0x00B0
+#define  XWAY_MMD_LEDxH_CON_CDIAG	0x00C0
+#define  XWAY_MMD_LEDxH_CON_COPPER	0x00D0
+#define  XWAY_MMD_LEDxH_CON_FIBER	0x00E0
+/* Configuration for LED Pin x */
+#define XWAY_MMD_LED0L			0x01E3
+/* Pulsing Configuration */
+#define  XWAY_MMD_LEDxL_PULSE_MASK	0x000F
+#define  XWAY_MMD_LEDxL_PULSE_NONE	0x0000
+#define  XWAY_MMD_LEDxL_PULSE_TXACT	0x0001
+#define  XWAY_MMD_LEDxL_PULSE_RXACT	0x0002
+#define  XWAY_MMD_LEDxL_PULSE_COL	0x0004
+/* Slow Blinking Configuration */
+#define  XWAY_MMD_LEDxL_BLINKS_MASK	0x00F0
+#define  XWAY_MMD_LEDxL_BLINKS_NONE	0x0000
+#define  XWAY_MMD_LEDxL_BLINKS_LINK10	0x0010
+#define  XWAY_MMD_LEDxL_BLINKS_LINK100	0x0020
+#define  XWAY_MMD_LEDxL_BLINKS_LINK10X	0x0030
+#define  XWAY_MMD_LEDxL_BLINKS_LINK1000	0x0040
+#define  XWAY_MMD_LEDxL_BLINKS_LINK10_0	0x0050
+#define  XWAY_MMD_LEDxL_BLINKS_LINK100X	0x0060
+#define  XWAY_MMD_LEDxL_BLINKS_LINK10XX	0x0070
+#define  XWAY_MMD_LEDxL_BLINKS_PDOWN	0x0080
+#define  XWAY_MMD_LEDxL_BLINKS_EEE	0x0090
+#define  XWAY_MMD_LEDxL_BLINKS_ANEG	0x00A0
+#define  XWAY_MMD_LEDxL_BLINKS_ABIST	0x00B0
+#define  XWAY_MMD_LEDxL_BLINKS_CDIAG	0x00C0
+#define XWAY_MMD_LED1H			0x01E4
+#define XWAY_MMD_LED1L			0x01E5
+#define XWAY_MMD_LED2H			0x01E6
+#define XWAY_MMD_LED2L			0x01E7
+#define XWAY_MMD_LED3H			0x01E8
+#define XWAY_MMD_LED3L			0x01E9
+
+#define PHY_ID_PHY11G_1_3		0x030260D1
+#define PHY_ID_PHY22F_1_3		0x030260E1
+#define PHY_ID_PHY11G_1_4		0xD565A400
+#define PHY_ID_PHY22F_1_4		0xD565A410
+#define PHY_ID_PHY11G_1_5		0xD565A401
+#define PHY_ID_PHY22F_1_5		0xD565A411
+#define PHY_ID_PHY11G_VR9		0xD565A409
+#define PHY_ID_PHY22F_VR9		0xD565A419
+
+static int xway_gphy_config_init(struct phy_device *phydev)
+{
+	int err;
+	u32 ledxh;
+	u32 ledxl;
+
+	/* Mask all interrupts */
+	err = phy_write(phydev, XWAY_MDIO_IMASK, 0);
+	if (err)
+		return err;
+
+	/* Clear all pending interrupts */
+	phy_read(phydev, XWAY_MDIO_ISTAT);
+
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LEDCH, MDIO_MMD_VEND2,
+			       XWAY_MMD_LEDCH_NACS_NONE |
+			       XWAY_MMD_LEDCH_SBF_F02HZ |
+			       XWAY_MMD_LEDCH_FBF_F16HZ);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LEDCL, MDIO_MMD_VEND2,
+			       XWAY_MMD_LEDCH_CBLINK_NONE |
+			       XWAY_MMD_LEDCH_SCAN_NONE);
+
+	/**
+	 * In most cases only one LED is connected to this phy, so
+	 * configure them all to constant on and pulse mode. LED3 is
+	 * only available in some packages, leave it in its reset
+	 * configuration.
+	 */
+	ledxh = XWAY_MMD_LEDxH_BLINKF_NONE | XWAY_MMD_LEDxH_CON_LINK10XX;
+	ledxl = XWAY_MMD_LEDxL_PULSE_TXACT | XWAY_MMD_LEDxL_PULSE_RXACT |
+		XWAY_MMD_LEDxL_BLINKS_NONE;
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0H, MDIO_MMD_VEND2, ledxh);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0L, MDIO_MMD_VEND2, ledxl);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED1H, MDIO_MMD_VEND2, ledxh);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED1L, MDIO_MMD_VEND2, ledxl);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2H, MDIO_MMD_VEND2, ledxh);
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2L, MDIO_MMD_VEND2, ledxl);
+
+	return 0;
+}
+
+static int xway_gphy14_config_aneg(struct phy_device *phydev)
+{
+	int reg, err;
+
+	/* Advertise as multi-port device, see IEEE802.3-2002 40.5.1.1 */
+	/* This is a workaround for an errata in rev < 1.5 devices */
+	reg = phy_read(phydev, MII_CTRL1000);
+	reg |= ADVERTISED_MPD;
+	err = phy_write(phydev, MII_CTRL1000, reg);
+	if (err)
+		return err;
+
+	return genphy_config_aneg(phydev);
+}
+
+static int xway_gphy_ack_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	/**
+	 * Possible IRQ numbers:
+	 * - IM3_IRL18 for GPHY0
+	 * - IM3_IRL17 for GPHY1
+	 *
+	 * Due to a silicon bug IRQ lines are not really independent from
+	 * each other. Sometimes the two lines are driven at the same time
+	 * if only one GPHY core raises the interrupt.
+	 */
+	reg = phy_read(phydev, XWAY_MDIO_ISTAT);
+
+	return (reg < 0) ? reg : 0;
+}
+
+static int xway_gphy_did_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = phy_read(phydev, XWAY_MDIO_ISTAT);
+
+	return reg & XWAY_MDIO_INIT_MASK;
+}
+
+static int xway_gphy_config_intr(struct phy_device *phydev)
+{
+	u16 mask = 0;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		mask = XWAY_MDIO_INIT_MASK;
+
+	return phy_write(phydev, XWAY_MDIO_IMASK, mask);
+}
+
+static struct phy_driver xway_gphy[] = {
+	{
+		.phy_id		= PHY_ID_PHY11G_1_3,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.3",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		 /* there is an errata regarding irqs in this rev */
+		.flags		= 0,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= xway_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_3,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY22F (PEF 7061) v1.3",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		 /* there is an errata regarding irqs in this rev */
+		.flags		= 0,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= xway_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY11G_1_4,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.4",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= xway_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_4,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY22F (PEF 7061) v1.4",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= xway_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY11G_1_5,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.5 / v1.6",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_5,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY22F (PEF 7061) v1.5 / v1.6",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY11G_VR9,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY11G (xRX200)",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_VR9,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Intel XWAY PHY22F (xRX200)",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= xway_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= xway_gphy_ack_interrupt,
+		.did_interrupt	= xway_gphy_did_interrupt,
+		.config_intr	= xway_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	},
+};
+module_phy_driver(xway_gphy);
+
+static struct mdio_device_id __maybe_unused xway_gphy_tbl[] = {
+	{ PHY_ID_PHY11G_1_3, 0xffffffff },
+	{ PHY_ID_PHY22F_1_3, 0xffffffff },
+	{ PHY_ID_PHY11G_1_4, 0xffffffff },
+	{ PHY_ID_PHY22F_1_4, 0xffffffff },
+	{ PHY_ID_PHY11G_1_5, 0xffffffff },
+	{ PHY_ID_PHY22F_1_5, 0xffffffff },
+	{ PHY_ID_PHY11G_VR9, 0xffffffff },
+	{ PHY_ID_PHY22F_VR9, 0xffffffff },
+	{ }
+};
+MODULE_DEVICE_TABLE(mdio, xway_gphy_tbl);
+
+MODULE_DESCRIPTION("Intel XWAY PHY driver");
+MODULE_LICENSE("GPL");
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
