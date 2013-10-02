From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 15/77] bnx2: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:31 +0200
Message-ID: <69c0bf5f6ee4b2a913891cfc94442a3c9a3f9434.1380703262.git.agordeev@redhat.com>
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
 drivers/net/ethernet/broadcom/bnx2.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e838a3f..c902627 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6202,25 +6202,26 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 	 *  is setup properly */
 	BNX2_RD(bp, BNX2_PCI_MSIX_CONTROL);
 
-	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
-		msix_ent[i].entry = i;
-		msix_ent[i].vector = 0;
-	}
-
 	total_vecs = msix_vecs;
 #ifdef BCM_CNIC
 	total_vecs++;
 #endif
-	rc = -ENOSPC;
-	while (total_vecs >= BNX2_MIN_MSIX_VEC) {
-		rc = pci_enable_msix(bp->pdev, msix_ent, total_vecs);
-		if (rc <= 0)
-			break;
-		if (rc > 0)
-			total_vecs = rc;
+	rc = pci_msix_table_size(bp->pdev);
+	if (rc < 0)
+		return;
+
+	total_vecs = min(total_vecs, rc);
+	if (total_vecs < BNX2_MIN_MSIX_VEC)
+		return;
+
+	BUG_ON(total_vecs > ARRAY_SIZE(msix_ent));
+	for (i = 0; i < total_vecs; i++) {
+		msix_ent[i].entry = i;
+		msix_ent[i].vector = 0;
 	}
 
-	if (rc != 0)
+	rc = pci_enable_msix(bp->pdev, msix_ent, total_vecs);
+	if (rc)
 		return;
 
 	msix_vecs = total_vecs;
-- 
1.7.7.6
