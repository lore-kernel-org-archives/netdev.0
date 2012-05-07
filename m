From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/2] stmmac: add mixed burst for DMA
Date: Mon,  7 May 2012 11:12:33 +0200
Message-ID: <1336381953-18041-2-git-send-email-peppe.cavallaro@st.com>
References: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:45555 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755906Ab2EGJMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 05:12:45 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 05F88BA
	for <netdev@vger.kernel.org>; Mon,  7 May 2012 09:12:43 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8D38F23AE
	for <netdev@vger.kernel.org>; Mon,  7 May 2012 09:12:43 +0000 (GMT)
In-Reply-To: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mixed burst (MB) mode, the AHB master always initiates
the bursts with fixed-size when the DMA requests transfers
of size less than or equal to 16 beats.
This patch adds the MB support and the flag that can be
passed from the platform to select it.
MB mode can also give some benefits in terms of performances
on some platforms.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 +++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    6 ++++--
 include/linux/stmmac.h                             |    1 +
 6 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7164509..b343b71 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -247,8 +247,8 @@ struct stmmac_desc_ops {
 
 struct stmmac_dma_ops {
 	/* DMA core initialization */
-	int (*init) (void __iomem *ioaddr, int pbl, int fb, int burst_len,
-			u32 dma_tx, u32 dma_rx);
+	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
+			int burst_len, u32 dma_tx, u32 dma_rx);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 53ed56b..f02162f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -141,6 +141,7 @@ enum rx_tx_priority_ratio {
 };
 
 #define DMA_BUS_MODE_FB		0x00010000	/* Fixed burst */
+#define DMA_BUS_MODE_MB		0x04000000	/* Mixed burst */
 #define DMA_BUS_MODE_RPBL_MASK	0x003e0000	/* Rx-Programmable Burst Len */
 #define DMA_BUS_MODE_RPBL_SHIFT	17
 #define DMA_BUS_MODE_USP	0x00800000
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 3675c57..15e1aa1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -30,7 +30,7 @@
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
-static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
+static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 			      int burst_len, u32 dma_tx, u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
@@ -66,6 +66,10 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
 	if (fb)
 		value |= DMA_BUS_MODE_FB;
 
+	/* Mixed Burst has no effect when fb is set */
+	if (mb)
+		value |= DMA_BUS_MODE_MB;
+
 #ifdef CONFIG_STMMAC_DA
 	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
 #endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 92ed2e0..e4eca62 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -32,7 +32,7 @@
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
-static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb,
+static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 			     int burst_len, u32 dma_tx, u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a9699ae..4fd62ff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -924,7 +924,8 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 
 static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
-	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
+	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0,
+	    mixed_burst = 0;
 
 	/* Some DMA parameters can be passed from the platform;
 	 * in case of these are not passed we keep a default
@@ -932,10 +933,11 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 	if (priv->plat->dma_cfg) {
 		pbl = priv->plat->dma_cfg->pbl;
 		fixed_burst = priv->plat->dma_cfg->fixed_burst;
+		mixed_burst = priv->plat->dma_cfg->mixed_burst;
 		burst_len = priv->plat->dma_cfg->burst_len;
 	}
 
-	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst,
+	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
 				   burst_len, priv->dma_tx_phy,
 				   priv->dma_rx_phy);
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index f85c93d..b69bdb1 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -86,6 +86,7 @@ struct stmmac_mdio_bus_data {
 struct stmmac_dma_cfg {
 	int pbl;
 	int fixed_burst;
+	int mixed_burst;
 	int burst_len;
 };
 
-- 
1.7.4.4
