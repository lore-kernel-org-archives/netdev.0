From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] i40e: re-enable VFLR interrupt sooner
Date: Fri, 14 Nov 2014 22:08:25 -0800
Message-ID: <1416031715-32498-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4893 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaKOGIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:38 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

VF interrupt processing takes a looooong time, and it's possible that we
could lose a VFLR event if it happens while we're processing a VFLR on
another VF. This would leave the VF in a semi-permanent reset state,
which would not be cleared until yet another VF experiences a VFLR.

To correct this situation, we enable the VFLR interrupt cause before we
begin processing any pending resets. This means that any VFLR that
occurs during reset processing will generate another interrupt and this
routine will get called again.

This change may cause a spurious interrupt when multiple VFLRs occur
very close together in time. If this happens, then this routine will be
called again and it will detect no outstanding VFLR events and do
nothing. No harm, no foul.

Change-ID: Id0451f3e6e73a2cf6db1668296c71e129b59dc19
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fff3c27..668d860 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1869,6 +1869,12 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 	if (!test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
 		return 0;
 
+	/* re-enable vflr interrupt cause */
+	reg = rd32(hw, I40E_PFINT_ICR0_ENA);
+	reg |= I40E_PFINT_ICR0_ENA_VFLR_MASK;
+	wr32(hw, I40E_PFINT_ICR0_ENA, reg);
+	i40e_flush(hw);
+
 	clear_bit(__I40E_VFLR_EVENT_PENDING, &pf->state);
 	for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
 		reg_idx = (hw->func_caps.vf_base_id + vf_id) / 32;
@@ -1885,12 +1891,6 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 		}
 	}
 
-	/* re-enable vflr interrupt cause */
-	reg = rd32(hw, I40E_PFINT_ICR0_ENA);
-	reg |= I40E_PFINT_ICR0_ENA_VFLR_MASK;
-	wr32(hw, I40E_PFINT_ICR0_ENA, reg);
-	i40e_flush(hw);
-
 	return 0;
 }
 
-- 
1.9.3
