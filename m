From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/24] ixgbe: cleanup logic related to HW semaphores
Date: Thu,  3 Mar 2011 05:03:31 -0800
Message-ID: <1299157429-15878-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24647 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758190Ab1CCNEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:20 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change cleans up much of the logic related to the hardware semaphores
on the adapters. There were a number of issues with timings that needed to
be addressed.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   42 +++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index ebbda7d..345c32e 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -603,7 +603,6 @@ s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
 		ixgbe_shift_out_eeprom_bits(hw, data, 16);
 		ixgbe_standby_eeprom(hw);
 
-		msleep(hw->eeprom.semaphore_delay);
 		/* Done with writing - release the EEPROM */
 		ixgbe_release_eeprom(hw);
 	}
@@ -747,7 +746,7 @@ s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
 static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
-	u32 eec = 0;
+	u32 eec;
 	u32 i;
 
 	if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
@@ -776,15 +775,15 @@ static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 			ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 			status = IXGBE_ERR_EEPROM;
 		}
-	}
 
-	/* Setup EEPROM for Read/Write */
-	if (status == 0) {
-		/* Clear CS and SK */
-		eec &= ~(IXGBE_EEC_CS | IXGBE_EEC_SK);
-		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
-		IXGBE_WRITE_FLUSH(hw);
-		udelay(1);
+		/* Setup EEPROM for Read/Write */
+		if (status == 0) {
+			/* Clear CS and SK */
+			eec &= ~(IXGBE_EEC_CS | IXGBE_EEC_SK);
+			IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+			IXGBE_WRITE_FLUSH(hw);
+			udelay(1);
+		}
 	}
 	return status;
 }
@@ -798,13 +797,10 @@ static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_EEPROM;
-	u32 timeout;
+	u32 timeout = 2000;
 	u32 i;
 	u32 swsm;
 
-	/* Set timeout value based on size of EEPROM */
-	timeout = hw->eeprom.word_size + 1;
-
 	/* Get SMBI software semaphore between device drivers first */
 	for (i = 0; i < timeout; i++) {
 		/*
@@ -816,7 +812,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 			status = 0;
 			break;
 		}
-		msleep(1);
+		udelay(50);
 	}
 
 	/* Now get the semaphore between SW/FW through the SWESMBI bit */
@@ -844,11 +840,14 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		 * was not granted because we don't have access to the EEPROM
 		 */
 		if (i >= timeout) {
-			hw_dbg(hw, "Driver can't access the Eeprom - Semaphore "
+			hw_dbg(hw, "SWESMBI Software EEPROM semaphore "
 			       "not granted.\n");
 			ixgbe_release_eeprom_semaphore(hw);
 			status = IXGBE_ERR_EEPROM;
 		}
+	} else {
+		hw_dbg(hw, "Software semaphore SMBI between device drivers "
+		       "not granted.\n");
 	}
 
 	return status;
@@ -1081,10 +1080,13 @@ static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
 
 	ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+
+	/* Delay before attempt to obtain semaphore again to allow FW access */
+	msleep(hw->eeprom.semaphore_delay);
 }
 
 /**
- *  ixgbe_calc_eeprom_checksum - Calculates and returns the checksum
+ *  ixgbe_calc_eeprom_checksum_generic - Calculates and returns the checksum
  *  @hw: pointer to hardware structure
  **/
 u16 ixgbe_calc_eeprom_checksum_generic(struct ixgbe_hw *hw)
@@ -2206,6 +2208,10 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 	s32 timeout = 200;
 
 	while (timeout) {
+		/*
+		 * SW EEPROM semaphore bit is used for access to all
+		 * SW_FW_SYNC/GSSR bits (not just EEPROM)
+		 */
 		if (ixgbe_get_eeprom_semaphore(hw))
 			return IXGBE_ERR_SWFW_SYNC;
 
@@ -2223,7 +2229,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 	}
 
 	if (!timeout) {
-		hw_dbg(hw, "Driver can't access resource, GSSR timeout.\n");
+		hw_dbg(hw, "Driver can't access resource, SW_FW_SYNC timeout.\n");
 		return IXGBE_ERR_SWFW_SYNC;
 	}
 
-- 
1.7.4

