From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 9/13] r8169: sync existing 8168 device hardware start
	sequences with vendor driver
Date: Sun, 29 Jun 2008 16:46:15 +0200
Message-ID: <20080629144615.GJ1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46542 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760236AbYF2Oqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:46:37 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This part of the driver should be reasonably in line with Realtek's
8.006.00 driver.

I have left some bits related to jumbo frame and optional features
aside for now.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |  161 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 161 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 46bdcb9..d8296fc 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -527,6 +527,72 @@ static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
 	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
 }
 
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
@@ -2166,33 +2232,128 @@ static void rtl8168_tx_performance_tweak(struct pci_dev *pdev,
 	pci_write_config_byte(pdev, reg, ctl);
 }
 
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
 static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
+
 	rtl8168_tx_performance_tweak(pdev, 0x69, 0x58);
 }
 
 static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	rtl_hw_start_8168bb(ioaddr, pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
 static void __rtl_hw_start_8168cpx(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
 	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+
+	rtl8168_disable_clock_request(pdev);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
 }
 
 static void rtl_hw_start_8168c(void __iomem *ioaddr, struct pci_dev *pdev)
 {
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
 	__rtl_hw_start_8168cpx(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 {
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
 	__rtl_hw_start_8168cpx(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168cx(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	static struct ephy_info e_info_8168cx[] = {
+		{ 0x01, 0,		1 <<  0 },
+		{ 0x03, 1 << 10,	1 <<  9 | 1 << 5 }
+	};
+
+	rtl8168_csi_access_enable(ioaddr);
+
+	rtl8168_ephy_init(ioaddr, e_info_8168cx, ARRAY_SIZE(e_info_8168cx));
+
 	__rtl_hw_start_8168cpx(ioaddr, pdev);
 }
 
-- 
1.5.3.3

