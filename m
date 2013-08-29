From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: add ethtool eeprom change/dump feature
Date: Thu, 29 Aug 2013 16:44:51 +0200
Message-ID: <1377787491-2932-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:58691 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab3H2Oo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 10:44:57 -0400
Received: by mail-we0-f182.google.com with SMTP id q59so510556wes.41
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 07:44:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ability to read and change EEPROM for 93C46/93C56 serial
EEPROM. Two-Wire serial interface and SPI are not supported. (Do not
even try this for SPI or other chips, it may break your hardware.)

Works with RTL8169SCL (driver detects RTL8169sb), with some quirks. Not
sure if it is a hardware bug, but to be able to read EEPROM, one has
to write something, e.g.:

    printf '\0\0' | ethtool -E eth0 magic 0x8169 offset 0x40 length 2

Otherwise, only zeroes are read. Another note for this NIC, one has to
"enable" the eeprom by writing to it (as shown above) and then make the
NIC to reload the contents from firmware such that the PCI ID gets
detected correctly (10ec:8169 instead of 10ec:8129). Reload by writing
0x40 (Auto-load) to register 0x50 (9346CR):

    printf '\x40' | dd seek=80 bs=1 \
        of=/sys/bus/pci/devices/0000:03:00.0/resource0

Then detach and rescan the PCI device (use `lspci -tv` to find parent):

    echo 1 > /sys/bus/pci/devices/0000\:03\:00.0/remove
    echo 1 > /sys/bus/pci/devices/0000\:02\:00.0/rescan

After this, this RTL8169sb PCI GbE NIC appears to work.

On a second RTL8188E onboard GbE chip, EEPROM cannot be dumped, writing
also does nothing. Here, reads all return FFs.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
Hi,

An RFC of this patch was created a month ago[1]. Ben Hutchings suggested
to drop the CONFIG knob and always include the ethtool operations for
getting and setting the EEPROM, so I did that for later versions. This
new patch also checks the EEPROM size (depends on whether 93C46 or 93C56
is used) and has a minor style fix (brace on new line).

I do not know why exactly I have to do funky things with the EEPROM to
fix the PCI IDs. Hayes, perhaps you have an idea?

[ lspci of broken device ]
03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8129 [10ec:8129] (rev 10)
        Subsystem: Coreco Inc RT8129 Fast Ethernet Adapter [11ec:8129]
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at e000 [size=256]
        Region 1: Memory at f7b41000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at f7b00000 [disabled] [size=256K]
        Capabilities: [dc] Power Management version 1
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0-,D1-,D2-,D3hot-,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: pci-stub
        Kernel modules: r8169, 8139too

