From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 3/3] net: stmmac: Prefer kcalloc() over kmalloc_array()
Date: Tue, 28 Mar 2017 15:57:06 +0200
Message-ID: <20170328135706.7605-3-thierry.reding@gmail.com>
References: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
 <20170328135706.7605-1-thierry.reding@gmail.com>
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>, clabbe.montjoie@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33778 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755671AbdC1N6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:58:08 -0400
Received: by mail-wr0-f195.google.com with SMTP id u18so3521044wrc.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 06:57:26 -0700 (PDT)
In-Reply-To: <20170328135706.7605-1-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

Some of the data in the new queue structures seems to not be properly
initialized, causing undefined behaviour (networking will work about 2
out of 10 tries). kcalloc() will zero the allocated memory and results
in 10 out of 10 successful boots.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 37 +++++++++++------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ec5bba85c529..845320bc3333 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1412,13 +1412,12 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 static int alloc_rx_dma_desc_resources(struct stmmac_priv *priv)
 {
 	u32 rx_count = priv->plat->rx_queues_to_use;
+	struct stmmac_rx_queue *rx_q;
 	int ret = -ENOMEM;
 	u32 queue = 0;
 
 	/* Allocate RX queues array */
-	priv->rx_queue = kmalloc_array(rx_count,
-				       sizeof(struct stmmac_rx_queue),
-				       GFP_KERNEL);
+	priv->rx_queue = kcalloc(rx_count, sizeof(*rx_q), GFP_KERNEL);
 	if (!priv->rx_queue) {
 		kfree(priv->rx_queue);
 		return -ENOMEM;
@@ -1426,20 +1425,19 @@ static int alloc_rx_dma_desc_resources(struct stmmac_priv *priv)
 
 	/* RX queues buffers and DMA */
 	for (queue = 0; queue < rx_count; queue++) {
-		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+		rx_q = &priv->rx_queue[queue];
 
 		rx_q->queue_index = queue;
 		rx_q->priv_data = priv;
 
-		rx_q->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE,
-							sizeof(dma_addr_t),
-							GFP_KERNEL);
+		rx_q->rx_skbuff_dma = kcalloc(DMA_RX_SIZE, sizeof(dma_addr_t),
+					      GFP_KERNEL);
 		if (!rx_q->rx_skbuff_dma)
 			goto err_dma_buffers;
 
-		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
-						    sizeof(struct sk_buff *),
-						    GFP_KERNEL);
+		rx_q->rx_skbuff = kcalloc(DMA_RX_SIZE,
+					  sizeof(struct sk_buff *),
+					  GFP_KERNEL);
 		if (!rx_q->rx_skbuff)
 			goto err_dma_buffers;
 
@@ -1477,33 +1475,32 @@ static int alloc_rx_dma_desc_resources(struct stmmac_priv *priv)
 static int alloc_tx_dma_desc_resources(struct stmmac_priv *priv)
 {
 	u32 tx_count = priv->plat->tx_queues_to_use;
+	struct stmmac_tx_queue *tx_q;
 	int ret = -ENOMEM;
 	u32 queue = 0;
 
 	/* Allocate TX queues array */
-	priv->tx_queue = kmalloc_array(tx_count,
-				       sizeof(struct stmmac_tx_queue),
-				       GFP_KERNEL);
+	priv->tx_queue = kcalloc(tx_count, sizeof(*tx_q), GFP_KERNEL);
 	if (!priv->tx_queue)
 		return -ENOMEM;
 
 	/* TX queues buffers and DMA */
 	for (queue = 0; queue < tx_count; queue++) {
-		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+		tx_q = &priv->tx_queue[queue];
 
 		tx_q->queue_index = queue;
 		tx_q->priv_data = priv;
 
-		tx_q->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
-					  sizeof(struct stmmac_tx_info),
-					  GFP_KERNEL);
+		tx_q->tx_skbuff_dma = kcalloc(DMA_TX_SIZE,
+					      sizeof(struct stmmac_tx_info),
+					      GFP_KERNEL);
 
 		if (!tx_q->tx_skbuff_dma)
 			goto err_dma_buffers;
 
-		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
-						    sizeof(struct sk_buff *),
-						    GFP_KERNEL);
+		tx_q->tx_skbuff = kcalloc(DMA_TX_SIZE,
+					  sizeof(struct sk_buff *),
+					  GFP_KERNEL);
 		if (!tx_q->tx_skbuff)
 			goto err_dma_buffers;
 
-- 
2.12.0
