From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/5] e1000e: allow for swflag to be held over
	consecutive PHY accesses
Date: Mon, 26 Oct 2009 14:24:02 -0700
Message-ID: <20091026212401.9682.51970.stgit@localhost.localdomain>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:35537
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753056AbZJZV1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:27:41 -0400
In-Reply-To: <20091026212242.9682.25442.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

PCH-based parts (82577/82578) and some ICH8-based parts (82566) need to
hold the swflag (sw/fw/hw hardware semaphore) over consecutive PHY accesses
in order to perform sw-driven PHY configuration during initialization to
workaround known hardware issues (see follow-on patch).  This patch
provides new PHY read/write functions (and function pointers) that will
allow accessing the PHY registers assuming the swflag has already been
acquired.  The actual PHY register access code has moved into helper
functions that are called with a flag indicating whether or not the swflag
has already been acquired and acquires/releases it if not.

The functions called from within the updated PHY access functions had to be
updated to assume the swflag was already acquired, and other functions that
called those functions were also updated to acquire/release the swflag.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |   12 +
 drivers/net/e1000e/hw.h      |    2 
 drivers/net/e1000e/ich8lan.c |    4 
 drivers/net/e1000e/phy.c     |  469 +++++++++++++++++++++++++++++-------------
 4 files changed, 346 insertions(+), 141 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 981936c..405a144 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -519,9 +519,13 @@ extern s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw);
 extern s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw);
 extern s32 e1000e_get_phy_info_igp(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_read_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset,
+                                          u16 *data);
 extern s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw);
 extern s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 extern s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_write_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset,
+                                           u16 data);
 extern s32 e1000e_phy_sw_reset(struct e1000_hw *hw);
 extern s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw);
 extern s32 e1000e_get_cfg_done(struct e1000_hw *hw);
@@ -538,7 +542,11 @@ extern s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data);
 extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_write_kmrn_reg_locked(struct e1000_hw *hw, u32 offset,
+                                        u16 data);
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset,
+                                       u16 *data);
 extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success);
 extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
@@ -546,7 +554,11 @@ extern s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_check_downshift(struct e1000_hw *hw);
 extern s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000_read_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
+                                        u16 *data);
 extern s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000_write_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
+                                         u16 data);
 extern s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow);
 extern s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw);
 extern s32 e1000_copper_link_setup_82577(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index fd44d9f..7b05cf4 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -764,11 +764,13 @@ struct e1000_phy_operations {
 	s32  (*get_cable_length)(struct e1000_hw *);
 	s32  (*get_phy_info)(struct e1000_hw *);
 	s32  (*read_phy_reg)(struct e1000_hw *, u32, u16 *);
+	s32  (*read_phy_reg_locked)(struct e1000_hw *, u32, u16 *);
 	void (*release_phy)(struct e1000_hw *);
 	s32  (*reset_phy)(struct e1000_hw *);
 	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
 	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
 	s32  (*write_phy_reg)(struct e1000_hw *, u32, u16);
+	s32  (*write_phy_reg_locked)(struct e1000_hw *, u32, u16);
 	s32  (*cfg_on_link_up)(struct e1000_hw *);
 };
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index aaaaf2c..b6388b9 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -250,9 +250,11 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 
 	phy->ops.check_polarity       = e1000_check_polarity_ife_ich8lan;
 	phy->ops.read_phy_reg         = e1000_read_phy_reg_hv;
+	phy->ops.read_phy_reg_locked  = e1000_read_phy_reg_hv_locked;
 	phy->ops.set_d0_lplu_state    = e1000_set_lplu_state_pchlan;
 	phy->ops.set_d3_lplu_state    = e1000_set_lplu_state_pchlan;
 	phy->ops.write_phy_reg        = e1000_write_phy_reg_hv;
+	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
 	phy->id = e1000_phy_unknown;
@@ -313,6 +315,8 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	case IGP03E1000_E_PHY_ID:
 		phy->type = e1000_phy_igp_3;
 		phy->autoneg_mask = AUTONEG_ADVERTISE_SPEED_DEFAULT;
+		phy->ops.read_phy_reg_locked = e1000e_read_phy_reg_igp_locked;
+		phy->ops.write_phy_reg_locked = e1000e_write_phy_reg_igp_locked;
 		break;
 	case IFE_E_PHY_ID:
 	case IFE_PLUS_E_PHY_ID:
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 994401f..f9d33ab 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -164,16 +164,25 @@ s32 e1000e_get_phy_id(struct e1000_hw *hw)
 		 * MDIC mode. No harm in trying again in this case since
 		 * the PHY ID is unknown at this point anyway
 		 */
+		ret_val = phy->ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
 		if (ret_val)
 			goto out;
+		phy->ops.release_phy(hw);
 
 		retry_count++;
 	}
 out:
 	/* Revert to MDIO fast mode, if applicable */
