From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH 4/4] i40e: use PCI VFs assignment helper
	function simplify i40e_vfs_are_assigned()
Date: Fri, 11 Jul 2014 08:47:22 +0800
Message-ID: <1405039642-23519-4-git-send-email-ethan.zhao@oracle.com>
References: <1405039642-23519-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	kvm@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-pci@vger.kernel.org, vaughan.cao@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ethan.kernel@gmail.com
To: bhelgaas@google.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, gleb@kernel.org, pbonzini@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405039642-23519-1-git-send-email-ethan.zhao@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

New VFs reference counter mechanism and VFs assignment helper functions are introduced to
PCI SRIOV, use them instead of manipulating device flag directly.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   17 ++---------------
 1 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 02c11a7..781040e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -693,22 +693,9 @@ complete_reset:
 static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
 {
 	struct pci_dev *pdev = pf->pdev;
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
 
-		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
-				       I40E_DEV_ID_VF,
-				       vfdev);
-	}
+	if (pci_vfs_assigned(pdev))
+		return true;
 
 	return false;
 }
-- 
1.7.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