[ lspci after EEPROM activation, working device ]
03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8129 [10ec:8129] (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. Device [10ec:8169]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at e000 [size=256]
        Region 1: [virtual] Memory at f7b41000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at f7b00000 [disabled] [size=256K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169
        Kernel modules: r8169, 8139too

Note: while writing the EEPROM while the card is "broken", I see the
following in my dmesg:

    eeprom_93cx6_write: timeout

FWIW, two photos of this card can be found on
https://lekensteyn.nl/files/realtek/ (this Lefen BL-L8169-2 card was
bought via eBay).

Regards,
Peter

 [1]: http://lkml.kernel.org/r/1906856.2MoFjQXLhS@al
---
 drivers/net/ethernet/realtek/Kconfig |   1 +
 drivers/net/ethernet/realtek/r8169.c | 158 ++++++++++++++++++++++++++++++++++-
 2 files changed, 156 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index ae5d027..d0d5b94 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -106,6 +106,7 @@ config R8169
 	select FW_LOADER
 	select CRC32
 	select MII
+	select EEPROM_93CX6
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f87f2c..35922b0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -28,6 +28,7 @@
 #include <linux/firmware.h>
 #include <linux/pci-aspm.h>
 #include <linux/prefetch.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -348,6 +349,7 @@ enum rtl_registers {
 #define	RXCFG_DMA_SHIFT			8
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
+#define	RX_9356SEL			(1 << 6) /* EEPROM type */
 
 	RxMissed	= 0x4c,
 	Cfg9346		= 0x50,
@@ -412,7 +414,8 @@ enum rtl8168_8101_registers {
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
-	TWSI			= 0xd2,
+	TWSI			= 0xd2, /* Two Wire Serial Interface */
+#define	TWSI_TYPE_EEPROM		(1 << 2)
 	MCU			= 0xd3,
 #define	NOW_IS_OOB			(1 << 7)
 #define	TX_EMPTY			(1 << 5)
@@ -504,8 +507,14 @@ enum rtl_register_content {
 	FSWInt		= 0x01,		/* Forced software interrupt */
 
 	/* Cfg9346Bits */
-	Cfg9346_Lock	= 0x00,
-	Cfg9346_Unlock	= 0xc0,
+	Cfg9346_Lock	= (0 << 6),	/* Normal communication mode */
+	Cfg9346_Program	= (2 << 6),	/* Programming mode */
+	Cfg9346_Unlock	= (3 << 6),	/* config register write enable */
+
+	Cfg9346_EECS	= (1 << 3),	/* Chip select */
+	Cfg9346_EESK	= (1 << 2),	/* Serial data clock */
+	Cfg9346_EEDI	= (1 << 1),	/* Data input */
+	Cfg9346_EEDO	= (1 << 0),	/* Data output */
 
 	/* rx_mode_bits */
 	AcceptErr	= 0x20,
@@ -1643,6 +1652,146 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 	return R8169_REGS_SIZE;
 }
 
+static int rtl8169_get_eeprom_len(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (RTL_R8(TWSI) & TWSI_TYPE_EEPROM)
+		return 0; /* 2-Wire Interface is unsupported for now */
+
+	/* 3-Wire Interface */
+	if (RTL_R8(RxConfig) & RX_9356SEL)
+		return 256; /* 93C56/93C66 */
+	else
+		return 128; /* 93C46 */
+}
+
+static void rtl_eeprom_read(struct eeprom_93cx6 *eeprom)
+{
+	void __iomem *ioaddr = eeprom->data;
+	u8 reg = RTL_R8(Cfg9346);
+
+	eeprom->reg_data_in = reg & Cfg9346_EEDI;
+	eeprom->reg_data_out = reg & Cfg9346_EEDO;
+	eeprom->reg_data_clock = reg & Cfg9346_EESK;
+	eeprom->reg_chip_select = reg & Cfg9346_EECS;
+}
+
+static void rtl_eeprom_write(struct eeprom_93cx6 *eeprom)
+{
+	void __iomem *ioaddr = eeprom->data;
+	u8 reg = Cfg9346_Program;
+
+	if (eeprom->reg_data_in)
+		reg |= Cfg9346_EEDI;
+	if (eeprom->reg_data_clock)
+		reg |= Cfg9346_EESK;
+	if (eeprom->reg_chip_select)
+		reg |= Cfg9346_EECS;
+
+	RTL_W8(Cfg9346, reg);
+	udelay(3); /* matches RTL_CLOCK_RATE in r8168 */
+}
+
+static void rtl_init_93cx6(void __iomem *ioaddr, struct eeprom_93cx6 *eeprom)
+{
+	eeprom->data = ioaddr;
+	eeprom->register_read = rtl_eeprom_read;
+	eeprom->register_write = rtl_eeprom_write;
+
+	/* assume 3-Wire Interface, not TWI */
+	if (RTL_R8(RxConfig) & RX_9356SEL)
+		eeprom->width = PCI_EEPROM_WIDTH_93C56;
+	else
+		eeprom->width = PCI_EEPROM_WIDTH_93C46;
+}
+
+/* semi-randomly chosen magic for ethtool --change-eeprom option */
+#define R8169_EEPROM_MAGIC (0x00008169)
+
+static int rtl8169_get_eeprom(struct net_device *dev,
+		struct ethtool_eeprom *ee_eeprom, u8 *data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct eeprom_93cx6 eeprom;
+	int i = 0;
+	u8 offset = ee_eeprom->offset >> 1;
+	u16 val;
+
+	ee_eeprom->magic = R8169_EEPROM_MAGIC;
+
+	rtl_lock_work(tp);
+	rtl_init_93cx6(ioaddr, &eeprom);
+
+	/* Do not use eeprom_93cx6_multiread, that returns data in an array of
+	 * little endian words which is not compatible with BE arches. */
+
+	if (ee_eeprom->offset & 1) {
+		eeprom_93cx6_read(&eeprom, offset++, &val);
+		data[i++] = val >> 8;
+	}
+
+	while (i < ee_eeprom->len - 1) {
+		eeprom_93cx6_read(&eeprom, offset++, &val);
+		data[i++] = val & 0xFF;
+		data[i++] = val >> 8;
+	}
+
+	if (i < ee_eeprom->len) {
+		eeprom_93cx6_read(&eeprom, offset, &val);
+		data[i] = val & 0xFF;
+	}
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_unlock_work(tp);
+	return 0;
+}
+
+static int rtl8169_set_eeprom(struct net_device *dev,
+		struct ethtool_eeprom *ee_eeprom, u8 *data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct eeprom_93cx6 eeprom;
+	int i = 0;
+	u8 offset = ee_eeprom->offset >> 1;
+	u16 val;
+
+	if (ee_eeprom->magic != R8169_EEPROM_MAGIC)
+		return -EINVAL;
+
+	rtl_lock_work(tp);
+	rtl_init_93cx6(ioaddr, &eeprom);
+	eeprom_93cx6_wren(&eeprom, true);
+
+	if (ee_eeprom->offset & 1) {
+		eeprom_93cx6_read(&eeprom, offset, &val);
+		val &= 0xFF;
+		val |= ((u16)data[i++]) << 8;
+		eeprom_93cx6_write(&eeprom, offset++, val);
+	}
+
+	while (i < ee_eeprom->len - 1) {
+		val = data[i++];
+		val |= ((u16)data[i++]) << 8;
+		eeprom_93cx6_write(&eeprom, offset++, val);
+	}
+
+	if (i < ee_eeprom->len) {
+		eeprom_93cx6_read(&eeprom, offset, &val);
+		val &= 0xFF00;
+		val |= data[i++];
+		eeprom_93cx6_write(&eeprom, offset, val);
+	}
+
+	eeprom_93cx6_wren(&eeprom, false);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_unlock_work(tp);
+	return 0;
+}
+
 static int rtl8169_set_speed_tbi(struct net_device *dev,
 				 u8 autoneg, u16 speed, u8 duplex, u32 ignored)
 {
@@ -2025,6 +2174,9 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
+	.get_eeprom_len		= rtl8169_get_eeprom_len,
+	.get_eeprom		= rtl8169_get_eeprom,
+	.set_eeprom		= rtl8169_set_eeprom,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 	.get_msglevel		= rtl8169_get_msglevel,
-- 
1.8.4
