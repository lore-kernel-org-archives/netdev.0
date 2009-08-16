From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Mon, 17 Aug 2009 01:05:35 +0200
Message-ID: <200908170105.38154.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:62670 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbZHPXFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 19:05:42 -0400
Received: by ewy10 with SMTP id 10so2603136ewy.37
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2009 16:05:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the board code to register a per-board au1000-eth
platform device to be used wit the au1000-eth platform driver in a
subsequent patch. Note that the au1000-eth driver knows about the
default driver settings such that we do not need to pass any
platform_data informations in most cases except db1x00.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/arch/mips/alchemy/devboards/db1x00/Makefile b/arch/mips/alchemy/devboards/db1x00/Makefile
index 432241a..532a214 100644
--- a/arch/mips/alchemy/devboards/db1x00/Makefile
+++ b/arch/mips/alchemy/devboards/db1x00/Makefile
@@ -5,4 +5,4 @@
 # Makefile for the Alchemy Semiconductor DBAu1xx0 boards.
 #
 
-obj-y := board_setup.o irqmap.o
+obj-y := board_setup.o irqmap.o platform.o
diff --git a/arch/mips/alchemy/devboards/db1x00/platform.c b/arch/mips/alchemy/devboards/db1x00/platform.c
new file mode 100644
index 0000000..df0d68a
--- /dev/null
+++ b/arch/mips/alchemy/devboards/db1x00/platform.c
@@ -0,0 +1,101 @@
+/*
+ * Db1x00 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+#if defined(CONFIG_SOC_AU1000)
+	MAC_RES(AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1100)
+	MAC_RES(AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1550)
+	MAC_RES(AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT),
+#elif defined(CONFIG_SOC_AU1500)
+	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
+#endif
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+#if defined(CONFIG_SOC_AU1000)
+	MAC_RES(AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT),
+#elif defined(CONFIG_SOC_AU1550)
+	MAC_RES(AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT),
+#elif defined(CONFIG_SOC_AU1500)
+	MAC_RES(AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT),
+#endif
+};
+
+/* Except for Bosporus, default is to search for a PHY on MAC0 */
+static struct au1000_eth_platform_data au1xxx_eth0_platform_data = {
+	.phy1_search_mac0 = 1,
+};
+
+static struct platform_device db1x00_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+.	.dev.platform_data = &au1xxx_eth0_platform_data,
+};
+
+#ifndef CONFIG_SOC_AU1100
+static struct platform_device db1x00_eth1 = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+#endif
+
+static struct platform_device *db1x00_devs[] = {
+	&db1x00_eth0,
+};
+
+static int __init db1x00_register_devices(void)
+{
+#ifdef CONFIG_MIPS_BOSPORUS
+	/*
+	 * Micrel/Kendin 5 port switch attached to MAC0,
+	 * MAC0 is associated with PHY address 5 (== WAN port)
+	 * MAC1 is not associated with any PHY, since it's connected directly
+	 * to the switch.
+	 * no interrupts are used
+	 */
+	au1xxx_eth0_platform_data.phy1_search_mac0 = 0;
+	au1xxx_eth0_platform_data.phy_static_config = 1;
+	au1xxx_eth0_platform_data.phy_addr = 5;
+	au1xxx_eth0_platform_data.phy_busid = 0;
+#endif
+
+#ifndef CONFIG_SOC_AU1100
+	int ni;
+
+	ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
+	if (!(ni + 1))
+		platform_device_register(&db1x00_eth1);
+#endif
+
+	return platform_add_devices(db1x00_devs, ARRAY_SIZE(db1x00_devs));
+}
+arch_initcall(db1x00_register_devices);
diff --git a/arch/mips/alchemy/devboards/pb1000/Makefile b/arch/mips/alchemy/devboards/pb1000/Makefile
index 97c6615..38d11bb 100644
--- a/arch/mips/alchemy/devboards/pb1000/Makefile
+++ b/arch/mips/alchemy/devboards/pb1000/Makefile
@@ -5,4 +5,4 @@
 # Makefile for the Alchemy Semiconductor Pb1000 board.
 #
 
