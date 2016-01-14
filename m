From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net: macb: clear interrupts when disabling them
Date: Thu, 14 Jan 2016 13:27:27 -0600
Message-ID: <1452799647-1426-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disabling interrupts with the IDR register does not stop the macb hardware
from asserting its interrupt line if there are interrupts pending.  Always
clear the interrupts using ISR, and be sure to write it on hardware that
is not read-to-clear, like Zynq.  Not doing so will cause interrupts when
the driver doesn't expect them.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c563475..9d9984a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1040,6 +1040,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		/* close possible race with dev_close */
 		if (unlikely(!netif_running(dev))) {
 			queue_writel(queue, IDR, -1);
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, -1);
 			break;
 		}
 
@@ -1561,6 +1563,8 @@ static void macb_reset_hw(struct macb *bp)
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
 		queue_writel(queue, IDR, -1);
 		queue_readl(queue, ISR);
+		if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+			queue_writel(queue, ISR, -1);
 	}
 }
 
-- 
1.7.10.4
