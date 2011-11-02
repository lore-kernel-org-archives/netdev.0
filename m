From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH RESEND 01/18] MIPS: Alchemy: remove PB1000 support
Date: Wed,  2 Nov 2011 12:53:44 +0100
Message-ID: <1320234824-28604-1-git-send-email-manuel.lauss@googlemail.com>
References: <1320174224-27305-2-git-send-email-manuel.lauss@googlemail.com>
Cc: Manuel Lauss <manuel.lauss@googlemail.com>, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org
To: Linux-MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52169 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306Ab1KBLx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 07:53:28 -0400
Received: by faao14 with SMTP id o14so319602faa.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 04:53:26 -0700 (PDT)
In-Reply-To: <1320174224-27305-2-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noone seems to have test hardware or care anymore.  Drop PB1000 support
and along with it the old Alchemy PCMCIA socket driver.

Cc: netdev@vger.kernel.org
Cc: linux-pcmcia@lists.infradead.org
Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
---
Resend with CC's added as requested by Ralf.
Cc'ing netdev for IrDA driver parts and pcmcia for the socket driver
removal.

 arch/mips/alchemy/Kconfig                        |    9 -
 arch/mips/alchemy/Platform                       |    7 -
 arch/mips/alchemy/common/irq.c                   |   11 -
 arch/mips/alchemy/devboards/Makefile             |    1 -
 arch/mips/alchemy/devboards/pb1000/Makefile      |    8 -
 arch/mips/alchemy/devboards/pb1000/board_setup.c |  209 ---------
 arch/mips/alchemy/devboards/prom.c               |    2 +-
 arch/mips/include/asm/mach-pb1x00/pb1000.h       |   87 ----
 drivers/net/irda/au1k_ir.c                       |    5 +-
 drivers/pcmcia/Kconfig                           |    4 -
 drivers/pcmcia/Makefile                          |    4 -
 drivers/pcmcia/au1000_generic.c                  |  545 ----------------------
 drivers/pcmcia/au1000_generic.h                  |  135 ------
 drivers/pcmcia/au1000_pb1x00.c                   |  294 ------------
 14 files changed, 2 insertions(+), 1319 deletions(-)
 delete mode 100644 arch/mips/alchemy/devboards/pb1000/Makefile
 delete mode 100644 arch/mips/alchemy/devboards/pb1000/board_setup.c
 delete mode 100644 arch/mips/include/asm/mach-pb1x00/pb1000.h
 delete mode 100644 drivers/pcmcia/au1000_generic.c
 delete mode 100644 drivers/pcmcia/au1000_generic.h
 delete mode 100644 drivers/pcmcia/au1000_pb1x00.c

diff --git a/arch/mips/alchemy/Kconfig b/arch/mips/alchemy/Kconfig
index 2a68be6..5a48387 100644
--- a/arch/mips/alchemy/Kconfig
+++ b/arch/mips/alchemy/Kconfig
@@ -78,15 +78,6 @@ config MIPS_MIRAGE
 	select SYS_SUPPORTS_LITTLE_ENDIAN
 	select SYS_HAS_EARLY_PRINTK
 
-config MIPS_PB1000
-	bool "Alchemy PB1000 board"
-	select ALCHEMY_GPIOINT_AU1000
-	select DMA_NONCOHERENT
-	select HW_HAS_PCI
-	select SWAP_IO_SPACE
-	select SYS_SUPPORTS_LITTLE_ENDIAN
-	select SYS_HAS_EARLY_PRINTK
-
 config MIPS_PB1100
 	bool "Alchemy PB1100 board"
 	select ALCHEMY_GPIOINT_AU1000
diff --git a/arch/mips/alchemy/Platform b/arch/mips/alchemy/Platform
index 96e9e41..4e07967 100644
--- a/arch/mips/alchemy/Platform
+++ b/arch/mips/alchemy/Platform
@@ -5,13 +5,6 @@ platform-$(CONFIG_MIPS_ALCHEMY)	+= alchemy/common/
 
 
 #
-# AMD Alchemy Pb1000 eval board
-#
-platform-$(CONFIG_MIPS_PB1000)	+= alchemy/devboards/
-cflags-$(CONFIG_MIPS_PB1000)	+= -I$(srctree)/arch/mips/include/asm/mach-pb1x00
-load-$(CONFIG_MIPS_PB1000)	+= 0xffffffff80100000
-
-#
 # AMD Alchemy Pb1100 eval board
 #
 platform-$(CONFIG_MIPS_PB1100)	+= alchemy/devboards/
diff --git a/arch/mips/alchemy/common/irq.c b/arch/mips/alchemy/common/irq.c
index 8b60ba0..2a94a64 100644
--- a/arch/mips/alchemy/common/irq.c
+++ b/arch/mips/alchemy/common/irq.c
@@ -35,9 +35,6 @@
 #include <asm/irq_cpu.h>
 #include <asm/mipsregs.h>
 #include <asm/mach-au1x00/au1000.h>
-#ifdef CONFIG_MIPS_PB1000
-#include <asm/mach-pb1x00/pb1000.h>
-#endif
 
 /* Interrupt Controller register offsets */
 #define IC_CFG0RD	0x40
@@ -265,14 +262,6 @@ static void au1x_ic1_unmask(struct irq_data *d)
 
 	__raw_writel(1 << bit, base + IC_MASKSET);
 	__raw_writel(1 << bit, base + IC_WAKESET);
-
-/* very hacky. does the pb1000 cpld auto-disable this int?
- * nowhere in the current kernel sources is it disabled.	--mlau
- */
-#if defined(CONFIG_MIPS_PB1000)
-	if (d->irq == AU1000_GPIO15_INT)
-		__raw_writel(0x4000, (void __iomem *)PB1000_MDR); /* enable int */
-#endif
 	wmb();
 }
 
diff --git a/arch/mips/alchemy/devboards/Makefile b/arch/mips/alchemy/devboards/Makefile
index 826449c..bea80d7 100644
--- a/arch/mips/alchemy/devboards/Makefile
+++ b/arch/mips/alchemy/devboards/Makefile
@@ -4,7 +4,6 @@
 
 obj-y += prom.o bcsr.o platform.o
 obj-$(CONFIG_PM)		+= pm.o
-obj-$(CONFIG_MIPS_PB1000)	+= pb1000/
 obj-$(CONFIG_MIPS_PB1100)	+= pb1100/
 obj-$(CONFIG_MIPS_PB1200)	+= pb1200/
 obj-$(CONFIG_MIPS_PB1500)	+= pb1500/
