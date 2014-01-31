From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 02/34] bnx2x: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:21 +0100
Message-ID: <911884c4e906af8acfa4c06ee3206387449f1d84.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Ariel Elior <ariele@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   48 ++++++++++-------------
 1 files changed, 21 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9d7419e..b396d74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1638,24 +1638,36 @@ int bnx2x_enable_msix(struct bnx2x *bp)
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
+	if (rc < 0) {
+		BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
+		goto no_msix;
+	} else if (rc == -ENOSPC) {
+		/* Get by with single vector */
+		rc = pci_enable_msix_range(bp->pdev, &bp->msix_table[0], 1, 1);
+		if (rc < 0) {
+			BNX2X_DEV_INFO("Single MSI-X is not attainable rc %d\n",
+				       rc);
+			goto no_msix;
+		}
+
+		BNX2X_DEV_INFO("Using single MSI-X vector\n");
+		bp->flags |= USING_SINGLE_MSIX_FLAG;
+
+		BNX2X_DEV_INFO("set number of queues to 1\n");
+		bp->num_ethernet_queues = 1;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+	} else if (rc < msix_vec) {
 		/* how less vectors we will have? */
 		int diff = msix_vec - rc;
 
 		BNX2X_DEV_INFO("Trying to use less MSI-X vectors: %d\n", rc);
 
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
-
-		if (rc) {
-			BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
-			goto no_msix;
-		}
 		/*
 		 * decrease number of queues by number of unallocated entries
 		 */
@@ -1664,24 +1676,6 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 
 		BNX2X_DEV_INFO("New queue configuration set: %d\n",
 			       bp->num_queues);
-	} else if (rc > 0) {
-		/* Get by with single vector */
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], 1);
-		if (rc) {
-			BNX2X_DEV_INFO("Single MSI-X is not attainable rc %d\n",
-				       rc);
-			goto no_msix;
-		}
-
-		BNX2X_DEV_INFO("Using single MSI-X vector\n");
-		bp->flags |= USING_SINGLE_MSIX_FLAG;
-
-		BNX2X_DEV_INFO("set number of queues to 1\n");
-		bp->num_ethernet_queues = 1;
-		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
-	} else if (rc < 0) {
-		BNX2X_DEV_INFO("MSI-X is not attainable  rc %d\n", rc);
-		goto no_msix;
 	}
 
 	bp->flags |= USING_MSIX_FLAG;
-- 
1.7.7.6
