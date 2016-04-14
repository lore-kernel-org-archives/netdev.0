From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] fm10k: fix multi-bit VLAN update requests from VF
Date: Wed, 13 Apr 2016 20:47:12 -0700
Message-ID: <1460605632-112945-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460605632-112945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52989 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbcDNDr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 23:47:56 -0400
In-Reply-To: <1460605632-112945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The VF uses a multi-bit update request to clear unused VLANs whenever it
resets. However, an accident in a previous refector broke multi-bit
updates for VFs, due to misreading a comment in fm10k_vf.c and
attempting to reduce code duplication. The problem occurs because
a multi-bit request has a non-zero length, and the PF would simply drop
any request with the upper 16 bits set.

We can't simply remove the check of the upper 16 bits and the call to
fm10k_iov_select vid, because this would remove the checks for default
VID and for ensuring no other VLANs can be enabled except pf_vid when it
has been set. To resolve that issue, this revision uses the
iov_select_vid when we have a single-bit update, and denies any
multi-bit update when the VLAN was administratively set by the PF. This
should be ok since the PF properly updates VLAN_TABLE when it assigns
the PF vid. This ensures that requests to add or remove the PF vid work
as expected, but a rogue VF could not use the multi-bit update as
a loophole to attempt receiving traffic on other VLANs.

Reported-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 30 +++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 62ccebc..8cf943d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1223,18 +1223,32 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		if (err)
 			return err;
 
-		/* verify upper 16 bits are zero */
-		if (vid >> 16)
-			return FM10K_ERR_PARAM;
-
 		set = !(vid & FM10K_VLAN_CLEAR);
 		vid &= ~FM10K_VLAN_CLEAR;
 
-		err = fm10k_iov_select_vid(vf_info, (u16)vid);
-		if (err < 0)
-			return err;
+		/* if the length field has been set, this is a multi-bit
+		 * update request. For multi-bit requests, simply disallow
+		 * them when the pf_vid has been set. In this case, the PF
+		 * should have already cleared the VLAN_TABLE, and if we
+		 * allowed them, it could allow a rogue VF to receive traffic
+		 * on a VLAN it was not assigned. In the single-bit case, we
+		 * need to modify requests for VLAN 0 to use the default PF or
+		 * SW vid when assigned.
+		 */
 
-		vid = err;
+		if (vid >> 16) {
+			/* prevent multi-bit requests when PF has
+			 * administratively set the VLAN for this VF
+			 */
+			if (vf_info->pf_vid)
+				return FM10K_ERR_PARAM;
+		} else {
+			err = fm10k_iov_select_vid(vf_info, (u16)vid);
+			if (err < 0)
+				return err;
+
+			vid = err;
+		}
 
 		/* update VSI info for VF in regards to VLAN table */
 		err = hw->mac.ops.update_vlan(hw, vid, vf_info->vsi, set);
-- 
2.5.5
