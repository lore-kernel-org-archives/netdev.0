From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 02/35] bnx2x: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:07:54 +0100
Message-ID: <f8822086d21320729a274f5920d5ed613016501b.1392717502.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Ariel Elior <ariele@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Ariel Elior <ariele@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   46 ++++++++++-------------
 1 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9ded3db..8363b9d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1638,36 +1638,16 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	DP(BNX2X_MSG_SP, "about to request enable msix with %d vectors\n",
 	   msix_vec);
 
-	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], msix_vec);
-
+	rc = pci_enable_msix_range(bp->pdev, &bp->msix_table[0],
+				   BNX2X_MIN_MSIX_VEC_CNT(bp), msix_vec);
 	/*
 	 * reconfigure number of tx/rx queues according to available
 	 * MSI-X vectors
 	 */
-	if (rc >= BNX2X_MIN_MSIX_VEC_CNT(bp)) {
-		/* how less vectors we will have? */
-		int diff = msix_vec - rc;
-
-		BNX2X_DEV_INFO("Trying to use less MSI-X vectors: %d\n", rc);
-
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
-
-		if (rc) {
-			BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
-			goto no_msix;
-		}
-		/*
-		 * decrease number of queues by number of unallocated entries
-		 */
-		bp->num_ethernet_queues -= diff;
-		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
-
-		BNX2X_DEV_INFO("New queue configuration set: %d\n",
-			       bp->num_queues);
-	} else if (rc > 0) {
+	if (rc == -ENOSPC) {
 		/* Get by with single vector */
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], 1);
-		if (rc) {
+		rc = pci_enable_msix_range(bp->pdev, &bp->msix_table[0], 1, 1);
+		if (rc < 0) {
 			BNX2X_DEV_INFO("Single MSI-X is not attainable rc %d\n",
 				       rc);
 			goto no_msix;
@@ -1680,8 +1660,22 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		bp->num_ethernet_queues = 1;
 		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
 	} else if (rc < 0) {
-		BNX2X_DEV_INFO("MSI-X is not attainable  rc %d\n", rc);
+		BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
 		goto no_msix;
+	} else if (rc < msix_vec) {
+		/* how less vectors we will have? */
+		int diff = msix_vec - rc;
+
+		BNX2X_DEV_INFO("Trying to use less MSI-X vectors: %d\n", rc);
+
+		/*
+		 * decrease number of queues by number of unallocated entries
+		 */
+		bp->num_ethernet_queues -= diff;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+
+		BNX2X_DEV_INFO("New queue configuration set: %d\n",
+			       bp->num_queues);
 	}
 
 	bp->flags |= USING_MSIX_FLAG;
-- 
1.7.7.6
