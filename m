From: Magnus Damm <magnus.damm@gmail.com>
Subject: ax88796: add 93cx6 eeprom support
Date: Thu, 27 Sep 2007 19:51:19 +0900
Message-ID: <20070927105119.6515.35298.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	jgarzik@pobox.com, akpm@linux-foundation.org, ben-linux@fluff.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.226]:51521 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbXI0Kx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 06:53:57 -0400
Received: by qb-out-0506.google.com with SMTP id e11so126977qbe
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 03:53:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ax88796: add 93cx6 eeprom support

This patch hooks up the 93cx6 eeprom code to the ax88796 driver and modifies
the ax88796 driver to read out the mac address from the eeprom. We need
this for the ax88796 on certain SuperH boards. The pin configuration used
to connect the eeprom to the ax88796 on these boards is the same as pointed
out by the ax88796 datasheet, so we can probably reuse this code for multiple
platforms in the future.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 This is a broken out version of the larger patch recently posted to netdev:
 http://www.mail-archive.com/netdev@vger.kernel.org/msg47278.html

 drivers/net/Kconfig          |    7 ++++++
 drivers/net/ax88796.c        |   49 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/eeprom_93cx6.h |    3 +-
 include/net/ax88796.h        |    1 
 4 files changed, 59 insertions(+), 1 deletion(-)

--- 0001/drivers/net/Kconfig
+++ work/drivers/net/Kconfig	2007-09-27 19:32:10.000000000 +0900
@@ -225,6 +225,13 @@ config AX88796
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
+++ work/drivers/net/ax88796.c	2007-09-27 19:17:44.000000000 +0900
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
+++ work/include/linux/eeprom_93cx6.h	2007-09-27 19:17:44.000000000 +0900
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
+++ work/include/net/ax88796.h	2007-09-27 19:17:44.000000000 +0900
@@ -14,6 +14,7 @@
 
 #define AXFLG_HAS_EEPROM		(1<<0)
 #define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
+#define AXFLG_HAS_93CX6			(1<<2)	/* use eeprom_93cx6 driver */
 
 struct ax_plat_data {
 	unsigned int	 flags;
