From: thor.thayer@linux.intel.com
Subject: [PATCH] net: stmmac: Adjust dump offset of DMA registers for ethtool
Date: Fri, 21 Jul 2017 16:35:09 -0500
Message-ID: <1500672909-24408-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:29788 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754654AbdGUVcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 17:32:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

The commit fbf68229ffe7 ("net: stmmac: unify registers dumps methods")

in the Linux kernel modified the register dump to store the DMA registers
at the DMA register offset (0x1000) but ethtool (stmmac.c) looks for the
DMA registers after the MAC registers which is offset 55.
This patch copies the DMA registers from the higher offset to the offset
where ethtool expects them.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c  | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c   | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h      | 3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 5 +++++
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index cc4ea13..ec539f7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -205,7 +205,7 @@ static void dwmac1000_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 {
 	int i;
 
-	for (i = 0; i < 23; i++)
+	for (i = 0; i < NUM_DWMAC1000_DMA_REGS; i++)
 		if ((i < 12) || (i > 17))
 			reg_space[DMA_BUS_MODE / 4 + i] =
 				readl(ioaddr + DMA_BUS_MODE + i * 4);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index eef2f22..6502b9a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -70,7 +70,7 @@ static void dwmac100_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 {
 	int i;
 
-	for (i = 0; i < 9; i++)
+	for (i = 0; i < NUM_DWMAC100_DMA_REGS; i++)
 		reg_space[DMA_BUS_MODE / 4 + i] =
 			readl(ioaddr + DMA_BUS_MODE + i * 4);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 56e485f..3107d19 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -136,6 +136,9 @@
 #define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
 #define DMA_CONTROL_FTF		0x00100000	/* Flush transmit FIFO */
 
+#define NUM_DWMAC100_DMA_REGS	9
+#define NUM_DWMAC1000_DMA_REGS	23
+
 void dwmac_enable_dma_transmission(void __iomem *ioaddr);
 void dwmac_enable_dma_irq(void __iomem *ioaddr);
 void dwmac_disable_dma_irq(void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 690b7c1..2ffb5b1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -33,6 +33,8 @@
 #define MAC100_ETHTOOL_NAME	"st_mac100"
 #define GMAC_ETHTOOL_NAME	"st_gmac"
 
+#define ETHTOOL_DMA_OFFSET	55
+
 struct stmmac_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
@@ -443,6 +445,9 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	priv->hw->mac->dump_regs(priv->hw, reg_space);
 	priv->hw->dma->dump_regs(priv->ioaddr, reg_space);
+	/* Copy DMA registers to where ethtool expects them */
+	memcpy(&reg_space[ETHTOOL_DMA_OFFSET], &reg_space[DMA_BUS_MODE / 4],
+	       NUM_DWMAC1000_DMA_REGS * 4);
 }
 
 static void
-- 
2.7.4
