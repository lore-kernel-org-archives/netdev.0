From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V2] Add platform driver support to the CS890x driver
Date: Sun, 9 Oct 2011 22:51:23 +0200
Message-ID: <CAGzjT4eKJCf36_n-W-XpiFUymUZj=tVzXYp2DNJFXb-Wjz6RVA@mail.gmail.com>
References: <20110913074626.GM28624@pengutronix.de>
	<1317148076-14931-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de,
	=?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49515 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab1JIUv0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 16:51:26 -0400
Received: by wwf22 with SMTP id 22so8266708wwf.1
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 13:51:24 -0700 (PDT)
In-Reply-To: <1317148076-14931-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch hasn't been sent to the netdev mailing list before, sorry fo=
r that.

Jaccon

---------- Forwarded message ----------
=46rom: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: 2011/9/27
Subject: [PATCH V2] Add platform driver support to the CS890x driver
To: s.hauer@pengutronix.de, u.kleine-koenig@pengutronix.de,
kernel@pengutronix.de
Cc: linux-arm-kernel@lists.infradead.org, Jaccon Bastiaansen
<jaccon.bastiaansen@gmail.com>


The CS89x0 ethernet controller is used on a number of evaluation
boards, such as the MX31ADS. The current driver has memory address and
IRQ settings for each board on which this controller is used. Driver
updates are therefore required to support other boards that also use
the CS89x0. To avoid these driver updates, a better mechanism
(platform driver support) is added to communicate the board dependent
settings to the driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
=A0arch/arm/mach-imx/mach-mx31ads.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 4=
0 ++++++-
=A0arch/arm/mach-ixp2000/ixdp2x01.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 2=
4 +++-
=A0arch/arm/mach-ixp2000/pci.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A03 +-
=A0arch/arm/mach-ixp23xx/ixdp2351.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 2=
1 +++
=A0arch/arm/mach-ixp23xx/pci.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A03 +-
=A0arch/arm/plat-mxc/include/mach/board-mx31ads.h | =A0 33 -----
=A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 16 ++-
=A0drivers/net/Space.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A02 +-
=A0drivers/net/cs89x0.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0175 +++++++++++++++---------
=A09 files changed, 210 insertions(+), 107 deletions(-)
=A0delete mode 100644 arch/arm/plat-mxc/include/mach/board-mx31ads.h

diff --git a/arch/arm/mach-imx/mach-mx31ads.c b/arch/arm/mach-imx/mach-=
mx31ads.c
index f4dee02..007bd38 100644
--- a/arch/arm/mach-imx/mach-mx31ads.c
+++ b/arch/arm/mach-imx/mach-mx31ads.c
@@ -28,7 +28,6 @@
=A0#include <asm/memory.h>
=A0#include <asm/mach/map.h>
=A0#include <mach/common.h>
-#include <mach/board-mx31ads.h>
=A0#include <mach/iomux-mx3.h>

=A0#ifdef CONFIG_MACH_MX31ADS_WM1133_EV1
@@ -62,6 +61,7 @@
=A0#define PBC_INTMASK_CLEAR_REG =A0(PBC_INTMASK_CLEAR + PBC_BASE_ADDRE=
SS)
=A0#define EXPIO_PARENT_INT =A0 =A0 =A0 IOMUX_TO_IRQ(MX31_PIN_GPIO1_4)

+#define MXC_EXP_IO_BASE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(MXC_BOARD_IRQ_=
START)
=A0#define MXC_IRQ_TO_EXPIO(irq) =A0((irq) - MXC_EXP_IO_BASE)

=A0#define EXPIO_INT_XUART_INTA =A0 (MXC_EXP_IO_BASE + 10)
@@ -69,6 +69,18 @@

=A0#define MXC_MAX_EXP_IO_LINES =A0 16

