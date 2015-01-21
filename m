From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH v2] net: stmmac: add BQL support
Date: Wed, 21 Jan 2015 19:07:27 +0100
Message-ID: <1421863647-20048-1-git-send-email-b.galvani@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37915 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbAUSIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 13:08:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Byte Queue Limits to the STMicro MAC driver.

Tested on a Amlogic S802 quad Cortex-A9 board, where the use of BQL
decreases the latency of a high priority ping from ~12ms to ~1ms when
the 100Mbit link is saturated by 20 TCP streams.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
Changes since v1:
 - don't access skb->len after the start of DMA transmission in
   stmmac_xmit(), to avoid potential use after free in case tx_lock is
   removed in the future

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 118a427..1d74313 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1097,6 +1097,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
+	netdev_reset_queue(priv->dev);
 
 	stmmac_clear_descriptors(priv);
 
@@ -1300,6 +1301,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 static void stmmac_tx_clean(struct stmmac_priv *priv)
 {
 	unsigned int txsize = priv->dma_tx_size;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	spin_lock(&priv->tx_lock);
 
@@ -1356,6 +1358,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		priv->hw->mode->clean_desc3(priv, p);
 
 		if (likely(skb != NULL)) {
+			pkts_compl++;
+			bytes_compl += skb->len;
 			dev_consume_skb_any(skb);
 			priv->tx_skbuff[entry] = NULL;
 		}
@@ -1364,6 +1368,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 		priv->dirty_tx++;
 	}
+
+	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
+
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
 		netif_tx_lock(priv->dev);
@@ -1418,6 +1425,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 						     (i == txsize - 1));
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
+	netdev_reset_queue(priv->dev);
 	priv->hw->dma->start_tx(priv->ioaddr);
 
 	priv->dev->stats.tx_errors++;
@@ -2048,6 +2056,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!priv->hwts_tx_en)
 		skb_tx_timestamp(skb);
 
+	netdev_sent_queue(dev, skb->len);
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
 	spin_unlock(&priv->tx_lock);
-- 
2.1.4
