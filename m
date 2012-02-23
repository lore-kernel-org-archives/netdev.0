From: John Crispin <blogic@openwrt.org>
Subject: [PATCH] NET: MIPS: lantiq: introduce missing locking of dma irq
Date: Thu, 23 Feb 2012 18:39:03 +0100
Message-ID: <1330018743-26383-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50746 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199Ab2BWRj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Feb 2012 12:39:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Access to the DMA irq was not properly locked, causing RX deadlocks under load.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/lantiq_etop.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 584794f..f1eb335 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -207,8 +207,10 @@ ltq_etop_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct ltq_etop_chan *ch = container_of(napi,
 				struct ltq_etop_chan, napi);
+	struct ltq_etop_priv *priv = netdev_priv(ch->netdev);
 	int rx = 0;
 	int complete = 0;
+	unsigned long flags;
 
 	while ((rx < budget) && !complete) {
 		struct ltq_dma_desc *desc = &ch->dma.desc_base[ch->dma.desc];
@@ -222,7 +224,9 @@ ltq_etop_poll_rx(struct napi_struct *napi, int budget)
 	}
 	if (complete || !rx) {
 		napi_complete(&ch->napi);
+		spin_lock_irqsave(&priv->lock, flags);
 		ltq_dma_ack_irq(&ch->dma);
+		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 	return rx;
 }
@@ -252,7 +256,9 @@ ltq_etop_poll_tx(struct napi_struct *napi, int budget)
 	if (netif_tx_queue_stopped(txq))
 		netif_tx_start_queue(txq);
 	napi_complete(&ch->napi);
+	spin_lock_irqsave(&priv->lock, flags);
 	ltq_dma_ack_irq(&ch->dma);
+	spin_unlock_irqrestore(&priv->lock, flags);
 	return 1;
 }
 
@@ -624,13 +630,16 @@ ltq_etop_open(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	int i;
+	unsigned long flags;
 
 	for (i = 0; i < MAX_DMA_CHAN; i++) {
 		struct ltq_etop_chan *ch = &priv->ch[i];
 
 		if (!IS_TX(i) && (!IS_RX(i)))
 			continue;
+		spin_lock_irqsave(&priv->lock, flags);
 		ltq_dma_open(&ch->dma);
+		spin_unlock_irqrestore(&priv->lock, flags);
 		napi_enable(&ch->napi);
 	}
 	if (priv->phydev)
@@ -644,6 +653,7 @@ ltq_etop_stop(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	int i;
+	unsigned long flags;
 
 	netif_tx_stop_all_queues(dev);
 	if (priv->phydev)
@@ -654,7 +664,9 @@ ltq_etop_stop(struct net_device *dev)
 		if (!IS_RX(i) && !IS_TX(i))
 			continue;
 		napi_disable(&ch->napi);
+		spin_lock_irqsave(&priv->lock, flags);
 		ltq_dma_close(&ch->dma);
+		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 	return 0;
 }
-- 
1.7.7.1
