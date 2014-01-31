From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 20/34] myri10ge: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:39 +0100
Message-ID: <1253b3c920637ab6bb987defb88d1698ac1e4851.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
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
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   32 ++++++++++-----------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 68026f7..9f717d6 100644
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
@@ -3901,23 +3899,23 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 	}
 
 	while (mgp->num_slices > 1) {
-		/* make sure it is a power of two */
-		while (!is_power_of_2(mgp->num_slices))
-			mgp->num_slices--;
+		mgp->num_slices = rounddown_pow_of_two(mgp->num_slices);
 		if (mgp->num_slices == 1)
 			goto disable_msix;
-		status = pci_enable_msix(pdev, mgp->msix_vectors,
-					 mgp->num_slices);
-		if (status == 0) {
-			pci_disable_msix(pdev);
+		status = pci_enable_msix_range(pdev, mgp->msix_vectors,
+					mgp->num_slices, mgp->num_slices);
+		if (status < 0)
+			goto disable_msix;
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
 
 disable_msix:
-- 
1.7.7.6
