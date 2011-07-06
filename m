From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/7] r8169: adjust some registers
Date: Wed, 6 Jul 2011 15:58:02 +0800
Message-ID: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define new registers and modify some existing ones.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   43 +++++++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index fbd6838..a8de449 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -70,8 +70,6 @@ static const int multicast_filter_limit = 32;
 #define MAC_ADDR_LEN	6
 
 #define MAX_READ_REQUEST_SHIFT	12
-#define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
-#define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
@@ -270,9 +268,20 @@ enum rtl_registers {
 	TxPoll		= 0x38,
 	IntrMask	= 0x3c,
 	IntrStatus	= 0x3e,
+
 	TxConfig	= 0x40,
-	RxConfig	= 0x44,
+#define	TXCFG_AUTO_FIFO			(1 << 7)	/* 8111e-vl */
+#define	TXCFG_EMPTY			(1 << 11)	/* 8111e-vl */
 
+	RxConfig	= 0x44,
+#define	RX128_INT_EN			(1 << 15)	/* 8111c and later */
+#define	RX_MULTI_EN			(1 << 14)	/* 8111c only */
+#define	RXCFG_FIFO_SHIFT		13
+					/* No threshold before first PCI xfer. */
+#define	RX_FIFO_THRESH			(7 << RXCFG_FIFO_SHIFT)
+#define	RXCFG_DMA_SHIFT			8
+					/* Unlimited maximum PCI burst. */
+#define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
 #define RTL_RX_CONFIG_MASK		0xff7e1880u
 
 	RxMissed	= 0x4c,
@@ -327,12 +336,13 @@ enum rtl8168_8101_registers {
 #define	EPHYAR_REG_SHIFT		16
 #define	EPHYAR_DATA_MASK		0xffff
 	DLLPR			= 0xd0,
-#define	PM_SWITCH			(1 << 6)
+#define	PFM_EN				(1 << 6)
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
 	TWSI			= 0xd2,
 	MCU			= 0xd3,
+#define	NOW_IS_OOB			(1 << 7)
 #define	EN_NDP				(1 << 3)
 #define	EN_OOB_RESET			(1 << 2)
 	EFUSEAR			= 0xdc,
@@ -345,18 +355,22 @@ enum rtl8168_8101_registers {
 };
 
 enum rtl8168_registers {
+	LED_FREQ		= 0x1a,
+	EEE_LED			= 0x1b,
 	ERIDR			= 0x70,
 	ERIAR			= 0x74,
 #define ERIAR_FLAG			0x80000000
 #define ERIAR_WRITE_CMD			0x80000000
 #define ERIAR_READ_CMD			0x00000000
 #define ERIAR_ADDR_BYTE_ALIGN		4
-#define ERIAR_EXGMAC			0
-#define ERIAR_MSIX			1
-#define ERIAR_ASF			2
 #define ERIAR_TYPE_SHIFT		16
-#define ERIAR_BYTEEN			0x0f
-#define ERIAR_BYTEEN_SHIFT		12
+#define ERIAR_EXGMAC			(0x00 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MSIX			(0x01 << ERIAR_TYPE_SHIFT)
+#define ERIAR_ASF			(0x02 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MASK_SHIFT		12
+#define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
 #define OCPDR_WRITE_CMD			0x80000000
@@ -371,6 +385,7 @@ enum rtl8168_registers {
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
+#define PWM_EN				(1 << 22)
 };
 
 enum rtl_register_content {
@@ -395,6 +410,7 @@ enum rtl_register_content {
 	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
+	StopReq		= 0x80,
 	CmdReset	= 0x10,
 	CmdRxEnb	= 0x08,
 	CmdTxEnb	= 0x04,
@@ -417,10 +433,6 @@ enum rtl_register_content {
 	AcceptMyPhys	= 0x02,
 	AcceptAllPhys	= 0x01,
 
-	/* RxConfigBits */
-	RxCfgFIFOShift	= 13,
-	RxCfgDMAShift	=  8,
-
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
@@ -712,8 +724,7 @@ static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
-static const unsigned int rtl8169_rx_config =
-	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
+static const unsigned int rtl8169_rx_config = RX_FIFO_THRESH | RX_DMA_BURST;
 
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
@@ -4368,7 +4379,7 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
-	RTL_W8(DLLPR, RTL_R8(DLLPR) | PM_SWITCH);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 
 	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
-- 
1.7.3.2
