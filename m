From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe: do not use adapter->num_vfs when setting VFs via module parameter
Date: Tue, 18 Apr 2017 16:02:00 -0700
Message-ID: <20170418230205.37223-11-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757578AbdDRXCP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:15 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Avoid setting adapter->num_vfs early in the init code path when
using the max_vfs module parameter by passing it to ixgbe_enable_sriov()
as a function parameter.

This fixes an issue where if we failed to allocate vfinfo in
__ixgbe_enable_sriov() the driver will crash with NULL pointer in
ixgbe_disable_sriov() when attempting to free the vfinfo struct based
on adapter->num_vfs. Also it cleans up the assignment of adapter->num_vfs
since now it will only be set in __ixgbe_enable_sriov() and cleared in
ixgbe_disable_sriov().

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 50 +++++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 +-
 3 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e250c1d54a11..dcc8a5c26276 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5955,10 +5955,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter,
 	/* assign number of SR-IOV VFs */
 	if (hw->mac.type != ixgbe_mac_82598EB) {
 		if (max_vfs > IXGBE_MAX_VFS_DRV_LIMIT) {
-			adapter->num_vfs = 0;
+			max_vfs = 0;
 			e_dev_warn("max_vfs parameter out of range. Not assigning any SR-IOV VFs\n");
-		} else {
-			adapter->num_vfs = max_vfs;
 		}
 	}
 #endif /* CONFIG_PCI_IOV */
@@ -9821,7 +9819,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ixgbe_init_mbx_params_pf(hw);
 	hw->mbx.ops = ii->mbx_ops;
 	pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
-	ixgbe_enable_sriov(adapter);
+	ixgbe_enable_sriov(adapter, max_vfs);
 skip_sriov:
 
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 16952d33730e..102ca937ddb4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -46,14 +46,15 @@
 #include "ixgbe_sriov.h"
 
 #ifdef CONFIG_PCI_IOV
-static inline void ixgbe_alloc_vf_macvlans(struct ixgbe_adapter *adapter)
+static inline void ixgbe_alloc_vf_macvlans(struct ixgbe_adapter *adapter,
+					   unsigned int num_vfs)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct vf_macvlans *mv_list;
 	int num_vf_macvlans, i;
 
 	num_vf_macvlans = hw->mac.num_rar_entries -
-			  (IXGBE_MAX_PF_MACVLANS + 1 + adapter->num_vfs);
+			  (IXGBE_MAX_PF_MACVLANS + 1 + num_vfs);
 	if (!num_vf_macvlans)
 		return;
 
@@ -71,7 +72,8 @@ static inline void ixgbe_alloc_vf_macvlans(struct ixgbe_adapter *adapter)
 	}
 }
 
-static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
+static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
+				unsigned int num_vfs)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
@@ -82,28 +84,27 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED;
 	if (!adapter->ring_feature[RING_F_VMDQ].limit)
 		adapter->ring_feature[RING_F_VMDQ].limit = 1;
-	adapter->ring_feature[RING_F_VMDQ].offset = adapter->num_vfs;
 
-	/* If call to enable VFs succeeded then allocate memory
-	 * for per VF control structures.
-	 */
-	adapter->vfinfo = kcalloc(adapter->num_vfs,
-				  sizeof(struct vf_data_storage), GFP_KERNEL);
+	/* Allocate memory for per VF control structures */
+	adapter->vfinfo = kcalloc(num_vfs, sizeof(struct vf_data_storage),
+				  GFP_KERNEL);
 	if (!adapter->vfinfo)
 		return -ENOMEM;
 
-	ixgbe_alloc_vf_macvlans(adapter);
+	adapter->num_vfs = num_vfs;
+
+	ixgbe_alloc_vf_macvlans(adapter, num_vfs);
+	adapter->ring_feature[RING_F_VMDQ].offset = num_vfs;
 
 	/* Initialize default switching mode VEB */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 	adapter->bridge_mode = BRIDGE_MODE_VEB;
 
 	/* limit trafffic classes based on VFs enabled */
