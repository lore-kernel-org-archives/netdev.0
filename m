From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40evf: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Wed, 21 May 2014 05:01:12 -0700
Message-ID: <1400673673-31626-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Gordeev <agordeev@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-pci@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Gordeev <agordeev@redhat.com>

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range()  or pci_enable_msi_exact()
and pci_enable_msix_range() or pci_enable_msix_exact()
interfaces.

Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: linux-pci@vger.kernel.org
Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 31 +++++++++----------------
 1 file changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 13989ef..6f6bd3f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1032,30 +1032,21 @@ i40evf_acquire_msix_vectors(struct i40evf_adapter *adapter, int vectors)
 	 * Right now, we simply care about how many we'll get; we'll
 	 * set them up later while requesting irq's.
 	 */
-	while (vectors >= vector_threshold) {
-		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				      vectors);
-		if (!err) /* Success in acquiring all requested vectors. */
-			break;
-		else if (err < 0)
-			vectors = 0; /* Nasty failure, quit now */
-		else /* err == number of vectors we should try again with */
-			vectors = err;
-	}
-
-	if (vectors < vector_threshold) {
+	err = pci_enable_msix_range(adapter->pdev, adapter->msix_entries,
+				    vector_threshold, vectors);
+	if (err < 0) {
 		dev_err(&adapter->pdev->dev, "Unable to allocate MSI-X interrupts.\n");
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-		err = -EIO;
-	} else {
-		/* Adjust for only the vectors we'll use, which is minimum
-		 * of max_msix_q_vectors + NONQ_VECS, or the number of
-		 * vectors we were allocated.
-		 */
-		adapter->num_msix_vectors = vectors;
+		return err;
 	}
-	return err;
+
+	/* Adjust for only the vectors we'll use, which is minimum
+	 * of max_msix_q_vectors + NONQ_VECS, or the number of
+	 * vectors we were allocated.
+	 */
+	adapter->num_msix_vectors = err;
+	return 0;
 }
 
 /**
-- 
1.9.0