diff --git a/arch/mips/alchemy/devboards/pb1000/Makefile b/arch/mips/alchemy/devboards/pb1000/Makefile
deleted file mode 100644
index 97c6615..0000000
--- a/arch/mips/alchemy/devboards/pb1000/Makefile
+++ /dev/null
@@ -1,8 +0,0 @@
-#
-#  Copyright 2000, 2008 MontaVista Software Inc.
-#  Author: MontaVista Software, Inc. <source@mvista.com>
-#
-# Makefile for the Alchemy Semiconductor Pb1000 board.
-#
-
-obj-y := board_setup.o
diff --git a/arch/mips/alchemy/devboards/pb1000/board_setup.c b/arch/mips/alchemy/devboards/pb1000/board_setup.c
deleted file mode 100644
index e64fdcb..0000000
--- a/arch/mips/alchemy/devboards/pb1000/board_setup.c
+++ /dev/null
@@ -1,209 +0,0 @@
-/*
- * Copyright 2000, 2008 MontaVista Software Inc.
- * Author: MontaVista Software, Inc. <source@mvista.com>
- *
- *  This program is free software; you can redistribute  it and/or modify it
- *  under  the terms of  the GNU General  Public License as published by the
- *  Free Software Foundation;  either version 2 of the  License, or (at your
- *  option) any later version.
- *
- *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
- *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
- *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
- *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
- *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
- *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
- *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- *  You should have received a copy of the  GNU General Public License along
- *  with this program; if not, write  to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#include <linux/delay.h>
-#include <linux/gpio.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-#include <linux/pm.h>
-#include <asm/mach-au1x00/au1000.h>
-#include <asm/mach-pb1x00/pb1000.h>
-#include <asm/reboot.h>
-#include <prom.h>
-
-#include "../platform.h"
-
-const char *get_system_type(void)
-{
-	return "Alchemy Pb1000";
-}
-
-static void board_reset(char *c)
-{
-	asm volatile ("jr %0" : : "r" (0xbfc00000));
-}
-
-static void board_power_off(void)
-{
-	while (1)
-		asm volatile (
-		"	.set	mips32					\n"
-		"	wait						\n"
-		"	.set	mips0					\n");
-}
-
-void __init board_setup(void)
-{
-	u32 pin_func, static_cfg0;
-	u32 sys_freqctrl, sys_clksrc;
-	u32 prid = read_c0_prid();
-
-	sys_freqctrl = 0;
-	sys_clksrc = 0;
-
-	/* Set AUX clock to 12 MHz * 8 = 96 MHz */
-	au_writel(8, SYS_AUXPLL);
-	alchemy_gpio1_input_enable();
-	udelay(100);
-
-#if defined(CONFIG_USB_OHCI_HCD) || defined(CONFIG_USB_OHCI_HCD_MODULE)
-	/* Zero and disable FREQ2 */
-	sys_freqctrl = au_readl(SYS_FREQCTRL0);
-	sys_freqctrl &= ~0xFFF00000;
-	au_writel(sys_freqctrl, SYS_FREQCTRL0);
-
-	/* Zero and disable USBH/USBD clocks */
-	sys_clksrc = au_readl(SYS_CLKSRC);
-	sys_clksrc &= ~(SYS_CS_CUD | SYS_CS_DUD | SYS_CS_MUD_MASK |
-		        SYS_CS_CUH | SYS_CS_DUH | SYS_CS_MUH_MASK);
-	au_writel(sys_clksrc, SYS_CLKSRC);
-
-	sys_freqctrl = au_readl(SYS_FREQCTRL0);
-	sys_freqctrl &= ~0xFFF00000;
-
-	sys_clksrc = au_readl(SYS_CLKSRC);
-	sys_clksrc &= ~(SYS_CS_CUD | SYS_CS_DUD | SYS_CS_MUD_MASK |
-		        SYS_CS_CUH | SYS_CS_DUH | SYS_CS_MUH_MASK);
-
-	switch (prid & 0x000000FF) {
-	case 0x00: /* DA */
-	case 0x01: /* HA */
-	case 0x02: /* HB */
-		/* CPU core freq to 48 MHz to slow it way down... */
-		au_writel(4, SYS_CPUPLL);
-
-		/*
-		 * Setup 48 MHz FREQ2 from CPUPLL for USB Host
-		 * FRDIV2 = 3 -> div by 8 of 384 MHz -> 48 MHz
-		 */
-		sys_freqctrl |= (3 << SYS_FC_FRDIV2_BIT) | SYS_FC_FE2;
-		au_writel(sys_freqctrl, SYS_FREQCTRL0);
-
-		/* CPU core freq to 384 MHz */
-		au_writel(0x20, SYS_CPUPLL);
-
-		printk(KERN_INFO "Au1000: 48 MHz OHCI workaround enabled\n");
-		break;
-
-	default: /* HC and newer */
-		/* FREQ2 = aux / 2 = 48 MHz */
-		sys_freqctrl |= (0 << SYS_FC_FRDIV2_BIT) |
-				 SYS_FC_FE2 | SYS_FC_FS2;
-		au_writel(sys_freqctrl, SYS_FREQCTRL0);
-		break;
-	}
-
-	/*
-	 * Route 48 MHz FREQ2 into USB Host and/or Device
-	 */
-	sys_clksrc |= SYS_CS_MUX_FQ2 << SYS_CS_MUH_BIT;
-	au_writel(sys_clksrc, SYS_CLKSRC);
-
-	/* Configure pins GPIO[14:9] as GPIO */
-	pin_func = au_readl(SYS_PINFUNC) & ~(SYS_PF_UR3 | SYS_PF_USB);
-
-	/* 2nd USB port is USB host */
-	pin_func |= SYS_PF_USB;
-
-	au_writel(pin_func, SYS_PINFUNC);
-
-	alchemy_gpio_direction_input(11);
-	alchemy_gpio_direction_input(13);
-	alchemy_gpio_direction_output(4, 0);
-	alchemy_gpio_direction_output(5, 0);
-#endif /* defined(CONFIG_USB_OHCI_HCD) || defined(CONFIG_USB_OHCI_HCD_MODULE) */
-
-	/* Make GPIO 15 an input (for interrupt line) */
-	pin_func = au_readl(SYS_PINFUNC) & ~SYS_PF_IRF;
-	/* We don't need I2S, so make it available for GPIO[31:29] */
-	pin_func |= SYS_PF_I2S;
-	au_writel(pin_func, SYS_PINFUNC);
-
-	alchemy_gpio_direction_input(15);
-
-	static_cfg0 = au_readl(MEM_STCFG0) & ~0xc00;
-	au_writel(static_cfg0, MEM_STCFG0);
-
-	/* configure RCE2* for LCD */
-	au_writel(0x00000004, MEM_STCFG2);
-
-	/* MEM_STTIME2 */
-	au_writel(0x09000000, MEM_STTIME2);
-
-	/* Set 32-bit base address decoding for RCE2* */
-	au_writel(0x10003ff0, MEM_STADDR2);
-
-	/*
-	 * PCI CPLD setup
-	 * Expand CE0 to cover PCI
-	 */
-	au_writel(0x11803e40, MEM_STADDR1);
-
-	/* Burst visibility on */
-	au_writel(au_readl(MEM_STCFG0) | 0x1000, MEM_STCFG0);
-
-	au_writel(0x83, MEM_STCFG1);	     /* ewait enabled, flash timing */
-	au_writel(0x33030a10, MEM_STTIME1);  /* slower timing for FPGA */
-
-	/* Setup the static bus controller */
-	au_writel(0x00000002, MEM_STCFG3);  /* type = PCMCIA */
-	au_writel(0x280E3D07, MEM_STTIME3); /* 250ns cycle time */
-	au_writel(0x10000000, MEM_STADDR3); /* any PCMCIA select */
-
-	/*
-	 * Enable Au1000 BCLK switching - note: sed1356 must not use
-	 * its BCLK (Au1000 LCLK) for any timings
-	 */
-	switch (prid & 0x000000FF) {
-	case 0x00: /* DA */
-	case 0x01: /* HA */
-	case 0x02: /* HB */
-		break;
-	default:  /* HC and newer */
-		/*
-		 * Enable sys bus clock divider when IDLE state or no bus
-		 * activity.
-		 */
-		au_writel(au_readl(SYS_POWERCTRL) | (0x3 << 5), SYS_POWERCTRL);
-		break;
-	}
-
-	pm_power_off = board_power_off;
-	_machine_halt = board_power_off;
-	_machine_restart = board_reset;
-}
-
-static int __init pb1000_init_irq(void)
-{
-	irq_set_irq_type(AU1000_GPIO15_INT, IRQF_TRIGGER_LOW);
-	return 0;
-}
-arch_initcall(pb1000_init_irq);
-
-static int __init pb1000_device_init(void)
-{
-	return db1x_register_norflash(8 * 1024 * 1024, 4, 0);
-}
-device_initcall(pb1000_device_init);
diff --git a/arch/mips/alchemy/devboards/prom.c b/arch/mips/alchemy/devboards/prom.c
index e5306b5..56d7ea5 100644
--- a/arch/mips/alchemy/devboards/prom.c
+++ b/arch/mips/alchemy/devboards/prom.c
@@ -33,7 +33,7 @@
 #include <asm/mach-au1x00/au1000.h>
 #include <prom.h>
 
