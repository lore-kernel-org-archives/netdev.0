From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH v2] net: macb: Handle the RXUBR interrupt on all devices
Date: Thu, 7 May 2015 13:41:52 -0500
Message-ID: <1431024112-11868-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a hardware issue under heavy load where DMA can stop.  This
causes endless "used buffer descriptor read" interrupts, but it can be
cleared by re-enabling RX. See the at91 manual section 41.3.1, or the
Zynq manual section 16.7.4, for details.

The at91 driver already works around this hardware issue, and the same
workaround applies to at least the Zynq Ethernet (and possibly more
devices), so apply it here as well.  In addition, handle the RXUBR
interrupt, since the driver turns it on with MACB_RX_INT_FLAGS anyway.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Reviewied-by: Josh Cartwright <joshc@ni.com>
Reviewied-by: Ben Shelton <ben.shelton@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4104d49..5f10dfc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -981,7 +981,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	struct macb_queue *queue = dev_id;
 	struct macb *bp = queue->bp;
 	struct net_device *dev = bp->dev;
-	u32 status;
+	u32 status, ctrl;
 
 	status = queue_readl(queue, ISR);
 
@@ -1037,6 +1037,21 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		 * add that if/when we get our hands on a full-blown MII PHY.
 		 */
 
+		/* There is a hardware issue under heavy load where DMA can
+		 * stop, this causes endless "used buffer descriptor read"
+		 * interrupts but it can be cleared by re-enabling RX. See
+		 * the at91 manual, section 41.3.1 or the Zynq manual
+		 * section 16.7.4 for details.
+		 */
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
