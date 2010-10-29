From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 1/2] Gemini: create platform device for ethernet in Raidsonic IB-4220B
Date: Fri, 29 Oct 2010 12:23:08 +0200 (CEST)
Message-ID: <181be0f834f3670249d3c8d7ba1462dab1ece2c1.1288321597.git.mirq-linux@rere.qmqm.pl>
References: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paulius Zaleckas <paulius.zaleckas@gmail.com>,
	Janos Laube <janos.dev@gmail.com>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44360 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756930Ab0J2KXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 06:23:09 -0400
In-Reply-To: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is cherry-picked from:

git://git.berlios.de/gemini-board ib4220

Code by Paulius Zaleckas <paulius.zaleckas@gmail.com>
and Janos Laube <janos.dev@gmail.com>.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

 arch/arm/mach-gemini/board-nas4220b.c    |   53 ++++++++++++++++++++++=
++++++++
 arch/arm/mach-gemini/common.h            |    2 +
 arch/arm/mach-gemini/devices.c           |   52 ++++++++++++++++++++++=
+++++++
 arch/arm/mach-gemini/include/mach/gmac.h |   21 ++++++++++++
 4 files changed, 128 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-gemini/include/mach/gmac.h

diff --git a/arch/arm/mach-gemini/board-nas4220b.c b/arch/arm/mach-gemi=
ni/board-nas4220b.c
index 2ba096d..ca6ec5a 100644
--- a/arch/arm/mach-gemini/board-nas4220b.c
+++ b/arch/arm/mach-gemini/board-nas4220b.c
@@ -26,6 +26,7 @@
 #include <asm/mach/arch.h>
 #include <asm/mach/time.h>
=20
+#include <mach/gmac.h>
 #include <mach/hardware.h>
 #include <mach/global_reg.h>
=20
@@ -91,13 +92,65 @@ static struct platform_device ib4220b_key_device =3D=
 {
 	},
 };
=20
+static struct mdio_gpio_platform_data ib4220b_mdio =3D {
+	.mdc		=3D 22,
+	.mdio		=3D 21,
+	.phy_mask	=3D ~(1 << 1),
+};
+
+static struct platform_device ib4220b_phy_device =3D {
+	.name	=3D "mdio-gpio",
+	.id	=3D 0,
+	.dev	=3D {
+		.platform_data =3D &ib4220b_mdio,
+	},
+};
+
+static struct gemini_gmac_platform_data ib4220b_gmac_data =3D {
+	.bus_id[0] =3D "0:01",
+	.interface[0] =3D PHY_INTERFACE_MODE_RGMII,
+};
+
+static void __init gmac_ib4220b_init(void)
+{
+	unsigned int val;
+
+	val =3D __raw_readl(IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_IO_DRIVING_CTRL);
+	val |=3D (0x3 << GMAC0_PADS_SHIFT) | (0x3 << GMAC1_PADS_SHIFT);
+	__raw_writel(val, IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_IO_DRIVING_CTRL);
+
+	val =3D (0x0 << GMAC0_RXDV_SKEW_SHIFT) | (0xf << GMAC0_RXC_SKEW_SHIFT=
) |
+		(0x7 << GMAC0_TXEN_SKEW_SHIFT) | (0xa << GMAC0_TXC_SKEW_SHIFT) |
+		(0x0 << GMAC1_RXDV_SKEW_SHIFT) | (0xf << GMAC1_RXC_SKEW_SHIFT) |
+		(0x7 << GMAC1_TXEN_SKEW_SHIFT) | (0xa << GMAC1_TXC_SKEW_SHIFT);
+	__raw_writel(val, IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_GMAC_CTRL_SKEW_CTRL);
+
+	__raw_writel(0x77777777, IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_GMAC0_DATA_SKEW_CTRL);
+	__raw_writel(0x77777777, IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_GMAC1_DATA_SKEW_CTRL);
+
+	val =3D __raw_readl(IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_ARBITRATION1_CTRL) & ~BURST_LENGTH_MASK;
+	val |=3D (0x20 << BURST_LENGTH_SHIFT);
+	__raw_writel(val, IO_ADDRESS(GEMINI_GLOBAL_BASE) +
+		GLOBAL_ARBITRATION1_CTRL);
+}
+
 static void __init ib4220b_init(void)
 {
 	gemini_gpio_init();
+	gmac_ib4220b_init();
+
 	platform_register_uart();
 	platform_register_pflash(SZ_16M, NULL, 0);
 	platform_device_register(&ib4220b_led_device);
 	platform_device_register(&ib4220b_key_device);
+	platform_device_register(&ib4220b_phy_device);
+	platform_register_ethernet(&ib4220b_gmac_data);
 }
