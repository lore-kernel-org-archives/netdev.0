From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 1/4] net: stmmac: break some functions into RX and TX scopes
Date: Tue,  4 Apr 2017 18:54:24 +0100
Message-ID: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
References: <cover.1491327063.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:41719 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932326AbdDDRyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:54:35 -0400
In-Reply-To: <cover.1491327063.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch breaks several functions into RX and TX scopes, which
will be useful when adding multiple buffers mechanism.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 350 +++++++++++++++++-----
 1 file changed, 268 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7cbda41..8e20e6f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -889,24 +889,41 @@ static int stmmac_init_phy(struct net_device *dev)
 	return 0;
 }
 
-static void stmmac_display_rings(struct stmmac_priv *priv)
+static void stmmac_display_rx_rings(struct stmmac_priv *priv)
 {
-	void *head_rx, *head_tx;
+	void *head_rx;
 
-	if (priv->extend_desc) {
+	if (priv->extend_desc)
 		head_rx = (void *)priv->dma_erx;
-		head_tx = (void *)priv->dma_etx;
-	} else {
+	else
 		head_rx = (void *)priv->dma_rx;
-		head_tx = (void *)priv->dma_tx;
-	}
 
-	/* Display Rx ring */
+	/* Display RX ring */
 	priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
-	/* Display Tx ring */
+}
+
+static void stmmac_display_tx_rings(struct stmmac_priv *priv)
+{
+	void *head_tx;
+
+	if (priv->extend_desc)
+		head_tx = (void *)priv->dma_etx;
+	else
+		head_tx = (void *)priv->dma_tx;
+
+	/* Display TX ring */
 	priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
 }
 
+static void stmmac_display_rings(struct stmmac_priv *priv)
+{
+	/* Display RX ring */
+	stmmac_display_rx_rings(priv);
+
+	/* Display TX ring */
+	stmmac_display_tx_rings(priv);
+}
+
 static int stmmac_set_bfsize(int mtu, int bufsize)
 {
 	int ret = bufsize;
@@ -924,16 +941,16 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 }
 
 /**
- * stmmac_clear_descriptors - clear descriptors
+ * stmmac_clear_rx_descriptors - clear RX descriptors
  * @priv: driver private structure
- * Description: this function is called to clear the tx and rx descriptors
+ * Description: this function is called to clear the rx descriptors
  * in case of both basic and extended descriptors are used.
  */
