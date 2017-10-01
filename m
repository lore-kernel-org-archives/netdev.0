From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 2/6] bcm63xx_enet: do not write to random DMA channel on BCM6345
Date: Sun,  1 Oct 2017 13:02:16 +0200
Message-ID: <20171001110220.27668-3-jonas.gorski@gmail.com>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36723 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750983AbdJALCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:14 -0400
Received: by mail-wm0-f66.google.com with SMTP id 63so678488wmn.3
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:14 -0700 (PDT)
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA controller regs actually point to DMA channel 0, so the write to
ENETDMA_CFG_REG will actually modify a random DMA channel.

Since DMA controller registers do not exist on BCM6345, guard the write
with the usual check for dma_has_sram.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a45ec97b5b1e..a1e1e12e187a 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1062,7 +1062,8 @@ static int bcm_enet_open(struct net_device *dev)
 	val = enet_readl(priv, ENET_CTL_REG);
 	val |= ENET_CTL_ENABLE_MASK;
 	enet_writel(priv, val, ENET_CTL_REG);
-	enet_dma_writel(priv, ENETDMA_CFG_EN_MASK, ENETDMA_CFG_REG);
+	if (priv->dma_has_sram)
+		enet_dma_writel(priv, ENETDMA_CFG_EN_MASK, ENETDMA_CFG_REG);
 	enet_dmac_writel(priv, priv->dma_chan_en_mask,
 			 ENETDMAC_CHANCFG, priv->rx_chan);
 
-- 
2.13.2
