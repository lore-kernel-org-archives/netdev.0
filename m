From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: Make VF resets more reliable
Date: Tue,  5 Apr 2016 20:36:01 -0700
Message-ID: <1459913769-56510-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46067 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760840AbcDFDgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:32 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Clear the VFLR bit immediately after triggering a reset instead of
waiting until after cleanup is complete. Make sure to trigger a reset
every time, not just if the PF is up.

These changes fix a problem where VF resets would get lost by the PF,
preventing the VF driver from initializing.

Change-ID: I5945cf2884095b7b0554867c64df8617e71d9d29
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 150002e..169c256 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -937,6 +937,10 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		wr32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id), reg);
 		i40e_flush(hw);
 	}
+	/* clear the VFLR bit in GLGEN_VFLRSTAT */
+	reg_idx = (hw->func_caps.vf_base_id + vf->vf_id) / 32;
+	bit_idx = (hw->func_caps.vf_base_id + vf->vf_id) % 32;
+	wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
 
 	if (i40e_quiesce_vf_pci(vf))
 		dev_err(&pf->pdev->dev, "VF %d PCI transactions stuck\n",
@@ -989,10 +993,6 @@ complete_reset:
 	/* tell the VF the reset is done */
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
 
-	/* clear the VFLR bit in GLGEN_VFLRSTAT */
-	reg_idx = (hw->func_caps.vf_base_id + vf->vf_id) / 32;
-	bit_idx = (hw->func_caps.vf_base_id + vf->vf_id) % 32;
-	wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
 	i40e_flush(hw);
 	clear_bit(__I40E_VF_DISABLE, &pf->state);
 }
@@ -2296,11 +2296,9 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 		/* read GLGEN_VFLRSTAT register to find out the flr VFs */
 		vf = &pf->vf[vf_id];
 		reg = rd32(hw, I40E_GLGEN_VFLRSTAT(reg_idx));
-		if (reg & BIT(bit_idx)) {
+		if (reg & BIT(bit_idx))
 			/* i40e_reset_vf will clear the bit in GLGEN_VFLRSTAT */
-			if (!test_bit(__I40E_DOWN, &pf->state))
-				i40e_reset_vf(vf, true);
-		}
+			i40e_reset_vf(vf, true);
 	}
 
 	return 0;
-- 
2.5.5
