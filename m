From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbe: return early instead of wrap block in if statement
Date: Tue, 18 Apr 2017 16:01:59 -0700
Message-ID: <20170418230205.37223-10-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757516AbdDRXCO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:14 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Since we exit at the end of the block, we can save a level of
indentation by performing an early return, and make the next several
sections of code more legible, with fewer 80 character line breaks.

Also moved allocating vfinfo at the beginning and the notification
for enabling SRIOV at the end of the function when we know that it
will succeed.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 85 +++++++++++++-------------
 1 file changed, 41 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d10b25fa0be4..16952d33730e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -74,9 +74,9 @@ static inline void ixgbe_alloc_vf_macvlans(struct ixgbe_adapter *adapter)
 static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
 
 	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
-	e_info(probe, "SR-IOV enabled with %d VFs\n", adapter->num_vfs);
 
 	/* Enable VMDq flag so device will be set in VM mode */
 	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED;
@@ -84,60 +84,57 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		adapter->ring_feature[RING_F_VMDQ].limit = 1;
 	adapter->ring_feature[RING_F_VMDQ].offset = adapter->num_vfs;
 
-	/* Initialize default switching mode VEB */
-	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-	adapter->bridge_mode = BRIDGE_MODE_VEB;
-
-	ixgbe_alloc_vf_macvlans(adapter);
-
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
 	 */
-	adapter->vfinfo =
-		kcalloc(adapter->num_vfs,
-			sizeof(struct vf_data_storage), GFP_KERNEL);
-	if (adapter->vfinfo) {
-		int i;
-
-		/* limit trafffic classes based on VFs enabled */
-		if ((adapter->hw.mac.type == ixgbe_mac_82599EB) &&
-		    (adapter->num_vfs < 16)) {
-			adapter->dcb_cfg.num_tcs.pg_tcs = MAX_TRAFFIC_CLASS;
-			adapter->dcb_cfg.num_tcs.pfc_tcs = MAX_TRAFFIC_CLASS;
-		} else if (adapter->num_vfs < 32) {
-			adapter->dcb_cfg.num_tcs.pg_tcs = 4;
-			adapter->dcb_cfg.num_tcs.pfc_tcs = 4;
-		} else {
-			adapter->dcb_cfg.num_tcs.pg_tcs = 1;
-			adapter->dcb_cfg.num_tcs.pfc_tcs = 1;
-		}
+	adapter->vfinfo = kcalloc(adapter->num_vfs,
+				  sizeof(struct vf_data_storage), GFP_KERNEL);
+	if (!adapter->vfinfo)
+		return -ENOMEM;
+
+	ixgbe_alloc_vf_macvlans(adapter);
+
+	/* Initialize default switching mode VEB */
+	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+	adapter->bridge_mode = BRIDGE_MODE_VEB;
 
-		/* Disable RSC when in SR-IOV mode */
-		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
-				     IXGBE_FLAG2_RSC_ENABLED);
+	/* limit trafffic classes based on VFs enabled */
+	if ((adapter->hw.mac.type == ixgbe_mac_82599EB) &&
+	    (adapter->num_vfs < 16)) {
+		adapter->dcb_cfg.num_tcs.pg_tcs = MAX_TRAFFIC_CLASS;
+		adapter->dcb_cfg.num_tcs.pfc_tcs = MAX_TRAFFIC_CLASS;
+	} else if (adapter->num_vfs < 32) {
+		adapter->dcb_cfg.num_tcs.pg_tcs = 4;
+		adapter->dcb_cfg.num_tcs.pfc_tcs = 4;
+	} else {
+		adapter->dcb_cfg.num_tcs.pg_tcs = 1;
+		adapter->dcb_cfg.num_tcs.pfc_tcs = 1;
+	}
 
-		for (i = 0; i < adapter->num_vfs; i++) {
-			/* enable spoof checking for all VFs */
-			adapter->vfinfo[i].spoofchk_enabled = true;
+	/* Disable RSC when in SR-IOV mode */
+	adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
+			     IXGBE_FLAG2_RSC_ENABLED);
 
-			/* We support VF RSS querying only for 82599 and x540
-			 * devices at the moment. These devices share RSS
-			 * indirection table and RSS hash key with PF therefore
-			 * we want to disable the querying by default.
-			 */
-			adapter->vfinfo[i].rss_query_enabled = 0;
+	for (i = 0; i < adapter->num_vfs; i++) {
+		/* enable spoof checking for all VFs */
+		adapter->vfinfo[i].spoofchk_enabled = true;
 
-			/* Untrust all VFs */
-			adapter->vfinfo[i].trusted = false;
+		/* We support VF RSS querying only for 82599 and x540
+		 * devices at the moment. These devices share RSS
+		 * indirection table and RSS hash key with PF therefore
+		 * we want to disable the querying by default.
+		 */
+		adapter->vfinfo[i].rss_query_enabled = 0;
 
-			/* set the default xcast mode */
-			adapter->vfinfo[i].xcast_mode = IXGBEVF_XCAST_MODE_NONE;
-		}
+		/* Untrust all VFs */
+		adapter->vfinfo[i].trusted = false;
 
-		return 0;
+		/* set the default xcast mode */
+		adapter->vfinfo[i].xcast_mode = IXGBEVF_XCAST_MODE_NONE;
 	}
 
-	return -ENOMEM;
+	e_info(probe, "SR-IOV enabled with %d VFs\n", adapter->num_vfs);
+	return 0;
 }
 
 /**
-- 
2.12.2
