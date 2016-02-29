From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 01/17] stmmac: share reset function between dwmac100 and dwmac1000
Date: Mon, 29 Feb 2016 14:27:27 +0100
Message-ID: <1456752463-27128-2-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:6106 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755279AbcB2N2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:11 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u1TDRwUI027540
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:09 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by m0046037.ppops.net with ESMTP id 21b2ev2twf-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:08 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 1164823
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:05 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id AB1DFF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:03 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch is to share the same reset procedure between dwmac100 and
dwmac1000 chips.
This will also help on enhancing the driver and support new chips.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 1e19c8f..bac0e44 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -376,7 +376,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
 /* Specific DMA helpers */
 struct stmmac_dma_ops {
 	/* DMA core initialization */
-	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
+	int (*reset)(void __iomem *ioaddr);
+	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
 		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
index 2ec6aea..1657acf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
@@ -95,7 +95,6 @@
 #define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
 #define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
 #define DMA_BUS_MODE_BAR_BUS	0x00000002	/* Bar-Bus Arbitration */
-#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
 #define DMA_BUS_MODE_DEFAULT	0x00000000
 
 /* DMA Control register defines */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 8831a05..9d36ae7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -221,7 +221,6 @@ enum inter_frame_gap {
 
 /*--- DMA BLOCK defines ---*/
 /* DMA Bus Mode register defines */
-#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
 #define DMA_BUS_MODE_DA		0x00000002	/* Arbitration scheme */
 #define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
 #define DMA_BUS_MODE_DSL_SHIFT	2		/*   (in DWORDS)      */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 0e8937c..5f0aea5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -30,23 +30,10 @@
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
-static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			      int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
+			       int burst_len, u32 dma_tx, u32 dma_rx, int atds)
 {
-	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	int limit;
-
-	/* DMA SW reset */
-	value |= DMA_BUS_MODE_SFT_RESET;
-	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 10;
-	while (limit--) {
-		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
-			break;
-		mdelay(10);
-	}
-	if (limit < 0)
-		return -EBUSY;
+	u32 value;
 
 	/*
 	 * Set the DMA PBL (Programmable Burst Length) mode
@@ -102,8 +89,6 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	 */
 	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
 	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
-
-	return 0;
 }
 
 static u32 dwmac1000_configure_fc(u32 csr6, int rxfifosz)
@@ -205,6 +190,7 @@ static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 }
 
 const struct stmmac_dma_ops dwmac1000_dma_ops = {
+	.reset = dwmac_dma_reset,
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
 	.dma_mode = dwmac1000_dma_operation_mode,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 9d0971c..c40582a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -32,24 +32,9 @@
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
-static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			     int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+static void dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
+			      int burst_len, u32 dma_tx, u32 dma_rx, int atds)
 {
-	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	int limit;
-
-	/* DMA SW reset */
-	value |= DMA_BUS_MODE_SFT_RESET;
-	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 10;
-	while (limit--) {
-		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
-			break;
-		mdelay(10);
-	}
-	if (limit < 0)
-		return -EBUSY;
-
 	/* Enable Application Access by writing to DMA CSR0 */
 	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
 	       ioaddr + DMA_BUS_MODE);
@@ -62,8 +47,6 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	 */
 	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
 	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
-
-	return 0;
 }
 
 /* Store and Forward capability is not used at all.
@@ -131,6 +114,7 @@ static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
 }
 
 const struct stmmac_dma_ops dwmac100_dma_ops = {
+	.reset = dwmac_dma_reset,
 	.init = dwmac100_dma_init,
 	.dump_regs = dwmac100_dump_dma_regs,
 	.dma_mode = dwmac100_dma_operation_mode,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index def266d..13ca90e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -35,6 +35,10 @@
 #define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
 #define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
 #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
+
+/* SW Reset */
+#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
+
 /* Rx watchdog register */
 #define DMA_RX_WATCHDOG		0x00001024
 /* AXI Bus Mode */
@@ -112,5 +116,6 @@ void dwmac_dma_stop_tx(void __iomem *ioaddr);
 void dwmac_dma_start_rx(void __iomem *ioaddr);
 void dwmac_dma_stop_rx(void __iomem *ioaddr);
 int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+int dwmac_dma_reset(void __iomem *ioaddr);
 
 #endif /* __DWMAC_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 484e3cf..84e3e84 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -26,6 +26,27 @@
 
 #define GMAC_HI_REG_AE		0x80000000
 
+int dwmac_dma_reset(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	int limit;
+
+	/* DMA SW reset */
+	value |= DMA_BUS_MODE_SFT_RESET;
+	writel(value, ioaddr + DMA_BUS_MODE);
+	limit = 10;
+	while (limit--) {
+		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
+			break;
+		mdelay(10);
+	}
+
+	if (limit < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
 /* CSR1 enables the transmit DMA to check for new descriptor */
 void dwmac_enable_dma_transmission(void __iomem *ioaddr)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c21015b..13752e9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1638,6 +1638,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
 	int mixed_burst = 0;
 	int atds = 0;
+	int ret = 0;
 
 	if (priv->plat->dma_cfg) {
 		pbl = priv->plat->dma_cfg->pbl;
@@ -1649,9 +1650,16 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
 		atds = 1;
 
-	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
-				   burst_len, priv->dma_tx_phy,
-				   priv->dma_rx_phy, atds);
+	ret = priv->hw->dma->reset(priv->ioaddr);
+	if (ret) {
+		dev_err(priv->device, "Failed to reset the dma\n");
+		return ret;
+	}
+
+	priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
+			    burst_len, priv->dma_tx_phy,
+			    priv->dma_rx_phy, atds);
+	return ret;
 }
 
 /**
-- 
1.9.1
