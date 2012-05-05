From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] e1000e: enable forced master/slave on 82577
Date: Sat,  5 May 2012 05:38:10 -0700
Message-ID: <1336221493-913-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755443Ab2EEMiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 08:38:16 -0400
In-Reply-To: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Like other supported (igp) PHYs, the driver needs to be able to force the
master/slave mode on 82577.  Since the code is the same as what already
exists in the code flow for igp PHYs, move it to a new function to be
called for both flows.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c |   71 +++++++++++++++++++-----------
 1 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index ada7133..0334d01 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -639,6 +639,45 @@ s32 e1000e_write_kmrn_reg_locked(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
+ *  e1000_set_master_slave_mode - Setup PHY for Master/slave mode
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets up Master/slave mode
+ **/
+static s32 e1000_set_master_slave_mode(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	u16 phy_data;
+
+	/* Resolve Master/Slave mode */
+	ret_val = e1e_rphy(hw, PHY_1000T_CTRL, &phy_data);
+	if (ret_val)
+		return ret_val;
+
+	/* load defaults for future use */
+	hw->phy.original_ms_type = (phy_data & CR_1000T_MS_ENABLE) ?
+	    ((phy_data & CR_1000T_MS_VALUE) ?
+	     e1000_ms_force_master : e1000_ms_force_slave) : e1000_ms_auto;
+
+	switch (hw->phy.ms_type) {
+	case e1000_ms_force_master:
+		phy_data |= (CR_1000T_MS_ENABLE | CR_1000T_MS_VALUE);
+		break;
+	case e1000_ms_force_slave:
+		phy_data |= CR_1000T_MS_ENABLE;
+		phy_data &= ~(CR_1000T_MS_VALUE);
+		break;
+	case e1000_ms_auto:
+		phy_data &= ~CR_1000T_MS_ENABLE;
+		/* fall-through */
+	default:
+		break;
+	}
+
+	return e1e_wphy(hw, PHY_1000T_CTRL, phy_data);
+}
+
+/**
  *  e1000_copper_link_setup_82577 - Setup 82577 PHY for copper link
  *  @hw: pointer to the HW structure
  *
@@ -659,7 +698,11 @@ s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
 	/* Enable downshift */
 	phy_data |= I82577_CFG_ENABLE_DOWNSHIFT;
 
-	return e1e_wphy(hw, I82577_CFG_REG, phy_data);
+	ret_val = e1e_wphy(hw, I82577_CFG_REG, phy_data);
+	if (ret_val)
+		return ret_val;
+
+	return e1000_set_master_slave_mode(hw);
 }
 
 /**
@@ -895,31 +938,7 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 				return ret_val;
 		}
 
-		ret_val = e1e_rphy(hw, PHY_1000T_CTRL, &data);
-		if (ret_val)
-			return ret_val;
-
-		/* load defaults for future use */
-		phy->original_ms_type = (data & CR_1000T_MS_ENABLE) ?
-			((data & CR_1000T_MS_VALUE) ?
-			e1000_ms_force_master :
-			e1000_ms_force_slave) :
-			e1000_ms_auto;
-
-		switch (phy->ms_type) {
-		case e1000_ms_force_master:
-			data |= (CR_1000T_MS_ENABLE | CR_1000T_MS_VALUE);
-			break;
-		case e1000_ms_force_slave:
-			data |= CR_1000T_MS_ENABLE;
-			data &= ~(CR_1000T_MS_VALUE);
-			break;
-		case e1000_ms_auto:
-			data &= ~CR_1000T_MS_ENABLE;
-		default:
-			break;
-		}
-		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, data);
+		ret_val = e1000_set_master_slave_mode(hw);
 	}
 
 	return ret_val;
-- 
1.7.7.6
