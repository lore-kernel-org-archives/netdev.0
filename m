From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 28/34] qlcnic: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:47 +0100
Message-ID: <7015fc7b0c4dda38cf2ecdc474d510984fcfbcab.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
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
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3d2eb14..ea7a17c 100644
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
