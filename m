From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: Fix 1G link WoL
Date: Wed, 17 Apr 2013 23:34:00 -0700
Message-ID: <1366266841-12466-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53682 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965506Ab3DRGeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 02:34:09 -0400
In-Reply-To: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We reset during the shutdown path which will reset AUTOC register.  This
would change LMS to 10G.  If we were currently linked at 1G we will lose
link, which is a bad thing if we wanted WoL to work.  For the fix I needed
to know if WoL is supported so I created a new bool in the ixgbe_hw struct.
If this is set we will not allow the reset to change the current LMS value
in AUTOC.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 5 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 1 +
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index b6289f1..7946da9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1051,8 +1051,11 @@ mac_reset_top:
 		/* If MNG FW is running on a multi-speed device that
 		 * doesn't autoneg with out driver support we need to
 		 * leave LMS in the state it was before we MAC reset.
+		 * Likewise if we support WoL we don't want change the
+		 * LMS state either.
 		 */
-		if (hw->phy.multispeed_fiber && hw->mng_fw_enabled)
+		if ((hw->phy.multispeed_fiber && hw->mng_fw_enabled) ||
+		    hw->wol_supported)
 			hw->mac.orig_autoc =
 				(hw->mac.orig_autoc & ~IXGBE_AUTOC_LMS_MASK) |
 				curr_lms;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ac6e464..25c0e35 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7526,7 +7526,9 @@ skip_sriov:
 	/* WOL not supported for all devices */
 	adapter->wol = 0;
 	hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
-	if (ixgbe_wol_supported(adapter, pdev->device, pdev->subsystem_device))
+	hw->wol_supported = ixgbe_wol_supported(adapter, pdev->device,
+						pdev->subsystem_device);
+	if (hw->wol_supported)
 		adapter->wol = IXGBE_WUFC_MAG;
 
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 200b1a8..155a793 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2998,6 +2998,7 @@ struct ixgbe_hw {
 	bool				force_full_reset;
 	bool				allow_unsupported_sfp;
 	bool				mng_fw_enabled;
+	bool				wol_supported;
 };
 
 struct ixgbe_info {
-- 
1.7.11.7
