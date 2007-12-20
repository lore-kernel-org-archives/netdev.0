From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/9][BNX2]: Restructure IRQ datastructures.
Date: Thu, 20 Dec 2007 12:31:28 -0800
Message-ID: <1198182688.9163.28.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3541 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbXLTTqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Restructure IRQ datastructures.

Add a table to keep track of multiple IRQs and restructure the IRQ
request and free functions so that they can be easily expanded to
handle multiple IRQs.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f19a1e9..83cdbde 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5234,18 +5234,15 @@ static int
 bnx2_request_irq(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
-	int rc = 0;
-
-	if (bp->flags & USING_MSI_FLAG) {
-		irq_handler_t	fn = bnx2_msi;
-
-		if (bp->flags & ONE_SHOT_MSI_FLAG)
-			fn = bnx2_msi_1shot;
+	unsigned long flags;
+	struct bnx2_irq *irq = &bp->irq_tbl[0];
+	int rc;
 
-		rc = request_irq(bp->pdev->irq, fn, 0, dev->name, dev);
-	} else
-		rc = request_irq(bp->pdev->irq, bnx2_interrupt,
-				 IRQF_SHARED, dev->name, dev);
+	if (bp->flags & USING_MSI_FLAG)
+		flags = 0;
+	else
+		flags = IRQF_SHARED;
+	rc = request_irq(irq->vector, irq->handler, flags, dev->name, dev);
 	return rc;
 }
 
@@ -5254,12 +5251,31 @@ bnx2_free_irq(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
 
+	free_irq(bp->irq_tbl[0].vector, dev);
 	if (bp->flags & USING_MSI_FLAG) {
-		free_irq(bp->pdev->irq, dev);
 		pci_disable_msi(bp->pdev);
 		bp->flags &= ~(USING_MSI_FLAG | ONE_SHOT_MSI_FLAG);
-	} else
-		free_irq(bp->pdev->irq, dev);
+	}
+}
+
+static void
+bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
+{
+	bp->irq_tbl[0].handler = bnx2_interrupt;
+	strcpy(bp->irq_tbl[0].name, bp->dev->name);
+
+	if ((bp->flags & MSI_CAP_FLAG) && !dis_msi) {
+		if (pci_enable_msi(bp->pdev) == 0) {
+			bp->flags |= USING_MSI_FLAG;
+			if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+				bp->flags |= ONE_SHOT_MSI_FLAG;
+				bp->irq_tbl[0].handler = bnx2_msi_1shot;
+			} else
+				bp->irq_tbl[0].handler = bnx2_msi;
+		}
+	}
+
+	bp->irq_tbl[0].vector = bp->pdev->irq;
 }
 
 /* Called with rtnl_lock */
@@ -5278,15 +5294,8 @@ bnx2_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
+	bnx2_setup_int_mode(bp, disable_msi);
 	napi_enable(&bp->napi);
-
-	if ((bp->flags & MSI_CAP_FLAG) && !disable_msi) {
-		if (pci_enable_msi(bp->pdev) == 0) {
-			bp->flags |= USING_MSI_FLAG;
-			if (CHIP_NUM(bp) == CHIP_NUM_5709)
-				bp->flags |= ONE_SHOT_MSI_FLAG;
-		}
-	}
 	rc = bnx2_request_irq(bp);
 
 	if (rc) {
@@ -5325,6 +5334,8 @@ bnx2_open(struct net_device *dev)
 			bnx2_disable_int(bp);
 			bnx2_free_irq(bp);
 
+			bnx2_setup_int_mode(bp, 1);
+
 			rc = bnx2_init_nic(bp);
 
 			if (!rc)
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1f244fa..1accf00 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6494,6 +6494,15 @@ struct flash_spec {
 	u8  *name;
 };
 
+#define BNX2_MAX_MSIX_HW_VEC	9
+#define BNX2_MAX_MSIX_VEC	1
+
+struct bnx2_irq {
+	irq_handler_t	handler;
+	u16		vector;
+	char		name[16];
+};
+
 struct bnx2 {
 	/* Fields used in the tx and intr/napi performance paths are grouped */
 	/* together in the beginning of the structure. */
@@ -6721,6 +6730,9 @@ struct bnx2 {
 	u32			flash_size;
 
 	int			status_stats_size;
+
+	struct bnx2_irq		irq_tbl[BNX2_MAX_MSIX_VEC];
+	int			irq_nvecs;
 };
 
 static u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset);


