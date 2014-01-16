From: <srinivas.kandagatla@st.com>
Subject: [PATCH v2 3/9] net: stmmac: move dma allocation to new function
Date: Thu, 16 Jan 2014 10:52:06 +0000
Message-ID: <1389869526-28136-1-git-send-email-srinivas.kandagatla@st.com>
References: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:54300 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752013AbaAPK5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 05:57:49 -0500
In-Reply-To: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch moves dma resource allocation to a new function
alloc_dma_desc_resources, the reason for moving this to a new function
is to keep the memory allocations in a separate function. One more reason
it to get suspend and hibernation cases working without releasing and
allocating these resources during suspend-resume and freeze-restore
cases.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  169 +++++++++++----------
 1 files changed, 85 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 15192c0..532f2b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -996,66 +996,6 @@ static int init_dma_desc_rings(struct net_device *dev)
 		pr_debug("%s: txsize %d, rxsize %d, bfsize %d\n", __func__,
 			 txsize, rxsize, bfsize);
 
-	if (priv->extend_desc) {
-		priv->dma_erx = dma_alloc_coherent(priv->device, rxsize *
-						   sizeof(struct
-							  dma_extended_desc),
-						   &priv->dma_rx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_erx)
-			goto err_dma;
-
-		priv->dma_etx = dma_alloc_coherent(priv->device, txsize *
-						   sizeof(struct
-							  dma_extended_desc),
-						   &priv->dma_tx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_etx) {
-			dma_free_coherent(priv->device, priv->dma_rx_size *
-					sizeof(struct dma_extended_desc),
-					priv->dma_erx, priv->dma_rx_phy);
-			goto err_dma;
-		}
-	} else {
-		priv->dma_rx = dma_alloc_coherent(priv->device, rxsize *
-						  sizeof(struct dma_desc),
-						  &priv->dma_rx_phy,
-						  GFP_KERNEL);
-		if (!priv->dma_rx)
-			goto err_dma;
-
-		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
-						  sizeof(struct dma_desc),
-						  &priv->dma_tx_phy,
-						  GFP_KERNEL);
-		if (!priv->dma_tx) {
-			dma_free_coherent(priv->device, priv->dma_rx_size *
-					sizeof(struct dma_desc),
-					priv->dma_rx, priv->dma_rx_phy);
-			goto err_dma;
-		}
-	}
-
-	priv->rx_skbuff_dma = kmalloc_array(rxsize, sizeof(dma_addr_t),
-					    GFP_KERNEL);
-	if (!priv->rx_skbuff_dma)
-		goto err_rx_skbuff_dma;
-
-	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
-					GFP_KERNEL);
-	if (!priv->rx_skbuff)
-		goto err_rx_skbuff;
-
-	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
-					    GFP_KERNEL);
-	if (!priv->tx_skbuff_dma)
-		goto err_tx_skbuff_dma;
-
-	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
-					GFP_KERNEL);
-	if (!priv->tx_skbuff)
-		goto err_tx_skbuff;
-
 	if (netif_msg_probe(priv)) {
 		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
 			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
@@ -1123,30 +1063,6 @@ static int init_dma_desc_rings(struct net_device *dev)
 err_init_rx_buffers:
 	while (--i >= 0)
 		stmmac_free_rx_buffers(priv, i);
-	kfree(priv->tx_skbuff);
-err_tx_skbuff:
-	kfree(priv->tx_skbuff_dma);
-err_tx_skbuff_dma:
-	kfree(priv->rx_skbuff);
-err_rx_skbuff:
-	kfree(priv->rx_skbuff_dma);
-err_rx_skbuff_dma:
-	if (priv->extend_desc) {
-		dma_free_coherent(priv->device, priv->dma_tx_size *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_etx, priv->dma_tx_phy);
-		dma_free_coherent(priv->device, priv->dma_rx_size *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_erx, priv->dma_rx_phy);
-	} else {
-		dma_free_coherent(priv->device,
-				priv->dma_tx_size * sizeof(struct dma_desc),
-				priv->dma_tx, priv->dma_tx_phy);
-		dma_free_coherent(priv->device,
-				priv->dma_rx_size * sizeof(struct dma_desc),
-				priv->dma_rx, priv->dma_rx_phy);
-	}
-err_dma:
 	return ret;
 }
 
@@ -1182,6 +1098,85 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 	}
 }
 
+static int alloc_dma_desc_resources(struct stmmac_priv *priv)
+{
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
+	int ret = -ENOMEM;
+
+	priv->rx_skbuff_dma = kmalloc_array(rxsize, sizeof(dma_addr_t),
+					    GFP_KERNEL);
+	if (!priv->rx_skbuff_dma)
+		return -ENOMEM;
+
+	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
+					GFP_KERNEL);
+	if (!priv->rx_skbuff)
+		goto err_rx_skbuff;
+
+	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
+					    GFP_KERNEL);
+	if (!priv->tx_skbuff_dma)
+		goto err_tx_skbuff_dma;
+
+	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
+					GFP_KERNEL);
+	if (!priv->tx_skbuff)
+		goto err_tx_skbuff;
+
+	if (priv->extend_desc) {
+		priv->dma_erx = dma_alloc_coherent(priv->device, rxsize *
+						   sizeof(struct
+							  dma_extended_desc),
+						   &priv->dma_rx_phy,
+						   GFP_KERNEL);
+		if (!priv->dma_erx)
+			goto err_dma;
+
+		priv->dma_etx = dma_alloc_coherent(priv->device, txsize *
+						   sizeof(struct
+							  dma_extended_desc),
+						   &priv->dma_tx_phy,
+						   GFP_KERNEL);
+		if (!priv->dma_etx) {
+			dma_free_coherent(priv->device, priv->dma_rx_size *
+					sizeof(struct dma_extended_desc),
+					priv->dma_erx, priv->dma_rx_phy);
+			goto err_dma;
+		}
+	} else {
+		priv->dma_rx = dma_alloc_coherent(priv->device, rxsize *
+						  sizeof(struct dma_desc),
+						  &priv->dma_rx_phy,
+						  GFP_KERNEL);
+		if (!priv->dma_rx)
+			goto err_dma;
+
+		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
+						  sizeof(struct dma_desc),
+						  &priv->dma_tx_phy,
+						  GFP_KERNEL);
+		if (!priv->dma_tx) {
+			dma_free_coherent(priv->device, priv->dma_rx_size *
+					sizeof(struct dma_desc),
+					priv->dma_rx, priv->dma_rx_phy);
+			goto err_dma;
+		}
+	}
+
+	return 0;
+
+err_dma:
+	kfree(priv->tx_skbuff);
+err_tx_skbuff:
+	kfree(priv->tx_skbuff_dma);
+err_tx_skbuff_dma:
+	kfree(priv->rx_skbuff);
+err_rx_skbuff:
+	kfree(priv->rx_skbuff_dma);
+	return ret;
+}
+
 static void free_dma_desc_resources(struct stmmac_priv *priv)
 {
 	/* Release the DMA TX/RX socket buffers */
@@ -1623,6 +1618,12 @@ static int stmmac_open(struct net_device *dev)
 	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 
+	alloc_dma_desc_resources(priv);
+	if (ret < 0) {
+		pr_err("%s: DMA descriptors allocation failed\n", __func__);
+		goto dma_desc_error;
+	}
+
 	ret = init_dma_desc_rings(dev);
 	if (ret < 0) {
 		pr_err("%s: DMA descriptors initialization failed\n", __func__);
-- 
1.7.6.5
