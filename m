From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [RFC] EEPROM dumping/changing code for r8169 driver
Date: Sun, 21 Jul 2013 18:27:53 +0200
Message-ID: <3011523.vtKLIuqRfe@al>
References: <1906856.2MoFjQXLhS@al> <1374422514.2804.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:59056 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755720Ab3GUQ16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:27:58 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so3329503eek.34
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:27:57 -0700 (PDT)
In-Reply-To: <1374422514.2804.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 21 July 2013 17:01:54 Ben Hutchings wrote:
> On Fri, 2013-07-19 at 11:48 +0200, Peter Wu wrote:
> > Hi,
> > 
> > As noted in another mail, I have been working on adding EEPROM reading
> > writing support for the r8169 driver. The below diff adds basic support,
> > but it
> > is not completely finished yet:
> [...]
> 
> > --- a/drivers/net/ethernet/realtek/Kconfig
> > +++ b/drivers/net/ethernet/realtek/Kconfig
> > @@ -112,4 +112,13 @@ config R8169
> > 
> >  	  To compile this driver as a module, choose M here: the module
> >  	  will be called r8169.  This is recommended.
> > 
> > +config R8169_93CX6
> > +	bool "Realtek 8169 external 93CX6 EEPROM support"
> > +	depends on R8169
> > +	select EEPROM_93CX6
> 
> [...]
> 
> This select is wrong as it will cause EEPROM_93CX6=y even if R8169=m.
> But why make this an option at all?
For this, I got inspiration from drivers/ethernet/8390/Kconfig which had an
AX88796_93CX6 option. Reading EEPROM is currently not a critical piece of
functionality, so I decided to make this optional. There seem also to be newer
hardware that use a two-wired serial interface for accessing EEPROM instead of
93C46/93C56/93C66. Would you suggest always including this code (distro
kernels should typically enable this) or making it optional? If optional, what
is the correct way to depend on EEPROM_93CX6? I think that this option will
be hidden in the R8169 menu until EEPROM_93CX6 is selected which might be
confusing if looking for this option.

Newer patch follows, I still need to figure out why it reads FFs on my onboard
RTL8111E NIC. (observation: accessing PCI memory resource2 via sysfs gives an
EIO error, `ethtool -d eth0` fails too and reads FFs).

Thanks,
Peter
---
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index ae5d027..68a1317 100644
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
+	  Select this if your want to access the 93C46/93C56/93C66 EEPROM of the
+	  Realtek 8169 PCI Gigabit Ethernet adapter. This is necessary for
+	  dumping or changing EEPROM using ethtool. If unsure, say N.
+
 endif # NET_VENDOR_REALTEK
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 880015c..d03d2ee 100644
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
@@ -1643,6 +1652,152 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 	return R8169_REGS_SIZE;
 }
 
+#ifdef CONFIG_R8169_93CX6
+static int rtl8169_get_eeprom_len(struct net_device *dev) {
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
+	struct rtl8169_private *tp = eeprom->data;
+	void __iomem *ioaddr = tp->mmio_addr;
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
+	struct rtl8169_private *tp = eeprom->data;
+	void __iomem *ioaddr = tp->mmio_addr;
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
+static void rtl_init_93cx6(struct net_device *dev, struct eeprom_93cx6 *eeprom)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	eeprom->data = tp;
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
+	rtl_init_93cx6(dev, &eeprom);
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
@@ -2024,6 +2179,11 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
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
