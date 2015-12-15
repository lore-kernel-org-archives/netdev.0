From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] igb: Improve cable length function for I210, etc.
Date: Mon, 14 Dec 2015 21:38:39 -0800
Message-ID: <1450157924-58901-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Schultz <jschultz@xes-inc.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Aaron Sierra <asierra@xes-inc.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59689 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbbLOFit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:49 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Schultz <jschultz@xes-inc.com>

Previously, the PHY-specific code to get the cable length for the
I210 internal and related PHYs was reporting the cable length of a
single pair and reporting it as the min, max, and total cable length.
Update it so that all four pairs are checked so the true min, max,
and average cable lengths are reported.

Signed-off-by: Joe Schultz <jschultz@xes-inc.com>
Signed-off-by: Aaron Sierra <asierra@xes-inc.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |  5 ++-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |  1 +
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 54 ++++++++++++++++++++++----
 3 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index a61ee94..c3c598c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -927,7 +927,10 @@
 
 /* Intel i347-AT4 Registers */
 
-#define I347AT4_PCDL                   0x10 /* PHY Cable Diagnostics Length */
+#define I347AT4_PCDL0                  0x10 /* Pair 0 PHY Cable Diagnostics Length */
+#define I347AT4_PCDL1                  0x11 /* Pair 1 PHY Cable Diagnostics Length */
+#define I347AT4_PCDL2                  0x12 /* Pair 2 PHY Cable Diagnostics Length */
+#define I347AT4_PCDL3                  0x13 /* Pair 3 PHY Cable Diagnostics Length */
 #define I347AT4_PCDC                   0x15 /* PHY Cable Diagnostics Control */
 #define I347AT4_PAGE_SELECT            0x16
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 2003b37..4034207 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -441,6 +441,7 @@ struct e1000_phy_info {
 	u16 cable_length;
 	u16 max_cable_length;
 	u16 min_cable_length;
+	u16 pair_length[4];
 
 	u8 mdix;
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 8015f3b..5b54254 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1717,6 +1717,9 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 	u16 phy_data, phy_data2, index, default_page, is_cm;
+	int len_tot = 0;
+	u16 len_min;
+	u16 len_max;
 
 	switch (hw->phy.id) {
 	case M88E1543_E_PHY_ID:
@@ -1733,11 +1736,6 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 		if (ret_val)
 			goto out;
 
-		/* Get cable length from PHY Cable Diagnostics Control Reg */
-		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL, &phy_data);
-		if (ret_val)
-			goto out;
-
 		/* Check if the unit of cable length is meters or cm */
 		ret_val = phy->ops.read_reg(hw, I347AT4_PCDC, &phy_data2);
 		if (ret_val)
@@ -1745,10 +1743,50 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 
 		is_cm = !(phy_data2 & I347AT4_PCDC_CABLE_LENGTH_UNIT);
 
+		/* Get cable length from Pair 0 length Regs */
+		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL0, &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy->pair_length[0] = phy_data / (is_cm ? 100 : 1);
+		len_tot = phy->pair_length[0];
+		len_min = phy->pair_length[0];
+		len_max = phy->pair_length[0];
+
+		/* Get cable length from Pair 1 length Regs */
+		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL1, &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy->pair_length[1] = phy_data / (is_cm ? 100 : 1);
+		len_tot += phy->pair_length[1];
+		len_min = min(len_min, phy->pair_length[1]);
+		len_max = max(len_max, phy->pair_length[1]);
+
+		/* Get cable length from Pair 2 length Regs */
+		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL2, &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy->pair_length[2] = phy_data / (is_cm ? 100 : 1);
+		len_tot += phy->pair_length[2];
+		len_min = min(len_min, phy->pair_length[2]);
+		len_max = max(len_max, phy->pair_length[2]);
+
+		/* Get cable length from Pair 3 length Regs */
+		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL3, &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy->pair_length[3] = phy_data / (is_cm ? 100 : 1);
+		len_tot += phy->pair_length[3];
+		len_min = min(len_min, phy->pair_length[3]);
+		len_max = max(len_max, phy->pair_length[3]);
+
 		/* Populate the phy structure with cable length in meters */
-		phy->min_cable_length = phy_data / (is_cm ? 100 : 1);
-		phy->max_cable_length = phy_data / (is_cm ? 100 : 1);
-		phy->cable_length = phy_data / (is_cm ? 100 : 1);
+		phy->min_cable_length = len_min;
+		phy->max_cable_length = len_max;
+		phy->cable_length = len_tot / 4;
 
 		/* Reset the page selec to its original value */
 		ret_val = phy->ops.write_reg(hw, I347AT4_PAGE_SELECT,
-- 
2.5.0
