From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net 5/5] stmmac: Configure Flow Control to work correctly based on rxfifo size
Date: Wed, 15 Apr 2015 11:17:42 -0500
Message-ID: <1429114662-1528-6-git-send-email-vbridger@opensource.altera.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@opensource.altera.com>, <vbridger@altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Configure flow control correctly, and based on the receive fifo size read
as a property from the devicetree since the Synopsys stmmac fifo sizes are
configurable based on a particular chip's implementation. This patch maintains
the previous incorrect behavior unless the receive fifo size is found in the
devicetree.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  5 +++--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 26 +++++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 16 ++++++++-----
 4 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index cd77289..623c6ed 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -150,7 +150,7 @@ struct stmmac_extra_stats {
 #define	MAC_CSR_H_FRQ_MASK	0x20
 
 #define HASH_TABLE_SIZE 64
-#define PAUSE_TIME 0x200
+#define PAUSE_TIME 0xffff
 
 /* Flow Control defines */
 #define FLOW_OFF	0
@@ -357,7 +357,8 @@ struct stmmac_dma_ops {
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
 	 * An invalid value enables the store-and-forward mode */
-	void (*dma_mode) (void __iomem *ioaddr, int txmode, int rxmode);
+	void (*dma_mode)(void __iomem *ioaddr, int txmode, int rxmode,
+			 int rxfifosz);
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 59d92e8..0e8937c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -106,8 +106,29 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	return 0;
 }
 
+static u32 dwmac1000_configure_fc(u32 csr6, int rxfifosz)
+{
+	csr6 &= ~DMA_CONTROL_RFA_MASK;
+	csr6 &= ~DMA_CONTROL_RFD_MASK;
+
+	/* Leave flow control disabled if receive fifo size is less than
+	 * 4K or 0. Otherwise, send XOFF when fifo is 1K less than full,
+	 * and send XON when 2K less than full.
+	 */
+	if (rxfifosz < 4096) {
+		csr6 &= ~DMA_CONTROL_EFC;
+		pr_debug("GMAC: disabling flow control, rxfifo too small(%d)\n",
+			 rxfifosz);
+	} else {
+		csr6 |= DMA_CONTROL_EFC;
+		csr6 |= RFA_FULL_MINUS_1K;
+		csr6 |= RFD_FULL_MINUS_2K;
+	}
+	return csr6;
+}
+
 static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
-					 int rxmode)
+					 int rxmode, int rxfifosz)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
@@ -153,6 +174,9 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 			csr6 |= DMA_CONTROL_RTC_128;
 	}
 
+	/* Configure flow control based on rx fifo size */
+	csr6 = dwmac1000_configure_fc(csr6, rxfifosz);
+
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 7d1dce9..9d0971c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -72,7 +72,7 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
  * control register.
  */
 static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
-					int rxmode)
+					int rxmode, int rxfifosz)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a0ea84f..73d104f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1277,8 +1277,10 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
+	int rxfifosz = priv->plat->rx_fifo_size;
+
 	if (priv->plat->force_thresh_dma_mode)
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
+		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
 	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
 		/*
 		 * In case of GMAC, SF mode can be enabled
@@ -1287,10 +1289,12 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 		 * 2) There is no bugged Jumbo frame support
 		 *    that needs to not insert csum in the TDES.
 		 */
-		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE);
+		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE,
+					rxfifosz);
 		priv->xstats.threshold = SF_DMA_MODE;
 	} else
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
+		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE,
+					rxfifosz);
 }
 
 /**
@@ -1442,6 +1446,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
 	int status;
+	int rxfifosz = priv->plat->rx_fifo_size;
 
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely((status & handle_rx)) || (status & handle_tx)) {
@@ -1456,10 +1461,11 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		    (tc <= 256)) {
 			tc += 64;
 			if (priv->plat->force_thresh_dma_mode)
-				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
+				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc,
+							rxfifosz);
 			else
 				priv->hw->dma->dma_mode(priv->ioaddr, tc,
-					SF_DMA_MODE);
+							SF_DMA_MODE, rxfifosz);
 			priv->xstats.threshold = tc;
 		}
 	} else if (unlikely(status == tx_hard_error))
-- 
1.9.1
