From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: systemport: rewrite bcm_sysport_rx_refill
Date: Thu, 28 May 2015 15:24:43 -0700
Message-ID: <1432851884-12026-3-git-send-email-f.fainelli@gmail.com>
References: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34203 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbbE1WZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 18:25:27 -0400
Received: by pdbki1 with SMTP id ki1so51367579pdb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 15:25:26 -0700 (PDT)
In-Reply-To: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bcm_sysport_desc_rx() calls bcm_sysport_rx_refill() at the end of Rx
packet processing loop, after the current Rx packet has already been passed to
napi_gro_receive(). However, bcm_sysport_rx_refill() might fail to allocate a new
Rx skb, thus leaving a hole on the Rx queue where no valid Rx buffer exists.

To eliminate this situation:

1. Rewrite bcm_sysport_rx_refill() to retain the current Rx skb on the
Rx queue if a new replacement Rx skb can't be allocated and DMA-mapped.
In this case, the data on the current Rx skb is effectively dropped.

2. Modify bcm_sysport_desc_rx() to call bcm_sysport_rx_refill() at the
top of Rx packet processing loop, so that the new replacement Rx skb is
already in place before the current Rx skb is processed.

This is loosely inspired from d6707bec5986 ("net: bcmgenet: rewrite
bcmgenet_rx_refill()")

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 81 +++++++++++++++---------------
 1 file changed, 41 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 267330ccd595..d777b0db9e63 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -524,62 +524,70 @@ static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
 	dma_unmap_addr_set(cb, dma_addr, 0);
 }
 
-static int bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
-				 struct bcm_sysport_cb *cb)
+static struct sk_buff *bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
+					     struct bcm_sysport_cb *cb)
 {
 	struct device *kdev = &priv->pdev->dev;
 	struct net_device *ndev = priv->netdev;
+	struct sk_buff *skb, *rx_skb;
 	dma_addr_t mapping;
-	int ret;
 
-	cb->skb = netdev_alloc_skb(priv->netdev, RX_BUF_LENGTH);
-	if (!cb->skb) {
+	/* Allocate a new SKB for a new packet */
+	skb = netdev_alloc_skb(priv->netdev, RX_BUF_LENGTH);
+	if (!skb) {
+		priv->mib.alloc_rx_buff_failed++;
 		netif_err(priv, rx_err, ndev, "SKB alloc failed\n");
-		return -ENOMEM;
+		return NULL;
 	}
 
-	mapping = dma_map_single(kdev, cb->skb->data,
+	mapping = dma_map_single(kdev, skb->data,
 				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
-	ret = dma_mapping_error(kdev, mapping);
-	if (ret) {
+	if (dma_mapping_error(kdev, mapping)) {
 		priv->mib.rx_dma_failed++;
-		bcm_sysport_free_cb(cb);
+		dev_kfree_skb_any(skb);
 		netif_err(priv, rx_err, ndev, "DMA mapping failure\n");
-		return ret;
+		return NULL;
 	}
 
+	/* Grab the current SKB on the ring */
+	rx_skb = cb->skb;
+	if (likely(rx_skb))
+		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
+				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
+
+	/* Put the new SKB on the ring */
+	cb->skb = skb;
 	dma_unmap_addr_set(cb, dma_addr, mapping);
 	dma_desc_set_addr(priv, cb->bd_addr, mapping);
 
 	netif_dbg(priv, rx_status, ndev, "RX refill\n");
 
-	return 0;
+	/* Return the current SKB to the caller */
+	return rx_skb;
 }
 
 static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
 {
 	struct bcm_sysport_cb *cb;
-	int ret = 0;
+	struct sk_buff *skb;
 	unsigned int i;
 
 	for (i = 0; i < priv->num_rx_bds; i++) {
 		cb = &priv->rx_cbs[i];
-		if (cb->skb)
-			continue;
-
-		ret = bcm_sysport_rx_refill(priv, cb);
-		if (ret)
-			break;
+		skb = bcm_sysport_rx_refill(priv, cb);
+		if (skb)
+			dev_kfree_skb(skb);
+		if (!cb->skb)
+			return -ENOMEM;
 	}
 
-	return ret;
+	return 0;
 }
 
 /* Poll the hardware for up to budget packets to process */
 static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 					unsigned int budget)
 {
-	struct device *kdev = &priv->pdev->dev;
 	struct net_device *ndev = priv->netdev;
 	unsigned int processed = 0, to_process;
 	struct bcm_sysport_cb *cb;
@@ -587,7 +595,6 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	unsigned int p_index;
 	u16 len, status;
 	struct bcm_rsb *rsb;
-	int ret;
 
 	/* Determine how much we should process since last call */
 	p_index = rdma_readl(priv, RDMA_PROD_INDEX);
@@ -605,13 +612,8 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 
 	while ((processed < to_process) && (processed < budget)) {
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
-		skb = cb->skb;
-
-		processed++;
-		priv->rx_read_ptr++;
+		skb = bcm_sysport_rx_refill(priv, cb);
 
-		if (priv->rx_read_ptr == priv->num_rx_bds)
-			priv->rx_read_ptr = 0;
 
 		/* We do not have a backing SKB, so we do not a corresponding
 		 * DMA mapping for this incoming packet since
@@ -622,12 +624,9 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 			netif_err(priv, rx_err, ndev, "out of memory!\n");
 			ndev->stats.rx_dropped++;
 			ndev->stats.rx_errors++;
-			goto refill;
+			goto next;
 		}
 
-		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
-				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
-
 		/* Extract the Receive Status Block prepended */
 		rsb = (struct bcm_rsb *)skb->data;
 		len = (rsb->rx_status_len >> DESC_LEN_SHIFT) & DESC_LEN_MASK;
@@ -643,8 +642,8 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 			netif_err(priv, rx_status, ndev, "fragmented packet!\n");
 			ndev->stats.rx_dropped++;
 			ndev->stats.rx_errors++;
-			bcm_sysport_free_cb(cb);
-			goto refill;
+			dev_kfree_skb_any(skb);
+			goto next;
 		}
 
 		if (unlikely(status & (RX_STATUS_ERR | RX_STATUS_OVFLOW))) {
@@ -653,8 +652,8 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 				ndev->stats.rx_over_errors++;
 			ndev->stats.rx_dropped++;
 			ndev->stats.rx_errors++;
-			bcm_sysport_free_cb(cb);
-			goto refill;
+			dev_kfree_skb_any(skb);
+			goto next;
 		}
 
 		skb_put(skb, len);
@@ -681,10 +680,12 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		ndev->stats.rx_bytes += len;
 
 		napi_gro_receive(&priv->napi, skb);
-refill:
-		ret = bcm_sysport_rx_refill(priv, cb);
-		if (ret)
-			priv->mib.alloc_rx_buff_failed++;
+next:
+		processed++;
+		priv->rx_read_ptr++;
+
+		if (priv->rx_read_ptr == priv->num_rx_bds)
+			priv->rx_read_ptr = 0;
 	}
 
 	return processed;
-- 
2.1.0
