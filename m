From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 2/5] r8169: add csi_opt
Date: Fri, 30 Mar 2012 14:33:01 +0800
Message-ID: <1333089184-1773-2-git-send-email-hayeswang@realtek.com>
References: <1333089184-1773-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:32940 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab2C3GaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 02:30:23 -0400
In-Reply-To: <1333089184-1773-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify the CSI relative functions by using csi_opt method.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  300 ++++++++++++++++++++++------------
 1 files changed, 194 insertions(+), 106 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3edb996..268ed51 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -717,6 +717,11 @@ struct rtl8169_private {
 		void (*disable)(struct rtl8169_private *);
 	} jumbo_ops;
 
+	struct csi_ops {
+		void (*write)(void __iomem *, int, int);
+		u32 (*read)(void __iomem *, int);
+	} csi_ops;
+
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -1079,40 +1084,6 @@ static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void rtl_csi_write(void __iomem *ioaddr, int addr, int value)
-{
-	unsigned int i;
-
-	RTL_W32(CSIDR, value);
-	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
-		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
-
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
-			break;
-		udelay(10);
-	}
-}
-
-static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
-{
-	u32 value = ~0x00;
-	unsigned int i;
-
-	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
-		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
-
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
-			value = RTL_R32(CSIDR);
-			break;
-		}
-		udelay(10);
-	}
-
-	return value;
-}
-
 static
 void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
 {
@@ -4209,22 +4180,100 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
 
-static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
+static void rtl_csi_write(struct rtl8169_private *tp, int addr, int value)
+{
+	if (tp->csi_ops.write)
+		tp->csi_ops.write(tp->mmio_addr, addr, value);
+}
+
+static u32 rtl_csi_read(struct rtl8169_private *tp, int addr)
+{
+	if (tp->csi_ops.read)
+		return tp->csi_ops.read(tp->mmio_addr, addr);
+	else
+		return ~0;
+}
+
+static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
 {
 	u32 csi;
 
-	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
-	rtl_csi_write(ioaddr, 0x070c, csi | bits);
+	csi = rtl_csi_read(tp, 0x070c) & 0x00ffffff;
+	rtl_csi_write(tp, 0x070c, csi | bits);
+}
+
+static void rtl_csi_access_enable_1(struct rtl8169_private *tp)
+{
+	rtl_csi_access_enable(tp, 0x17000000);
 }
 
-static void rtl_csi_access_enable_1(void __iomem *ioaddr)
+static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable(ioaddr, 0x17000000);
+	rtl_csi_access_enable(tp, 0x27000000);
 }
 
-static void rtl_csi_access_enable_2(void __iomem *ioaddr)
+static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
 {
-	rtl_csi_access_enable(ioaddr, 0x27000000);
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
+static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
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
+static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
+{
+	struct csi_ops *ops = &tp->csi_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01:
+	case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03:
+	case RTL_GIGA_MAC_VER_04:
+	case RTL_GIGA_MAC_VER_05:
+	case RTL_GIGA_MAC_VER_06:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_14:
+	case RTL_GIGA_MAC_VER_15:
+	case RTL_GIGA_MAC_VER_16:
+	case RTL_GIGA_MAC_VER_17:
+		ops->write	= NULL;
+		ops->read	= NULL;
+		break;
+
+	default:
+		ops->write	= r8169_csi_write;
+		ops->read	= r8169_csi_read;
+		break;
+	}
 }
 
 struct ephy_info {
@@ -4281,8 +4330,11 @@ static void rtl_enable_clock_request(struct pci_dev *pdev)
 	PktCntrDisable | \
 	Mac_dbgo_sel)
 
-static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
@@ -4291,17 +4343,22 @@ static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
 
