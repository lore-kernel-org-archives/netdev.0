From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: stmmac: clear reset value of snps,wr_osr_lmt/snps,rd_osr_lmt before writing
Date: Mon, 5 Dec 2016 18:12:54 +0100
Message-ID: <1480957974-22326-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

WR_OSR_LMT and RD_OSR_LMT have a reset value of 1.
Since the reset value wasn't cleared before writing, the value in the
register would be incorrect if specifying an uneven value for
snps,wr_osr_lmt/snps,rd_osr_lmt.

Zero is a valid value for the properties, since the databook specifies:
maximum outstanding requests = WR_OSR_LMT + 1.

We do not want to change the behavior for existing users when the
property is missing. Therefore, default to 1 if the property is missing,
since that is the same as the reset value.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   | 2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c      | 2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 6 ++++--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 990746955216..f35385266fbf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -43,9 +43,11 @@ static void dwmac1000_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	if (axi->axi_xit_frm)
 		value |= DMA_AXI_LPI_XIT_FRM;
 
+	value &= ~DMA_AXI_WR_OSR_LMT;
 	value |= (axi->axi_wr_osr_lmt & DMA_AXI_WR_OSR_LMT_MASK) <<
 		 DMA_AXI_WR_OSR_LMT_SHIFT;
 
+	value &= ~DMA_AXI_RD_OSR_LMT;
 	value |= (axi->axi_rd_osr_lmt & DMA_AXI_RD_OSR_LMT_MASK) <<
 		 DMA_AXI_RD_OSR_LMT_SHIFT;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 577316de6ba8..e81b6e565c29 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -30,9 +30,11 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	if (axi->axi_xit_frm)
 		value |= DMA_AXI_LPI_XIT_FRM;
 
+	value &= ~DMA_AXI_WR_OSR_LMT;
 	value |= (axi->axi_wr_osr_lmt & DMA_AXI_OSR_MAX) <<
 		 DMA_AXI_WR_OSR_LMT_SHIFT;
 
+	value &= ~DMA_AXI_RD_OSR_LMT;
 	value |= (axi->axi_rd_osr_lmt & DMA_AXI_OSR_MAX) <<
 		 DMA_AXI_RD_OSR_LMT_SHIFT;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 98bf86d64d96..e528e7126b65 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -126,8 +126,10 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 	axi->axi_mb = of_property_read_bool(np, "snps,axi_mb");
 	axi->axi_rb =  of_property_read_bool(np, "snps,axi_rb");
 
-	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
-	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
+	if (of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt))
+		axi->axi_wr_osr_lmt = 1;
+	if (of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt))
+		axi->axi_rd_osr_lmt = 1;
 	of_property_read_u32_array(np, "snps,blen", axi->axi_blen, AXI_BLEN);
 	of_node_put(np);
 
-- 
2.1.4