+
+/* Base address of PBC controller */
+#define PBC_BASE_ADDRESS =A0 =A0 =A0 =A0MX31_CS4_BASE_ADDR_VIRT
+
+/* Offsets for the PBC Controller register */
+
+/* Ethernet Controller IO addresses */
+#define PBC_CS8900A_IOBASE =A0 =A0 =A00x020000
+#define CS8900A_START =A0 =A0 =A0 =A0 =A0(PBC_BASE_ADDRESS + PBC_CS890=
0A_IOBASE + 0x300)
+
+#define EXPIO_INT_ENET_INT =A0 =A0 (MXC_EXP_IO_BASE + 8)
+
=A0/*
=A0* The serial port definition structure.
=A0*/
@@ -101,11 +113,36 @@ static struct platform_device serial_device =3D {
=A0 =A0 =A0 =A0},
=A0};

+static struct resource mx31ads_cs8900_resources[] =3D {
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D (u32)CS8900A_START,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D (u32)CS8900A_START + 0x10=
00 - 1,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_MEM,
+ =A0 =A0 =A0 },
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D EXPIO_INT_ENET_INT,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D EXPIO_INT_ENET_INT,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_IRQ,
+ =A0 =A0 =A0 },
+};
+
+static struct platform_device mx31ads_cs8900_device =3D {
+ =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "cs89x0",
+ =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D 0,
+ =A0 =A0 =A0 .num_resources =A0=3D ARRAY_SIZE(mx31ads_cs8900_resources=
),
+ =A0 =A0 =A0 .resource =A0 =A0 =A0 =3D mx31ads_cs8900_resources,
+};
+
=A0static int __init mxc_init_extuart(void)
=A0{
=A0 =A0 =A0 =A0return platform_device_register(&serial_device);
=A0}

+static void __init mxc_init_ext_ethernet(void)
+{
+ =A0 =A0 =A0 platform_device_register(&mx31ads_cs8900_device);
+}
+
=A0static const struct imxuart_platform_data uart_pdata __initconst =3D=
 {
=A0 =A0 =A0 =A0.flags =3D IMXUART_HAVE_RTSCTS,
=A0};
@@ -520,6 +557,7 @@ static void __init mx31ads_init(void)
=A0 =A0 =A0 =A0mxc_init_imx_uart();
=A0 =A0 =A0 =A0mxc_init_i2c();
=A0 =A0 =A0 =A0mxc_init_audio();
+ =A0 =A0 =A0 mxc_init_ext_ethernet();
=A0}

=A0static void __init mx31ads_timer_init(void)
diff --git a/arch/arm/mach-ixp2000/ixdp2x01.c b/arch/arm/mach-ixp2000/i=
xdp2x01.c
index 84835b2..1ec4a74 100644
--- a/arch/arm/mach-ixp2000/ixdp2x01.c
+++ b/arch/arm/mach-ixp2000/ixdp2x01.c
@@ -394,9 +394,31 @@ static struct platform_device ixdp2x01_i2c_control=
ler =3D {
=A0 =A0 =A0 =A0.num_resources =A0=3D 0
=A0};

+static struct resource ixdp2x01_cs8900_resources[] =3D {
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D (u32)IXDP2X01_CS8900_VIRT_B=
ASE,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D (u32)IXDP2X01_CS8900_VIRT=
_BASE + 0x1000 - 1,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_MEM,
+ =A0 =A0 =A0 },
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D IRQ_IXDP2X01_CS8900,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D IRQ_IXDP2X01_CS8900,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_IRQ,
+ =A0 =A0 =A0 },
+};
+
+static struct platform_device ixdp2x01_cs8900 =3D {
+ =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "cs89x0",
+ =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D 0,
+ =A0 =A0 =A0 .num_resources =A0=3D ARRAY_SIZE(ixdp2x01_cs8900_resource=
s),
+ =A0 =A0 =A0 .resource =A0 =A0 =A0 =3D ixdp2x01_cs8900_resources,
+};
+
+
=A0static struct platform_device *ixdp2x01_devices[] __initdata =3D {
=A0 =A0 =A0 =A0&ixdp2x01_flash,
- =A0 =A0 =A0 &ixdp2x01_i2c_controller
+ =A0 =A0 =A0 &ixdp2x01_i2c_controller,
+ =A0 =A0 =A0 &ixdp2x01_cs8900
=A0};

