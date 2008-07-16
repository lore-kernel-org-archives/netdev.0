From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 02/10] mv643xx_eth: fix TX hang erratum workaround
Date: Wed, 16 Jul 2008 12:32:06 +0200
Message-ID: <20080716103206.GC8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44727 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365AbYGPKcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previously merged TX hang erratum workaround ("mv643xx_eth:
work around TX hang hardware issue") assumes that TX_END interrupts
are delivered simultaneously with or after their corresponding TX
interrupts, but this is not always true in practise.

In particular, it appears that TX_END interrupts are issued as soon
as descriptor fetch returns an invalid descriptor, which may happen
before earlier descriptors have been fully transmitted and written
back to memory as being done.

This hardware behavior can lead to a situation where the current
driver code mistakenly assumes that the MAC has given up transmitting
before noticing the packets that it is in fact still currently working
on, causing the driver to re-kick the transmit queue, which will only
cause the MAC to re-fetch the invalid head descriptor, and generate
another TX_END interrupt, et cetera, until the packets in the pipe
finally finish transmitting and have their descriptors written back
to memory, which will then finally break the loop.

Fix this by having the erratum workaround not check the 'number of
unfinished descriptor', but instead, to compare the software's idea
of what the head descriptor pointer should be to the hardware's head
descriptor pointer (which is updated on the same conditions as the
TX_END interupt is generated on, i.e. possibly before all previous
descriptors have been transmitted and written back).

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8a97a00..910920e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -96,6 +96,7 @@ static char mv643xx_eth_driver_version[] = "1.1";
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define  INT_TX_END_0			0x00080000
 #define  INT_TX_END			0x07f80000
 #define  INT_RX				0x0007fbfc
 #define  INT_EXT			0x00000002
@@ -706,6 +707,7 @@ static inline __be16 sum16_as_be(__sum16 sum)
 
 static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int tx_index;
 	struct tx_desc *desc;
@@ -759,6 +761,10 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	wmb();
 	desc->cmd_sts = cmd_sts;
 
+	/* clear TX_END interrupt status */
+	wrl(mp, INT_CAUSE(mp->port_num), ~(INT_TX_END_0 << txq->index));
+	rdl(mp, INT_CAUSE(mp->port_num));
+
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
 	txq_enable(txq);
@@ -1684,7 +1690,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 int_cause;
 	u32 int_cause_ext;
-	u32 txq_active;
 
 	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
 			(INT_TX_END | INT_RX | INT_EXT);
@@ -1743,8 +1748,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	}
 #endif
 
-	txq_active = rdl(mp, TXQ_COMMAND(mp->port_num));
-
 	/*
 	 * TxBuffer or TxError set for any of the 8 queues?
 	 */
@@ -1754,6 +1757,14 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		for (i = 0; i < 8; i++)
 			if (mp->txq_mask & (1 << i))
 				txq_reclaim(mp->txq + i, 0);
+
+		/*
+		 * Enough space again in the primary TX queue for a
+		 * full packet?
+		 */
+		spin_lock(&mp->lock);
+		__txq_maybe_wake(mp->txq + mp->txq_primary);
+		spin_unlock(&mp->lock);
 	}
 
 	/*
@@ -1763,19 +1774,25 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		int i;
 
 		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
+
+		spin_lock(&mp->lock);
 		for (i = 0; i < 8; i++) {
 			struct tx_queue *txq = mp->txq + i;
-			if (txq->tx_desc_count && !((txq_active >> i) & 1))
+			u32 hw_desc_ptr;
+			u32 expected_ptr;
+
+			if ((int_cause & (INT_TX_END_0 << i)) == 0)
+				continue;
+
+			hw_desc_ptr =
+				rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, i));
+			expected_ptr = (u32)txq->tx_desc_dma +
+				txq->tx_curr_desc * sizeof(struct tx_desc);
+
+			if (hw_desc_ptr != expected_ptr)
 				txq_enable(txq);
 		}
-	}
-
-	/*
-	 * Enough space again in the primary TX queue for a full packet?
-	 */
-	if (int_cause_ext & INT_EXT_TX) {
-		struct tx_queue *txq = mp->txq + mp->txq_primary;
-		__txq_maybe_wake(txq);
+		spin_unlock(&mp->lock);
 	}
 
 	return IRQ_HANDLED;
-- 
1.5.3.4
