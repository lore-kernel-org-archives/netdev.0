From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/5] e1000e: Fix HW Error on es2lan, ARP capture issue by BMC
Date: Mon, 14 Apr 2008 10:06:14 -0700
Message-ID: <20080414170614.23286.62770.stgit@localhost.localdomain>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63565 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761148AbYDNRGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 13:06:23 -0400
In-Reply-To: <20080414170557.23286.71580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Graham <david.graham@intel.com>

Several components to this complex fix. The es2lan cards occasionally
gave a "HW Error" especially when forcing speed. Some users also
reported that the BMC stole ARP packets.

The fixes include setting the proper SW_FW bits to tell the BMC
that we're active and not do any un-initialization at all, so the
setup routine is largely changed.

Signed-off-by: David Graham <david.graham@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/e1000.h   |    2 +
 drivers/net/e1000e/es2lan.c  |  127 +++++++++++++++++++++++++++++++-----------
 drivers/net/e1000e/phy.c     |   73 +++++++++++++-----------
 4 files changed, 137 insertions(+), 66 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 4fb9d87..2a53875 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -184,6 +184,7 @@
 #define E1000_SWFW_EEP_SM   0x1
 #define E1000_SWFW_PHY0_SM  0x2
 #define E1000_SWFW_PHY1_SM  0x4
+#define E1000_SWFW_CSR_SM   0x8
 
 /* Device Control */
 #define E1000_CTRL_FD       0x00000001  /* Full duplex.0=half; 1=full */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 79a426f..f6835c3 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -449,6 +449,8 @@ extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success);
 extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
+extern s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_check_downshift(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 13a6f44..dc552d7 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -41,6 +41,7 @@
 #define E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL	 0x00
 #define E1000_KMRNCTRLSTA_OFFSET_INB_CTRL	 0x02
 #define E1000_KMRNCTRLSTA_OFFSET_HD_CTRL	 0x10
+#define E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE	 0x1F
 
 #define E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS	 0x0008
 #define E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS	 0x0800
@@ -48,6 +49,7 @@
 
 #define E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT 0x0004
 #define E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT	 0x0000
+#define E1000_KMRNCTRLSTA_OPMODE_E_IDLE		 0x2000
 
 #define E1000_TCTL_EXT_GCEX_MASK 0x000FFC00 /* Gigabit Carry Extend Padding */
 #define DEFAULT_TCTL_EXT_GCEX_80003ES2LAN	 0x00010000
@@ -85,6 +87,9 @@
 /* Kumeran Mode Control Register (Page 193, Register 16) */
 #define GG82563_KMCR_PASS_FALSE_CARRIER		 0x0800
 
+/* Max number of times Kumeran read/write should be validated */
+#define GG82563_MAX_KMRN_RETRY  0x5
+
 /* Power Management Control Register (Page 193, Register 20) */
 #define GG82563_PMCR_ENABLE_ELECTRICAL_IDLE	 0x0001
 					   /* 1=Enable SERDES Electrical Idle */
@@ -270,6 +275,7 @@ static s32 e1000_acquire_phy_80003es2lan(struct e1000_hw *hw)
 	u16 mask;
 
 	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
+	mask |= E1000_SWFW_CSR_SM;
 
 	return e1000_acquire_swfw_sync_80003es2lan(hw, mask);
 }
@@ -286,6 +292,8 @@ static void e1000_release_phy_80003es2lan(struct e1000_hw *hw)
 	u16 mask;
 
 	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
+	mask |= E1000_SWFW_CSR_SM;
+
 	e1000_release_swfw_sync_80003es2lan(hw, mask);
 }
 
@@ -410,20 +418,27 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	u32 page_select;
 	u16 temp;
 
+	ret_val = e1000_acquire_phy_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Select Configuration Page */
-	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
+	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
 		page_select = GG82563_PHY_PAGE_SELECT;
-	else
+	} else {
 		/*
 		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
+	}
 
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val = e1000e_write_phy_reg_m88(hw, page_select, temp);
-	if (ret_val)
+	ret_val = e1000e_write_phy_reg_mdic(hw, page_select, temp);
+	if (ret_val) {
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
+	}
 
 	/*
 	 * The "ready" bit in the MDIC register may be incorrectly set
@@ -433,20 +448,21 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	udelay(200);
 
 	/* ...and verify the command was successful. */
-	ret_val = e1000e_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val = e1000e_read_phy_reg_mdic(hw, page_select, &temp);
 
 	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
 		ret_val = -E1000_ERR_PHY;
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
 	}
 
 	udelay(200);
 
