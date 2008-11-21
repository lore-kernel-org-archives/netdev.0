From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 07/14] e1000e: ESB2 config after link up
Date: Fri, 21 Nov 2008 11:00:52 -0800
Message-ID: <20081121190052.32313.88452.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:51736 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753883AbYKUTBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:01:11 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On ESB2, the MAC-to-PHY (Kumeran) interface must be configured after link
is up before any traffic is sent; a new PHY operations function pointer is
provided for this.  To facilitate read/write of the Kumeran registers
without blocking PHY register writes, the driver/firmware synchronization
method which previously used a hardware semaphore for both PHY and Kumeran
register accesses is now split.  New Kumeran register read/write functions
utilize this new synchronization method.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |    3 +
 drivers/net/e1000e/es2lan.c |  192 +++++++++++++++++++++++++++++++++++--------
 drivers/net/e1000e/hw.h     |    1 
 drivers/net/e1000e/netdev.c |    8 ++
 4 files changed, 167 insertions(+), 37 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cbb1707..11e72b6 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1394,6 +1394,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_phy_reg		= e1000e_write_phy_reg_igp,
+	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_m88 = {
@@ -1410,6 +1411,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_phy_reg		= e1000e_write_phy_reg_m88,
+	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_bm = {
@@ -1426,6 +1428,7 @@ static struct e1000_phy_operations e82_phy_ops_bm = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_phy_reg		= e1000e_write_phy_reg_bm2,
+	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index da9c09c..db51114 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -112,6 +112,11 @@ static void e1000_initialize_hw_bits_80003es2lan(struct e1000_hw *hw);
 static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw);
 static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw);
 static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex);
+static s32 e1000_cfg_on_link_up_80003es2lan(struct e1000_hw *hw);
+static s32  e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
+                                            u16 *data);
+static s32  e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
+                                             u16 data);
 
 /**
  *  e1000_init_phy_params_80003es2lan - Init ESB2 PHY func ptrs.
@@ -275,8 +280,6 @@ static s32 e1000_acquire_phy_80003es2lan(struct e1000_hw *hw)
 	u16 mask;
 
 	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
-	mask |= E1000_SWFW_CSR_SM;
-
 	return e1000_acquire_swfw_sync_80003es2lan(hw, mask);
 }
 
@@ -292,7 +295,36 @@ static void e1000_release_phy_80003es2lan(struct e1000_hw *hw)
 	u16 mask;
 
 	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
-	mask |= E1000_SWFW_CSR_SM;
+	e1000_release_swfw_sync_80003es2lan(hw, mask);
+}
+
+/**
+ *  e1000_acquire_mac_csr_80003es2lan - Acquire rights to access Kumeran register
+ *  @hw: pointer to the HW structure
+ *
+ *  Acquire the semaphore to access the Kumeran interface.
+ *
+ **/
+static s32 e1000_acquire_mac_csr_80003es2lan(struct e1000_hw *hw)
+{
+	u16 mask;
+
+	mask = E1000_SWFW_CSR_SM;
+
+	return e1000_acquire_swfw_sync_80003es2lan(hw, mask);
+}
+
+/**
+ *  e1000_release_mac_csr_80003es2lan - Release rights to access Kumeran Register
+ *  @hw: pointer to the HW structure
+ *
+ *  Release the semaphore used to access the Kumeran interface
+ **/
+static void e1000_release_mac_csr_80003es2lan(struct e1000_hw *hw)
+{
+	u16 mask;
+
+	mask = E1000_SWFW_CSR_SM;
 
 	e1000_release_swfw_sync_80003es2lan(hw, mask);
 }
@@ -347,7 +379,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	u32 swmask = mask;
 	u32 fwmask = mask << 16;
 	s32 i = 0;
-	s32 timeout = 200;
+	s32 timeout = 50;
 
 	while (i < timeout) {
 		if (e1000e_get_hw_semaphore(hw))
@@ -715,13 +747,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 		ret_val = e1000e_get_speed_and_duplex_copper(hw,
 								    speed,
 								    duplex);
-		if (ret_val)
-			return ret_val;
-		if (*speed == SPEED_1000)
-			ret_val = e1000_cfg_kmrn_1000_80003es2lan(hw);
-		else
-			ret_val = e1000_cfg_kmrn_10_100_80003es2lan(hw,
-							      *duplex);
+		hw->phy.ops.cfg_on_link_up(hw);
 	} else {
 		ret_val = e1000e_get_speed_and_duplex_fiber_serdes(hw,
 								  speed,
@@ -763,8 +789,10 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 
 	ctrl = er32(CTRL);
 
+	ret_val = e1000_acquire_phy_80003es2lan(hw);
 	hw_dbg(hw, "Issuing a global reset to MAC\n");
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
+	e1000_release_phy_80003es2lan(hw);
 
 	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val)
@@ -907,8 +935,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 	u32 ctrl_ext;
-	u32 i = 0;
-	u16 data, data2;
+	u16 data;
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL, &data);
 	if (ret_val)
@@ -972,19 +999,20 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	}
 
 	/* Bypass Rx and Tx FIFO's */
