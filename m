From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 33/34] vmxnet3: Fix MSI-X/MSI enablement code
Date: Fri, 31 Jan 2014 16:08:52 +0100
Message-ID: <30f15232ede6abf6de8421554a17ca1a093ac951.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This update cleans up the MSI-X/MSI enablement code, fixes
vmxnet3_acquire_msix_vectors() invalid return values and
enables a dead code in case VMXNET3_LINUX_MIN_MSIX_VECT
MSI-X vectors were allocated.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |  101 +++++++++++++++++--------------------
 1 files changed, 46 insertions(+), 55 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3be786f..3a17797 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2729,47 +2729,44 @@ vmxnet3_read_mac_addr(struct vmxnet3_adapter *adapter, u8 *mac)
 /*
  * Enable MSIx vectors.
  * Returns :
- *	0 on successful enabling of required vectors,
  *	VMXNET3_LINUX_MIN_MSIX_VECT when only minimum number of vectors required
- *	 could be enabled.
- *	number of vectors which can be enabled otherwise (this number is smaller
+ *	 were enabled.
+ *	number of vectors which were enabled otherwise (this number is greater
  *	 than VMXNET3_LINUX_MIN_MSIX_VECT)
  */
 
 static int
-vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
-			     int vectors)
+vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter, int nvec)
 {
-	int err = 0, vector_threshold;
-	vector_threshold = VMXNET3_LINUX_MIN_MSIX_VECT;
-
-	while (vectors >= vector_threshold) {
-		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
-				      vectors);
+	do {
+		int err = pci_enable_msix(adapter->pdev,
+					  adapter->intr.msix_entries, nvec);
 		if (!err) {
-			adapter->intr.num_intrs = vectors;
-			return 0;
+			return nvec;
 		} else if (err < 0) {
 			dev_err(&adapter->netdev->dev,
-				   "Failed to enable MSI-X, error: %d\n", err);
-			vectors = 0;
-		} else if (err < vector_threshold) {
-			break;
+				"Failed to enable MSI-X, error: %d\n", err);
+			return err;
+		} else if (err < VMXNET3_LINUX_MIN_MSIX_VECT) {
+			dev_info(&adapter->pdev->dev,
+				 "Number of MSI-X which can be allocated "
+				 "is lower than min threshold required.\n");
+			return -ENOSPC;
 		} else {
 			/* If fails to enable required number of MSI-x vectors
 			 * try enabling minimum number of vectors required.
 			 */
 			dev_err(&adapter->netdev->dev,
-				"Failed to enable %d MSI-X, trying %d instead\n",
-				    vectors, vector_threshold);
-			vectors = vector_threshold;
+				"Failed to enable %d MSI-X, trying %d\n",
+				nvec, VMXNET3_LINUX_MIN_MSIX_VECT);
+			nvec = VMXNET3_LINUX_MIN_MSIX_VECT;
 		}
-	}
+	} while (nvec >= VMXNET3_LINUX_MIN_MSIX_VECT);
 
-	dev_info(&adapter->pdev->dev,
-		 "Number of MSI-X interrupts which can be allocated "
-		 "is lower than min threshold required.\n");
-	return err;
+	/*
+	 * Should never get here
+	 */
+	return -ENOSPC;
 }
 
 
@@ -2796,56 +2793,50 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 
 #ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_MSIX) {
-		int vector, err = 0;
-
-		adapter->intr.num_intrs = (adapter->share_intr ==
-					   VMXNET3_INTR_TXSHARE) ? 1 :
-					   adapter->num_tx_queues;
-		adapter->intr.num_intrs += (adapter->share_intr ==
-					   VMXNET3_INTR_BUDDYSHARE) ? 0 :
-					   adapter->num_rx_queues;
-		adapter->intr.num_intrs += 1;		/* for link event */
-
-		adapter->intr.num_intrs = (adapter->intr.num_intrs >
-					   VMXNET3_LINUX_MIN_MSIX_VECT
-					   ? adapter->intr.num_intrs :
-					   VMXNET3_LINUX_MIN_MSIX_VECT);
-
-		for (vector = 0; vector < adapter->intr.num_intrs; vector++)
-			adapter->intr.msix_entries[vector].entry = vector;
-
-		err = vmxnet3_acquire_msix_vectors(adapter,
-						   adapter->intr.num_intrs);
+		int i, nvec;
+
+		nvec  = adapter->share_intr == VMXNET3_INTR_TXSHARE ?
+			1 : adapter->num_tx_queues;
+		nvec += adapter->share_intr == VMXNET3_INTR_BUDDYSHARE ?
+			0 : adapter->num_rx_queues;
+		nvec += 1;	/* for link event */
+		nvec = nvec > VMXNET3_LINUX_MIN_MSIX_VECT ?
+		       nvec : VMXNET3_LINUX_MIN_MSIX_VECT;
+
+		for (i = 0; i < nvec; i++)
+			adapter->intr.msix_entries[i].entry = i;
+
+		nvec = vmxnet3_acquire_msix_vectors(adapter, nvec);
+		if (nvec < 0)
+			goto msix_err;
+
 		/* If we cannot allocate one MSIx vector per queue
 		 * then limit the number of rx queues to 1
 		 */
-		if (err == VMXNET3_LINUX_MIN_MSIX_VECT) {
+		if (nvec == VMXNET3_LINUX_MIN_MSIX_VECT) {
 			if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE
 			    || adapter->num_rx_queues != 1) {
 				adapter->share_intr = VMXNET3_INTR_TXSHARE;
 				netdev_err(adapter->netdev,
 					   "Number of rx queues : 1\n");
 				adapter->num_rx_queues = 1;
-				adapter->intr.num_intrs =
-						VMXNET3_LINUX_MIN_MSIX_VECT;
 			}
-			return;
 		}
-		if (!err)
-			return;
 
+		adapter->intr.num_intrs = nvec;
+		return;
+
+msix_err:
 		/* If we cannot allocate MSIx vectors use only one rx queue */
 		dev_info(&adapter->pdev->dev,
 			 "Failed to enable MSI-X, error %d. "
-			 "Limiting #rx queues to 1, try MSI.\n", err);
+			 "Limiting #rx queues to 1, try MSI.\n", nvec);
 
 		adapter->intr.type = VMXNET3_IT_MSI;
 	}
 
 	if (adapter->intr.type == VMXNET3_IT_MSI) {
-		int err;
-		err = pci_enable_msi(adapter->pdev);
-		if (!err) {
+		if (!pci_enable_msi(adapter->pdev)) {
 			adapter->num_rx_queues = 1;
 			adapter->intr.num_intrs = 1;
 			return;
-- 
1.7.7.6
