From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/6] r8169: adjust the settings about RxConfig
Date: Tue, 5 Jul 2011 17:44:52 +0800
Message-ID: <1309859095-32031-3-git-send-email-hayeswang@realtek.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the init value before reset in probe function. And then just
modify the relative bits and keep the init settings.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   63 +++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index cdbbe47..3aeae68 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -71,7 +71,7 @@ static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
-#define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
+#define RX_DMA_BURST	7	/* Maximum PCI burst, '7' is Unlimited */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
@@ -272,9 +272,6 @@ enum rtl_registers {
 	IntrStatus	= 0x3e,
 	TxConfig	= 0x40,
 	RxConfig	= 0x44,
-
-#define RTL_RX_CONFIG_MASK		0xff7e1880u
-
 	RxMissed	= 0x4c,
 	Cfg9346		= 0x50,
 	Config0		= 0x51,
@@ -727,10 +724,6 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
-
-static const unsigned int rtl8169_rx_config =
-	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
-
 static void rtl8169_init_ring_indexes(struct rtl8169_private *tp);
 
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
@@ -3337,6 +3330,45 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_init_rxcfg(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
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
+		RTL_W32(RxConfig, (RX_FIFO_THRESH << RxCfgFIFOShift) |
+			(RX_DMA_BURST << RxCfgDMAShift));
+		break;
+	case RTL_GIGA_MAC_VER_18:
+	case RTL_GIGA_MAC_VER_19:
+	case RTL_GIGA_MAC_VER_20:
+	case RTL_GIGA_MAC_VER_21:
+	case RTL_GIGA_MAC_VER_22:
+	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN |
+			(RX_DMA_BURST << RxCfgDMAShift));
+		break;
+	default:
+		RTL_W32(RxConfig, RX128_INT_EN |
+			(RX_DMA_BURST << RxCfgDMAShift));
+		break;
+	}
+}
+
 static void rtl_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3459,6 +3491,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pci_is_pcie(pdev))
 		netif_info(tp, probe, dev, "not PCI Express\n");
 
+	/* Identify chip attached to board */
+	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
+
+	rtl_init_rxcfg(tp);
+
 	RTL_W16(IntrMask, 0x0000);
 
 	rtl_hw_reset(tp);
@@ -3467,9 +3504,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	/* Identify chip attached to board */
-	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
-
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
 	 * Interrupts stop flowing on high load on 8110SCd controllers.
@@ -3770,10 +3804,6 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 cfg = rtl8169_rx_config;
-
-	cfg |= (RTL_R32(RxConfig) & RTL_RX_CONFIG_MASK);
-	RTL_W32(RxConfig, cfg);
 
 	/* Set DMA burst size and Interframe Gap Time */
 	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
@@ -5343,8 +5373,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tmp = rtl8169_rx_config | rx_mode |
-	      (RTL_R32(RxConfig) & RTL_RX_CONFIG_MASK);
+	tmp = RTL_R32(RxConfig) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
 		u32 data = mc_filter[0];
-- 
1.7.3.2
