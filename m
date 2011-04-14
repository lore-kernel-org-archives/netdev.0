From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 17/24] ixgbe: fix 82599 KR downshift coexistence with LESM FW module
Date: Wed, 13 Apr 2011 18:02:13 -0700
Message-ID: <1302742940-22141-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15002 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758168Ab1DNBCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:36 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Disable KR to KX4/KX downshift on 82599 backplane devices when
LESM (Link Establishment State Machine) is enabled in FW. Those
features cannot co-exist as they both manipulate the same registers.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phillip Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |   46 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_type.h  |    3 ++
 2 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 09934a8..d195278 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -61,6 +61,7 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
                                          bool autoneg,
                                          bool autoneg_wait_to_complete);
 static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
+static bool ixgbe_verify_lesm_fw_enabled_82599(struct ixgbe_hw *hw);
 
 static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 {
@@ -86,7 +87,8 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 		if ((mac->ops.get_media_type(hw) ==
 		     ixgbe_media_type_backplane) &&
 		    (hw->phy.smart_speed == ixgbe_smart_speed_auto ||
-		     hw->phy.smart_speed == ixgbe_smart_speed_on))
+		     hw->phy.smart_speed == ixgbe_smart_speed_on) &&
+		     !ixgbe_verify_lesm_fw_enabled_82599(hw))
 			mac->ops.setup_link = &ixgbe_setup_mac_link_smartspeed;
 		else
 			mac->ops.setup_link = &ixgbe_setup_mac_link_82599;
@@ -2028,6 +2030,48 @@ fw_version_out:
 	return status;
 }
 
+/**
+ *  ixgbe_verify_lesm_fw_enabled_82599 - Checks LESM FW module state.
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns true if the LESM FW module is present and enabled. Otherwise
+ *  returns false. Smart Speed must be disabled if LESM FW module is enabled.
+ **/
+static bool ixgbe_verify_lesm_fw_enabled_82599(struct ixgbe_hw *hw)
+{
+	bool lesm_enabled = false;
+	u16 fw_offset, fw_lesm_param_offset, fw_lesm_state;
+	s32 status;
+
+	/* get the offset to the Firmware Module block */
+	status = hw->eeprom.ops.read(hw, IXGBE_FW_PTR, &fw_offset);
+
+	if ((status != 0) ||
+	    (fw_offset == 0) || (fw_offset == 0xFFFF))
+		goto out;
+
+	/* get the offset to the LESM Parameters block */
+	status = hw->eeprom.ops.read(hw, (fw_offset +
+				     IXGBE_FW_LESM_PARAMETERS_PTR),
+				     &fw_lesm_param_offset);
+
+	if ((status != 0) ||
+	    (fw_lesm_param_offset == 0) || (fw_lesm_param_offset == 0xFFFF))
+		goto out;
+
+	/* get the lesm state word */
+	status = hw->eeprom.ops.read(hw, (fw_lesm_param_offset +
+				     IXGBE_FW_LESM_STATE_1),
+				     &fw_lesm_state);
+
+	if ((status == 0) &&
+	    (fw_lesm_state & IXGBE_FW_LESM_STATE_ENABLED))
+		lesm_enabled = true;
+
+out:
+	return lesm_enabled;
+}
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index cd1c2b6..e00356a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1625,6 +1625,9 @@
 #define IXGBE_SAN_MAC_ADDR_PORT1_OFFSET  0x3
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
 #define IXGBE_DEVICE_CAPS_FCOE_OFFLOADS  0x2
+#define IXGBE_FW_LESM_PARAMETERS_PTR     0x2
+#define IXGBE_FW_LESM_STATE_1            0x1
+#define IXGBE_FW_LESM_STATE_ENABLED      0x8000 /* LESM Enable bit */
 #define IXGBE_FW_PASSTHROUGH_PATCH_CONFIG_PTR   0x4
 #define IXGBE_FW_PATCH_VERSION_4   0x7
 
-- 
1.7.4.2

