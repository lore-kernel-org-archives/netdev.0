From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbe: Avoid Tx hang by not allowing more than the number of VFs supported.
Date: Tue, 18 Apr 2017 16:01:51 -0700
Message-ID: <20170418230205.37223-2-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Usha Ketineni <usha.k.ketineni@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752879AbdDRXCK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:10 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Usha Ketineni <usha.k.ketineni@intel.com>

When DCB is enabled, add checks to ensure creation of number of VF's is
valid based on the traffic classes configured by the device.

Signed-off-by: Usha Ketineni <usha.k.ketineni@intel.com>
Tested-by: Ronald Bynoe <ronald.j.bynoe@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 26 +++++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  3 +++
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 044cb44747cf..39e109da9bd9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -298,6 +298,7 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
 #ifdef CONFIG_PCI_IOV
 	struct ixgbe_adapter *adapter = pci_get_drvdata(dev);
 	int err = 0;
+	u8 num_tc;
 	int i;
 	int pre_existing_vfs = pci_num_vf(dev);
 
@@ -310,16 +311,35 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
 		return err;
 
 	/* While the SR-IOV capability structure reports total VFs to be 64,
-	 * we have to limit the actual number allocated based on two factors.
+	 * we limit the actual number allocated as below based on two factors.
+	 *    Num_TCs	MAX_VFs
+	 *	1	  63
+	 *	<=4	  31
+	 *	>4	  15
 	 * First, we reserve some transmit/receive resources for the PF.
 	 * Second, VMDQ also uses the same pools that SR-IOV does. We need to
 	 * account for this, so that we don't accidentally allocate more VFs
 	 * than we have available pools. The PCI bus driver already checks for
 	 * other values out of range.
 	 */
-	if ((num_vfs + adapter->num_rx_pools) > IXGBE_MAX_VF_FUNCTIONS)
-		return -EPERM;
+	num_tc = netdev_get_num_tc(adapter->netdev);
 
+	if (num_tc > 4) {
+		if ((num_vfs + adapter->num_rx_pools) > IXGBE_MAX_VFS_8TC) {
+			e_dev_err("Currently the device is configured with %d TCs, Creating more than %d VFs is not allowed\n", num_tc, IXGBE_MAX_VFS_8TC);
+			return -EPERM;
+		}
+	} else if ((num_tc > 1) && (num_tc <= 4)) {
+		if ((num_vfs + adapter->num_rx_pools) > IXGBE_MAX_VFS_4TC) {
+			e_dev_err("Currently the device is configured with %d TCs, Creating more than %d VFs is not allowed\n", num_tc, IXGBE_MAX_VFS_4TC);
+			return -EPERM;
+		}
+	} else {
+		if ((num_vfs + adapter->num_rx_pools) > IXGBE_MAX_VFS_1TC) {
+			e_dev_err("Currently the device is configured with %d TCs, Creating more than %d VFs is not allowed\n", num_tc, IXGBE_MAX_VFS_1TC);
+			return -EPERM;
+		}
+	}
 	adapter->num_vfs = num_vfs;
 
 	err = __ixgbe_enable_sriov(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 0c7977d27b71..3166fd164e51 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -33,6 +33,9 @@
  *  63 (IXGBE_MAX_VF_FUNCTIONS - 1)
  */
 #define IXGBE_MAX_VFS_DRV_LIMIT  (IXGBE_MAX_VF_FUNCTIONS - 1)
+#define IXGBE_MAX_VFS_1TC		IXGBE_MAX_VF_FUNCTIONS
+#define IXGBE_MAX_VFS_4TC		32
+#define IXGBE_MAX_VFS_8TC		16
 
 #ifdef CONFIG_PCI_IOV
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
-- 
2.12.2
