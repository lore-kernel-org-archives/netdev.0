From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] ixgbe: cache AUTOC reads
Date: Thu, 25 Apr 2013 21:57:09 -0700
Message-ID: <1366952231-16727-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28519 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067Ab3DZE5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:19 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch removes majority of the AUTOC register reads by using a cached
value instead.

The reason for this change is to avoid writing corrupted values to AUTOC
due to bad FW.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 40 +++++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 2 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 3f79242..c4c5e87 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -167,9 +167,9 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 		}
 
 		/* Restart DSP and set SFI mode */
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (IXGBE_READ_REG(hw,
-				IXGBE_AUTOC) | IXGBE_AUTOC_LMS_10G_SERIAL));
-
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, ((hw->mac.orig_autoc) |
+				IXGBE_AUTOC_LMS_10G_SERIAL));
+		hw->mac.cached_autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 		ret_val = ixgbe_reset_pipeline_82599(hw);
 
 		if (got_lock) {
@@ -803,12 +803,9 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 				      bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
-	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 autoc, pma_pmd_1g, link_mode, start_autoc;
 	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
-	u32 start_autoc = autoc;
 	u32 orig_autoc = 0;
-	u32 link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
-	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
 	u32 pma_pmd_10g_serial = autoc2 & IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK;
 	u32 links_reg;
 	u32 i;
@@ -831,9 +828,14 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 
 	/* Use stored value (EEPROM defaults) of AUTOC to find KR/KX4 support*/
 	if (hw->mac.orig_link_settings_stored)
-		orig_autoc = hw->mac.orig_autoc;
+		autoc = hw->mac.orig_autoc;
 	else
-		orig_autoc = autoc;
+		autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+
+	orig_autoc = autoc;
+	start_autoc = hw->mac.cached_autoc;
+	link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
+	pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
 
 	if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
 	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
@@ -887,6 +889,7 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 
 		/* Restart link */
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
+		hw->mac.cached_autoc = autoc;
 		ixgbe_reset_pipeline_82599(hw);
 
 		if (got_lock)
@@ -958,7 +961,7 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 {
 	ixgbe_link_speed link_speed;
 	s32 status;
-	u32 ctrl, i, autoc, autoc2;
+	u32 ctrl, i, autoc2;
 	u32 curr_lms;
 	bool link_up = false;
 
@@ -991,8 +994,12 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	if (hw->phy.reset_disable == false && hw->phy.ops.reset != NULL)
 		hw->phy.ops.reset(hw);
 
-	/* remember AUTOC LMS from before we reset */
-	curr_lms = IXGBE_READ_REG(hw, IXGBE_AUTOC) & IXGBE_AUTOC_LMS_MASK;
+	/* remember AUTOC from before we reset */
+	if (hw->mac.cached_autoc)
+		curr_lms = hw->mac.cached_autoc & IXGBE_AUTOC_LMS_MASK;
+	else
+		curr_lms = IXGBE_READ_REG(hw, IXGBE_AUTOC) &
+			   IXGBE_AUTOC_LMS_MASK;
 
 mac_reset_top:
 	/*
@@ -1042,10 +1049,10 @@ mac_reset_top:
 	 * stored off yet.  Otherwise restore the stored original
 	 * values since the reset operation sets back to defaults.
 	 */
-	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	hw->mac.cached_autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
 	if (hw->mac.orig_link_settings_stored == false) {
-		hw->mac.orig_autoc = autoc;
+		hw->mac.orig_autoc = hw->mac.cached_autoc;
 		hw->mac.orig_autoc2 = autoc2;
 		hw->mac.orig_link_settings_stored = true;
 	} else {
@@ -1062,7 +1069,7 @@ mac_reset_top:
 				(hw->mac.orig_autoc & ~IXGBE_AUTOC_LMS_MASK) |
 				curr_lms;
 
-		if (autoc != hw->mac.orig_autoc) {
+		if (hw->mac.cached_autoc != hw->mac.orig_autoc) {
 			/* Need SW/FW semaphore around AUTOC writes if LESM is
 			 * on, likewise reset_pipeline requires us to hold
 			 * this lock as it also writes to AUTOC.
@@ -1078,6 +1085,7 @@ mac_reset_top:
 			}
 
 			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, hw->mac.orig_autoc);
+			hw->mac.cached_autoc = hw->mac.orig_autoc;
 			ixgbe_reset_pipeline_82599(hw);
 
 			if (got_lock)
@@ -2181,7 +2189,7 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw)
 	s32 i, autoc_reg, ret_val;
 	s32 anlp1_reg = 0;
 
-	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc_reg = hw->mac.cached_autoc;
 	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 
 	/* Write AUTOC register with toggled LMS[2] bit and Restart_AN */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6d70665..7480f7b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2928,6 +2928,7 @@ struct ixgbe_mac_info {
 	u32                             max_tx_queues;
 	u32                             max_rx_queues;
 	u32                             orig_autoc;
+	u32                             cached_autoc;
 	u32                             orig_autoc2;
 	bool                            orig_link_settings_stored;
 	bool                            autotry_restart;
-- 
1.7.11.7
