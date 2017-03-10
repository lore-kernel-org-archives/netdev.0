From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH v2 net 5/8] net: bcmgenet: synchronize irq0 status between the isr and task
Date: Thu,  9 Mar 2017 16:58:47 -0800
Message-ID: <20170310005850.10808-6-opendmb@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a spinlock to ensure that irq0_stat is not unintentionally altered
as the result of preemption.  Also removed unserviced irq0 interrupts
and removed irq1_stat since there is no bottom half service for those
interrupts.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 73 ++++++++++++++------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++-
 2 files changed, 44 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 475dc14931af..527cecaf12c1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2506,24 +2506,28 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 /* Interrupt bottom half */
 static void bcmgenet_irq_task(struct work_struct *work)
 {
+	unsigned long flags;
+	unsigned int status;
 	struct bcmgenet_priv *priv = container_of(
 			work, struct bcmgenet_priv, bcmgenet_irq_work);
 
 	netif_dbg(priv, intr, priv->dev, "%s\n", __func__);
 
-	if (priv->irq0_stat & UMAC_IRQ_MPD_R) {
-		priv->irq0_stat &= ~UMAC_IRQ_MPD_R;
+	spin_lock_irqsave(&priv->lock, flags);
+	status = priv->irq0_stat;
+	priv->irq0_stat = 0;
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (status & UMAC_IRQ_MPD_R) {
 		netif_dbg(priv, wol, priv->dev,
 			  "magic packet detected, waking up\n");
 		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
 	}
 
 	/* Link UP/DOWN event */
-	if (priv->irq0_stat & UMAC_IRQ_LINK_EVENT) {
+	if (status & UMAC_IRQ_LINK_EVENT)
 		phy_mac_interrupt(priv->phydev,
-				  !!(priv->irq0_stat & UMAC_IRQ_LINK_UP));
-		priv->irq0_stat &= ~UMAC_IRQ_LINK_EVENT;
-	}
+				  !!(status & UMAC_IRQ_LINK_UP));
 }
 
 /* bcmgenet_isr1: handle Rx and Tx priority queues */
@@ -2532,22 +2536,21 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 	struct bcmgenet_priv *priv = dev_id;
 	struct bcmgenet_rx_ring *rx_ring;
 	struct bcmgenet_tx_ring *tx_ring;
-	unsigned int index;
+	unsigned int index, status;
 
-	/* Save irq status for bottom-half processing. */
-	priv->irq1_stat =
-		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
+	/* Read irq status */
+	status = bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_MASK_STATUS);
 
 	/* clear interrupts */
-	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, status, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
-		  "%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
+		  "%s: IRQ=0x%x\n", __func__, status);
 
 	/* Check Rx priority queue interrupts */
 	for (index = 0; index < priv->hw_params->rx_queues; index++) {
-		if (!(priv->irq1_stat & BIT(UMAC_IRQ1_RX_INTR_SHIFT + index)))
+		if (!(status & BIT(UMAC_IRQ1_RX_INTR_SHIFT + index)))
 			continue;
 
 		rx_ring = &priv->rx_rings[index];
@@ -2560,7 +2563,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 
 	/* Check Tx priority queue interrupts */
 	for (index = 0; index < priv->hw_params->tx_queues; index++) {
-		if (!(priv->irq1_stat & BIT(index)))
+		if (!(status & BIT(index)))
 			continue;
 
 		tx_ring = &priv->tx_rings[index];
@@ -2580,19 +2583,20 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	struct bcmgenet_priv *priv = dev_id;
 	struct bcmgenet_rx_ring *rx_ring;
 	struct bcmgenet_tx_ring *tx_ring;
+	unsigned int status;
+	unsigned long flags;
 
-	/* Save irq status for bottom-half processing. */
-	priv->irq0_stat =
-		bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
+	/* Read irq status */
+	status = bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
 
 	/* clear interrupts */
-	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
+	bcmgenet_intrl2_0_writel(priv, status, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
-		  "IRQ=0x%x\n", priv->irq0_stat);
+		  "IRQ=0x%x\n", status);
 
-	if (priv->irq0_stat & UMAC_IRQ_RXDMA_DONE) {
+	if (status & UMAC_IRQ_RXDMA_DONE) {
 		rx_ring = &priv->rx_rings[DESC_INDEX];
 
 		if (likely(napi_schedule_prep(&rx_ring->napi))) {
@@ -2601,7 +2605,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		}
 	}
 
-	if (priv->irq0_stat & UMAC_IRQ_TXDMA_DONE) {
+	if (status & UMAC_IRQ_TXDMA_DONE) {
 		tx_ring = &priv->tx_rings[DESC_INDEX];
 
 		if (likely(napi_schedule_prep(&tx_ring->napi))) {
@@ -2610,22 +2614,23 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		}
 	}
 
-	if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
-				UMAC_IRQ_PHY_DET_F |
-				UMAC_IRQ_LINK_EVENT |
-				UMAC_IRQ_HFB_SM |
-				UMAC_IRQ_HFB_MM |
-				UMAC_IRQ_MPD_R)) {
-		/* all other interested interrupts handled in bottom half */
-		schedule_work(&priv->bcmgenet_irq_work);
-	}
-
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
-	    priv->irq0_stat & (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR)) {
-		priv->irq0_stat &= ~(UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
+		status & (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR)) {
 		wake_up(&priv->wq);
 	}
 
+	/* all other interested interrupts handled in bottom half */
+	status &= (UMAC_IRQ_LINK_EVENT |
+		   UMAC_IRQ_MPD_R);
+	if (status) {
+		/* Save irq status for bottom-half processing. */
+		spin_lock_irqsave(&priv->lock, flags);
+		priv->irq0_stat |= status;
+		spin_unlock_irqrestore(&priv->lock, flags);
+
+		schedule_work(&priv->bcmgenet_irq_work);
+	}
+
 	return IRQ_HANDLED;
 }
 
@@ -3327,6 +3332,8 @@ static int bcmgenet_probe(struct platform_device *pdev)
 		goto err;
 	}
 
+	spin_lock_init(&priv->lock);
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	dev_set_drvdata(&pdev->dev, dev);
 	ether_addr_copy(dev->dev_addr, macaddr);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index d5fb0d772dcd..db7f289d65ae 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -623,11 +623,13 @@ struct bcmgenet_priv {
 	struct work_struct bcmgenet_irq_work;
 	int irq0;
 	int irq1;
-	unsigned int irq0_stat;
-	unsigned int irq1_stat;
 	int wol_irq;
 	bool wol_irq_disabled;
 
+	/* shared status */
+	spinlock_t lock;
+	unsigned int irq0_stat;
+
 	/* HW descriptors/checksum variables */
 	bool desc_64b_en;
 	bool desc_rxchk_en;
-- 
2.11.1
