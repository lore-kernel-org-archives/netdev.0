From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Fix early link interrupt enabling
Date: Sat, 17 Oct 2015 14:22:46 -0700
Message-ID: <1445116966-27610-1-git-send-email-fainelli@broadcom.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34628 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbJQVWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 17:22:49 -0400
Received: by pasz6 with SMTP id z6so9890928pas.1
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 14:22:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

Link interrupts are enabled in init_umac(), which is too early for us to
process them since we do not yet have a valid PHY device pointer. On
BCM7425 chips for instance, we will crash calling phy_mac_interrupt()
because phydev is NULL.

Fix this by moving the link interrupts enabling in
bcmgenet_netif_start(), under a specific function:
bcmgenet_link_intr_enable() and while at it, update the comments
surrounding the code.

Fixes: 6cc8e6d4dcb36 ("net: bcmgenet: Delay PHY initialization to bcmgenet_open()")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Hi David,

This fixes a problem which is currently in v4.3-rcX, thank you!

 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   32 +++++++++++++++++------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 3bc701e..1805541 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1683,6 +1683,24 @@ static void bcmgenet_intr_disable(struct bcmgenet_priv *priv)
 	bcmgenet_intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 }
 
+static void bcmgenet_link_intr_enable(struct bcmgenet_priv *priv)
+{
+	u32 int0_enable = 0;
+
+	/* Monitor cable plug/unplugged event for internal PHY, external PHY
+	 * and MoCA PHY
+	 */
+	if (priv->internal_phy) {
+		int0_enable |= UMAC_IRQ_LINK_EVENT;
+	} else if (priv->ext_phy) {
+		int0_enable |= UMAC_IRQ_LINK_EVENT;
+	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
+		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
+			int0_enable |= UMAC_IRQ_LINK_EVENT;
+	}
+	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
+}
+
 static int init_umac(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
@@ -1723,15 +1741,8 @@ static int init_umac(struct bcmgenet_priv *priv)
 	/* Enable Tx default queue 16 interrupts */
 	int0_enable |= UMAC_IRQ_TXDMA_DONE;
 
-	/* Monitor cable plug/unplugged event for internal PHY */
-	if (priv->internal_phy) {
-		int0_enable |= UMAC_IRQ_LINK_EVENT;
-	} else if (priv->ext_phy) {
-		int0_enable |= UMAC_IRQ_LINK_EVENT;
-	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
-		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
-			int0_enable |= UMAC_IRQ_LINK_EVENT;
-
+	/* Configure backpressure vectors for MoCA */
+	if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
 		reg = bcmgenet_bp_mc_get(priv);
 		reg |= BIT(priv->hw_params->bp_in_en_shift);
 
@@ -2645,6 +2656,9 @@ static void bcmgenet_netif_start(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	/* Monitor link interrupts now */
+	bcmgenet_link_intr_enable(priv);
+
 	phy_start(priv->phydev);
 }
 
-- 
1.7.1
