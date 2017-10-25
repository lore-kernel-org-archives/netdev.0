From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 5/9] net: bcmgenet: cleanup ring interrupt masking and unmasking
Date: Wed, 25 Oct 2017 15:04:15 -0700
Message-ID: <20171025220419.24951-6-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:53361 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932329AbdJYWFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:05:12 -0400
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the NAPI interrupts are basically ignored when NAPI is
disabled we don't need to mask them within the functions
bcmgenet_disable_tx_napi() and bcmgenet_disable_rx_napi().
So wait until all NAPI instances are disabled and mask all of the
bcmgenet driver interrupts together in bcmgenet_netif_stop().

The interrupts can still be enabled in the functions
bcmgenet_enable_tx_napi() and bcmgenet_enable_rx_napi(), but use
the ring context int_enable() method to keep the functionality
consistent and the code cleaner.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 28 +++++---------------------
 1 file changed, 5 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9ce6671e8916..88aacf3bf44f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2147,33 +2147,24 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 static void bcmgenet_enable_tx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
-	u32 int0_enable = UMAC_IRQ_TXDMA_DONE;
-	u32 int1_enable = 0;
 	struct bcmgenet_tx_ring *ring;
 
 	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
 		ring = &priv->tx_rings[i];
 		napi_enable(&ring->napi);
-		int1_enable |= (1 << i);
+		ring->int_enable(ring);
 	}
 
 	ring = &priv->tx_rings[DESC_INDEX];
 	napi_enable(&ring->napi);
-
-	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
-	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
+	ring->int_enable(ring);
 }
 
 static void bcmgenet_disable_tx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
-	u32 int0_disable = UMAC_IRQ_TXDMA_DONE;
-	u32 int1_disable = 0xffff;
 	struct bcmgenet_tx_ring *ring;
 
-	bcmgenet_intrl2_0_writel(priv, int0_disable, INTRL2_CPU_MASK_SET);
-	bcmgenet_intrl2_1_writel(priv, int1_disable, INTRL2_CPU_MASK_SET);
-
 	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
 		ring = &priv->tx_rings[i];
 		napi_disable(&ring->napi);
@@ -2269,33 +2260,24 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 static void bcmgenet_enable_rx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
-	u32 int0_enable = UMAC_IRQ_RXDMA_DONE;
-	u32 int1_enable = 0;
 	struct bcmgenet_rx_ring *ring;
 
 	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
 		ring = &priv->rx_rings[i];
 		napi_enable(&ring->napi);
-		int1_enable |= (1 << (UMAC_IRQ1_RX_INTR_SHIFT + i));
+		ring->int_enable(ring);
 	}
 
 	ring = &priv->rx_rings[DESC_INDEX];
 	napi_enable(&ring->napi);
-
-	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
-	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
+	ring->int_enable(ring);
 }
 
 static void bcmgenet_disable_rx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
-	u32 int0_disable = UMAC_IRQ_RXDMA_DONE;
-	u32 int1_disable = 0xffff << UMAC_IRQ1_RX_INTR_SHIFT;
 	struct bcmgenet_rx_ring *ring;
 
-	bcmgenet_intrl2_0_writel(priv, int0_disable, INTRL2_CPU_MASK_SET);
-	bcmgenet_intrl2_1_writel(priv, int1_disable, INTRL2_CPU_MASK_SET);
-
 	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
 		ring = &priv->rx_rings[i];
 		napi_disable(&ring->napi);
@@ -2888,9 +2870,9 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 
 	netif_tx_stop_all_queues(dev);
 	phy_stop(priv->phydev);
-	bcmgenet_intr_disable(priv);
 	bcmgenet_disable_rx_napi(priv);
 	bcmgenet_disable_tx_napi(priv);
+	bcmgenet_intr_disable(priv);
 
 	/* Wait for pending work items to complete. Since interrupts are
 	 * disabled no new work will be scheduled.
-- 
2.14.1
