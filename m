From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH] Restore the original TX FIFO overflow process.
Date: Fri, 22 Sep 2006 15:30:01 -0400
Message-ID: <1158953401.2630.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr48.hinet.net ([168.95.4.148]:60885 "EHLO msr48.hinet.net")
	by vger.kernel.org with ESMTP id S1750882AbWIVHoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 03:44:00 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
   - Restore the original TX FIFO overflow process.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>

---

 drivers/net/sundance.c |   45 +++++++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 18 deletions(-)

7d8d60d6b1dbdbc36896148df1cc0242c037d838
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a253924..e68d325 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -21,8 +21,8 @@
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.01+LK1.14"
-#define DRV_RELDATE	"04-Aug-2006"
+#define DRV_VERSION	"1.01+LK1.15"
+#define DRV_RELDATE	"22-Sep-2006"
 
 
 /* The user-configurable values.
@@ -1167,24 +1167,33 @@ static irqreturn_t intr_handler(int irq,
 					if (tx_status & 0x02)
 						np->stats.tx_window_errors++;
 
-					/* FIFO ERROR need to be reset tx */
-					if (tx_status & 0x10) {	/* Reset the Tx. */
-						spin_lock(&np->lock);
-						reset_tx(dev);
-						spin_unlock(&np->lock);
-					}
-					if (tx_status & 0x1e) {
-					/* need to make sure tx enabled */
-						int i = 10;
-						do {
-							iowrite16(ioread16(ioaddr + MACCtrl1) | TxEnable, ioaddr + MACCtrl1);
-							if (ioread16(ioaddr + MACCtrl1) & TxEnabled)
-								break;
-							mdelay(1);
-						} while (--i);
+					/*
+					** This reset has been verified on
+					** DFE-580TX boards ! phdm@macqel.be.
+					*/
+					if (tx_status & 0x10) {	/* TxUnderrun */
+						unsigned short txthreshold;
+
+						txthreshold = ioread16 (ioaddr + TxStartThresh);
+						/* Restart Tx FIFO and transmitter */
+						sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
+						iowrite16 (txthreshold, ioaddr + TxStartThresh);
+						/* No need to reset the Tx pointer here */
 					}
+					/* Restart the Tx. */
+					iowrite16 (TxEnable, ioaddr + MACCtrl1);
 				}
-
+				if (tx_status & 0x1e) {
+				/* need to make sure tx enabled */
+					int i = 10;
+					do {
+						iowrite16(ioread16(ioaddr + MACCtrl1) | TxEnable, ioaddr + MACCtrl1);
+						if (ioread16(ioaddr + MACCtrl1) & TxEnabled)
+							break;
+						mdelay(1);
+					} while (--i);
+				}
+				
 				iowrite16 (0, ioaddr + TxStatus);
 				tx_status = ioread16 (ioaddr + TxStatus);
 				if (tx_cnt < 0)
-- 
1.3.GIT



