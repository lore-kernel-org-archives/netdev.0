From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net-next] altera_tse: Fixes in NAPI and interrupt handling paths
Date: Mon, 23 Feb 2015 11:30:29 -0600
Message-ID: <1424712629-24330-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>,
	<setka@vsis.cz>, Roman Pisl <rpisl@kky.zcu.cz>
To: <netdev@vger.kernel.org>, <nios2-dev@lists.rocketboards.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlastimil Setka <setka@vsis.cz>

Incorrect NAPI polling caused WARNING at net/core/dev.c net_rx_action.
Some stability issues were also seen at high throughput and system
load before this patch.

This patch contains several changes in altera_tse_main.c:

- tse_rx() is fixed to not process more than `limit` frames

- tse_poll() is refactored to match NAPI logic
  - only received frames are counted for return value
  - removed bogus condition `(rxcomplete >= budget || txcomplete > 0)`
  - replace by: if (rxcomplete < budget) -> call __napi_complete and enable irq

- altera_isr()
  - replace spin_lock_irqsave() by spin_lock() - we are in isr
  - use spinlocks just over irq manipulation, not over __napi_schedule
  - reset IRQ first, then disable and schedule napi

This is a cleaned up resubmission from Vlastimil's recent submission.

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
Signed-off-by: Roman Pisl <rpisl@kky.zcu.cz>
Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 45 +++++++++++++--------------
 1 file changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 91ad435..fd9296a 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -376,7 +376,8 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 	u16 pktlength;
 	u16 pktstatus;
 
-	while ((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) {
+	while (((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) &&
+	       (count < limit))  {
 		pktstatus = rxstatus >> 16;
 		pktlength = rxstatus & 0xffff;
 
@@ -491,28 +492,27 @@ static int tse_poll(struct napi_struct *napi, int budget)
 	struct altera_tse_private *priv =
 			container_of(napi, struct altera_tse_private, napi);
 	int rxcomplete = 0;
-	int txcomplete = 0;
 	unsigned long int flags;
 
-	txcomplete = tse_tx_complete(priv);
+	tse_tx_complete(priv);
 
 	rxcomplete = tse_rx(priv, budget);
 
-	if (rxcomplete >= budget || txcomplete > 0)
-		return rxcomplete;
+	if (rxcomplete < budget) {
 
-	napi_gro_flush(napi, false);
-	__napi_complete(napi);
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
 
-	netdev_dbg(priv->dev,
-		   "NAPI Complete, did %d packets with budget %d\n",
-		   txcomplete+rxcomplete, budget);
+		netdev_dbg(priv->dev,
+			   "NAPI Complete, did %d packets with budget %d\n",
+			   rxcomplete, budget);
 
-	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
-	priv->dmaops->enable_rxirq(priv);
-	priv->dmaops->enable_txirq(priv);
-	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
-	return rxcomplete + txcomplete;
+		spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+		priv->dmaops->enable_rxirq(priv);
+		priv->dmaops->enable_txirq(priv);
+		spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+	}
+	return rxcomplete;
 }
 
 /* DMA TX & RX FIFO interrupt routing
@@ -521,7 +521,6 @@ static irqreturn_t altera_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct altera_tse_private *priv;
-	unsigned long int flags;
 
 	if (unlikely(!dev)) {
 		pr_err("%s: invalid dev pointer\n", __func__);
@@ -529,20 +528,20 @@ static irqreturn_t altera_isr(int irq, void *dev_id)
 	}
 	priv = netdev_priv(dev);
 
-	/* turn off desc irqs and enable napi rx */
-	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+	spin_lock(&priv->rxdma_irq_lock);
+	/* reset IRQs */
+	priv->dmaops->clear_rxirq(priv);
+	priv->dmaops->clear_txirq(priv);
+	spin_unlock(&priv->rxdma_irq_lock);
 
 	if (likely(napi_schedule_prep(&priv->napi))) {
+		spin_lock(&priv->rxdma_irq_lock);
 		priv->dmaops->disable_rxirq(priv);
 		priv->dmaops->disable_txirq(priv);
+		spin_unlock(&priv->rxdma_irq_lock);
 		__napi_schedule(&priv->napi);
 	}
 
-	/* reset IRQs */
-	priv->dmaops->clear_rxirq(priv);
-	priv->dmaops->clear_txirq(priv);
-
-	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
 
 	return IRQ_HANDLED;
 }
-- 
1.9.1