-	if (retry_count)
+	if (retry_count) {
+		ret_val = phy->ops.acquire_phy(hw);
+		if (ret_val)
+			return ret_val;
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+		phy->ops.release_phy(hw);
+	}
 
 	return ret_val;
 }
@@ -354,94 +363,173 @@ s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
- *  e1000e_read_phy_reg_igp - Read igp PHY register
+ *  __e1000e_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary, then reads the PHY register at offset
- *  and storing the retrieved information in data.  Release any acquired
+ *  and stores the retrieved information in data.  Release any acquired
  *  semaphores before exiting.
  **/
-s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
+static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
+                                    bool locked)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
+	if (!locked) {
+		if (!(hw->phy.ops.acquire_phy))
+			goto out;
+
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
+	}
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
 		ret_val = e1000e_write_phy_reg_mdic(hw,
 						    IGP01E1000_PHY_PAGE_SELECT,
 						    (u16)offset);
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
-			return ret_val;
-		}
+		if (ret_val)
+			goto release;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
-					   data);
-
-	hw->phy.ops.release_phy(hw);
+	                                  data);
 
+release:
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
+out:
 	return ret_val;
 }
 
 /**
+ *  e1000e_read_phy_reg_igp - Read igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore then reads the PHY register at offset and stores the
+ *  retrieved information in data.
+ *  Release the acquired semaphore before exiting.
+ **/
+s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000e_read_phy_reg_igp(hw, offset, data, false);
+}
+
+/**
+ *  e1000e_read_phy_reg_igp_locked - Read igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Reads the PHY register at offset and stores the retrieved information
+ *  in data.  Assumes semaphore already acquired.
+ **/
+s32 e1000e_read_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000e_read_phy_reg_igp(hw, offset, data, true);
+}
+
+/**
  *  e1000e_write_phy_reg_igp - Write igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary, then writes the data to PHY register
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
-s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
+static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
+                                     bool locked)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
+	if (!locked) {
+		if (!(hw->phy.ops.acquire_phy))
+			goto out;
+
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
+	}
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
 		ret_val = e1000e_write_phy_reg_mdic(hw,
 						    IGP01E1000_PHY_PAGE_SELECT,
 						    (u16)offset);
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
-			return ret_val;
-		}
+		if (ret_val)
+			goto release;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					    data);
 
-	hw->phy.ops.release_phy(hw);
+release:
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
 
+out:
 	return ret_val;
 }
 
 /**
- *  e1000e_read_kmrn_reg - Read kumeran register
+ *  e1000e_write_phy_reg_igp - Write igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000e_write_phy_reg_igp(hw, offset, data, false);
+}
+
+/**
+ *  e1000e_write_phy_reg_igp_locked - Write igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Writes the data to PHY register at the offset.
+ *  Assumes semaphore already acquired.
+ **/
+s32 e1000e_write_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000e_write_phy_reg_igp(hw, offset, data, true);
+}
+
+/**
+ *  __e1000_read_kmrn_reg - Read kumeran register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary.  Then reads the PHY register at offset
  *  using the kumeran interface.  The information retrieved is stored in data.
  *  Release any acquired semaphores before exiting.
  **/
-s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
+static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
+                                 bool locked)
 {
 	u32 kmrnctrlsta;
-	s32 ret_val;
+	s32 ret_val = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
+	if (!locked) {
+		if (!(hw->phy.ops.acquire_phy))
+			goto out;
+
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
+	}
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
@@ -452,41 +540,111 @@ s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 	kmrnctrlsta = er32(KMRNCTRLSTA);
 	*data = (u16)kmrnctrlsta;
 
-	hw->phy.ops.release_phy(hw);
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
 
+out:
 	return ret_val;
 }
 
 /**
- *  e1000e_write_kmrn_reg - Write kumeran register
+ *  e1000e_read_kmrn_reg -  Read kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore then reads the PHY register at offset using the
+ *  kumeran interface.  The information retrieved is stored in data.
+ *  Release the acquired semaphore before exiting.
+ **/
+s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000_read_kmrn_reg(hw, offset, data, false);
+}
+
+/**
+ *  e1000_read_kmrn_reg_locked -  Read kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Reads the PHY register at offset using the kumeran interface.  The
+ *  information retrieved is stored in data.
+ *  Assumes semaphore already acquired.
+ **/
+s32 e1000_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000_read_kmrn_reg(hw, offset, data, true);
+}
+
+/**
+ *  __e1000_write_kmrn_reg - Write kumeran register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary.  Then write the data to PHY register
  *  at the offset using the kumeran interface.  Release any acquired semaphores
  *  before exiting.
  **/