-#if defined(CONFIG_MIPS_PB1000) || defined(CONFIG_MIPS_DB1000) || \
+#if defined(CONFIG_MIPS_DB1000) || \
     defined(CONFIG_MIPS_PB1100) || defined(CONFIG_MIPS_DB1100) || \
     defined(CONFIG_MIPS_PB1500) || defined(CONFIG_MIPS_DB1500) || \
     defined(CONFIG_MIPS_BOSPORUS) || defined(CONFIG_MIPS_MIRAGE)
diff --git a/arch/mips/include/asm/mach-pb1x00/pb1000.h b/arch/mips/include/asm/mach-pb1x00/pb1000.h
deleted file mode 100644
index 6505925..0000000
--- a/arch/mips/include/asm/mach-pb1x00/pb1000.h
+++ /dev/null
@@ -1,87 +0,0 @@
-/*
- * Alchemy Semi Pb1000 Reference Board
- *
- * Copyright 2001, 2008 MontaVista Software Inc.
- * Author: MontaVista Software, Inc. <source@mvista.com>
- *
- * ########################################################################
- *
- *  This program is free software; you can distribute it and/or modify it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WITHOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- *
- * ########################################################################
- *
- *
- */
-#ifndef __ASM_PB1000_H
-#define __ASM_PB1000_H
-
-/* PCMCIA PB1000 specific defines */
-#define PCMCIA_MAX_SOCK  1
-#define PCMCIA_NUM_SOCKS (PCMCIA_MAX_SOCK + 1)
-
-#define PB1000_PCR		0xBE000000
-#  define PCR_SLOT_0_VPP0	(1 << 0)
-#  define PCR_SLOT_0_VPP1	(1 << 1)
-#  define PCR_SLOT_0_VCC0	(1 << 2)
-#  define PCR_SLOT_0_VCC1	(1 << 3)
-#  define PCR_SLOT_0_RST	(1 << 4)
-#  define PCR_SLOT_1_VPP0	(1 << 8)
-#  define PCR_SLOT_1_VPP1	(1 << 9)
-#  define PCR_SLOT_1_VCC0	(1 << 10)
-#  define PCR_SLOT_1_VCC1	(1 << 11)
-#  define PCR_SLOT_1_RST	(1 << 12)
-
-#define PB1000_MDR		0xBE000004
-#  define MDR_PI		(1 << 5)	/* PCMCIA int latch  */
-#  define MDR_EPI		(1 << 14)	/* enable PCMCIA int */
-#  define MDR_CPI		(1 << 15)	/* clear  PCMCIA int  */
-
-#define PB1000_ACR1		0xBE000008
-#  define ACR1_SLOT_0_CD1	(1 << 0)	/* card detect 1	*/
-#  define ACR1_SLOT_0_CD2	(1 << 1)	/* card detect 2	*/
-#  define ACR1_SLOT_0_READY	(1 << 2)	/* ready		*/
-#  define ACR1_SLOT_0_STATUS	(1 << 3)	/* status change	*/
-#  define ACR1_SLOT_0_VS1	(1 << 4)	/* voltage sense 1	*/
-#  define ACR1_SLOT_0_VS2	(1 << 5)	/* voltage sense 2	*/
-#  define ACR1_SLOT_0_INPACK	(1 << 6)	/* inpack pin status	*/
-#  define ACR1_SLOT_1_CD1	(1 << 8)	/* card detect 1	*/
-#  define ACR1_SLOT_1_CD2	(1 << 9)	/* card detect 2	*/
-#  define ACR1_SLOT_1_READY	(1 << 10)	/* ready		*/
-#  define ACR1_SLOT_1_STATUS	(1 << 11)	/* status change	*/
-#  define ACR1_SLOT_1_VS1	(1 << 12)	/* voltage sense 1	*/
-#  define ACR1_SLOT_1_VS2	(1 << 13)	/* voltage sense 2	*/
-#  define ACR1_SLOT_1_INPACK	(1 << 14)	/* inpack pin status	*/
-
-#define CPLD_AUX0		0xBE00000C
-#define CPLD_AUX1		0xBE000010
-#define CPLD_AUX2		0xBE000014
-
-/* Voltage levels */
-
-/* VPPEN1 - VPPEN0 */
-#define VPP_GND ((0 << 1) | (0 << 0))
-#define VPP_5V	((1 << 1) | (0 << 0))
-#define VPP_3V	((0 << 1) | (1 << 0))
-#define VPP_12V ((0 << 1) | (1 << 0))
-#define VPP_HIZ ((1 << 1) | (1 << 0))
-
-/* VCCEN1 - VCCEN0 */
-#define VCC_3V	((0 << 1) | (1 << 0))
-#define VCC_5V	((1 << 1) | (0 << 0))
-#define VCC_HIZ ((0 << 1) | (0 << 0))
-
-/* VPP/VCC */
-#define SET_VCC_VPP(VCC, VPP, SLOT) \
-	((((VCC) << 2) | ((VPP) << 0)) << ((SLOT) * 8))
-#endif /* __ASM_PB1000_H */
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index a3d696a..d1a77ef 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -32,10 +32,7 @@
 #include <asm/irq.h>
 #include <asm/io.h>
 #include <asm/au1000.h>
