From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 05/12] net: bcmgenet: manage dma interrupts in napi code
Date: Mon, 13 Mar 2017 17:41:35 -0700
Message-ID: <20170314004142.4746-6-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit moves DMA interrupt enabling out of init_umac() and adds
the masking of these interrupts to the napi enable and disable code.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 39 +++++++++++++++-----------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 22c92f5a9829..9be884021679 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1862,8 +1862,6 @@ static int init_umac(struct bcmgenet_priv *priv)
 	int ret;
 	u32 reg;
 	u32 int0_enable = 0;
-	u32 int1_enable = 0;
-	int i;
 
 	dev_dbg(&priv->pdev->dev, "bcmgenet: init_umac\n");
 
@@ -1890,12 +1888,6 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	bcmgenet_intr_disable(priv);
 
-	/* Enable Rx default queue 16 interrupts */
-	int0_enable |= UMAC_IRQ_RXDMA_DONE;
-
-	/* Enable Tx default queue 16 interrupts */
-	int0_enable |= UMAC_IRQ_TXDMA_DONE;
-
 	/* Configure backpressure vectors for MoCA */
 	if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
 		reg = bcmgenet_bp_mc_get(priv);
@@ -1913,16 +1905,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
 		int0_enable |= (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
 
-	/* Enable Rx priority queue interrupts */
-	for (i = 0; i < priv->hw_params->rx_queues; ++i)
-		int1_enable |= (1 << (UMAC_IRQ1_RX_INTR_SHIFT + i));
-
-	/* Enable Tx priority queue interrupts */
-	for (i = 0; i < priv->hw_params->tx_queues; ++i)
-		int1_enable |= (1 << i);
-
 	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
-	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 
 	dev_dbg(kdev, "done init umac\n");
 
@@ -2055,22 +2038,33 @@ static void bcmgenet_init_tx_napi(struct bcmgenet_priv *priv)
 static void bcmgenet_enable_tx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
+	u32 int0_enable = UMAC_IRQ_TXDMA_DONE;
+	u32 int1_enable = 0;
 	struct bcmgenet_tx_ring *ring;
 
 	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
 		ring = &priv->tx_rings[i];
 		napi_enable(&ring->napi);
+		int1_enable |= (1 << i);
 	}
 
 	ring = &priv->tx_rings[DESC_INDEX];
 	napi_enable(&ring->napi);
+
+	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 }
 
 static void bcmgenet_disable_tx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
+	u32 int0_disable = UMAC_IRQ_TXDMA_DONE;
+	u32 int1_disable = 0xffff;
 	struct bcmgenet_tx_ring *ring;
 
+	bcmgenet_intrl2_0_writel(priv, int0_disable, INTRL2_CPU_MASK_SET);
+	bcmgenet_intrl2_1_writel(priv, int1_disable, INTRL2_CPU_MASK_SET);
+
 	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
 		ring = &priv->tx_rings[i];
 		napi_disable(&ring->napi);
@@ -2183,22 +2177,33 @@ static void bcmgenet_init_rx_napi(struct bcmgenet_priv *priv)
 static void bcmgenet_enable_rx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
+	u32 int0_enable = UMAC_IRQ_RXDMA_DONE;
+	u32 int1_enable = 0;
 	struct bcmgenet_rx_ring *ring;
 
 	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
 		ring = &priv->rx_rings[i];
 		napi_enable(&ring->napi);
+		int1_enable |= (1 << (UMAC_IRQ1_RX_INTR_SHIFT + i));
 	}
 
 	ring = &priv->rx_rings[DESC_INDEX];
 	napi_enable(&ring->napi);
+
+	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 }
 
 static void bcmgenet_disable_rx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
+	u32 int0_disable = UMAC_IRQ_RXDMA_DONE;
+	u32 int1_disable = 0xffff << UMAC_IRQ1_RX_INTR_SHIFT;
 	struct bcmgenet_rx_ring *ring;
 
+	bcmgenet_intrl2_0_writel(priv, int0_disable, INTRL2_CPU_MASK_SET);
+	bcmgenet_intrl2_1_writel(priv, int1_disable, INTRL2_CPU_MASK_SET);
+
 	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
 		ring = &priv->rx_rings[i];
 		napi_disable(&ring->napi);
-- 
2.11.1