=A0static void __init ixdp2x01_init_machine(void)
diff --git a/arch/arm/mach-ixp2000/pci.c b/arch/arm/mach-ixp2000/pci.c
index f797c5f..54bf1b8 100644
--- a/arch/arm/mach-ixp2000/pci.c
+++ b/arch/arm/mach-ixp2000/pci.c
@@ -130,7 +130,8 @@ static struct pci_ops ixp2000_pci_ops =3D {
=A0 =A0 =A0 =A0.write =A0=3D ixp2000_pci_write_config
=A0};

-struct pci_bus *ixp2000_pci_scan_bus(int nr, struct pci_sys_data *sysd=
ata)
+struct pci_bus __devinit
+*ixp2000_pci_scan_bus(int nr, struct pci_sys_data *sysdata)
=A0{
=A0 =A0 =A0 =A0return pci_scan_bus(sysdata->busnr, &ixp2000_pci_ops, sy=
sdata);
=A0}
diff --git a/arch/arm/mach-ixp23xx/ixdp2351.c b/arch/arm/mach-ixp23xx/i=
xdp2351.c
index 8dcba17..d559110 100644
--- a/arch/arm/mach-ixp23xx/ixdp2351.c
+++ b/arch/arm/mach-ixp23xx/ixdp2351.c
@@ -311,6 +311,26 @@ static struct platform_device ixdp2351_flash =3D {
=A0 =A0 =A0 =A0.resource =A0 =A0 =A0 =3D &ixdp2351_flash_resource,
=A0};

+static struct resource ixdp2351_cs8900_resources[] =3D {
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D (u32)IXDP2351_VIRT_CS8900_B=
ASE,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D (u32)IXDP2351_VIRT_CS8900=
_BASE + 0x1000 - 1,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_MEM,
+ =A0 =A0 =A0 },
+ =A0 =A0 =A0 {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .start =A0=3D IRQ_IXDP2351_CS8900,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .end =A0 =A0=3D IRQ_IXDP2351_CS8900,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =A0=3D IORESOURCE_IRQ,
+ =A0 =A0 =A0 },
+};
+
+static struct platform_device ixdp2351_cs8900 =3D {
+ =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "cs89x0",
+ =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D 0,
+ =A0 =A0 =A0 .num_resources =A0=3D ARRAY_SIZE(ixdp2351_cs8900_resource=
s),
+ =A0 =A0 =A0 .resource =A0 =A0 =A0 =3D ixdp2351_cs8900_resources,
+};
+
=A0static void __init ixdp2351_init(void)
=A0{
=A0 =A0 =A0 =A0platform_device_register(&ixdp2351_flash);
@@ -323,6 +343,7 @@ static void __init ixdp2351_init(void)
=A0 =A0 =A0 =A0IXP23XX_EXP_CS0[2] |=3D IXP23XX_FLASH_WRITABLE;
=A0 =A0 =A0 =A0IXP23XX_EXP_CS0[3] |=3D IXP23XX_FLASH_WRITABLE;

+ =A0 =A0 =A0 platform_device_register(&ixdp2351_cs8900);
=A0 =A0 =A0 =A0ixp23xx_sys_init();
=A0}

diff --git a/arch/arm/mach-ixp23xx/pci.c b/arch/arm/mach-ixp23xx/pci.c
index 563819a..f82bb91 100644
--- a/arch/arm/mach-ixp23xx/pci.c
+++ b/arch/arm/mach-ixp23xx/pci.c
@@ -141,7 +141,8 @@ struct pci_ops ixp23xx_pci_ops =3D {
=A0 =A0 =A0 =A0.write =A0=3D ixp23xx_pci_write_config,
=A0};

