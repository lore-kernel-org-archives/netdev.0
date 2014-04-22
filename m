From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e: Reset the VF upon conflicting VLAN configuration
Date: Tue, 22 Apr 2014 05:39:18 -0700
Message-ID: <1398170371-3333-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45665 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932601AbaDVMjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:37 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If a host VMM administrator hoses his VF by assigning a port VLAN after
it is already up and running with implicit permission to set local
VLANs then we print a message warning the host administrator that the
VF driver needs to be reloaded.

In addition we need to knock the VF offline so that it does not continue
to receive traffic not on the port VLAN assigned to it.  So we reset the
VF.  The VF will cease operation and the administrator will be forced to
unload and reload the VF driver to make it work again.

Change-ID: Iae1ae006b244e74e30a4ee546b3c5fca5cfb40aa
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 26 +++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 02c11a7..e3e4df0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -29,6 +29,24 @@
 /***********************misc routines*****************************/
 
 /**
+ * i40e_vc_disable_vf
+ * @pf: pointer to the pf info
+ * @vf: pointer to the vf info
+ *
+ * Disable the VF through a SW reset
+ **/
+static inline void i40e_vc_disable_vf(struct i40e_pf *pf, struct i40e_vf *vf)
+{
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg;
+
+	reg = rd32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id));
+	reg |= I40E_VPGEN_VFRTRIG_VFSWR_MASK;
+	wr32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id), reg);
+	i40e_flush(hw);
+}
+
+/**
  * i40e_vc_isvalid_vsi_id
  * @vf: pointer to the vf info
  * @vsi_id: vf relative vsi id
@@ -2088,10 +2106,16 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
-	if (vsi->info.pvid == 0 && i40e_is_vsi_in_vlan(vsi))
+	if (vsi->info.pvid == 0 && i40e_is_vsi_in_vlan(vsi)) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
+		/* Administrator Error - knock the VF offline until he does
+		 * the right thing by reconfiguring his network correctly
+		 * and then reloading the VF driver.
+		 */
+		i40e_vc_disable_vf(pf, vf);
+	}
 
 	/* Check for condition where there was already a port VLAN ID
 	 * filter set and now it is being deleted by setting it to zero.
-- 
1.9.0
