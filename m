From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH RFC] r8169: minimal rtl8111e-vl support
Date: Tue, 28 Jun 2011 23:44:10 +0200
Message-ID: <20110628214410.GA4163@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SLDf9lqlvOQaIe6s"
Cc: netdev@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53930 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab1F1V5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 17:57:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Mostly bits from version 8.023.00 of Realtek's own r8168 driver. It applies
on top of davem's net-next branch + a small, uninteresting attached patch.

I have given it a short testing w/o the new-format rtl8168e-3_0.0.1 firmware
and it is fairly encouraging.

The code is still incomplete :
- WoL needs some care. No difficulty here.
- rtl8168e_2_hw_phy_config imho deserves a few comments similar to those in
  rtl8168e_1_hw_phy_config. Hayes, can you take care of it ?
- I have excluded a set of completely unidentified registers / bits
  operations, for instance:
  - Config5
      BIT_0
  - Config2
      BIT_5
      BIT_7
  - TxConfig
      BIT_7
  - 0x1a
      BIT_2
      BIT_3
  - 0x1b
      0xf8 / 0x07
  - 0xb0,
      0xee480010
  - 0xd0
      BIT_6
  - 0xd3
      BIT_7
  - 0xf2
      BIT_6
  Either they are not needed or someone will have to name them adequately.
  Hayes ?
- Short packets apparently need to be checksummed by the driver (?) but
  the work-around seems strange. It is not clear to me what Realtek's
  driver is trying to achieve in hard_start_xmit. Hayes, can you elaborate ?

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  254 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 254 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f5b8d52..1b38a0f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -41,6 +41,7 @@
 #define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-2.fw"
 #define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-1.fw"
 #define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-2.fw"
+#define FIRMWARE_8168E_3	"rtl_nic/rtl8168e-3.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 
 #ifdef RTL8169_DEBUG
@@ -133,6 +134,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_31,
 	RTL_GIGA_MAC_VER_32,
 	RTL_GIGA_MAC_VER_33,
+	RTL_GIGA_MAC_VER_34,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -217,6 +219,8 @@ static const struct {
 		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
 	[RTL_GIGA_MAC_VER_33] =
 		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2),
+	[RTL_GIGA_MAC_VER_34] =
+		_R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3),
 };
 #undef _R
 