-#if defined(CONFIG_MIPS_PB1000) || defined(CONFIG_MIPS_PB1100)
-#include <asm/pb1000.h>
-#elif defined(CONFIG_MIPS_DB1000) || defined(CONFIG_MIPS_DB1100)
-#include <asm/db1x00.h>
+#if defined(CONFIG_MIPS_DB1000) || defined(CONFIG_MIPS_DB1100)
 #include <asm/mach-db1x00/bcsr.h>
 #else 
 #error au1k_ir: unsupported board
diff --git a/drivers/pcmcia/Kconfig b/drivers/pcmcia/Kconfig
index 6e318ce..c022b5c 100644
--- a/drivers/pcmcia/Kconfig
+++ b/drivers/pcmcia/Kconfig
@@ -155,10 +155,6 @@ config PCMCIA_M8XX
 
 	  This driver is also available as a module called m8xx_pcmcia.
 
-config PCMCIA_AU1X00
-	tristate "Au1x00 pcmcia support"
-	depends on MIPS_ALCHEMY && PCMCIA
-
 config PCMCIA_ALCHEMY_DEVBOARD
 	tristate "Alchemy Db/Pb1xxx PCMCIA socket services"
 	depends on MIPS_ALCHEMY && PCMCIA
diff --git a/drivers/pcmcia/Makefile b/drivers/pcmcia/Makefile
index 29935ea..ec543a4 100644
--- a/drivers/pcmcia/Makefile
+++ b/drivers/pcmcia/Makefile
@@ -29,7 +29,6 @@ obj-$(CONFIG_PCMCIA_SA1100)			+= sa11xx_base.o sa1100_cs.o
 obj-$(CONFIG_PCMCIA_SA1111)			+= sa11xx_base.o sa1111_cs.o
 obj-$(CONFIG_M32R_PCC)				+= m32r_pcc.o
 obj-$(CONFIG_M32R_CFC)				+= m32r_cfc.o
-obj-$(CONFIG_PCMCIA_AU1X00)			+= au1x00_ss.o
 obj-$(CONFIG_PCMCIA_BCM63XX)			+= bcm63xx_pcmcia.o
 obj-$(CONFIG_PCMCIA_VRC4171)			+= vrc4171_card.o
 obj-$(CONFIG_PCMCIA_VRC4173)			+= vrc4173_cardu.o
@@ -39,9 +38,6 @@ obj-$(CONFIG_AT91_CF)				+= at91_cf.o
 obj-$(CONFIG_ELECTRA_CF)			+= electra_cf.o
 obj-$(CONFIG_PCMCIA_ALCHEMY_DEVBOARD)		+= db1xxx_ss.o
 
-au1x00_ss-y					+= au1000_generic.o
-au1x00_ss-$(CONFIG_MIPS_PB1000)			+= au1000_pb1x00.o
-
 sa1111_cs-y					+= sa1111_generic.o
 sa1111_cs-$(CONFIG_ASSABET_NEPONSET)		+= sa1100_neponset.o
 sa1111_cs-$(CONFIG_SA1100_BADGE4)		+= sa1100_badge4.o
