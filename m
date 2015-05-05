From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net: macb: Handle the RXUBR interrupt on all devices
Date: Tue, 5 May 2015 15:00:25 -0500
Message-ID: <1430856025-1066-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The same hardware issue the at91 must work around applies to at least the
Zynq ethernet, and possibly more devices.  The driver also needs to handle
the RXUBR interrupt since it turns it on with MACB_RX_INT_FLAGS anyway.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4104d49..61aa570 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -981,7 +981,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	struct macb_queue *queue = dev_id;
 	struct macb *bp = queue->bp;
 	struct net_device *dev = bp->dev;
-	u32 status;
+	u32 status, ctrl;
 
 	status = queue_readl(queue, ISR);
 
@@ -1037,6 +1037,15 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		 * add that if/when we get our hands on a full-blown MII PHY.
 		 */
 
+		if (status & MACB_BIT(RXUBR)) {
+			ctrl = macb_readl(bp, NCR);
+			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
+			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
+
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				macb_writel(bp, ISR, MACB_BIT(RXUBR));
+		}
+
 		if (status & MACB_BIT(ISR_ROVR)) {
 			/* We missed at least one packet */
 			if (macb_is_gem(bp))
-- 
1.7.10.4
