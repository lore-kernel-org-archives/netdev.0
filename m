From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/9] e1000e: provide family-specific functions to
	manage VLAN filter arrays
Date: Tue, 01 Dec 2009 17:46:43 -0800
Message-ID: <20091202014641.396.57708.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:46466 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752036AbZLBBqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:46:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The two MAC-families that have VLAN filter table register arrays manage
each a bit differently from one another, so provide family-specific
functions for managing the register arrays and function pointers to access
the appropriate function.  Also make sure attempts to access these
register arrays are not done on parts not supporting that feature.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |    9 ++++++---
 drivers/net/e1000e/e1000.h  |    4 ++--
 drivers/net/e1000e/es2lan.c |    4 +++-
 drivers/net/e1000e/hw.h     |    2 ++
 drivers/net/e1000e/lib.c    |   21 +++++++++++++++++++--
 drivers/net/e1000e/netdev.c |   21 +++++++++++++--------
 6 files changed, 45 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 62bbc6e..8ea3ed7 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -65,6 +65,7 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw);
 static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw);
 static s32 e1000_setup_link_82571(struct e1000_hw *hw);
 static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw);
+static void e1000_clear_vfta_82571(struct e1000_hw *hw);
 static bool e1000_check_mng_mode_82574(struct e1000_hw *hw);
 static s32 e1000_led_on_82574(struct e1000_hw *hw);
 static void e1000_put_hw_semaphore_82571(struct e1000_hw *hw);
@@ -949,7 +950,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
-	e1000e_clear_vfta(hw);
+	mac->ops.clear_vfta(hw);
 
 	/* Setup the receive address. */
 	/*
@@ -1128,13 +1129,13 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_clear_vfta - Clear VLAN filter table
+ *  e1000_clear_vfta_82571 - Clear VLAN filter table
  *  @hw: pointer to the HW structure
  *
  *  Clears the register array which contains the VLAN filter table by
  *  setting all the values to 0.
  **/
-void e1000e_clear_vfta(struct e1000_hw *hw)
+static void e1000_clear_vfta_82571(struct e1000_hw *hw)
 {
 	u32 offset;
 	u32 vfta_value = 0;
@@ -1656,6 +1657,8 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	/* .led_on: mac type dependent */
 	.led_off		= e1000e_led_off_generic,
 	.update_mc_addr_list	= e1000_update_mc_addr_list_82571,
+	.write_vfta		= e1000_write_vfta_generic,
+	.clear_vfta		= e1000_clear_vfta_82571,
 	.reset_hw		= e1000_reset_hw_82571,
 	.init_hw		= e1000_init_hw_82571,
 	.setup_link		= e1000_setup_link_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 3102d73..4c08752 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -509,7 +509,7 @@ extern s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw);
 extern s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw);
 extern s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw);
 extern s32 e1000e_setup_link(struct e1000_hw *hw);
-extern void e1000e_clear_vfta(struct e1000_hw *hw);
+extern void e1000_clear_vfta_generic(struct e1000_hw *hw);
 extern void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
 extern void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
 					       u8 *mc_addr_list,
@@ -525,7 +525,7 @@ extern void e1000e_config_collision_dist(struct e1000_hw *hw);
 extern s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw);
 extern s32 e1000e_force_mac_fc(struct e1000_hw *hw);
 extern s32 e1000e_blink_led(struct e1000_hw *hw);
-extern void e1000e_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
+extern void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value);
 extern void e1000e_reset_adaptive(struct e1000_hw *hw);
 extern void e1000e_update_adaptive(struct e1000_hw *hw);
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index e505798..3ff932f 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -807,7 +807,7 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
-	e1000e_clear_vfta(hw);
+	mac->ops.clear_vfta(hw);
 
 	/* Setup the receive address. */
 	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
@@ -1350,6 +1350,8 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
 	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
+	.write_vfta		= e1000_write_vfta_generic,
+	.clear_vfta		= e1000_clear_vfta_generic,
 	.reset_hw		= e1000_reset_hw_80003es2lan,
 	.init_hw		= e1000_init_hw_80003es2lan,
 	.setup_link		= e1000e_setup_link,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 426155c..6c3d55f 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -741,6 +741,7 @@ struct e1000_mac_operations {
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*cleanup_led)(struct e1000_hw *);
 	void (*clear_hw_cntrs)(struct e1000_hw *);
+	void (*clear_vfta)(struct e1000_hw *);
 	s32  (*get_bus_info)(struct e1000_hw *);
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
@@ -751,6 +752,7 @@ struct e1000_mac_operations {
 	s32  (*setup_link)(struct e1000_hw *);
 	s32  (*setup_physical_interface)(struct e1000_hw *);
 	s32  (*setup_led)(struct e1000_hw *);
+	void (*write_vfta)(struct e1000_hw *, u32, u32);
 };
 
 /* Function pointers for the PHY. */
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index f690a10..e3976ea 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -82,7 +82,24 @@ s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_write_vfta - Write value to VLAN filter table
+ *  e1000_clear_vfta_generic - Clear VLAN filter table
+ *  @hw: pointer to the HW structure
+ *
+ *  Clears the register array which contains the VLAN filter table by
+ *  setting all the values to 0.
+ **/
+void e1000_clear_vfta_generic(struct e1000_hw *hw)
+{
+	u32 offset;
+
+	for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
+		E1000_WRITE_REG_ARRAY(hw, E1000_VFTA, offset, 0);
+		e1e_flush();
+	}
+}
+
+/**
+ *  e1000_write_vfta_generic - Write value to VLAN filter table
  *  @hw: pointer to the HW structure
  *  @offset: register offset in VLAN filter table
  *  @value: register value written to VLAN filter table
@@ -90,7 +107,7 @@ s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
  *  Writes value at the given offset in the register array which stores
  *  the VLAN filter table.
  **/
-void e1000e_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
+void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value)
 {
 	E1000_WRITE_REG_ARRAY(hw, E1000_VFTA, offset, value);
 	e1e_flush();
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e546b4e..2381cb7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2031,11 +2031,14 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
+
 	/* add VID to filter table */
-	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
-	vfta |= (1 << (vid & 0x1F));
-	e1000e_write_vfta(hw, index, vfta);
+	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
+		index = (vid >> 5) & 0x7F;
+		vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
+		vfta |= (1 << (vid & 0x1F));
+		hw->mac.ops.write_vfta(hw, index, vfta);
+	}
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -2060,10 +2063,12 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	}
 
 	/* remove VID from filter table */
-	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
-	vfta &= ~(1 << (vid & 0x1F));
-	e1000e_write_vfta(hw, index, vfta);
+	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
+		index = (vid >> 5) & 0x7F;
+		vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
+		vfta &= ~(1 << (vid & 0x1F));
+		hw->mac.ops.write_vfta(hw, index, vfta);
+	}
 }
 
 static void e1000_update_mng_vlan(struct e1000_adapter *adapter)

