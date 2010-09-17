From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/4] stmmac: prevent dma init stuck in case of failures.
Date: Fri, 17 Sep 2010 15:23:41 +0200
Message-ID: <1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
References: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
 <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:41502 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753989Ab0IQNYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 09:24:13 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2DCC61B6
	for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 13:24:09 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id EE4022B17
	for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 13:24:08 +0000 (GMT)
In-Reply-To: <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a limit when perform the DMA reset procedure
so, in case of problems (i.e. PHY reset failed) the
Kernel won't hang on the stmmac DMA initialisation
blocking the Kernels execution.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/dwmac1000_dma.c |   10 +++++++++-
 drivers/net/stmmac/dwmac100_dma.c  |   10 +++++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 2ef5a56..ce6163e 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -33,10 +33,18 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 			      u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	int limit;
+
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
+	limit = 15000;
+	while (limit--) {
+		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
+			break;
+	}
+	if (limit < 0)
+		return -EBUSY;
 
 	value = /* DMA_BUS_MODE_FB | */ DMA_BUS_MODE_4PBL |
 	    ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/stmmac/dwmac100_dma.c
index c7279d2..96aac93 100644
--- a/drivers/net/stmmac/dwmac100_dma.c
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -35,10 +35,18 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 			     u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	int limit;
+
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
+	limit = 15000;
+	while (limit--) {
+		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
+			break;
+	}
+	if (limit < 0)
+		return -EBUSY;
 
 	/* Enable Application Access by writing to DMA CSR0 */
 	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
-- 
1.7.0.4

