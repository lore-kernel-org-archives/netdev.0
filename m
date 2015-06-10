From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/18] ixgbe: fix issue with sfp events with new X550 devices
Date: Tue,  9 Jun 2015 18:10:21 -0700
Message-ID: <1433898629-76729-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914AbbFJBKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:49 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Add checks for systems that don't have SFP's to avoid incorrectly
acting on interrupts that are falsely interpreted as SFP events.
We do this by updating the ixgbe_is_sfp to be aware of the
new X550 devices.  This also includes a modified check generating
the EICR mask to be more forward-looking.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 47 ++++++++++++---------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1c3477a..4b681c4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2444,6 +2444,27 @@ static void ixgbe_check_overtemp_event(struct ixgbe_adapter *adapter, u32 eicr)
 	e_crit(drv, "%s\n", ixgbe_overheat_msg);
 }
 
+static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
+{
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		if (hw->phy.type == ixgbe_phy_nl)
+			return true;
+		return false;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X550EM_x:
+		switch (hw->mac.ops.get_media_type(hw)) {
+		case ixgbe_media_type_fiber:
+		case ixgbe_media_type_fiber_qsfp:
+			return true;
+		default:
+			return false;
+		}
+	default:
+		return false;
+	}
+}
+
 static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -4714,32 +4735,6 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_dfwd(adapter);
 }
 
-static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
-{
-	switch (hw->phy.type) {
-	case ixgbe_phy_sfp_avago:
-	case ixgbe_phy_sfp_ftl:
-	case ixgbe_phy_sfp_intel:
-	case ixgbe_phy_sfp_unknown:
-	case ixgbe_phy_sfp_passive_tyco:
-	case ixgbe_phy_sfp_passive_unknown:
-	case ixgbe_phy_sfp_active_unknown:
-	case ixgbe_phy_sfp_ftl_active:
-	case ixgbe_phy_qsfp_passive_unknown:
-	case ixgbe_phy_qsfp_active_unknown:
-	case ixgbe_phy_qsfp_intel:
-	case ixgbe_phy_qsfp_unknown:
-	/* ixgbe_phy_none is set when no SFP module is present */
-	case ixgbe_phy_none:
-		return true;
-	case ixgbe_phy_nl:
-		if (hw->mac.type == ixgbe_mac_82598EB)
-			return true;
-	default:
-		return false;
-	}
-}
-
 /**
  * ixgbe_sfp_link_config - set up SFP+ link
  * @adapter: pointer to private adapter struct
-- 
2.4.2
