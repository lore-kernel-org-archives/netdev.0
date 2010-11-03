From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] mpc52xx: cleanup locking
Date: Wed, 03 Nov 2010 16:56:38 +0100
Message-ID: <1288799798.2511.164.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Asier Llano <a.llano@ziv.es>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jean-Michel Hautbois <jhautbois@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58307 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab0KCP4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 11:56:44 -0400
Received: by wwi17 with SMTP id 17so1586274wwi.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 08:56:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1e4e0767ecb1 (Fix locking on fec_mpc52xx driver) assumed IRQ are
enabled when an IRQ handler is called.

It is not the case anymore (IRQF_DISABLED is deprecated), so we can use
regular spin_lock(), no need for spin_lock_irqsave().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Jean-Michel Hautbois <jhautbois@gmail.com>
Cc: Asier Llano <a.llano@ziv.es>
Cc: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/fec_mpc52xx.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index e9f5d03..50c1213 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -366,9 +366,8 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	unsigned long flags;
 
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock(&priv->lock);
 	while (bcom_buffer_done(priv->tx_dmatsk)) {
 		struct sk_buff *skb;
 		struct bcom_fec_bd *bd;
@@ -379,7 +378,7 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
 
 		dev_kfree_skb_irq(skb);
 	}
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock(&priv->lock);
 
 	netif_wake_queue(dev);
 
@@ -395,9 +394,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 	struct bcom_fec_bd *bd;
 	u32 status, physaddr;
 	int length;
-	unsigned long flags;
 
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock(&priv->lock);
 
 	while (bcom_buffer_done(priv->rx_dmatsk)) {
 
@@ -429,7 +427,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 
 		/* Process the received skb - Drop the spin lock while
 		 * calling into the network stack */
-		spin_unlock_irqrestore(&priv->lock, flags);
+		spin_unlock(&priv->lock);
 
 		dma_unmap_single(dev->dev.parent, physaddr, rskb->len,
 				 DMA_FROM_DEVICE);
@@ -438,10 +436,10 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 		rskb->protocol = eth_type_trans(rskb, dev);
 		netif_rx(rskb);
 
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock(&priv->lock);
 	}
 
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock(&priv->lock);
 
 	return IRQ_HANDLED;
 }
@@ -452,7 +450,6 @@ static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct mpc52xx_fec __iomem *fec = priv->fec;
 	u32 ievent;
-	unsigned long flags;
 
 	ievent = in_be32(&fec->ievent);
 
@@ -470,9 +467,9 @@ static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
 		if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
 			dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
 
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock(&priv->lock);
 		mpc52xx_fec_reset(dev);
-		spin_unlock_irqrestore(&priv->lock, flags);
+		spin_unlock(&priv->lock);
 
 		return IRQ_HANDLED;
 	}


