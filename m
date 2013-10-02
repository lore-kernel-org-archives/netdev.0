From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 38/77] ixgbe: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:54 +0200
Message-ID: <5b809a723104ca6350f4aefaae1ca2a44f7e7116.1380703263.git.agordeev@redhat.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |   62 +++++++++++++------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 90b4e10..2444a4d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -711,37 +711,39 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
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
+	err = pci_msix_table_size(adapter->pdev);
+	if (err < 0)
+		goto err_alloc_msix;
 
-	if (vectors < vector_threshold) {
-		/* Can't allocate enough MSI-X interrupts?  Oh well.
-		 * This just means we'll go with either a single MSI
-		 * vector or fall back to legacy interrupts.
-		 */
-		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
-			     "Unable to allocate MSI-X interrupts\n");
-		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
-		kfree(adapter->msix_entries);
-		adapter->msix_entries = NULL;
-	} else {
-		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
-		/*
-		 * Adjust for only the vectors we'll use, which is minimum
-		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
-		 * vectors we were allocated.
-		 */
-		vectors -= NON_Q_VECTORS;
-		adapter->num_q_vectors = min(vectors, adapter->max_q_vectors);
-	}
+	vectors = min(vectors, err);
+	if (vectors < vector_threshold)
+		goto err_alloc_msix;
+
+	err = pci_enable_msix(adapter->pdev, adapter->msix_entries, vectors);
+	if (err)
+		goto err_alloc_msix;
+
+	adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
+	/*
+	 * Adjust for only the vectors we'll use, which is minimum
+	 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
+	 * vectors we were allocated.
+	 */
+	vectors -= NON_Q_VECTORS;
+	adapter->num_q_vectors = min(vectors, adapter->max_q_vectors);
+
+	return;
+
+err_alloc_msix:
+	/* Can't allocate enough MSI-X interrupts?  Oh well.
+	 * This just means we'll go with either a single MSI
+	 * vector or fall back to legacy interrupts.
+	 */
+	netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
+		     "Unable to allocate MSI-X interrupts\n");
+	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
 }
 
 static void ixgbe_add_ring(struct ixgbe_ring *ring,
-- 
1.7.7.6
