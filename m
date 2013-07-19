From: Peter Wu <lekensteyn@gmail.com>
Subject: [RFC] EEPROM dumping/changing code for r8169 driver
Date: Fri, 19 Jul 2013 11:48:55 +0200
Message-ID: <1906856.2MoFjQXLhS@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:44930 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759915Ab3GSJtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 05:49:00 -0400
Received: by mail-wg0-f49.google.com with SMTP id a12so3868742wgh.16
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 02:48:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As noted in another mail, I have been working on adding EEPROM reading
writing support for the r8169 driver. The below diff adds basic support, but it
is not completely finished yet:

- debug code is still present
- Kconfig help text might be reworded
- No check for EEPROM size, currently it assumed 1K bits, but 2K bits also
  exist. This is low-hanging fruit, but as I did not have hardware with 93c56,
  I did not bother to add it right now. (according to the Realtek r8168
  driver, there are also configurations without these 93cx6 chips, but an
  EEPROM with "TWSI" which these changes currently do not account for at all)

There is an issue with reading though, the initial read fails until a
certain action has happened[1]. In the case of an external RTL8169sb GBe PCI card
(RTL869SC according to the text on the chip), a write to the EEPROM has to
happen first. Could it be a timing issue? I have several PDFs available, but the
most detailed one is a PDF with the title "xRTL8169spec_1.21.DOC" (from 2002)
which also has a section "11.3.2 Serial EEPROM Interface Timing".

Regards,
Peter

 [1]: http://marc.info/?l=linux-netdev&m=137422584013574
--
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index ae5d027..ee70de2 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -112,4 +112,13 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
+config R8169_93CX6
+	bool "Realtek 8169 external 93CX6 EEPROM support"
+	depends on R8169
+	select EEPROM_93CX6
+	---help---
+	  Select this if your want to access EEPROM of the Realtek 8169 PCI
+	  Gigabit Ethernet adapter. This is necessary for dumping or changing
+	  EEPROM using ethtool. If unsure, say N.
+
 endif # NET_VENDOR_REALTEK
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4106a74..dc5d11c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -28,6 +28,7 @@
 #include <linux/firmware.h>
 #include <linux/pci-aspm.h>
 #include <linux/prefetch.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -412,7 +413,8 @@ enum rtl8168_8101_registers {
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
-	TWSI			= 0xd2,
+	TWSI			= 0xd2, /* Two Wire Serial Interface */
+#define TWSI_TYPE_EEPROM		(1 << 2)
 	MCU			= 0xd3,
 #define	NOW_IS_OOB			(1 << 7)
 #define	TX_EMPTY			(1 << 5)
@@ -504,8 +506,14 @@ enum rtl_register_content {
 	FSWInt		= 0x01,		/* Forced software interrupt */
 
 	/* Cfg9346Bits */
+	Cfg9346_mask	= 0xc0,
 	Cfg9346_Lock	= 0x00,
 	Cfg9346_Unlock	= 0xc0,
+	Cfg9346_Program	= 0x80,		/* Programming mode */
+	Cfg9346_EECS	= 0x08,		/* Chip select */
+	Cfg9346_EESK	= 0x04,		/* Serial data clock */
+	Cfg9346_EEDI	= 0x02,		/* Data input */
+	Cfg9346_EEDO	= 0x01,		/* Data output */
 
 	/* rx_mode_bits */
 	AcceptErr	= 0x20,
@@ -1643,6 +1651,172 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 	return R8169_REGS_SIZE;
 }
 
