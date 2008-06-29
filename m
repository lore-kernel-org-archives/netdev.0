From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [RFT 0/13] r8169 branch info
Date: Sun, 29 Jun 2008 16:38:17 +0200
Message-ID: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52830 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758308AbYF2OjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:39:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'r8169' branch in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169

contains the changes below.

The bulk of the changes reduces the gap with Realtek's driver for the
8168 devices. Let aside the first two patches of the serie I am quite
comfortable with, it needs some seriously wider testing. The serie could
make the life of some 8168 users better but, if anything, the changes
have been worked so that any regression can be easily pinpointed.

I have not experienced any noticeable change of behavior with either
a PCI-E 8168b or an old PCI 8169 (resp. XID 38000000 and 04000000 in
dmesg).

The patchkit is available at:

http://userweb.kernel.org/~romieu/r8169/2.6.26-rc6

Please test it. There are more changes to come.

Patches #1 .. #13 will be sent for review to netdev only.

Thank you for your attention.

Distance from 'davem-next' (be0976be9148f31ee0d1997354c3e30ff8d07587)
--------------------------------------------------------------------

04c3064c78b6294f46da00fdba62286ae197d873
7b1d25c8e676bbe494860cc0d2f038c7dbf861ba
537fdb9532875e565a957b7593c38d13ddc19327
86329ffbd8752b82c5c428f36d7eca9355d2df73
d059fc20c4e1af7825c7f42d958911900bd25c81
02a0733ad8624bfd80dc90af4ae4e44d2c6c7b93
278f407059d905b61485ec90544c563908a4d2f9
c110685bda5f480d0a9dca016f88329c8db52ba6
62c2ff92dd76c5f2af3425151c115c3da62fb5fb
674ab49e3a8d63f2a07f6ef71348e5f08aa2ddbe
f7c0f2ee1156a3329cdf7c8cc504ac4e557292f6
865c652d6be9929927cabdc54b137b7541eb6612
1087f4f4af302e6e2fa40dd741f306444d90bece

Diffstat
--------

 drivers/net/Kconfig |   16 +--
 drivers/net/r8169.c |  607 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 485 insertions(+), 138 deletions(-)

Shortlog
--------

