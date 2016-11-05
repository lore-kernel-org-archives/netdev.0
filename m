From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] ixgbe: Update setup PHY link to unset all speeds
Date: Sat,  5 Nov 2016 00:54:09 -0700
Message-ID: <1478332461-43147-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:25789 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752921AbcKEHyY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:24 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch updates ixgbe_setup_phy_link_generic to set/unset
auto-negotiation for all speeds. This ensures that unsupported
speeds are unset. This is necessary since the PHY NVM may
advertise unsupported speeds.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 77 ++++++++++++++--------------
 1 file changed, 38 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 021ab9b..648739a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -705,53 +705,52 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 
 	ixgbe_get_copper_link_capabilities_generic(hw, &speed, &autoneg);
 
-	if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
-		/* Set or unset auto-negotiation 10G advertisement */
-		hw->phy.ops.read_reg(hw, MDIO_AN_10GBT_CTRL,
-				     MDIO_MMD_AN,
-				     &autoneg_reg);
+	/* Set or unset auto-negotiation 10G advertisement */
+	hw->phy.ops.read_reg(hw, MDIO_AN_10GBT_CTRL, MDIO_MMD_AN, &autoneg_reg);
 
-		autoneg_reg &= ~MDIO_AN_10GBT_CTRL_ADV10G;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
-			autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
+	autoneg_reg &= ~MDIO_AN_10GBT_CTRL_ADV10G;
+	if ((hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL) &&
+	    (speed & IXGBE_LINK_SPEED_10GB_FULL))
+		autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
 
-		hw->phy.ops.write_reg(hw, MDIO_AN_10GBT_CTRL,
-				      MDIO_MMD_AN,
-				      autoneg_reg);
-	}
+	hw->phy.ops.write_reg(hw, MDIO_AN_10GBT_CTRL, MDIO_MMD_AN, autoneg_reg);
 
-	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
-		/* Set or unset auto-negotiation 1G advertisement */
-		hw->phy.ops.read_reg(hw,
-				     IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
-				     MDIO_MMD_AN,
-				     &autoneg_reg);
-
-		autoneg_reg &= ~IXGBE_MII_1GBASE_T_ADVERTISE;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
-			autoneg_reg |= IXGBE_MII_1GBASE_T_ADVERTISE;
+	hw->phy.ops.read_reg(hw, IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
+			     MDIO_MMD_AN, &autoneg_reg);
 
-		hw->phy.ops.write_reg(hw,
-				      IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
-				      MDIO_MMD_AN,
-				      autoneg_reg);
+	if (hw->mac.type == ixgbe_mac_X550) {
+		/* Set or unset auto-negotiation 5G advertisement */
+		autoneg_reg &= ~IXGBE_MII_5GBASE_T_ADVERTISE;
+		if ((hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_5GB_FULL) &&
+		    (speed & IXGBE_LINK_SPEED_5GB_FULL))
+			autoneg_reg |= IXGBE_MII_5GBASE_T_ADVERTISE;
+
+		/* Set or unset auto-negotiation 2.5G advertisement */
+		autoneg_reg &= ~IXGBE_MII_2_5GBASE_T_ADVERTISE;
+		if ((hw->phy.autoneg_advertised &
+		     IXGBE_LINK_SPEED_2_5GB_FULL) &&
+		    (speed & IXGBE_LINK_SPEED_2_5GB_FULL))
+			autoneg_reg |= IXGBE_MII_2_5GBASE_T_ADVERTISE;
 	}
 
-	if (speed & IXGBE_LINK_SPEED_100_FULL) {
-		/* Set or unset auto-negotiation 100M advertisement */
-		hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
-				     MDIO_MMD_AN,
-				     &autoneg_reg);
+	/* Set or unset auto-negotiation 1G advertisement */
+	autoneg_reg &= ~IXGBE_MII_1GBASE_T_ADVERTISE;
+	if ((hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL) &&
+	    (speed & IXGBE_LINK_SPEED_1GB_FULL))
+		autoneg_reg |= IXGBE_MII_1GBASE_T_ADVERTISE;
 
-		autoneg_reg &= ~(ADVERTISE_100FULL |
-				 ADVERTISE_100HALF);
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
-			autoneg_reg |= ADVERTISE_100FULL;
+	hw->phy.ops.write_reg(hw, IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
+			      MDIO_MMD_AN, autoneg_reg);
 
-		hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE,
-				      MDIO_MMD_AN,
-				      autoneg_reg);
-	}
+	/* Set or unset auto-negotiation 100M advertisement */
+	hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, &autoneg_reg);
+
+	autoneg_reg &= ~(ADVERTISE_100FULL | ADVERTISE_100HALF);
+	if ((hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL) &&
+	    (speed & IXGBE_LINK_SPEED_100_FULL))
+		autoneg_reg |= ADVERTISE_100FULL;
+
+	hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, autoneg_reg);
 
 	/* Blocked by MNG FW so don't reset PHY */
 	if (ixgbe_check_reset_blocked(hw))
-- 
2.7.4
