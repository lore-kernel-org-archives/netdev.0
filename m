From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 2/6] net: stmmac: simplify the common DMA init API
Date: Mon, 5 Dec 2016 10:10:34 +0100
Message-ID: <1480929039-20257-3-git-send-email-niklass@axis.com>
References: <1480929039-20257-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:48427 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbcLEJLP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 04:11:15 -0500
In-Reply-To: <1480929039-20257-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>

Use struct stmmac_dma_cfg *dma_cfg as an argument rather
than using all the struct members as individual arguments.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h        |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c | 13 +++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c  |  7 ++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c    | 14 ++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c   |  6 +-----
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 3ced2e1703c1..b13a144f72ad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -412,8 +412,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*reset)(void __iomem *ioaddr);
-	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
-		     int aal, u32 dma_tx, u32 dma_rx, int atds);
+	void (*init)(void __iomem *ioaddr, struct stmmac_dma_cfg *dma_cfg,
+		     u32 dma_tx, u32 dma_rx, int atds);
 	/* Configure the AXI Bus Mode Register */
 	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
 	/* Dump DMA registers */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 990746955216..01d0d0f315e5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -82,8 +82,9 @@ static void dwmac1000_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_AXI_BUS_MODE);
 }
 
-static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			       int aal, u32 dma_tx, u32 dma_rx, int atds)
+static void dwmac1000_dma_init(void __iomem *ioaddr,
+			       struct stmmac_dma_cfg *dma_cfg,
+			       u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
 
@@ -99,20 +100,20 @@ static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	 */
 	value |= DMA_BUS_MODE_MAXPBL;
 	value &= ~DMA_BUS_MODE_PBL_MASK;
-	value |= (pbl << DMA_BUS_MODE_PBL_SHIFT);
+	value |= (dma_cfg->pbl << DMA_BUS_MODE_PBL_SHIFT);
 
 	/* Set the Fixed burst mode */
-	if (fb)
+	if (dma_cfg->fixed_burst)
 		value |= DMA_BUS_MODE_FB;
 
 	/* Mixed Burst has no effect when fb is set */
-	if (mb)
+	if (dma_cfg->mixed_burst)
 		value |= DMA_BUS_MODE_MB;
 
 	if (atds)
 		value |= DMA_BUS_MODE_ATDS;
 
-	if (aal)
+	if (dma_cfg->aal)
 		value |= DMA_BUS_MODE_AAL;
 
 	writel(value, ioaddr + DMA_BUS_MODE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 61f54c99a7de..e5664da382f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -32,11 +32,12 @@
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
-static void dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			      int aal, u32 dma_tx, u32 dma_rx, int atds)
+static void dwmac100_dma_init(void __iomem *ioaddr,
+			      struct stmmac_dma_cfg *dma_cfg,
+			      u32 dma_tx, u32 dma_rx, int atds)
 {
 	/* Enable Application Access by writing to DMA CSR0 */
-	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
+	writel(DMA_BUS_MODE_DEFAULT | (dma_cfg->pbl << DMA_BUS_MODE_PBL_SHIFT),
 	       ioaddr + DMA_BUS_MODE);
 
 	/* Mask interrupts by writing to CSR7 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 577316de6ba8..0946546d6dcd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -97,27 +97,29 @@ static void dwmac4_dma_init_channel(void __iomem *ioaddr, int pbl,
 	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
 }
 
-static void dwmac4_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			    int aal, u32 dma_tx, u32 dma_rx, int atds)
+static void dwmac4_dma_init(void __iomem *ioaddr,
+			    struct stmmac_dma_cfg *dma_cfg,
+			    u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
 	int i;
 
 	/* Set the Fixed burst mode */
-	if (fb)
+	if (dma_cfg->fixed_burst)
 		value |= DMA_SYS_BUS_FB;
 
 	/* Mixed Burst has no effect when fb is set */
-	if (mb)
+	if (dma_cfg->mixed_burst)
 		value |= DMA_SYS_BUS_MB;
 
-	if (aal)
+	if (dma_cfg->aal)
 		value |= DMA_SYS_BUS_AAL;
 
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 
 	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		dwmac4_dma_init_channel(ioaddr, pbl, dma_tx, dma_rx, i);
+		dwmac4_dma_init_channel(ioaddr, dma_cfg->pbl,
+					dma_tx, dma_rx, i);
 }
 
 static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 14366800e5e6..b1e42ddf0370 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1595,11 +1595,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 		return ret;
 	}
 
-	priv->hw->dma->init(priv->ioaddr,
-			    priv->plat->dma_cfg->pbl,
-			    priv->plat->dma_cfg->fixed_burst,
-			    priv->plat->dma_cfg->mixed_burst,
-			    priv->plat->dma_cfg->aal,
+	priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
 			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
 
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-- 
2.1.4
