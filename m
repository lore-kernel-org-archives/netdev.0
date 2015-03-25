From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 7/7] net: bcmgenet: add support for multiple Rx queues
Date: Wed, 25 Mar 2015 12:35:16 -0700 (PDT)
Message-ID: <20150325193516.417182201FC@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33810 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbCYTfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:18 -0400
Received: by igir2 with SMTP id r2so2440377igi.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for multiple Rx queues:
1. Add NAPI context per Rx queue
2. Modify Rx interrupt and Rx NAPI code to handle multiple Rx queues

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 170 +++++++++++++++++++------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  12 +-
 2 files changed, 137 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index dc3b1fa..31e1407 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -964,6 +964,34 @@ static void bcmgenet_free_cb(struct enet_cb *cb)
 	dma_unmap_addr_set(cb, dma_addr, 0);
 }
 
+static inline void bcmgenet_rx_ring16_int_disable(struct bcmgenet_rx_ring *ring)
+{
+	bcmgenet_intrl2_0_writel(ring->priv,
+				 UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE,
+				 INTRL2_CPU_MASK_SET);
+}
+
+static inline void bcmgenet_rx_ring16_int_enable(struct bcmgenet_rx_ring *ring)
+{
+	bcmgenet_intrl2_0_writel(ring->priv,
+				 UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE,
+				 INTRL2_CPU_MASK_CLEAR);
+}
+
+static inline void bcmgenet_rx_ring_int_disable(struct bcmgenet_rx_ring *ring)
+{
+	bcmgenet_intrl2_1_writel(ring->priv,
+				 1 << (UMAC_IRQ1_RX_INTR_SHIFT + ring->index),
+				 INTRL2_CPU_MASK_SET);
+}
+
+static inline void bcmgenet_rx_ring_int_enable(struct bcmgenet_rx_ring *ring)
+{
+	bcmgenet_intrl2_1_writel(ring->priv,
+				 1 << (UMAC_IRQ1_RX_INTR_SHIFT + ring->index),
+				 INTRL2_CPU_MASK_CLEAR);
+}
+
 static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_tx_ring *ring)
 {
 	bcmgenet_intrl2_0_writel(ring->priv,
@@ -1390,11 +1418,10 @@ static struct sk_buff *bcmgenet_rx_refill(struct bcmgenet_priv *priv,
 /* bcmgenet_desc_rx - descriptor based rx process.
  * this could be called from bottom half, or from NAPI polling method.
  */
-static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
-				     unsigned int index,
+static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 				     unsigned int budget)
 {
-	struct bcmgenet_rx_ring *ring = &priv->rx_rings[index];
+	struct bcmgenet_priv *priv = ring->priv;
 	struct net_device *dev = priv->dev;
 	struct enet_cb *cb;
 	struct sk_buff *skb;
@@ -1406,7 +1433,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 	unsigned int discards;
 	unsigned int chksum_ok = 0;
 
-	p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
+	p_index = bcmgenet_rdma_ring_readl(priv, ring->index, RDMA_PROD_INDEX);
 
 	discards = (p_index >> DMA_P_INDEX_DISCARD_CNT_SHIFT) &
 		   DMA_P_INDEX_DISCARD_CNT_MASK;
@@ -1419,7 +1446,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		/* Clear HW register when we reach 75% of maximum 0xFFFF */
 		if (ring->old_discards >= 0xC000) {
 			ring->old_discards = 0;
-			bcmgenet_rdma_ring_writel(priv, index, 0,
+			bcmgenet_rdma_ring_writel(priv, ring->index, 0,
 						  RDMA_PROD_INDEX);
 		}
 	}
@@ -1527,7 +1554,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 			dev->stats.multicast++;
 
 		/* Notify kernel */
-		napi_gro_receive(&priv->napi, skb);
+		napi_gro_receive(&ring->napi, skb);
 		netif_dbg(priv, rx_status, dev, "pushed up to kernel\n");
 
 next:
@@ -1538,7 +1565,7 @@ next:
 			ring->read_ptr = ring->cb_ptr;
 
 		ring->c_index = (ring->c_index + 1) & DMA_C_INDEX_MASK;
-		bcmgenet_rdma_ring_writel(priv, index, ring->c_index, RDMA_CONS_INDEX);
+		bcmgenet_rdma_ring_writel(priv, ring->index, ring->c_index, RDMA_CONS_INDEX);
 	}
 
 	return rxpktprocessed;
@@ -1547,17 +1574,15 @@ next:
 /* Rx NAPI polling method */
 static int bcmgenet_rx_poll(struct napi_struct *napi, int budget)
 {
-	struct bcmgenet_priv *priv = container_of(napi,
-			struct bcmgenet_priv, napi);
+	struct bcmgenet_rx_ring *ring = container_of(napi,
+			struct bcmgenet_rx_ring, napi);
 	unsigned int work_done;
 
-	work_done = bcmgenet_desc_rx(priv, DESC_INDEX, budget);
+	work_done = bcmgenet_desc_rx(ring, budget);
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
-					 UMAC_IRQ_RXDMA_PDONE,
-					 INTRL2_CPU_MASK_CLEAR);
+		ring->int_enable(ring);
 	}
 
 	return work_done;
@@ -1728,6 +1753,10 @@ static int init_umac(struct bcmgenet_priv *priv)
 	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
 		int0_enable |= (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
 
+	/* Enable Rx priority queue interrupts */
+	for (i = 0; i < priv->hw_params->rx_queues; ++i)
+		int1_enable |= (1 << (UMAC_IRQ1_RX_INTR_SHIFT + i));
+
 	/* Enable Tx priority queue interrupts */
 	for (i = 0; i < priv->hw_params->tx_queues; ++i)
 		int1_enable |= (1 << i);
@@ -1806,7 +1835,15 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	u32 words_per_bd = WORDS_PER_BD(priv);
 	int ret;
 
+	ring->priv = priv;
 	ring->index = index;
+	if (index == DESC_INDEX) {
+		ring->int_enable = bcmgenet_rx_ring16_int_enable;
+		ring->int_disable = bcmgenet_rx_ring16_int_disable;
+	} else {
+		ring->int_enable = bcmgenet_rx_ring_int_enable;
+		ring->int_disable = bcmgenet_rx_ring_int_disable;
+	}
 	ring->cbs = priv->rx_cbs + start_ptr;
 	ring->size = size;
 	ring->c_index = 0;
@@ -1972,22 +2009,58 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 
 static void bcmgenet_init_rx_napi(struct bcmgenet_priv *priv)
 {
-	netif_napi_add(priv->dev, &priv->napi, bcmgenet_rx_poll, 64);
+	unsigned int i;
+	struct bcmgenet_rx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
+		ring = &priv->rx_rings[i];
+		netif_napi_add(priv->dev, &ring->napi, bcmgenet_rx_poll, 64);
+	}
+
+	ring = &priv->rx_rings[DESC_INDEX];
+	netif_napi_add(priv->dev, &ring->napi, bcmgenet_rx_poll, 64);
 }
 
 static void bcmgenet_enable_rx_napi(struct bcmgenet_priv *priv)
 {
-	napi_enable(&priv->napi);
+	unsigned int i;
+	struct bcmgenet_rx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
+		ring = &priv->rx_rings[i];
+		napi_enable(&ring->napi);
+	}
+
+	ring = &priv->rx_rings[DESC_INDEX];
+	napi_enable(&ring->napi);
 }
 
 static void bcmgenet_disable_rx_napi(struct bcmgenet_priv *priv)
 {
-	napi_disable(&priv->napi);
+	unsigned int i;
+	struct bcmgenet_rx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
+		ring = &priv->rx_rings[i];
+		napi_disable(&ring->napi);
+	}
+
+	ring = &priv->rx_rings[DESC_INDEX];
+	napi_disable(&ring->napi);
 }
 
 static void bcmgenet_fini_rx_napi(struct bcmgenet_priv *priv)
 {
-	netif_napi_del(&priv->napi);
+	unsigned int i;
+	struct bcmgenet_rx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
+		ring = &priv->rx_rings[i];
+		netif_napi_del(&ring->napi);
+	}
+
+	ring = &priv->rx_rings[DESC_INDEX];
+	netif_napi_del(&ring->napi);
 }
 
 /* Initialize Rx queues
@@ -2214,50 +2287,66 @@ static void bcmgenet_irq_task(struct work_struct *work)
 	}
 }
 
-/* bcmgenet_isr1: interrupt handler for ring buffer. */
+/* bcmgenet_isr1: handle Rx and Tx priority queues */
 static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 {
 	struct bcmgenet_priv *priv = dev_id;
-	struct bcmgenet_tx_ring *ring;
+	struct bcmgenet_rx_ring *rx_ring;
+	struct bcmgenet_tx_ring *tx_ring;
 	unsigned int index;
 
 	/* Save irq status for bottom-half processing. */
 	priv->irq1_stat =
 		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_MASK_STATUS);
