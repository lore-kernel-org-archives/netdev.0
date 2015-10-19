From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/17] i40e: Fix basic support for X722 devices
Date: Mon, 19 Oct 2015 15:49:17 -0700
Message-ID: <1445294971-44714-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbbJSWte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:34 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

Acquire NVM, before issuing an AQ read nvm command for X722.
We need to acquire the NVM before issuing an AQ read to the NVM
otherwise we will get EBUSY from the FW. Also release when done.

This fixes the two X722 issues with respect to eeprom checksum verify
and reading NVM version info.

With this patch in place, i40e driver will provide basic support
for X722 devices.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 31 +++++++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  3 +++
 3 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index daa6b17..7f456e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -958,6 +958,9 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 	else
 		hw->pf_id = (u8)(func_rid & 0x7);
 
+	if (hw->mac.type == I40E_MAC_X722)
+		hw->flags |= I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE;
+
 	status = i40e_init_nvm(hw);
 	return status;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 875a8cc..58e384a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -290,9 +290,18 @@ static i40e_status i40e_read_nvm_word_aq(struct i40e_hw *hw, u16 offset,
 i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 			       u16 *data)
 {
-	if (hw->mac.type == I40E_MAC_X722)
-		return i40e_read_nvm_word_aq(hw, offset, data);
-	return i40e_read_nvm_word_srctl(hw, offset, data);
+	enum i40e_status_code ret_code = 0;
+
+	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE) {
+		ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
+		if (!ret_code) {
+			ret_code = i40e_read_nvm_word_aq(hw, offset, data);
+			i40e_release_nvm(hw);
+		}
+	} else {
+		ret_code = i40e_read_nvm_word_srctl(hw, offset, data);
+	}
+	return ret_code;
 }
 
 /**
@@ -397,9 +406,19 @@ read_nvm_buffer_aq_exit:
 i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
 				 u16 *words, u16 *data)
 {
-	if (hw->mac.type == I40E_MAC_X722)
-		return i40e_read_nvm_buffer_aq(hw, offset, words, data);
-	return i40e_read_nvm_buffer_srctl(hw, offset, words, data);
+	enum i40e_status_code ret_code = 0;
+
+	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE) {
+		ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
+		if (!ret_code) {
+			ret_code = i40e_read_nvm_buffer_aq(hw, offset, words,
+							   data);
+			i40e_release_nvm(hw);
+		}
+	} else {
+		ret_code = i40e_read_nvm_buffer_srctl(hw, offset, words, data);
+	}
+	return ret_code;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9c4a457..f631ca0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -544,6 +544,9 @@ struct i40e_hw {
 	struct i40e_dcbx_config remote_dcbx_config; /* Peer Cfg */
 	struct i40e_dcbx_config desired_dcbx_config; /* CEE Desired Cfg */
 
+#define I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE BIT_ULL(0)
+	u64 flags;
+
 	/* debug mask */
 	u32 debug_mask;
 	char err_str[16];
-- 
2.4.3
