From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: reduce queue lengths if MTU is very large
Date: Mon, 19 Dec 2011 06:45:30 +0100
Message-ID: <1324273530-18499-1-git-send-email-peppe.cavallaro@st.com>
Cc: rubini@gnudd.com, giancarlo.asnaghi@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39654 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab1LSFpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 00:45:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alessandro Rubini <rubini@gnudd.com>

In my use case (STA2X11 IO-Hub), the alloc_coherent, map_single and
friends map to a reserved area set up in swiotlb.  With the default
MTU each packet takes 2kB, but with jumbo frames it increases to 16kB
and consumes up my area (it takes 8MB instead of 1MB).

Instead of increasing the reserved (== wasted) preallocated area in
swiotlb, this patch rescales the user-selected queue lengths if the MTU
is modified at runtime to be larger than the default. User choices
are still obeyed (compiled default, module parameter, command line)

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 72cd190..e8ebb6e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -413,9 +413,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct sk_buff *skb;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int bfsize;
+	unsigned int txsize, rxsize;
+	unsigned int bfsize = priv->dma_buf_sz;
 	int dis_ic = 0;
 	int des3_as_data_buf = 0;
 
@@ -428,6 +427,20 @@ static void init_dma_desc_rings(struct net_device *dev)
 	else
 		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
 
+	/*
+	 * If we use jumbo frames, we end up consuming too much memory
+	 * in the coherent buffer, so reduce the queue lenght according
+	 * to the increase in frame size over the default.
+	 */
+	i = bfsize / BUF_SIZE_2KiB;
+	if (i > 1) {
+		pr_warning("%s: reducing queue length by %i\n", __func__, i);
+		priv->dma_tx_size /= i;
+		priv->dma_rx_size /= i;
+	}
+	txsize = priv->dma_tx_size;
+	rxsize = priv->dma_rx_size;
+
 #ifdef CONFIG_STMMAC_TIMER
 	/* Disable interrupts on completion for the reception if timer is on */
 	if (likely(priv->tm->enable))
-- 
1.7.4.4
