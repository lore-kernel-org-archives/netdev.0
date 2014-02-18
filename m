From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 22/35] vxge: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:51 +0100
Message-ID: <799aa59d70b2e96f094917a8581a331afa068702.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
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
Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index e46e869..c83cedd 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2349,12 +2349,18 @@ start:
 	vdev->vxge_entries[j].entry = VXGE_ALARM_MSIX_ID;
 	vdev->vxge_entries[j].in_use = 0;
 
-	ret = pci_enable_msix(vdev->pdev, vdev->entries, vdev->intr_cnt);
-	if (ret > 0) {
+	ret = pci_enable_msix_range(vdev->pdev,
+				    vdev->entries, 3, vdev->intr_cnt);
+	if (ret < 0) {
+		ret = -ENODEV;
+		goto enable_msix_failed;
+	} else if (ret < vdev->intr_cnt) {
+		pci_disable_msix(vdev->pdev);
+
 		vxge_debug_init(VXGE_ERR,
 			"%s: MSI-X enable failed for %d vectors, ret: %d",
 			VXGE_DRIVER_NAME, vdev->intr_cnt, ret);
-		if ((max_config_vpath != VXGE_USE_DEFAULT) || (ret < 3)) {
+		if (max_config_vpath != VXGE_USE_DEFAULT) {
 			ret = -ENODEV;
 			goto enable_msix_failed;
 		}
@@ -2368,9 +2374,6 @@ start:
 		vxge_close_vpaths(vdev, temp);
 		vdev->no_of_vpath = temp;
 		goto start;
-	} else if (ret < 0) {
-		ret = -ENODEV;
-		goto enable_msix_failed;
 	}
 	return 0;
 
-- 
1.7.7.6