-	ret_val = e1000e_read_phy_reg_m88(hw,
-					 MAX_PHY_REG_ADDRESS & offset,
-					 data);
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					   data);
 
 	udelay(200);
+	e1000_release_phy_80003es2lan(hw);
 
 	return ret_val;
 }
@@ -467,20 +483,27 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	u32 page_select;
 	u16 temp;
 
+	ret_val = e1000_acquire_phy_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Select Configuration Page */
-	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
+	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
 		page_select = GG82563_PHY_PAGE_SELECT;
-	else
+	} else {
 		/*
 		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
+	}
 
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val = e1000e_write_phy_reg_m88(hw, page_select, temp);
-	if (ret_val)
+	ret_val = e1000e_write_phy_reg_mdic(hw, page_select, temp);
+	if (ret_val) {
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
+	}
 
 
 	/*
@@ -491,18 +514,20 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	udelay(200);
 
 	/* ...and verify the command was successful. */
-	ret_val = e1000e_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val = e1000e_read_phy_reg_mdic(hw, page_select, &temp);
 
-	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp)
+	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
+		e1000_release_phy_80003es2lan(hw);
 		return -E1000_ERR_PHY;
+	}
 
 	udelay(200);
 
-	ret_val = e1000e_write_phy_reg_m88(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					    data);
 
 	udelay(200);
+	e1000_release_phy_80003es2lan(hw);
 
 	return ret_val;
 }
@@ -882,10 +907,10 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 	u32 ctrl_ext;
-	u16 data;
+	u32 i = 0;
+	u16 data, data2;
 
-	ret_val = e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
-				     &data);
+	ret_val = e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL, &data);
 	if (ret_val)
 		return ret_val;
 
@@ -893,8 +918,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	/* Use 25MHz for both link down and 1000Base-T for Tx clock. */
 	data |= GG82563_MSCR_TX_CLK_1000MBPS_25;
 
-	ret_val = e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
-				      data);
+	ret_val = e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL, data);
 	if (ret_val)
 		return ret_val;
 
@@ -954,6 +978,18 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
+	ret_val = e1000e_read_kmrn_reg(hw,
+				       E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
+				       &data);
+	if (ret_val)
+		return ret_val;
+	data |= E1000_KMRNCTRLSTA_OPMODE_E_IDLE;
+	ret_val = e1000e_write_kmrn_reg(hw,
+					E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
+					data);
+	if (ret_val)
+		return ret_val;
+
 	ret_val = e1e_rphy(hw, GG82563_PHY_SPEC_CTRL_2, &data);
 	if (ret_val)
 		return ret_val;
@@ -983,9 +1019,18 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &data);
-		if (ret_val)
-			return ret_val;
+		do {
+			ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
+					   &data);
+			if (ret_val)
+				return ret_val;
+
+			ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
+					   &data2);
+			if (ret_val)
+				return ret_val;
+			i++;
+		} while ((data != data2) && (i < GG82563_MAX_KMRN_RETRY));
 
 		data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 		ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, data);
@@ -1074,7 +1119,8 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 {
 	s32 ret_val;
 	u32 tipg;
-	u16 reg_data;
+	u32 i = 0;
+	u16 reg_data, reg_data2;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
 	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
@@ -1088,9 +1134,16 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 	tipg |= DEFAULT_TIPG_IPGT_10_100_80003ES2LAN;
 	ew32(TIPG, tipg);
 
-	ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-	if (ret_val)
-		return ret_val;
+	do {
+		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data2);
+		if (ret_val)
+			return ret_val;
+		i++;
+	} while ((reg_data != reg_data2) && (i < GG82563_MAX_KMRN_RETRY));
 
 	if (duplex == HALF_DUPLEX)
 		reg_data |= GG82563_KMCR_PASS_FALSE_CARRIER;
@@ -1112,8 +1165,9 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	u16 reg_data;
+	u16 reg_data, reg_data2;
 	u32 tipg;
+	u32 i = 0;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
 	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
@@ -1127,9 +1181,16 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	tipg |= DEFAULT_TIPG_IPGT_1000_80003ES2LAN;
 	ew32(TIPG, tipg);
 
