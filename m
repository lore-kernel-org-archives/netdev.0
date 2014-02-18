From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 20/35] myri10ge: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:49 +0100
Message-ID: <4174e05e893a4b62b9c39692691b926cec2dc2c3.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
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
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   40 +++++++++++-----------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 68026f7..130f6b2 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -2329,16 +2329,14 @@ static int myri10ge_request_irq(struct myri10ge_priv *mgp)
 	status = 0;
 	if (myri10ge_msi) {
 		if (mgp->num_slices > 1) {
-			status =
-			    pci_enable_msix(pdev, mgp->msix_vectors,
-					    mgp->num_slices);
-			if (status == 0) {
-				mgp->msix_enabled = 1;
-			} else {
+			status = pci_enable_msix_range(pdev, mgp->msix_vectors,
+					mgp->num_slices, mgp->num_slices);
+			if (status < 0) {
 				dev_err(&pdev->dev,
 					"Error %d setting up MSI-X\n", status);
 				return status;
 			}
+			mgp->msix_enabled = 1;
 		}
 		if (mgp->msix_enabled == 0) {
 			status = pci_enable_msi(pdev);
@@ -3895,32 +3893,34 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 	mgp->msix_vectors = kcalloc(mgp->num_slices, sizeof(*mgp->msix_vectors),
 				    GFP_KERNEL);
 	if (mgp->msix_vectors == NULL)
-		goto disable_msix;
+		goto no_msix;
 	for (i = 0; i < mgp->num_slices; i++) {
 		mgp->msix_vectors[i].entry = i;
 	}
 
 	while (mgp->num_slices > 1) {
-		/* make sure it is a power of two */
-		while (!is_power_of_2(mgp->num_slices))
-			mgp->num_slices--;
+		mgp->num_slices = rounddown_pow_of_two(mgp->num_slices);
 		if (mgp->num_slices == 1)
-			goto disable_msix;
-		status = pci_enable_msix(pdev, mgp->msix_vectors,
-					 mgp->num_slices);
-		if (status == 0) {
-			pci_disable_msix(pdev);
+			goto no_msix;
+		status = pci_enable_msix_range(pdev,
+					       mgp->msix_vectors,
+					       mgp->num_slices,
+					       mgp->num_slices);
+		if (status < 0)
+			goto no_msix;
+
+		pci_disable_msix(pdev);
+
+		if (status == mgp->num_slices) {
 			if (old_allocated)
 				kfree(old_fw);
 			return;
-		}
-		if (status > 0)
+		} else {
 			mgp->num_slices = status;
-		else
-			goto disable_msix;
+		}
 	}
 
-disable_msix:
+no_msix:
 	if (mgp->msix_vectors != NULL) {
 		kfree(mgp->msix_vectors);
 		mgp->msix_vectors = NULL;
-- 
1.7.7.6
