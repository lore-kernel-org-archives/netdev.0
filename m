From: Magnus Damm <magnus.damm@gmail.com>
Subject: sh: add support for ax88796 and 93cx6 to highlander boards
Date: Mon, 10 Sep 2007 15:36:26 +0900
Message-ID: <20070910063626.2300.75144.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	jgarzik@pobox.com, ben-linux@fluff.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.228]:49379 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbXIJGhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 02:37:50 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1022480qbe
        for <netdev@vger.kernel.org>; Sun, 09 Sep 2007 23:37:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sh: add support for ax88796 and 93cx6 to highlander boards

This patch adds eeprom support to the ax88796 driver together with a platform
device for highlander boards. The 93cx6 driver is hooked up to the ax88796
driver and is used to read out the mac address from the on board eeprom. The
pin configuration used to connect the eeprom to the ax88796 is the same one
as pointed out by the ax88796 datasheet. So it's likely that we can reuse
this code for other boards as well.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 arch/sh/boards/renesas/r7780rp/setup.c |   40 ++++++++++++++++++++++++++
 drivers/net/Kconfig                    |    9 +++++
 drivers/net/ax88796.c                  |   49 ++++++++++++++++++++++++++++++++
 include/linux/eeprom_93cx6.h           |    3 +
 include/net/ax88796.h                  |    1 
 5 files changed, 100 insertions(+), 2 deletions(-)

--- 0004/arch/sh/boards/renesas/r7780rp/setup.c
+++ work/arch/sh/boards/renesas/r7780rp/setup.c	2007-09-06 15:35:49.000000000 +0900
@@ -21,6 +21,7 @@
 #include <asm/clock.h>
 #include <asm/heartbeat.h>
 #include <asm/io.h>
