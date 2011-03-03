From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 23/24] ixgbe: add function pointer for semaphore function
Date: Thu,  3 Mar 2011 05:03:48 -0800
Message-ID: <1299157429-15878-24-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758217Ab1CCNE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:27 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The X540 devices grabs semaphores differently than 82599 and 82598
devices do.  They do however also grab them in allot of the same
functions.  So I'm adding a new MAC operation function pointer to
allow us to use the correct function based on our MAC type.  I'm also
changing all the semaphore calls to use this new function pointer.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |    2 ++
 drivers/net/ixgbe/ixgbe_82599.c  |    6 +++++-
 drivers/net/ixgbe/ixgbe_common.c |    4 ++--
 drivers/net/ixgbe/ixgbe_phy.c    |    8 ++++----
 drivers/net/ixgbe/ixgbe_type.h   |    2 ++
 drivers/net/ixgbe/ixgbe_x540.c   |    6 ++++--
 6 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 8f6205e..2da629a 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1201,6 +1201,8 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.clear_vfta		= &ixgbe_clear_vfta_82598,
 	.set_vfta		= &ixgbe_set_vfta_82598,
 	.fc_enable		= &ixgbe_fc_enable_82598,
+	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
+	.release_swfw_sync      = &ixgbe_release_swfw_sync,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 3d40e68..8f7c6bd 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -112,7 +112,8 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 			goto setup_sfp_out;
 
 		/* PHY config will finish before releasing the semaphore */
-		ret_val = ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
+		ret_val = hw->mac.ops.acquire_swfw_sync(hw,
+		                                        IXGBE_GSSR_MAC_CSR_SM);
 		if (ret_val != 0) {
 			ret_val = IXGBE_ERR_SWFW_SYNC;
 			goto setup_sfp_out;
@@ -2044,6 +2045,9 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.setup_sfp              = &ixgbe_setup_sfp_modules_82599,
 	.set_mac_anti_spoofing  = &ixgbe_set_mac_anti_spoofing,
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
+	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
+	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 33f568c..bd14ea4 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -745,7 +745,7 @@ static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 	u32 eec;
 	u32 i;
 
-	if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
 		status = IXGBE_ERR_SWFW_SYNC;
 
 	if (status == 0) {
@@ -768,7 +768,7 @@ static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 			IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
 			hw_dbg(hw, "Could not acquire EEPROM grant\n");
 
-			ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+			hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 			status = IXGBE_ERR_EEPROM;
 		}
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 16b5f49..f4569e8 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -205,7 +205,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 	else
 		gssr = IXGBE_GSSR_PHY0_SM;
 
-	if (ixgbe_acquire_swfw_sync(hw, gssr) != 0)
+	if (hw->mac.ops.acquire_swfw_sync(hw, gssr) != 0)
 		status = IXGBE_ERR_SWFW_SYNC;
 
 	if (status == 0) {
@@ -277,7 +277,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			}
 		}
 
-		ixgbe_release_swfw_sync(hw, gssr);
+		hw->mac.ops.release_swfw_sync(hw, gssr);
 	}
 
 	return status;
@@ -303,7 +303,7 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 	else
 		gssr = IXGBE_GSSR_PHY0_SM;
 
-	if (ixgbe_acquire_swfw_sync(hw, gssr) != 0)
+	if (hw->mac.ops.acquire_swfw_sync(hw, gssr) != 0)
 		status = IXGBE_ERR_SWFW_SYNC;
 
 	if (status == 0) {
@@ -370,7 +370,7 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			}
 		}
 
-		ixgbe_release_swfw_sync(hw, gssr);
+		hw->mac.ops.release_swfw_sync(hw, gssr);
 	}
 
 	return status;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 8e0a213..e940f23 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2495,6 +2495,8 @@ struct ixgbe_mac_operations {
 	s32 (*write_analog_reg8)(struct ixgbe_hw*, u32, u8);
 	s32 (*setup_sfp)(struct ixgbe_hw *);
 	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
+	s32 (*acquire_swfw_sync)(struct ixgbe_hw *, u16);
+	void (*release_swfw_sync)(struct ixgbe_hw *, u16);
 
 	/* Link */
 	void (*disable_tx_laser)(struct ixgbe_hw *);
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 11cb136..eb04773 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -287,7 +287,7 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
 	s32 status;
 
-	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM) == 0)
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0)
 		status = ixgbe_read_eerd_generic(hw, offset, data);
 	else
 		status = IXGBE_ERR_SWFW_SYNC;
@@ -320,7 +320,7 @@ static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 	       (data << IXGBE_EEPROM_RW_REG_DATA) |
 	       IXGBE_EEPROM_RW_REG_START;
 
-	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM) == 0) {
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
 		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
 		if (status != 0) {
 			hw_dbg(hw, "Eeprom write EEWR timed out\n");
@@ -695,6 +695,8 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.setup_sfp              = NULL,
 	.set_mac_anti_spoofing  = &ixgbe_set_mac_anti_spoofing,
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
+	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync_X540,
+	.release_swfw_sync      = &ixgbe_release_swfw_sync_X540,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
-- 
1.7.4