-struct pci_bus *ixp23xx_pci_scan_bus(int nr, struct pci_sys_data *sysd=
ata)
+struct pci_bus __devinit
+*ixp23xx_pci_scan_bus(int nr, struct pci_sys_data *sysdata)
=A0{
=A0 =A0 =A0 =A0return pci_scan_bus(sysdata->busnr, &ixp23xx_pci_ops, sy=
sdata);
=A0}
diff --git a/arch/arm/plat-mxc/include/mach/board-mx31ads.h
b/arch/arm/plat-mxc/include/mach/board-mx31ads.h
deleted file mode 100644
index 94b60dd..0000000
--- a/arch/arm/plat-mxc/include/mach/board-mx31ads.h
+++ /dev/null
@@ -1,33 +0,0 @@
-/*
- * Copyright 2005-2007 Freescale Semiconductor, Inc. All Rights Reserv=
ed.
- */
-
-/*
- * This program is free software; you can redistribute it and/or modif=
y
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
-#define PBC_BASE_ADDRESS =A0 =A0 =A0 =A0MX31_CS4_BASE_ADDR_VIRT
-/* Offsets for the PBC Controller register */
-
-/* Ethernet Controller IO base address */
-#define PBC_CS8900A_IOBASE =A0 =A0 =A00x020000
-
-#define MXC_EXP_IO_BASE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(MXC_BOARD_IRQ_=
START)
-
-#define EXPIO_INT_ENET_INT =A0 =A0 (MXC_EXP_IO_BASE + 8)
-
-#endif /* __ASM_ARCH_MXC_BOARD_MX31ADS_H__ */
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 93359fa..2873f86 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1497,8 +1497,7 @@ config FORCEDETH

=A0config CS89x0
=A0 =A0 =A0 =A0tristate "CS89x0 support"
- =A0 =A0 =A0 depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 =
\
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_=
QQ2440)
+ =A0 =A0 =A0 depends on NET_ETHERNET
=A0 =A0 =A0 =A0---help---
=A0 =A0 =A0 =A0 =A0Support for CS89x0 chipset based Ethernet cards. If =
you have a
=A0 =A0 =A0 =A0 =A0network (Ethernet) card of this type, say Y and read=
 the
@@ -1509,10 +1508,15 @@ config CS89x0
=A0 =A0 =A0 =A0 =A0To compile this driver as a module, choose M here. T=
he module
=A0 =A0 =A0 =A0 =A0will be called cs89x0.

-config CS89x0_NONISA_IRQ
- =A0 =A0 =A0 def_bool y
- =A0 =A0 =A0 depends on CS89x0 !=3D n
- =A0 =A0 =A0 depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS=
 || MACH_QQ2440
+config CS89x0_PLATFORM
+ =A0 =A0 =A0 bool "CS89x0 platform driver support"
+ =A0 =A0 =A0 depends on CS89x0
+ =A0 =A0 =A0 help
+ =A0 =A0 =A0 =A0 Say Y to compile the cs890x0 driver as a platform dri=
ver. This
+ =A0 =A0 =A0 =A0 makes this driver suitable for use on certain evaluat=
ion boards
+ =A0 =A0 =A0 =A0 such as the IMX21ADS.
+
+ =A0 =A0 =A0 =A0 If you are unsure, say N.

