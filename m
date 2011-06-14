From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 5/24] bnx2x: avoid release of unrequested irqs
Date: Tue, 14 Jun 2011 14:33:08 +0300
Message-ID: <201106141433.08430.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2356 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab1FNLdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   43 +++++++++++++++++++++++++++-------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index d8e6571..dabfec0 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1095,30 +1095,43 @@ void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value)
 	}
 }
 
-static void bnx2x_free_msix_irqs(struct bnx2x *bp)
+/**
+ * bnx2x_free_msix_irqs - free previously requested MSI-X IRQ vectors
+ *
+ * @bp:		driver handle
+ * @nvecs:	number of vectors to be released
+ */
+static void bnx2x_free_msix_irqs(struct bnx2x *bp, int nvecs)
 {
-	int i, offset = 1;
+	int i, offset = 0;
 
-	free_irq(bp->msix_table[0].vector, bp->dev);
+	if (nvecs == offset)
+		return;
+	free_irq(bp->msix_table[offset].vector, bp->dev);
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
-	   bp->msix_table[0].vector);
-
+	   bp->msix_table[offset].vector);
+	offset++;
 #ifdef BCM_CNIC
+	if (nvecs == offset)
+		return;
 	offset++;
 #endif
+
 	for_each_eth_queue(bp, i) {
-		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
-		   "state %x\n", i, bp->msix_table[i + offset].vector,
-		   bnx2x_fp(bp, i, state));
+		if (nvecs == offset)
+			return;
+		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d "
+		   "irq\n", i, bp->msix_table[offset].vector);
 
-		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
+		free_irq(bp->msix_table[offset++].vector, &bp->fp[i]);
 	}
 }
 
 void bnx2x_free_irq(struct bnx2x *bp)
 {
 	if (bp->flags & USING_MSIX_FLAG)
-		bnx2x_free_msix_irqs(bp);
+		bnx2x_free_msix_irqs(bp, BNX2X_NUM_ETH_QUEUES(bp) +
+				     CNIC_CONTEXT_USE + 1);
 	else if (bp->flags & USING_MSI_FLAG)
 		free_irq(bp->pdev->irq, bp->dev);
 	else
@@ -1191,9 +1204,10 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 {
-	int i, rc, offset = 1;
+	int i, rc, offset = 0;
 
-	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
+	rc = request_irq(bp->msix_table[offset++].vector,
+			 bnx2x_msix_sp_int, 0,
 			 bp->dev->name, bp->dev);
 	if (rc) {
 		BNX2X_ERR("request sp irq failed\n");
@@ -1211,8 +1225,9 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		rc = request_irq(bp->msix_table[offset].vector,
 				 bnx2x_msix_fp_int, 0, fp->name, fp);
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed  rc %d\n", i, rc);
-			bnx2x_free_msix_irqs(bp);
+			BNX2X_ERR("request fp #%d irq (%d) failed  rc %d\n", i,
+			      bp->msix_table[offset].vector, rc);
+			bnx2x_free_msix_irqs(bp, offset);
 			return -EBUSY;
 		}
 
-- 
1.7.2.2


