From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] stmmac: add DMA initialization delay to device tree
Date: Mon,  2 Jun 2014 18:53:55 +0400
Message-ID: <1401720835-21507-1-git-send-email-abrodkin@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hans de Goede <hdegoede@redhat.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Chen-Yu Tsai <wens@csie.org>, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some platforms existing 100 msecond delay is not enough for DMA block to
recover after reset.
For example MAC DMA waits for all PHY input clocks are present and depending
on the board reset bit deassertion may take different amount of time.

Having this parameter easily configurable allows each board to have its own
value, while all exisiting boards will continue to use current default value of
100 msec.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: David S. Miller <davem@davemloft.net>
Cc: Hans de Goede <hdegoede@redhat.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Chen-Yu Tsai <wens@csie.org>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      | 2 ++
 drivers/net/ethernet/stmicro/stmmac/common.h          | 5 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   | 5 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c    | 5 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 8 ++++++++
 include/linux/stmmac.h                                | 1 +
 7 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index a2acd2b..1e28772 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -20,6 +20,7 @@ Required properties:
 - snps,pbl		Programmable Burst Length
 - snps,fixed-burst	Program the DMA to use the fixed burst mode
 - snps,mixed-burst	Program the DMA to use the mixed burst mode
+- snps,dma-init-delay	Maximum delay for DMA initialization in milliseconds
 - snps,force_thresh_dma_mode	Force DMA to use the threshold mode for
 				both tx and rx
 - snps,force_sf_dma_mode	Force DMA to use the Store and Forward
@@ -49,4 +50,5 @@ Examples:
 		phy-mode = "gmii";
 		clocks = <&clock>;
 		clock-names = "stmmaceth">;
+		dma-init-delay = <1000>;
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 74610f3..1a17080 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -294,6 +294,8 @@ struct dma_features {
 
 #define JUMBO_LEN		9000
 
+#define DMA_INIT_DELAY	100
+
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, int disable_rx_ic, int mode,
@@ -344,7 +346,8 @@ struct stmmac_desc_ops {
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
-		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
+		     int burst_len, u32 dma_tx, u32 dma_rx, int atds,
+		     int init_delay);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 0c2058a..adaa1d3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -31,15 +31,14 @@
 #include "dwmac_dma.h"
 
 static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			      int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+			      int burst_len, u32 dma_tx, u32 dma_rx, int atds,
+			      int limit)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	int limit;
 
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 10;
 	while (limit--) {
 		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
 			break;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 7d1dce9..595e450 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -33,15 +33,14 @@
 #include "dwmac_dma.h"
 
 static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			     int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+			     int burst_len, u32 dma_tx, u32 dma_rx, int atds,
+			     int limit)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	int limit;
 
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 10;
 	while (limit--) {
 		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
 			break;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 110ca1c..79b7d64 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1567,7 +1567,8 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 
 	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
 				   burst_len, priv->dma_tx_phy,
-				   priv->dma_rx_phy, atds);
+				   priv->dma_rx_phy, atds,
+				   priv->plat->dma_cfg->init_delay);
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 46aef510..e5743c9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -153,6 +153,14 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 			of_property_read_bool(np, "snps,fixed-burst");
 		dma_cfg->mixed_burst =
 			of_property_read_bool(np, "snps,mixed-burst");
+
+		if (of_property_read_u32(np, "dma-init-delay",
+					 &dma_cfg->init_delay))
+			dma_cfg->init_delay = DMA_INIT_DELAY;
+		dma_cfg->init_delay /= 10;
+		if (!dma_cfg->init_delay)
+			dma_cfg->init_delay = 1;
+
 	}
 	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 6f27d4f..3d7f3e7 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -91,6 +91,7 @@ struct stmmac_dma_cfg {
 	int fixed_burst;
 	int mixed_burst;
 	int burst_len;
+	int init_delay;
 };
 
 struct plat_stmmacenet_data {
-- 
1.9.3
