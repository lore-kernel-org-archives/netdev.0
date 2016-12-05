From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 5/6] net: stmmac: add support for independent DMA pbl for tx/rx
Date: Mon, 5 Dec 2016 10:12:30 +0100
Message-ID: <1480929155-20462-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-doc@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Jonathan Corbet <corbet@lwn.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklass@axis.com>,
        Phil Reid <preid@electromag.com.au>,
        Eric Engestrom <eric@engestrom.ch>,
        Pavel Machek <pavel@ucw.cz>,
        Joachim Eastwood <manabian@gmail.com>,
        Gabriel Fernandez <gabriel.fernandez@linaro.org>,
        Vincent Palatin <vpalatin@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

GMAC and newer supports independent programmable burst lengths for
DMA tx/rx. Add new optional devicetree properties representing this.

To be backwards compatible, snps,pbl will still be valid, but
snps,txpbl/snps,rxpbl will override the value in snps,pbl if set.

If the IP is synthesized to use the AXI interface, there is a register
and a matching DT property inside the optional stmmac-axi-config DT node
for controlling burst lengths, named snps,blen.
However, using this register, it is not possible to control tx and rx
independently. Also, this register is not available if the IP was
synthesized with, e.g., the AHB interface.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      |  6 +++++-
 Documentation/networking/stmmac.txt                   | 19 +++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   | 12 ++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c      | 12 +++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 ++
 include/linux/stmmac.h                                |  2 ++
 6 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 41b49e6075f5..a3dc1453dffb 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -34,7 +34,11 @@ Optional properties:
   platforms.
 - tx-fifo-depth: See ethernet.txt file in the same directory
 - rx-fifo-depth: See ethernet.txt file in the same directory
-- snps,pbl		Programmable Burst Length
+- snps,pbl		Programmable Burst Length (tx and rx)
+- snps,txpbl		Tx Programmable Burst Length. Only for GMAC and newer.
+			If set, DMA tx will use this value rather than snps,pbl.
+- snps,rxpbl		Rx Programmable Burst Length. Only for GMAC and newer.
+			If set, DMA rx will use this value rather than snps,pbl.
 - snps,aal		Address-Aligned Beats
 - snps,fixed-burst	Program the DMA to use the fixed burst mode
 - snps,mixed-burst	Program the DMA to use the mixed burst mode
diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 014f4f756cb7..6add57374f70 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -153,7 +153,8 @@ Where:
    o pbl: the Programmable Burst Length is maximum number of beats to
        be transferred in one DMA transaction.
        GMAC also enables the 4xPBL by default.
-   o fixed_burst/mixed_burst/burst_len
+   o txpbl/rxpbl: GMAC and newer supports independent DMA pbl for tx/rx.
+   o fixed_burst/mixed_burst/aal
  o clk_csr: fixed CSR Clock range selection.
  o has_gmac: uses the GMAC core.
  o enh_desc: if sets the MAC will use the enhanced descriptor structure.
@@ -205,16 +206,22 @@ tuned according to the HW capabilities.
 
 struct stmmac_dma_cfg {
 	int pbl;
+	int txpbl;
+	int rxpbl;
 	int fixed_burst;
-	int burst_len_supported;
+	int mixed_burst;
+	bool aal;
 };
 
 Where:
- o pbl: Programmable Burst Length
+ o pbl: Programmable Burst Length (tx and rx)
+ o txpbl: Transmit Programmable Burst Length. Only for GMAC and newer.
+	 If set, DMA tx will use this value rather than pbl.
+ o rxpbl: Receive Programmable Burst Length. Only for GMAC and newer.
+	 If set, DMA rx will use this value rather than pbl.
  o fixed_burst: program the DMA to use the fixed burst mode
- o burst_len: this is the value we put in the register
-	      supported values are provided as macros in
-	      linux/stmmac.h header file.
+ o mixed_burst: program the DMA to use the mixed burst mode
+ o aal: Address-Aligned Beats
 
 ---
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 01d0d0f315e5..1dd34fb4c1a9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -87,20 +87,20 @@ static void dwmac1000_dma_init(void __iomem *ioaddr,
 			       u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	int txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
+	int rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
 
 	/*
 	 * Set the DMA PBL (Programmable Burst Length) mode.
 	 *
 	 * Note: before stmmac core 3.50 this mode bit was 4xPBL, and
 	 * post 3.5 mode bit acts as 8*PBL.
-	 *
-	 * This configuration doesn't take care about the Separate PBL
-	 * so only the bits: 13-8 are programmed with the PBL passed from the
-	 * platform.
 	 */
 	value |= DMA_BUS_MODE_MAXPBL;
-	value &= ~DMA_BUS_MODE_PBL_MASK;
-	value |= (dma_cfg->pbl << DMA_BUS_MODE_PBL_SHIFT);
+	value |= DMA_BUS_MODE_USP;
+	value &= ~(DMA_BUS_MODE_PBL_MASK | DMA_BUS_MODE_RPBL_MASK);
+	value |= (txpbl << DMA_BUS_MODE_PBL_SHIFT);
+	value |= (rxpbl << DMA_BUS_MODE_RPBL_SHIFT);
 
 	/* Set the Fixed burst mode */
 	if (dma_cfg->fixed_burst)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 0946546d6dcd..0bf47825bfeb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -69,11 +69,14 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 }
 
-static void dwmac4_dma_init_channel(void __iomem *ioaddr, int pbl,
+static void dwmac4_dma_init_channel(void __iomem *ioaddr,
+				    struct stmmac_dma_cfg *dma_cfg,
 				    u32 dma_tx_phy, u32 dma_rx_phy,
 				    u32 channel)
 {
 	u32 value;
+	int txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
+	int rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
 
 	/* set PBL for each channels. Currently we affect same configuration
 	 * on each channel
@@ -83,11 +86,11 @@ static void dwmac4_dma_init_channel(void __iomem *ioaddr, int pbl,
 	writel(value, ioaddr + DMA_CHAN_CONTROL(channel));
 
 	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
-	value = value | (pbl << DMA_BUS_MODE_PBL_SHIFT);
+	value = value | (txpbl << DMA_BUS_MODE_PBL_SHIFT);
 	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(channel));
 
 	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(channel));
-	value = value | (pbl << DMA_BUS_MODE_RPBL_SHIFT);
+	value = value | (rxpbl << DMA_BUS_MODE_RPBL_SHIFT);
 	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(channel));
 
 	/* Mask interrupts by writing to CSR7 */
@@ -118,8 +121,7 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 
 	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		dwmac4_dma_init_channel(ioaddr, dma_cfg->pbl,
-					dma_tx, dma_rx, i);
+		dwmac4_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
 }
 
 static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 59e1740479fc..55cac48897f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -310,6 +310,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	plat->dma_cfg = dma_cfg;
 
 	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+	of_property_read_u32(np, "snps,txpbl", &dma_cfg->txpbl);
+	of_property_read_u32(np, "snps,rxpbl", &dma_cfg->rxpbl);
 
 	dma_cfg->aal = of_property_read_bool(np, "snps,aal");
 	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 3537fb33cc90..e6d7a5940819 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -88,6 +88,8 @@ struct stmmac_mdio_bus_data {
 
 struct stmmac_dma_cfg {
 	int pbl;
+	int txpbl;
+	int rxpbl;
 	int fixed_burst;
 	int mixed_burst;
 	bool aal;
-- 
2.1.4
