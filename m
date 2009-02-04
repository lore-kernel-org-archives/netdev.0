From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.30 2/3] gianfar: Add support for skb recycling
Date: Tue,  3 Feb 2009 19:17:02 -0600
Message-ID: <1233710223-17808-4-git-send-email-afleming@freescale.com>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
 <1233710223-17808-2-git-send-email-afleming@freescale.com>
 <1233710223-17808-3-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57446 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbZBDBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:17:22 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n141H5Uk004696
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:17:05 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n141H43N007287
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 19:17:04 -0600 (CST)
In-Reply-To: <1233710223-17808-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   23 +++++++++++++++++++----
 drivers/net/gianfar.h |    2 ++
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1085e71..e822701 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1183,6 +1183,8 @@ static int gfar_enet_open(struct net_device *dev)
 
 	napi_enable(&priv->napi);
 
+	skb_queue_head_init(&priv->rx_recycle);
+
 	/* Initialize a bunch of registers */
 	init_registers(dev);
 
@@ -1399,6 +1401,7 @@ static int gfar_close(struct net_device *dev)
 
 	napi_disable(&priv->napi);
 
+	skb_queue_purge(&priv->rx_recycle);
 	cancel_work_sync(&priv->reset_task);
 	stop_gfar(dev);
 
@@ -1595,7 +1598,17 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 			bdp = next_txbd(bdp, base, tx_ring_size);
 		}
 
-		dev_kfree_skb_any(skb);
+		/*
+		 * If there's room in the queue (limit it to rx_buffer_size)
+		 * we add this skb back into the pool, if it's the right size
+		 */
+		if (skb_queue_len(&priv->rx_recycle) < priv->rx_ring_size &&
+				skb_recycle_check(skb, priv->rx_buffer_size +
+					RXBUF_ALIGNMENT))
+			__skb_queue_head(&priv->rx_recycle, skb);
+		else
+			dev_kfree_skb_any(skb);
+
 		priv->tx_skbuff[skb_dirtytx] = NULL;
 
 		skb_dirtytx = (skb_dirtytx + 1) &
@@ -1668,8 +1681,10 @@ struct sk_buff * gfar_new_skb(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
 
-	/* We have to allocate the skb, so keep trying till we succeed */
-	skb = netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT);
+	skb = __skb_dequeue(&priv->rx_recycle);
+	if (!skb)
+		skb = netdev_alloc_skb(dev,
+				priv->rx_buffer_size + RXBUF_ALIGNMENT);
 
 	if (!skb)
 		return NULL;
@@ -1817,7 +1832,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb)
-				dev_kfree_skb_any(skb);
+				__skb_queue_head(&priv->rx_recycle, skb);
 		} else {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index e5ed2cc..3aedae7 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -758,6 +758,8 @@ struct gfar_private {
 	unsigned int rx_stash_size;
 	unsigned int rx_stash_index;
 
+	struct sk_buff_head rx_recycle;
+
 	struct vlan_group *vlgrp;
 
 	/* Unprotected fields */
-- 
1.5.4.GIT

