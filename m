From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 16/24] ixgbe: rework ixgbe MTA handling to not drop packets
Date: Thu,  3 Mar 2011 05:03:41 -0800
Message-ID: <1299157429-15878-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, daveboutcher@gmail.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758207Ab1CCNEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:24 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change modifies the ixgbe drivers so that it will not drop the
multicast filters while updating them.  Instead it uses an intermediate
table to store the filter and then writes that filter to the hardware.

Based on original patch from Dave Boutcher <daveboutcher@gmail.com>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Reported-by: Dave Boutcher <daveboutcher@gmail.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   68 +++++---------------------------------
 drivers/net/ixgbe/ixgbe_type.h   |    3 +-
 2 files changed, 11 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 882a350..b94634f 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -46,8 +46,6 @@ static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
 
-static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
-static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
@@ -1310,38 +1308,6 @@ s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index)
 }
 
 /**
- *  ixgbe_enable_rar - Enable Rx address register
- *  @hw: pointer to hardware structure
- *  @index: index into the RAR table
- *
- *  Enables the select receive address register.
- **/
-static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index)
-{
-	u32 rar_high;
-
-	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
-	rar_high |= IXGBE_RAH_AV;
-	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
-}
-
-/**
- *  ixgbe_disable_rar - Disable Rx address register
- *  @hw: pointer to hardware structure
- *  @index: index into the RAR table
- *
- *  Disables the select receive address register.
- **/
-static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index)
-{
-	u32 rar_high;
-
-	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
-	rar_high &= (~IXGBE_RAH_AV);
-	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
-}
-
-/**
  *  ixgbe_init_rx_addrs_generic - Initializes receive address filters.
  *  @hw: pointer to hardware structure
  *
@@ -1387,7 +1353,6 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 	}
 
 	/* Clear the MTA */
-	hw->addr_ctrl.mc_addr_in_rar_count = 0;
 	hw->addr_ctrl.mta_in_use = 0;
 	IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
 
@@ -1421,8 +1386,7 @@ static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
 	 * else put the controller into promiscuous mode
 	 */
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
-		rar = hw->addr_ctrl.rar_used_count -
-		      hw->addr_ctrl.mc_addr_in_rar_count;
+		rar = hw->addr_ctrl.rar_used_count;
 		hw->mac.ops.set_rar(hw, rar, addr, vmdq, IXGBE_RAH_AV);
 		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
 		hw->addr_ctrl.rar_used_count++;
@@ -1551,7 +1515,6 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 	u32 vector;
 	u32 vector_bit;
 	u32 vector_reg;
-	u32 mta_reg;
 
 	hw->addr_ctrl.mta_in_use++;
 
@@ -1569,9 +1532,7 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 	 */
 	vector_reg = (vector >> 5) & 0x7F;
 	vector_bit = vector & 0x1F;
-	mta_reg = IXGBE_READ_REG(hw, IXGBE_MTA(vector_reg));
-	mta_reg |= (1 << vector_bit);
-	IXGBE_WRITE_REG(hw, IXGBE_MTA(vector_reg), mta_reg);
+	hw->mac.mta_shadow[vector_reg] |= (1 << vector_bit);
 }
 
 /**
@@ -1597,18 +1558,21 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
 	hw->addr_ctrl.num_mc_addrs = netdev_mc_count(netdev);
 	hw->addr_ctrl.mta_in_use = 0;
 
-	/* Clear the MTA */
+	/* Clear mta_shadow */
 	hw_dbg(hw, " Clearing MTA\n");
-	for (i = 0; i < hw->mac.mcft_size; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
+	memset(&hw->mac.mta_shadow, 0, sizeof(hw->mac.mta_shadow));
 
-	/* Add the new addresses */
+	/* Update mta shadow */
 	netdev_for_each_mc_addr(ha, netdev) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
 		ixgbe_set_mta(hw, ha->addr);
 	}
 
 	/* Enable mta */
+	for (i = 0; i < hw->mac.mcft_size; i++)
+		IXGBE_WRITE_REG_ARRAY(hw, IXGBE_MTA(0), i,
+				      hw->mac.mta_shadow[i]);
+
 	if (hw->addr_ctrl.mta_in_use > 0)
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL,
 		                IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
@@ -1625,15 +1589,8 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
  **/
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 i;
-	u32 rar_entries = hw->mac.num_rar_entries;
 	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	if (a->mc_addr_in_rar_count > 0)
-		for (i = (rar_entries - a->mc_addr_in_rar_count);
-		     i < rar_entries; i++)
-			ixgbe_enable_rar(hw, i);
-
 	if (a->mta_in_use > 0)
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, IXGBE_MCSTCTRL_MFE |
 		                hw->mac.mc_filter_type);
@@ -1649,15 +1606,8 @@ s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw)
  **/
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 i;
-	u32 rar_entries = hw->mac.num_rar_entries;
 	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	if (a->mc_addr_in_rar_count > 0)
-		for (i = (rar_entries - a->mc_addr_in_rar_count);
-		     i < rar_entries; i++)
-			ixgbe_disable_rar(hw, i);
-
 	if (a->mta_in_use > 0)
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index b1ae185..f6d0d4d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2358,7 +2358,6 @@ enum ixgbe_bus_width {
 struct ixgbe_addr_filter_info {
 	u32 num_mc_addrs;
 	u32 rar_used_count;
-	u32 mc_addr_in_rar_count;
 	u32 mta_in_use;
 	u32 overflow_promisc;
 	bool uc_set_promisc;
@@ -2570,6 +2569,8 @@ struct ixgbe_mac_info {
 	u16                             wwnn_prefix;
 	/* prefix for World Wide Port Name (WWPN) */
 	u16                             wwpn_prefix;
+#define IXGBE_MAX_MTA			128
+	u32				mta_shadow[IXGBE_MAX_MTA];
 	s32                             mc_filter_type;
 	u32                             mcft_size;
 	u32                             vft_size;
-- 
1.7.4