-static void stmmac_clear_descriptors(struct stmmac_priv *priv)
+static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv)
 {
 	int i;
 
-	/* Clear the Rx/Tx descriptors */
+	/* Clear the RX descriptors */
 	for (i = 0; i < DMA_RX_SIZE; i++)
 		if (priv->extend_desc)
 			priv->hw->desc->init_rx_desc(&priv->dma_erx[i].basic,
@@ -943,6 +960,19 @@ static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 			priv->hw->desc->init_rx_desc(&priv->dma_rx[i],
 						     priv->use_riwt, priv->mode,
 						     (i == DMA_RX_SIZE - 1));
+}
+
+/**
+ * stmmac_clear_tx_descriptors - clear tx descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv)
+{
+	int i;
+
+	/* Clear the TX descriptors */
 	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
 			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
@@ -955,6 +985,21 @@ static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 }
 
 /**
+ * stmmac_clear_descriptors - clear descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx and rx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void stmmac_clear_descriptors(struct stmmac_priv *priv)
+{
+	/* Clear the RX descriptors */
+	stmmac_clear_rx_descriptors(priv);
+
+	/* Clear the TX descriptors */
+	stmmac_clear_tx_descriptors(priv);
+}
+
+/**
  * stmmac_init_rx_buffers - init the RX descriptor buffer.
  * @priv: driver private structure
  * @p: descriptor pointer
@@ -996,6 +1041,11 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 	return 0;
 }
 
+/**
+ * stmmac_free_rx_buffers - free RX dma buffers
+ * @priv: private structure
+ * @i: buffer index.
+ */
 static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
 {
 	if (priv->rx_skbuff[i]) {
@@ -1007,14 +1057,42 @@ static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
 }
 
 /**
- * init_dma_desc_rings - init the RX/TX descriptor rings
+ * stmmac_free_tx_buffers - free RX dma buffers
+ * @priv: private structure
+ * @i: buffer index.
+ */
+static void stmmac_free_tx_buffers(struct stmmac_priv *priv, int i)
+{
+	if (priv->tx_skbuff_dma[i].buf) {
+		if (priv->tx_skbuff_dma[i].map_as_page)
+			dma_unmap_page(priv->device,
+				       priv->tx_skbuff_dma[i].buf,
+				       priv->tx_skbuff_dma[i].len,
+				       DMA_TO_DEVICE);
+		else
+			dma_unmap_single(priv->device,
+					 priv->tx_skbuff_dma[i].buf,
+					 priv->tx_skbuff_dma[i].len,
+					 DMA_TO_DEVICE);
+	}
+
+	if (priv->tx_skbuff[i]) {
+		dev_kfree_skb_any(priv->tx_skbuff[i]);
+		priv->tx_skbuff[i] = NULL;
+		priv->tx_skbuff_dma[i].buf = 0;
+		priv->tx_skbuff_dma[i].map_as_page = false;
+	}
+}
+
+/**
+ * init_dma_rx_desc_rings - init the RX descriptor rings
  * @dev: net device structure
  * @flags: gfp flag.
- * Description: this function initializes the DMA RX/TX descriptors
+ * Description: this function initializes the DMA RX descriptors
  * and allocates the socket buffers. It supports the chained and ring
  * modes.
  */
-static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
+static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
 {
 	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
@@ -1030,8 +1108,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	priv->dma_buf_sz = bfsize;
 
 	netif_dbg(priv, probe, priv->dev,
-		  "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
-		  __func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
+		  "(%s) dma_rx_phy=0x%08x\n", __func__, (u32)priv->dma_rx_phy);
 
 	/* RX INITIALIZATION */
 	netif_dbg(priv, probe, priv->dev,
@@ -1058,17 +1135,44 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	/* Setup the chained descriptor addresses */
 	if (priv->mode == STMMAC_CHAIN_MODE) {
-		if (priv->extend_desc) {
+		if (priv->extend_desc)
 			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
 					     DMA_RX_SIZE, 1);
-			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
-					     DMA_TX_SIZE, 1);
-		} else {
+		else
 			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
 					     DMA_RX_SIZE, 0);
+	}
+
+	return 0;
+err_init_rx_buffers:
+	while (--i >= 0)
+		stmmac_free_rx_buffers(priv, i);
+	return ret;
+}
+
+/**
+ * init_dma_tx_desc_rings - init the TX descriptor rings
+ * @dev: net device structure.
+ * Description: this function initializes the DMA TX descriptors
+ * and allocates the socket buffers. It supports the chained and ring
+ * modes.
+ */
+static int init_dma_tx_desc_rings(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int i;
+
+	netif_dbg(priv, probe, priv->dev,
+		  "(%s) dma_tx_phy=0x%08x\n", __func__, (u32)priv->dma_rx_phy);
+
+	/* Setup the chained descriptor addresses */
+	if (priv->mode == STMMAC_CHAIN_MODE) {
+		if (priv->extend_desc)
+			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
+					     DMA_TX_SIZE, 1);
+		else
 			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
 					     DMA_TX_SIZE, 0);
-		}
 	}
 
 	/* TX INITIALIZATION */
@@ -1099,18 +1203,42 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	priv->cur_tx = 0;
 	netdev_reset_queue(priv->dev);
 
+	return 0;
+}
+
+/**
+ * init_dma_desc_rings - init the RX/TX descriptor rings
+ * @dev: net device structure
+ * @flags: gfp flag.
+ * Description: this function initializes the DMA RX/TX descriptors
+ * and allocates the socket buffers. It supports the chained and ring
+ * modes.
+ */
+static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int ret;
+
+	/* RX INITIALIZATION */
+	ret = init_dma_rx_desc_rings(dev, flags);
+	if (ret)
+		return ret;
+
+	/* TX INITIALIZATION */
+	ret = init_dma_tx_desc_rings(dev);
+
 	stmmac_clear_descriptors(priv);
 
 	if (netif_msg_hw(priv))
 		stmmac_display_rings(priv);
 
-	return 0;
-err_init_rx_buffers:
-	while (--i >= 0)
-		stmmac_free_rx_buffers(priv, i);
 	return ret;
 }
 
