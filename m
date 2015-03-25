From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 4/7] net: bcmgenet: tweak init_umac()
Date: Wed, 25 Mar 2015 12:35:12 -0700 (PDT)
Message-ID: <20150325193513.08B462201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:32882 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbCYTfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:14 -0400
Received: by ykbq200 with SMTP id q200so2131981ykb.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more meaningful variable names int0_enable and int1_enable when
enabling bcmgenet interrupts.

For Rx default queue interrupts, use:
UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE

For Tx default queue interrupts, use:
UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 ++++++++++++++++----------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1c9f9b4..68873be 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1652,8 +1652,10 @@ static int init_umac(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
 	int ret;
-	u32 reg, cpu_mask_clear;
-	int index;
+	u32 reg;
+	u32 int0_enable = 0;
+	u32 int1_enable = 0;
+	int i;
 
 	dev_dbg(&priv->pdev->dev, "bcmgenet: init_umac\n");
 
@@ -1680,15 +1682,17 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	bcmgenet_intr_disable(priv);
 
-	cpu_mask_clear = UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_TXDMA_BDONE;
+	/* Enable Rx default queue 16 interrupts */
+	int0_enable |= (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE);
 
-	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
+	/* Enable Tx default queue 16 interrupts */
+	int0_enable |= (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE);
 
 	/* Monitor cable plug/unplugged event for internal PHY */
 	if (phy_is_internal(priv->phydev)) {
-		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
+		int0_enable |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
 	} else if (priv->ext_phy) {
-		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
+		int0_enable |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
 	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
 		reg = bcmgenet_bp_mc_get(priv);
 		reg |= BIT(priv->hw_params->bp_in_en_shift);
@@ -1703,13 +1707,14 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	/* Enable MDIO interrupts on GENET v3+ */
 	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
-		cpu_mask_clear |= UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR;
+		int0_enable |= (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
 
-	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear, INTRL2_CPU_MASK_CLEAR);
+	/* Enable Tx priority queue interrupts */
+	for (i = 0; i < priv->hw_params->tx_queues; ++i)
+		int1_enable |= (1 << i);
 
-	for (index = 0; index < priv->hw_params->tx_queues; index++)
-		bcmgenet_intrl2_1_writel(priv, (1 << index),
-					 INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 
 	/* Enable rx/tx engine.*/
 	dev_dbg(kdev, "done init umac\n");
@@ -2111,7 +2116,8 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
+		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
+					 UMAC_IRQ_RXDMA_PDONE,
 					 INTRL2_CPU_MASK_CLEAR);
 	}
 
@@ -2198,7 +2204,8 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		 * Disable interrupt, will be enabled in the poll method.
 		 */
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
+			bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
+						 UMAC_IRQ_RXDMA_PDONE,
 						 INTRL2_CPU_MASK_SET);
 			__napi_schedule(&priv->napi);
 		}
-- 
2.2.0.rc0.207.ga3a616c
