From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/18] fm10k: fix iov_msg_mac_vlan_pf VID checks
Date: Tue, 15 Sep 2015 17:36:43 -0700
Message-ID: <1442363803-47237-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26175 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbbIPAgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:51 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The VF will send a message to request multicast addresses with the
default VID. In the current code, if the PF has statically assigned a
VLAN to a VF, then the VF will not get the multicast addresses. Fix up
all of the various VLAN messages to use identical checks (since each
check was different). Also use set as a variable, so that it simplifies
our check for whether VLAN matches the pf_vid.

The new logic will allow set of a VLAN if it is zero, automatically
converting to the default VID. Otherwise it will allow setting the PF
VID, or any VLAN if PF has not statically assigned a VLAN. This is
consistent behavior, and allows VF to request either 0 or the
default_vid without silently failing.

Note that we need the check for zero since VFs might not get the default
VID message in time to actually request non-zero VLANs.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 85 ++++++++++++++++++-----------
 1 file changed, 52 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index d806d87..8c0bdc4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1155,6 +1155,24 @@ s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *hw, u32 **results,
 }
 
 /**
+ * fm10k_iov_select_vid - Select correct default VID
+ * @hw: Pointer to hardware structure
+ * @vid: VID to correct
+ *
+ * Will report an error if VID is out of range. For VID = 0, it will return
+ * either the pf_vid or sw_vid depending on which one is set.
+ */
+static inline s32 fm10k_iov_select_vid(struct fm10k_vf_info *vf_info, u16 vid)
+{
+	if (!vid)
+		return vf_info->pf_vid ? vf_info->pf_vid : vf_info->sw_vid;
+	else if (vf_info->pf_vid && vid != vf_info->pf_vid)
+		return FM10K_ERR_PARAM;
+	else
+		return vid;
+}
+
+/**
  *  fm10k_iov_msg_mac_vlan_pf - Message handler for MAC/VLAN request from VF
  *  @hw: Pointer to hardware structure
  *  @results: Pointer array to message, results[0] is pointer to message
@@ -1168,9 +1186,10 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 			      struct fm10k_mbx_info *mbx)
 {
 	struct fm10k_vf_info *vf_info = (struct fm10k_vf_info *)mbx;
-	int err = 0;
 	u8 mac[ETH_ALEN];
 	u32 *result;
+	int err = 0;
+	bool set;
 	u16 vlan;
 	u32 vid;
 
@@ -1186,19 +1205,21 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		if (err)
 			return err;
 
-		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
-		if (!vid || (vid == FM10K_VLAN_CLEAR)) {
-			if (vf_info->pf_vid)
-				vid |= vf_info->pf_vid;
-			else
-				vid |= vf_info->sw_vid;
-		} else if (vid != vf_info->pf_vid) {
+		/* verify upper 16 bits are zero */
+		if (vid >> 16)
 			return FM10K_ERR_PARAM;
-		}
+
+		set = !(vid & FM10K_VLAN_CLEAR);
+		vid &= ~FM10K_VLAN_CLEAR;
+
+		err = fm10k_iov_select_vid(vf_info, vid);
+		if (err < 0)
+			return err;
+		else
+			vid = err;
 
 		/* update VSI info for VF in regards to VLAN table */
-		err = hw->mac.ops.update_vlan(hw, vid, vf_info->vsi,
-					      !(vid & FM10K_VLAN_CLEAR));
+		err = hw->mac.ops.update_vlan(hw, vid, vf_info->vsi, set);
 	}
 
 	if (!err && !!results[FM10K_MAC_VLAN_MSG_MAC]) {
@@ -1214,19 +1235,18 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		    memcmp(mac, vf_info->mac, ETH_ALEN))
 			return FM10K_ERR_PARAM;
 
-		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
-		if (!vlan || (vlan == FM10K_VLAN_CLEAR)) {
-			if (vf_info->pf_vid)
-				vlan |= vf_info->pf_vid;
-			else
-				vlan |= vf_info->sw_vid;
-		} else if (vf_info->pf_vid) {
-			return FM10K_ERR_PARAM;
-		}
+		set = !(vlan & FM10K_VLAN_CLEAR);
+		vlan &= ~FM10K_VLAN_CLEAR;
+
+		err = fm10k_iov_select_vid(vf_info, vlan);
+		if (err < 0)
+			return err;
+		else
+			vlan = err;
 
 		/* notify switch of request for new unicast address */
-		err = hw->mac.ops.update_uc_addr(hw, vf_info->glort, mac, vlan,
-						 !(vlan & FM10K_VLAN_CLEAR), 0);
+		err = hw->mac.ops.update_uc_addr(hw, vf_info->glort,
+						 mac, vlan, set, 0);
 	}
 
 	if (!err && !!results[FM10K_MAC_VLAN_MSG_MULTICAST]) {
@@ -1241,19 +1261,18 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		if (!(vf_info->vf_flags & FM10K_VF_FLAG_MULTI_ENABLED))
 			return FM10K_ERR_PARAM;
 
-		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
-		if (!vlan || (vlan == FM10K_VLAN_CLEAR)) {
-			if (vf_info->pf_vid)
-				vlan |= vf_info->pf_vid;
-			else
-				vlan |= vf_info->sw_vid;
-		} else if (vf_info->pf_vid) {
-			return FM10K_ERR_PARAM;
-		}
+		set = !(vlan & FM10K_VLAN_CLEAR);
+		vlan &= ~FM10K_VLAN_CLEAR;
+
+		err = fm10k_iov_select_vid(vf_info, vlan);
+		if (err < 0)
+			return err;
+		else
+			vlan = err;
 
 		/* notify switch of request for new multicast address */
-		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort, mac, vlan,
-						 !(vlan & FM10K_VLAN_CLEAR));
+		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort,
+						 mac, vlan, set);
 	}
 
 	return err;
-- 
2.4.3
