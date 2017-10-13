From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] i40e: Add macro for PF reset bit
Date: Fri, 13 Oct 2017 14:52:42 -0700
Message-ID: <20171013215249.61286-3-jeffrey.t.kirsher@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:59784 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753050AbdJMVxV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:21 -0400
In-Reply-To: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

Introduce a macro for the bit setting the PF reset flag and
update its usages. This makes it easier to use this flag
in functions to be introduced in future without encountering
checkpatch issues related to alignment and line over 80
characters.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 9 ++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 ++---
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8139b4ee1dc3..e7c7a853cf7f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -157,6 +157,8 @@ enum i40e_state_t {
 	__I40E_STATE_SIZE__,
 };
 
+#define I40E_PF_RESET_FLAG	BIT_ULL(__I40E_PF_RESET_REQUESTED)
+
 /* VSI state flags */
 enum i40e_vsi_state_t {
 	__I40E_VSI_DOWN,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 6f2725fc50a1..2b8bbc84e34f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -798,8 +798,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		 */
 		if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
 			pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
-			i40e_do_reset_safe(pf,
-					   BIT_ULL(__I40E_PF_RESET_REQUESTED));
+			i40e_do_reset_safe(pf, I40E_PF_RESET_FLAG);
 		}
 
 		vsi = i40e_vsi_setup(pf, I40E_VSI_VMDQ2, vsi_seid, 0);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4de52001a2b9..6190257eecfe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5747,7 +5747,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 err_setup_tx:
 	i40e_vsi_free_tx_resources(vsi);
 	if (vsi == pf->vsi[pf->lan_vsi])
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
+		i40e_do_reset(pf, I40E_PF_RESET_FLAG, true);
 
 	return err;
 }
@@ -5875,7 +5875,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired)
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
 		i40e_flush(&pf->hw);
 
-	} else if (reset_flags & BIT_ULL(__I40E_PF_RESET_REQUESTED)) {
+	} else if (reset_flags & I40E_PF_RESET_FLAG) {
 
 		/* Request a PF Reset
 		 *
@@ -9223,7 +9223,7 @@ static int i40e_set_features(struct net_device *netdev,
 	need_reset = i40e_set_ntuple(pf, features);
 
 	if (need_reset)
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
+		i40e_do_reset(pf, I40E_PF_RESET_FLAG, true);
 
 	return 0;
 }
@@ -9475,8 +9475,7 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
 				pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
 			else
 				pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
-			i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED),
-				      true);
+			i40e_do_reset(pf, I40E_PF_RESET_FLAG, true);
 			break;
 		}
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0c4fa225c7be..e7f98e306554 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1425,8 +1425,7 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (num_vfs) {
 		if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
 			pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
-			i40e_do_reset_safe(pf,
-					   BIT_ULL(__I40E_PF_RESET_REQUESTED));
+			i40e_do_reset_safe(pf, I40E_PF_RESET_FLAG);
 		}
 		return i40e_pci_sriov_enable(pdev, num_vfs);
 	}
@@ -1434,7 +1433,7 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (!pci_vfs_assigned(pf->pdev)) {
 		i40e_free_vfs(pf);
 		pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
-		i40e_do_reset_safe(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, I40E_PF_RESET_FLAG);
 	} else {
 		dev_warn(&pdev->dev, "Unable to free VFs because some are assigned to VMs.\n");
 		return -EINVAL;
-- 
2.14.2
