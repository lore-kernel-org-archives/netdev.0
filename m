From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 1/2] can: xilinx: Fix ksoftirq CPU monopolization
Date: Mon,  7 Aug 2017 15:47:56 +0200
Message-ID: <21850c76207942f5ae5c225f2627fb068d5234d0.1502113674.git.michal.simek@xilinx.com>
Cc: Matthias Auchmann <m.auchmann@artech.at>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
        linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Auchmann <m.auchmann@artech.at>

When using both the RXOK and the RXNEMP interrupt, when there were more
than one receive messages in the FIFO, ksoftirqd started to go crazy
and monopolize one CPU. The reason being is that RXOK just fires once
even if there are multiple frames sitting in the RX FIFO, so the code
didn't reflect that properly.

Changed that to only use the RXNEMP interrupt and thereby got rid of the
bug.

Signed-off-by: Matthias Auchmann <m.auchmann@artech.at>
Acked-by: Kedareswara rao Appana <appanad@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/can/xilinx_can.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 89aec07c225f..05ea2820d27b 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -101,7 +101,7 @@ enum xcan_reg {
 #define XCAN_INTR_ALL		(XCAN_IXR_TXOK_MASK | XCAN_IXR_BSOFF_MASK |\
 				 XCAN_IXR_WKUP_MASK | XCAN_IXR_SLP_MASK | \
 				 XCAN_IXR_RXNEMP_MASK | XCAN_IXR_ERROR_MASK | \
-				 XCAN_IXR_ARBLST_MASK | XCAN_IXR_RXOK_MASK)
+				 XCAN_IXR_ARBLST_MASK)
 
 /* CAN register bit shift - XCAN_<REG>_<BIT>_SHIFT */
 #define XCAN_BTR_SJW_SHIFT		7  /* Synchronous jump width */
@@ -709,15 +709,7 @@ static int xcan_rx_poll(struct napi_struct *napi, int quota)
 
 	isr = priv->read_reg(priv, XCAN_ISR_OFFSET);
 	while ((isr & XCAN_IXR_RXNEMP_MASK) && (work_done < quota)) {
-		if (isr & XCAN_IXR_RXOK_MASK) {
-			priv->write_reg(priv, XCAN_ICR_OFFSET,
-				XCAN_IXR_RXOK_MASK);
-			work_done += xcan_rx(ndev);
-		} else {
-			priv->write_reg(priv, XCAN_ICR_OFFSET,
-				XCAN_IXR_RXNEMP_MASK);
-			break;
-		}
+		work_done += xcan_rx(ndev);
 		priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_RXNEMP_MASK);
 		isr = priv->read_reg(priv, XCAN_ISR_OFFSET);
 	}
@@ -728,7 +720,7 @@ static int xcan_rx_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		napi_complete_done(napi, work_done);
 		ier = priv->read_reg(priv, XCAN_IER_OFFSET);
-		ier |= (XCAN_IXR_RXOK_MASK | XCAN_IXR_RXNEMP_MASK);
+		ier |= XCAN_IXR_RXNEMP_MASK;
 		priv->write_reg(priv, XCAN_IER_OFFSET, ier);
 	}
 	return work_done;
@@ -800,9 +792,9 @@ static irqreturn_t xcan_interrupt(int irq, void *dev_id)
 	}
 
 	/* Check for the type of receive interrupt and Processing it */
-	if (isr & (XCAN_IXR_RXNEMP_MASK | XCAN_IXR_RXOK_MASK)) {
+	if (isr & XCAN_IXR_RXNEMP_MASK) {
 		ier = priv->read_reg(priv, XCAN_IER_OFFSET);
-		ier &= ~(XCAN_IXR_RXNEMP_MASK | XCAN_IXR_RXOK_MASK);
+		ier &= ~XCAN_IXR_RXNEMP_MASK;
 		priv->write_reg(priv, XCAN_IER_OFFSET, ier);
 		napi_schedule(&priv->napi);
 	}
-- 
1.9.1

