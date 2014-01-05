From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: guard against vf message races
Date: Sun,  5 Jan 2014 02:46:57 -0800
Message-ID: <1388918827-13430-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26680 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbaAEKrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:13 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When disabling and enabling VFs on a live system with the VF driver
loaded, it's possible to receive an admin queue message from the VF
driver at an inconvenient time, e.g. when the associated data structures
aren't present or configured. This causes a rather inconvenient panic.

To guard against this, we change the order of when we set num_alloc_vfs
when turning off SR-IOV, and then gate processing of any VF messages
based upon that value. Likewise, when enabling VFs, we shut off the
relevant interrupt until configuration is complete.

Change-Id: I0c172c056616c2bebd78bbc807ab446eb484deea
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 23 +++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cc4ebf5..ed25fcb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -720,7 +720,7 @@ static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
 void i40e_free_vfs(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	int i;
+	int i, tmp;
 
 	if (!pf->vf)
 		return;
@@ -728,9 +728,11 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	/* Disable interrupt 0 so we don't try to handle the VFLR. */
 	wr32(hw, I40E_PFINT_DYN_CTL0, 0);
 	i40e_flush(hw);
-
+	mdelay(10); /* let any messages in transit get finished up */
 	/* free up vf resources */
-	for (i = 0; i < pf->num_alloc_vfs; i++) {
+	tmp = pf->num_alloc_vfs;
+	pf->num_alloc_vfs = 0;
+	for (i = 0; i < tmp; i++) {
 		if (test_bit(I40E_VF_STAT_INIT, &pf->vf[i].vf_states))
 			i40e_free_vf_res(&pf->vf[i]);
 		/* disable qp mappings */
@@ -739,7 +741,6 @@ void i40e_free_vfs(struct i40e_pf *pf)
 
 	kfree(pf->vf);
 	pf->vf = NULL;
-	pf->num_alloc_vfs = 0;
 
 	if (!i40e_vfs_are_assigned(pf))
 		pci_disable_sriov(pf->pdev);
@@ -765,9 +766,13 @@ void i40e_free_vfs(struct i40e_pf *pf)
  **/
 static int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 {
+	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vfs;
 	int i, ret = 0;
 
+	/* Disable interrupt 0 so we don't try to handle the VFLR. */
+	wr32(hw, I40E_PFINT_DYN_CTL0, 0);
+	i40e_flush(hw);
 	ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
 	if (ret) {
 		dev_err(&pf->pdev->dev,
@@ -804,6 +809,11 @@ err_alloc:
 	if (ret)
 		i40e_free_vfs(pf);
 err_iov:
+	/* Re-enable interrupt 0. */
+	wr32(hw, I40E_PFINT_DYN_CTL0,
+	     I40E_PFINT_DYN_CTL0_INTENA_MASK |
+	     I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
+	     (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT));
 	return ret;
 }
 
@@ -1644,11 +1654,14 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 			   u32 v_retval, u8 *msg, u16 msglen)
 {
-	struct i40e_vf *vf = &(pf->vf[vf_id]);
 	struct i40e_hw *hw = &pf->hw;
+	struct i40e_vf *vf;
 	int ret;
 
 	pf->vf_aq_requests++;
+	if (vf_id >= pf->num_alloc_vfs)
+		return -EINVAL;
+	vf = &(pf->vf[vf_id]);
 	/* perform basic checks on the msg */
 	ret = i40e_vc_validate_vf_msg(vf, v_opcode, v_retval, msg, msglen);
 
-- 
1.8.3.1
