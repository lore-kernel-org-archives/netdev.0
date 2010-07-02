From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 2/8] net/gianfar: use generic recycling infrasstructure
Date: Fri,  2 Jul 2010 21:20:15 +0200
Message-ID: <1278098421-21296-3-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41199 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756411Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/gianfar.c         |   28 ++++++++--------------------
 drivers/net/gianfar.h         |    2 --
 drivers/net/gianfar_ethtool.c |    1 +
 3 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index fccb7a3..1a1a249 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1148,6 +1148,9 @@ static int gfar_probe(struct of_device *ofdev,
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}
 
+	net_recycle_init(dev, DEFAULT_RX_RING_SIZE,
+			priv->rx_buffer_size + RXBUF_ALIGNMENT);
+
 	/* enable filer if using multiple RX queues*/
 	if(priv->num_rx_queues > 1)
 		priv->rx_filer_enable = 1;
@@ -1768,7 +1771,7 @@ static void free_skb_resources(struct gfar_private *priv)
 			sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			priv->tx_queue[0]->tx_bd_base,
 			priv->tx_queue[0]->tx_bd_dma_base);
-	skb_queue_purge(&priv->rx_recycle);
+	net_recycle_cleanup(priv->ndev);
 }
 
 void gfar_start(struct net_device *dev)
@@ -1949,8 +1952,6 @@ static int gfar_enet_open(struct net_device *dev)
 
 	enable_napi(priv);
 
-	skb_queue_head_init(&priv->rx_recycle);
-
 	/* Initialize a bunch of registers */
 	init_registers(dev);
 
@@ -2366,6 +2367,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		stop_gfar(dev);
 
 	priv->rx_buffer_size = tempsize;
+	net_recycle_size(dev, tempsize + RXBUF_ALIGNMENT);
 
 	dev->mtu = new_mtu;
 
@@ -2498,16 +2500,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			bdp = next_txbd(bdp, base, tx_ring_size);
 		}
 
-		/*
-		 * If there's room in the queue (limit it to rx_buffer_size)
-		 * we add this skb back into the pool, if it's the right size
-		 */
-		if (skb_queue_len(&priv->rx_recycle) < rx_queue->rx_ring_size &&
-				skb_recycle_check(skb, priv->rx_buffer_size +
-					RXBUF_ALIGNMENT))
-			__skb_queue_head(&priv->rx_recycle, skb);
-		else
-			dev_kfree_skb_any(skb);
+		net_recycle_add(dev, skb);
 
 		tx_queue->tx_skbuff[skb_dirtytx] = NULL;
 
@@ -2573,14 +2566,9 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 struct sk_buff * gfar_new_skb(struct net_device *dev)
 {
 	unsigned int alignamount;
-	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
 
-	skb = __skb_dequeue(&priv->rx_recycle);
-	if (!skb)
-		skb = netdev_alloc_skb(dev,
-				priv->rx_buffer_size + RXBUF_ALIGNMENT);
-
+	skb = net_recycle_get(dev);
 	if (!skb)
 		return NULL;
 
@@ -2753,7 +2741,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				 * recycle list.
 				 */
 				skb_reserve(skb, -GFAR_CB(skb)->alignamount);
-				__skb_queue_head(&priv->rx_recycle, skb);
+				net_recycle_add(dev, skb);
 			}
 		} else {
 			/* Increment the number of packets */
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 710810e..66f8c04 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1068,8 +1068,6 @@ struct gfar_private {
 
 	u32 cur_filer_idx;
 
-	struct sk_buff_head rx_recycle;
-
 	struct vlan_group *vlgrp;
 
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 9bda023..8a6d567 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -508,6 +508,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		priv->tx_queue[i]->tx_ring_size = rvals->tx_pending;
 		priv->tx_queue[i]->num_txbdfree = priv->tx_queue[i]->tx_ring_size;
 	}
+	net_recycle_qlen(dev, rvals->rx_pending);
 
 	/* Rebuild the rings with the new size */
 	if (dev->flags & IFF_UP) {
-- 
1.6.6.1

