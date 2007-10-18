From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 00/13] r8169: pull request for 'upstream-jeff' branch
Date: Thu, 18 Oct 2007 22:48:46 +0200
Message-ID: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51001 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750911AbXJRUxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 16:53:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'upstream-jeff' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff

to get the changes below.

Following mails on netdev describe each patch.

Distance from 'master' (d85714d81cc0408daddb68c10f7fd69eafe7c213)
-----------------------------------------------------------------

7da97ec96a0934319c7fbedd3d38baf533e20640
a3f8067186c8d8459a20644b690f3a02131a3e37
a441d7b6bf3386c5b384685151a1cea921658819
867763c113494106574a64dc81175d66741a01cb
5615d9f1b9f5221d5b69dfa3722c16918c896cdd
e179bb7b437f4bd726e9ea9b08aff2fa4a530c1a
e3cf0cc09141ddef9d75a984c0d286040f1f2743
bc1660b57021b91f4adcb8fd06fe7bbecade3a8b
cebf8cc79ec776a2f35b5912cf4eb41439a2cfda
fbac58fcde6bbbd33c45870eb16f17795660093a
f23e7fdad166a4968f1f7f56964b75acfdcf57a4
53edbecd589520833a89b57af1ee636fdc7544a5
06fa73589f79e58e52e6a0329594fb42f8c6d277

Diffstat
--------

 drivers/net/r8169.c |  406 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 265 insertions(+), 141 deletions(-)

Shortlog
--------

Francois Romieu (11):
      r8169: convert bitfield to plain enum mask
      r8169: MSI support
      r8169: remove private net_device_stats structure
      r8169: use the existing symbolic name of vendor PCI ID 0x1259
      r8169: add MAC identifiers
      r8169: remove dead wood
      r8169: make room for more phy init changes
      r8169: phy init for the 8168
      r8169: phy init cleanup
      r8169: update the phy init for the 8168C
      r8169: more phy init for the 8168

Joe Perches (2):
      r8169: add KERN_DEBUG to dprintk (trivial)
      r8169: KERN_XXX vs PFX (trivial)

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..e8960f2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -44,7 +44,8 @@
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
 		#expr,__FILE__,__FUNCTION__,__LINE__);		\
 	}
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
+#define dprintk(fmt, args...) \
+	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
 #define dprintk(fmt, args...)	do {} while (0)
@@ -111,19 +112,15 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
-	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
-	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
-	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
-	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
-};
-
-enum phy_version {
-	RTL_GIGA_PHY_VER_C = 0x03, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_D = 0x04, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
-	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
-	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101 ?
+	RTL_GIGA_MAC_VER_15 = 0x0f, // 8101 ?
+	RTL_GIGA_MAC_VER_16 = 0x11, // 8101Ec
+	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
+	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
+	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
+	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -144,7 +141,12 @@ static const struct {
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
 	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, 0xff7e1880), // PCI-E 8139
-	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880)  // PCI-E 8139
+	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880), // PCI-E 8139
+	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_17, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -165,7 +167,7 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
-	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
@@ -277,6 +279,7 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -380,17 +383,20 @@ struct ring_info {
 	u8		__pad[sizeof(void *) - sizeof(u32)];
 };
 
+enum features {
+	RTL_FEATURE_WOL	= (1 << 0),
+	RTL_FEATURE_MSI	= (1 << 1),
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
 	int mac_version;
-	int phy_version;
 	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
 	u32 dirty_rx;
@@ -420,7 +426,7 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
-	unsigned wol_enabled : 1;
+	unsigned features;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -626,7 +632,10 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	tp->wol_enabled = (wol->wolopts) ? 1 : 0;
+	if (wol->wolopts)
+		tp->features |= RTL_FEATURE_WOL;
+	else
+		tp->features &= ~RTL_FEATURE_WOL;
 
 	spin_unlock_irq(&tp->lock);
 
@@ -707,7 +716,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		/* This tweak comes straight from Realtek's driver. */
 		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_13)) {
+		    ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+		     (tp->mac_version == RTL_GIGA_MAC_VER_16))) {
 			auto_nego = ADVERTISE_100HALF | ADVERTISE_CSMA;
 		}
 	}
