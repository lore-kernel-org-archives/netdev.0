From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 3/3] smc911x: Make the driver safer on SMP
Date: Mon, 20 Oct 2008 18:15:37 +0100
Message-ID: <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:52986 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751670AbYJTRkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:40:18 -0400
Received: from cam-owa2.Emea.Arm.com (cam-owa2.emea.arm.com [10.1.105.18])
	by cam-admin0.cambridge.arm.com (8.12.6/8.12.6) with ESMTP id m9KHFc6e003400
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:15:38 +0100 (BST)
In-Reply-To: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the critical regions covered by lp->lock to make it
safer on SMP. The main failure point was the smc911x_hard_start_xmit
function being called from different CPUs. It was tested on the ARM SMP
platforms.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 drivers/net/smc911x.c |   25 ++++++++-----------------
 1 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 0216440..89f1fa6 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -155,23 +155,17 @@ static void PRINT_PKT(u_char *buf, int length)
 /* this enables an interrupt in the interrupt mask register */
 #define SMC_ENABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
-	unsigned long __flags;				\
-	spin_lock_irqsave(&lp->lock, __flags);		\
 	__mask = SMC_GET_INT_EN((lp));			\
 	__mask |= (x);					\
 	SMC_SET_INT_EN((lp), __mask);			\
-	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
 /* this disables an interrupt from the interrupt mask register */
 #define SMC_DISABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
-	unsigned long __flags;				\
-	spin_lock_irqsave(&lp->lock, __flags);		\
 	__mask = SMC_GET_INT_EN((lp));			\
 	__mask &= ~(x);					\
 	SMC_SET_INT_EN((lp), __mask);			\
-	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
 /*
@@ -279,6 +273,8 @@ static void smc911x_enable(struct net_device *dev)
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
+	spin_lock_irqsave(&lp->lock, flags);
+
 	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
 
 	/* Enable TX */
@@ -291,12 +287,10 @@ static void smc911x_enable(struct net_device *dev)
 	SMC_SET_FIFO_TSL(lp, 64);
 	SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
 
-	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(lp, cr);
 	cr |= MAC_CR_TXEN_ | MAC_CR_HBDIS_;
 	SMC_SET_MAC_CR(lp, cr);
 	SMC_SET_TX_CFG(lp, TX_CFG_TX_ON_);
-	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Add 2 byte padding to start of packets */
 	SMC_SET_RX_CFG(lp, (2<<8) & RX_CFG_RXDOFF_);
@@ -305,9 +299,7 @@ static void smc911x_enable(struct net_device *dev)
 	if (cr & MAC_CR_RXEN_)
 		DBG(SMC_DEBUG_RX, "%s: Receiver already enabled\n", dev->name);
 
-	spin_lock_irqsave(&lp->lock, flags);
 	SMC_SET_MAC_CR(lp, cr | MAC_CR_RXEN_);
-	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Interrupt on every received packet */
 	SMC_SET_FIFO_RSA(lp, 0x01);
@@ -323,6 +315,8 @@ static void smc911x_enable(struct net_device *dev)
 		mask|=INT_EN_RDFO_EN_;
 	}
 	SMC_ENABLE_INT(lp, mask);
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 /*
@@ -463,7 +457,6 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	struct sk_buff *skb;
 	unsigned int cmdA, cmdB, len;
 	unsigned char *buf;
-	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __func__);
 	BUG_ON(lp->pending_tx_skb == NULL);
@@ -508,11 +501,9 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 #endif
-	spin_lock_irqsave(&lp->lock, flags);
 	if (!lp->tx_throttle) {
 		netif_wake_queue(dev);
 	}
-	spin_unlock_irqrestore(&lp->lock, flags);
 	SMC_ENABLE_INT(lp, INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_);
 }
 
@@ -531,6 +522,8 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
 		dev->name, __func__);
 
+	spin_lock_irqsave(&lp->lock, flags);
+
 	BUG_ON(lp->pending_tx_skb != NULL);
 
 	free = SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TDFREE_;
@@ -540,12 +533,10 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (free <= SMC911X_TX_FIFO_LOW_THRESHOLD) {
 		DBG(SMC_DEBUG_TX, "%s: Disabling data flow due to low FIFO space (%d)\n",
 			dev->name, free);
-		spin_lock_irqsave(&lp->lock, flags);
 		/* Reenable when at least 1 packet of size MTU present */
 		SMC_SET_FIFO_TDA(lp, (SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
 		lp->tx_throttle = 1;
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 
 	/* Drop packets when we run out of space in TX FIFO
@@ -561,6 +552,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lp->pending_tx_skb = NULL;
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
+		spin_unlock_irqrestore(&lp->lock, flags);
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -570,7 +562,6 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* If the DMA is already running then defer this packet Tx until
 		 * the DMA IRQ starts it
 		 */
-		spin_lock_irqsave(&lp->lock, flags);
 		if (lp->txdma_active) {
 			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: Tx DMA running, deferring packet\n", dev->name);
 			lp->pending_tx_skb = skb;
@@ -581,11 +572,11 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: Activating Tx DMA\n", dev->name);
 			lp->txdma_active = 1;
 		}
-		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 #endif
 	lp->pending_tx_skb = skb;
 	smc911x_hardware_send_pkt(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return 0;
 }

