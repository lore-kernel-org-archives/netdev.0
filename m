From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 34/34] vmxnet3: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:53 +0100
Message-ID: <3407b374f3926408fde736674b5dce4841c50fa6.1391172839.git.agordeev@redhat.com>
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

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   47 +++++++++++++++----------------------
 1 files changed, 19 insertions(+), 28 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3a17797..9275c8c 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2738,35 +2738,26 @@ vmxnet3_read_mac_addr(struct vmxnet3_adapter *adapter, u8 *mac)
 static int
 vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter, int nvec)
 {
-	do {
-		int err = pci_enable_msix(adapter->pdev,
-					  adapter->intr.msix_entries, nvec);
-		if (!err) {
-			return nvec;
-		} else if (err < 0) {
-			dev_err(&adapter->netdev->dev,
-				"Failed to enable MSI-X, error: %d\n", err);
-			return err;
-		} else if (err < VMXNET3_LINUX_MIN_MSIX_VECT) {
-			dev_info(&adapter->pdev->dev,
-				 "Number of MSI-X which can be allocated "
-				 "is lower than min threshold required.\n");
-			return -ENOSPC;
-		} else {
-			/* If fails to enable required number of MSI-x vectors
-			 * try enabling minimum number of vectors required.
-			 */
-			dev_err(&adapter->netdev->dev,
-				"Failed to enable %d MSI-X, trying %d\n",
-				nvec, VMXNET3_LINUX_MIN_MSIX_VECT);
-			nvec = VMXNET3_LINUX_MIN_MSIX_VECT;
-		}
-	} while (nvec >= VMXNET3_LINUX_MIN_MSIX_VECT);
+	int ret = pci_enable_msix_range(adapter->pdev,
+					adapter->intr.msix_entries, nvec, nvec);
 
-	/*
-	 * Should never get here
-	 */
-	return -ENOSPC;
+	if (ret == -ENOSPC && nvec > VMXNET3_LINUX_MIN_MSIX_VECT) {
+		dev_err(&adapter->netdev->dev,
+			"Failed to enable %d MSI-X, trying %d\n",
+			nvec, VMXNET3_LINUX_MIN_MSIX_VECT);
+
+		ret = pci_enable_msix_range(adapter->pdev,
+					    adapter->intr.msix_entries,
+					    VMXNET3_LINUX_MIN_MSIX_VECT,
+					    VMXNET3_LINUX_MIN_MSIX_VECT);
+	}
+
+	if (ret < 0) {
+		dev_err(&adapter->netdev->dev,
+			"Failed to enable MSI-X, error: %d\n", ret);
+	}
+
+	return ret;
 }
 
 
-- 
1.7.7.6