+#ifdef CONFIG_R8169_93CX6
+static int rtl8169_get_eeprom_len(struct net_device *dev) {
+	/* TODO do not hard code EEPROM size, detect it! */
+	/* 93c46 -> 1K bit, 93c56 -> 2K bit */
+	return 1024 / 8; /* must be ONE byte! */
+}
+
+static void rtl_eeprom_read(struct eeprom_93cx6 *eeprom)
+{
+	struct rtl8169_private *tp = eeprom->data;
+	void __iomem *ioaddr = tp->mmio_addr;
+	u8 reg;
+
+	reg = RTL_R8(Cfg9346);
+
+	eeprom->reg_data_in = reg & Cfg9346_EEDI;
+	eeprom->reg_data_out = reg & Cfg9346_EEDO;
+	eeprom->reg_data_clock = reg & Cfg9346_EESK;
+	eeprom->reg_chip_select = reg & Cfg9346_EECS;
+	if (0 && !(reg & Cfg9346_EECS)) { /* DEBUG - remove me! */
+		struct net_device *dev;
+		dev = (struct net_device *)((char *) tp - ALIGN(sizeof(struct net_device), NETDEV_ALIGN));
+		netif_warn(tp, link, dev, "CS is disabled, reg=0x%02x\n", reg);
+	}
+}
+
+static void rtl_eeprom_write(struct eeprom_93cx6 *eeprom)
+{
+	struct rtl8169_private *tp = eeprom->data;
+	void __iomem *ioaddr = tp->mmio_addr;
+	u8 reg;
+
+	reg = RTL_R8(Cfg9346) & ~Cfg9346_mask;
+	reg |= Cfg9346_Program;
+	reg &= ~(Cfg9346_EEDO | Cfg9346_EEDI | Cfg9346_EESK | Cfg9346_EECS);
+
+	if (eeprom->reg_data_in)
+		reg |= Cfg9346_EEDI;
+	if (eeprom->reg_data_clock)
+		reg |= Cfg9346_EESK;
+	if (eeprom->reg_chip_select)
+		reg |= Cfg9346_EECS;
+
+	RTL_W8(Cfg9346, reg);
+	RTL_R8(Cfg9346); /* sync? */
+	udelay(4); /* SK Clock Cycle Time */
+	//udelay(3); /* DO Setup time is min 2 us for 9346, DO hold time max 2us */
+}
+
+static void rtl_init_93cx6(struct net_device *dev, struct eeprom_93cx6 *eeprom)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	eeprom->data = tp;
+	eeprom->register_read = rtl_eeprom_read;
+	eeprom->register_write = rtl_eeprom_write;
+	/* TODO: check EEPROM type; note TWSI_TYPE_EEPROM is not supported */
+	eeprom->width = PCI_EEPROM_WIDTH_93C46;
+}
+
+/* semi-randomly chosen key for ethtool --change-eeprom option */
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
+	rtl_init_93cx6(dev, &eeprom);
+	/* something odd is happening, I must write *at least once* to the
+	 * eeprom (say, 00 to offset 0) before read returns something else than
+	 * 00. IOTW, if no write is performed, all values read as 00. Attempted
+	 * solutions that failed:
+	 * eeprom_93cx6_wren(&eeprom, false); // also tried wr(1) before wren(0)
+	 * W(Cfg9346, Cfg9346_Program);R(Cfg9346);udelay(10); // tried |CS too
+	 *
+	 * The oddiest thing is that this seems to survive a shutdown (even 15
+	 * minutes). Next attempt wa taking this PCI card out of the machine and
+	 * leave it disconnected for 20 minutes. This did not work either. The
+	 * capacitors are likely still charged. When the machine was left
+	 * powered off (not disconnected) for 9.5 hours, the eeprom read empty
+	 * though. auto-loading from eeprom (Cfg9346 = 0x40) also seems to work?
+	 * (or was it caused by writing 2981 to EEPROM[0:1] before autoload?)
+	 */
+
+	/* this does not work (from rtl8180): */
+	//RTL_W8(Cfg9346, Cfg9346_Program);
+	//RTL_R8(Cfg9346);
+	//udelay(10);
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
+	rtl_init_93cx6(dev, &eeprom);
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
+#endif
+
 static int rtl8169_set_speed_tbi(struct net_device *dev,
 				 u8 autoneg, u16 speed, u8 duplex, u32 ignored)
 {
@@ -2024,6 +2198,11 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
+#ifdef CONFIG_R8169_93CX6
+	.get_eeprom_len		= rtl8169_get_eeprom_len,
+	.get_eeprom		= rtl8169_get_eeprom,
+	.set_eeprom		= rtl8169_set_eeprom,
+#endif
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 	.get_msglevel		= rtl8169_get_msglevel,
@@ -7114,6 +7293,19 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	mutex_init(&tp->wk.mutex);
 
+	if (0) { /* DEBUG - remove me! */
+		u16 val = 0xAB;
+		struct eeprom_93cx6 eeprom = {
+			.data = tp,
+			.register_read = rtl_eeprom_read,
+			.register_write = rtl_eeprom_write,
+			.width = PCI_EEPROM_WIDTH_93C46
+		};
+		eeprom_93cx6_read(&eeprom, 0, &val);
+		pr_info("Read something: 0x%04x\n", val);
+		RTL_W8(Cfg9346, Cfg9346_Lock);
+	}
+
 	/* Get MAC address */
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