@@ -715,6 +719,76 @@ static int rtl8169_poll(struct napi_struct *napi, int budget);
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
+static void rtl_eri_cmd(void __iomem *ioaddr, int type, int addr, u32 cmd)
+{
+	int i;
+
+	RTL_W32(ERIAR, cmd | type | ERIAR_BYTEEN | addr);
+
+	for (i = 0; i < 10; i++) {
+		udelay(100);
+
+		if ((RTL_R32(ERIAR) ^ cmd) & ERIAR_FLAG)
+			break;
+	}
+}
+
+static u32 eri_data_mask[] = { 0x000000ff, 0x0000ffff, 0x00ffffff, 0xffffffff };
+
+u32 rtl_eri_read(void __iomem *ioaddr, int addr, int len, int type)
+{
+	int done = 0;
+	u32 val = 0;
+
+	BUG_ON((len > 4) || (len <= 0));
+
+	while ((len <= 4) && (len > 0)) {
+		int offset = addr % ERIAR_ADDR_BYTE_ALIGN;
+		int avail = ERIAR_ADDR_BYTE_ALIGN - offset;
+		u32 data;
+
+		addr &= ~(ERIAR_ADDR_BYTE_ALIGN - 1);
+
+		rtl_eri_cmd(ioaddr, type, addr, ERIAR_READ_CMD);
+
+		data = (RTL_R32(ERIDR) >> (8 * offset)) & eri_data_mask[len -1];
+		val |= data << (8 * done);
+		done += min(avail, len);
+		len -= done;
+		addr += ERIAR_ADDR_BYTE_ALIGN;
+	}
+
+	return val;
+}
+
+static void rtl_eri_write(void __iomem *ioaddr, int addr, int len, u32 val,
+			  int type)
+{
+	BUG_ON((len > 4) || (len <= 0));
+
+	while ((len <= 4) && (len > 0)) {
+		int offset = addr % ERIAR_ADDR_BYTE_ALIGN;
+		int avail = ERIAR_ADDR_BYTE_ALIGN - offset;
+		u32 data;
+		int done;
+
+		addr &= ~(ERIAR_ADDR_BYTE_ALIGN - 1);
+
+		data  = rtl_eri_read(ioaddr, addr, 4, type);
+		data &= ~(eri_data_mask[len - 1] << (8 * offset));
+		data |= val << (8 * offset);
+
+		RTL_W32(ERIDR, data);
+
+		rtl_eri_cmd(ioaddr, type, addr, ERIAR_WRITE_CMD);
+
+		done = min(avail, len);
+		val >>= 8 * done;
+		len -= done;
+		addr += ERIAR_ADDR_BYTE_ALIGN;
+	}
+}
+
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1641,6 +1715,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168E family. */
+		{ 0x7cf00000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
 		{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
 		{ 0x7cf00000, 0x2c100000,	RTL_GIGA_MAC_VER_32 },
 		{ 0x7c800000, 0x2c000000,	RTL_GIGA_MAC_VER_33 },
@@ -2691,6 +2766,109 @@ static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
 
+static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init_1[] = {
+		/* ? */
+		{ 0x1f, 0x0001 },
+		{ 0x0b, 0x6c14 },
+		{ 0x14, 0x7f3d },
+		{ 0x1c, 0xfafe },
+		{ 0x08, 0x07c5 },
+		{ 0x10, 0xf090 },
+		{ 0x1f, 0x0003 },
+		{ 0x14, 0x641a },
+		{ 0x1a, 0x0606 },
+		{ 0x12, 0xf480 },
+		{ 0x13, 0x0747 },
+		{ 0x1f, 0x0000 },
+
+		/* ? */
+		{ 0x1f, 0x0004 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x0078 },
+		{ 0x15, 0xa408 },
+		{ 0x17, 0x5100 },
+		{ 0x19, 0x0008 },
+		{ 0x1f, 0x0002 },
+		{ 0x1f, 0x0000 },
+
+		/* ? */
+		{ 0x1f, 0x0003 },
+		{ 0x0d, 0x0207 },
+		{ 0x02, 0x5fd0 },
+		{ 0x1f, 0x0000 }
+	}, phy_reg_init_2[] = {
+		/* ? */
+		{ 0x1f, 0x0004 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x00ac },
+		{ 0x18, 0x0006 },
+		{ 0x1f, 0x0002 },
+		{ 0x1f, 0x0000 },
+
+		/* ? */
+		{ 0x1f, 0x0003 },
+		{ 0x09, 0xa20f },
+		{ 0x1f, 0x0000 },
+
+		/* ? */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b5b },
+		{ 0x06, 0x9222 },
+		{ 0x05, 0x8b6d },
+		{ 0x06, 0x8000 },
+		{ 0x05, 0x8b76 },
+		{ 0x06, 0x8000 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_apply_firmware(tp);
+
+	/* ? */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* ? */
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x15, 0x1006);
+
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	rtl_writephy_batch(tp, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+
+	/* ? */
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x00a1);
+	rtl_w1w0_phy(tp, 0x1a, 0x0000, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* ? */
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x16, 0x0020, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	rtl_writephy_batch(tp, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2812,6 +2990,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_33:
 		rtl8168e_1_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_34:
+		rtl8168e_2_hw_phy_config(tp);
+		break;
 
 	default:
 		break;
@@ -3170,6 +3351,7 @@ static void r8168_phy_power_down(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_34:
 		rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE | BMCR_PDOWN);
 		break;
 
@@ -3926,6 +4108,20 @@ static void rtl_csi_access_enable_2(void __iomem *ioaddr)
 	rtl_csi_access_enable(ioaddr, 0x27000000);
 }
 
+struct ephy_reg {
+	u16 offset;
+	u16 val;
+};
+
+static void rtl_write_ephy_batch(void __iomem *ioaddr,
+				 const struct ephy_reg *regs, int len)
+{
+	while (len-- > 0) {
+		rtl_ephy_write(ioaddr, regs->offset, regs->val);
+		regs++;
+	}
+}
+
 struct ephy_info {
 	unsigned int offset;
 	u16 mask;
@@ -4184,6 +4380,60 @@ static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
+struct eri_reg {
+	u16 addr;
+	u16 len;
+	u32 data;
+};
+
+static void rtl_write_eri_batch(void __iomem * ioaddr,
+				const struct eri_reg *regs, int len, int type)
+{
+	while (len-- > 0) {
+		rtl_eri_write(ioaddr, regs->addr, regs->len, regs->data, type);
+		regs++;
+	}
+}
+
+static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_reg ephy_reg_init[] = {
+		{ 0x06, 0xf020 },
+		{ 0x07, 0x01ff },
+		{ 0x00, 0x5027 },
+		{ 0x01, 0x0003 },
+		{ 0x02, 0x2d16 },
+		{ 0x03, 0x6d49 },
+		{ 0x08, 0x0006 },
+		{ 0x0a, 0x00c8 },
+	};
+	static const struct ephy_info e_info_8168e[] = {
+		{ 0x09, 0x0000, 0x0080 },
+		{ 0x19, 0x0000, 0x0224 }
+	};
+	static const struct eri_reg eri_reg_init[] = {
+		{ 0xd5, 1, 0x0000000c },
+		{ 0xc0, 2, 0x00000000 },
+		{ 0xb8, 2, 0x00000000 },
+		{ 0xc8, 4, 0x00100002 },
+		{ 0xe8, 4, 0x00100006 }
+	};
+
+	rtl_csi_access_enable_1(ioaddr);
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
+
+	rtl_write_eri_batch(ioaddr, eri_reg_init, ARRAY_SIZE(eri_reg_init),
+			    ERIAR_EXGMAC);
+
+	rtl_eri_write(ioaddr, 0x01dc, 1, 0x64, ERIAR_EXGMAC);
+
+	rtl_write_ephy_batch(ioaddr, ephy_reg_init, ARRAY_SIZE(ephy_reg_init));
+	rtl_ephy_init(ioaddr, e_info_8168e, ARRAY_SIZE(e_info_8168e));
+
+	rtl_disable_clock_request(pdev);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4275,6 +4525,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168e_1(ioaddr, pdev);
 		break;
 
+	case RTL_GIGA_MAC_VER_34:
+		rtl_hw_start_8168e_2(ioaddr, pdev);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.7.4.4


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-noise-redux.patch"

>From d777443c097b65b06f1d0e7da37db1368185db8e Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 28 Jun 2011 17:01:29 +0200
Subject: [PATCH 1/3] r8169: noise redux.

- insert an empty record in rtl_chip_infos for future chipsets.
  NB: the array is only accessed through the RTL_GIGA_MAC_VER_xy enum.
- ready-to-use ERIAR bits definitions. Those were not used.
- ERIDR / ERIAR confusion. This one is already in Linus's tree. I'll
  remove it before the final submission.
- make room for different 8168e hw_phy_config and hw_start methods.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index fbd6838..f5b8d52 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -216,7 +216,7 @@ static const struct {
 	[RTL_GIGA_MAC_VER_32] =
 		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
 	[RTL_GIGA_MAC_VER_33] =
-		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2)
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2),
 };
 #undef _R
 
@@ -351,12 +351,12 @@ enum rtl8168_registers {
 #define ERIAR_WRITE_CMD			0x80000000
 #define ERIAR_READ_CMD			0x00000000
 #define ERIAR_ADDR_BYTE_ALIGN		4
-#define ERIAR_EXGMAC			0
-#define ERIAR_MSIX			1
-#define ERIAR_ASF			2
 #define ERIAR_TYPE_SHIFT		16
-#define ERIAR_BYTEEN			0x0f
+#define ERIAR_EXGMAC			(0x00 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MSIX			(0x01 << ERIAR_TYPE_SHIFT)
+#define ERIAR_ASF			(0x02 << ERIAR_TYPE_SHIFT)
 #define ERIAR_BYTEEN_SHIFT		12
+#define ERIAR_BYTEEN			(0x0f << ERIAR_BYTEEN_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
 #define OCPDR_WRITE_CMD			0x80000000
@@ -749,11 +749,12 @@ static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 	int i;
 
 	RTL_W8(ERIDR, cmd);
-	RTL_W32(ERIAR, 0x800010e8);
+	/* Could 0x10e8 be replaced with (ERIAR_BYTEEN | 0x00e8) ? */
+	RTL_W32(ERIAR, ERIAR_WRITE_CMD | ERIAR_EXGMAC | 0x10e8);
 	msleep(2);
 	for (i = 0; i < 5; i++) {
 		udelay(100);
-		if (!(RTL_R32(ERIDR) & ERIAR_FLAG))
+		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
 			break;
 	}
 
@@ -2617,7 +2618,7 @@ static void rtl8168d_4_hw_phy_config(struct rtl8169_private *tp)
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 }
 
-static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
+static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		/* Enable Delay cap */
@@ -2809,7 +2810,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl8168e_hw_phy_config(tp);
+		rtl8168e_1_hw_phy_config(tp);
 		break;
 
 	default:
@@ -4148,7 +4149,7 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_enable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	static const struct ephy_info e_info_8168e[] = {
 		{ 0x00, 0x0200,	0x0100 },
@@ -4271,7 +4272,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl_hw_start_8168e(ioaddr, pdev);
+		rtl_hw_start_8168e_1(ioaddr, pdev);
 		break;
 
 	default:
-- 
1.7.4.4


--SLDf9lqlvOQaIe6s--
