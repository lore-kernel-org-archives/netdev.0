From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/10] bnx2x: added support for working with one
 msix irq.
Date: Wed, 4 Apr 2012 07:41:26 +0300
Message-ID: <1333514492-20425-5-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4903 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab2DDErZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:25 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Until now, the bnx2x driver needed at least 2 available msix interrupt
vectors in order to use msix. This patch add the possibility of configuring
msix when only one interrupt vector is available.
Notice this patch contains lines with over 80 characters, as it keeps print
strings in a single line.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   66 +++++++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   20 ++++--
 4 files changed, 61 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e37161f..ae0dcd4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1293,6 +1293,7 @@ struct bnx2x {
 #define NO_ISCSI_FLAG			(1 << 14)
 #define NO_FCOE_FLAG			(1 << 15)
 #define BC_SUPPORTS_PFC_STATS		(1 << 17)
+#define USING_SINGLE_MSIX_FLAG		(1 << 20)
 
 #define NO_ISCSI(bp)		((bp)->flags & NO_ISCSI_FLAG)
 #define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a95242..98b82eb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1211,16 +1211,15 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp, int nvecs)
 
 void bnx2x_free_irq(struct bnx2x *bp)
 {
-	if (bp->flags & USING_MSIX_FLAG)
+	if (bp->flags & USING_MSIX_FLAG &&
+	    !(bp->flags & USING_SINGLE_MSIX_FLAG))
 		bnx2x_free_msix_irqs(bp, BNX2X_NUM_ETH_QUEUES(bp) +
 				     CNIC_PRESENT + 1);
-	else if (bp->flags & USING_MSI_FLAG)
-		free_irq(bp->pdev->irq, bp->dev);
 	else
-		free_irq(bp->pdev->irq, bp->dev);
+		free_irq(bp->dev->irq, bp->dev);
 }
 
-int bnx2x_enable_msix(struct bnx2x *bp)
+int __devinit bnx2x_enable_msix(struct bnx2x *bp)
 {
 	int msix_vec = 0, i, rc, req_cnt;
 
@@ -1260,8 +1259,8 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
 
 		if (rc) {
-			BNX2X_DEV_INFO("MSI-X is not attainable  rc %d\n", rc);
-			return rc;
+			BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
+			goto no_msix;
 		}
 		/*
 		 * decrease number of queues by number of unallocated entries
@@ -1269,18 +1268,34 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		bp->num_queues -= diff;
 
 		BNX2X_DEV_INFO("New queue configuration set: %d\n",
-				  bp->num_queues);
-	} else if (rc) {
-		/* fall to INTx if not enough memory */
-		if (rc == -ENOMEM)
-			bp->flags |= DISABLE_MSI_FLAG;
+			       bp->num_queues);
+	} else if (rc > 0) {
+		/* Get by with single vector */
+		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], 1);
+		if (rc) {
+			BNX2X_DEV_INFO("Single MSI-X is not attainable rc %d\n",
+				       rc);
+			goto no_msix;
+		}
+
+		BNX2X_DEV_INFO("Using single MSI-X vector\n");
+		bp->flags |= USING_SINGLE_MSIX_FLAG;
+
+	} else if (rc < 0) {
 		BNX2X_DEV_INFO("MSI-X is not attainable  rc %d\n", rc);
-		return rc;
+		goto no_msix;
 	}
 
 	bp->flags |= USING_MSIX_FLAG;
 
 	return 0;
+
+no_msix:
+	/* fall to INTx if not enough memory */
+	if (rc == -ENOMEM)
+		bp->flags |= DISABLE_MSI_FLAG;
+
+	return rc;
 }
 
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
@@ -1342,22 +1357,26 @@ int bnx2x_enable_msi(struct bnx2x *bp)
 static int bnx2x_req_irq(struct bnx2x *bp)
 {
 	unsigned long flags;
-	int rc;
+	unsigned int irq;
 
-	if (bp->flags & USING_MSI_FLAG)
+	if (bp->flags & (USING_MSI_FLAG | USING_MSIX_FLAG))
 		flags = 0;
 	else
 		flags = IRQF_SHARED;
 
-	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, flags,
-			 bp->dev->name, bp->dev);
-	return rc;
+	if (bp->flags & USING_MSIX_FLAG)
+		irq = bp->msix_table[0].vector;
+	else
+		irq = bp->pdev->irq;
+
+	return request_irq(irq, bnx2x_interrupt, flags, bp->dev->name, bp->dev);
 }
 
 static inline int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc = 0;