Francois Romieu (13):
      r8169: multicast register update (sync with Realtek's 8.004.00 8168 driver)
      r8169: remove non-napi code
      r8169: update phy init parameters
      r8169: new phy init parameters for the 8168b
      r8169: shuffle some registers handling around (8168 operation only)
      r8169: add 8168 registers description
      r8169: make room for more specific 8168 hardware start procedure
      r8169: Tx performance tweak
      r8169: sync existing 8168 device hardware start sequences with vendor driver
      r8169: add a new 8168 flavor
      r8169: add a new 8168 flavor (bis)
      r8169: add a new 8168 flavor (ter)
      r8169: change default behavior for mildly identified 8168c chipsets

Patch
-----

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d85b9d0..8492591 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2122,27 +2122,13 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config R8169_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on R8169 && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config R8169_VLAN
 	bool "VLAN support"
 	depends on R8169 && VLAN_8021Q
 	---help---
 	  Say Y here for the r8169 driver to support the functions required
 	  by the kernel 802.1Q code.
-	  
+
 	  If in doubt, say Y.
 
 config SB1250_MAC
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6572425..84e6fc4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -28,13 +28,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#ifdef CONFIG_R8169_NAPI
-#define NAPI_SUFFIX	"-NAPI"
-#else
-#define NAPI_SUFFIX	""
-#endif
-
-#define RTL8169_VERSION "2.2LK" NAPI_SUFFIX
+#define RTL8169_VERSION "2.3LK-NAPI"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -57,16 +51,6 @@
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
 
-#ifdef CONFIG_R8169_NAPI
-#define rtl8169_rx_skb			netif_receive_skb
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
-#define rtl8169_rx_quota(count, quota)	min(count, quota)
-#else
-#define rtl8169_rx_skb			netif_rx
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
-#define rtl8169_rx_quota(count, quota)	count
-#endif
-
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static const int max_interrupt_work = 20;
 
@@ -120,7 +104,10 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
 	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
-	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
+	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
+	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
+	RTL_GIGA_MAC_VER_23 = 0x17  // 8168CP
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -146,7 +133,10 @@ static const struct {
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -212,9 +202,6 @@ enum rtl_registers {
 	Config5		= 0x56,
 	MultiIntr	= 0x5c,
 	PHYAR		= 0x60,
-	TBICSR		= 0x64,
-	TBI_ANAR	= 0x68,
-	TBI_LPAR	= 0x6a,
 	PHYstatus	= 0x6c,
 	RxMaxSize	= 0xda,
 	CPlusCmd	= 0xe0,
@@ -228,6 +215,32 @@ enum rtl_registers {
 	FuncForceEvent	= 0xfc,
 };
 
+enum rtl8110_registers {
+	TBICSR			= 0x64,
+	TBI_ANAR		= 0x68,
+	TBI_LPAR		= 0x6a,
+};
+
+enum rtl8168_registers {
+	CSIDR			= 0x64,
+	CSIAR			= 0x68,
+#define	CSIAR_FLAG			0x80000000
+#define	CSIAR_WRITE_CMD			0x80000000
+#define	CSIAR_BYTE_ENABLE		0x0f
+#define	CSIAR_BYTE_ENABLE_SHIFT		12
+#define	CSIAR_ADDR_MASK			0x0fff
+
+	EPHYAR			= 0x80,
+#define	EPHYAR_FLAG			0x80000000
+#define	EPHYAR_WRITE_CMD		0x80000000
+#define	EPHYAR_REG_MASK			0x1f
+#define	EPHYAR_REG_SHIFT		16
+#define	EPHYAR_DATA_MASK		0xffff
+	DBG_REG			= 0xd1,
+#define	FIX_NAK_1			(1 << 4)
+#define	FIX_NAK_2			(1 << 3)
+};
+
 enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
@@ -281,7 +294,13 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	LEDS1		= (1 << 7),
+	LEDS0		= (1 << 6),
 	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
+	Speed_down	= (1 << 4),
+	MEMMAP		= (1 << 3),
+	IOMAP		= (1 << 2),
+	VPD		= (1 << 1),
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -291,6 +310,7 @@ enum rtl_register_content {
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
+	Beacon_en	= (1 << 0),	/* 8168 only. Reserved in the 8168b */
 
 	/* Config5 register p.27 */
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
@@ -308,7 +328,17 @@ enum rtl_register_content {
 	TBINwComplete	= 0x01000000,
 
 	/* CPlusCmd p.31 */
+	EnableBist	= (1 << 15),	// 8168
+	Mac_dbgo_oe	= (1 << 14),	// 8168
+	Normal_mode	= (1 << 13),	// 8168 (unused)
+	Force_half_dup	= (1 << 12),	// 8168
+	Force_rxflow_en	= (1 << 11),	// 8168
+	Force_txflow_en	= (1 << 10),	// 8168
+	Cxpl_dbg_sel	= (1 << 9),	// 8168c
+	ASF		= (1 << 8),	// 8168b
 	PktCntrDisable	= (1 << 7),	// 8168
+	Mac_dbgo_sel	= 0x001c,	// 8168
+
 	RxVlan		= (1 << 6),
 	RxChkSum	= (1 << 5),
 	PCIDAC		= (1 << 4),
@@ -394,9 +424,7 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
-#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
-#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -458,10 +486,7 @@ static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
-
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget);
-#endif
 
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
@@ -503,6 +528,77 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+{
+	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+}
+
+static void rtl8168_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
+		(reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(EPHYAR) & EPHYAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u16 rtl8168_ephy_read(void __iomem *ioaddr, int reg_addr)
+{
+	u16 value = 0xffff;
+	unsigned int i;
+
+	RTL_W32(EPHYAR, (reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(EPHYAR) & EPHYAR_FLAG) {
+			value = RTL_R32(EPHYAR) & EPHYAR_DATA_MASK;
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
+static void rtl8168_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 rtl8168_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value = RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -843,10 +939,11 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 			       struct sk_buff *skb)
 {
 	u32 opts2 = le32_to_cpu(desc->opts2);
+	struct vlan_group *vlgrp = tp->vlgrp;
 	int ret;
 
-	if (tp->vlgrp && (opts2 & RxVlanTag)) {
-		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp, swab16(opts2 & 0xffff));
+	if (vlgrp && (opts2 & RxVlanTag)) {
+		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -1123,11 +1220,15 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		/* 8168B family. */
-		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		/* 8168C family. */
+		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
+		{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
-		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
+		{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_22 },
 
 		/* 8168B family. */
 		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
@@ -1248,6 +1349,30 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0001);
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1277,26 +1402,87 @@ static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0003 },
 		{ 0x12, 0xc096 },
 		{ 0x16, 0x000a },
-		{ 0x1f, 0x0000 }
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+		{ 0x09, 0x2000 },
+		{ 0x09, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
+		{ 0x03, 0x802f },
+		{ 0x02, 0x4f02 },
+		{ 0x01, 0x0409 },
+		{ 0x00, 0xf099 },
+		{ 0x04, 0x9800 },
+		{ 0x04, 0x9000 },
+		{ 0x1d, 0x3d98 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x7eb8 },
+		{ 0x06, 0x0761 },
 		{ 0x1f, 0x0003 },
 		{ 0x16, 0x0f0a },
-		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8168cz_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x12, 0x2300 },
+		{ 0x1d, 0x3d98 },
 		{ 0x1f, 0x0002 },
 		{ 0x0c, 0x7eb8 },
+		{ 0x06, 0x5461 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
 		{ 0x1f, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8168cw_hw_phy_config(void __iomem *ioaddr)
+{
+	rtl8168cz_hw_phy_config(ioaddr);
+}
+
+static void rtl8168cy_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x1d, 0x3d98 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
 static void rtl_hw_phy_config(struct net_device *dev)
@@ -1316,6 +1502,15 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_11:
+		rtl8168bb_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_12:
+		rtl8168bef_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_17:
+		rtl8168bef_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
@@ -1325,6 +1520,16 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_20:
 		rtl8168cx_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_21:
+		rtl8168cz_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_22:
+		rtl8168cw_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_23:
+		rtl8168cy_hw_phy_config(ioaddr);
+		break;
+
 	default:
 		break;
 	}
@@ -1764,9 +1969,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = rtl8169_change_mtu;
 	dev->set_mac_address = rtl_set_mac_address;
 
-#ifdef CONFIG_R8169_NAPI
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
-#endif
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -1887,9 +2090,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2083,12 +2284,169 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
+static void rtl8168_tx_performance_tweak(struct pci_dev *pdev,
+					 unsigned int reg, u8 force)
+{
+	u8 ctl;
+
+	pci_read_config_byte(pdev, reg, &ctl);
+	ctl = (ctl & ~0x70) | force;
+	pci_write_config_byte(pdev, reg, ctl);
+}
+
+static void rtl8168_disable_clock_request(struct pci_dev *pdev)
+{
+	pci_write_config_byte(pdev, 0x81, 0x00);
+}
+
+/*
+ * Taken from Realtek's 8168 driver.
+ *
+ * There is not much description for these bits in the datasheet.
+ * Note that Mac_dbgo_sel forces the PCI DAC bit to zero. Tnis should
+ * be taken into consideration to implement proper DAC support on
+ * the 8168 family. -- FR
+ */
+static void rtl8168c_cpcmd_quirk(void __iomem *ioaddr)
+{
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~(EnableBist | Mac_dbgo_oe |
+		Force_half_dup | Force_rxflow_en | Force_txflow_en |
+		Cxpl_dbg_sel | ASF | PktCntrDisable | Mac_dbgo_sel));
+}
+
+static void rtl8168_csi_access_enable(void __iomem *ioaddr)
+{
+	u32 csi;
+
+	csi = rtl8168_csi_read(ioaddr, 0x070c) & 0x00ffffff;
+	rtl8168_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+}
+
+struct ephy_info {
+	unsigned int offset;
+	u16 mask;
+	u16 bits;
+};
+
+static void rtl8168_ephy_init(void __iomem *ioaddr, struct ephy_info *e,
+			      int len)
+{
+	u16 w;
+
+	while (len-- > 0) {
+		w = (rtl8168_ephy_read(ioaddr, e->offset) & ~e->mask) | e->bits;
+		rtl8168_ephy_write(ioaddr, e->offset, w);
+		e++;
+	}
+}
+
+static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
+
+	rtl8168_tx_performance_tweak(pdev, 0x69, 0x58);
+}
+
+static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8168bb(ioaddr, pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
+}
+
+static void __rtl_hw_start_8168cpx(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+
+	rtl8168_disable_clock_request(pdev);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
+}
+
+static void rtl_hw_start_8168c(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168c[] = {
+		{ 0x02, 1 << 11,	1 << 12 },
+		{ 0x03, 0,		1 <<  1 },
+		{ 0x06, 1 <<  7,	0 }
+	};
+
+	rtl8168_csi_access_enable(ioaddr);
+
+	RTL_W8(DBG_REG, 0x0e | FIX_NAK_1 | FIX_NAK_2);
+
+	rtl8168_ephy_init(ioaddr, e_info_8168c, ARRAY_SIZE(e_info_8168c));
+
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168cp[] = {
+		{ 0x01, 0,		1 <<  0 },
+		{ 0x02, 1 << 11,	1 << 12 },
+		{ 0x03, 0,		1 <<  6 | 1 << 1 },
+		{ 0x06, (1 <<  7),	0 },
+		{ 0x07, 0,		1 << 13 }
+	};
+
+	rtl8168_csi_access_enable(ioaddr);
+
+	rtl8168_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cx(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168cx[] = {
+		{ 0x01, 0,		1 <<  0 },
+		{ 0x03, 1 << 10,	1 <<  9 | 1 << 5 }
+	};
+
+	rtl8168_csi_access_enable(ioaddr);
+
+	rtl8168_ephy_init(ioaddr, e_info_8168cx, ARRAY_SIZE(e_info_8168cx));
+
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cz(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8168cx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cw(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_csi_access_enable(ioaddr);
+
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cy(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 ctl;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -2096,17 +2454,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
-
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	/* Tx performance tweak. */
-	pci_read_config_byte(pdev, 0x69, &ctl);
-	ctl = (ctl & ~0x70) | 0x50;
-	pci_write_config_byte(pdev, 0x69, ctl);
-
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
@@ -2117,16 +2468,59 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_set_rx_mode(dev);
 
-	RTL_R8(IntrMask);
+	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+		(InterFrameGap << TxInterFrameGapShift));
 
 	RTL_W32(RxMissed, 0);
 
-	rtl_set_rx_mode(dev);
+	RTL_R8(IntrMask);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_11:
+		rtl_hw_start_8168bb(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl_hw_start_8168bef(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_18:
+		rtl_hw_start_8168cp(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_19:
+		rtl_hw_start_8168c(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_20:
+		rtl_hw_start_8168cx(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_21:
+		rtl_hw_start_8168cz(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_22:
+		rtl_hw_start_8168cw(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_23:
+		rtl_hw_start_8168cy(ioaddr, pdev);
+	break;
+
+	default:
+		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
+			dev->name, tp->mac_version);
+	break;
+	}
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	RTL_W16(IntrMask, tp->intr_event);
@@ -2197,9 +2591,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 	if (ret < 0)
 		goto out;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2391,17 +2783,13 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
 	tp->intr_mask = 0xffff;
 	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
-#endif
 }
 
 static void rtl8169_reinit_task(struct work_struct *work)
@@ -2767,7 +3155,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left = rtl8169_rx_quota(rx_left, budget);
+	rx_left = min(rx_left, budget);
 
 	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
@@ -2829,7 +3217,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			skb->protocol = eth_type_trans(skb, dev);
 
 			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-				rtl8169_rx_skb(skb);
+				netif_receive_skb(skb);
 
 			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
@@ -2869,87 +3257,61 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
-	int boguscnt = max_interrupt_work;
 	void __iomem *ioaddr = tp->mmio_addr;
-	int status;
 	int handled = 0;
+	int status;
 
-	do {
-		status = RTL_R16(IntrStatus);
+	status = RTL_R16(IntrStatus);
 
-		/* hotplug/major error/no more work/shared irq */
-		if ((status == 0xFFFF) || !status)
-			break;
+	/* hotplug/major error/no more work/shared irq */
+	if ((status == 0xffff) || !status)
+		goto out;
 
-		handled = 1;
+	handled = 1;
 
-		if (unlikely(!netif_running(dev))) {
-			rtl8169_asic_down(ioaddr);
-			goto out;
-		}
+	if (unlikely(!netif_running(dev))) {
+		rtl8169_asic_down(ioaddr);
+		goto out;
+	}
 
-		status &= tp->intr_mask;
-		RTL_W16(IntrStatus,
-			(status & RxFIFOOver) ? (status | RxOverflow) : status);
+	status &= tp->intr_mask;
+	RTL_W16(IntrStatus,
+		(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if (!(status & tp->intr_event))
-			break;
+	if (!(status & tp->intr_event))
+		goto out;
 
-                /* Work around for rx fifo overflow */
-                if (unlikely(status & RxFIFOOver) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
-			netif_stop_queue(dev);
-			rtl8169_tx_timeout(dev);
-			break;
-		}
+	/* Work around for rx fifo overflow */
+	if (unlikely(status & RxFIFOOver) &&
+	    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		netif_stop_queue(dev);
+		rtl8169_tx_timeout(dev);
+		goto out;
+	}
 
-		if (unlikely(status & SYSErr)) {
-			rtl8169_pcierr_interrupt(dev);
-			break;
-		}
+	if (unlikely(status & SYSErr)) {
+		rtl8169_pcierr_interrupt(dev);
+		goto out;
+	}
 
-		if (status & LinkChg)
-			rtl8169_check_link_status(dev, tp, ioaddr);
+	if (status & LinkChg)
+		rtl8169_check_link_status(dev, tp, ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
-		if (status & tp->napi_event) {
-			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-			tp->intr_mask = ~tp->napi_event;
+	if (status & tp->napi_event) {
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		tp->intr_mask = ~tp->napi_event;
 
 		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
 			__netif_rx_schedule(dev, &tp->napi);
-			else if (netif_msg_intr(tp)) {
-				printk(KERN_INFO "%s: interrupt %04x in poll\n",
-				       dev->name, status);
-			}
-		}
-		break;
-#else
-		/* Rx interrupt */
-		if (status & (RxOK | RxOverflow | RxFIFOOver))
-			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
-
-		/* Tx interrupt */
-		if (status & (TxOK | TxErr))
-			rtl8169_tx_interrupt(dev, tp, ioaddr);
-#endif
-
-		boguscnt--;
-	} while (boguscnt > 0);
-
-	if (boguscnt <= 0) {
-		if (netif_msg_intr(tp) && net_ratelimit() ) {
-			printk(KERN_WARNING
-			       "%s: Too much work at interrupt!\n", dev->name);
+		else if (netif_msg_intr(tp)) {
+			printk(KERN_INFO "%s: interrupt %04x in poll\n",
+			       dev->name, status);
 		}
-		/* Clear all interrupt sources. */
-		RTL_W16(IntrStatus, 0xffff);
 	}
 out:
 	return IRQ_RETVAL(handled);
 }
 
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
@@ -2975,7 +3337,6 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 
 	return work_done;
 }
-#endif
 
 static void rtl8169_down(struct net_device *dev)
 {
@@ -2987,9 +3348,7 @@ static void rtl8169_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 core_down:
 	spin_lock_irq(&tp->lock);
@@ -3098,8 +3457,10 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		mc_filter[0] = 0xffffffff;
-		mc_filter[1] = 0xffffffff;
+		u32 data = mc_filter[0];
+
+		mc_filter[0] = swab32(mc_filter[1]);
+		mc_filter[1] = swab32(data);
 	}
 
 	RTL_W32(MAR0 + 0, mc_filter[0]);
-- 
Ueimor
