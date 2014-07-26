From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: Fix spurious release of semaphore in EEPROM access
Date: Fri, 25 Jul 2014 21:45:12 -0700
Message-ID: <1406349922-9883-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57220 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbaGZEp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:26 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Failure to acquire the semaphore would lead to a spurious release
of the semaphore in several functions. Do not release a semaphore
that you did not get.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 123 +++++++++++---------------
 1 file changed, 53 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 942ad13..efdb517 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -258,13 +258,12 @@ static s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
-	s32 status = 0;
+	s32 status;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
-	    0)
-		status = ixgbe_read_eerd_generic(hw, offset, data);
-	else
-		status = IXGBE_ERR_SWFW_SYNC;
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return IXGBE_ERR_SWFW_SYNC;
+
+	status = ixgbe_read_eerd_generic(hw, offset, data);
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
@@ -282,14 +281,12 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 static s32 ixgbe_read_eerd_buffer_X540(struct ixgbe_hw *hw,
 				       u16 offset, u16 words, u16 *data)
 {
-	s32 status = 0;
+	s32 status;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
-	    0)
-		status = ixgbe_read_eerd_buffer_generic(hw, offset,
-							words, data);
-	else
-		status = IXGBE_ERR_SWFW_SYNC;
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return IXGBE_ERR_SWFW_SYNC;
+
+	status = ixgbe_read_eerd_buffer_generic(hw, offset, words, data);
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
@@ -305,12 +302,12 @@ static s32 ixgbe_read_eerd_buffer_X540(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 {
-	s32 status = 0;
+	s32 status;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0)
-		status = ixgbe_write_eewr_generic(hw, offset, data);
-	else
-		status = IXGBE_ERR_SWFW_SYNC;
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return IXGBE_ERR_SWFW_SYNC;
+
+	status = ixgbe_write_eewr_generic(hw, offset, data);
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
@@ -328,14 +325,12 @@ static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 static s32 ixgbe_write_eewr_buffer_X540(struct ixgbe_hw *hw,
 					u16 offset, u16 words, u16 *data)
 {
-	s32 status = 0;
+	s32 status;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
-	    0)
-		status = ixgbe_write_eewr_buffer_generic(hw, offset,
-							 words, data);
-	else
-		status = IXGBE_ERR_SWFW_SYNC;
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return IXGBE_ERR_SWFW_SYNC;
+
+	status = ixgbe_write_eewr_buffer_generic(hw, offset, words, data);
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
@@ -430,44 +425,37 @@ static s32 ixgbe_validate_eeprom_checksum_X540(struct ixgbe_hw *hw,
 	u16 checksum;
 	u16 read_checksum = 0;
 
-	/*
-	 * Read the first word from the EEPROM. If this times out or fails, do
+	/* Read the first word from the EEPROM. If this times out or fails, do
 	 * not continue or we could be in for a very long wait while every
 	 * EEPROM read fails
 	 */
 	status = hw->eeprom.ops.read(hw, 0, &checksum);
-
-	if (status != 0) {
+	if (status) {
 		hw_dbg(hw, "EEPROM read failed\n");
-		goto out;
+		return status;
 	}
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
-		checksum = hw->eeprom.ops.calc_checksum(hw);
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return IXGBE_ERR_SWFW_SYNC;
 
-		/*
-		 * Do not use hw->eeprom.ops.read because we do not want to take
-		 * the synchronization semaphores twice here.
-		 */
-		ixgbe_read_eerd_generic(hw, IXGBE_EEPROM_CHECKSUM,
-					&read_checksum);
-
-		/*
-		 * Verify read checksum from EEPROM is the same as
-		 * calculated checksum
-		 */
-		if (read_checksum != checksum)
-			status = IXGBE_ERR_EEPROM_CHECKSUM;
+	checksum = hw->eeprom.ops.calc_checksum(hw);
 
-		/* If the user cares, return the calculated checksum */
-		if (checksum_val)
-			*checksum_val = checksum;
-	} else {
-		status = IXGBE_ERR_SWFW_SYNC;
-	}
+	/* Do not use hw->eeprom.ops.read because we do not want to take
+	 * the synchronization semaphores twice here.
+	 */
+	status = ixgbe_read_eerd_generic(hw, IXGBE_EEPROM_CHECKSUM,
+					 &read_checksum);
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
-out:
+
+	/* If the user cares, return the calculated checksum */
+	if (checksum_val)
+		*checksum_val = checksum;
+
+	/* Verify read and calculated checksums are the same */
+	if (read_checksum != checksum)
+		return IXGBE_ERR_EEPROM_CHECKSUM;
+
 	return status;
 }
 
@@ -484,34 +472,29 @@ static s32 ixgbe_update_eeprom_checksum_X540(struct ixgbe_hw *hw)
 	s32 status;
 	u16 checksum;
 
-	/*
-	 * Read the first word from the EEPROM. If this times out or fails, do
+	/* Read the first word from the EEPROM. If this times out or fails, do
 	 * not continue or we could be in for a very long wait while every
 	 * EEPROM read fails
 	 */
 	status = hw->eeprom.ops.read(hw, 0, &checksum);
-
-	if (status != 0)
+	if (status) {
 		hw_dbg(hw, "EEPROM read failed\n");
+		return status;
+	}
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
-		checksum = hw->eeprom.ops.calc_checksum(hw);
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM))
+		return  IXGBE_ERR_SWFW_SYNC;
 
-		/*
-		 * Do not use hw->eeprom.ops.write because we do not want to
-		 * take the synchronization semaphores twice here.
-		 */
-		status = ixgbe_write_eewr_generic(hw, IXGBE_EEPROM_CHECKSUM,
-						  checksum);
+	checksum = hw->eeprom.ops.calc_checksum(hw);
 
-	if (status == 0)
+	/* Do not use hw->eeprom.ops.write because we do not want to
+	 * take the synchronization semaphores twice here.
+	 */
+	status = ixgbe_write_eewr_generic(hw, IXGBE_EEPROM_CHECKSUM, checksum);
+	if (!status)
 		status = ixgbe_update_flash_X540(hw);
-	else
-		status = IXGBE_ERR_SWFW_SYNC;
-	}
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
-
 	return status;
 }
 
-- 
1.9.3