-	if (bp->flags & USING_MSIX_FLAG) {
+	if (bp->flags & USING_MSIX_FLAG &&
+	    !(bp->flags & USING_SINGLE_MSIX_FLAG)) {
 		rc = bnx2x_req_msix_irqs(bp);
 		if (rc)
 			return rc;
@@ -1370,8 +1389,13 @@ static inline int bnx2x_setup_irqs(struct bnx2x *bp)
 		}
 		if (bp->flags & USING_MSI_FLAG) {
 			bp->dev->irq = bp->pdev->irq;
-			netdev_info(bp->dev, "using MSI  IRQ %d\n",
-			       bp->pdev->irq);
+			netdev_info(bp->dev, "using MSI IRQ %d\n",
+				    bp->dev->irq);
+		}
+		if (bp->flags & USING_MSIX_FLAG) {
+			bp->dev->irq = bp->msix_table[0].vector;
+			netdev_info(bp->dev, "using MSIX IRQ %d\n",
+				    bp->dev->irq);
 		}
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 8b16338..b0d0c69 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -482,7 +482,7 @@ void bnx2x_netif_start(struct bnx2x *bp);
  * fills msix_table, requests vectors, updates num_queues
  * according to number of available vectors.
  */
-int bnx2x_enable_msix(struct bnx2x *bp);
+int __devinit bnx2x_enable_msix(struct bnx2x *bp);
 
 /**
  * bnx2x_enable_msi - request msi mode from OS, updated internals accordingly
@@ -840,7 +840,7 @@ static inline void bnx2x_disable_msi(struct bnx2x *bp)
 {
 	if (bp->flags & USING_MSIX_FLAG) {
 		pci_disable_msix(bp->pdev);
-		bp->flags &= ~USING_MSIX_FLAG;
+		bp->flags &= ~(USING_MSIX_FLAG | USING_SINGLE_MSIX_FLAG);
 	} else if (bp->flags & USING_MSI_FLAG) {
 		pci_disable_msi(bp->pdev);
 		bp->flags &= ~USING_MSI_FLAG;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 16de19f..c5f85ad 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1333,8 +1333,9 @@ static void bnx2x_hc_int_enable(struct bnx2x *bp)
 static void bnx2x_igu_int_enable(struct bnx2x *bp)
 {
 	u32 val;
-	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
-	int msi = (bp->flags & USING_MSI_FLAG) ? 1 : 0;
+	bool msix = (bp->flags & USING_MSIX_FLAG) ? true : false;
+	bool single_msix = (bp->flags & USING_SINGLE_MSIX_FLAG) ? true : false;
+	bool msi = (bp->flags & USING_MSI_FLAG) ? true : false;
 
 	val = REG_RD(bp, IGU_REG_PF_CONFIGURATION);
 
@@ -1344,6 +1345,9 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
 		val |= (IGU_PF_CONF_FUNC_EN |
 			IGU_PF_CONF_MSI_MSIX_EN |
 			IGU_PF_CONF_ATTN_BIT_EN);
+
+		if (single_msix)
+			val |= IGU_PF_CONF_SINGLE_ISR_EN;
 	} else if (msi) {
 		val &= ~IGU_PF_CONF_INT_LINE_EN;
 		val |= (IGU_PF_CONF_FUNC_EN |
@@ -7144,7 +7148,7 @@ static void __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 		BNX2X_DEV_INFO("set number of queues to 1\n");
 		break;
 	default:
-		/* Set number of queues according to bp->multi_mode value */
+		/* Set number of queues for MSI-X mode */
 		bnx2x_set_num_queues(bp);
 
 		BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
@@ -7153,15 +7157,17 @@ static void __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
-		if (bnx2x_enable_msix(bp)) {
-			/* failed to enable MSI-X */
-			BNX2X_DEV_INFO("Failed to enable MSI-X (%d), set number of queues to %d\n",
+		if (bnx2x_enable_msix(bp) ||
+		    bp->flags & USING_SINGLE_MSIX_FLAG) {
+			/* failed to enable multiple MSI-X */
+			BNX2X_DEV_INFO("Failed to enable multiple MSI-X (%d), set number of queues to %d\n",
 				       bp->num_queues, 1 + NON_ETH_CONTEXT_USE);
 
 			bp->num_queues = 1 + NON_ETH_CONTEXT_USE;
 
 			/* Try to enable MSI */
-			if (!(bp->flags & DISABLE_MSI_FLAG))
+			if (!(bp->flags & USING_SINGLE_MSIX_FLAG) &&
+			    !(bp->flags & DISABLE_MSI_FLAG))
 				bnx2x_enable_msi(bp);
 		}
 		break;
-- 
1.7.9.rc2
