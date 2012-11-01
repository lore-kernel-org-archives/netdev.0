From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] e1000: fix concurrent accesses to PHY from watchdog and ethtool
Date: Thu,  1 Nov 2012 03:44:27 -0700
Message-ID: <1351766667-28489-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Maxime Bizon <mbizon@freebox.fr>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Florian Fainelli <ffainelli@freebox.fr>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19249 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759476Ab2KAKoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:34 -0400
In-Reply-To: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>

The e1000 driver currently does not protect concurrent accesses to the PHY
from both the ethtool callbacks, and from the e1000_watchdog function. This
patchs adds a new spinlock which is used by e1000_{read,write}_phy_reg in
order to serialize concurrent accesses to the PHY.

Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 3d68395..8fedd24 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -107,6 +107,7 @@ u16 e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] = {
 };
 
 static DEFINE_SPINLOCK(e1000_eeprom_lock);
+static DEFINE_SPINLOCK(e1000_phy_lock);
 
 /**
  * e1000_set_phy_type - Set the phy type member in the hw struct.
@@ -2830,19 +2831,25 @@ static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 {
 	u32 ret_val;
+	unsigned long flags;
 
 	e_dbg("e1000_read_phy_reg");
 
+	spin_lock_irqsave(&e1000_phy_lock, flags);
+
 	if ((hw->phy_type == e1000_phy_igp) &&
 	    (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
 		ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
 						 (u16) reg_addr);
-		if (ret_val)
+		if (ret_val) {
+			spin_unlock_irqrestore(&e1000_phy_lock, flags);
 			return ret_val;
+		}
 	}
 
 	ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
 					phy_data);
+	spin_unlock_irqrestore(&e1000_phy_lock, flags);
 
 	return ret_val;
 }
@@ -2965,19 +2972,25 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
 {
 	u32 ret_val;
+	unsigned long flags;
 
 	e_dbg("e1000_write_phy_reg");
 
+	spin_lock_irqsave(&e1000_phy_lock, flags);
+
 	if ((hw->phy_type == e1000_phy_igp) &&
 	    (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
 		ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
 						 (u16) reg_addr);
-		if (ret_val)
+		if (ret_val) {
+			spin_unlock_irqrestore(&e1000_phy_lock, flags);
 			return ret_val;
+		}
 	}
 
 	ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
 					 phy_data);
+	spin_unlock_irqrestore(&e1000_phy_lock, flags);
 
 	return ret_val;
 }
-- 
1.7.11.7