-obj-y := board_setup.o
+obj-y := board_setup.o platform.o
diff --git a/arch/mips/alchemy/devboards/pb1000/platform.c b/arch/mips/alchemy/devboards/pb1000/platform.c
new file mode 100644
index 0000000..621e71c
--- /dev/null
+++ b/arch/mips/alchemy/devboards/pb1000/platform.c
@@ -0,0 +1,58 @@
+/*
+ * PB1000 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT),
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+	MAC_RES(AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT),
+};
+
+static struct platform_device pb1000_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+
+static struct platform_device pb1000_eth1 = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+
+static struct platform_device *pb1000_devs[] = {
+	&pb1000_eth0,
+	&pb1000_eth1,
+};
+
+static int __init pb1000_register_devices(void)
+{
+	return platform_add_devices(pb1000_devs, ARRAY_SIZE(pb1000_devs));
+}
+arch_initcall(pb1000_register_devices);
diff --git a/arch/mips/alchemy/devboards/pb1100/Makefile b/arch/mips/alchemy/devboards/pb1100/Makefile
index c586dd7..7e3756c 100644
--- a/arch/mips/alchemy/devboards/pb1100/Makefile
+++ b/arch/mips/alchemy/devboards/pb1100/Makefile
@@ -5,4 +5,4 @@
 # Makefile for the Alchemy Semiconductor Pb1100 board.
 #
 
-obj-y := board_setup.o
+obj-y := board_setup.o platform.o
diff --git a/arch/mips/alchemy/devboards/pb1100/platform.c b/arch/mips/alchemy/devboards/pb1100/platform.c
new file mode 100644
index 0000000..9ff939c
--- /dev/null
+++ b/arch/mips/alchemy/devboards/pb1100/platform.c
@@ -0,0 +1,47 @@
+/*
+ * PB1100 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT),
+};
+
+static struct platform_device pb1100_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+};
+
+static struct platform_device *pb1100_devs[] = {
+	&pb1100_eth0,
+};
+
+static int __init pb1100_register_devices(void)
+{
+	return platform_add_devices(pb1100_devs, ARRAY_SIZE(pb1100_devs));
+}
+
+arch_initcall(pb1100_register_devices);
diff --git a/arch/mips/alchemy/devboards/pb1500/Makefile b/arch/mips/alchemy/devboards/pb1500/Makefile
index 173b419..e83b151 100644
--- a/arch/mips/alchemy/devboards/pb1500/Makefile
+++ b/arch/mips/alchemy/devboards/pb1500/Makefile
@@ -5,4 +5,4 @@
 # Makefile for the Alchemy Semiconductor Pb1500 board.
 #
 
-obj-y := board_setup.o
+obj-y := board_setup.o platform.o
diff --git a/arch/mips/alchemy/devboards/pb1500/platform.c b/arch/mips/alchemy/devboards/pb1500/platform.c
new file mode 100644
index 0000000..98dbe8f
--- /dev/null
+++ b/arch/mips/alchemy/devboards/pb1500/platform.c
@@ -0,0 +1,59 @@
+/*
+ * PB1500 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+	MAC_RES(AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT),
+};
+
+static struct platform_device pb1500_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+};
+
+static struct platform_device pb1500_eth1 = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+
+static struct platform_device *pb1500_devs[] = {
+	&pb1500_eth0,
+	&pb1500_eth1,
+};
+
+static int __init pb1500_register_devices(void)
+{
+	return platform_add_devices(pb1500_devs, ARRAY_SIZE(pb1500_devs));
+}
+
+arch_initcall(pb1500_register_devices);
diff --git a/arch/mips/alchemy/devboards/pb1550/Makefile b/arch/mips/alchemy/devboards/pb1550/Makefile
index cff95bc..9661b6e 100644
--- a/arch/mips/alchemy/devboards/pb1550/Makefile
+++ b/arch/mips/alchemy/devboards/pb1550/Makefile
@@ -5,4 +5,4 @@
 # Makefile for the Alchemy Semiconductor Pb1550 board.
 #
 
-obj-y := board_setup.o
+obj-y := board_setup.o platform.o
diff --git a/arch/mips/alchemy/devboards/pb1550/platform.c b/arch/mips/alchemy/devboards/pb1550/platform.c
new file mode 100644
index 0000000..c46f4ef
--- /dev/null
+++ b/arch/mips/alchemy/devboards/pb1550/platform.c
@@ -0,0 +1,59 @@
+/*
+ * PB1550 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT),
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+	MAC_RES(AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT),
+};
+
+static struct platform_device pb1550_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+};
+
+static struct platform_device pb1550_eth1 = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+
+static struct platform_device *pb1550_devs[] = {
+	&pb1550_eth0,
+	&pb1550_eth1,
+};
+
+static int __init pb1550_register_devices(void)
+{
+	return platform_add_devices(pb1550_devs, ARRAY_SIZE(pb1550_devs));
+}
+
+arch_initcall(pb1550_register_devices);
diff --git a/arch/mips/alchemy/mtx-1/platform.c b/arch/mips/alchemy/mtx-1/platform.c
index e30e42a..30a7a56 100644
--- a/arch/mips/alchemy/mtx-1/platform.c
+++ b/arch/mips/alchemy/mtx-1/platform.c
@@ -28,6 +28,9 @@
 #include <linux/mtd/physmap.h>
 #include <mtd/mtd-abi.h>
 
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
 static struct gpio_keys_button mtx1_gpio_button[] = {
 	{
 		.gpio = 207,
@@ -133,11 +136,23 @@ static struct platform_device mtx1_mtd = {
 	.resource	= &mtx1_mtd_resource,
 };
 
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
+};
+
+static struct platform_device mtx1_eth = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+};
+
 static struct __initdata platform_device * mtx1_devs[] = {
 	&mtx1_gpio_leds,
 	&mtx1_wdt,
 	&mtx1_button,
 	&mtx1_mtd,
+	&mtx1_eth,
 };
 
 static int __init mtx1_register_devices(void)
diff --git a/arch/mips/alchemy/xxs1500/Makefile b/arch/mips/alchemy/xxs1500/Makefile
index db3c526..375748f 100644
--- a/arch/mips/alchemy/xxs1500/Makefile
+++ b/arch/mips/alchemy/xxs1500/Makefile
@@ -6,3 +6,4 @@
 #
 
 lib-y := init.o board_setup.o irqmap.o
+obj-y := platform.o
diff --git a/arch/mips/alchemy/xxs1500/platform.c b/arch/mips/alchemy/xxs1500/platform.c
new file mode 100644
index 0000000..ef7f7b7
--- /dev/null
+++ b/arch/mips/alchemy/xxs1500/platform.c
@@ -0,0 +1,59 @@
+/*
+ * XXS1500 platform devices registration
+ *
+ * Copyright (C) 2009, Florian Fainelli <florian@openwrt.org>
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
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+#include <asm/mach-au1x00/au1xxx.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
+
+static struct resource au1xxx_eth0_resources[] = {
+	MAC_RES(AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT),
+};
+
+static struct resource au1xxx_eth1_resources[] = {
+	MAC_RES(AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT),
+};
+
+static struct platform_device xxs1500_eth0 = {
+	.name		= "au1000-eth",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	= au1xxx_eth0_resources,
+};
+
+static struct platform_device xxs1500_eth1 = {
+	.name		= "au1000-eth",
+	.id		= 1,
+	.num_resources	= ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	= au1xxx_eth1_resources,
+};
+
+static struct platform_device *xxs1500_devs[] = {
+	&xxs1500_eth0,
+	&xxs1500_eth1,
+};
+
+static int __init xxs1500_register_devices(void)
+{
+	return platform_add_devices(xxs1500_devs, ARRAY_SIZE(xxs1500_devs));
+}
+
+arch_initcall(xxs1500_register_devices);
diff --git a/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
new file mode 100644
index 0000000..6d1543e
--- /dev/null
+++ b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
@@ -0,0 +1,33 @@
+#ifndef __AU1X00_ETH_DATA_H
+#define __AU1X00_ETH_DATA_H
+
+/* Macro to help defining the Ethernet MAC resources */
+#define MAC_RES(_base, _enable, _irq)			\
+	{						\
+		.start	= CPHYSADDR(_base),		\
+		.end	= CPHYSADDR(_base + 0xffff),	\
+		.flags	= IORESOURCE_MEM,		\
+	},						\
+	{						\
+		.start	= CPHYSADDR(_enable),		\
+		.end	= CPHYSADDR(_enable + 0x4),	\
+		.flags	= IORESOURCE_MEM,		\
+	},						\
+	{						\
+		.start	= _irq,				\
+		.end	= _irq,				\
+		.flags	= IORESOURCE_IRQ		\
+	}
+
+/* Platform specific PHY configuration passed to the MAC driver */
+struct au1000_eth_platform_data {
+	int phy_static_config;
+	int phy_search_highest_addr;
+	int phy1_search_mac0;
+	int phy_addr;
+	int phy_busid;
+	int phy_irq;
+};
+
+#endif /* __AU1X00_ETH_DATA_H */
+