-s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
+static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
+                                  bool locked)
 {
 	u32 kmrnctrlsta;
-	s32 ret_val;
+	s32 ret_val = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
+	if (!locked) {
+		if (!(hw->phy.ops.acquire_phy))
+			goto out;
+
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
+	}
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | data;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
 
 	udelay(2);
-	hw->phy.ops.release_phy(hw);
 
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
+
+out:
 	return ret_val;
 }
 
 /**
+ *  e1000e_write_kmrn_reg -  Write kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore then writes the data to the PHY register at the offset
+ *  using the kumeran interface.  Release the acquired semaphore before exiting.
+ **/
+s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000_write_kmrn_reg(hw, offset, data, false);
+}
+
+/**
+ *  e1000_write_kmrn_reg_locked -  Write kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Write the data to PHY register at the offset using the kumeran interface.
+ *  Assumes semaphore already acquired.
+ **/
+s32 e1000_write_kmrn_reg_locked(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000_write_kmrn_reg(hw, offset, data, true);
+}
+
+/**
  *  e1000_copper_link_setup_82577 - Setup 82577 PHY for copper link
  *  @hw: pointer to the HW structure
  *
@@ -2105,6 +2263,10 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 	u32 page = offset >> IGP_PAGE_SHIFT;
 	u32 page_shift = 0;
 
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
@@ -2112,10 +2274,6 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		goto out;
-
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
@@ -2135,18 +2293,15 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 		/* Page is shifted left, PHY expects (page x 32) */
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
 		                                    (page << page_shift));
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
+		if (ret_val)
 			goto out;
-		}
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 	                                    data);
 
-	hw->phy.ops.release_phy(hw);
-
 out:
+	hw->phy.ops.release_phy(hw);
 	return ret_val;
 }
 
@@ -2167,6 +2322,10 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 	u32 page = offset >> IGP_PAGE_SHIFT;
 	u32 page_shift = 0;
 
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
@@ -2174,10 +2333,6 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		goto out;
-
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
@@ -2197,17 +2352,14 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 		/* Page is shifted left, PHY expects (page x 32) */
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
 		                                    (page << page_shift));
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
+		if (ret_val)
 			goto out;
-		}
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 	                                   data);
-	hw->phy.ops.release_phy(hw);
-
 out:
+	hw->phy.ops.release_phy(hw);
 	return ret_val;
 }
 
@@ -2226,17 +2378,17 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 	s32 ret_val;
 	u16 page = (u16)(offset >> IGP_PAGE_SHIFT);
 
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
 							 true);
-		return ret_val;
+		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
-
 	hw->phy.addr = 1;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
@@ -2245,16 +2397,14 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 		ret_val = e1000e_write_phy_reg_mdic(hw, BM_PHY_PAGE_SELECT,
 						    page);
 
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
-			return ret_val;
-		}
+		if (ret_val)
+			goto out;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					   data);
+out:
 	hw->phy.ops.release_phy(hw);
-
 	return ret_val;
 }
 
@@ -2272,17 +2422,17 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 	s32 ret_val;
 	u16 page = (u16)(offset >> IGP_PAGE_SHIFT);
 
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
 							 false);
-		return ret_val;
+		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
-
 	hw->phy.addr = 1;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
@@ -2290,17 +2440,15 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 		ret_val = e1000e_write_phy_reg_mdic(hw, BM_PHY_PAGE_SELECT,
 						    page);
 
-		if (ret_val) {
-			hw->phy.ops.release_phy(hw);
-			return ret_val;
-		}
+		if (ret_val)
+			goto out;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					    data);
 
+out:
 	hw->phy.ops.release_phy(hw);
-
 	return ret_val;
 }
 
@@ -2320,6 +2468,8 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
  *  3) Write the address using the address opcode (0x11)
  *  4) Read or write the data using the data opcode (0x12)
  *  5) Restore 769_17.2 to its original value
