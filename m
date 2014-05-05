From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] e1000e: Workaround for dropped packets in Gig/100 speeds on 82579
Date: Mon,  5 May 2014 13:07:37 -0700
Message-ID: <1399320460-21774-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbaEEUHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 16:07:49 -0400
In-Reply-To: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

This is a workaround for a HW erratum on 82579 devices.
Erratum is #23 in Intel 6 Series Chipset and Intel C200 Series Chipset
specification Update June 2013.

Problem: 82579 parts experience packet loss in Gig and 100 speeds
when interconnect between PHY and MAC is exiting K1 power saving state.
This was previously believed to only affect 1Gig speed, but has been observed
at 100Mbs also.

Workaround: Disable K1 for 82579 devices at Gig and 100 speeds.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 31 +++++++++++------------------
 drivers/net/ethernet/intel/e1000e/phy.h     |  1 +
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9866f26..9b736b8 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2493,51 +2493,44 @@ release:
  *  e1000_k1_gig_workaround_lv - K1 Si workaround
  *  @hw:   pointer to the HW structure
  *
- *  Workaround to set the K1 beacon duration for 82579 parts
+ *  Workaround to set the K1 beacon duration for 82579 parts in 10Mbps
+ *  Disable K1 in 1000Mbps and 100Mbps
  **/
 static s32 e1000_k1_workaround_lv(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 	u16 status_reg = 0;
-	u32 mac_reg;
-	u16 phy_reg;
 
 	if (hw->mac.type != e1000_pch2lan)
 		return 0;
 
-	/* Set K1 beacon duration based on 1Gbps speed or otherwise */
+	/* Set K1 beacon duration based on 10Mbs speed */
 	ret_val = e1e_rphy(hw, HV_M_STATUS, &status_reg);
 	if (ret_val)
 		return ret_val;
 
 	if ((status_reg & (HV_M_STATUS_LINK_UP | HV_M_STATUS_AUTONEG_COMPLETE))
 	    == (HV_M_STATUS_LINK_UP | HV_M_STATUS_AUTONEG_COMPLETE)) {
-		mac_reg = er32(FEXTNVM4);
-		mac_reg &= ~E1000_FEXTNVM4_BEACON_DURATION_MASK;
-
-		ret_val = e1e_rphy(hw, I82579_LPI_CTRL, &phy_reg);
-		if (ret_val)
-			return ret_val;
-
-		if (status_reg & HV_M_STATUS_SPEED_1000) {
+		if (status_reg &
+		    (HV_M_STATUS_SPEED_1000 | HV_M_STATUS_SPEED_100)) {
 			u16 pm_phy_reg;
 
-			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_8USEC;
-			phy_reg &= ~I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
-			/* LV 1G Packet drop issue wa  */
+			/* LV 1G/100 Packet drop issue wa  */
 			ret_val = e1e_rphy(hw, HV_PM_CTRL, &pm_phy_reg);
 			if (ret_val)
 				return ret_val;
-			pm_phy_reg &= ~HV_PM_CTRL_PLL_STOP_IN_K1_GIGA;
+			pm_phy_reg &= ~HV_PM_CTRL_K1_ENABLE;
 			ret_val = e1e_wphy(hw, HV_PM_CTRL, pm_phy_reg);
 			if (ret_val)
 				return ret_val;
 		} else {
+			u32 mac_reg;
+
+			mac_reg = er32(FEXTNVM4);
+			mac_reg &= ~E1000_FEXTNVM4_BEACON_DURATION_MASK;
 			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_16USEC;
-			phy_reg |= I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
+			ew32(FEXTNVM4, mac_reg);
 		}
-		ew32(FEXTNVM4, mac_reg);
-		ret_val = e1e_wphy(hw, I82579_LPI_CTRL, phy_reg);
 	}
 
 	return ret_val;
diff --git a/drivers/net/ethernet/intel/e1000e/phy.h b/drivers/net/ethernet/intel/e1000e/phy.h
index 3841bcc..537d278 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.h
+++ b/drivers/net/ethernet/intel/e1000e/phy.h
@@ -164,6 +164,7 @@ s32 e1000_get_cable_length_82577(struct e1000_hw *hw);
 #define HV_M_STATUS_AUTONEG_COMPLETE	0x1000
 #define HV_M_STATUS_SPEED_MASK		0x0300
 #define HV_M_STATUS_SPEED_1000		0x0200
+#define HV_M_STATUS_SPEED_100		0x0100
 #define HV_M_STATUS_LINK_UP		0x0040
 
 #define IGP01E1000_PHY_PCS_INIT_REG	0x00B4
-- 
1.9.0
