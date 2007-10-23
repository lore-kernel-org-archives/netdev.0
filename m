From: Matteo Croce <technoboy85@gmail.com>
Subject: Re: [PATCH][MIPS] AR7 ethernet
Date: Tue, 23 Oct 2007 19:12:22 +0200
Message-ID: <200710231912.23446.technoboy85@gmail.com>
References: <200710141810.13752.technoboy85@gmail.com> <4713B055.802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Eugene Konev <ejka@imfi.kspu.ru>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de, Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:28809 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755768AbXJWRMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 13:12:35 -0400
Received: by rn-out-0102.google.com with SMTP id s46so1599995rnb
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 10:12:33 -0700 (PDT)
In-Reply-To: <4713B055.802@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il Monday 15 October 2007 20:24:21 Jeff Garzik ha scritto:
> applied

Small update to the driver, please apply

Signed-off-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Eugene Konev <ejka@imfi.kspu.ru>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index ae41973..57541d2 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -460,18 +460,11 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct cpmac_desc *desc;
 	struct cpmac_priv *priv = netdev_priv(dev);
 
-	if (unlikely(skb_padto(skb, ETH_ZLEN))) {
-		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: tx: padding failed, dropping\n", dev->name);
-		spin_lock(&priv->lock);
-		dev->stats.tx_dropped++;
-		spin_unlock(&priv->lock);
-		return -ENOMEM;
-	}
+	if (unlikely(skb_padto(skb, ETH_ZLEN)))
+		return NETDEV_TX_OK;
 
 	len = max(skb->len, ETH_ZLEN);
-	queue = skb_get_queue_mapping(skb);
+	queue = skb->queue_mapping;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(dev, queue);
 #else
@@ -481,13 +474,9 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	desc = &priv->desc_ring[queue];
 	if (unlikely(desc->dataflags & CPMAC_OWN)) {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: tx dma ring full, dropping\n",
+			printk(KERN_WARNING "%s: tx dma ring full\n",
 			       dev->name);
-		spin_lock(&priv->lock);
-		dev->stats.tx_dropped++;
-		spin_unlock(&priv->lock);
-		dev_kfree_skb_any(skb);
-		return -ENOMEM;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock(&priv->lock);
@@ -509,7 +498,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		cpmac_dump_skb(dev, skb);
 	cpmac_write(priv->regs, CPMAC_TX_PTR(queue), (u32)desc->mapping);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void cpmac_end_xmit(struct net_device *dev, int queue)
@@ -646,12 +635,14 @@ static void cpmac_clear_tx(struct net_device *dev)
 	int i;
 	if (unlikely(!priv->desc_ring))
 		return;
-	for (i = 0; i < CPMAC_QUEUES; i++)
+	for (i = 0; i < CPMAC_QUEUES; i++) {
+		priv->desc_ring[i].dataflags = 0;
 		if (priv->desc_ring[i].skb) {
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
 			if (netif_subqueue_stopped(dev, i))
 			    netif_wake_subqueue(dev, i);
 		}
+	}
 }
 
 static void cpmac_hw_error(struct work_struct *work)
@@ -727,11 +718,13 @@ static void cpmac_tx_timeout(struct net_device *dev)
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < CPMAC_QUEUES; i++)
 		if (priv->desc_ring[i].skb) {
+			priv->desc_ring[i].dataflags = 0;
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
 			netif_wake_subqueue(dev, i);
 			break;
 		}
 #else
+	priv->desc_ring[0].dataflags = 0;
 	if (priv->desc_ring[0].skb)
 		dev_kfree_skb_any(priv->desc_ring[0].skb);
 	netif_wake_queue(dev);
@@ -794,7 +787,7 @@ static int cpmac_set_ringparam(struct net_device *dev, struct ethtool_ringparam*
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 
-	if (dev->flags && IFF_UP)
+	if (netif_running(dev))
 		return -EBUSY;
 	priv->ring_size = ring->rx_pending;
 	return 0;
