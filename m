From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/16] i40e: get pf_id from HW rather than PCI function
Date: Sat,  6 Dec 2014 05:02:11 -0800
Message-ID: <1417870933-17248-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8818 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbaLFNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:03:00 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Getting the pf_id from the function number was a good place to start,
but when the PF was setup in passthru mode, the PCI bus/device/function
was virtualized and the number in the VM is different from the number in
the bare metal.  This caused HW configuration issues when the wrong pf_id
was used to set up the HMC and other structures.  The PF_FUNC_RID register
has the real bus/device/function information as configured by the BIOS,
so use that for a better number.  This works in NPAR mode as well.

Change-ID: I65e3dd6c97594890c2bad566b83cc670b1dae534
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index ec63bcb..3d741ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -550,7 +550,7 @@ struct i40e_rx_ptype_decoded i40e_ptype_lookup[] = {
 i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 {
 	i40e_status status = 0;
-	u32 reg;
+	u32 port, ari, func_rid;
 
 	i40e_set_mac_type(hw);
 
@@ -563,18 +563,17 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 
 	hw->phy.get_link_info = true;
 
-	/* Determine port number */
-	reg = rd32(hw, I40E_PFGEN_PORTNUM);
-	reg = ((reg & I40E_PFGEN_PORTNUM_PORT_NUM_MASK) >>
-	       I40E_PFGEN_PORTNUM_PORT_NUM_SHIFT);
-	hw->port = (u8)reg;
-
-	/* Determine the PF number based on the PCI fn */
-	reg = rd32(hw, I40E_GLPCI_CAPSUP);
-	if (reg & I40E_GLPCI_CAPSUP_ARI_EN_MASK)
-		hw->pf_id = (u8)((hw->bus.device << 3) | hw->bus.func);
+	/* Determine port number and PF number*/
+	port = (rd32(hw, I40E_PFGEN_PORTNUM) & I40E_PFGEN_PORTNUM_PORT_NUM_MASK)
+					   >> I40E_PFGEN_PORTNUM_PORT_NUM_SHIFT;
+	hw->port = (u8)port;
+	ari = (rd32(hw, I40E_GLPCI_CAPSUP) & I40E_GLPCI_CAPSUP_ARI_EN_MASK) >>
+						 I40E_GLPCI_CAPSUP_ARI_EN_SHIFT;
+	func_rid = rd32(hw, I40E_PF_FUNC_RID);
+	if (ari)
+		hw->pf_id = (u8)(func_rid & 0xff);
 	else
-		hw->pf_id = (u8)hw->bus.func;
+		hw->pf_id = (u8)(func_rid & 0x7);
 
 	status = i40e_init_nvm(hw);
 	return status;
-- 
1.9.3
