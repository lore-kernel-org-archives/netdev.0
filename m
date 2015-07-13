From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e: do a proper reset when disabling a VF
Date: Mon, 13 Jul 2015 02:08:31 -0700
Message-ID: <1436778517-16254-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40574 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbbGMJIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:08:47 -0400
In-Reply-To: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The VF disable code was just whanging on the reset bit without properly
cleaning up the VF, which would leave the VF in an indeterminate state
from which it could not recover. Fix this by notifying the VF and then
by calling the normal VF reset routine.

Change-ID: I862b9dfa919368773cbdc212b805b520db2f7430
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4070a22..55b19f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -160,13 +160,8 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
  **/
 static inline void i40e_vc_disable_vf(struct i40e_pf *pf, struct i40e_vf *vf)
 {
-	struct i40e_hw *hw = &pf->hw;
-	u32 reg;
-
-	reg = rd32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id));
-	reg |= I40E_VPGEN_VFRTRIG_VFSWR_MASK;
-	wr32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id), reg);
-	i40e_flush(hw);
+	i40e_vc_notify_vf_reset(vf);
+	i40e_reset_vf(vf, false);
 }
 
 /**
-- 
2.4.3
