From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Sat, 17 Mar 2012 12:35:01 +0100
Message-ID: <20120317113501.GC20532@electric-eye.fr.zoreil.com>
References: <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com> <20120314215142.655ae607@vostro> <1331755965.6022.55.camel@edumazet-glaptop> <20120314223343.23dc9df3@vostro> <20120314205319.GA28394@electric-eye.fr.zoreil.com> <20120315080635.1f76512b@vostro> <20120315171148.0050714d@vostro> <20120315191118.GA19809@electric-eye.fr.zoreil.com> <20120316221557.235f5ffd@vostro> <20120317115625.3fc04de4@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56938 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756267Ab2CQLgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 07:36:49 -0400
Content-Disposition: inline
In-Reply-To: <20120317115625.3fc04de4@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
> On Fri, 16 Mar 2012 22:15:57 +0200 Timo Teras <timo.teras@iki.fi> wrote:
[...]
> > Additional pointer to this direction is that one of the "broken" boxes
> > has different PCI ID for the "broken NIC" of the three. The hardware
> > is Jetway daughter board with the three NICs on single board. So it
> > sounds really weird that one of those NICs chips would be from
> > different series. I wonder if the PCI ID and other stuff could have
> > got corrupted in EEPROM or something similar.

Some of my old PCI 8169 show an unpleasant trend to lose config bits and
they can turn into unavailable devices (i.e. all 0xff registers) when
things go really wrong.

> It seems that we have working eeprom reading code in commit 6709fe9a27e4
> "r8169: read MAC address from EEPROM on init (2nd attempt)" which later
> got reverted due to problems. I'm now wondering if those problems were
> actually caused by unrelated issues that got later fixed in 78f1cd02457
> "r8169: fix broken register writes".

I have not tried working with the eeprom again since 024a07bac.

> I wonder if it'd be worth to do the eeprom reading and expose it via
> ethtool so I can compare those.

Yes.

> Or as easy alternative, enabling the VPD bit in Config1 should allow me
> to read the EEPROM contents using the PCI /sys/.../vpd interface, right?

In theory, yes. I have not tested it. Imho both access methods will be
useful.

I should have some unfinished VPD stuff somewhere. Will have to dig...

> And maybe re-introduce the reading of the MAC from there on reboot. Or
> if could just do:
> -	Cfg9346_Lock    = 0x00,
> +	Cfg9346_Lock    = 0x40,
> 
> The 0x40 apparently means "Auto-load: the EEPROM contents will be
> reloaded when PCI RSTB signal is asserted, and will automatically
> resume to normal 0x00 mode after the load".

It's a bit early to tell but I agree it may make some sense with
adequate conditions. I do not want to immediately break platforms
where bios / firmware plays itself games with eeprom reload or such.

See some resurrected r8169 eeprom patch below. I have to leave for work so
it is done in a hurry. It does not seem to crash immediately though:

# for d in 8168d-vb-gr 8102e-vb-gr 8168b-lom netgear; do ethtool -e $d; done
Offset		Values
------		------
0x0000		29 81 ec 10 68 81 ec 10 68 81 04 01 9c 62 00 e0 
0x0010		4c 68 00 2c 05 cf c3 ff 04 02 c0 8c 80 02 00 00 
0x0020		11 3c 07 00 10 20 76 00 63 01 01 ff 00 27 aa 03 
0x0030		02 20 89 7a 80 02 00 20 04 40 20 00 04 40 20 20 
0x0040		00 00 20 e1 22 b5 60 00 0a 00 e0 00 68 4c 00 00 
0x0050		30 00 00 00 b2 73 75 ea 87 75 7a 39 ca 98 ff ff 
0x0060		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0070		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
Offset		Values
------		------
0x0000		29 81 ec 10 36 81 ec 10 36 81 04 01 3c 62 00 e0 
0x0010		4c 36 00 07 05 0f c3 ff 02 14 c1 86 80 02 00 00 
0x0020		11 3c 07 00 10 20 76 00 63 01 01 ff 00 27 aa 03 
0x0030		02 20 4e 86 80 02 00 20 10 00 21 00 10 00 21 20 
0x0040		00 00 80 70 22 1d 80 00 20 00 e0 00 36 4c 00 00 
0x0050		07 00 00 00 af eb b5 35 00 00 00 00 00 00 00 00 
0x0060		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0070		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
Offset		Values
------		------
0x0000		29 81 ec 10 68 81 49 18 68 81 04 01 00 20 00 13 
0x0010		8f ea b1 5d 05 df c2 f7 42 00 23 7f 00 10 04 03 
0x0020		68 81 ec 10 00 00 00 1a ff ff ff ff ff ff 1f 00 
0x0030		00 47 ee 79 10 f0 f0 01 bf 01 00 00 60 00 00 01 
0x0040		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0070		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
Offset		Values
------		------
0x0000		29 81 ec 10 69 81 85 13 1a 31 20 40 00 a1 00 09 
0x0010		5b bd c1 a5 15 0d c2 f7 00 80 00 00 00 00 00 13 
0x0020		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0030		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 
0x0040		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0070		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

"netgear" is PCI but its XID is 04000000. I'll swap it this evening.

diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index 5821966..039fcc6 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -109,6 +109,7 @@ config R8169
 	select CRC32
 	select NET_CORE
 	select MII
+	select EEPROM_93CX6
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 27c358c..b909475 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -28,6 +28,7 @@
 #include <linux/firmware.h>
 #include <linux/pci-aspm.h>
 #include <linux/prefetch.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -310,6 +311,7 @@ enum rtl_registers {
 #define	RXCFG_DMA_SHIFT			8
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
+#define EEPROM_9356_SELECT		(1 << 6)
 
 	RxMissed	= 0x4c,
 	Cfg9346		= 0x50,
