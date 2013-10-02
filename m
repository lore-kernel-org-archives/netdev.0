From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 14/77] bnx2x: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:30 +0200
Message-ID: <1a91f00e27e06e93806bd8af34fccd580ec68585.1380703262.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.ne
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

As result of recent re-design of the MSI/MSI-X interrupts enabling
pattern this driver has to be updated to use the new technique to
obtain a optimal number of MSI/MSI-X interrupts required.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   54 ++++++++++-------------
 1 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 61726af..edf31d2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1564,7 +1564,7 @@ void bnx2x_free_irq(struct bnx2x *bp)
 
 int bnx2x_enable_msix(struct bnx2x *bp)
 {
-	int msix_vec = 0, i, rc;
+	int msix_vec = 0, nvec, i, rc;
 
 	/* VFs don't have a default status block */
 	if (IS_PF(bp)) {
@@ -1590,60 +1590,52 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		msix_vec++;
 	}
 
+	rc = pci_msix_table_size(bp->pdev);
+	if (rc < 0)
+		goto no_msix;
+
+	nvec = min(msix_vec, rc);
+	if (nvec < BNX2X_MIN_MSIX_VEC_CNT(bp))
+		nvec = 1;
+
 	DP(BNX2X_MSG_SP, "about to request enable msix with %d vectors\n",
 	   msix_vec);
 
-	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], msix_vec);
+	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], nvec);
+	if (rc)
+		goto no_msix;
 
 	/*
 	 * reconfigure number of tx/rx queues according to available
 	 * MSI-X vectors
 	 */
-	if (rc >= BNX2X_MIN_MSIX_VEC_CNT(bp)) {
-		/* how less vectors we will have? */
-		int diff = msix_vec - rc;
-
-		BNX2X_DEV_INFO("Trying to use less MSI-X vectors: %d\n", rc);
+	if (nvec == 1) {
+		bp->flags |= USING_SINGLE_MSIX_FLAG;
 
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
+		bp->num_ethernet_queues = 1;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+	} else if (nvec < msix_vec) {
+		/* how less vectors we will have? */
+		int diff = msix_vec - nvec;
 
-		if (rc) {
-			BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
-			goto no_msix;
-		}
 		/*
 		 * decrease number of queues by number of unallocated entries
 		 */
 		bp->num_ethernet_queues -= diff;
 		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+	}
 
+	if (nvec != msix_vec)
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
-	}
 
 	bp->flags |= USING_MSIX_FLAG;
 
 	return 0;
 
 no_msix:
+	BNX2X_DEV_INFO("MSI-X is not attainable rc %d\n", rc);
+
 	/* fall to INTx if not enough memory */
 	if (rc == -ENOMEM)
 		bp->flags |= DISABLE_MSI_FLAG;
-- 
1.7.7.6
