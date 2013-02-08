From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] igb: Intialize MAC function pointers
Date: Fri,  8 Feb 2013 02:39:16 -0800
Message-ID: <1360319958-10497-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57761 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946211Ab3BHKjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 05:39:36 -0500
In-Reply-To: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch initializes MAC function pointers for device configuration.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 61 ++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index e59fc9b..8604013 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -332,6 +332,67 @@ s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
 	return 0;
 }
 
+/**
+ *  igb_init_mac_params_82575 - Init MAC func ptrs.
+ *  @hw: pointer to the HW structure
+ **/
+static s32 igb_init_mac_params_82575(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
+
+	/* Set mta register count */
+	mac->mta_reg_count = 128;
+	/* Set rar entry count */
+	switch (mac->type) {
+	case e1000_82576:
+		mac->rar_entry_count = E1000_RAR_ENTRIES_82576;
+		break;
+	case e1000_82580:
+		mac->rar_entry_count = E1000_RAR_ENTRIES_82580;
+		break;
+	case e1000_i350:
+		mac->rar_entry_count = E1000_RAR_ENTRIES_I350;
+		break;
+	default:
+		mac->rar_entry_count = E1000_RAR_ENTRIES_82575;
+		break;
+	}
+	/* reset */
+	if (mac->type >= e1000_82580)
+		mac->ops.reset_hw = igb_reset_hw_82580;
+	else
+		mac->ops.reset_hw = igb_reset_hw_82575;
+
+	if (mac->type >= e1000_i210) {
+		mac->ops.acquire_swfw_sync = igb_acquire_swfw_sync_i210;
+		mac->ops.release_swfw_sync = igb_release_swfw_sync_i210;
+
+	} else {
+		mac->ops.acquire_swfw_sync = igb_acquire_swfw_sync_82575;
+		mac->ops.release_swfw_sync = igb_release_swfw_sync_82575;
+	}
+
+	/* Set if part includes ASF firmware */
+	mac->asf_firmware_present = true;
+	/* Set if manageability features are enabled. */
+	mac->arc_subsystem_valid =
+		(rd32(E1000_FWSM) & E1000_FWSM_MODE_MASK)
+			? true : false;
+	/* enable EEE on i350 parts and later parts */
+	if (mac->type >= e1000_i350)
+		dev_spec->eee_disable = false;
+	else
+		dev_spec->eee_disable = true;
+	/* physical interface link setup */
+	mac->ops.setup_physical_interface =
+		(hw->phy.media_type == e1000_media_type_copper)
+			? igb_setup_copper_link_82575
+			: igb_setup_serdes_link_82575;
+
+	return 0;
+}
+
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-- 
1.7.11.7