-	ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-	if (ret_val)
-		return ret_val;
+	do {
+		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data2);
+		if (ret_val)
+			return ret_val;
+		i++;
+	} while ((reg_data != reg_data2) && (i < GG82563_MAX_KMRN_RETRY));
 
 	reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 	ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3a4574c..e102332 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -116,7 +116,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_phy_reg_mdic - Read MDI control register
+ *  e1000e_read_phy_reg_mdic - Read MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -124,7 +124,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
  *  Reads the MDI control register in the PHY at offset and stores the
  *  information read to data.
  **/
-static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
+s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 i, mdic = 0;
@@ -150,7 +150,7 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * Increasing the time out as testing showed failures with
 	 * the lower time out
 	 */
-	for (i = 0; i < 64; i++) {
+	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
 		udelay(50);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
@@ -170,14 +170,14 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 }
 
 /**
- *  e1000_write_phy_reg_mdic - Write MDI control register
+ *  e1000e_write_phy_reg_mdic - Write MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write to register at offset
  *
  *  Writes data to MDI control register in the PHY at offset.
  **/
-static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
+s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 i, mdic = 0;
@@ -199,9 +199,13 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 
 	ew32(MDIC, mdic);
 
-	/* Poll the ready bit to see if the MDI read completed */
-	for (i = 0; i < E1000_GEN_POLL_TIMEOUT; i++) {
-		udelay(5);
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
+	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
+		udelay(50);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -210,6 +214,10 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 		hw_dbg(hw, "MDI Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
+	if (mdic & E1000_MDIC_ERROR) {
+		hw_dbg(hw, "MDI Error\n");
+		return -E1000_ERR_PHY;
+	}
 
 	return 0;
 }
@@ -232,9 +240,8 @@ s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000_read_phy_reg_mdic(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					   data);
 
 	hw->phy.ops.release_phy(hw);
 
@@ -258,9 +265,8 @@ s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000_write_phy_reg_mdic(hw,
-					   MAX_PHY_REG_ADDRESS & offset,
-					   data);
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					    data);
 
 	hw->phy.ops.release_phy(hw);
 
@@ -286,18 +292,17 @@ s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 		return ret_val;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
-		ret_val = e1000_write_phy_reg_mdic(hw,
-						   IGP01E1000_PHY_PAGE_SELECT,
-						   (u16)offset);
+		ret_val = e1000e_write_phy_reg_mdic(hw,
+						    IGP01E1000_PHY_PAGE_SELECT,
+						    (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
 			return ret_val;
 		}
 	}
 
-	ret_val = e1000_read_phy_reg_mdic(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					   data);
 
 	hw->phy.ops.release_phy(hw);
 
@@ -322,18 +327,17 @@ s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 		return ret_val;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
-		ret_val = e1000_write_phy_reg_mdic(hw,
-						   IGP01E1000_PHY_PAGE_SELECT,
-						   (u16)offset);
+		ret_val = e1000e_write_phy_reg_mdic(hw,
+						    IGP01E1000_PHY_PAGE_SELECT,
+						    (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
 			return ret_val;
 		}
 	}
 
-	ret_val = e1000_write_phy_reg_mdic(hw,
-					   MAX_PHY_REG_ADDRESS & offset,
-					   data);
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					    data);
 
 	hw->phy.ops.release_phy(hw);
 
@@ -420,7 +424,9 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
+	/* For newer PHYs this bit is downshift enable */
+	if (phy->type == e1000_phy_m88)
+		phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
 	/*
 	 * Options:
@@ -463,7 +469,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	if (phy->revision < 4) {
+	if ((phy->type == e1000_phy_m88) && (phy->revision < 4)) {
 		/*
 		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
@@ -518,8 +524,11 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Wait 15ms for MAC to configure PHY from NVM settings. */
-	msleep(15);
+	/*
+	 * Wait 100ms for MAC to configure PHY from NVM settings, to avoid
+	 * timeout issues when LFS is enabled.
+	 */
+	msleep(100);
 
 	/* disable lplu d0 during driver init */
 	ret_val = e1000_set_d0_lplu_state(hw, 0);
@@ -1152,9 +1161,7 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 
 	if (!active) {
 		data &= ~IGP02E1000_PM_D3_LPLU;
-		ret_val = e1e_wphy(hw,
-					     IGP02E1000_PHY_POWER_MGMT,
-					     data);
+		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
 		if (ret_val)
 			return ret_val;
 		/*

