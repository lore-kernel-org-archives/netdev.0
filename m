From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 15/24] ixgbe: refactor common start_hw code for 82599 and x540
Date: Wed, 13 Apr 2011 18:02:11 -0700
Message-ID: <1302742940-22141-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758152Ab1DNBCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:35 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Factored out the common start_hw code into a new function
ixgbe_start_hw_gen2() so that it can be used by x540 and 82599.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c  |   22 ++++++++++------------
 drivers/net/ixgbe/ixgbe_common.c |   24 ++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h |    1 +
 drivers/net/ixgbe/ixgbe_x540.c   |   24 +++++++++++++++++++++++-
 4 files changed, 58 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 32ad411..09934a8 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1740,30 +1740,28 @@ static s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
  *  ixgbe_start_hw_82599 - Prepare hardware for Tx/Rx
  *  @hw: pointer to hardware structure
  *
- *  Starts the hardware using the generic start_hw function.
- *  Then performs device-specific:
- *  Clears the rate limiter registers.
+ *  Starts the hardware using the generic start_hw function
+ *  and the generation start_hw function.
+ *  Then performs revision-specific operations, if any.
  **/
 static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 {
-	u32 q_num;
-	s32 ret_val;
+	s32 ret_val = 0;
 
 	ret_val = ixgbe_start_hw_generic(hw);
+	if (ret_val != 0)
+		goto out;
 
-	/* Clear the rate limiters */
-	for (q_num = 0; q_num < hw->mac.max_tx_queues; q_num++) {
-		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, q_num);
-		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, 0);
-	}
-	IXGBE_WRITE_FLUSH(hw);
+	ret_val = ixgbe_start_hw_gen2(hw);
+	if (ret_val != 0)
+		goto out;
 
 	/* We need to run link autotry after the driver loads */
 	hw->mac.autotry_restart = true;
 
 	if (ret_val == 0)
 		ret_val = ixgbe_verify_fw_version_82599(hw);
-
+out:
 	return ret_val;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index bcd9529..c66fd95 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -96,6 +96,30 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_start_hw_gen2 - Init sequence for common device family
+ *  @hw: pointer to hw structure
+ *
+ * Performs the init sequence common to the second generation
+ * of 10 GbE devices.
+ * Devices in the second generation:
+ *     82599
+ *     X540
+ **/
+s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
+{
+	u32 i;
+
+	/* Clear the rate limiters */
+	for (i = 0; i < hw->mac.max_tx_queues; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, i);
+		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, 0);
+	}
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
  *  ixgbe_init_hw_generic - Generic hardware initialization
  *  @hw: pointer to hardware structure
  *
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 508f635..2585bf3 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -35,6 +35,7 @@ u32 ixgbe_get_pcie_msix_count_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw);
 s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw);
+s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw);
 s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
 s32 ixgbe_read_pba_string_generic(struct ixgbe_hw *hw, u8 *pba_num,
                                   u32 pba_num_size);
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 7ce3f45..295c170 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -226,6 +226,28 @@ mac_reset_top:
 }
 
 /**
+ *  ixgbe_start_hw_X540 - Prepare hardware for Tx/Rx
+ *  @hw: pointer to hardware structure
+ *
+ *  Starts the hardware using the generic start_hw function
+ *  and the generation start_hw function.
+ *  Then performs revision-specific operations, if any.
+ **/
+static s32 ixgbe_start_hw_X540(struct ixgbe_hw *hw)
+{
+	s32 ret_val = 0;
+
+	ret_val = ixgbe_start_hw_generic(hw);
+	if (ret_val != 0)
+		goto out;
+
+	ret_val = ixgbe_start_hw_gen2(hw);
+
+out:
+	return ret_val;
+}
+
+/**
  *  ixgbe_get_supported_physical_layer_X540 - Returns physical layer type
  *  @hw: pointer to hardware structure
  *
@@ -660,7 +682,7 @@ static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
 static struct ixgbe_mac_operations mac_ops_X540 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_X540,
-	.start_hw               = &ixgbe_start_hw_generic,
+	.start_hw               = &ixgbe_start_hw_X540,
 	.clear_hw_cntrs         = &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type         = &ixgbe_get_media_type_X540,
 	.get_supported_physical_layer =
-- 
1.7.4.2