+
 	/* clear interrupts */
 	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
 		  "%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
 
-	/* Check the MBDONE interrupts.
-	 * packet is done, reclaim descriptors
-	 */
+	/* Check Rx priority queue interrupts */
+	for (index = 0; index < priv->hw_params->rx_queues; index++) {
+		if (!(priv->irq1_stat & BIT(UMAC_IRQ1_RX_INTR_SHIFT + index)))
+			continue;
+
+		rx_ring = &priv->rx_rings[index];
+
+		if (likely(napi_schedule_prep(&rx_ring->napi))) {
+			rx_ring->int_disable(rx_ring);
+			__napi_schedule(&rx_ring->napi);
+		}
+	}
+
+	/* Check Tx priority queue interrupts */
 	for (index = 0; index < priv->hw_params->tx_queues; index++) {
 		if (!(priv->irq1_stat & BIT(index)))
 			continue;
 
-		ring = &priv->tx_rings[index];
+		tx_ring = &priv->tx_rings[index];
 
-		if (likely(napi_schedule_prep(&ring->napi))) {
-			ring->int_disable(ring);
-			__napi_schedule(&ring->napi);
+		if (likely(napi_schedule_prep(&tx_ring->napi))) {
+			tx_ring->int_disable(tx_ring);
+			__napi_schedule(&tx_ring->napi);
 		}
 	}
 
 	return IRQ_HANDLED;
 }
 
