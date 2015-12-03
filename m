From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/15] ixgbe: Always turn PHY power on when requested
Date: Thu,  3 Dec 2015 03:07:22 -0800
Message-ID: <1449140843-118580-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27448 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933007AbbLCLHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:37 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Instead of inhibiting PHY power control when manageability is
present, only inhibit turning PHY power off when manageability
is present. Consequently, PHY power will always be turned on when
requested. Without this patch, some systems with X540 or X550
devices in some conditions will never get link.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index fb8673d..db0731e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -2393,6 +2393,9 @@ s32 ixgbe_set_copper_phy_power(struct ixgbe_hw *hw, bool on)
 	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_copper)
 		return 0;
 
+	if (!on && ixgbe_mng_present(hw))
+		return 0;
+
 	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_VENDOR_SPECIFIC_1_CONTROL,
 				      IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
 				      &reg);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index b9e9b0c..bf8225c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -57,8 +57,7 @@ s32 ixgbe_get_invariants_X540(struct ixgbe_hw *hw)
 	struct ixgbe_phy_info *phy = &hw->phy;
 
 	/* set_phy_power was set by default to NULL */
-	if (!ixgbe_mng_present(hw))
-		phy->ops.set_phy_power = ixgbe_set_copper_phy_power;
+	phy->ops.set_phy_power = ixgbe_set_copper_phy_power;
 
 	mac->mcft_size = IXGBE_X540_MC_TBL_SIZE;
 	mac->vft_size = IXGBE_X540_VFT_TBL_SIZE;
-- 
2.5.0