-	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
+					E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
 					E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
 					E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS);
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000e_read_kmrn_reg(hw,
+	ret_val = e1000_read_kmrn_reg_80003es2lan(hw,
 				       E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
 				       &data);
 	if (ret_val)
 		return ret_val;
 	data |= E1000_KMRNCTRLSTA_OPMODE_E_IDLE;
-	ret_val = e1000e_write_kmrn_reg(hw,
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
 					E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
 					data);
 	if (ret_val)
@@ -1019,18 +1047,9 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		do {
-			ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
-					   &data);
-			if (ret_val)
-				return ret_val;
-
-			ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
-					   &data2);
-			if (ret_val)
-				return ret_val;
-			i++;
-		} while ((data != data2) && (i < GG82563_MAX_KMRN_RETRY));
+		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &data);
+		if (ret_val)
+			return ret_val;
 
 		data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 		ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, data);
@@ -1077,23 +1096,27 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	 * iteration and increase the max iterations when
 	 * polling the phy; this fixes erroneous timeouts at 10Mbps.
 	 */
-	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 4),
+	                                           0xFFFF);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000e_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
+	ret_val = e1000_read_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 9),
+	                                          &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
-	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 9),
+	                                           reg_data);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000e_read_kmrn_reg(hw,
+	ret_val = e1000_read_kmrn_reg_80003es2lan(hw,
 				      E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 				      &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= E1000_KMRNCTRLSTA_INB_CTRL_DIS_PADDING;
-	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
+					E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 					reg_data);
 	if (ret_val)
 		return ret_val;
@@ -1108,6 +1131,35 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_cfg_on_link_up_80003es2lan - es2 link configuration after link-up
+ *  @hw: pointer to the HW structure
+ *  @duplex: current duplex setting
+ *
+ *  Configure the KMRN interface by applying last minute quirks for
+ *  10/100 operation.
+ **/
+static s32 e1000_cfg_on_link_up_80003es2lan(struct e1000_hw *hw)
+{
+	s32 ret_val = 0;
+	u16 speed;
+	u16 duplex;
+
+	if (hw->phy.media_type == e1000_media_type_copper) {
+		ret_val = e1000e_get_speed_and_duplex_copper(hw, &speed,
+		                                             &duplex);
+		if (ret_val)
+			return ret_val;
+
+		if (speed == SPEED_1000)
+			ret_val = e1000_cfg_kmrn_1000_80003es2lan(hw);
+		else
+			ret_val = e1000_cfg_kmrn_10_100_80003es2lan(hw, duplex);
+	}
+
+	return ret_val;
+}
+
+/**
  *  e1000_cfg_kmrn_10_100_80003es2lan - Apply "quirks" for 10/100 operation
  *  @hw: pointer to the HW structure
  *  @duplex: current duplex setting
@@ -1123,8 +1175,9 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 	u16 reg_data, reg_data2;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-					reg_data);
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
+	                               E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+	                               reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1170,8 +1223,9 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	u32 i = 0;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-					reg_data);
+	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
+	                               E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+	                               reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1199,6 +1253,69 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_read_kmrn_reg_80003es2lan - Read kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquire semaphore, then read the PHY register at offset
+ *  using the kumeran interface.  The information retrieved is stored in data.
+ *  Release the semaphore before exiting.
+ **/
+s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	u32 kmrnctrlsta;
+	s32 ret_val = 0;
+
+	ret_val = e1000_acquire_mac_csr_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
+	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
+	               E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
+	ew32(KMRNCTRLSTA, kmrnctrlsta);
+
+	udelay(2);
+
+	kmrnctrlsta = er32(KMRNCTRLSTA);
+	*data = (u16)kmrnctrlsta;
+
+	e1000_release_mac_csr_80003es2lan(hw);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_write_kmrn_reg_80003es2lan - Write kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquire semaphore, then write the data to PHY register
+ *  at the offset using the kumeran interface.  Release semaphore
+ *  before exiting.
+ **/
+s32 e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	u32 kmrnctrlsta;
+	s32 ret_val = 0;
+
+	ret_val = e1000_acquire_mac_csr_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
+	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
+	               E1000_KMRNCTRLSTA_OFFSET) | data;
+	ew32(KMRNCTRLSTA, kmrnctrlsta);
+
+	udelay(2);
+
+	e1000_release_mac_csr_80003es2lan(hw);
+
+	return ret_val;
+}
+
+/**
  *  e1000_clear_hw_cntrs_80003es2lan - Clear device specific hardware counters
  *  @hw: pointer to the HW structure
  *
@@ -1276,6 +1393,7 @@ static struct e1000_phy_operations es2_phy_ops = {
 	.set_d0_lplu_state  	= NULL,
 	.set_d3_lplu_state  	= e1000e_set_d3_lplu_state,
 	.write_phy_reg      	= e1000_write_phy_reg_gg82563_80003es2lan,
+	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
 };
 
 static struct e1000_nvm_operations es2_nvm_ops = {
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index c4ffd4b..ac1efb9 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -739,6 +739,7 @@ struct e1000_phy_operations {
 	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
 	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
 	s32  (*write_phy_reg)(struct e1000_hw *, u32, u16);
+	s32  (*cfg_on_link_up)(struct e1000_hw *);
 };
 
 /* Function pointers for the NVM. */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ae6dce5..7eb1a36 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3493,6 +3493,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 					struct e1000_adapter, watchdog_task);
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
+	struct e1000_phy_info *phy = &adapter->hw.phy;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 link, tctl;
@@ -3599,6 +3600,13 @@ static void e1000_watchdog_task(struct work_struct *work)
 			tctl |= E1000_TCTL_EN;
 			ew32(TCTL, tctl);
 
+                        /*
+			 * Perform any post-link-up configuration before
+			 * reporting link up.
+			 */
+			if (phy->ops.cfg_on_link_up)
+				phy->ops.cfg_on_link_up(hw);
+
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 

