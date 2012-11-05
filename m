From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Mon,  5 Nov 2012 10:22:23 -0600
Message-ID: <1352132544-15809-6-git-send-email-robherring2@gmail.com>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33164 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab2KEQWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:22:48 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so5859114obb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:22:48 -0800 (PST)
In-Reply-To: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Only generate tx interrupts on every ring size / 4 descriptors. Move the
netif_stop_queue call to the end of the xmit function rather than
checking at the beginning.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 8263219..362b35e 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -211,7 +211,7 @@
 #define DMA_INTR_ENA_TIE	0x00000001	/* Transmit Interrupt */
 
 #define DMA_INTR_NORMAL		(DMA_INTR_ENA_NIE | DMA_INTR_ENA_RIE | \
-				 DMA_INTR_ENA_TUE)
+				 DMA_INTR_ENA_TUE | DMA_INTR_ENA_TIE)
 
 #define DMA_INTR_ABNORMAL	(DMA_INTR_ENA_AIE | DMA_INTR_ENA_FBE | \
 				 DMA_INTR_ENA_RWE | DMA_INTR_ENA_RSE | \
@@ -374,6 +374,7 @@ struct xgmac_priv {
 	struct sk_buff **tx_skbuff;
 	unsigned int tx_head;
 	unsigned int tx_tail;
+	int tx_irq_cnt;
 
 	void __iomem *base;
 	unsigned int dma_buf_sz;
@@ -886,7 +887,7 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 	}
 
 	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) >
-	    TX_THRESH)
+	    MAX_SKB_FRAGS)
 		netif_wake_queue(priv->dev);
 }
 
@@ -1057,19 +1058,15 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct xgmac_priv *priv = netdev_priv(dev);
 	unsigned int entry;
 	int i;
+	u32 irq_flag;
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	struct xgmac_dma_desc *desc, *first;
 	unsigned int desc_flags;
 	unsigned int len;
 	dma_addr_t paddr;
 
-	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
-	    (nfrags + 1)) {
-		writel(DMA_INTR_DEFAULT_MASK | DMA_INTR_ENA_TIE,
-			priv->base + XGMAC_DMA_INTR_ENA);
-		netif_stop_queue(dev);
-		return NETDEV_TX_BUSY;
-	}
+	priv->tx_irq_cnt = (priv->tx_irq_cnt + 1) & (DMA_TX_RING_SZ/4 - 1);
+	irq_flag = priv->tx_irq_cnt ? 0 : TXDESC_INTERRUPT;
 
 	desc_flags = (skb->ip_summed == CHECKSUM_PARTIAL) ?
 		TXDESC_CSUM_ALL : 0;
@@ -1110,9 +1107,9 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Interrupt on completition only for the latest segment */
 	if (desc != first)
 		desc_set_tx_owner(desc, desc_flags |
-			TXDESC_LAST_SEG | TXDESC_INTERRUPT);
+			TXDESC_LAST_SEG | irq_flag);
 	else
-		desc_flags |= TXDESC_LAST_SEG | TXDESC_INTERRUPT;
+		desc_flags |= TXDESC_LAST_SEG | irq_flag;
 
 	/* Set owner on first desc last to avoid race condition */
 	wmb();
@@ -1121,6 +1118,9 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
 
 	writel(1, priv->base + XGMAC_DMA_TX_POLL);
+	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
+	    MAX_SKB_FRAGS)
+		netif_stop_queue(dev);
 
 	return NETDEV_TX_OK;
 }
@@ -1397,7 +1397,7 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 	}
 
 	/* TX/RX NORMAL interrupts */
-	if (intr_status & (DMA_STATUS_RI | DMA_STATUS_TU)) {
+	if (intr_status & (DMA_STATUS_RI | DMA_STATUS_TU | DMA_STATUS_TI)) {
 		__raw_writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
 		napi_schedule(&priv->napi);
 	}
-- 
1.7.10.4
