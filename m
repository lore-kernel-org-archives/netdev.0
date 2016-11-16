From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/3] net: stmmac: replace if (netif_msg_type) by their netif_xxx counterpart
Date: Wed, 16 Nov 2016 20:09:41 +0100
Message-ID: <1479323381-26639-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36288 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753101AbcKPTMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:12:55 -0500
In-Reply-To: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: LABBE Corentin <clabbe.montjoie@gmail.com>

As sugested by Joe Perches, we could replace all
if (netif_msg_type(priv)) dev_xxx(priv->devices, ...)
by the simpler macro netif_xxx(priv, hw, priv->dev, ...)

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 49 ++++++++++-------------
 1 file changed, 21 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d160bdb..fbd1cd7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -755,10 +755,9 @@ static void stmmac_adjust_link(struct net_device *dev)
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			default:
-				if (netif_msg_link(priv))
-					netdev_warn(priv->dev,
-						    "Speed (%d) not 10/100\n",
-						    phydev->speed);
+				netif_warn(priv, link, priv->dev,
+					   "Speed (%d) not 10/100\n",
+					   phydev->speed);
 				break;
 			}
 
@@ -1036,14 +1035,14 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dma_buf_sz = bfsize;
 
-	if (netif_msg_probe(priv)) {
-		netdev_dbg(priv->dev, "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
-			   __func__, (u32)priv->dma_rx_phy,
-			   (u32)priv->dma_tx_phy);
+	netif_dbg(priv, probe, priv->dev,
+		  "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
+		  __func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
+
+	/* RX INITIALIZATION */
+	netif_dbg(priv, probe, priv->dev,
+		  "SKB addresses:\nskb\t\tskb data\tdma data\n");
 
-		/* RX INITIALIZATION */
-		netdev_dbg(priv->dev, "SKB addresses:\nskb\t\tskb data\tdma data\n");
-	}
 	for (i = 0; i < DMA_RX_SIZE; i++) {
 		struct dma_desc *p;
 		if (priv->extend_desc)
@@ -1055,11 +1054,9 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		if (ret)
 			goto err_init_rx_buffers;
 
-		if (netif_msg_probe(priv))
-			netdev_dbg(priv->dev, "[%p]\t[%p]\t[%x]\n",
-				   priv->rx_skbuff[i],
-				 priv->rx_skbuff[i]->data,
-				 (unsigned int)priv->rx_skbuff_dma[i]);
+		netif_dbg(priv, probe, priv->dev, "[%p]\t[%p]\t[%x]\n",
+			  priv->rx_skbuff[i], priv->rx_skbuff[i]->data,
+			  (unsigned int)priv->rx_skbuff_dma[i]);
 	}
 	priv->cur_rx = 0;
 	priv->dirty_rx = (unsigned int)(i - DMA_RX_SIZE);
@@ -1389,9 +1386,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
 		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
-			if (netif_msg_tx_done(priv))
-				netdev_dbg(priv->dev, "%s: restart transmit\n",
-					   __func__);
+			netif_dbg(priv, tx_done, priv->dev,
+				  "%s: restart transmit\n", __func__);
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
@@ -2096,9 +2092,8 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
 
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			netdev_dbg(priv->dev, "%s: stop transmitted packets\n",
-				   __func__);
+		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
+			  __func__);
 		netif_stop_queue(dev);
 	}
 
@@ -2298,9 +2293,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			netdev_dbg(priv->dev,
-				   "%s: stop transmitted packets\n", __func__);
+		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
+			  __func__);
 		netif_stop_queue(dev);
 	}
 
@@ -2465,9 +2459,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			if (priv->rx_zeroc_thresh > 0)
 				priv->rx_zeroc_thresh--;
 
-			if (netif_msg_rx_status(priv))
-				netdev_dbg(priv->dev,
-					   "refill entry #%d\n", entry);
+			netif_dbg(priv, rx_status, priv->dev,
+				  "refill entry #%d\n", entry);
 		}
 		wmb();
 
-- 
2.7.3