@@ -715,7 +725,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 	/* The 8100e/8101e do Fast Ethernet only. */
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
 		    netif_msg_link(tp)) {
 			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
@@ -726,7 +737,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
@@ -1104,26 +1116,51 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	 */
 	const struct {
 		u32 mask;
+		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		{ 0x38800000,	RTL_GIGA_MAC_VER_15 },
-		{ 0x38000000,	RTL_GIGA_MAC_VER_12 },
-		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
-		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
-		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
-		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
-		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
-		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
-		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
-		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
-		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
+		/* 8168B family. */
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
+		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+
+		/* 8168B family. */
+		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
+		{ 0x7cf00000, 0x38500000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x38000000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
+
+		/* 8101 family. */
+		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
+		/* FIXME: where did these entries come from ? -- FR */
+		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
+		{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
+
+		/* 8110 family. */
+		{ 0xfc800000, 0x98000000,	RTL_GIGA_MAC_VER_06 },
+		{ 0xfc800000, 0x18000000,	RTL_GIGA_MAC_VER_05 },
+		{ 0xfc800000, 0x10000000,	RTL_GIGA_MAC_VER_04 },
+		{ 0xfc800000, 0x04000000,	RTL_GIGA_MAC_VER_03 },
+		{ 0xfc800000, 0x00800000,	RTL_GIGA_MAC_VER_02 },
+		{ 0xfc800000, 0x00000000,	RTL_GIGA_MAC_VER_01 },
+
+		{ 0x00000000, 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0xfc800000;
-	while ((reg & p->mask) != p->mask)
+	reg = RTL_R32(TxConfig);
+	while ((reg & p->mask) != p->val)
 		p++;
 	tp->mac_version = p->mac_version;
+
+	if (p->mask == 0x00000000) {
+		struct pci_dev *pdev = tp->pci_dev;
+
+		dev_info(&pdev->dev, "unknown MAC (%08x)\n", reg);
+	}
 }
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
@@ -1131,54 +1168,21 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_get_phy_version(struct rtl8169_private *tp,
-				    void __iomem *ioaddr)
-{
-	const struct {
-		u16 mask;
-		u16 set;
-		int phy_version;
-	} phy_info[] = {
-		{ 0x000f, 0x0002, RTL_GIGA_PHY_VER_G },
-		{ 0x000f, 0x0001, RTL_GIGA_PHY_VER_F },
-		{ 0x000f, 0x0000, RTL_GIGA_PHY_VER_E },
-		{ 0x0000, 0x0000, RTL_GIGA_PHY_VER_D } /* Catch-all */
-	}, *p = phy_info;
+struct phy_reg {
 	u16 reg;
+	u16 val;
+};
 
-	reg = mdio_read(ioaddr, MII_PHYSID2) & 0xffff;
-	while ((reg & p->mask) != p->set)
-		p++;
-	tp->phy_version = p->phy_version;
-}
-
-static void rtl8169_print_phy_version(struct rtl8169_private *tp)
+static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
 {
-	struct {
-		int version;
-		char *msg;
-		u32 reg;
-	} phy_print[] = {
-		{ RTL_GIGA_PHY_VER_G, "RTL_GIGA_PHY_VER_G", 0x0002 },
-		{ RTL_GIGA_PHY_VER_F, "RTL_GIGA_PHY_VER_F", 0x0001 },
-		{ RTL_GIGA_PHY_VER_E, "RTL_GIGA_PHY_VER_E", 0x0000 },
-		{ RTL_GIGA_PHY_VER_D, "RTL_GIGA_PHY_VER_D", 0x0000 },
-		{ 0, NULL, 0x0000 }
-	}, *p;
-
-	for (p = phy_print; p->msg; p++) {
-		if (tp->phy_version == p->version) {
-			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
-			return;
-		}
+	while (len-- > 0) {
+		mdio_write(ioaddr, regs->reg, regs->val);
+		regs++;
 	}
-	dprintk("phy_version == Unknown\n");
 }
 
-static void rtl8169_hw_phy_config(struct net_device *dev)
+static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	struct {
 		u16 regs[5]; /* Beware of bit-sign propagation */
 	} phy_magic[5] = { {
@@ -1211,33 +1215,9 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	}, *p = phy_magic;
 	unsigned int i;
 
-	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
-		return;
-
-	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
-	dprintk("Do final_reg2.cfg\n");
-
-	/* Shazam ! */
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
-		mdio_write(ioaddr, 31, 0x0002);
-		mdio_write(ioaddr,  1, 0x90d0);
-		mdio_write(ioaddr, 31, 0x0000);
-		return;
-	}
-
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
-		return;
-
-	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
-	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
-	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
+	mdio_write(ioaddr, 0x1f, 0x0001);		//w 31 2 0 1
+	mdio_write(ioaddr, 0x15, 0x1000);		//w 21 15 0 1000
+	mdio_write(ioaddr, 0x18, 0x65c7);		//w 24 15 0 65c7
 	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
 
 	for (i = 0; i < ARRAY_SIZE(phy_magic); i++, p++) {
@@ -1250,7 +1230,115 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 1); //w 4 11 11 1
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0); //w 4 11 11 0
 	}
-	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
+	mdio_write(ioaddr, 0x1f, 0x0000); //w 31 2 0 0
+}
+
+static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0002 },
+		{ 0x01, 0x90d0 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x1d, 0x0f00 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x1ec8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x12, 0x2300 },
+		{ 0x1f, 0x0002 },
+		{ 0x00, 0x88d4 },
+		{ 0x01, 0x82b1 },
+		{ 0x03, 0x7002 },
+		{ 0x08, 0x9e30 },
+		{ 0x09, 0x01f0 },
+		{ 0x0a, 0x5500 },
+		{ 0x0c, 0x00c8 },
+		{ 0x1f, 0x0003 },
+		{ 0x12, 0xc096 },
+		{ 0x16, 0x000a },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x12, 0x2300 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x7eb8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl_hw_phy_config(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl8169_print_mac_version(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01:
+		break;
+	case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03:
+		rtl8169s_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_04:
+		rtl8169sb_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl8168b_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_18:
+		rtl8168cp_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_19:
+		rtl8168c_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_20:
+		rtl8168cx_hw_phy_config(ioaddr);
+		break;
+	default:
+		break;
+	}
 }
 
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -1262,7 +1350,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
-	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		return;
@@ -1297,8 +1384,7 @@ static inline void rtl8169_delete_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	del_timer_sync(timer);
@@ -1309,8 +1395,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -1362,7 +1447,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl8169_hw_phy_config(dev);
+	rtl_hw_phy_config(dev);
 
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
@@ -1457,6 +1542,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
+	unsigned msi;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1464,7 +1550,8 @@ static const struct rtl_cfg_info {
 		.align		= 0,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 0
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1472,7 +1559,8 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1480,10 +1568,39 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	}
 };
 
