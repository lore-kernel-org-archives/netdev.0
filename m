From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 21/24] ixgbe: cleanup handling of I2C interface to PHY
Date: Thu,  3 Mar 2011 05:03:46 -0800
Message-ID: <1299157429-15878-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758215Ab1CCNE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:26 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The I2C interface was not being correctly locked down per port.  As such
this can lead to race conditions that can cause issues.  This patch cleans
up the handling to make certain we are not experiencing racy I2C access.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_phy.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index ebd6e44..16b5f49 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -858,6 +858,9 @@ err_read_i2c_eeprom:
  *  @hw: pointer to hardware structure
  *  @list_offset: offset to the SFP ID list
  *  @data_offset: offset to the SFP data block
+ *
+ *  Checks the MAC's EEPROM to see if it supports a given SFP+ module type, if
+ *  so it returns the offsets to the phy init sequence block.
  **/
 s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
                                         u16 *list_offset,
@@ -972,11 +975,22 @@ s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
                                 u8 dev_addr, u8 *data)
 {
 	s32 status = 0;
-	u32 max_retry = 1;
+	u32 max_retry = 10;
 	u32 retry = 0;
+	u16 swfw_mask = 0;
 	bool nack = 1;
 
+	if (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)
+		swfw_mask = IXGBE_GSSR_PHY1_SM;
+	else
+		swfw_mask = IXGBE_GSSR_PHY0_SM;
+
 	do {
+		if (ixgbe_acquire_swfw_sync(hw, swfw_mask) != 0) {
+			status = IXGBE_ERR_SWFW_SYNC;
+			goto read_byte_out;
+		}
+
 		ixgbe_i2c_start(hw);
 
 		/* Device Address and write indication */
@@ -1019,6 +1033,8 @@ s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 		break;
 
 fail:
+		ixgbe_release_swfw_sync(hw, swfw_mask);
+		msleep(100);
 		ixgbe_i2c_bus_clear(hw);
 		retry++;
 		if (retry < max_retry)
@@ -1028,6 +1044,9 @@ fail:
 
 	} while (retry < max_retry);
 
+	ixgbe_release_swfw_sync(hw, swfw_mask);
+
+read_byte_out:
 	return status;
 }
 
@@ -1046,6 +1065,17 @@ s32 ixgbe_write_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 	s32 status = 0;
 	u32 max_retry = 1;
 	u32 retry = 0;
+	u16 swfw_mask = 0;
+
+	if (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)
+		swfw_mask = IXGBE_GSSR_PHY1_SM;
+	else
+		swfw_mask = IXGBE_GSSR_PHY0_SM;
+
+	if (ixgbe_acquire_swfw_sync(hw, swfw_mask) != 0) {
+		status = IXGBE_ERR_SWFW_SYNC;
+		goto write_byte_out;
+	}
 
 	do {
 		ixgbe_i2c_start(hw);
@@ -1086,6 +1116,9 @@ fail:
 			hw_dbg(hw, "I2C byte write error.\n");
 	} while (retry < max_retry);
 
+	ixgbe_release_swfw_sync(hw, swfw_mask);
+
+write_byte_out:
 	return status;
 }
 
@@ -1404,6 +1437,8 @@ static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw)
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
 	u32 i;
 
+	ixgbe_i2c_start(hw);
+
 	ixgbe_set_i2c_data(hw, &i2cctl, 1);
 
 	for (i = 0; i < 9; i++) {
@@ -1418,6 +1453,8 @@ static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw)
 		udelay(IXGBE_I2C_T_LOW);
 	}
 
+	ixgbe_i2c_start(hw);
+
 	/* Put the i2c bus back to default state */
 	ixgbe_i2c_stop(hw);
 }
-- 
1.7.4