+ *
+ *  Assumes semaphore already acquired.
  **/
 static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read)
@@ -2327,20 +2477,12 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	s32 ret_val;
 	u16 reg = BM_PHY_REG_NUM(offset);
 	u16 phy_reg = 0;
-	u8  phy_acquired = 1;
-
 
 	/* Gig must be disabled for MDIO accesses to page 800 */
 	if ((hw->mac.type == e1000_pchlan) &&
 	   (!(er32(PHY_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)))
 		hw_dbg(hw, "Attempting to access page 800 while gig enabled\n");
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val) {
-		phy_acquired = 0;
-		goto out;
-	}
-
 	/* All operations in this function are phy address 1 */
 	hw->phy.addr = 1;
 
@@ -2397,8 +2539,6 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
 
 out:
-	if (phy_acquired == 1)
-		hw->phy.ops.release_phy(hw);
 	return ret_val;
 }
 
@@ -2439,52 +2579,63 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 	return 0;
 }
 
+/**
+ *  e1000_set_mdio_slow_mode_hv - Set slow MDIO access mode
+ *  @hw:   pointer to the HW structure
+ *  @slow: true for slow mode, false for normal mode
+ *
+ *  Assumes semaphore already acquired.
+ **/
 s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow)
 {
 	s32 ret_val = 0;
 	u16 data = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		return ret_val;
-
 	/* Set MDIO mode - page 769, register 16: 0x2580==slow, 0x2180==fast */
 	hw->phy.addr = 1;
 	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
 				         (BM_PORT_CTRL_PAGE << IGP_PAGE_SHIFT));
-	if (ret_val) {
-		hw->phy.ops.release_phy(hw);
-		return ret_val;
-	}
+	if (ret_val)
+		goto out;
+
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_CS_CTRL1,
 	                                   (0x2180 | (slow << 10)));
+	if (ret_val)
+		goto out;
 
 	/* dummy read when reverting to fast mode - throw away result */
 	if (!slow)
-		e1000e_read_phy_reg_mdic(hw, BM_CS_CTRL1, &data);
-
-	hw->phy.ops.release_phy(hw);
+		ret_val = e1000e_read_phy_reg_mdic(hw, BM_CS_CTRL1, &data);
 
+out:
 	return ret_val;
 }
 
 /**
- *  e1000_read_phy_reg_hv -  Read HV PHY register
+ *  __e1000_read_phy_reg_hv -  Read HV PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary, then reads the PHY register at offset
- *  and storing the retrieved information in data.  Release any acquired
+ *  and stores the retrieved information in data.  Release any acquired
  *  semaphore before exiting.
  **/
-s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data)
+static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
+                                   bool locked)
 {
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
 	u16 reg = BM_PHY_REG_NUM(offset);
 	bool in_slow_mode = false;
 
+	if (!locked) {
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/* Workaround failure in MDIO access while cable is disconnected */
 	if ((hw->phy.type == e1000_phy_82577) &&
 	    !(er32(STATUS) & E1000_STATUS_LU)) {
@@ -2508,10 +2659,6 @@ s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		goto out;
-
 	hw->phy.addr = e1000_get_phy_addr_for_hv_page(page);
 
 	if (page == HV_INTC_FC_PAGE_START)
@@ -2529,42 +2676,76 @@ s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data)
 			ret_val = e1000e_write_phy_reg_mdic(hw,
 			                             IGP01E1000_PHY_PAGE_SELECT,
 			                             (page << IGP_PAGE_SHIFT));
-			if (ret_val) {
-				hw->phy.ops.release_phy(hw);
-				goto out;
-			}
 			hw->phy.addr = phy_addr;
 		}
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
 	                                  data);
-	hw->phy.ops.release_phy(hw);
-
 out:
 	/* Revert to MDIO fast mode, if applicable */
 	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
