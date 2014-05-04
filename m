From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 2/5] net: macb: Clear interrupt flags
Date: Sun,  4 May 2014 15:42:59 -0700
Message-ID: <1399243382-12528-3-git-send-email-soren.brinkmann@xilinx.com>
References: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	git@xilinx.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few interrupt flags were not cleared in the ISR, resulting in a sytem
trapped in the ISR in cases one of those interrupts occurred. Clear all
flags to avoid such situations.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 18fdcd9d51b3..e38fe39d9589 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -951,6 +951,10 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		if (unlikely(status & (MACB_TX_ERR_FLAGS))) {
 			macb_writel(bp, IDR, MACB_TX_INT_FLAGS);
 			schedule_work(&bp->tx_error_task);
+
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				macb_writel(bp, ISR, MACB_TX_ERR_FLAGS);
+
 			break;
 		}
 
@@ -968,6 +972,9 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				bp->hw_stats.gem.rx_overruns++;
 			else
 				bp->hw_stats.macb.rx_overruns++;
+
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				macb_writel(bp, ISR, MACB_BIT(ISR_ROVR));
 		}
 
 		if (status & MACB_BIT(HRESP)) {
@@ -977,6 +984,9 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			 * (work queue?)
 			 */
 			netdev_err(dev, "DMA bus error: HRESP not OK\n");
+
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				macb_writel(bp, ISR, MACB_BIT(HRESP));
 		}
 
 		status = macb_readl(bp, ISR);
-- 
1.9.2.1.g06c4abd