-	if ((adapter->hw.mac.type == ixgbe_mac_82599EB) &&
-	    (adapter->num_vfs < 16)) {
+	if ((adapter->hw.mac.type == ixgbe_mac_82599EB) && (num_vfs < 16)) {
 		adapter->dcb_cfg.num_tcs.pg_tcs = MAX_TRAFFIC_CLASS;
 		adapter->dcb_cfg.num_tcs.pfc_tcs = MAX_TRAFFIC_CLASS;
-	} else if (adapter->num_vfs < 32) {
+	} else if (num_vfs < 32) {
 		adapter->dcb_cfg.num_tcs.pg_tcs = 4;
 		adapter->dcb_cfg.num_tcs.pfc_tcs = 4;
 	} else {
@@ -115,7 +116,7 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 	adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 			     IXGBE_FLAG2_RSC_ENABLED);
 
-	for (i = 0; i < adapter->num_vfs; i++) {
+	for (i = 0; i < num_vfs; i++) {
 		/* enable spoof checking for all VFs */
 		adapter->vfinfo[i].spoofchk_enabled = true;
 
@@ -133,7 +134,7 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		adapter->vfinfo[i].xcast_mode = IXGBEVF_XCAST_MODE_NONE;
 	}
 
-	e_info(probe, "SR-IOV enabled with %d VFs\n", adapter->num_vfs);
+	e_info(probe, "SR-IOV enabled with %d VFs\n", num_vfs);
 	return 0;
 }
 
@@ -172,12 +173,13 @@ static void ixgbe_get_vfs(struct ixgbe_adapter *adapter)
 /* Note this function is called when the user wants to enable SR-IOV
  * VFs using the now deprecated module parameter
  */
-void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
+void ixgbe_enable_sriov(struct ixgbe_adapter *adapter, unsigned int max_vfs)
 {
 	int pre_existing_vfs = 0;
+	unsigned int num_vfs;
 
 	pre_existing_vfs = pci_num_vf(adapter->pdev);
-	if (!pre_existing_vfs && !adapter->num_vfs)
+	if (!pre_existing_vfs && !max_vfs)
 		return;
 
 	/* If there are pre-existing VFs then we have to force
@@ -187,7 +189,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 	 * have been created via the new PCI SR-IOV sysfs interface.
 	 */
 	if (pre_existing_vfs) {
-		adapter->num_vfs = pre_existing_vfs;
+		num_vfs = pre_existing_vfs;
 		dev_warn(&adapter->pdev->dev,
 			 "Virtual Functions already enabled for this device - Please reload all VF drivers to avoid spoofed packet errors\n");
 	} else {
@@ -199,17 +201,16 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		 * physical function.  If the user requests greater than
 		 * 63 VFs then it is an error - reset to default of zero.
 		 */
-		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
+		num_vfs = min_t(unsigned int, max_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
 
-		err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
+		err = pci_enable_sriov(adapter->pdev, num_vfs);
 		if (err) {
 			e_err(probe, "Failed to enable PCI sriov: %d\n", err);
-			adapter->num_vfs = 0;
 			return;
 		}
 	}
 
-	if (!__ixgbe_enable_sriov(adapter)) {
+	if (!__ixgbe_enable_sriov(adapter, num_vfs)) {
 		ixgbe_get_vfs(adapter);
 		return;
 	}
@@ -347,13 +348,12 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
 			return -EPERM;
 		}
 	}
-	adapter->num_vfs = num_vfs;
 
-	err = __ixgbe_enable_sriov(adapter);
+	err = __ixgbe_enable_sriov(adapter, num_vfs);
 	if (err)
 		return  err;
 
-	for (i = 0; i < adapter->num_vfs; i++)
+	for (i = 0; i < num_vfs; i++)
 		ixgbe_vf_configuration(dev, (i | 0x10000000));
 
 	/* reset before enabling SRIOV to avoid mailbox issues */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 3166fd164e51..cf67b9b18ed7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -59,7 +59,7 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
 int ixgbe_disable_sriov(struct ixgbe_adapter *adapter);
 #ifdef CONFIG_PCI_IOV
-void ixgbe_enable_sriov(struct ixgbe_adapter *adapter);
+void ixgbe_enable_sriov(struct ixgbe_adapter *adapter, unsigned int max_vfs);
 #endif
 int ixgbe_pci_sriov_configure(struct pci_dev *dev, int num_vfs);
 
-- 
2.12.2