diff --git a/drivers/pcmcia/au1000_generic.c b/drivers/pcmcia/au1000_generic.c
deleted file mode 100644
index 95dd7c6..0000000
--- a/drivers/pcmcia/au1000_generic.c
+++ /dev/null
@@ -1,545 +0,0 @@
-/*
- *
- * Alchemy Semi Au1000 pcmcia driver
- *
- * Copyright 2001-2003 MontaVista Software Inc.
- * Author: MontaVista Software, Inc.
- *         	ppopov@embeddedalley.com or source@mvista.com
- *
- * Copyright 2004 Pete Popov, Embedded Alley Solutions, Inc.
- * Updated the driver to 2.6. Followed the sa11xx API and largely
- * copied many of the hardware independent functions.
- *
- * ########################################################################
- *
- *  This program is free software; you can distribute it and/or modify it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WITHOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- *
- * ########################################################################
- *
- * 
- */
-
-#include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/init.h>
-#include <linux/cpufreq.h>
-#include <linux/ioport.h>
-#include <linux/kernel.h>
-#include <linux/timer.h>
-#include <linux/mm.h>
-#include <linux/notifier.h>
-#include <linux/interrupt.h>
-#include <linux/spinlock.h>
-#include <linux/mutex.h>
-#include <linux/platform_device.h>
-#include <linux/slab.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/system.h>
-
-#include <asm/mach-au1x00/au1000.h>
-#include "au1000_generic.h"
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Pete Popov <ppopov@embeddedalley.com>");
-MODULE_DESCRIPTION("Linux PCMCIA Card Services: Au1x00 Socket Controller");
-
-#if 0
-#define debug(x,args...) printk(KERN_DEBUG "%s: " x, __func__ , ##args)
-#else
-#define debug(x,args...)
-#endif
-
-#define MAP_SIZE 0x100000
-extern struct au1000_pcmcia_socket au1000_pcmcia_socket[];
-#define PCMCIA_SOCKET(x)	(au1000_pcmcia_socket + (x))
-#define to_au1000_socket(x)	container_of(x, struct au1000_pcmcia_socket, socket)
-
-/* Some boards like to support CF cards as IDE root devices, so they
- * grab pcmcia sockets directly.
- */
-u32 *pcmcia_base_vaddrs[2];
-extern const unsigned long mips_io_port_base;
-
-static DEFINE_MUTEX(pcmcia_sockets_lock);
-
-static int (*au1x00_pcmcia_hw_init[])(struct device *dev) = {
-	au1x_board_init,
-};
-
-static int
-au1x00_pcmcia_skt_state(struct au1000_pcmcia_socket *skt)
-{
-	struct pcmcia_state state;
-	unsigned int stat;
-
-	memset(&state, 0, sizeof(struct pcmcia_state));
-
-	skt->ops->socket_state(skt, &state);
-
-	stat = state.detect  ? SS_DETECT : 0;
-	stat |= state.ready  ? SS_READY  : 0;
-	stat |= state.wrprot ? SS_WRPROT : 0;
-	stat |= state.vs_3v  ? SS_3VCARD : 0;
-	stat |= state.vs_Xv  ? SS_XVCARD : 0;
-	stat |= skt->cs_state.Vcc ? SS_POWERON : 0;
-
-	if (skt->cs_state.flags & SS_IOCARD)
-		stat |= state.bvd1 ? SS_STSCHG : 0;
-	else {
-		if (state.bvd1 == 0)
-			stat |= SS_BATDEAD;
-		else if (state.bvd2 == 0)
-			stat |= SS_BATWARN;
-	}
-	return stat;
-}
-
-/*
- * au100_pcmcia_config_skt
- *
- * Convert PCMCIA socket state to our socket configure structure.
- */
-static int
-au1x00_pcmcia_config_skt(struct au1000_pcmcia_socket *skt, socket_state_t *state)
-{
-	int ret;
-
-	ret = skt->ops->configure_socket(skt, state);
-	if (ret == 0) {
-		skt->cs_state = *state;
-	}
-
-	if (ret < 0)
-		debug("unable to configure socket %d\n", skt->nr);
-
-	return ret;
-}
-
-/* au1x00_pcmcia_sock_init()
- *
- * (Re-)Initialise the socket, turning on status interrupts
- * and PCMCIA bus.  This must wait for power to stabilise
- * so that the card status signals report correctly.
- *
- * Returns: 0
- */
-static int au1x00_pcmcia_sock_init(struct pcmcia_socket *sock)
-{
-	struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-
-	debug("initializing socket %u\n", skt->nr);
-
-	skt->ops->socket_init(skt);
-	return 0;
-}
-
-/*
- * au1x00_pcmcia_suspend()
- *
- * Remove power on the socket, disable IRQs from the card.
- * Turn off status interrupts, and disable the PCMCIA bus.
- *
- * Returns: 0
- */
-static int au1x00_pcmcia_suspend(struct pcmcia_socket *sock)
-{
-	struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-
-	debug("suspending socket %u\n", skt->nr);
-
-	skt->ops->socket_suspend(skt);
-
-	return 0;
-}
-
-static DEFINE_SPINLOCK(status_lock);
-
-/*
- * au1x00_check_status()
- */
-static void au1x00_check_status(struct au1000_pcmcia_socket *skt)
-{
-	unsigned int events;
-
-	debug("entering PCMCIA monitoring thread\n");
-
-	do {
-		unsigned int status;
-		unsigned long flags;
-
-		status = au1x00_pcmcia_skt_state(skt);
-
-		spin_lock_irqsave(&status_lock, flags);
-		events = (status ^ skt->status) & skt->cs_state.csc_mask;
-		skt->status = status;
-		spin_unlock_irqrestore(&status_lock, flags);
-
-		debug("events: %s%s%s%s%s%s\n",
-			events == 0         ? "<NONE>"   : "",
-			events & SS_DETECT  ? "DETECT "  : "",
-			events & SS_READY   ? "READY "   : "",
-			events & SS_BATDEAD ? "BATDEAD " : "",
-			events & SS_BATWARN ? "BATWARN " : "",
-			events & SS_STSCHG  ? "STSCHG "  : "");
-
-		if (events)
-			pcmcia_parse_events(&skt->socket, events);
-	} while (events);
-}
-
-/* 
- * au1x00_pcmcia_poll_event()
- * Let's poll for events in addition to IRQs since IRQ only is unreliable...
- */
-static void au1x00_pcmcia_poll_event(unsigned long dummy)
-{
-	struct au1000_pcmcia_socket *skt = (struct au1000_pcmcia_socket *)dummy;
-	debug("polling for events\n");
-
-	mod_timer(&skt->poll_timer, jiffies + AU1000_PCMCIA_POLL_PERIOD);
-
-	au1x00_check_status(skt);
-}
-
-/* au1x00_pcmcia_get_status()
- *
- * From the sa11xx_core.c:
- * Implements the get_status() operation for the in-kernel PCMCIA
- * service (formerly SS_GetStatus in Card Services). Essentially just
- * fills in bits in `status' according to internal driver state or
- * the value of the voltage detect chipselect register.
- *
- * As a debugging note, during card startup, the PCMCIA core issues
- * three set_socket() commands in a row the first with RESET deasserted,
- * the second with RESET asserted, and the last with RESET deasserted
- * again. Following the third set_socket(), a get_status() command will
- * be issued. The kernel is looking for the SS_READY flag (see
- * setup_socket(), reset_socket(), and unreset_socket() in cs.c).
- *
- * Returns: 0
- */
-static int
-au1x00_pcmcia_get_status(struct pcmcia_socket *sock, unsigned int *status)
-{
-	struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-
-	skt->status = au1x00_pcmcia_skt_state(skt);
-	*status = skt->status;
-
-	return 0;
-}
-
-/* au1x00_pcmcia_set_socket()
- * Implements the set_socket() operation for the in-kernel PCMCIA
- * service (formerly SS_SetSocket in Card Services). We more or
- * less punt all of this work and let the kernel handle the details
- * of power configuration, reset, &c. We also record the value of
- * `state' in order to regurgitate it to the PCMCIA core later.
- *
- * Returns: 0
- */
-static int
-au1x00_pcmcia_set_socket(struct pcmcia_socket *sock, socket_state_t *state)
-{
-  struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-
-  debug("for sock %u\n", skt->nr);
-
-  debug("\tmask:  %s%s%s%s%s%s\n\tflags: %s%s%s%s%s%s\n",
-	(state->csc_mask==0)?"<NONE>":"",
-	(state->csc_mask&SS_DETECT)?"DETECT ":"",
-	(state->csc_mask&SS_READY)?"READY ":"",
-	(state->csc_mask&SS_BATDEAD)?"BATDEAD ":"",
-	(state->csc_mask&SS_BATWARN)?"BATWARN ":"",
-	(state->csc_mask&SS_STSCHG)?"STSCHG ":"",
-	(state->flags==0)?"<NONE>":"",
-	(state->flags&SS_PWR_AUTO)?"PWR_AUTO ":"",
-	(state->flags&SS_IOCARD)?"IOCARD ":"",
-	(state->flags&SS_RESET)?"RESET ":"",
-	(state->flags&SS_SPKR_ENA)?"SPKR_ENA ":"",
-	(state->flags&SS_OUTPUT_ENA)?"OUTPUT_ENA ":"");
-  debug("\tVcc %d  Vpp %d  irq %d\n",
-	state->Vcc, state->Vpp, state->io_irq);
-
-  return au1x00_pcmcia_config_skt(skt, state);
-}
-
-int 
-au1x00_pcmcia_set_io_map(struct pcmcia_socket *sock, struct pccard_io_map *map)
-{
-	struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-	unsigned int speed;
-
-	if(map->map>=MAX_IO_WIN){
-		debug("map (%d) out of range\n", map->map);
-		return -1;
-	}
-
-	if(map->flags&MAP_ACTIVE){
-		speed=(map->speed>0)?map->speed:AU1000_PCMCIA_IO_SPEED;
-		skt->spd_io[map->map] = speed;
-	}
-
-	map->start=(unsigned int)(u32)skt->virt_io;
-	map->stop=map->start+MAP_SIZE;
-	return 0;
-
-}  /* au1x00_pcmcia_set_io_map() */
-
-
-static int 
-au1x00_pcmcia_set_mem_map(struct pcmcia_socket *sock, struct pccard_mem_map *map)
-{
-	struct au1000_pcmcia_socket *skt = to_au1000_socket(sock);
-	unsigned short speed = map->speed;
-
-	if(map->map>=MAX_WIN){
-		debug("map (%d) out of range\n", map->map);
-		return -1;
-	}
-
-	if (map->flags & MAP_ATTRIB) {
-		skt->spd_attr[map->map] = speed;
-		skt->spd_mem[map->map] = 0;
-	} else {
-		skt->spd_attr[map->map] = 0;
-		skt->spd_mem[map->map] = speed;
-	}
-
-	if (map->flags & MAP_ATTRIB) {
-		map->static_start = skt->phys_attr + map->card_start;
-	}
-	else {
-		map->static_start = skt->phys_mem + map->card_start;
-	}
-
-	debug("set_mem_map %d start %08lx card_start %08x\n",
-			map->map, map->static_start, map->card_start);
-	return 0;
-
-}  /* au1x00_pcmcia_set_mem_map() */
-
-static struct pccard_operations au1x00_pcmcia_operations = {
-	.init			= au1x00_pcmcia_sock_init,
-	.suspend		= au1x00_pcmcia_suspend,
-	.get_status		= au1x00_pcmcia_get_status,
-	.set_socket		= au1x00_pcmcia_set_socket,
-	.set_io_map		= au1x00_pcmcia_set_io_map,
-	.set_mem_map		= au1x00_pcmcia_set_mem_map,
-};
-
-static const char *skt_names[] = {
-	"PCMCIA socket 0",
-	"PCMCIA socket 1",
-};
-
-struct skt_dev_info {
-	int nskt;
-};
-
-int au1x00_pcmcia_socket_probe(struct device *dev, struct pcmcia_low_level *ops, int first, int nr)
-{
-	struct skt_dev_info *sinfo;
-	struct au1000_pcmcia_socket *skt;
-	int ret, i;
-
-	sinfo = kzalloc(sizeof(struct skt_dev_info), GFP_KERNEL);
-	if (!sinfo) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	sinfo->nskt = nr;
-
-	/*
-	 * Initialise the per-socket structure.
-	 */
-	for (i = 0; i < nr; i++) {
-		skt = PCMCIA_SOCKET(i);
-		memset(skt, 0, sizeof(*skt));
-
-		skt->socket.resource_ops = &pccard_static_ops;
-		skt->socket.ops = &au1x00_pcmcia_operations;
-		skt->socket.owner = ops->owner;
-		skt->socket.dev.parent = dev;
-
-		init_timer(&skt->poll_timer);
-		skt->poll_timer.function = au1x00_pcmcia_poll_event;
-		skt->poll_timer.data = (unsigned long)skt;
-		skt->poll_timer.expires = jiffies + AU1000_PCMCIA_POLL_PERIOD;
-
-		skt->nr		= first + i;
-		skt->irq	= 255;
-		skt->dev	= dev;
-		skt->ops	= ops;
-
-		skt->res_skt.name	= skt_names[skt->nr];
-		skt->res_io.name	= "io";
-		skt->res_io.flags	= IORESOURCE_MEM | IORESOURCE_BUSY;
-		skt->res_mem.name	= "memory";
-		skt->res_mem.flags	= IORESOURCE_MEM;
-		skt->res_attr.name	= "attribute";
-		skt->res_attr.flags	= IORESOURCE_MEM;
-
-		/*
-		 * PCMCIA client drivers use the inb/outb macros to access the
-		 * IO registers. Since mips_io_port_base is added to the
-		 * access address of the mips implementation of inb/outb,
-		 * we need to subtract it here because we want to access the
-		 * I/O or MEM address directly, without going through this
-		 * "mips_io_port_base" mechanism.
-		 */
-		if (i == 0) {
-			skt->virt_io = (void *)
-				(ioremap((phys_t)AU1X_SOCK0_IO, 0x1000) -
-				(u32)mips_io_port_base);
-			skt->phys_attr = AU1X_SOCK0_PHYS_ATTR;
-			skt->phys_mem = AU1X_SOCK0_PHYS_MEM;
-		}
-		else  {
-			skt->virt_io = (void *)
-				(ioremap((phys_t)AU1X_SOCK1_IO, 0x1000) -
-				(u32)mips_io_port_base);
-			skt->phys_attr = AU1X_SOCK1_PHYS_ATTR;
-			skt->phys_mem = AU1X_SOCK1_PHYS_MEM;
-		}
-		pcmcia_base_vaddrs[i] = (u32 *)skt->virt_io;
-		ret = ops->hw_init(skt);
-
-		skt->socket.features = SS_CAP_STATIC_MAP|SS_CAP_PCCARD;
-		skt->socket.irq_mask = 0;
-		skt->socket.map_size = MAP_SIZE;
-		skt->socket.pci_irq = skt->irq;
-		skt->socket.io_offset = (unsigned long)skt->virt_io;
-
-		skt->status = au1x00_pcmcia_skt_state(skt);
-
-		ret = pcmcia_register_socket(&skt->socket);
-		if (ret)
-			goto out_err;
-
-		WARN_ON(skt->socket.sock != i);
-
-		add_timer(&skt->poll_timer);
-	}
-
-	dev_set_drvdata(dev, sinfo);
-	return 0;
-
-
-out_err:
-	ops->hw_shutdown(skt);
-	while (i-- > 0) {
-		skt = PCMCIA_SOCKET(i);
-
-		del_timer_sync(&skt->poll_timer);
-		pcmcia_unregister_socket(&skt->socket);
-		if (i == 0) {
-			iounmap(skt->virt_io + (u32)mips_io_port_base);
-			skt->virt_io = NULL;
-		}
-#ifndef CONFIG_MIPS_XXS1500
-		else {
-			iounmap(skt->virt_io + (u32)mips_io_port_base);
-			skt->virt_io = NULL;
-		}
-#endif
-		ops->hw_shutdown(skt);
-
-	}
-	kfree(sinfo);
-out:
-	return ret;
-}
-
-int au1x00_drv_pcmcia_remove(struct platform_device *dev)
-{
-	struct skt_dev_info *sinfo = platform_get_drvdata(dev);
-	int i;
-
-	mutex_lock(&pcmcia_sockets_lock);
-	platform_set_drvdata(dev, NULL);
-
-	for (i = 0; i < sinfo->nskt; i++) {
-		struct au1000_pcmcia_socket *skt = PCMCIA_SOCKET(i);
-
-		del_timer_sync(&skt->poll_timer);
-		pcmcia_unregister_socket(&skt->socket);
-		skt->ops->hw_shutdown(skt);
-		au1x00_pcmcia_config_skt(skt, &dead_socket);
-		iounmap(skt->virt_io + (u32)mips_io_port_base);
-		skt->virt_io = NULL;
-	}
-
-	kfree(sinfo);
-	mutex_unlock(&pcmcia_sockets_lock);
-	return 0;
-}
-
-
-/*
- * PCMCIA "Driver" API
- */
-
-static int au1x00_drv_pcmcia_probe(struct platform_device *dev)
-{
-	int i, ret = -ENODEV;
-
-	mutex_lock(&pcmcia_sockets_lock);
-	for (i=0; i < ARRAY_SIZE(au1x00_pcmcia_hw_init); i++) {
-		ret = au1x00_pcmcia_hw_init[i](&dev->dev);
-		if (ret == 0)
-			break;
-	}
-	mutex_unlock(&pcmcia_sockets_lock);
-	return ret;
-}
-
-static struct platform_driver au1x00_pcmcia_driver = {
-	.driver = {
-		.name		= "au1x00-pcmcia",
-		.owner		= THIS_MODULE,
-	},
-	.probe		= au1x00_drv_pcmcia_probe,
-	.remove		= au1x00_drv_pcmcia_remove,
-};
-
-
-/* au1x00_pcmcia_init()
- *
- * This routine performs low-level PCMCIA initialization and then
- * registers this socket driver with Card Services.
- *
- * Returns: 0 on success, -ve error code on failure
- */
-static int __init au1x00_pcmcia_init(void)
-{
-	int error = 0;
-	error = platform_driver_register(&au1x00_pcmcia_driver);
-	return error;
-}
-
-/* au1x00_pcmcia_exit()
- * Invokes the low-level kernel service to free IRQs associated with this
- * socket controller and reset GPIO edge detection.
- */
-static void __exit au1x00_pcmcia_exit(void)
-{
-	platform_driver_unregister(&au1x00_pcmcia_driver);
-}
-
-module_init(au1x00_pcmcia_init);
-module_exit(au1x00_pcmcia_exit);
diff --git a/drivers/pcmcia/au1000_generic.h b/drivers/pcmcia/au1000_generic.h
deleted file mode 100644
index 5c36bda..0000000
--- a/drivers/pcmcia/au1000_generic.h
+++ /dev/null
@@ -1,135 +0,0 @@
-/*
- * Alchemy Semi Au1000 pcmcia driver include file
- *
- * Copyright 2001 MontaVista Software Inc.
- * Author: MontaVista Software, Inc.
- *         	ppopov@mvista.com or source@mvista.com
- *
- *  This program is free software; you can distribute it and/or modify it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WITHOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- */
-#ifndef __ASM_AU1000_PCMCIA_H
-#define __ASM_AU1000_PCMCIA_H
-
-/* include the world */
-
-#include <pcmcia/ss.h>
-#include <pcmcia/cistpl.h>
-#include "cs_internal.h"
-
-#define AU1000_PCMCIA_POLL_PERIOD    (2*HZ)
-#define AU1000_PCMCIA_IO_SPEED       (255)
-#define AU1000_PCMCIA_MEM_SPEED      (300)
-
-#define AU1X_SOCK0_IO        0xF00000000ULL
-#define AU1X_SOCK0_PHYS_ATTR 0xF40000000ULL
-#define AU1X_SOCK0_PHYS_MEM  0xF80000000ULL
-
-/* pcmcia socket 1 needs external glue logic so the memory map
- * differs from board to board.
- */
-#if defined(CONFIG_MIPS_PB1000)
-#define AU1X_SOCK1_IO        0xF08000000ULL
-#define AU1X_SOCK1_PHYS_ATTR 0xF48000000ULL
-#define AU1X_SOCK1_PHYS_MEM  0xF88000000ULL
-#endif
-
-struct pcmcia_state {
-  unsigned detect: 1,
-            ready: 1,
-           wrprot: 1,
-	     bvd1: 1,
-	     bvd2: 1,
-            vs_3v: 1,
-            vs_Xv: 1;
-};
-
-struct pcmcia_configure {
-  unsigned sock: 8,
-            vcc: 8,
-            vpp: 8,
-         output: 1,
-        speaker: 1,
-          reset: 1;
-};
-
-struct pcmcia_irqs {
-	int sock;
-	int irq;
-	const char *str;
-};
-
-
-struct au1000_pcmcia_socket {
-	struct pcmcia_socket socket;
-
-	/*
-	 * Info from low level handler
-	 */
-	struct device		*dev;
-	unsigned int		nr;
-	unsigned int		irq;
-
-	/*
-	 * Core PCMCIA state
-	 */
-	struct pcmcia_low_level *ops;
-
-	unsigned int 		status;
-	socket_state_t		cs_state;
-
-	unsigned short		spd_io[MAX_IO_WIN];
-	unsigned short		spd_mem[MAX_WIN];
-	unsigned short		spd_attr[MAX_WIN];
-
-	struct resource		res_skt;
-	struct resource		res_io;
-	struct resource		res_mem;
-	struct resource		res_attr;
-
-	void *                 	virt_io;
-	unsigned int		phys_io;
-	unsigned int           	phys_attr;
-	unsigned int           	phys_mem;
-	unsigned short        	speed_io, speed_attr, speed_mem;
-
-	unsigned int		irq_state;
-
-	struct timer_list	poll_timer;
-};
-
-struct pcmcia_low_level {
-	struct module *owner;
-
-	int (*hw_init)(struct au1000_pcmcia_socket *);
-	void (*hw_shutdown)(struct au1000_pcmcia_socket *);
-
-	void (*socket_state)(struct au1000_pcmcia_socket *, struct pcmcia_state *);
-	int (*configure_socket)(struct au1000_pcmcia_socket *, struct socket_state_t *);
-
-	/*
-	 * Enable card status IRQs on (re-)initialisation.  This can
-	 * be called at initialisation, power management event, or
-	 * pcmcia event.
-	 */
-	void (*socket_init)(struct au1000_pcmcia_socket *);
-
-	/*
-	 * Disable card status IRQs and PCMCIA bus on suspend.
-	 */
-	void (*socket_suspend)(struct au1000_pcmcia_socket *);
-};
-
-extern int au1x_board_init(struct device *dev);
-
-#endif /* __ASM_AU1000_PCMCIA_H */
diff --git a/drivers/pcmcia/au1000_pb1x00.c b/drivers/pcmcia/au1000_pb1x00.c
deleted file mode 100644
index b239664..0000000
--- a/drivers/pcmcia/au1000_pb1x00.c
+++ /dev/null
@@ -1,294 +0,0 @@
-/*
- *
- * Alchemy Semi Pb1000 boards specific pcmcia routines.
- *
- * Copyright 2002 MontaVista Software Inc.
- * Author: MontaVista Software, Inc.
- *         	ppopov@mvista.com or source@mvista.com
- *
- * ########################################################################
- *
- *  This program is free software; you can distribute it and/or modify it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WITHOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- */
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/ioport.h>
-#include <linux/kernel.h>
-#include <linux/timer.h>
-#include <linux/mm.h>
-#include <linux/proc_fs.h>
-#include <linux/types.h>
-
-#include <pcmcia/ss.h>
-#include <pcmcia/cistpl.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/system.h>
-
-#include <asm/au1000.h>
-#include <asm/au1000_pcmcia.h>
-
-#define debug(fmt, arg...) do { } while (0)
-
-#include <asm/pb1000.h>
-#define PCMCIA_IRQ AU1000_GPIO_15
-
-static int pb1x00_pcmcia_init(struct pcmcia_init *init)
-{
-	u16 pcr;
-	pcr = PCR_SLOT_0_RST | PCR_SLOT_1_RST;
-
-	au_writel(0x8000, PB1000_MDR); /* clear pcmcia interrupt */
-	au_sync_delay(100);
-	au_writel(0x4000, PB1000_MDR); /* enable pcmcia interrupt */
-	au_sync();
-
-	pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,0);
-	pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,1);
-	au_writel(pcr, PB1000_PCR);
-	au_sync_delay(20);
-	  
-	return PCMCIA_NUM_SOCKS;
-}
-
-static int pb1x00_pcmcia_shutdown(void)
-{
-	u16 pcr;
-	pcr = PCR_SLOT_0_RST | PCR_SLOT_1_RST;
-	pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,0);
-	pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,1);
-	au_writel(pcr, PB1000_PCR);
-	au_sync_delay(20);
-	return 0;
-}
-
-static int 
-pb1x00_pcmcia_socket_state(unsigned sock, struct pcmcia_state *state)
-{
-	u32 inserted0, inserted1;
-	u16 vs0, vs1;
-
-	vs0 = vs1 = (u16)au_readl(PB1000_ACR1);
-	inserted0 = !(vs0 & (ACR1_SLOT_0_CD1 | ACR1_SLOT_0_CD2));
-	inserted1 = !(vs1 & (ACR1_SLOT_1_CD1 | ACR1_SLOT_1_CD2));
-	vs0 = (vs0 >> 4) & 0x3;
-	vs1 = (vs1 >> 12) & 0x3;
-
-	state->ready = 0;
-	state->vs_Xv = 0;
-	state->vs_3v = 0;
-	state->detect = 0;
-
-	if (sock == 0) {
-		if (inserted0) {
-			switch (vs0) {
-				case 0:
-				case 2:
-					state->vs_3v=1;
-					break;
-				case 3: /* 5V */
-					break;
-				default:
-					/* return without setting 'detect' */
-					printk(KERN_ERR "pb1x00 bad VS (%d)\n",
-							vs0);
-					return 0;
-			}
-			state->detect = 1;
-		}
-	}
-	else  {
-		if (inserted1) {
-			switch (vs1) {
-				case 0:
-				case 2:
-					state->vs_3v=1;
-					break;
-				case 3: /* 5V */
-					break;
-				default:
-					/* return without setting 'detect' */
-					printk(KERN_ERR "pb1x00 bad VS (%d)\n",
-							vs1);
-					return 0;
-			}
-			state->detect = 1;
-		}
-	}
-
-	if (state->detect) {
-		state->ready = 1;
-	}
-
-	state->bvd1=1;
-	state->bvd2=1;
-	state->wrprot=0; 
-	return 1;
-}
-
-
-static int pb1x00_pcmcia_get_irq_info(struct pcmcia_irq_info *info)
-{
-
-	if(info->sock > PCMCIA_MAX_SOCK) return -1;
-
-	/*
-	 * Even in the case of the Pb1000, both sockets are connected
-	 * to the same irq line.
-	 */
-	info->irq = PCMCIA_IRQ;
-
-	return 0;
-}
-
-
-static int 
-pb1x00_pcmcia_configure_socket(const struct pcmcia_configure *configure)
-{
-	u16 pcr;
-
-	if(configure->sock > PCMCIA_MAX_SOCK) return -1;
-
-	pcr = au_readl(PB1000_PCR);
-
-	if (configure->sock == 0) {
-		pcr &= ~(PCR_SLOT_0_VCC0 | PCR_SLOT_0_VCC1 | 
-				PCR_SLOT_0_VPP0 | PCR_SLOT_0_VPP1);
-	}
-	else  {
-		pcr &= ~(PCR_SLOT_1_VCC0 | PCR_SLOT_1_VCC1 | 
-				PCR_SLOT_1_VPP0 | PCR_SLOT_1_VPP1);
-	}
-
-	pcr &= ~PCR_SLOT_0_RST;
-	debug("Vcc %dV Vpp %dV, pcr %x\n", 
-			configure->vcc, configure->vpp, pcr);
-	switch(configure->vcc){
-		case 0:  /* Vcc 0 */
-			switch(configure->vpp) {
-				case 0:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_GND,
-							configure->sock);
-					break;
-				case 12:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_12V,
-							configure->sock);
-					break;
-				case 50:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_5V,
-							configure->sock);
-					break;
-				case 33:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_3V,
-							configure->sock);
-					break;
-				default:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,
-							configure->sock);
-					printk("%s: bad Vcc/Vpp (%d:%d)\n", 
-							__func__,
-							configure->vcc, 
-							configure->vpp);
-					break;
-			}
-			break;
-		case 50: /* Vcc 5V */
-			switch(configure->vpp) {
-				case 0:
-					pcr |= SET_VCC_VPP(VCC_5V,VPP_GND,
-							configure->sock);
-					break;
-				case 50:
-					pcr |= SET_VCC_VPP(VCC_5V,VPP_5V,
-							configure->sock);
-					break;
-				case 12:
-					pcr |= SET_VCC_VPP(VCC_5V,VPP_12V,
-							configure->sock);
-					break;
-				case 33:
-					pcr |= SET_VCC_VPP(VCC_5V,VPP_3V,
-							configure->sock);
-					break;
-				default:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,
-							configure->sock);
-					printk("%s: bad Vcc/Vpp (%d:%d)\n", 
-							__func__,
-							configure->vcc, 
-							configure->vpp);
-					break;
-			}
-			break;
-		case 33: /* Vcc 3.3V */
-			switch(configure->vpp) {
-				case 0:
-					pcr |= SET_VCC_VPP(VCC_3V,VPP_GND,
-							configure->sock);
-					break;
-				case 50:
-					pcr |= SET_VCC_VPP(VCC_3V,VPP_5V,
-							configure->sock);
-					break;
-				case 12:
-					pcr |= SET_VCC_VPP(VCC_3V,VPP_12V,
-							configure->sock);
-					break;
-				case 33:
-					pcr |= SET_VCC_VPP(VCC_3V,VPP_3V,
-							configure->sock);
-					break;
-				default:
-					pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,
-							configure->sock);
-					printk("%s: bad Vcc/Vpp (%d:%d)\n", 
-							__func__,
-							configure->vcc, 
-							configure->vpp);
-					break;
-			}
-			break;
-		default: /* what's this ? */
-			pcr |= SET_VCC_VPP(VCC_HIZ,VPP_HIZ,configure->sock);
-			printk(KERN_ERR "%s: bad Vcc %d\n", 
-					__func__, configure->vcc);
-			break;
-	}
-
-	if (configure->sock == 0) {
-	pcr &= ~(PCR_SLOT_0_RST);
-		if (configure->reset)
-		pcr |= PCR_SLOT_0_RST;
-	}
-	else {
-		pcr &= ~(PCR_SLOT_1_RST);
-		if (configure->reset)
-			pcr |= PCR_SLOT_1_RST;
-	}
-	au_writel(pcr, PB1000_PCR);
-	au_sync_delay(300);
-
-	return 0;
-}
-
-
-struct pcmcia_low_level pb1x00_pcmcia_ops = { 
-	pb1x00_pcmcia_init,
-	pb1x00_pcmcia_shutdown,
-	pb1x00_pcmcia_socket_state,
-	pb1x00_pcmcia_get_irq_info,
-	pb1x00_pcmcia_configure_socket
-};
-- 
1.7.7.1
