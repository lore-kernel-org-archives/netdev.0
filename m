From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] i40e: Added code to prevent double resets
Date: Tue,  5 Apr 2016 13:17:31 -0700
Message-ID: <1459887455-146634-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759914AbcDEURl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:41 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Clear the VFLR bit after reset processing, instead of before. This
prevents double resets on VF init.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 816c6bb..291d628 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -917,9 +917,9 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 {
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
+	u32 reg, reg_idx, bit_idx;
 	bool rsd = false;
 	int i;
-	u32 reg;
 
 	if (test_and_set_bit(__I40E_VF_DISABLE, &pf->state))
 		return;
@@ -988,6 +988,11 @@ complete_reset:
 	}
 	/* tell the VF the reset is done */
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
+
+	/* clear the VFLR bit in GLGEN_VFLRSTAT */
+	reg_idx = (hw->func_caps.vf_base_id + vf->vf_id) / 32;
+	bit_idx = (hw->func_caps.vf_base_id + vf->vf_id) % 32;
+	wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
 	i40e_flush(hw);
 	clear_bit(__I40E_VF_DISABLE, &pf->state);
 }
@@ -2293,9 +2298,7 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 		vf = &pf->vf[vf_id];
 		reg = rd32(hw, I40E_GLGEN_VFLRSTAT(reg_idx));
 		if (reg & BIT(bit_idx)) {
-			/* clear the bit in GLGEN_VFLRSTAT */
-			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
-
+			/* i40e_reset_vf will clear the bit in GLGEN_VFLRSTAT */
 			if (!test_bit(__I40E_DOWN, &pf->state))
 				i40e_reset_vf(vf, true);
 		}
-- 
2.5.5