-/* bcmgenet_isr0: Handle various interrupts. */
+/* bcmgenet_isr0: handle Rx and Tx default queues + other stuff */
 static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 {
 	struct bcmgenet_priv *priv = dev_id;
+	struct bcmgenet_rx_ring *rx_ring;
+	struct bcmgenet_tx_ring *tx_ring;
 
 	/* Save irq status for bottom-half processing. */
 	priv->irq0_stat =
 		bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
+
 	/* clear interrupts */
 	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
 
@@ -2265,26 +2354,23 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		  "IRQ=0x%x\n", priv->irq0_stat);
 
 	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
-		/* We use NAPI(software interrupt throttling, if
-		 * Rx Descriptor throttling is not used.
-		 * Disable interrupt, will be enabled in the poll method.
-		 */
-		if (likely(napi_schedule_prep(&priv->napi))) {
-			bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
-						 UMAC_IRQ_RXDMA_PDONE,
-						 INTRL2_CPU_MASK_SET);
-			__napi_schedule(&priv->napi);
+		rx_ring = &priv->rx_rings[DESC_INDEX];
+
+		if (likely(napi_schedule_prep(&rx_ring->napi))) {
+			rx_ring->int_disable(rx_ring);
+			__napi_schedule(&rx_ring->napi);
 		}
 	}
-	if (priv->irq0_stat &
-			(UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
-		struct bcmgenet_tx_ring *ring = &priv->tx_rings[DESC_INDEX];
 
-		if (likely(napi_schedule_prep(&ring->napi))) {
-			ring->int_disable(ring);
-			__napi_schedule(&ring->napi);
+	if (priv->irq0_stat & (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
+		tx_ring = &priv->tx_rings[DESC_INDEX];
+
+		if (likely(napi_schedule_prep(&tx_ring->napi))) {
+			tx_ring->int_disable(tx_ring);
+			__napi_schedule(&tx_ring->napi);
 		}
 	}
+
 	if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
 				UMAC_IRQ_PHY_DET_F |
 				UMAC_IRQ_LINK_UP |
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 7b11e7a..a834da1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -310,6 +310,11 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_MDIO_DONE		(1 << 23)
 #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
 
+/* INTRL2 instance 1 definitions */
+#define UMAC_IRQ1_TX_INTR_MASK		0xFFFF
+#define UMAC_IRQ1_RX_INTR_MASK		0xFFFF
+#define UMAC_IRQ1_RX_INTR_SHIFT		16
+
 /* Register block offsets */
 #define GENET_SYS_OFF			0x0000
 #define GENET_GR_BRIDGE_OFF		0x0040
@@ -541,6 +546,7 @@ struct bcmgenet_tx_ring {
 };
 
 struct bcmgenet_rx_ring {
+	struct napi_struct napi;	/* Rx NAPI struct */
 	unsigned int	index;		/* Rx ring index */
 	struct enet_cb	*cbs;		/* Rx ring buffer control block */
 	unsigned int	size;		/* Rx ring size */
@@ -549,6 +555,9 @@ struct bcmgenet_rx_ring {
 	unsigned int	cb_ptr;		/* Rx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Rx ring end CB ptr */
 	unsigned int	old_discards;
+	void (*int_enable)(struct bcmgenet_rx_ring *);
+	void (*int_disable)(struct bcmgenet_rx_ring *);
+	struct bcmgenet_priv *priv;
 };
 
 /* device context */
@@ -557,9 +566,6 @@ struct bcmgenet_priv {
 	enum bcmgenet_version version;
 	struct net_device *dev;
 
-	/* NAPI for descriptor based rx */
-	struct napi_struct napi ____cacheline_aligned;
-
 	/* transmit variables */
 	void __iomem *tx_bds;
 	struct enet_cb *tx_cbs;
-- 
2.2.0.rc0.207.ga3a616c
