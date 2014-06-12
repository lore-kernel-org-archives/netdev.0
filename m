From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Thu, 12 Jun 2014 17:50:54 +0900
Message-ID: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com>
Cc: linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	Jongsung Kim <neidhard.kim@lge.com>,
	Youngkyu Choi <youngkyu7.choi@lge.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "Rx used bit read" interrupt is enabled but not cleared for some
systems with the ISR (Interrupt Status Register) configured as clear-
on-write. This interrupt may be asserted when the CPU does not handle
Rx-complete interrupts for a long time. (e.g., if the CPU is stopped
by debugger) Once asserted, it'll not be cleared, and the CPU will
loop infinitly in the interrupt handler.

This patch forces to use a dedicated function for reading the ISR,
and the function clears it if clear-on-write. So the ISR is always
cleared after read, regardless of clear-on-write configuration.

Reported-by: Hayun Hwang <hwang.hayun@lge.com>
Signed-off-by: Youngkyu Choi <youngkyu7.choi@lge.com>
Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
Tested-by: Hayun Hwang <hwang.hayun@lge.com>
---
 drivers/net/ethernet/cadence/macb.c |   37 ++++++++++++++--------------------
 1 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e9daa07..21cc022 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -98,6 +98,16 @@ static void *macb_rx_buffer(struct macb *bp, unsigned int index)
 	return bp->rx_buffers + bp->rx_buffer_size * macb_rx_ring_wrap(index);
 }
 
+static u32 macb_read_isr(struct macb *bp)
+{
+	u32 status = macb_readl(bp, ISR);
+
+	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+		macb_writel(bp, ISR, status);
+
+	return status;
+}
+
 void macb_set_hwaddr(struct macb *bp)
 {
 	u32 bottom;
@@ -552,9 +562,6 @@ static void macb_tx_interrupt(struct macb *bp)
 	status = macb_readl(bp, TSR);
 	macb_writel(bp, TSR, status);
 
-	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-		macb_writel(bp, ISR, MACB_BIT(TCOMP));
-
 	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
 		(unsigned long)status);
 
@@ -883,13 +890,10 @@ static int macb_poll(struct napi_struct *napi, int budget)
 
 		/* Packets received while interrupts were disabled */
 		status = macb_readl(bp, RSR);
-		if (status) {
-			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(RCOMP));
+		if (status)
 			napi_reschedule(napi);
-		} else {
+		else
 			macb_writel(bp, IER, MACB_RX_INT_FLAGS);
-		}
 	}
 
 	/* TODO: Handle errors */
@@ -903,7 +907,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	struct macb *bp = netdev_priv(dev);
 	u32 status;
 
-	status = macb_readl(bp, ISR);
+	status = macb_read_isr(bp);
 
 	if (unlikely(!status))
 		return IRQ_NONE;
@@ -928,8 +932,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			 * now.
 			 */
 			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
-			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(RCOMP));
 
 			if (napi_schedule_prep(&bp->napi)) {
 				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
@@ -941,9 +943,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			macb_writel(bp, IDR, MACB_TX_INT_FLAGS);
 			schedule_work(&bp->tx_error_task);
 
-			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_TX_ERR_FLAGS);
-
 			break;
 		}
 
@@ -961,9 +960,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				bp->hw_stats.gem.rx_overruns++;
 			else
 				bp->hw_stats.macb.rx_overruns++;
-
-			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(ISR_ROVR));
 		}
 
 		if (status & MACB_BIT(HRESP)) {
@@ -973,12 +969,9 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			 * (work queue?)
 			 */
 			netdev_err(dev, "DMA bus error: HRESP not OK\n");
-
-			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(HRESP));
 		}
 
-		status = macb_readl(bp, ISR);
+		status = macb_read_isr(bp);
 	}
 
 	spin_unlock(&bp->lock);
@@ -1273,7 +1266,7 @@ static void macb_reset_hw(struct macb *bp)
 
 	/* Disable all interrupts */
 	macb_writel(bp, IDR, -1);
-	macb_readl(bp, ISR);
+	macb_read_isr(bp);
 }
 
 static u32 gem_mdc_clk_div(struct macb *bp)
-- 
1.7.1
