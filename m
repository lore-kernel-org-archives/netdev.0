From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V2 3/4] CS89x0 : add CS89x0 platform device to the iMX31ADS board
Date: Wed, 11 Jan 2012 00:14:37 +0100
Message-ID: <1326237277-23664-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: jaccon.bastiaansen@gmail.com, s.hauer@pengutronix.de,
	kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50720 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757008Ab2AJXOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 18:14:46 -0500
Received: by eaad14 with SMTP id d14so35457eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 15:14:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CS89x0 networking support to the iMX31ADS board by using the
platform driver support in the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 arch/arm/configs/mx3_defconfig                 |    2 +
 arch/arm/mach-imx/mach-mx31ads.c               |   34 ++++++++++++++++++++++-
 arch/arm/plat-mxc/include/mach/board-mx31ads.h |   33 -----------------------
 drivers/net/Space.c                            |    3 +-
 drivers/net/ethernet/cirrus/cs89x0.c           |   12 +-------
 5 files changed, 37 insertions(+), 47 deletions(-)
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
index 9cc1a49..4d42634 100644
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
 
@@ -62,10 +64,12 @@
 #define PBC_INTMASK_CLEAR_REG	(PBC_INTMASK_CLEAR + PBC_BASE_ADDRESS)
 #define EXPIO_PARENT_INT	IOMUX_TO_IRQ(MX31_PIN_GPIO1_4)
 
+#define MXC_EXP_IO_BASE		MXC_BOARD_IRQ_START
 #define MXC_IRQ_TO_EXPIO(irq)	((irq) - MXC_EXP_IO_BASE)
 
 #define EXPIO_INT_XUART_INTA	(MXC_EXP_IO_BASE + 10)
 #define EXPIO_INT_XUART_INTB	(MXC_EXP_IO_BASE + 11)
+#define EXPIO_INT_ENET_INT	(MXC_EXP_IO_BASE + 8)
 
 #define MXC_MAX_EXP_IO_LINES	16
 
@@ -101,11 +105,36 @@ static struct platform_device serial_device = {
 	},
 };
 
+static struct resource mx31ads_cs8900_resources[] = {
+	{
+		.start	= MX31_CS4_BASE_ADDR + 0x20000 + 0x300,
+		.end	= MX31_CS4_BASE_ADDR + 0x20000 + 0x1000 - 1,
+		.flags	= IORESOURCE_MEM
+	},
+	{
+		.start	= EXPIO_INT_ENET_INT,
+		.end	= EXPIO_INT_ENET_INT,
+		.flags	= IORESOURCE_IRQ
+	}
+};
+
+static struct platform_device mx31ads_cs8900_device = {
+	.name		= "cs89x0",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(mx31ads_cs8900_resources),
+	.resource	= mx31ads_cs8900_resources
+};
+
 static int __init mxc_init_extuart(void)
 {
 	return platform_device_register(&serial_device);
 }
 
+static void __init mxc_init_ext_ethernet(void)
+{
+	platform_device_register(&mx31ads_cs8900_device);
+}
+
 static const struct imxuart_platform_data uart_pdata __initconst = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
@@ -497,7 +526,7 @@ static struct map_desc mx31ads_io_desc[] __initdata = {
 	{
 		.virtual	= MX31_CS4_BASE_ADDR_VIRT,
 		.pfn		= __phys_to_pfn(MX31_CS4_BASE_ADDR),
-		.length		= MX31_CS4_SIZE / 2,
+		.length		= 0x20000,
 		.type		= MT_DEVICE
 	},
 };
@@ -522,6 +551,7 @@ static void __init mx31ads_init(void)
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
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 00fe11b..04c4561 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -191,8 +191,7 @@ static struct devprobe2 isa_probes[] __initdata = {
 #endif
 #ifdef CONFIG_CS89x0
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) || \
-	defined(CONFIG_MACH_MX31ADS)
+	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
  	{cs89x0_probe, 0},
 #endif
 #endif
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index d6c6398..9149974 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -185,12 +185,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #include <mach/qq2440.h>
 static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
 static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
-#elif defined(CONFIG_MACH_MX31ADS)
-#include <mach/board-mx31ads.h>
-static unsigned int netcard_portlist[] __used __initdata = {
-	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
-};
-static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
 #endif
 #else
 static unsigned int netcard_portlist[] __used __initdata =
@@ -303,8 +297,7 @@ __setup("cs89x0_media=", media_fn);
 
 
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) ||  \
-	defined(CONFIG_MACH_MX31ADS)
+	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
    If dev->base_addr == 1, always return failure.
@@ -1180,8 +1173,7 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 
 	if (chip_type == CS8900) {
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) ||  \
-	defined(CONFIG_MACH_MX31ADS)
+	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
 		/* Search the mapping table for the corresponding IRQ pin. */
 		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
 			if (cs8900_irq_map[i] == irq)
-- 
1.7.1
