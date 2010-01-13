From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: MDIO slow mode should always be done for
	82577
Date: Wed, 13 Jan 2010 03:52:49 -0800
Message-ID: <20100113115248.23394.71869.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:50573 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751968Ab0AMLxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 06:53:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A previous 82577 workaround that set the MDIO access speed to slow mode for
every PHY register read/write when the cable is unplugged should instead
set the access mode to always be slow before any PHY register access.
Since the mode bit gets cleared when the PHY is reset, set the mode after
every PHY reset.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 
 drivers/net/e1000e/ich8lan.c |   57 ++++++++++++++++++++++++++--
 drivers/net/e1000e/phy.c     |   85 ------------------------------------------
 3 files changed, 53 insertions(+), 90 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index cebbd90..d6ee28f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -582,7 +582,6 @@ extern s32 e1000_read_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
 extern s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000_write_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
                                          u16 data);
-extern s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow);
 extern s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw);
 extern s32 e1000_copper_link_setup_82577(struct e1000_hw *hw);
 extern s32 e1000_check_polarity_82577(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index ad08cf3..c2ea861 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -138,6 +138,10 @@
 #define E1000_NVM_K1_CONFIG 0x1B /* NVM K1 Config Word */
 #define E1000_NVM_K1_ENABLE 0x1  /* NVM Enable K1 bit */
 
+/* KMRN Mode Control */
+#define HV_KMRN_MODE_CTRL      PHY_REG(769, 16)
+#define HV_KMRN_MDIO_SLOW      0x0400
+
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
@@ -219,6 +223,7 @@ static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active);
 static void e1000_power_down_phy_copper_ich8lan(struct e1000_hw *hw);
 static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
 static s32  e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link);
+static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -270,7 +275,21 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
 	phy->id = e1000_phy_unknown;
-	e1000e_get_phy_id(hw);
+	ret_val = e1000e_get_phy_id(hw);
+	if (ret_val)
+		goto out;
+	if ((phy->id == 0) || (phy->id == PHY_REVISION_MASK)) {
+		/*
+		 * In case the PHY needs to be in mdio slow mode (eg. 82577),
+		 * set slow mode and try to get the PHY id again.
+		 */
+		ret_val = e1000_set_mdio_slow_mode_hv(hw);
+		if (ret_val)
+			goto out;
+		ret_val = e1000e_get_phy_id(hw);
+		if (ret_val)
+			goto out;
+	}
 	phy->type = e1000e_get_phy_type_from_id(phy->id);
 
 	switch (phy->type) {
@@ -292,6 +311,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		break;
 	}
 
+out:
 	return ret_val;
 }
 
@@ -1076,6 +1096,26 @@ out:
 
 
 /**
+ *  e1000_set_mdio_slow_mode_hv - Set slow MDIO access mode
+ *  @hw:   pointer to the HW structure
+ **/
+static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	u16 data;
+
+	ret_val = e1e_rphy(hw, HV_KMRN_MODE_CTRL, &data);
+	if (ret_val)
+		return ret_val;
+
+	data |= HV_KMRN_MDIO_SLOW;
+
+	ret_val = e1e_wphy(hw, HV_KMRN_MODE_CTRL, data);
+
+	return ret_val;
+}
+
+/**
  *  e1000_hv_phy_workarounds_ich8lan - A series of Phy workarounds to be
  *  done after every PHY reset.
  **/
@@ -1086,6 +1126,13 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	if (hw->mac.type != e1000_pchlan)
 		return ret_val;
 
