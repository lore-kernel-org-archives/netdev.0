From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: Added condition for non fix_burst mode
Date: Wed, 07 May 2014 17:14:01 +0900
Message-ID: <008c01cf69cc$4dcc8e50$e965aaf0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds the condition for non fixed burst mode
and separates into two conditions depending on pbl value.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c  |   32 ++++++++++++++++++++---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h  |    2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |    3 ++-
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index bb9b5b8..49240c9 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -45,7 +45,8 @@ static int sxgbe_dma_init(void __iomem *ioaddr, int fix_burst, int burst_map)
 
 static void sxgbe_dma_channel_init(void __iomem *ioaddr, int cha_num,
 				   int fix_burst, int pbl, dma_addr_t dma_tx,
-				   dma_addr_t dma_rx, int t_rsize, int r_rsize)
+				   dma_addr_t dma_rx, int t_rsize, int r_rsize,
+				   int buf_size)
 {
 	u32 reg_val;
 	dma_addr_t dma_addr;
@@ -57,12 +58,37 @@ static void sxgbe_dma_channel_init(void __iomem *ioaddr, int cha_num,
 		writel(reg_val, ioaddr + SXGBE_DMA_CHA_CTL_REG(cha_num));
 		/* program the TX pbl */
 		reg_val = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
-		reg_val |= (pbl << SXGBE_DMA_TXPBL_LSHIFT);
+		reg_val |= pbl << SXGBE_DMA_TXPBL_LSHIFT;
 		writel(reg_val, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
 		/* program the RX pbl */
 		reg_val = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
-		reg_val |= (pbl << SXGBE_DMA_RXPBL_LSHIFT);
+		reg_val |= pbl << SXGBE_DMA_RXPBL_LSHIFT;
 		writel(reg_val, ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+	} else {
+		if (pbl > 32) {
+			/* program the pblx8  */
+			reg_val |= SXGBE_DMA_PBL_X8MODE;
+			writel(reg_val, ioaddr + SXGBE_DMA_CHA_CTL_REG(cha_num));
+			/* program the TX pbl */
+			reg_val = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+			reg_val |= (pbl >> 3) << SXGBE_DMA_TXPBL_LSHIFT;
+			writel(reg_val, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+			/* program the RX pbl */
+			reg_val = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+			reg_val |= (pbl >> 3) << SXGBE_DMA_RXPBL_LSHIFT |
+				   buf_size << SXGBE_DMA_BLENMAP_LSHIFT;
+			writel(reg_val, ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+		} else {
+			/* program the TX pbl */
+			reg_val = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+			reg_val |= pbl << SXGBE_DMA_TXPBL_LSHIFT;
+			writel(reg_val, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+			/* program the RX pbl */
+			reg_val = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+			reg_val |= pbl << SXGBE_DMA_RXPBL_LSHIFT |
+				   buf_size << SXGBE_DMA_BLENMAP_LSHIFT;
+			writel(reg_val, ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+		}
 	}
 
 	/* program desc registers */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
index 1607b54..843fa9b 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
@@ -25,7 +25,7 @@ struct sxgbe_dma_ops {
 	int (*init)(void __iomem *ioaddr, int fix_burst, int burst_map);
 	void (*cha_init)(void __iomem *ioaddr, int cha_num, int fix_burst,
 			 int pbl, dma_addr_t dma_tx, dma_addr_t dma_rx,
-			 int t_rzie, int r_rsize);
+			 int t_rzie, int r_rsize, int buf_size);
 	void (*enable_dma_transmission)(void __iomem *ioaddr, int dma_cnum);
 	void (*enable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
 	void (*disable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 82a9a98..93bf151 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -944,7 +944,8 @@ static int sxgbe_init_dma_engine(struct sxgbe_priv_data *priv)
 					fixed_burst, pbl,
 					(priv->txq[queue_num])->dma_tx_phy,
 					(priv->rxq[queue_num])->dma_rx_phy,
-					priv->dma_tx_size, priv->dma_rx_size);
+					priv->dma_tx_size, priv->dma_rx_size,
+					priv->dma_buf_sz);
 
 	return priv->hw->dma->init(priv->ioaddr, fixed_burst, burst_map);
 }
-- 
1.7.10.4
