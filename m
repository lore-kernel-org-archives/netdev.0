From: akpm@linux-foundation.org
Subject: [patch 13/13] ax88796: add 93cx6 eeprom support
Date: Tue, 02 Oct 2007 14:11:44 -0700
Message-ID: <200710022111.l92LBi6H022513@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, ben-linux@fluff.org, damm@igel.co.jp,
	lethal@linux-sh.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36089 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755381AbXJBVVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:21:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>

Hook up the 93cx6 eeprom code to the ax88796 driver and modify the ax88796
driver to read out the mac address from the eeprom.  We need this for the
ax88796 on certain SuperH boards.  The pin configuration used to connect
the eeprom to the ax88796 on these boards is the same as pointed out by the
ax88796 datasheet, so we can probably reuse this code for multiple
platforms in the future.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Cc: Ben Dooks <ben-linux@fluff.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig          |    7 ++++
 drivers/net/ax88796.c        |   49 +++++++++++++++++++++++++++++++++
 include/linux/eeprom_93cx6.h |    3 +-
 include/net/ax88796.h        |    1 
 4 files changed, 59 insertions(+), 1 deletion(-)

diff -puN drivers/net/Kconfig~ax88796-add-93cx6-eeprom-support drivers/net/Kconfig
--- a/drivers/net/Kconfig~ax88796-add-93cx6-eeprom-support
+++ a/drivers/net/Kconfig
@@ -240,6 +240,13 @@ config AX88796
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
diff -puN drivers/net/ax88796.c~ax88796-add-93cx6-eeprom-support drivers/net/ax88796.c
--- a/drivers/net/ax88796.c~ax88796-add-93cx6-eeprom-support
+++ a/drivers/net/ax88796.c
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
diff -puN include/linux/eeprom_93cx6.h~ax88796-add-93cx6-eeprom-support include/linux/eeprom_93cx6.h
--- a/include/linux/eeprom_93cx6.h~ax88796-add-93cx6-eeprom-support
+++ a/include/linux/eeprom_93cx6.h
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
diff -puN include/net/ax88796.h~ax88796-add-93cx6-eeprom-support include/net/ax88796.h
--- a/include/net/ax88796.h~ax88796-add-93cx6-eeprom-support
+++ a/include/net/ax88796.h
@@ -14,6 +14,7 @@
 
 #define AXFLG_HAS_EEPROM		(1<<0)
 #define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
+#define AXFLG_HAS_93CX6			(1<<2)	/* use eeprom_93cx6 driver */
 
 struct ax_plat_data {
 	unsigned int	 flags;
_