+/**
+ * dma_free_rx_skbufs - free RX dma buffers
+ * @priv: private structure
+ */
 static void dma_free_rx_skbufs(struct stmmac_priv *priv)
 {
 	int i;
@@ -1119,42 +1247,27 @@ static void dma_free_rx_skbufs(struct stmmac_priv *priv)
 		stmmac_free_rx_buffers(priv, i);
 }
 
+/**
+ * dma_free_tx_skbufs - free TX dma buffers
+ * @priv: private structure
+ */
 static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 {
 	int i;
 
-	for (i = 0; i < DMA_TX_SIZE; i++) {
-		if (priv->tx_skbuff_dma[i].buf) {
-			if (priv->tx_skbuff_dma[i].map_as_page)
-				dma_unmap_page(priv->device,
-					       priv->tx_skbuff_dma[i].buf,
-					       priv->tx_skbuff_dma[i].len,
-					       DMA_TO_DEVICE);
-			else
-				dma_unmap_single(priv->device,
-						 priv->tx_skbuff_dma[i].buf,
-						 priv->tx_skbuff_dma[i].len,
-						 DMA_TO_DEVICE);
-		}
-
-		if (priv->tx_skbuff[i]) {
-			dev_kfree_skb_any(priv->tx_skbuff[i]);
-			priv->tx_skbuff[i] = NULL;
-			priv->tx_skbuff_dma[i].buf = 0;
-			priv->tx_skbuff_dma[i].map_as_page = false;
-		}
-	}
+	for (i = 0; i < DMA_TX_SIZE; i++)
+		stmmac_free_tx_buffers(priv, i);
 }
 
 /**
- * alloc_dma_desc_resources - alloc TX/RX resources.
+ * alloc_dma_rx_desc_resources - alloc RX resources.
  * @priv: private structure
  * Description: according to which descriptor can be used (extend or basic)
  * this function allocates the resources for TX and RX paths. In case of
  * reception, for example, it pre-allocated the RX socket buffer in order to
  * allow zero-copy mechanism.
  */
-static int alloc_dma_desc_resources(struct stmmac_priv *priv)
+static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
 {
 	int ret = -ENOMEM;
 
@@ -1168,11 +1281,50 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 	if (!priv->rx_skbuff)
 		goto err_rx_skbuff;
 
+	if (priv->extend_desc) {
+		priv->dma_erx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
+						    sizeof(struct
+							   dma_extended_desc),
+						    &priv->dma_rx_phy,
+						    GFP_KERNEL);
+		if (!priv->dma_erx)
+			goto err_dma;
+
+	} else {
+		priv->dma_rx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
+						   sizeof(struct dma_desc),
+						   &priv->dma_rx_phy,
+						   GFP_KERNEL);
+		if (!priv->dma_rx)
+			goto err_dma;
+	}
+
+	return 0;
+
+err_dma:
+	kfree(priv->rx_skbuff);
+err_rx_skbuff:
+	kfree(priv->rx_skbuff_dma);
+	return ret;
+}
+
+/**
+ * alloc_dma_tx_desc_resources - alloc TX resources.
+ * @priv: private structure
+ * Description: according to which descriptor can be used (extend or basic)
+ * this function allocates the resources for TX and RX paths. In case of
+ * reception, for example, it pre-allocated the RX socket buffer in order to
+ * allow zero-copy mechanism.
+ */
+static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
+{
+	int ret = -ENOMEM;
+
 	priv->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
 					    sizeof(*priv->tx_skbuff_dma),
 					    GFP_KERNEL);
 	if (!priv->tx_skbuff_dma)
-		goto err_tx_skbuff_dma;
+		return -ENOMEM;
 
 	priv->tx_skbuff = kmalloc_array(DMA_TX_SIZE, sizeof(struct sk_buff *),
 					GFP_KERNEL);
@@ -1180,14 +1332,6 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 		goto err_tx_skbuff;
 
 	if (priv->extend_desc) {
-		priv->dma_erx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						    sizeof(struct
-							   dma_extended_desc),
-						    &priv->dma_rx_phy,
-						    GFP_KERNEL);
-		if (!priv->dma_erx)
-			goto err_dma;
-
 		priv->dma_etx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
 						    sizeof(struct
 							   dma_extended_desc),
