From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: improve TX timeout
Date: Thu,  4 Jun 2015 16:15:50 -0700
Message-ID: <1433459750-14861-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:32815 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbFDXQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 19:16:58 -0400
Received: by qcmi9 with SMTP id i9so24039010qcm.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 16:16:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump useful ring statistics along with interrupt status, software
maintained pointers and hardware registers to help troubleshoot TX queue
stalls.

When a timeout occurs, disable TX NAPI for the rings, dump their states
while interrupts are disabled, re-enable interrupts, NAPI and queue flow
control to help with the recovery.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 67 ++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 6043734ea613..b43b2cb9b830 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2770,12 +2770,79 @@ static int bcmgenet_close(struct net_device *dev)
 	return ret;
 }
 
+static void bcmgenet_dump_tx_queue(struct bcmgenet_tx_ring *ring)
+{
+	struct bcmgenet_priv *priv = ring->priv;
+	u32 p_index, c_index, intsts, intmsk;
+	struct netdev_queue *txq;
+	unsigned int free_bds;
+	unsigned long flags;
+	bool txq_stopped;
+
+	if (!netif_msg_tx_err(priv))
+		return;
+
+	txq = netdev_get_tx_queue(priv->dev, ring->queue);
+
+	spin_lock_irqsave(&ring->lock, flags);
+	if (ring->index == DESC_INDEX) {
+		intsts = ~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
+		intmsk = UMAC_IRQ_TXDMA_DONE | UMAC_IRQ_TXDMA_MBDONE;
+	} else {
+		intsts = ~bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_MASK_STATUS);
+		intmsk = 1 << ring->index;
+	}
+	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
+	p_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_PROD_INDEX);
+	txq_stopped = netif_tx_queue_stopped(txq);
+	free_bds = ring->free_bds;
+	spin_unlock_irqrestore(&ring->lock, flags);
+
+	netif_err(priv, tx_err, priv->dev, "Ring %d queue %d status summary\n"
+		  "TX queue status: %s, interrupts: %s\n"
+		  "(sw)free_bds: %d (sw)size: %d\n"
+		  "(sw)p_index: %d (hw)p_index: %d\n"
+		  "(sw)c_index: %d (hw)c_index: %d\n"
+		  "(sw)clean_p: %d (sw)write_p: %d\n"
+		  "(sw)cb_ptr: %d (sw)end_ptr: %d\n",
+		  ring->index, ring->queue,
+		  txq_stopped ? "stopped" : "active",
+		  intsts & intmsk ? "enabled" : "disabled",
+		  free_bds, ring->size,
+		  ring->prod_index, p_index & DMA_P_INDEX_MASK,
+		  ring->c_index, c_index & DMA_C_INDEX_MASK,
+		  ring->clean_ptr, ring->write_ptr,
+		  ring->cb_ptr, ring->end_ptr);
+}
+
 static void bcmgenet_timeout(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
+	u32 int0_enable = 0;
+	u32 int1_enable = 0;
+	unsigned int q;
 
 	netif_dbg(priv, tx_err, dev, "bcmgenet_timeout\n");
 
+	bcmgenet_disable_tx_napi(priv);
+
+	for (q = 0; q < priv->hw_params->tx_queues; q++)
+		bcmgenet_dump_tx_queue(&priv->tx_rings[q]);
+	bcmgenet_dump_tx_queue(&priv->tx_rings[DESC_INDEX]);
+
+	bcmgenet_tx_reclaim_all(dev);
+
+	for (q = 0; q < priv->hw_params->tx_queues; q++)
+		int1_enable |= (1 << q);
+
+	int0_enable = UMAC_IRQ_TXDMA_DONE;
+
+	/* Re-enable TX interrupts if disabled */
+	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
+
+	bcmgenet_enable_tx_napi(priv);
+
 	dev->trans_start = jiffies;
 
 	dev->stats.tx_errors++;
-- 
2.1.0
