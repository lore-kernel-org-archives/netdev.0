From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 03/10] mv643xx_eth: prevent breakage when link goes down during transmit
Date: Wed, 16 Jul 2008 12:32:14 +0200
Message-ID: <20080716103214.GD8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44729 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192AbYGPKcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ethernet link goes down while mv643xx_eth is transmitting
data, transmit DMA can stop before all queued transmit descriptors
have been processed.  But even the descriptors that _have_ been
processed might not be properly marked as done before the transmit
DMA unit shuts down.

Then when the link comes up again, the hardware transmit pointer
might have advanced while not all previous packet descriptors have
been marked as transmitted, causing software transmit reclaim to
hang waiting for the hardware to finish transmitting a descriptor
that it has already skipped.

This patch forcibly reclaims all packets on the transmit ring on a
link down interrupt, and then resyncs the hardware transmit pointer to
what the software's idea of the first free descriptor is.  Also, we
need to prevent re-waking the transmit queue if we get a 'transmit
done' interrupt at the same time as a 'link down' interrupt, which
this patch does as well.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 910920e..d7620c5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -405,6 +405,17 @@ static void rxq_disable(struct rx_queue *rxq)
 		udelay(10);
 }
 
+static void txq_reset_hw_ptr(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int off = TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index);
+	u32 addr;
+
+	addr = (u32)txq->tx_desc_dma;
+	addr += txq->tx_curr_desc * sizeof(struct tx_desc);
+	wrl(mp, off, addr);
+}
+
 static void txq_enable(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
@@ -1545,8 +1556,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	tx_desc = (struct tx_desc *)txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
+		struct tx_desc *txd = tx_desc + i;
 		int nexti = (i + 1) % txq->tx_ring_size;
-		tx_desc[i].next_desc_ptr = txq->tx_desc_dma +
+
+		txd->cmd_sts = 0;
+		txd->next_desc_ptr = txq->tx_desc_dma +
 					nexti * sizeof(struct tx_desc);
 	}
 
@@ -1583,8 +1597,11 @@ static void txq_reclaim(struct tx_queue *txq, int force)
 		desc = &txq->tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
-		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA))
-			break;
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			if (!force)
+				break;
+			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+		}
 
 		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
 		txq->tx_desc_count--;
@@ -1705,8 +1722,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 
 	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
 		if (mp->phy_addr == -1 || mii_link_ok(&mp->mii)) {
-			int i;
-
 			if (mp->phy_addr != -1) {
 				struct ethtool_cmd cmd;
 
@@ -1714,17 +1729,24 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 				update_pscr(mp, cmd.speed, cmd.duplex);
 			}
 
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_enable(mp->txq + i);
-
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
-				__txq_maybe_wake(mp->txq + mp->txq_primary);
+				netif_wake_queue(dev);
 			}
 		} else if (netif_carrier_ok(dev)) {
+			int i;
+
 			netif_stop_queue(dev);
 			netif_carrier_off(dev);
+
+			for (i = 0; i < 8; i++) {
+				struct tx_queue *txq = mp->txq + i;
+
+				if (mp->txq_mask & (1 << i)) {
+					txq_reclaim(txq, 1);
+					txq_reset_hw_ptr(txq);
+				}
+			}
 		}
 	}
 
@@ -1762,9 +1784,11 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		 * Enough space again in the primary TX queue for a
 		 * full packet?
 		 */
-		spin_lock(&mp->lock);
-		__txq_maybe_wake(mp->txq + mp->txq_primary);
-		spin_unlock(&mp->lock);
+		if (netif_carrier_ok(dev)) {
+			spin_lock(&mp->lock);
+			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			spin_unlock(&mp->lock);
+		}
 	}
 
 	/*
@@ -1851,16 +1875,11 @@ static void port_start(struct mv643xx_eth_private *mp)
 	tx_set_rate(mp, 1000000000, 16777216);
 	for (i = 0; i < 8; i++) {
 		struct tx_queue *txq = mp->txq + i;
-		int off = TXQ_CURRENT_DESC_PTR(mp->port_num, i);
-		u32 addr;
 
 		if ((mp->txq_mask & (1 << i)) == 0)
 			continue;
 
-		addr = (u32)txq->tx_desc_dma;
-		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
-		wrl(mp, off, addr);
-
+		txq_reset_hw_ptr(txq);
 		txq_set_rate(txq, 1000000000, 16777216);
 		txq_set_fixed_prio_mode(txq);
 	}
-- 
1.5.3.4
