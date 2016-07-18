From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH] net: macb: Handle HRESP error
Date: Mon, 18 Jul 2016 12:46:40 +0530
Message-ID: <1468826200-15142-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<harinik@xilinx.com>, <punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle HRESP error by doing a SW reset of RX and TX and
re-initializing the descriptors, RX and TX queue pointers.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |   48 ++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h |    2 ++
 2 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..8ffb863 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1070,6 +1070,46 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static void macb_hresp_error_task(unsigned long data)
+{
+	struct macb *bp = (struct macb *)data;
+	struct net_device *dev = bp->dev;
+	struct macb_queue *queue = bp->queues;
+	unsigned int q;
+	u32 ctrl;
+
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue_writel(queue, IDR, MACB_RX_INT_FLAGS |
+					 MACB_TX_INT_FLAGS |
+					 MACB_BIT(HRESP));
+	}
+	ctrl = macb_readl(bp, NCR);
+	ctrl &= ~(MACB_BIT(RE) | MACB_BIT(TE));
+	macb_writel(bp, NCR, ctrl);
+
+	netif_tx_stop_all_queues(dev);
+	netif_carrier_off(dev);
+
+	bp->macbgem_ops.mog_init_rings(bp);
+
+	macb_writel(bp, RBQP, bp->rx_ring_dma);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue_writel(queue, TBQP, queue->tx_ring_dma);
+
+		/* Enable interrupts */
+		queue_writel(queue, IER,
+			     MACB_RX_INT_FLAGS |
+			     MACB_TX_INT_FLAGS |
+			     MACB_BIT(HRESP));
+	}
+
+	ctrl |= MACB_BIT(RE) | MACB_BIT(TE);
+	macb_writel(bp, NCR, ctrl);
+
+	netif_carrier_on(dev);
+	netif_tx_start_all_queues(dev);
+}
+
 static irqreturn_t macb_interrupt(int irq, void *dev_id)
 {
 	struct macb_queue *queue = dev_id;
@@ -1158,10 +1198,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (status & MACB_BIT(HRESP)) {
-			/* TODO: Reset the hardware, and maybe move the
-			 * netdev_err to a lower-priority context as well
-			 * (work queue?)
-			 */
+			tasklet_schedule(&bp->hresp_err_tasklet);
 			netdev_err(dev, "DMA bus error: HRESP not OK\n");
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
@@ -2998,6 +3035,9 @@ static int macb_probe(struct platform_device *pdev)
 
 	phy_attached_info(phydev);
 
+	tasklet_init(&bp->hresp_err_tasklet, macb_hresp_error_task,
+		     (unsigned long)bp);
+
 	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
 		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
 		    dev->base_addr, dev->irq, dev->dev_addr);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 36893d8..8393068 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -845,6 +845,8 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+
+	struct tasklet_struct   hresp_err_tasklet;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.9.5
