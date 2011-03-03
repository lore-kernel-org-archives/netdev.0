From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 17/24] ixgbe: Drop unused code for setting up unicast addresses
Date: Thu,  3 Mar 2011 05:03:42 -0800
Message-ID: <1299157429-15878-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758208Ab1CCNEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:25 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change removes the unused code that was setting up the uc_addr_list.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |    1 -
 drivers/net/ixgbe/ixgbe_82599.c  |    1 -
 drivers/net/ixgbe/ixgbe_common.c |   99 --------------------------------------
 drivers/net/ixgbe/ixgbe_common.h |    2 -
 drivers/net/ixgbe/ixgbe_type.h   |    1 -
 drivers/net/ixgbe/ixgbe_x540.c   |    1 -
 6 files changed, 0 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index bff7011..a5b83b7 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1198,7 +1198,6 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.set_vmdq		= &ixgbe_set_vmdq_82598,
 	.clear_vmdq		= &ixgbe_clear_vmdq_82598,
 	.init_rx_addrs		= &ixgbe_init_rx_addrs_generic,
-	.update_uc_addr_list	= &ixgbe_update_uc_addr_list_generic,
 	.update_mc_addr_list	= &ixgbe_update_mc_addr_list_generic,
 	.enable_mc		= &ixgbe_enable_mc_generic,
 	.disable_mc		= &ixgbe_disable_mc_generic,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 126a06f..69d345b 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -2035,7 +2035,6 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
 	.clear_vmdq             = &ixgbe_clear_vmdq_generic,
 	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
-	.update_uc_addr_list    = &ixgbe_update_uc_addr_list_generic,
 	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
 	.enable_mc              = &ixgbe_enable_mc_generic,
 	.disable_mc             = &ixgbe_disable_mc_generic,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index b94634f..4fa195e 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -47,7 +47,6 @@ static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
 
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
-static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
 
 /**
@@ -1367,104 +1366,6 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_add_uc_addr - Adds a secondary unicast address.
- *  @hw: pointer to hardware structure
- *  @addr: new address
- *
- *  Adds it to unused receive address register or goes into promiscuous mode.
- **/
-static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
-{
-	u32 rar_entries = hw->mac.num_rar_entries;
-	u32 rar;
-
-	hw_dbg(hw, " UC Addr = %.2X %.2X %.2X %.2X %.2X %.2X\n",
-	          addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
-
-	/*
-	 * Place this address in the RAR if there is room,
-	 * else put the controller into promiscuous mode
-	 */
-	if (hw->addr_ctrl.rar_used_count < rar_entries) {
-		rar = hw->addr_ctrl.rar_used_count;
-		hw->mac.ops.set_rar(hw, rar, addr, vmdq, IXGBE_RAH_AV);
-		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
-		hw->addr_ctrl.rar_used_count++;
-	} else {
-		hw->addr_ctrl.overflow_promisc++;
-	}
-
-	hw_dbg(hw, "ixgbe_add_uc_addr Complete\n");
-}
-
-/**
- *  ixgbe_update_uc_addr_list_generic - Updates MAC list of secondary addresses
- *  @hw: pointer to hardware structure
- *  @netdev: pointer to net device structure
- *
- *  The given list replaces any existing list.  Clears the secondary addrs from
- *  receive address registers.  Uses unused receive address registers for the
- *  first secondary addresses, and falls back to promiscuous mode as needed.
- *
- *  Drivers using secondary unicast addresses must set user_set_promisc when
- *  manually putting the device into promiscuous mode.
- **/
-s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
-				      struct net_device *netdev)
-{
-	u32 i;
-	u32 old_promisc_setting = hw->addr_ctrl.overflow_promisc;
-	u32 uc_addr_in_use;
-	u32 fctrl;
-	struct netdev_hw_addr *ha;
-
-	/*
-	 * Clear accounting of old secondary address list,
-	 * don't count RAR[0]
-	 */
-	uc_addr_in_use = hw->addr_ctrl.rar_used_count - 1;
-	hw->addr_ctrl.rar_used_count -= uc_addr_in_use;
-	hw->addr_ctrl.overflow_promisc = 0;
-
-	/* Zero out the other receive addresses */
-	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use + 1);
-	for (i = 0; i < uc_addr_in_use; i++) {
-		IXGBE_WRITE_REG(hw, IXGBE_RAL(1+i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RAH(1+i), 0);
-	}
-
-	/* Add the new addresses */
-	netdev_for_each_uc_addr(ha, netdev) {
-		hw_dbg(hw, " Adding the secondary addresses:\n");
-		ixgbe_add_uc_addr(hw, ha->addr, 0);
-	}
-
-	if (hw->addr_ctrl.overflow_promisc) {
-		/* enable promisc if not already in overflow or set by user */
-		if (!old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
-			hw_dbg(hw, " Entering address overflow promisc mode\n");
-			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-			fctrl |= IXGBE_FCTRL_UPE;
-			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
-			hw->addr_ctrl.uc_set_promisc = true;
-		}
-	} else {
-		/* only disable if set by overflow, not by user */
-		if ((old_promisc_setting && hw->addr_ctrl.uc_set_promisc) &&
-		   !(hw->addr_ctrl.user_set_promisc)) {
-			hw_dbg(hw, " Leaving address overflow promisc mode\n");
-			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-			fctrl &= ~IXGBE_FCTRL_UPE;
-			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
-			hw->addr_ctrl.uc_set_promisc = false;
-		}
-	}
-
-	hw_dbg(hw, "ixgbe_update_uc_addr_list_generic Complete\n");
-	return 0;
-}
-
-/**
  *  ixgbe_mta_vector - Determines bit-vector in multicast table to set
  *  @hw: pointer to hardware structure
  *  @mc_addr: the multicast address
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 90cceb4..90ac609 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -63,8 +63,6 @@ s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw);
 s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
 				      struct net_device *netdev);
-s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
-				      struct net_device *netdev);
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f6d0d4d..8e0a213 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2517,7 +2517,6 @@ struct ixgbe_mac_operations {
 	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
-	s32 (*update_uc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*enable_mc)(struct ixgbe_hw *);
 	s32 (*disable_mc)(struct ixgbe_hw *);
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 3229398..fbc0a8b 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -686,7 +686,6 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
 	.clear_vmdq             = &ixgbe_clear_vmdq_generic,
 	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
-	.update_uc_addr_list    = &ixgbe_update_uc_addr_list_generic,
 	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
 	.enable_mc              = &ixgbe_enable_mc_generic,
 	.disable_mc             = &ixgbe_disable_mc_generic,
-- 
1.7.4