@@ -1200,13 +1344,6 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 			goto err_dma;
 		}
 	} else {
-		priv->dma_rx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						   sizeof(struct dma_desc),
-						   &priv->dma_rx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_rx)
-			goto err_dma;
-
 		priv->dma_tx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
 						   sizeof(struct dma_desc),
 						   &priv->dma_tx_phy,
@@ -1225,42 +1362,91 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 	kfree(priv->tx_skbuff);
 err_tx_skbuff:
 	kfree(priv->tx_skbuff_dma);
-err_tx_skbuff_dma:
-	kfree(priv->rx_skbuff);
-err_rx_skbuff:
-	kfree(priv->rx_skbuff_dma);
 	return ret;
 }
 
-static void free_dma_desc_resources(struct stmmac_priv *priv)
+/**
+ * alloc_dma_desc_resources - alloc TX/RX resources.
+ * @priv: private structure
+ * Description: according to which descriptor can be used (extend or basic)
+ * this function allocates the resources for TX and RX paths. In case of
+ * reception, for example, it pre-allocated the RX socket buffer in order to
+ * allow zero-copy mechanism.
+ */
+static int alloc_dma_desc_resources(struct stmmac_priv *priv)
+{
+	/* RX Allocation */
+	int ret = alloc_dma_rx_desc_resources(priv);
+
+	if (ret)
+		return ret;
+
+	/* TX Allocation */
+	ret = alloc_dma_tx_desc_resources(priv);
+
+	return ret;
+}
+
+/**
+ * free_dma_rx_desc_resources - free RX dma desc resources
+ * @priv: private structure
+ */
+static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
 {
-	/* Release the DMA TX/RX socket buffers */
+	/* Release the DMA RX socket buffers */
 	dma_free_rx_skbufs(priv);
-	dma_free_tx_skbufs(priv);
 
 	/* Free DMA regions of consistent memory previously allocated */
-	if (!priv->extend_desc) {
-		dma_free_coherent(priv->device,
-				  DMA_TX_SIZE * sizeof(struct dma_desc),
-				  priv->dma_tx, priv->dma_tx_phy);
+	if (!priv->extend_desc)
 		dma_free_coherent(priv->device,
 				  DMA_RX_SIZE * sizeof(struct dma_desc),
 				  priv->dma_rx, priv->dma_rx_phy);
-	} else {
-		dma_free_coherent(priv->device, DMA_TX_SIZE *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_etx, priv->dma_tx_phy);
+	else
 		dma_free_coherent(priv->device, DMA_RX_SIZE *
 				  sizeof(struct dma_extended_desc),
 				  priv->dma_erx, priv->dma_rx_phy);
-	}
+
 	kfree(priv->rx_skbuff_dma);
 	kfree(priv->rx_skbuff);
+}
+
+/**
+ * free_dma_tx_desc_resources - free TX dma desc resources
+ * @priv: private structure
+ */
+static void free_dma_tx_desc_resources(struct stmmac_priv *priv)
+{
+	/* Release the DMA TX socket buffers */
+	dma_free_tx_skbufs(priv);
+
+	/* Free DMA regions of consistent memory previously allocated */
+	if (!priv->extend_desc)
+		dma_free_coherent(priv->device,
+				  DMA_TX_SIZE * sizeof(struct dma_desc),
+				  priv->dma_tx, priv->dma_tx_phy);
+	else
+		dma_free_coherent(priv->device, DMA_TX_SIZE *
+				  sizeof(struct dma_extended_desc),
+				  priv->dma_etx, priv->dma_tx_phy);
+
 	kfree(priv->tx_skbuff_dma);
 	kfree(priv->tx_skbuff);
 }
 
 /**
+ * free_dma_desc_resources - free dma desc resources
+ * @priv: private structure
+ */
+static void free_dma_desc_resources(struct stmmac_priv *priv)
+{
+	/* Release the DMA RX socket buffers */
+	free_dma_rx_desc_resources(priv);
+
+	/* Release the DMA TX socket buffers */
+	free_dma_tx_desc_resources(priv);
+}
+
+/**
  *  stmmac_mac_enable_rx_queues - Enable MAC rx queues
  *  @priv: driver private structure
  *  Description: It is used for enabling the rx queues in the MAC
-- 
2.9.3
