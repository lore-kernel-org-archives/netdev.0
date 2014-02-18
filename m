From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 28/35] qlcnic: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:57 +0100
Message-ID: <cb8eb41f672c62d1149c375bdaf97ca3328703f9.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
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
Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0c077cf..e07fd94 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -701,13 +701,17 @@ enable_msix:
 		for (vector = 0; vector < num_msix; vector++)
 			adapter->msix_entries[vector].entry = vector;
 
-		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
-		if (err == 0) {
+		err = pci_enable_msix_range(pdev,
+					    adapter->msix_entries, 1, num_msix);
+
+		if (err == num_msix) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
 			adapter->ahw->num_msix = num_msix;
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return 0;
 		} else if (err > 0) {
+			pci_disable_msix(pdev);
+
 			dev_info(&pdev->dev,
 				 "Unable to allocate %d MSI-X vectors, Available vectors %d\n",
 				 num_msix, err);
-- 
1.7.7.6
