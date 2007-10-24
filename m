From: Eugene Konev <ejka@imfi.kspu.ru>
Subject: [PATCH 2/3] cpmac: convert to napi_struct interface
Date: Wed, 24 Oct 2007 10:42:02 +0800
Message-ID: <1193193723-12691-3-git-send-email-ejka@imfi.kspu.ru>
References: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru>
 <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
Cc: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org,
	Eugene Konev <ejka@imfi.kspu.ru>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 117.19.65.80.ip.morning.ru ([80.65.19.117]:54702 "EHLO
	mail.imfi.kspu.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753853AbXJXDBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:01:12 -0400
In-Reply-To: <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
Message-Id: <ad70799b9f985de8e07528f3d9fd65081416efca.1193191283.git.ejka@imfi.kspu.ru>
In-Reply-To: <5070e5ddd7ae0681b14e712980d830225a2103aa.1193191283.git.ejka@imfi.kspu.ru>
References: <5070e5ddd7ae0681b14e712980d830225a2103aa.1193191283.git.ejka@imfi.kspu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert cpmac to new napi_struct API introduced by
bea3348eef27e6044b6161fd04c3152215f96411 [NET]: Make NAPI polling independent
of struct net_device objects.
Only disable rx interrupts if napi actually has been scheduled.

Signed-off-by: Eugene Konev <ejka@imfi.kspu.ru>
---
 drivers/net/cpmac.c |   68 +++++++++++++++++++++++++++-----------------------
 1 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 0598d4d..486c82b 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -205,6 +205,7 @@ struct cpmac_priv {
 	struct net_device *dev;
 	struct work_struct reset_work;
 	struct platform_device *pdev;
+	struct napi_struct napi;
 };
 
 static irqreturn_t cpmac_irq(int, void *);
@@ -356,47 +357,48 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 	}
 }
 
-static struct sk_buff *cpmac_rx_one(struct net_device *dev,
-				    struct cpmac_priv *priv,
+static struct sk_buff *cpmac_rx_one(struct cpmac_priv *priv,
 				    struct cpmac_desc *desc)
 {
 	struct sk_buff *skb, *result = NULL;
 
 	if (unlikely(netif_msg_hw(priv)))
-		cpmac_dump_desc(dev, desc);
+		cpmac_dump_desc(priv->dev, desc);
 	cpmac_write(priv->regs, CPMAC_RX_ACK(0), (u32)desc->mapping);
 	if (unlikely(!desc->datalen)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING "%s: rx: spurious interrupt\n",
-			       dev->name);
+			       priv->dev->name);
 		return NULL;
 	}
 
-	skb = netdev_alloc_skb(dev, CPMAC_SKB_SIZE);
+	skb = netdev_alloc_skb(priv->dev, CPMAC_SKB_SIZE);
 	if (likely(skb)) {
 		skb_reserve(skb, 2);
 		skb_put(desc->skb, desc->datalen);
-		desc->skb->protocol = eth_type_trans(desc->skb, dev);
+		desc->skb->protocol = eth_type_trans(desc->skb, priv->dev);
 		desc->skb->ip_summed = CHECKSUM_NONE;
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += desc->datalen;
+		priv->dev->stats.rx_packets++;
+		priv->dev->stats.rx_bytes += desc->datalen;
 		result = desc->skb;
-		dma_unmap_single(&dev->dev, desc->data_mapping, CPMAC_SKB_SIZE,
-				 DMA_FROM_DEVICE);
+		dma_unmap_single(&priv->dev->dev, desc->data_mapping,
+				 CPMAC_SKB_SIZE, DMA_FROM_DEVICE);
 		desc->skb = skb;
-		desc->data_mapping = dma_map_single(&dev->dev, skb->data,
+		desc->data_mapping = dma_map_single(&priv->dev->dev, skb->data,
 						    CPMAC_SKB_SIZE,
 						    DMA_FROM_DEVICE);
 		desc->hw_data = (u32)desc->data_mapping;
 		if (unlikely(netif_msg_pktdata(priv))) {
-			printk(KERN_DEBUG "%s: received packet:\n", dev->name);
-			cpmac_dump_skb(dev, result);
+			printk(KERN_DEBUG "%s: received packet:\n",
+			       priv->dev->name);
+			cpmac_dump_skb(priv->dev, result);
 		}
 	} else {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING
-			       "%s: low on skbs, dropping packet\n", dev->name);
-		dev->stats.rx_dropped++;
+			       "%s: low on skbs, dropping packet\n",
+			       priv->dev->name);
+		priv->dev->stats.rx_dropped++;
 	}
 
 	desc->buflen = CPMAC_SKB_SIZE;