+/* Cfg9346_Unlock assumed. */
+static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
+			    const struct rtl_cfg_info *cfg)
+{
+	unsigned msi = 0;
+	u8 cfg2;
+
+	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	if (cfg->msi) {
+		if (pci_enable_msi(pdev)) {
+			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
+		} else {
+			cfg2 |= MSIEnable;
+			msi = RTL_FEATURE_MSI;
+		}
+	}
+	RTL_W8(Config2, cfg2);
+	return msi;
+}
+
+static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
+{
+	if (tp->features & RTL_FEATURE_MSI) {
+		pci_disable_msi(pdev);
+		tp->features &= ~RTL_FEATURE_MSI;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1596,10 +1713,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
-	rtl8169_get_phy_version(tp, ioaddr);
 
 	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
 
 	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
 		if (tp->mac_version == rtl_chip_info[i].mac_version)
@@ -1619,6 +1734,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
@@ -1686,7 +1802,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_unmap_5;
+		goto err_out_msi_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1709,7 +1825,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_unmap_5:
+err_out_msi_5:
+	rtl_disable_msi(pdev, tp);
 	iounmap(ioaddr);
 err_out_free_res_4:
 	pci_release_regions(pdev);
@@ -1730,6 +1847,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
+	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -1773,7 +1891,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
-	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+	retval = request_irq(dev->irq, rtl8169_interrupt,
+			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
 		goto err_release_ring_2;
@@ -1933,7 +2052,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+		dprintk("Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
 	}
@@ -2029,7 +2148,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		pci_write_config_word(pdev, 0x68, 0x00);
 		pci_write_config_word(pdev, 0x69, 0x08);
 	}
@@ -2259,7 +2379,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
-			tp->stats.tx_dropped++;
+			tp->dev->stats.tx_dropped++;
 		}
 	}
 	tp->cur_tx = tp->dirty_tx = 0;
@@ -2310,7 +2430,7 @@ static void rtl8169_reinit_task(struct work_struct *work)
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
 		if (net_ratelimit() && netif_msg_drv(tp)) {
-			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
+			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
 			       " Rescheduling.\n", dev->name, ret);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
@@ -2340,9 +2460,10 @@ static void rtl8169_reset_task(struct work_struct *work)
 		rtl8169_init_ring_indexes(tp);
 		rtl_hw_start(dev);
 		netif_wake_queue(dev);
+		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
 		if (net_ratelimit() && netif_msg_intr(tp)) {
-			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
+			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
 			       dev->name);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
@@ -2496,7 +2617,7 @@ err_stop:
 	netif_stop_queue(dev);
 	ret = NETDEV_TX_BUSY;
 err_update_stats:
-	tp->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	goto out;
 }
 
@@ -2571,8 +2692,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		if (status & DescOwn)
 			break;
 
-		tp->stats.tx_bytes += len;
-		tp->stats.tx_packets++;
+		dev->stats.tx_bytes += len;
+		dev->stats.tx_packets++;
 
 		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
 
@@ -2672,14 +2793,14 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				       "%s: Rx ERROR. status = %08x\n",
 				       dev->name, status);
 			}
-			tp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (status & RxCRC)
-				tp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
 				rtl8169_schedule_work(dev, rtl8169_reset_task);
-				tp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
@@ -2694,8 +2815,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			 * sized frames.
 			 */
 			if (unlikely(rtl8169_fragmented_frame(status))) {
-				tp->stats.rx_dropped++;
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_dropped++;
+				dev->stats.rx_length_errors++;
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 				continue;
 			}
@@ -2719,8 +2840,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				rtl8169_rx_skb(skb);
 
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 		}
 
 		/* Work around for AMD plateform. */
@@ -2881,7 +3002,7 @@ core_down:
 	rtl8169_asic_down(ioaddr);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
@@ -2984,7 +3105,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		mc_filter[0] = 0xffffffff;
 		mc_filter[1] = 0xffffffff;
 	}
@@ -3011,12 +3134,12 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 		RTL_W32(RxMissed, 0);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 #ifdef CONFIG_PM
@@ -3037,14 +3160,15 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
 
 out_pci_suspend:
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state),
+		(tp->features & RTL_FEATURE_WOL) ? 1 : 0);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
-- 
Ueimor
