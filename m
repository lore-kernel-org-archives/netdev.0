From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 16/17] fm10k: fix iov_msg_lport_state_pf issue
Date: Wed, 17 Jun 2015 05:55:03 -0700
Message-ID: <1434545704-112470-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14632 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756603AbbFQMzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:23 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When a VF issues an LPORT_STATE request to enable a port that is already
enabled, the PF will first disable the VF LPORT. Then it should
re-enable the VF again with the new requested settings. This ensures
that any switch rules are cleared by deleting the LPORT on the switch.
However, the flow is bugged because we actually check if the VF is
enabled at the end, and thus don't re-enable it. Fix the flow so that we
actually clear the enabled flags as part of our removal of the LPORT.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index ab81c00..54d1cd9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1351,6 +1351,14 @@ s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *hw, u32 **results,
 			err = fm10k_update_lport_state_pf(hw, vf_info->glort,
 							  1, false);
 
+		/* we need to clear VF_FLAG_ENABLED flags in order to ensure
+		 * that we actually re-enable the LPORT state below. Note that
+		 * this has no impact if the VF is already disabled, as the
+		 * flags are already cleared.
+		 */
+		if (!err)
+			vf_info->vf_flags = FM10K_VF_FLAG_CAPABLE(vf_info);
+
 		/* when enabling the port we should reset the rate limiters */
 		hw->iov.ops.configure_tc(hw, vf_info->vf_idx, vf_info->rate);
 
-- 
2.4.3
