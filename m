From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 3/9] net/macb: change debugging messages
Date: Wed, 19 Sep 2012 13:55:16 +0200
Message-ID: <b853c43377c39e410fcade1cddda1019fbd103ca.1348055112.git.nicolas.ferre@atmel.com>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, patrice.vilchez@atmel.com,
 linux-kernel@vger.kernel.org, bhutchings@solarflare.com, plagnioj@jcrosoft.com,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <havard@skinnemoen.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1348055112.git.nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Convert some noisy netdev_dbg() statements to netdev_vdbg(). Defining
DEBUG will no longer fill up the logs; VERBOSE_DEBUG still does.
Add one more verbose debug for ISR status.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: split patch in topics, add ISR status]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 313cba2..2948553 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -310,7 +310,7 @@ static void macb_tx(struct macb *bp)
 	status = macb_readl(bp, TSR);
 	macb_writel(bp, TSR, status);
 
-	netdev_dbg(bp->dev, "macb_tx status = %02lx\n", (unsigned long)status);
+	netdev_vdbg(bp->dev, "macb_tx status = %02lx\n", (unsigned long)status);
 
 	if (status & (MACB_BIT(UND) | MACB_BIT(TSR_RLE))) {
 		int i;
@@ -377,7 +377,7 @@ static void macb_tx(struct macb *bp)
 		if (!(bufstat & MACB_BIT(TX_USED)))
 			break;
 
-		netdev_dbg(bp->dev, "skb %u (data %p) TX complete\n",
+		netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 			   tail, skb->data);
 		dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
 				 DMA_TO_DEVICE);
@@ -403,7 +403,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 
 	len = MACB_BFEXT(RX_FRMLEN, bp->rx_ring[last_frag].ctrl);
 
-	netdev_dbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
+	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		   first_frag, last_frag, len);
 
 	skb = netdev_alloc_skb(bp->dev, len + RX_OFFSET);
@@ -450,7 +450,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 
 	bp->stats.rx_packets++;
 	bp->stats.rx_bytes += len;
-	netdev_dbg(bp->dev, "received skb of length %u, csum: %08x\n",
+	netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
 		   skb->len, skb->csum);
 	netif_receive_skb(skb);
 
@@ -532,7 +532,7 @@ static int macb_poll(struct napi_struct *napi, int budget)
 
 	work_done = 0;
 
-	netdev_dbg(bp->dev, "poll: status = %08lx, budget = %d\n",
+	netdev_vdbg(bp->dev, "poll: status = %08lx, budget = %d\n",
 		   (unsigned long)status, budget);
 
 	work_done = macb_rx(bp, budget);
@@ -571,6 +571,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			break;
 		}
 
+		netdev_vdbg(bp->dev, "isr = 0x%08lx\n", (unsigned long)status);
+
 		if (status & MACB_RX_INT_FLAGS) {
 			/*
 			 * There's no point taking any more interrupts
@@ -582,7 +584,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 
 			if (napi_schedule_prep(&bp->napi)) {
-				netdev_dbg(bp->dev, "scheduling RX softirq\n");
+				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
 				__napi_schedule(&bp->napi);
 			}
 		}
@@ -644,8 +646,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 ctrl;
 	unsigned long flags;
 
-#ifdef DEBUG
-	netdev_dbg(bp->dev,
+#if defined(DEBUG) && defined(VERBOSE_DEBUG)
+	netdev_vdbg(bp->dev,
 		   "start_xmit: len %u head %p data %p tail %p end %p\n",
 		   skb->len, skb->head, skb->data,
 		   skb_tail_pointer(skb), skb_end_pointer(skb));
@@ -667,12 +669,12 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	entry = bp->tx_head;
-	netdev_dbg(bp->dev, "Allocated ring entry %u\n", entry);
+	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
 	mapping = dma_map_single(&bp->pdev->dev, skb->data,
 				 len, DMA_TO_DEVICE);
 	bp->tx_skb[entry].skb = skb;
 	bp->tx_skb[entry].mapping = mapping;
-	netdev_dbg(bp->dev, "Mapped skb data %p to DMA addr %08lx\n",
+	netdev_vdbg(bp->dev, "Mapped skb data %p to DMA addr %08lx\n",
 		   skb->data, (unsigned long)mapping);
 
 	ctrl = MACB_BF(TX_FRMLEN, len);
-- 
1.7.11.3
