From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] fm10k: use different name than FM10K_VLAN_CLEAR for override bit
Date: Wed, 20 Apr 2016 23:09:24 -0700
Message-ID: <1461218969-68578-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbcDUGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:35 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Use a new #define FM10K_VLAN_OVERRIDE even though we're using the exact
same bit. The reason for this is clarity in the code, otherwise you can
read FM10K_VLAN_CLEAR and think it should be removed. Also add a comment
explaining why the FM10K_VLAN_OVERRIDE bit is set.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 8 ++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c   | 2 +-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index ffe9805..88d5acf 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -864,9 +864,13 @@ static s32 fm10k_iov_assign_default_mac_vlan_pf(struct fm10k_hw *hw,
 	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), 0);
 	fm10k_write_reg(hw, FM10K_TXDCTL(vf_q_idx), 0);
 
-	/* determine correct default VLAN ID */
+	/* Determine correct default VLAN ID. The FM10K_VLAN_OVERRIDE bit is
+	 * used here to indicate to the VF that it will not have privilege to
+	 * write VLAN_TABLE. All policy is enforced on the PF but this allows
+	 * the VF to correctly report errors to userspace rqeuests.
+	 */
 	if (vf_info->pf_vid)
-		vf_vid = vf_info->pf_vid | FM10K_VLAN_CLEAR;
+		vf_vid = vf_info->pf_vid | FM10K_VLAN_OVERRIDE;
 	else
 		vf_vid = vf_info->sw_vid;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 995dcee..f3f37a4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -350,6 +350,7 @@ struct fm10k_hw;
 #define FM10K_VLAN_TABLE_VSI_MAX		64
 #define FM10K_VLAN_LENGTH_SHIFT			16
 #define FM10K_VLAN_CLEAR			BIT(15)
+#define FM10K_VLAN_OVERRIDE			FM10K_VLAN_CLEAR
 #define FM10K_VLAN_ALL \
 	((FM10K_VLAN_TABLE_VID_MAX - 1) << FM10K_VLAN_LENGTH_SHIFT)
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 86c358c..801238d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -228,7 +228,7 @@ s32 fm10k_msg_mac_vlan_vf(struct fm10k_hw *hw, u32 **results,
 
 	ether_addr_copy(hw->mac.perm_addr, perm_addr);
 	hw->mac.default_vid = vid & (FM10K_VLAN_TABLE_VID_MAX - 1);
-	hw->mac.vlan_override = !!(vid & FM10K_VLAN_CLEAR);
+	hw->mac.vlan_override = !!(vid & FM10K_VLAN_OVERRIDE);
 
 	return 0;
 }
-- 
2.5.5