+#include <net/ax88796.h>
 
 static struct resource r8a66597_usb_host_resources[] = {
 	[0] = {
@@ -136,11 +137,50 @@ static struct platform_device heartbeat_
 	.resource	= heartbeat_resources,
 };
 
+static struct ax_plat_data ax88796_platdata = {
+	.flags          = AXFLG_HAS_93CX6,
+	.wordlength     = 2,
+	.dcr_val        = 0x1,
+	.rcr_val        = 0x40,
+};
+
+static struct resource ax88796_resources[] = {
+	{
+#ifdef CONFIG_SH_R7780RP
+		.start  = 0xa5800400,
+		.end    = 0xa5800400 + (0x20 * 0x2) - 1,
+#else
+		.start  = 0xa4100400,
+		.end    = 0xa4100400 + (0x20 * 0x2) - 1,
+#endif
+		.flags  = IORESOURCE_MEM,
+	},
+	{
+		.start  = IRQ_AX88796,
+		.end    = IRQ_AX88796,
+		.flags  = IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device ax88796_device = {
+	.name           = "ax88796",
+	.id             = 0,
+
+	.dev    = {
+		.platform_data = &ax88796_platdata,
+	},
+
+	.num_resources  = ARRAY_SIZE(ax88796_resources),
+	.resource       = ax88796_resources,
+};
+
+
 static struct platform_device *r7780rp_devices[] __initdata = {
 	&r8a66597_usb_host_device,
 	&m66592_usb_peripheral_device,
 	&cf_ide_device,
 	&heartbeat_device,
+	&ax88796_device,
 };
 
 static int __init r7780rp_devices_setup(void)
--- 0001/drivers/net/Kconfig
+++ work/drivers/net/Kconfig	2007-09-06 15:35:41.000000000 +0900
@@ -218,13 +218,20 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS
+	depends on ARM || MIPS || SUPERH
 	select CRC32
 	select MII
 	help
 	  AX88796 driver, using platform bus to provide
 	  chip detection and resources
 
+config AX88796_93CX6
+	bool "ASIX AX88796 external 93CX6 eeprom support"
+	depends on AX88796
+	select EEPROM_93CX6
+	help
+	  Select this if your platform comes with an external 93CX6 eeprom.
+
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on PPC_PMAC && PPC32
--- 0001/drivers/net/ax88796.c
+++ work/drivers/net/ax88796.c	2007-09-06 15:35:41.000000000 +0900
@@ -24,6 +24,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <net/ax88796.h>
 
@@ -582,6 +583,37 @@ static const struct ethtool_ops ax_ethto
 	.get_link		= ax_get_link,
 };
 
+#ifdef CONFIG_AX88796_93CX6
+static void ax_eeprom_register_read(struct eeprom_93cx6 *eeprom)
+{
+	struct ei_device *ei_local = eeprom->data;
+	u8 reg = ei_inb(ei_local->mem + AX_MEMR);
+
+	eeprom->reg_data_in = reg & AX_MEMR_EEI;
+	eeprom->reg_data_out = reg & AX_MEMR_EEO; /* Input pin */
+	eeprom->reg_data_clock = reg & AX_MEMR_EECLK;
+	eeprom->reg_chip_select = reg & AX_MEMR_EECS;
+}
+
+static void ax_eeprom_register_write(struct eeprom_93cx6 *eeprom)
+{
+	struct ei_device *ei_local = eeprom->data;
+	u8 reg = ei_inb(ei_local->mem + AX_MEMR);
+
+	reg &= ~(AX_MEMR_EEI | AX_MEMR_EECLK | AX_MEMR_EECS);
+
+	if (eeprom->reg_data_in)
+		reg |= AX_MEMR_EEI;
+	if (eeprom->reg_data_clock)
+		reg |= AX_MEMR_EECLK;
+	if (eeprom->reg_chip_select)
+		reg |= AX_MEMR_EECS;
+
+	ei_outb(reg, ei_local->mem + AX_MEMR);
+	udelay(10);
+}
+#endif
+
 /* setup code */
 
 static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
@@ -640,6 +672,23 @@ static int ax_init_dev(struct net_device
 		memcpy(dev->dev_addr,  SA_prom, 6);
 	}
 
+#ifdef CONFIG_AX88796_93CX6
+	if (first_init && ax->plat->flags & AXFLG_HAS_93CX6) {
+		unsigned char mac_addr[6];
+		struct eeprom_93cx6 eeprom;
+
+		eeprom.data = ei_local;
+		eeprom.register_read = ax_eeprom_register_read;
+		eeprom.register_write = ax_eeprom_register_write;
+		eeprom.width = PCI_EEPROM_WIDTH_93C56;
+
+		eeprom_93cx6_multiread(&eeprom, 0,
+				       (__le16 __force *)mac_addr,
+				       sizeof(mac_addr) >> 1);
+
+		memcpy(dev->dev_addr,  mac_addr, 6);
+	}
+#endif
 	if (ax->plat->wordlength == 2) {
 		/* We must set the 8390 for word mode. */
 		ei_outb(ax->plat->dcr_val, ei_local->mem + EN0_DCFG);
--- 0001/include/linux/eeprom_93cx6.h
+++ work/include/linux/eeprom_93cx6.h	2007-09-06 15:35:41.000000000 +0900
@@ -21,13 +21,14 @@
 /*
 	Module: eeprom_93cx6
 	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
-	Supported chipsets: 93c46 & 93c66.
+	Supported chipsets: 93c46, 93c56 and 93c66.
  */
 
 /*
  * EEPROM operation defines.
  */
 #define PCI_EEPROM_WIDTH_93C46	6
+#define PCI_EEPROM_WIDTH_93C56	8
 #define PCI_EEPROM_WIDTH_93C66	8
 #define PCI_EEPROM_WIDTH_OPCODE	3
 #define PCI_EEPROM_WRITE_OPCODE	0x05
--- 0001/include/net/ax88796.h
+++ work/include/net/ax88796.h	2007-09-06 15:35:41.000000000 +0900
@@ -14,6 +14,7 @@
 
 #define AXFLG_HAS_EEPROM		(1<<0)
 #define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
+#define AXFLG_HAS_93CX6			(1<<2)	/* use eeprom_93cx6 driver */
 
 struct ax_plat_data {
 	unsigned int	 flags;
