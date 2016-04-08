From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] ixgbe: Introduce function to control MDIO speed
Date: Thu,  7 Apr 2016 20:21:09 -0700
Message-ID: <1460085673-87056-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9519 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756998AbcDHDVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:22 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Move code that controls MDIO speed into a new function because
there will be more MACs that need the control.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 3563b86..0d6cbb0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2306,6 +2306,26 @@ static s32 ixgbe_init_ext_t_x550em(struct ixgbe_hw *hw)
 	return status;
 }
 
+/**
+ * ixgbe_set_mdio_speed - Set MDIO clock speed
+ * @hw: pointer to hardware structure
+ */
+static void ixgbe_set_mdio_speed(struct ixgbe_hw *hw)
+{
+	u32 hlreg0;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_X550EM_X_10G_T:
+		/* Config MDIO clock speed before the first MDIO PHY access */
+		hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
+		hlreg0 &= ~IXGBE_HLREG0_MDCSPD;
+		IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
+		break;
+	default:
+		break;
+	}
+}
+
 /**  ixgbe_reset_hw_X550em - Perform hardware reset
  **  @hw: pointer to hardware structure
  **
@@ -2319,7 +2339,6 @@ static s32 ixgbe_reset_hw_X550em(struct ixgbe_hw *hw)
 	s32 status;
 	u32 ctrl = 0;
 	u32 i;
-	u32 hlreg0;
 	bool link_up = false;
 
 	/* Call adapter stop to disable Tx/Rx and clear interrupts */
@@ -2405,11 +2424,7 @@ mac_reset_top:
 	hw->mac.num_rar_entries = 128;
 	hw->mac.ops.init_rx_addrs(hw);
 
-	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_10G_T) {
-		hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
-		hlreg0 &= ~IXGBE_HLREG0_MDCSPD;
-		IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
-	}
+	ixgbe_set_mdio_speed(hw);
 
 	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_SFP)
 		ixgbe_setup_mux_ctl(hw);
-- 
2.5.5
