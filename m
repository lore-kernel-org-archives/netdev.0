From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 5/9] ixgbe: Use function pointer for ixgbe_acquire/release_swfw_sync()
Date: Wed,  4 May 2011 12:30:37 -0700
Message-ID: <1304537441-2056-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415Ab1EDTar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:47 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Change remaining direct calls to function pointers.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |    3 +--
 drivers/net/ixgbe/ixgbe_phy.c   |   10 +++++-----
 drivers/net/ixgbe/ixgbe_x540.c  |    2 +-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index d1cda36..5b8e17e 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -110,7 +110,6 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 
 		ret_val = ixgbe_get_sfp_init_sequence_offsets(hw, &list_offset,
 		                                              &data_offset);
-
 		if (ret_val != 0)
 			goto setup_sfp_out;
 
@@ -130,7 +129,7 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 		}
 
 		/* Release the semaphore */
-		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
+		hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
 		/*
 		 * Delay obtaining semaphore again to allow FW access,
 		 * semaphore_delay is in ms usleep_range needs us.
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index edcaaeb..735f686 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1222,7 +1222,7 @@ s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 		swfw_mask = IXGBE_GSSR_PHY0_SM;
 
 	do {
-		if (ixgbe_acquire_swfw_sync(hw, swfw_mask) != 0) {
+		if (hw->mac.ops.acquire_swfw_sync(hw, swfw_mask) != 0) {
 			status = IXGBE_ERR_SWFW_SYNC;
 			goto read_byte_out;
 		}
@@ -1269,7 +1269,7 @@ s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 		break;
 
 fail:
-		ixgbe_release_swfw_sync(hw, swfw_mask);
+		hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 		msleep(100);
 		ixgbe_i2c_bus_clear(hw);
 		retry++;
@@ -1280,7 +1280,7 @@ fail:
 
 	} while (retry < max_retry);
 
-	ixgbe_release_swfw_sync(hw, swfw_mask);
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 
 read_byte_out:
 	return status;
@@ -1308,7 +1308,7 @@ s32 ixgbe_write_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 	else
 		swfw_mask = IXGBE_GSSR_PHY0_SM;
 
-	if (ixgbe_acquire_swfw_sync(hw, swfw_mask) != 0) {
+	if (hw->mac.ops.acquire_swfw_sync(hw, swfw_mask) != 0) {
 		status = IXGBE_ERR_SWFW_SYNC;
 		goto write_byte_out;
 	}
@@ -1352,7 +1352,7 @@ fail:
 			hw_dbg(hw, "I2C byte write error.\n");
 	} while (retry < max_retry);
 
-	ixgbe_release_swfw_sync(hw, swfw_mask);
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 
 write_byte_out:
 	return status;
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 75c6465..179ee82 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -318,7 +318,7 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 	else
 		status = IXGBE_ERR_SWFW_SYNC;
 
-	ixgbe_release_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM);
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
 }
 
-- 
1.7.4.4

