From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] ixgbe: Add function ixgbe_reset_pipeline_82599
Date: Fri, 19 Oct 2012 23:26:05 -0700
Message-ID: <1350714367-24208-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311Ab2JTG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:40 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds a function that forces a full pipeline reset.  This
function will be used in following patches to completely reset the PHY
during resets.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  | 44 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  1 +
 2 files changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 1077cb2..b527813 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2080,6 +2080,50 @@ static s32 ixgbe_read_eeprom_82599(struct ixgbe_hw *hw,
 	return ret_val;
 }
 
+/**
+ * ixgbe_reset_pipeline_82599 - perform pipeline reset
+ *
+ * @hw: pointer to hardware structure
+ *
+ * Reset pipeline by asserting Restart_AN together with LMS change to ensure
+ * full pipeline reset.  Note - We must hold the SW/FW semaphore before writing
+ * to AUTOC, so this function assumes the semaphore is held.
+ **/
+s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw)
+{
+	s32 i, autoc_reg, ret_val;
+	s32 anlp1_reg = 0;
+
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+
+	/* Write AUTOC register with toggled LMS[2] bit and Restart_AN */
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg ^ IXGBE_AUTOC_LMS_1G_AN);
+
+	/* Wait for AN to leave state 0 */
+	for (i = 0; i < 10; i++) {
+		usleep_range(4000, 8000);
+		anlp1_reg = IXGBE_READ_REG(hw, IXGBE_ANLP1);
+		if (anlp1_reg & IXGBE_ANLP1_AN_STATE_MASK)
+			break;
+	}
+
+	if (!(anlp1_reg & IXGBE_ANLP1_AN_STATE_MASK)) {
+		hw_dbg(hw, "auto negotiation not completed\n");
+		ret_val = IXGBE_ERR_RESET_FAILED;
+		goto reset_pipeline_out;
+	}
+
+	ret_val = 0;
+
+reset_pipeline_out:
+	/* Write AUTOC register with original LMS field and Restart_AN */
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return ret_val;
+}
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index d813d11..587db47 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -107,6 +107,7 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw);
 
 void ixgbe_set_rxpba_generic(struct ixgbe_hw *hw, int num_pb,
 			     u32 headroom, int strategy);
+s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
 
 #define IXGBE_I2C_THERMAL_SENSOR_ADDR	0xF8
 #define IXGBE_EMC_INTERNAL_DATA		0x00
-- 
1.7.11.7
