From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/18] ixgbe: Restore ESDP settings after MAC reset
Date: Tue,  9 Jun 2015 18:10:16 -0700
Message-ID: <1433898629-76729-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56324 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136AbbFJBKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:35 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The I2C mux control relies on the SDP setting in the ESDP register
so it is necessary to restore the value after a MAC reset.  Combine
all this functionality in to a support function.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 38 +++++++++++++++------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index f78cac8..a1d8ab0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -26,6 +26,22 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+/** ixgbe_setup_mux_ctl - Setup ESDP register for I2C mux control
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_setup_mux_ctl(struct ixgbe_hw *hw)
+{
+	u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
+
+	if (hw->bus.lan_id) {
+		esdp &= ~(IXGBE_ESDP_SDP1_NATIVE | IXGBE_ESDP_SDP1);
+		esdp |= IXGBE_ESDP_SDP1_DIR;
+	}
+	esdp &= ~(IXGBE_ESDP_SDP0_NATIVE | IXGBE_ESDP_SDP0_DIR);
+	IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
+	IXGBE_WRITE_FLUSH(hw);
+}
+
 /** ixgbe_identify_phy_x550em - Get PHY type based on device id
  *  @hw: pointer to hardware structure
  *
@@ -33,18 +49,11 @@
  */
 static s32 ixgbe_identify_phy_x550em(struct ixgbe_hw *hw)
 {
-	u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
-
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_X550EM_X_SFP:
 		/* set up for CS4227 usage */
 		hw->phy.phy_semaphore_mask = IXGBE_GSSR_SHARED_I2C_SM;
-		if (hw->bus.lan_id) {
-			esdp &= ~(IXGBE_ESDP_SDP1_NATIVE | IXGBE_ESDP_SDP1);
-			esdp |= IXGBE_ESDP_SDP1_DIR;
-		}
-		esdp &= ~(IXGBE_ESDP_SDP0_NATIVE | IXGBE_ESDP_SDP0_DIR);
-		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
+		ixgbe_setup_mux_ctl(hw);
 
 		return ixgbe_identify_module_generic(hw);
 	case IXGBE_DEV_ID_X550EM_X_KX4:
@@ -1127,18 +1136,10 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 {
 	struct ixgbe_phy_info *phy = &hw->phy;
 	s32 ret_val;
-	u32 esdp;
 
 	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_SFP) {
-		esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
 		phy->phy_semaphore_mask = IXGBE_GSSR_SHARED_I2C_SM;
-
-		if (hw->bus.lan_id) {
-			esdp &= ~(IXGBE_ESDP_SDP1_NATIVE | IXGBE_ESDP_SDP1);
-			esdp |= IXGBE_ESDP_SDP1_DIR;
-		}
-		esdp &= ~(IXGBE_ESDP_SDP0_NATIVE | IXGBE_ESDP_SDP0_DIR);
-		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
+		ixgbe_setup_mux_ctl(hw);
 	}
 
 	/* Identify the PHY or SFP module */
@@ -1366,6 +1367,9 @@ mac_reset_top:
 	hw->mac.num_rar_entries = 128;
 	hw->mac.ops.init_rx_addrs(hw);
 
+	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_SFP)
+		ixgbe_setup_mux_ctl(hw);
+
 	return status;
 }
 
-- 
2.4.2
