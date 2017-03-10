From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 6/9] net: stmmac: Parse FIFO sizes from feature registers
Date: Fri, 10 Mar 2017 17:34:58 +0100
Message-ID: <20170310163501.31811-7-thierry.reding@gmail.com>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170310163501.31811-1-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

New version of this core encode the FIFO sizes in one of the feature
registers. Use these sizes as default, but still allow device tree to
override them for backwards compatibility.

Reviewed-by: Mikko Perttunen <mperttunen-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
Changes in v2:
- provide macros for the FIFO size fields in the feature register
- add comment about FIFO size encoding to clarify the computation

 drivers/net/ethernet/stmicro/stmmac/common.h      | 3 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +++
 4 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 04d9245b7149..3ca36744007b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -324,6 +324,9 @@ struct dma_features {
 	unsigned int number_tx_queues;
 	/* Alternate (enhanced) DESC mode */
 	unsigned int enh_desc;
+	/* TX and RX FIFO sizes */
+	unsigned int tx_fifo_size;
+	unsigned int rx_fifo_size;
 };
 
 /* GMAC TX FIFO is 8K, Rx FIFO is 16K */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index db45134fddf0..83f5e953e291 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -148,6 +148,8 @@ enum power_event {
 /* MAC HW features1 bitmap */
 #define GMAC_HW_FEAT_AVSEL		BIT(20)
 #define GMAC_HW_TSOEN			BIT(18)
+#define GMAC_HW_TXFIFOSIZE		GENMASK(10, 6)
+#define GMAC_HW_RXFIFOSIZE		GENMASK(4, 0)
 
 /* MAC HW features2 bitmap */
 #define GMAC_HW_FEAT_TXCHCNT		GENMASK(21, 18)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index f97b0d5d9987..55270933bae1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -294,6 +294,11 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 	hw_cap = readl(ioaddr + GMAC_HW_FEATURE1);
 	dma_cap->av = (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
 	dma_cap->tsoen = (hw_cap & GMAC_HW_TSOEN) >> 18;
+	/* RX and TX FIFO sizes are encoded as log2(n / 128). Undo that by
+	 * shifting and store the sizes in bytes.
+	 */
+	dma_cap->tx_fifo_size = 128 << ((hw_cap & GMAC_HW_TXFIFOSIZE) >> 6);
+	dma_cap->rx_fifo_size = 128 << ((hw_cap & GMAC_HW_RXFIFOSIZE) >> 0);
 	/* MAC HW feature2 */
 	hw_cap = readl(ioaddr + GMAC_HW_FEATURE2);
 	/* TX and RX number of channels */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index eba9088e1f61..78f6ec2d165b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1281,6 +1281,9 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
 	int rxfifosz = priv->plat->rx_fifo_size;
 
+	if (rxfifosz == 0)
+		rxfifosz = priv->dma_cap.rx_fifo_size;
+
 	if (priv->plat->force_thresh_dma_mode)
 		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
 	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
-- 
2.12.0
