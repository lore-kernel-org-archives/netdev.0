From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 2/7] net: bcmgenet: modify Tx ring int_enable and int_disable vectors
Date: Wed, 25 Mar 2015 12:35:10 -0700 (PDT)
Message-ID: <20150325193510.E280D2201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33915 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbbCYTfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:12 -0400
Received: by qgdq107 with SMTP id q107so2125120qgd.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary function parameter priv. Use ring->priv instead.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 26 +++++++++++---------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++----
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 030249d..550bf98 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -964,33 +964,29 @@ static void bcmgenet_free_cb(struct enet_cb *cb)
 	dma_unmap_addr_set(cb, dma_addr, 0);
 }
 
-static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_priv *priv,
-						  struct bcmgenet_tx_ring *ring)
+static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(priv,
+	bcmgenet_intrl2_0_writel(ring->priv,
 				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
 				 INTRL2_CPU_MASK_SET);
 }
 
-static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_priv *priv,
-						 struct bcmgenet_tx_ring *ring)
+static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(priv,
+	bcmgenet_intrl2_0_writel(ring->priv,
 				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
 				 INTRL2_CPU_MASK_CLEAR);
 }
 
-static inline void bcmgenet_tx_ring_int_enable(struct bcmgenet_priv *priv,
-					       struct bcmgenet_tx_ring *ring)
+static inline void bcmgenet_tx_ring_int_enable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
+	bcmgenet_intrl2_1_writel(ring->priv, 1 << ring->index,
 				 INTRL2_CPU_MASK_CLEAR);
 }
 
-static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
-						struct bcmgenet_tx_ring *ring)
+static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
+	bcmgenet_intrl2_1_writel(ring->priv, 1 << ring->index,
 				 INTRL2_CPU_MASK_SET);
 }
 
@@ -1083,7 +1079,7 @@ static int bcmgenet_tx_poll(struct napi_struct *napi, int budget)
 
 	if (work_done == 0) {
 		napi_complete(napi);
-		ring->int_enable(ring->priv, ring);
+		ring->int_enable(ring);
 
 		return 0;
 	}
@@ -2172,7 +2168,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 		ring = &priv->tx_rings[index];
 
 		if (likely(napi_schedule_prep(&ring->napi))) {
-			ring->int_disable(priv, ring);
+			ring->int_disable(ring);
 			__napi_schedule(&ring->napi);
 		}
 	}
@@ -2211,7 +2207,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		struct bcmgenet_tx_ring *ring = &priv->tx_rings[DESC_INDEX];
 
 		if (likely(napi_schedule_prep(&ring->napi))) {
-			ring->int_disable(priv, ring);
+			ring->int_disable(ring);
 			__napi_schedule(&ring->napi);
 		}
 	}
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index a9e1612..7b11e7a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -535,10 +535,8 @@ struct bcmgenet_tx_ring {
 	unsigned int	prod_index;	/* Tx ring producer index SW copy */
 	unsigned int	cb_ptr;		/* Tx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Tx ring end CB ptr */
-	void (*int_enable)(struct bcmgenet_priv *priv,
-			   struct bcmgenet_tx_ring *);
-	void (*int_disable)(struct bcmgenet_priv *priv,
-			    struct bcmgenet_tx_ring *);
+	void (*int_enable)(struct bcmgenet_tx_ring *);
+	void (*int_disable)(struct bcmgenet_tx_ring *);
 	struct bcmgenet_priv *priv;
 };
 
-- 
2.2.0.rc0.207.ga3a616c
