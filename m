From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH] qlcnic: Fix MSI-X initialization code
Date: Tue, 15 Apr 2014 11:37:14 +0200
Message-ID: <1397554634-26795-1-git-send-email-agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function qlcnic_setup_tss_rss_intr() might enter endless
loop in case pci_enable_msix() contiguously returns a
positive number of MSI-Xs that could have been allocated.
Besides, the function contains 'err = -EIO;' assignment
that never could be reached. This update fixes the
aforementioned issues.

Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
Cc: Dept-HSGLinuxNICDev@qlogic.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   28 ++++++++++++---------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 309d056..2e615d5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -670,7 +670,7 @@ int qlcnic_setup_tss_rss_intr(struct qlcnic_adapter *adapter)
 	else
 		num_msix += adapter->drv_tx_rings;
 
-	if (adapter->drv_rss_rings  > 0)
+	if (adapter->drv_rss_rings > 0)
 		num_msix += adapter->drv_rss_rings;
 	else
 		num_msix += adapter->drv_sds_rings;
@@ -686,19 +686,15 @@ int qlcnic_setup_tss_rss_intr(struct qlcnic_adapter *adapter)
 			return -ENOMEM;
 	}
 
-restore:
 	for (vector = 0; vector < num_msix; vector++)
 		adapter->msix_entries[vector].entry = vector;
 
+restore:
 	err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
-	if (err == 0) {
-		adapter->ahw->num_msix = num_msix;
-		if (adapter->drv_tss_rings > 0)
-			adapter->drv_tx_rings = adapter->drv_tss_rings;
+	if (err > 0) {
+		if (!adapter->drv_tss_rings && !adapter->drv_rss_rings)
+			return -ENOSPC;
 
-		if (adapter->drv_rss_rings > 0)
-			adapter->drv_sds_rings = adapter->drv_rss_rings;
-	} else {
 		netdev_info(adapter->netdev,
 			    "Unable to allocate %d MSI-X vectors, Available vectors %d\n",
 			    num_msix, err);
@@ -716,12 +712,20 @@ restore:
 			    "Restoring %d Tx, %d SDS rings for total %d vectors.\n",
 			    adapter->drv_tx_rings, adapter->drv_sds_rings,
 			    num_msix);
-		goto restore;
 
-		err = -EIO;
+		goto restore;
+	} else if (err < 0) {
+		return err;
 	}
 
-	return err;
+	adapter->ahw->num_msix = num_msix;
+	if (adapter->drv_tss_rings > 0)
+		adapter->drv_tx_rings = adapter->drv_tss_rings;
+
+	if (adapter->drv_rss_rings > 0)
+		adapter->drv_sds_rings = adapter->drv_rss_rings;
+
+	return 0;
 }
 
 int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
-- 
1.7.7.6