+	/* Set MDIO slow mode before any other MDIO access */
+	if (hw->phy.type == e1000_phy_82577) {
+		ret_val = e1000_set_mdio_slow_mode_hv(hw);
+		if (ret_val)
+			goto out;
+	}
+
 	if (((hw->phy.type == e1000_phy_82577) &&
 	     ((hw->phy.revision == 1) || (hw->phy.revision == 2))) ||
 	    ((hw->phy.type == e1000_phy_82578) && (hw->phy.revision == 1))) {
@@ -1184,6 +1231,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	/* Allow time for h/w to get to a quiescent state after reset */
 	mdelay(10);
 
+	/* Perform any necessary post-reset workarounds */
 	if (hw->mac.type == e1000_pchlan) {
 		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
 		if (ret_val)
@@ -2484,6 +2532,10 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	if (!ret_val)
 		e1000_release_swflag_ich8lan(hw);
 
+	/* Perform any necessary post-reset workarounds */
+	if (hw->mac.type == e1000_pchlan)
+		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
+
 	if (ctrl & E1000_CTRL_PHY_RST)
 		ret_val = hw->phy.ops.get_cfg_done(hw);
 
@@ -2528,9 +2580,6 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	kab |= E1000_KABGTXD_BGSQLBIAS;
 	ew32(KABGTXD, kab);
 
-	if (hw->mac.type == e1000_pchlan)
-		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
-
 out:
 	return ret_val;
 }
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 55a2c0a..7f3ceb9 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -152,32 +152,9 @@ s32 e1000e_get_phy_id(struct e1000_hw *hw)
 		if (phy->id != 0 && phy->id != PHY_REVISION_MASK)
 			goto out;
 
-		/*
-		 * If the PHY ID is still unknown, we may have an 82577
-		 * without link.  We will try again after setting Slow MDIC
-		 * mode. No harm in trying again in this case since the PHY
-		 * ID is unknown at this point anyway.
-		 */
-		ret_val = phy->ops.acquire(hw);
-		if (ret_val)
-			goto out;
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
-		if (ret_val)
-			goto out;
-		phy->ops.release(hw);
-
 		retry_count++;
 	}
 out:
-	/* Revert to MDIO fast mode, if applicable */
-	if (retry_count) {
-		ret_val = phy->ops.acquire(hw);
-		if (ret_val)
-			return ret_val;
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
-		phy->ops.release(hw);
-	}
-
 	return ret_val;
 }
 
@@ -2791,38 +2768,6 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 }
 
 /**
- *  e1000_set_mdio_slow_mode_hv - Set slow MDIO access mode
- *  @hw:   pointer to the HW structure
- *  @slow: true for slow mode, false for normal mode
- *
- *  Assumes semaphore already acquired.
- **/
-s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow)
-{
-	s32 ret_val = 0;
-	u16 data = 0;
-
-	/* Set MDIO mode - page 769, register 16: 0x2580==slow, 0x2180==fast */
-	hw->phy.addr = 1;
-	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
-				         (BM_PORT_CTRL_PAGE << IGP_PAGE_SHIFT));
-	if (ret_val)
-		goto out;
-
-	ret_val = e1000e_write_phy_reg_mdic(hw, BM_CS_CTRL1,
-	                                   (0x2180 | (slow << 10)));
-	if (ret_val)
-		goto out;
-
-	/* dummy read when reverting to fast mode - throw away result */
-	if (!slow)
-		ret_val = e1000e_read_phy_reg_mdic(hw, BM_CS_CTRL1, &data);
-
-out:
-	return ret_val;
-}
-
-/**
  *  __e1000_read_phy_reg_hv -  Read HV PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
@@ -2839,7 +2784,6 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
 	u16 reg = BM_PHY_REG_NUM(offset);
-	bool in_slow_mode = false;
 
 	if (!locked) {
 		ret_val = hw->phy.ops.acquire(hw);
@@ -2847,16 +2791,6 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 			return ret_val;
 	}
 
-	/* Workaround failure in MDIO access while cable is disconnected */
-	if ((hw->phy.type == e1000_phy_82577) &&
-	    !(er32(STATUS) & E1000_STATUS_LU)) {
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
-		if (ret_val)
-			goto out;
-
-		in_slow_mode = true;
-	}
-
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
@@ -2893,10 +2827,6 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
 	                                  data);
 out:
-	/* Revert to MDIO fast mode, if applicable */
-	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
-		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
-
 	if (!locked)
 		hw->phy.ops.release(hw);
 
@@ -2948,7 +2878,6 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
 	u16 reg = BM_PHY_REG_NUM(offset);
-	bool in_slow_mode = false;
 
 	if (!locked) {
 		ret_val = hw->phy.ops.acquire(hw);
@@ -2956,16 +2885,6 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 			return ret_val;
 	}
 
-	/* Workaround failure in MDIO access while cable is disconnected */
-	if ((hw->phy.type == e1000_phy_82577) &&
-	    !(er32(STATUS) & E1000_STATUS_LU)) {
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
-		if (ret_val)
-			goto out;
-
-		in_slow_mode = true;
-	}
-
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
@@ -3019,10 +2938,6 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	                                  data);
 
 out:
-	/* Revert to MDIO fast mode, if applicable */
-	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
-		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
-
 	if (!locked)
 		hw->phy.ops.release(hw);
 