=A0config TC35815
=A0 =A0 =A0 =A0tristate "TOSHIBA TC35815 Ethernet support"
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 068c356..3c53ab1 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -189,7 +189,7 @@ static struct devprobe2 isa_probes[] __initdata =3D=
 {
=A0#ifdef CONFIG_SEEQ8005
=A0 =A0 =A0 =A0{seeq8005_probe, 0},
=A0#endif
-#ifdef CONFIG_CS89x0
+#if defined(CONFIG_CS89x0) && !defined(CONFIG_CS89x0_PLATFORM)
=A0 =A0 =A0 =A0{cs89x0_probe, 0},
=A0#endif
=A0#ifdef CONFIG_AT1700
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 537a4b2..b7fb3bc 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -12,6 +12,14 @@
=A0 =A0 =A0 =A0 The author may be reached at nelson@crynwr.com, Crynwr
=A0 =A0 =A0 =A0 Software, 521 Pleasant Valley Rd., Potsdam, NY 13676

+Sources
+
+ =A0 =A0 =A0 Crynwr packet driver epktisa.
+
+ =A0 =A0 =A0 Crystal Semiconductor data sheets.
+
+
+
=A0 Changelog:

=A0 Mike Cruse =A0 =A0 =A0 =A0: mcruse@cti-ltd.com
@@ -98,39 +106,14 @@
=A0 Domenico Andreoli : cavokz@gmail.com
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : QQ2440 platform support

+ =A0Jaccon Bastiaansen: jaccon.bastiaansen@gmail.com
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : added platform driver support
=A0*/

-/* Always include 'config.h' first in case the user wants to turn on
- =A0 or override something. */
-#include <linux/module.h>
-
-/*
- * Set this to zero to disable DMA code
- *
- * Note that even if DMA is turned off we still support the 'dma' and
=A0'use_dma'
- * module options so we don't break any startup scripts.
- */
-#ifndef CONFIG_ISA_DMA_API
-#define ALLOW_DMA =A0 =A0 =A00
-#else
-#define ALLOW_DMA =A0 =A0 =A01
-#endif
-
-/*
- * Set this to zero to remove all the debug statements via
- * dead code elimination
- */
-#define DEBUGGING =A0 =A0 =A01
-
-/*
- =A0Sources:
-
- =A0 =A0 =A0 Crynwr packet driver epktisa.
-
- =A0 =A0 =A0 Crystal Semiconductor data sheets.
-
-*/
+#define pr_fmt(fmt) =A0 =A0KBUILD_MODNAME ": " fmt

+#include <linux/module.h>
+#include <linux/printk.h>
=A0#include <linux/errno.h>
=A0#include <linux/netdevice.h>
=A0#include <linux/etherdevice.h>
@@ -147,21 +130,36 @@
=A0#include <linux/bitops.h>
=A0#include <linux/delay.h>
=A0#include <linux/gfp.h>
-
=A0#include <asm/system.h>
=A0#include <asm/io.h>
=A0#include <asm/irq.h>
-#if ALLOW_DMA
+#include <linux/platform_device.h>
+#include "cs89x0.h"
+
+/*
+ * Set this to zero to disable DMA code
+ *
+ * Note that even if DMA is turned off we still support the 'dma' and
=A0'use_dma'
+ * module options so we don't break any startup scripts.
+ */
+#ifndef CONFIG_ISA_DMA_API
+#define ALLOW_DMA =A0 =A0 =A00
+#else
+#define ALLOW_DMA =A0 =A0 =A01
=A0#include <asm/dma.h>
=A0#endif

-#include "cs89x0.h"
-
-static char version[] __initdata =3D
-"cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Mort=
on\n";
+/*
+ * Set this to zero to remove all the debug statements via
+ * dead code elimination
+ */
+#define DEBUGGING =A0 =A0 =A01

=A0#define DRV_NAME "cs89x0"

+static char version[] =3D
+"cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Mort=
on\n";
+
=A0/* First, a few definitions that the brave might change.
=A0 =A0A zero-terminated list of I/O addresses to be probed. Some speci=
al flags..
=A0 =A0 =A0 Addr & 1 =3D Read back the address port, look for signature=
 and reset
@@ -173,22 +171,9 @@ static char version[] __initdata =3D
=A0/* The cs8900 has 4 IRQ pins, software selectable. cs8900_irq_map ma=
ps
=A0 =A0them to system IRQ numbers. This mapping is card specific and is=
 set to
=A0 =A0the configuration of the Cirrus Eval board for this chip. */
-#if defined(CONFIG_MACH_IXDP2351)
-static unsigned int netcard_portlist[] __used __initdata =3D
{IXDP2351_VIRT_CS8900_BASE, 0};
-static unsigned int cs8900_irq_map[] =3D {IRQ_IXDP2351_CS8900, 0, 0, 0=
};
-#elif defined(CONFIG_ARCH_IXDP2X01)
-static unsigned int netcard_portlist[] __used __initdata =3D
{IXDP2X01_CS8900_VIRT_BASE, 0};
-static unsigned int cs8900_irq_map[] =3D {IRQ_IXDP2X01_CS8900, 0, 0, 0=
};
-#elif defined(CONFIG_MACH_QQ2440)
-#include <mach/qq2440.h>
-static unsigned int netcard_portlist[] __used __initdata =3D {
QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
-static unsigned int cs8900_irq_map[] =3D { QQ2440_CS8900_IRQ, 0, 0, 0 =
};
-#elif defined(CONFIG_MACH_MX31ADS)
-#include <mach/board-mx31ads.h>
-static unsigned int netcard_portlist[] __used __initdata =3D {
- =A0 =A0 =A0 PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
-};
-static unsigned cs8900_irq_map[] =3D {EXPIO_INT_ENET_INT, 0, 0, 0};
+#if defined(CONFIG_CS89x0_PLATFORM)
+static unsigned int netcard_portlist[] __used __initdata =3D {0, 0};
+static unsigned int cs8900_irq_map[] =3D {0, 0, 0, 0};
=A0#else
=A0static unsigned int netcard_portlist[] __used __initdata =3D
=A0 =A0{ 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280,
0x2a0, 0x2c0, 0x2e0, 0};
@@ -424,7 +409,7 @@ writereg(struct net_device *dev, u16 regno, u16 val=
ue)
=A0 =A0 =A0 =A0writeword(dev->base_addr, DATA_PORT, value);
=A0}

-static int __init
+static int
=A0wait_eeprom_ready(struct net_device *dev)
=A0{
=A0 =A0 =A0 =A0int timeout =3D jiffies;
@@ -437,7 +422,7 @@ wait_eeprom_ready(struct net_device *dev)
=A0 =A0 =A0 =A0return 0;
=A0}

-static int __init
+static int
=A0get_eeprom_data(struct net_device *dev, int off, int len, int *buffe=
r)
=A0{
=A0 =A0 =A0 =A0int i;
@@ -455,7 +440,7 @@ get_eeprom_data(struct net_device *dev, int off,
int len, int *buffer)
=A0 =A0 =A0 =A0 return 0;
=A0}

-static int =A0__init
+static int
=A0get_eeprom_cksum(int off, int len, int *buffer)
=A0{
=A0 =A0 =A0 =A0int i, cksum;
@@ -503,7 +488,7 @@ static const struct net_device_ops net_ops =3D {
=A0 =A0Return 0 on success.
=A0*/

-static int __init
+static int
=A0cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
=A0{
=A0 =A0 =A0 =A0struct net_local *lp =3D netdev_priv(dev);
@@ -529,9 +514,6 @@ cs89x0_probe1(struct net_device *dev, int ioaddr,
int modular)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->force =3D g_cs89x0_media__force;
=A0#endif

-#if defined(CONFIG_MACH_QQ2440)
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->force |=3D FORCE_RJ45 | FORCE_FULL;
-#endif
=A0 =A0 =A0 =A0 }

=A0 =A0 =A0 =A0/* Grab the region so we can find another board if autoI=
RQ fails. */
@@ -737,7 +719,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr,
int modular)
=A0 =A0 =A0 =A0} else {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i =3D lp->isa_config & INT_NO_MASK;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (lp->chip_type =3D=3D CS8900) {
-#ifdef CONFIG_CS89x0_NONISA_IRQ
+#ifdef CONFIG_CS89x0_PLATFORM
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i =3D cs8900_irq_map[0];
=A0#else
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Translate the IRQ usi=
ng the IRQ mapping table. */
@@ -1228,7 +1210,7 @@ net_open(struct net_device *dev)
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0else
=A0 =A0 =A0 =A0{
-#ifndef CONFIG_CS89x0_NONISA_IRQ
+#ifndef CONFIG_CS89x0_PLATFORM
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (((1 << dev->irq) & lp->irq_map) =3D=3D=
 0) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "%s: IRQ=
 %d is not in our map
of allowable IRQs, which is %x\n",
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e, dev->irq, lp->irq_map);
@@ -1746,7 +1728,7 @@ static int set_mac_address(struct net_device
*dev, void *p)
=A0 =A0 =A0 =A0return 0;
=A0}

-#ifdef MODULE
+#if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)

=A0static struct net_device *dev_cs89x0;

@@ -1900,7 +1882,74 @@ cleanup_module(void)
=A0 =A0 =A0 =A0release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT)=
;
=A0 =A0 =A0 =A0free_netdev(dev_cs89x0);
=A0}
-#endif /* MODULE */
+#endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
+
+#ifdef CONFIG_CS89x0_PLATFORM
+static int cs89x0_platform_probe(struct platform_device *pdev)
+{
+ =A0 =A0 =A0 struct net_device *dev =3D alloc_etherdev(sizeof(struct n=
et_local));
+ =A0 =A0 =A0 struct resource *mem_res;
+ =A0 =A0 =A0 struct resource *irq_res;
+ =A0 =A0 =A0 int err;
+
+ =A0 =A0 =A0 if (!dev)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
+
+ =A0 =A0 =A0 mem_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0=
);
+ =A0 =A0 =A0 irq_res =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0=
);
+ =A0 =A0 =A0 if (mem_res =3D=3D NULL || irq_res =3D=3D NULL) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("memory and/or interrupt resou=
rce missing.\n");
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOENT;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 cs8900_irq_map[0] =3D irq_res->start;
+ =A0 =A0 =A0 err =3D cs89x0_probe1(dev, mem_res->start, 0);
+ =A0 =A0 =A0 if (err) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("no cs8900 or cs8920 detected.=
\n");
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 platform_set_drvdata(pdev, dev);
+ =A0 =A0 =A0 return 0;
+out:
+ =A0 =A0 =A0 free_netdev(dev);
+ =A0 =A0 =A0 return err;
+}
+
+static int cs89x0_platform_remove(struct platform_device *pdev)
+{
+ =A0 =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
+
+ =A0 =A0 =A0 unregister_netdev(dev);
+ =A0 =A0 =A0 free_netdev(dev);
+ =A0 =A0 =A0 return 0;
+}
+
+static struct platform_driver cs89x0_platform_driver =3D {
+ =A0 =A0 =A0 .driver =3D {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =3D DRV_NAME,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =A0=3D THIS_MODULE,
+ =A0 =A0 =A0 },
+ =A0 =A0 =A0 .probe =A0=3D cs89x0_platform_probe,
+ =A0 =A0 =A0 .remove =3D cs89x0_platform_remove,
+};
+
+static int __init cs89x0_init(void)
+{
+ =A0 =A0 =A0 return platform_driver_register(&cs89x0_platform_driver);
+}
+
+module_init(cs89x0_init);
+
+static void __exit cs89x0_cleanup(void)
+{
+ =A0 =A0 =A0 platform_driver_unregister(&cs89x0_platform_driver);
+}
+
+module_exit(cs89x0_cleanup);
+
+#endif

=A0/*
=A0* Local variables:
--
1.7.1
