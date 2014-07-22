From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH] i40e: use global pci_vfs_assigned() to
	replace local i40e_vfs_are_assigned()
Date: Tue, 22 Jul 2014 09:50:51 +0800
Message-ID: <1405993851-24375-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

There is global funcion pci_vfs_assigned(), so use it instead of composing
local one.

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   31 +-------------------
 1 files changed, 1 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 02c11a7..ec59190 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -683,35 +683,6 @@ complete_reset:
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
 	i40e_flush(hw);
 }
-
-/**
- * i40e_vfs_are_assigned
- * @pf: pointer to the pf structure
- *
- * Determine if any VFs are assigned to VMs
- **/
-static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
-{
-	struct pci_dev *pdev = pf->pdev;
-	struct pci_dev *vfdev;
-
-	/* loop through all the VFs to see if we own any that are assigned */
-	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_DEV_ID_VF , NULL);
-	while (vfdev) {
-		/* if we don't own it we don't care */
-		if (vfdev->is_virtfn && pci_physfn(vfdev) == pdev) {
-			/* if it is assigned we cannot release it */
-			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
-				return true;
-		}
-
-		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
-				       I40E_DEV_ID_VF,
-				       vfdev);
-	}
-
-	return false;
-}
 #ifdef CONFIG_PCI_IOV
 
 /**
@@ -815,7 +786,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	kfree(pf->vf);
 	pf->vf = NULL;
 
-	if (!i40e_vfs_are_assigned(pf)) {
+	if (!pci_vfs_assigned(pf->pdev)) {
 		pci_disable_sriov(pf->pdev);
 		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
 		 * work correctly when SR-IOV gets re-enabled.
-- 
1.7.1


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
