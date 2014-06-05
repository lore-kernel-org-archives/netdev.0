From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: systemport: fix transmit locking scheme
Date: Thu,  5 Jun 2014 10:22:15 -0700
Message-ID: <1401988938-25940-2-git-send-email-f.fainelli@gmail.com>
References: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:41899 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbaFERWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:22:39 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so1403009pbb.13
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:22:39 -0700 (PDT)
In-Reply-To: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our transmit locking scheme did not account for the TX ring full
interrupt. If a TX ring full interrupt fires while we are attempting to
transmit, we will cause a deadlock to occur. Fix this by making sure
that we properly disable interrupts while acquiring the spinlock.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 25982b02f0ea..4dfc93fe9744 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -637,10 +637,11 @@ static unsigned int bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 					   struct bcm_sysport_tx_ring *ring)
 {
 	unsigned int released;
+	unsigned long flags;
 
-	spin_lock(&ring->lock);
+	spin_lock_irqsave(&ring->lock, flags);
 	released = __bcm_sysport_tx_reclaim(priv, ring);
-	spin_unlock(&ring->lock);
+	spin_unlock_irqrestore(&ring->lock, flags);
 
 	return released;
 }
@@ -822,6 +823,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	struct netdev_queue *txq;
 	struct dma_desc *desc;
 	unsigned int skb_len;
+	unsigned long flags;
 	dma_addr_t mapping;
 	u32 len_status;
 	u16 queue;
@@ -831,8 +833,8 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	txq = netdev_get_tx_queue(dev, queue);
 	ring = &priv->tx_rings[queue];
 
-	/* lock against tx reclaim in BH context */
-	spin_lock(&ring->lock);
+	/* lock against tx reclaim in BH context and TX ring full interrupt */
+	spin_lock_irqsave(&ring->lock, flags);
 	if (unlikely(ring->desc_count == 0)) {
 		netif_tx_stop_queue(txq);
 		netdev_err(dev, "queue %d awake and ring full!\n", queue);
@@ -914,7 +916,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 
 	ret = NETDEV_TX_OK;
 out:
-	spin_unlock(&ring->lock);
+	spin_unlock_irqrestore(&ring->lock, flags);
 	return ret;
 }
 
-- 
1.9.1