-static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8168bb(ioaddr, pdev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_hw_start_8168bb(tp);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
-static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
 	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
@@ -4313,8 +4370,9 @@ static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
@@ -4323,16 +4381,19 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x07, 0,	0x2000 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -4341,9 +4402,12 @@ static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -4357,52 +4421,57 @@ static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168c_1[] = {
 		{ 0x02, 0x0800,	0x1000 },
 		{ 0x03, 0,	0x0002 },
 		{ 0x06, 0x0080,	0x0000 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168c_2[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x03, 0x0400,	0x0220 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_3(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8168c_2(ioaddr, pdev);
+	rtl_hw_start_8168c_2(tp);
 }
 
-static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_4(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	rtl_disable_clock_request(pdev);
 
@@ -4413,9 +4482,12 @@ static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168dp(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_1(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_1(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4424,8 +4496,10 @@ static void rtl_hw_start_8168dp(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_disable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168d_4[] = {
 		{ 0x0b, ~0,	0x48 },
 		{ 0x19, 0x20,	0x50 },
@@ -4433,7 +4507,7 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	int i;
 
-	rtl_csi_access_enable_1(ioaddr);
+	rtl_csi_access_enable_1(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4450,8 +4524,10 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_enable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_1[] = {
 		{ 0x00, 0x0200,	0x0100 },
 		{ 0x00, 0x0000,	0x0004 },
@@ -4468,7 +4544,7 @@ static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x0a, 0x0000,	0x0040 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
@@ -4485,14 +4561,16 @@ static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
-static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_2[] = {
 		{ 0x09, 0x0000,	0x0080 },
 		{ 0x19, 0x0000,	0x0224 }
 	};
 
-	rtl_csi_access_enable_1(ioaddr);
+	rtl_csi_access_enable_1(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
 
@@ -4523,8 +4601,10 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
-static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168f_1[] = {
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x08, 0x0001,	0x0002 },
@@ -4532,7 +4612,7 @@ static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x19, 0x0000,	0x0224 }
 	};
 
-	rtl_csi_access_enable_1(ioaddr);
+	rtl_csi_access_enable_1(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
@@ -4570,7 +4650,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -4601,67 +4680,67 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_11:
-		rtl_hw_start_8168bb(ioaddr, pdev);
+		rtl_hw_start_8168bb(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_12:
 	case RTL_GIGA_MAC_VER_17:
-		rtl_hw_start_8168bef(ioaddr, pdev);
+		rtl_hw_start_8168bef(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_18:
-		rtl_hw_start_8168cp_1(ioaddr, pdev);
+		rtl_hw_start_8168cp_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_19:
-		rtl_hw_start_8168c_1(ioaddr, pdev);
+		rtl_hw_start_8168c_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_20:
-		rtl_hw_start_8168c_2(ioaddr, pdev);
+		rtl_hw_start_8168c_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_21:
-		rtl_hw_start_8168c_3(ioaddr, pdev);
+		rtl_hw_start_8168c_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_22:
-		rtl_hw_start_8168c_4(ioaddr, pdev);
+		rtl_hw_start_8168c_4(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_23:
-		rtl_hw_start_8168cp_2(ioaddr, pdev);
+		rtl_hw_start_8168cp_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_24:
-		rtl_hw_start_8168cp_3(ioaddr, pdev);
+		rtl_hw_start_8168cp_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_27:
-		rtl_hw_start_8168d(ioaddr, pdev);
+		rtl_hw_start_8168d(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_28:
-		rtl_hw_start_8168d_4(ioaddr, pdev);
+		rtl_hw_start_8168d_4(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_31:
-		rtl_hw_start_8168dp(ioaddr, pdev);
+		rtl_hw_start_8168dp(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl_hw_start_8168e_1(ioaddr, pdev);
+		rtl_hw_start_8168e_1(tp);
 		break;
 	case RTL_GIGA_MAC_VER_34:
-		rtl_hw_start_8168e_2(ioaddr, pdev);
+		rtl_hw_start_8168e_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
-		rtl_hw_start_8168f_1(ioaddr, pdev);
+		rtl_hw_start_8168f_1(tp);
 		break;
 
 	default:
@@ -4688,8 +4767,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	PktCntrDisable | \
 	Mac_dbgo_sel)
 
-static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8102e_1[] = {
 		{ 0x01,	0, 0x6e65 },
 		{ 0x02,	0, 0x091f },
@@ -4702,7 +4783,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	u8 cfg1;
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(DBG_REG, FIX_NAK_1);
 
@@ -4719,9 +4800,12 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
-static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4729,15 +4813,16 @@ static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 }
 
-static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_3(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8102e_2(ioaddr, pdev);
+	rtl_hw_start_8102e_2(tp);
 
-	rtl_ephy_write(ioaddr, 0x03, 0xc2f9);
+	rtl_ephy_write(tp->mmio_addr, 0x03, 0xc2f9);
 }
 
-static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8105e_1[] = {
 		{ 0x07,	0, 0x4000 },
 		{ 0x19,	0, 0x0200 },
@@ -4761,9 +4846,11 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
 
-static void rtl_hw_start_8105e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8105e_2(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8105e_1(ioaddr, pdev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_hw_start_8105e_1(tp);
 	rtl_ephy_write(ioaddr, 0x1e, rtl_ephy_read(ioaddr, 0x1e) | 0x8000);
 }
 
@@ -4790,22 +4877,22 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
-		rtl_hw_start_8102e_1(ioaddr, pdev);
+		rtl_hw_start_8102e_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_08:
-		rtl_hw_start_8102e_3(ioaddr, pdev);
+		rtl_hw_start_8102e_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_09:
-		rtl_hw_start_8102e_2(ioaddr, pdev);
+		rtl_hw_start_8102e_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_29:
-		rtl_hw_start_8105e_1(ioaddr, pdev);
+		rtl_hw_start_8105e_1(tp);
 		break;
 	case RTL_GIGA_MAC_VER_30:
-		rtl_hw_start_8105e_2(ioaddr, pdev);
+		rtl_hw_start_8105e_2(tp);
 		break;
 	}
 
@@ -6199,6 +6286,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 	rtl_init_jumbo_ops(tp);
+	rtl_init_csi_ops(tp);
 
 	rtl8169_print_mac_version(tp);
 
-- 
1.7.7.6
