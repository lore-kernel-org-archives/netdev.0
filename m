From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v3 6/6] net: smmac: allow configuring lower pbl values
Date: Wed, 7 Dec 2016 15:20:08 +0100
Message-ID: <1481120409-18103-7-git-send-email-niklass@axis.com>
References: <1481120409-18103-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-doc@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Jonathan Corbet <corbet@lwn.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "David S. Miller" <davem@davemloft.net>,
        Phil Reid <preid@electromag.com.au>,
        Eric Engestrom <eric@engestrom.ch>,
        Pavel Machek <pavel@ucw.cz>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
        Joachim Eastwood <manabian@gmail.com>,
        Vincent Palatin <vpalatin@chromium.org>,
        Gabriel Fernandez <gabriel.fernandez@linaro.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1481120409-18103-1-git-send-email-niklass@axis.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

The driver currently always sets the PBLx8/PBLx4 bit, which means that
the pbl values configured via the pbl/txpbl/rxpbl DT properties are
always multiplied by 8/4 in the hardware.

In order to allow the DT to configure lower pbl values, while at the
same time not changing behavior of any existing device trees using the
pbl/txpbl/rxpbl settings, add a property to disable the multiplication
of the pbl by 8/4 in the hardware.

Suggested-by: Rabin Vincent <rabinv@axis.com>
Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      | 2 ++
 Documentation/networking/stmmac.txt                   | 5 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c      | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      | 2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 +
 include/linux/stmmac.h                                | 1 +
 7 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 8080038ff1b2..128da752fec9 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -39,6 +39,8 @@ Optional properties:
 			If set, DMA tx will use this value rather than snps,pbl.
 - snps,rxpbl		Rx Programmable Burst Length. Only for GMAC and newer.
 			If set, DMA rx will use this value rather than snps,pbl.
+- snps,no-pbl-x8	Don't multiply the pbl/txpbl/rxpbl values by 8.
+			For core rev < 3.50, don't multiply the values by 4.
 - snps,aal		Address-Aligned Beats
 - snps,fixed-burst	Program the DMA to use the fixed burst mode
 - snps,mixed-burst	Program the DMA to use the mixed burst mode
diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 6add57374f70..2bb07078f535 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -152,8 +152,9 @@ Where:
  o dma_cfg: internal DMA parameters
    o pbl: the Programmable Burst Length is maximum number of beats to
        be transferred in one DMA transaction.
-       GMAC also enables the 4xPBL by default.
+       GMAC also enables the 4xPBL by default. (8xPBL for GMAC 3.50 and newer)
    o txpbl/rxpbl: GMAC and newer supports independent DMA pbl for tx/rx.
+   o pblx8: Enable 8xPBL (4xPBL for core rev < 3.50). Enabled by default.
    o fixed_burst/mixed_burst/aal
  o clk_csr: fixed CSR Clock range selection.
  o has_gmac: uses the GMAC core.
@@ -208,6 +209,7 @@ struct stmmac_dma_cfg {
 	int pbl;
 	int txpbl;
 	int rxpbl;
+	bool pblx8;
 	int fixed_burst;
 	int mixed_burst;
 	bool aal;
@@ -219,6 +221,7 @@ Where:
 	 If set, DMA tx will use this value rather than pbl.
  o rxpbl: Receive Programmable Burst Length. Only for GMAC and newer.
 	 If set, DMA rx will use this value rather than pbl.
+ o pblx8: Enable 8xPBL (4xPBL for core rev < 3.50). Enabled by default.
  o fixed_burst: program the DMA to use the fixed burst mode
  o mixed_burst: program the DMA to use the mixed burst mode
  o aal: Address-Aligned Beats
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 99b8040af592..612d3aaac9a4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -98,7 +98,8 @@ static void dwmac1000_dma_init(void __iomem *ioaddr,
 	 * Note: before stmmac core 3.50 this mode bit was 4xPBL, and
 	 * post 3.5 mode bit acts as 8*PBL.
 	 */
-	value |= DMA_BUS_MODE_MAXPBL;
+	if (dma_cfg->pblx8)
+		value |= DMA_BUS_MODE_MAXPBL;
 	value |= DMA_BUS_MODE_USP;
 	value &= ~(DMA_BUS_MODE_PBL_MASK | DMA_BUS_MODE_RPBL_MASK);
 	value |= (txpbl << DMA_BUS_MODE_PBL_SHIFT);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 2c3b2098f350..8196ab5fc33c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -84,7 +84,8 @@ static void dwmac4_dma_init_channel(void __iomem *ioaddr,
 	 * on each channel
 	 */
 	value = readl(ioaddr + DMA_CHAN_CONTROL(channel));
-	value = value | DMA_BUS_MODE_PBL;
+	if (dma_cfg->pblx8)
+		value = value | DMA_BUS_MODE_PBL;
 	writel(value, ioaddr + DMA_CHAN_CONTROL(channel));
 
 	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 56c8a2342c14..a2831773431a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -81,6 +81,7 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	plat->mdio_bus_data->phy_mask = 0;
 
 	plat->dma_cfg->pbl = 32;
+	plat->dma_cfg->pblx8 = true;
 	/* TODO: AXI */
 
 	/* Set default value for multicast hash bins */
@@ -115,6 +116,7 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	plat->mdio_bus_data->phy_mask = 0;
 
 	plat->dma_cfg->pbl = 16;
+	plat->dma_cfg->pblx8 = true;
 	plat->dma_cfg->fixed_burst = 1;
 	/* AXI (TODO) */
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 96afe0561c99..082cd48db6a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -317,6 +317,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		dma_cfg->pbl = DEFAULT_DMA_PBL;
 	of_property_read_u32(np, "snps,txpbl", &dma_cfg->txpbl);
 	of_property_read_u32(np, "snps,rxpbl", &dma_cfg->rxpbl);
+	dma_cfg->pblx8 = !of_property_read_bool(np, "snps,no-pbl-x8");
 
 	dma_cfg->aal = of_property_read_bool(np, "snps,aal");
 	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index e6d7a5940819..266dab9ad782 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -90,6 +90,7 @@ struct stmmac_dma_cfg {
 	int pbl;
 	int txpbl;
 	int rxpbl;
+	bool pblx8;
 	int fixed_burst;
 	int mixed_burst;
 	bool aal;
-- 
2.1.4