@@ -405,25 +407,25 @@ static struct sk_buff *cpmac_rx_one(struct net_device *dev,
 	return result;
 }
 
-static int cpmac_poll(struct net_device *dev, int *budget)
+static int cpmac_poll(struct napi_struct *napi, int budget)
 {
 	struct sk_buff *skb;
 	struct cpmac_desc *desc;
-	int received = 0, quota = min(dev->quota, *budget);
-	struct cpmac_priv *priv = netdev_priv(dev);
+	int received = 0;
+	struct cpmac_priv *priv = container_of(napi, struct cpmac_priv, napi);
 
 	spin_lock(&priv->rx_lock);
 	if (unlikely(!priv->rx_head)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
-			       dev->name);
-		netif_rx_complete(dev);
+			       priv->dev->name);
+		netif_rx_complete(priv->dev, napi);
 		return 0;
 	}
 
 	desc = priv->rx_head;
-	while ((received < quota) && ((desc->dataflags & CPMAC_OWN) == 0)) {
-		skb = cpmac_rx_one(dev, priv, desc);
+	while (((desc->dataflags & CPMAC_OWN) == 0) && (received < budget)) {
+		skb = cpmac_rx_one(priv, desc);
 		if (likely(skb)) {
 			netif_receive_skb(skb);
 			received++;
@@ -433,13 +435,11 @@ static int cpmac_poll(struct net_device *dev, int *budget)
 
 	priv->rx_head = desc;
 	spin_unlock(&priv->rx_lock);
-	*budget -= received;
-	dev->quota -= received;
 	if (unlikely(netif_msg_rx_status(priv)))
-		printk(KERN_DEBUG "%s: poll processed %d packets\n", dev->name,
-		       received);
+		printk(KERN_DEBUG "%s: poll processed %d packets\n",
+		       priv->dev->name, received);
 	if (desc->dataflags & CPMAC_OWN) {
-		netif_rx_complete(dev);
+		netif_rx_complete(priv->dev, napi);
 		cpmac_write(priv->regs, CPMAC_RX_PTR(0), (u32)desc->mapping);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
@@ -649,6 +649,7 @@ static void cpmac_hw_error(struct work_struct *work)
 	spin_unlock(&priv->rx_lock);
 	cpmac_clear_tx(priv->dev);
 	cpmac_hw_start(priv->dev);
+	napi_enable(&priv->napi);
 	netif_start_queue(priv->dev);
 }
 
@@ -675,8 +676,10 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 
 	if (status & MAC_INT_RX) {
 		queue = (status >> 8) & 7;
-		netif_rx_schedule(dev);
-		cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
+		if (netif_rx_schedule_prep(dev, &priv->napi)) {
+			cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
+			__netif_rx_schedule(dev, &priv->napi);
+		}
 	}
 
 	cpmac_write(priv->regs, CPMAC_MAC_EOI_VECTOR, 0);
@@ -686,6 +689,7 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 			printk(KERN_ERR "%s: hw error, resetting...\n",
 			       dev->name);
 		netif_stop_queue(dev);
+		napi_disable(&priv->napi);
 		cpmac_hw_stop(dev);
 		schedule_work(&priv->reset_work);
 		if (unlikely(netif_msg_hw(priv)))
@@ -921,6 +925,7 @@ static int cpmac_open(struct net_device *dev)
 	INIT_WORK(&priv->reset_work, cpmac_hw_error);
 	cpmac_hw_start(dev);
 
+	napi_enable(&priv->napi);
 	priv->phy->state = PHY_CHANGELINK;
 	phy_start(priv->phy);
 
@@ -959,6 +964,7 @@ static int cpmac_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	cancel_work_sync(&priv->reset_work);
+	napi_disable(&priv->napi);
 	phy_stop(priv->phy);
 	phy_disconnect(priv->phy);
 	priv->phy = NULL;
@@ -1048,10 +1054,10 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	dev->set_multicast_list = cpmac_set_multicast_list;
 	dev->tx_timeout         = cpmac_tx_timeout;
 	dev->ethtool_ops        = &cpmac_ethtool_ops;
-	dev->poll = cpmac_poll;
-	dev->weight = 64;
 	dev->features |= NETIF_F_MULTI_QUEUE;
 
+	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
+
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->rx_lock);
 	priv->dev = dev;
-- 
1.5.3.4

