From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] ixgbe: fix X550 devices init flow
Date: Tue,  9 Jun 2015 18:10:23 -0700
Message-ID: <1433898629-76729-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754139AbbFJBKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:50 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Reviewing the X550 copper init flow with the Si team resulted in a
new simplified flow.  We no longer wait for the PHY FW initialization
complete bit to be set as this bit is only set once by the PHY at power
on and then cleared on the first read. So only the first instance of
running SW (or possibly MAC FW) needs to initialize the PHY.

The PHY initialization has been simplified and now only requires that
the PHY FW be un-stalled
low-power mode or enabled the transceiver

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 68 ++++++++-------------------
 1 file changed, 19 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index a48134e..ef3d686 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1516,65 +1516,35 @@ static s32 ixgbe_init_ext_t_x550em(struct ixgbe_hw *hw)
 {
 	s32 status;
 	u16 reg;
-	u32 retries = 2;
 
-	do {
-		/* decrement retries counter and exit if we hit 0 */
-		if (retries < 1) {
-			hw_dbg(hw, "External PHY not yet finished resetting.");
-			return IXGBE_ERR_PHY;
-		}
-		retries--;
-
-		status = hw->phy.ops.read_reg(hw,
-					      IXGBE_MDIO_TX_VENDOR_ALARMS_3,
-					      IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-					      &reg);
-		if (status)
-			return status;
-
-		/* Verify PHY FW reset has completed */
-	} while ((reg & IXGBE_MDIO_TX_VENDOR_ALARMS_3_RST_MASK) != 1);
-
-	/* Set port to low power mode */
-	status = hw->phy.ops.read_reg(hw,
-				      IXGBE_MDIO_VENDOR_SPECIFIC_1_CONTROL,
-				      IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
-				      &reg);
-	if (status)
-		return status;
-
-	/* Enable the transmitter */
 	status = hw->phy.ops.read_reg(hw,
-				      IXGBE_MDIO_PMD_STD_TX_DISABLE_CNTR,
+				      IXGBE_MDIO_TX_VENDOR_ALARMS_3,
 				      IXGBE_MDIO_PMA_PMD_DEV_TYPE,
 				      &reg);
 	if (status)
 		return status;
 
-	reg &= ~IXGBE_MDIO_PMD_GLOBAL_TX_DISABLE;
-
-	status = hw->phy.ops.write_reg(hw,
-				       IXGBE_MDIO_PMD_STD_TX_DISABLE_CNTR,
-				       IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-				       reg);
-	if (status)
-		return status;
+	/* If PHY FW reset completed bit is set then this is the first
+	 * SW instance after a power on so the PHY FW must be un-stalled.
+	 */
+	if (reg & IXGBE_MDIO_TX_VENDOR_ALARMS_3_RST_MASK) {
+		status = hw->phy.ops.read_reg(hw,
+					IXGBE_MDIO_GLOBAL_RES_PR_10,
+					IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+					&reg);
+		if (status)
+			return status;
 
-	/* Un-stall the PHY FW */
-	status = hw->phy.ops.read_reg(hw,
-				      IXGBE_MDIO_GLOBAL_RES_PR_10,
-				      IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
-				      &reg);
-	if (status)
-		return status;
+		reg &= ~IXGBE_MDIO_POWER_UP_STALL;
 
-	reg &= ~IXGBE_MDIO_POWER_UP_STALL;
+		status = hw->phy.ops.write_reg(hw,
+					IXGBE_MDIO_GLOBAL_RES_PR_10,
+					IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+					reg);
+		if (status)
+			return status;
+	}
 
-	status = hw->phy.ops.write_reg(hw,
-				       IXGBE_MDIO_GLOBAL_RES_PR_10,
-				       IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
-				       reg);
 	return status;
 }
 
-- 
2.4.2
