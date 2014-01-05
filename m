From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: use functions to enable and disable icr 0
Date: Sun,  5 Jan 2014 02:46:59 -0800
Message-ID: <1388918827-13430-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26680 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083AbaAEKrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:14 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Introduce i40e_irq_dynamic_disable_icr0 and use it and its previously-
extant counterpart when appropriate.

Change-Id: Ieb4037874fba2e96fc2354b34a97a3cb8f6490f3
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 13 +++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 21 ++++++---------------
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 934623e..496ce05 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -565,6 +565,7 @@ static inline void i40e_dbg_init(void) {}
 static inline void i40e_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS*/
 void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector);
+void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf);
 void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf);
 int i40e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e48e1c8..94d0e45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2543,6 +2543,19 @@ static void i40e_configure_msi_and_legacy(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_irq_dynamic_disable_icr0 - Disable default interrupt generation for icr0
+ * @pf: board private structure
+ **/
+void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf)
+{
+	struct i40e_hw *hw = &pf->hw;
+
+	wr32(hw, I40E_PFINT_DYN_CTL0,
+	     I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
+	i40e_flush(hw);
+}
+
+/**
  * i40e_irq_dynamic_enable_icr0 - Enable default interrupt generation for icr0
  * @pf: board private structure
  **/
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ed25fcb..685b285 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -719,15 +719,14 @@ static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
  **/
 void i40e_free_vfs(struct i40e_pf *pf)
 {
-	struct i40e_hw *hw = &pf->hw;
 	int i, tmp;
 
 	if (!pf->vf)
 		return;
 
 	/* Disable interrupt 0 so we don't try to handle the VFLR. */
-	wr32(hw, I40E_PFINT_DYN_CTL0, 0);
-	i40e_flush(hw);
+	i40e_irq_dynamic_disable_icr0(pf);
+
 	mdelay(10); /* let any messages in transit get finished up */
 	/* free up vf resources */
 	tmp = pf->num_alloc_vfs;
@@ -749,11 +748,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			 "unable to disable SR-IOV because VFs are assigned.\n");
 
 	/* Re-enable interrupt 0. */
-	wr32(hw, I40E_PFINT_DYN_CTL0,
-	     I40E_PFINT_DYN_CTL0_INTENA_MASK |
-	     I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
-	     (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT));
-	i40e_flush(hw);
+	i40e_irq_dynamic_enable_icr0(pf);
 }
 
 #ifdef CONFIG_PCI_IOV
@@ -766,13 +761,12 @@ void i40e_free_vfs(struct i40e_pf *pf)
  **/
 static int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 {
-	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vfs;
 	int i, ret = 0;
 
 	/* Disable interrupt 0 so we don't try to handle the VFLR. */
-	wr32(hw, I40E_PFINT_DYN_CTL0, 0);
-	i40e_flush(hw);
+	i40e_irq_dynamic_disable_icr0(pf);
+
 	ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
 	if (ret) {
 		dev_err(&pf->pdev->dev,
@@ -810,10 +804,7 @@ err_alloc:
 		i40e_free_vfs(pf);
 err_iov:
 	/* Re-enable interrupt 0. */
-	wr32(hw, I40E_PFINT_DYN_CTL0,
-	     I40E_PFINT_DYN_CTL0_INTENA_MASK |
-	     I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
-	     (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT));
+	i40e_irq_dynamic_enable_icr0(pf);
 	return ret;
 }
 
-- 
1.8.3.1