+
 	return ret_val;
 }
 
 /**
- *  e1000_write_phy_reg_hv - Write HV PHY register
+ *  e1000_read_phy_reg_hv -  Read HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore then reads the PHY register at offset and stores
+ *  the retrieved information in data.  Release the acquired semaphore
+ *  before exiting.
+ **/
+s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000_read_phy_reg_hv(hw, offset, data, false);
+}
+
+/**
+ *  e1000_read_phy_reg_hv_locked -  Read HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Reads the PHY register at offset and stores the retrieved information
+ *  in data.  Assumes semaphore already acquired.
+ **/
+s32 e1000_read_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return __e1000_read_phy_reg_hv(hw, offset, data, true);
+}
+
+/**
+ *  __e1000_write_phy_reg_hv - Write HV PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
+ *  @locked: semaphore has already been acquired or not
  *
  *  Acquires semaphore, if necessary, then writes the data to PHY register
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
-s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
+static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
+                                    bool locked)
 {
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
 	u16 reg = BM_PHY_REG_NUM(offset);
 	bool in_slow_mode = false;
 
+	if (!locked) {
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/* Workaround failure in MDIO access while cable is disconnected */
 	if ((hw->phy.type == e1000_phy_82577) &&
 	    !(er32(STATUS) & E1000_STATUS_LU)) {
@@ -2588,10 +2769,6 @@ s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val)
-		goto out;
-
 	hw->phy.addr = e1000_get_phy_addr_for_hv_page(page);
 
 	if (page == HV_INTC_FC_PAGE_START)
@@ -2607,15 +2784,10 @@ s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
 	    ((MAX_PHY_REG_ADDRESS & reg) == 0) &&
 	    (data & (1 << 11))) {
 		u16 data2 = 0x7EFF;
-		hw->phy.ops.release_phy(hw);
 		ret_val = e1000_access_phy_debug_regs_hv(hw, (1 << 6) | 0x3,
 		                                         &data2, false);
 		if (ret_val)
 			goto out;
-
-		ret_val = hw->phy.ops.acquire_phy(hw);
-		if (ret_val)
-			goto out;
 	}
 
 	if (reg > MAX_PHY_MULTI_PAGE_REG) {
@@ -2630,27 +2802,53 @@ s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
 			ret_val = e1000e_write_phy_reg_mdic(hw,
 			                             IGP01E1000_PHY_PAGE_SELECT,
 			                             (page << IGP_PAGE_SHIFT));
-			if (ret_val) {
-				hw->phy.ops.release_phy(hw);
-				goto out;
-			}
 			hw->phy.addr = phy_addr;
 		}
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
 	                                  data);
-	hw->phy.ops.release_phy(hw);
 
 out:
 	/* Revert to MDIO fast mode, if applicable */
 	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 
+	if (!locked)
+		hw->phy.ops.release_phy(hw);
+
 	return ret_val;
 }
 
 /**
+ *  e1000_write_phy_reg_hv - Write HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore then writes the data to PHY register at the offset.
+ *  Release the acquired semaphores before exiting.
+ **/
+s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000_write_phy_reg_hv(hw, offset, data, false);
+}
+
+/**
+ *  e1000_write_phy_reg_hv_locked - Write HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Writes the data to PHY register at the offset.  Assumes semaphore
+ *  already acquired.
+ **/
+s32 e1000_write_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return __e1000_write_phy_reg_hv(hw, offset, data, true);
+}
+
+/**
  *  e1000_get_phy_addr_for_hv_page - Get PHY adrress based on page
  *  @page: page to be accessed
  **/
@@ -2671,10 +2869,9 @@ static u32 e1000_get_phy_addr_for_hv_page(u32 page)
  *  @data: pointer to the data to be read or written
  *  @read: determines if operation is read or written
  *
- *  Acquires semaphore, if necessary, then reads the PHY register at offset
- *  and storing the retreived information in data.  Release any acquired
- *  semaphores before exiting.  Note that the procedure to read these regs
- *  uses the address port and data port to read/write.
+ *  Reads the PHY register at offset and stores the retreived information
+ *  in data.  Assumes semaphore already acquired.  Note that the procedure
+ *  to read these regs uses the address port and data port to read/write.
  **/
 static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
                                           u16 *data, bool read)
@@ -2682,20 +2879,12 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 	s32 ret_val;
 	u32 addr_reg = 0;
 	u32 data_reg = 0;
-	u8  phy_acquired = 1;
 
 	/* This takes care of the difference with desktop vs mobile phy */
 	addr_reg = (hw->phy.type == e1000_phy_82578) ?
 	           I82578_ADDR_REG : I82577_ADDR_REG;
 	data_reg = addr_reg + 1;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
-	if (ret_val) {
-		hw_dbg(hw, "Could not acquire PHY\n");
-		phy_acquired = 0;
-		goto out;
-	}
-
 	/* All operations in this function are phy address 2 */
 	hw->phy.addr = 2;
 
@@ -2718,8 +2907,6 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 	}
 
 out:
-	if (phy_acquired == 1)
-		hw->phy.ops.release_phy(hw);
 	return ret_val;
 }
 

