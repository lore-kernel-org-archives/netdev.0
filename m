From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] ixgbe: move num_vfs_macvlans allocation into separate function
Date: Tue, 18 Apr 2017 16:01:58 -0700
Message-ID: <20170418230205.37223-9-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:55358 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757500AbdDRXCO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:14 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Move the code allocating memory for list of MAC addresses that
the VFs can use for MACVLAN into its own function.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 48 ++++++++++++++++----------
 1 file changed, 29 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 39e109da9bd9..d10b25fa0be4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -46,42 +46,50 @@
 #include "ixgbe_sriov.h"
 
 #ifdef CONFIG_PCI_IOV
-static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
+static inline void ixgbe_alloc_vf_macvlans(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int num_vf_macvlans, i;
 	struct vf_macvlans *mv_list;
-
-	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
-	e_info(probe, "SR-IOV enabled with %d VFs\n", adapter->num_vfs);
-
-	/* Enable VMDq flag so device will be set in VM mode */
-	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED;
-	if (!adapter->ring_feature[RING_F_VMDQ].limit)
-		adapter->ring_feature[RING_F_VMDQ].limit = 1;
-	adapter->ring_feature[RING_F_VMDQ].offset = adapter->num_vfs;
+	int num_vf_macvlans, i;
 
 	num_vf_macvlans = hw->mac.num_rar_entries -
-	(IXGBE_MAX_PF_MACVLANS + 1 + adapter->num_vfs);
+			  (IXGBE_MAX_PF_MACVLANS + 1 + adapter->num_vfs);
+	if (!num_vf_macvlans)
+		return;
 
-	adapter->mv_list = mv_list = kcalloc(num_vf_macvlans,
-					     sizeof(struct vf_macvlans),
-					     GFP_KERNEL);
+	mv_list = kcalloc(num_vf_macvlans, sizeof(struct vf_macvlans),
+			  GFP_KERNEL);
 	if (mv_list) {
 		/* Initialize list of VF macvlans */
 		INIT_LIST_HEAD(&adapter->vf_mvs.l);
 		for (i = 0; i < num_vf_macvlans; i++) {
-			mv_list->vf = -1;
-			mv_list->free = true;
-			list_add(&mv_list->l, &adapter->vf_mvs.l);
-			mv_list++;
+			mv_list[i].vf = -1;
+			mv_list[i].free = true;
+			list_add(&mv_list[i].l, &adapter->vf_mvs.l);
 		}
+		adapter->mv_list = mv_list;
 	}
+}
+
+static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
+	e_info(probe, "SR-IOV enabled with %d VFs\n", adapter->num_vfs);
+
+	/* Enable VMDq flag so device will be set in VM mode */
+	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED;
+	if (!adapter->ring_feature[RING_F_VMDQ].limit)
+		adapter->ring_feature[RING_F_VMDQ].limit = 1;
+	adapter->ring_feature[RING_F_VMDQ].offset = adapter->num_vfs;
 
 	/* Initialize default switching mode VEB */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 	adapter->bridge_mode = BRIDGE_MODE_VEB;
 
+	ixgbe_alloc_vf_macvlans(adapter);
+
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
 	 */
@@ -89,6 +97,8 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		kcalloc(adapter->num_vfs,
 			sizeof(struct vf_data_storage), GFP_KERNEL);
 	if (adapter->vfinfo) {
+		int i;
+
 		/* limit trafffic classes based on VFs enabled */
 		if ((adapter->hw.mac.type == ixgbe_mac_82599EB) &&
 		    (adapter->num_vfs < 16)) {
-- 
2.12.2
