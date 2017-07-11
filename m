From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 2/6] [next-queue]net: i40e: Add macro for PF reset bit
Date: Tue, 11 Jul 2017 03:18:40 -0700
Message-ID: <149976832087.2896.12643778659209921543.stgit@anamdev.jf.intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:53446 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932322AbdGKKTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:19:09 -0400
In-Reply-To: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a macro for the bit setting the PF reset flag and
update its usages. This makes it easier to use this flag
in functions to be introduced in future without encountering
checkpatch issues related to alignment and line over 80
characters.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |    2 ++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        |    9 ++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    5 ++---
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 5f75e67..bd9bf46 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -155,6 +155,8 @@ enum i40e_state_t {
 	__I40E_STATE_SIZE__,
 };
 
+#define I40E_PF_RESET_FLAG	BIT_ULL(__I40E_PF_RESET_REQUESTED)
+
 /* VSI state flags */
 enum i40e_vsi_state_t {
 	__I40E_VSI_DOWN,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 8f326f8..b46117e 100644
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
index 998ad96..03412a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5738,7 +5738,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 err_setup_tx:
 	i40e_vsi_free_tx_resources(vsi);
 	if (vsi == pf->vsi[pf->lan_vsi])
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
+		i40e_do_reset(pf, I40E_PF_RESET_FLAG, true);
 
 	return err;
 }
@@ -5866,7 +5866,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired)
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
 		i40e_flush(&pf->hw);
 
-	} else if (reset_flags & BIT_ULL(__I40E_PF_RESET_REQUESTED)) {
+	} else if (reset_flags & I40E_PF_RESET_FLAG) {
 
 		/* Request a PF Reset
 		 *
@@ -9145,7 +9145,7 @@ static int i40e_set_features(struct net_device *netdev,
 	need_reset = i40e_set_ntuple(pf, features);
 
 	if (need_reset)
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
+		i40e_do_reset(pf, I40E_PF_RESET_FLAG, true);
 
 	return 0;
 }
@@ -9397,8 +9397,7 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
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
index 3ef67dc..be172f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1377,8 +1377,7 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (num_vfs) {
 		if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
 			pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
-			i40e_do_reset_safe(pf,
-					   BIT_ULL(__I40E_PF_RESET_REQUESTED));
+			i40e_do_reset_safe(pf, I40E_PF_RESET_FLAG);
 		}
 		return i40e_pci_sriov_enable(pdev, num_vfs);
 	}
@@ -1386,7 +1385,7 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (!pci_vfs_assigned(pf->pdev)) {
 		i40e_free_vfs(pf);
 		pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
-		i40e_do_reset_safe(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, I40E_PF_RESET_FLAG);
 	} else {
 		dev_warn(&pdev->dev, "Unable to free VFs because some are assigned to VMs.\n");
 		return -EINVAL;
