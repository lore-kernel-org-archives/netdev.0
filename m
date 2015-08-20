From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: bcmgenet: fix uncleaned dma flags
Date: Thu, 20 Aug 2015 12:17:07 +0900
Message-ID: <1440040627-59949-1-git-send-email-jaedon.shin@gmail.com>
Cc: Jaedon Shin <jaedon.shin@gmail.com>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35699 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbHTDSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 23:18:48 -0400
Received: by pacdd16 with SMTP id dd16so8860261pac.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 20:18:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean the dma flags of multiq ring buffer int the interface stop
process. This patch fixes that the genet is not running while the
interface is re-enabled.

$ ifup eth0 - running after booting
$ ifdown eth0
$ ifup eth0 - not running and occur tx_timeout

The bcmgenet_dma_disable() in bcmgenet_open() do clean ring16 dma flag
only. If the genet has multiq, the dma register is not cleaned. and
bcmgenet_init_dma() is not done correctly. in case
GENET_V2(tx_queues=4), tdma_ctrl has 0x1e after running
bcmgenet_dma_disable().

Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 64c1e9db6b0b..81bde6fa70b7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2174,6 +2174,8 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 
 static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
+	u32 dma_ctrl;
+	u32 reg;
 	int i;
 
 	bcmgenet_fini_rx_napi(priv);
@@ -2182,6 +2184,20 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 	/* disable DMA */
 	bcmgenet_dma_teardown(priv);
 
+	dma_ctrl = 0;
+	for (i = 0; i < priv->hw_params->rx_queues; i++)
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
+	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
+	reg &= ~dma_ctrl;
+	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
+
+	dma_ctrl = 0;
+	for (i = 0; i < priv->hw_params->tx_queues; i++)
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
+	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
+	reg &= ~dma_ctrl;
+	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
+
 	for (i = 0; i < priv->num_tx_bds; i++) {
 		if (priv->tx_cbs[i].skb != NULL) {
 			dev_kfree_skb(priv->tx_cbs[i].skb);
-- 
2.5.0
