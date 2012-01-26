From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V5 4/4] CS89x0 : add CS89x0 platform device to the iMX31ADS board
Date: Thu, 26 Jan 2012 21:47:27 +0100
Message-ID: <1327610847-26995-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	s.hauer@pengutronix.de, davem@davemloft.net, cavokz@gmail.com,
	linux@arm.linux.org.uk, fabio.estevam@freescale.com,
	festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58290 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab2AZUrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:47:36 -0500
Received: by eaal13 with SMTP id l13so4686eaa.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:47:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CS89x0 networking support to the iMX31ADS board by using the
platform driver support in the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 arch/arm/configs/mx3_defconfig                 |    2 +
 arch/arm/mach-imx/mach-mx31ads.c               |   35 +++++++++++++++++++++--
 arch/arm/plat-mxc/include/mach/board-mx31ads.h |   33 ----------------------
 drivers/net/ethernet/cirrus/cs89x0.c           |    7 -----
 4 files changed, 34 insertions(+), 43 deletions(-)
 delete mode 100644 arch/arm/plat-mxc/include/mach/board-mx31ads.h

diff --git a/arch/arm/configs/mx3_defconfig b/arch/arm/configs/mx3_defconfig
index cb0717f..5d2bc6e 100644
--- a/arch/arm/configs/mx3_defconfig
+++ b/arch/arm/configs/mx3_defconfig
@@ -66,6 +66,8 @@ CONFIG_NETDEVICES=y
 CONFIG_SMSC_PHY=y
 CONFIG_NET_ETHERNET=y
 CONFIG_SMSC911X=y
+CONFIG_CS89x0=y
+CONFIG_CS89x0_PLATFORM=y
 CONFIG_DNET=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
diff --git a/arch/arm/mach-imx/mach-mx31ads.c b/arch/arm/mach-imx/mach-mx31ads.c
index 9cc1a49..ac1a14c 100644
--- a/arch/arm/mach-imx/mach-mx31ads.c
+++ b/arch/arm/mach-imx/mach-mx31ads.c
@@ -28,7 +28,6 @@
 #include <asm/memory.h>
 #include <asm/mach/map.h>
 #include <mach/common.h>
-#include <mach/board-mx31ads.h>
 #include <mach/iomux-mx3.h>
 
 #ifdef CONFIG_MACH_MX31ADS_WM1133_EV1
@@ -39,6 +38,9 @@
 
 #include "devices-imx31.h"
 
+/* Base address of PBC controller */
+#define PBC_BASE_ADDRESS	MX31_CS4_BASE_ADDR_VIRT
+
 /* PBC Board interrupt status register */
 #define PBC_INTSTATUS           0x000016
 
@@ -62,6 +64,7 @@
 #define PBC_INTMASK_CLEAR_REG	(PBC_INTMASK_CLEAR + PBC_BASE_ADDRESS)
 #define EXPIO_PARENT_INT	IOMUX_TO_IRQ(MX31_PIN_GPIO1_4)
 
+#define MXC_EXP_IO_BASE		MXC_BOARD_IRQ_START
 #define MXC_IRQ_TO_EXPIO(irq)	((irq) - MXC_EXP_IO_BASE)
 
 #define EXPIO_INT_XUART_INTA	(MXC_EXP_IO_BASE + 10)
@@ -69,6 +72,10 @@
 
 #define MXC_MAX_EXP_IO_LINES	16
 
+/* CS8900 */
+#define EXPIO_INT_ENET_INT	(MXC_EXP_IO_BASE + 8)
+#define CS4_CS8900_MMIO_START	0x20000
+
 /*
  * The serial port definition structure.
  */
@@ -101,11 +108,29 @@ static struct platform_device serial_device = {
 	},
 };
 
+static const struct resource mx31ads_cs8900_resources[] __initconst = {
+	DEFINE_RES_MEM(MX31_CS4_BASE_ADDR + CS4_CS8900_MMIO_START, SZ_64K),
+	DEFINE_RES_IRQ(EXPIO_INT_ENET_INT),
+};
+
+static const struct platform_device_info mx31ads_cs8900_devinfo __initconst = {
+	.name = "cs89x0",
+	.id = 0,
+	.res = mx31ads_cs8900_resources,
+	.num_res = ARRAY_SIZE(mx31ads_cs8900_resources),
+};
+
 static int __init mxc_init_extuart(void)
 {
 	return platform_device_register(&serial_device);
 }
 
+static void __init mxc_init_ext_ethernet(void)
+{
+	platform_device_register_full(
+		(struct platform_device_info *)&mx31ads_cs8900_devinfo);
+}
+
 static const struct imxuart_platform_data uart_pdata __initconst = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
@@ -492,12 +517,15 @@ static void __init mxc_init_audio(void)
 	mxc_iomux_setup_multiple_pins(ssi_pins, ARRAY_SIZE(ssi_pins), "ssi");
 }
 
-/* static mappings */
+/*
+ * Static mappings, starting from the CS4 start address up to the start address
+ * of the CS8900.
+ */
 static struct map_desc mx31ads_io_desc[] __initdata = {
 	{
 		.virtual	= MX31_CS4_BASE_ADDR_VIRT,
 		.pfn		= __phys_to_pfn(MX31_CS4_BASE_ADDR),
-		.length		= MX31_CS4_SIZE / 2,
+		.length		= CS4_CS8900_MMIO_START,
 		.type		= MT_DEVICE
 	},
 };
@@ -522,6 +550,7 @@ static void __init mx31ads_init(void)
 	mxc_init_imx_uart();
 	mxc_init_i2c();
 	mxc_init_audio();
+	mxc_init_ext_ethernet();
 }
 
 static void __init mx31ads_timer_init(void)
diff --git a/arch/arm/plat-mxc/include/mach/board-mx31ads.h b/arch/arm/plat-mxc/include/mach/board-mx31ads.h
deleted file mode 100644
index 94b60dd..0000000
--- a/arch/arm/plat-mxc/include/mach/board-mx31ads.h
+++ /dev/null
@@ -1,33 +0,0 @@
-/*
- * Copyright 2005-2007 Freescale Semiconductor, Inc. All Rights Reserved.
- */
-
-/*
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef __ASM_ARCH_MXC_BOARD_MX31ADS_H__
-#define __ASM_ARCH_MXC_BOARD_MX31ADS_H__
-
-#include <mach/hardware.h>
-
-/*
- * These symbols are used by drivers/net/cs89x0.c.
- * This is ugly as hell, but we have to provide them until
- * someone fixed the driver.
- */
-
-/* Base address of PBC controller */
-#define PBC_BASE_ADDRESS        MX31_CS4_BASE_ADDR_VIRT
-/* Offsets for the PBC Controller register */
-
-/* Ethernet Controller IO base address */
-#define PBC_CS8900A_IOBASE      0x020000
-
-#define MXC_EXP_IO_BASE		(MXC_BOARD_IRQ_START)
-
-#define EXPIO_INT_ENET_INT	(MXC_EXP_IO_BASE + 8)
-
-#endif /* __ASM_ARCH_MXC_BOARD_MX31ADS_H__ */
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index f7449bd..7202ca9 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -182,13 +182,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #define CS89x0_NONISA_IRQ
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
-#elif defined(CONFIG_MACH_MX31ADS)
-#define CS89x0_NONISA_IRQ
-#include <mach/board-mx31ads.h>
-static unsigned int netcard_portlist[] __used __initdata = {
-	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
-};
-static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
 #else
 #ifndef CONFIG_CS89x0_PLATFORM
 static unsigned int netcard_portlist[] __used __initdata =
-- 
1.7.1