=20
 MACHINE_START(NAS4220B, "Raidsonic NAS IB-4220-B")
diff --git a/arch/arm/mach-gemini/common.h b/arch/arm/mach-gemini/commo=
n.h
index 9392834..4eafed5 100644
--- a/arch/arm/mach-gemini/common.h
+++ b/arch/arm/mach-gemini/common.h
@@ -13,6 +13,7 @@
 #define __GEMINI_COMMON_H__
=20
 struct mtd_partition;
+struct gemini_gmac_platform_data;
=20
 extern void gemini_map_io(void);
 extern void gemini_init_irq(void);
@@ -21,6 +22,7 @@ extern void gemini_gpio_init(void);
=20
 /* Common platform devices registration functions */
 extern int platform_register_uart(void);
+extern int platform_register_ethernet(struct gemini_gmac_platform_data=
 *pdata);
 extern int platform_register_pflash(unsigned int size,
 				    struct mtd_partition *parts,
 				    unsigned int nr_parts);
diff --git a/arch/arm/mach-gemini/devices.c b/arch/arm/mach-gemini/devi=
ces.c
index 6b52525..ead7ab1 100644
--- a/arch/arm/mach-gemini/devices.c
+++ b/arch/arm/mach-gemini/devices.c
@@ -17,6 +17,7 @@
 #include <mach/irqs.h>
 #include <mach/hardware.h>
 #include <mach/global_reg.h>
+#include <mach/gmac.h>
=20
 static struct plat_serial8250_port serial_platform_data[] =3D {
 	{
@@ -45,6 +46,57 @@ int platform_register_uart(void)
 	return platform_device_register(&serial_device);
 }
=20
+
+static struct resource gmac_resources[] =3D {
+	{
+		.start	=3D GEMINI_TOE_BASE,
+		.end	=3D GEMINI_TOE_BASE + 0xffff,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	{
+		.start	=3D IRQ_GMAC0,
+		.end	=3D IRQ_GMAC0,
+		.flags	=3D IORESOURCE_IRQ,
+	},
+	{
+		.start	=3D IRQ_GMAC1,
+		.end	=3D IRQ_GMAC1,
+		.flags	=3D IORESOURCE_IRQ,
+	},
+};
+
+static u64 gmac_dmamask =3D 0xffffffffUL;
+
+static struct platform_device ethernet_device =3D {
+	.name	=3D "gemini-gmac",
+	.id	=3D 0,
+	.dev	=3D {
+		.dma_mask =3D &gmac_dmamask,
+		.coherent_dma_mask =3D 0xffffffff,
+	},
+	.num_resources	=3D ARRAY_SIZE(gmac_resources),
+	.resource	=3D gmac_resources,
+};
+
+int __init platform_register_ethernet(struct gemini_gmac_platform_data=
 *pdata)
+{
+	unsigned int reg =3D __raw_readl(IO_ADDRESS(GEMINI_GLOBAL_BASE) + GLO=
BAL_MISC_CTRL);
+
+	reg &=3D ~(GMAC_GMII | GMAC_1_ENABLE);
+
+	if (pdata->bus_id[1])
+		reg |=3D GMAC_1_ENABLE;
+	else if (pdata->interface[0] =3D=3D PHY_INTERFACE_MODE_GMII)
+		reg |=3D GMAC_GMII;	=09
+
+	__raw_writel(reg, IO_ADDRESS(GEMINI_GLOBAL_BASE) + GLOBAL_MISC_CTRL);
+
+	ethernet_device.dev.platform_data =3D pdata;
+
+	return platform_device_register(&ethernet_device);
+}
+
+
 static struct resource flash_resource =3D {
 	.start	=3D GEMINI_FLASH_BASE,
 	.flags	=3D IORESOURCE_MEM,
diff --git a/arch/arm/mach-gemini/include/mach/gmac.h b/arch/arm/mach-g=
emini/include/mach/gmac.h
new file mode 100644
index 0000000..c6eeacc
--- /dev/null
+++ b/arch/arm/mach-gemini/include/mach/gmac.h
@@ -0,0 +1,21 @@
+/*
+ * Gemini GMAC specific defines
+ *
+ * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt=
>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef __MACH_GMAC_H__
+#define __MACH_GMAC_H__
+
+#include <linux/phy.h>
+
+struct gemini_gmac_platform_data {
+	char *bus_id[2]; /* NULL means that this port is not used */
+	phy_interface_t interface[2];
+};
+
+#endif /* __MACH_GMAC_H__ */
--=20
1.7.1