@@ -450,9 +452,16 @@ enum rtl_register_content {
 	NPQ		= 0x40,		/* Poll cmd on the low prio queue */
 	FSWInt		= 0x01,		/* Forced software interrupt */
 
-	/* Cfg9346Bits */
-	Cfg9346_Lock	= 0x00,
+	/* Cfg9346 operating mode register p.23 */
 	Cfg9346_Unlock	= 0xc0,
+	Cfg9346_Prog	= 0x80,
+	Cfg9346_Auto	= 0x80,
+	Cfg9346_Lock	= 0x00,
+	/* Sub-mode bits in Programming or Auto-load mode. */
+	Cfg9346_CS	= 0x08,		/* Chip Select */
+	Cfg9346_SK	= 0x04,		/* Serial Data Clock */
+	Cfg9346_DI	= 0x02,		/* Data In (going into the eeprom) */
+	Cfg9346_DO	= 0x01,		/* Data Out (coming from the eeprom) */
 
 	/* rx_mode_bits */
 	AcceptErr	= 0x20,
@@ -751,6 +760,8 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	struct eeprom_93cx6 eeprom;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1702,6 +1713,58 @@ static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
 	return mii_ethtool_gset(&tp->mii, cmd);
 }
 
+static int rtl_get_eeprom_len(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	return tp->eeprom.size;
+}
+
+static void eeprom_cmd_start(void __iomem *ioaddr)
+{
+	RTL_W8(Cfg9346, Cfg9346_Prog);
+}
+
+static void eeprom_cmd_end(void __iomem *ioaddr)
+{
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
+static int rtl_get_eeprom(struct net_device *dev, struct ethtool_eeprom *ee,
+			  u8 *data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct eeprom_93cx6 *eeprom = &tp->eeprom;
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 offset = ee->offset;
+	u32 len = ee->len;
+	u16 reg;
+
+	rtl_lock_work(tp);
+
+	eeprom_cmd_start(ioaddr);
+
+	if (offset & 0x1) {
+		eeprom_93cx6_read(eeprom, offset >> 1, &reg);
+		*data++ = reg >> 8;
+		offset++;
+		len--;
+	}
+
+	eeprom_93cx6_multiread(eeprom, offset >> 1,  (__le16 *)data, len >> 1);
+
+	if (len & 0x1) {
+		eeprom_93cx6_read(eeprom, (offset >> 1) + (len >> 1) + 1, &reg);
+		data[len] = reg;
+	}
+
+	eeprom_cmd_end(ioaddr);
+
+	rtl_unlock_work(tp);
+
+	return 0;
+}
+
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1844,6 +1907,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
+	.get_eeprom_len		= rtl_get_eeprom_len,
+	.get_eeprom		= rtl_get_eeprom,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 	.get_msglevel		= rtl8169_get_msglevel,
@@ -5803,6 +5868,63 @@ static int rtl8169_suspend(struct device *device)
 	return 0;
 }
 
+static void rtl_93cx6_register_read(struct eeprom_93cx6 *eeprom)
+{
+	struct net_device *dev = eeprom->data;
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	u8 reg;
+
+	reg = RTL_R8(Cfg9346);
+
+	eeprom->reg_data_in     = reg & Cfg9346_DI;
+	eeprom->reg_data_out    = reg & Cfg9346_DO;
+	eeprom->reg_data_clock  = reg & Cfg9346_SK;
+	eeprom->reg_chip_select = reg & Cfg9346_CS;
+}
+
+static void rtl_93cx6_register_write(struct eeprom_93cx6 *eeprom)
+{
+	struct net_device *dev = eeprom->data;
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	u8 reg = Cfg9346_Prog;
+
+	if (eeprom->reg_data_in)
+		reg |= Cfg9346_DI;
+	if (eeprom->reg_data_out)
+		reg |= Cfg9346_DO;
+	if (eeprom->reg_data_clock)
+		reg |= Cfg9346_SK;
+	if (eeprom->reg_chip_select)
+		reg |= Cfg9346_CS;
+
+	RTL_W8(Cfg9346, reg);
+	/* PCI commit */
+	RTL_R8(ChipCmd);
+	/* This is not a posting bug band-aid: the eeprom wants ~250 ns. */
+	ndelay(250);
+}
+
+static void rtl_init_eeprom(struct net_device *dev, struct rtl8169_private *tp)
+{
+	struct eeprom_93cx6 *eeprom = &tp->eeprom;
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	eeprom->data = dev;
+
+	eeprom->register_read  = rtl_93cx6_register_read;
+	eeprom->register_write = rtl_93cx6_register_write;
+
+	if (RTL_R32(RxConfig) & EEPROM_9356_SELECT) {
+		eeprom->width = PCI_EEPROM_WIDTH_93C56;
+		eeprom->size = 256;
+	} else {
+		eeprom->width = PCI_EEPROM_WIDTH_93C46;
+		eeprom->size = 128;
+	}
+}
+
 static void __rtl8169_resume(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -6243,6 +6365,8 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
 
+	rtl_init_eeprom(dev, tp);
+
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index e50f98b..d6e9cef 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -63,6 +63,7 @@ struct eeprom_93cx6 {
 	void (*register_write)(struct eeprom_93cx6 *eeprom);
 
 	int width;
+	int size;
 
 	char drive_data;
 	char reg_data_in;
-- 
Ueimor
