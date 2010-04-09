From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH 2/2] bcm63xx_enet: do not overwrite ENET_CTL_REG value
Date: Fri, 9 Apr 2010 13:04:52 +0200
Message-ID: <201004091304.52540.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34060 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab0DILON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 07:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_enet_hw_preinit will correctly set values in ENET_CTL_REG for internal
or external MII operations, however, bcm_enet_open will blindly overwrite the
ENET_CTL_REG register value and thus we will loose any changes to it that
were made in bcm_enet_hw_preinit, rendering external MII operations non-working.

This would lead to the driver not being able to check for link availability on
external PHY setups, and thus we would never get to sending packets because
link was down from the driver side.

This was completely un-noticed because all boards out there but BCM6338-based
ones use internal phy on their enet0 interface.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
---
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 5173340..14ab4dc 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -958,7 +958,9 @@ static int bcm_enet_open(struct net_device *dev)
 	/* all set, enable mac and interrupts, start dma engine and
 	 * kick rx dma channel */
 	wmb();
-	enet_writel(priv, ENET_CTL_ENABLE_MASK, ENET_CTL_REG);
+	val = enet_readl(priv, ENET_CTL_REG);
+	val |= ENET_CTL_ENABLE_MASK;
+	enet_writel(priv, val, ENET_CTL_REG);
 	enet_dma_writel(priv, ENETDMA_CFG_EN_MASK, ENETDMA_CFG_REG);
 	enet_dma_writel(priv, ENETDMA_CHANCFG_EN_MASK,
 			ENETDMA_CHANCFG_REG(priv->rx_chan));
