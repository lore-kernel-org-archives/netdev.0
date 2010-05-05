From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC 2/5] net/gianfar: use generic recycling infrasstructure
Date: Wed,  5 May 2010 16:47:47 +0200
Message-ID: <1273070870-7821-3-git-send-email-sebastian@breakpoint.cc>
References: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51294 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933649Ab0EEOr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 10:47:59 -0400
In-Reply-To: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/gianfar.c |   28 ++++++++--------------------
 drivers/net/gianfar.h |    2 --
 2 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c6df2ba..af98675 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1102,6 +1102,9 @@ static int gfar_probe(struct of_device *ofdev,
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}
 
+	net_recycle_init(dev, DEFAULT_RX_RING_SIZE,
+			priv->rx_buffer_size + RXBUF_ALIGNMENT);
+
 	/* enable filer if using multiple RX queues*/
 	if(priv->num_rx_queues > 1)
 		priv->rx_filer_enable = 1;
@@ -1705,7 +1708,7 @@ static void free_skb_resources(struct gfar_private *priv)
 			sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			priv->tx_queue[0]->tx_bd_base,
 			priv->tx_queue[0]->tx_bd_dma_base);
-	skb_queue_purge(&priv->rx_recycle);
+	net_recycle_cleanup(priv->ndev);
 }
 
 void gfar_start(struct net_device *dev)
@@ -1886,8 +1889,6 @@ static int gfar_enet_open(struct net_device *dev)
 
 	enable_napi(priv);
 
-	skb_queue_head_init(&priv->rx_recycle);
-
 	/* Initialize a bunch of registers */
 	init_registers(dev);
 
@@ -2291,6 +2292,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		stop_gfar(dev);
 
 	priv->rx_buffer_size = tempsize;
+	net_recycle_size(dev, tempsize + RXBUF_ALIGNMENT);
 
 	dev->mtu = new_mtu;
 
@@ -2422,16 +2424,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
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
 
@@ -2497,14 +2490,9 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
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
 
@@ -2673,7 +2661,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				 * recycle list.
 				 */
 				skb_reserve(skb, -GFAR_CB(skb)->alignamount);
-				__skb_queue_head(&priv->rx_recycle, skb);
+				net_recycle_add(dev, skb);
 			}
 		} else {
 			/* Increment the number of packets */
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index ac4a92e..99f5a9b 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1061,8 +1061,6 @@ struct gfar_private {
 
 	u32 cur_filer_idx;
 
-	struct sk_buff_head rx_recycle;
-
 	struct vlan_group *vlgrp;
 
 
-- 
1.6.6.1

