From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 03/13] ixgbe: Implement HAVE_SET_RX_MODE
Date: Tue, 26 Aug 2008 04:27:02 -0700
Message-ID: <20080826112701.15787.26887.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Christopher Leech <christopher.leech@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603AbYHZL1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:03 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher Leech <christopher.leech@intel.com>

Implement HAVE_SET_RX_MODE in the driver for MC and UC lists.

Signed-off-by: Christopher Leech <christopher.leech@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |    6 ++
 drivers/net/ixgbe/ixgbe_common.c |  123 +++++++++++++++++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_common.h |    4 +
 drivers/net/ixgbe/ixgbe_main.c   |   72 ++++++++++++----------
 drivers/net/ixgbe/ixgbe_type.h   |   14 +++-
 5 files changed, 169 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index f96358b..ba09063 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -36,6 +36,8 @@
 #define IXGBE_82598_MAX_TX_QUEUES 32
 #define IXGBE_82598_MAX_RX_QUEUES 64
 #define IXGBE_82598_RAR_ENTRIES   16
+#define IXGBE_82598_MC_TBL_SIZE  128
+#define IXGBE_82598_VFT_TBL_SIZE 128
 
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
 static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
@@ -60,7 +62,9 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
 	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
 	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.num_rx_addrs = IXGBE_82598_RAR_ENTRIES;
+	hw->mac.mcft_size = IXGBE_82598_MC_TBL_SIZE;
+	hw->mac.vft_size = IXGBE_82598_VFT_TBL_SIZE;
+	hw->mac.num_rar_entries = IXGBE_82598_RAR_ENTRIES;
 
 	/* PHY ops are filled in by default properly for Fiber only */
 	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper) {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 7fd6aeb..a9f4d0e 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -661,7 +661,7 @@ s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
 static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 {
 	u32 i;
-	u32 rar_entries = hw->mac.num_rx_addrs;
+	u32 rar_entries = hw->mac.num_rar_entries;
 
 	/*
 	 * If the current mac address is valid, assume it is a software override
@@ -705,13 +705,114 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
 
 	hw_dbg(hw, " Clearing MTA\n");
-	for (i = 0; i < IXGBE_MC_TBL_SIZE; i++)
+	for (i = 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
 	return 0;
 }
 
 /**
+ *  ixgbe_add_uc_addr - Adds a secondary unicast address.
+ *  @hw: pointer to hardware structure
+ *  @addr: new address
+ *
+ *  Adds it to unused receive address register or goes into promiscuous mode.
+ **/
+void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
+{
+	u32 rar_entries = hw->mac.num_rar_entries;
+	u32 rar;
+
+	hw_dbg(hw, " UC Addr = %.2X %.2X %.2X %.2X %.2X %.2X\n",
+	          addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+	/*
+	 * Place this address in the RAR if there is room,
+	 * else put the controller into promiscuous mode
+	 */
+	if (hw->addr_ctrl.rar_used_count < rar_entries) {
+		rar = hw->addr_ctrl.rar_used_count -
+		      hw->addr_ctrl.mc_addr_in_rar_count;
+		ixgbe_set_rar(hw, rar, addr, 0, IXGBE_RAH_AV);
+		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
+		hw->addr_ctrl.rar_used_count++;
+	} else {
+		hw->addr_ctrl.overflow_promisc++;
+	}
+
+	hw_dbg(hw, "ixgbe_add_uc_addr Complete\n");
+}
+
+/**
+ *  ixgbe_update_uc_addr_list - Updates MAC list of secondary addresses
+ *  @hw: pointer to hardware structure
+ *  @addr_list: the list of new addresses
+ *  @addr_count: number of addresses
+ *  @next: iterator function to walk the address list
+ *
+ *  The given list replaces any existing list.  Clears the secondary addrs from
+ *  receive address registers.  Uses unused receive address registers for the
+ *  first secondary addresses, and falls back to promiscuous mode as needed.
+ *
+ *  Drivers using secondary unicast addresses must set user_set_promisc when
+ *  manually putting the device into promiscuous mode.
+ **/
+s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
+                              u32 addr_count, ixgbe_mc_addr_itr next)
+{
+	u8 *addr;
+	u32 i;
+	u32 old_promisc_setting = hw->addr_ctrl.overflow_promisc;
+	u32 uc_addr_in_use;
+	u32 fctrl;
+	u32 vmdq;
+
+	/*
+	 * Clear accounting of old secondary address list,
+	 * don't count RAR[0]
+	 */
+	uc_addr_in_use = hw->addr_ctrl.rar_used_count -
+	                 hw->addr_ctrl.mc_addr_in_rar_count - 1;
+	hw->addr_ctrl.rar_used_count -= uc_addr_in_use;
+	hw->addr_ctrl.overflow_promisc = 0;
+
+	/* Zero out the other receive addresses */
+	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use);
+	for (i = 1; i <= uc_addr_in_use; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
+	}
+
+	/* Add the new addresses */
+	for (i = 0; i < addr_count; i++) {
+		hw_dbg(hw, " Adding the secondary addresses:\n");
+		addr = next(hw, &addr_list, &vmdq);
+		ixgbe_add_uc_addr(hw, addr);
+	}
+
+	if (hw->addr_ctrl.overflow_promisc) {
+		/* enable promisc if not already in overflow or set by user */
+		if (!old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
+			hw_dbg(hw, " Entering address overflow promisc mode\n");
+			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			fctrl |= IXGBE_FCTRL_UPE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+		}
+	} else {
+		/* only disable if set by overflow, not by user */
+		if (old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
+			hw_dbg(hw, " Leaving address overflow promisc mode\n");
+			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			fctrl &= ~IXGBE_FCTRL_UPE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+		}
+	}
+
+	hw_dbg(hw, "ixgbe_update_uc_addr_list Complete\n");
+	return 0;
+}
+
+/**
  *  ixgbe_mta_vector - Determines bit-vector in multicast table to set
  *  @hw: pointer to hardware structure
  *  @mc_addr: the multicast address
@@ -794,7 +895,7 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
  **/
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 {
-	u32 rar_entries = hw->mac.num_rx_addrs;
+	u32 rar_entries = hw->mac.num_rar_entries;
 
 	hw_dbg(hw, " MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
 		  mc_addr[0], mc_addr[1], mc_addr[2],
@@ -823,7 +924,7 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
  *  @hw: pointer to hardware structure
  *  @mc_addr_list: the list of new multicast addresses
  *  @mc_addr_count: number of addresses
- *  @pad: number of bytes between addresses in the list
+ *  @next: iterator function to walk the multicast address list
  *
  *  The given list replaces any existing list. Clears the MC addrs from receive
  *  address registers and the multicast table. Uses unsed receive address
@@ -831,10 +932,11 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
  *  multicast table.
  **/
 s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, u32 pad)
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
-	u32 rar_entries = hw->mac.num_rx_addrs;
+	u32 rar_entries = hw->mac.num_rar_entries;
+	u32 vmdq;
 
 	/*
 	 * Set the new number of MC addresses that we are being requested to
@@ -854,14 +956,13 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
 
 	/* Clear the MTA */
 	hw_dbg(hw, " Clearing MTA\n");
-	for (i = 0; i < IXGBE_MC_TBL_SIZE; i++)
+	for (i = 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
 	/* Add the new addresses */
 	for (i = 0; i < mc_addr_count; i++) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
-		ixgbe_add_mc_addr(hw, mc_addr_list +
-				  (i * (IXGBE_ETH_LENGTH_OF_ADDRESS + pad)));
+		ixgbe_add_mc_addr(hw, next(hw, &mc_addr_list, &vmdq));
 	}
 
 	/* Enable mta */
@@ -884,11 +985,11 @@ static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw)
 	u32 offset;
 	u32 vlanbyte;
 
-	for (offset = 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+	for (offset = 0; offset < hw->mac.vft_size; offset++)
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
 
 	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
-		for (offset = 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+		for (offset = 0; offset < hw->mac.vft_size; offset++)
 			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
 					0);
 
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index de6ddd5..c75ecba 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -47,7 +47,9 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val);
 s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
 		  u32 enable_addr);
 s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, u32 pad);
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
+s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *uc_addr_list,
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
 s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind, bool vlan_on);
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b14192f..87ef2db 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1619,23 +1619,37 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 	}
 }
 
+static u8 *ixgbe_addr_list_itr(struct ixgbe_hw *hw, u8 **mc_addr_ptr, u32 *vmdq)
+{
+	struct dev_mc_list *mc_ptr;
+	u8 *addr = *mc_addr_ptr;
+	*vmdq = 0;
+
+	mc_ptr = container_of(addr, struct dev_mc_list, dmi_addr[0]);
+	if (mc_ptr->next)
+		*mc_addr_ptr = mc_ptr->next->dmi_addr;
+	else
+		*mc_addr_ptr = NULL;
+
+	return addr;
+}
+
 /**
- * ixgbe_set_multi - Multicast and Promiscuous mode set
+ * ixgbe_set_rx_mode - Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
- * promiscuous mode, and all-multi behavior.
+ * The set_rx_method entry point is called whenever the unicast/multicast
+ * address list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper unicast, multicast and
+ * promiscuous mode.
  **/
-static void ixgbe_set_multi(struct net_device *netdev)
+static void ixgbe_set_rx_mode(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
-	u8 *mta_list;
 	u32 fctrl, vlnctrl;
-	int i;
+	u8 *addr_list = NULL;
+	int addr_count = 0;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -1643,6 +1657,7 @@ static void ixgbe_set_multi(struct net_device *netdev)
 	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
+		hw->addr_ctrl.user_set_promisc = 1;
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 	} else {
@@ -1653,33 +1668,25 @@ static void ixgbe_set_multi(struct net_device *netdev)
 			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
 		vlnctrl |= IXGBE_VLNCTRL_VFE;
+		hw->addr_ctrl.user_set_promisc = 0;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
-	if (netdev->mc_count) {
-		mta_list = kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);
-		if (!mta_list)
-			return;
-
-		/* Shared function expects packed array of only addresses. */
-		mc_ptr = netdev->mc_list;
-
-		for (i = 0; i < netdev->mc_count; i++) {
-			if (!mc_ptr)
-				break;
-			memcpy(mta_list + (i * ETH_ALEN), mc_ptr->dmi_addr,
-			       ETH_ALEN);
-			mc_ptr = mc_ptr->next;
-		}
-
-		ixgbe_update_mc_addr_list(hw, mta_list, i, 0);
-		kfree(mta_list);
-	} else {
-		ixgbe_update_mc_addr_list(hw, NULL, 0, 0);
-	}
+	/* reprogram secondary unicast list */
+	addr_count = netdev->uc_count;
+	if (addr_count)
+		addr_list = netdev->uc_list->dmi_addr;
+	ixgbe_update_uc_addr_list(hw, addr_list, addr_count,
+	                          ixgbe_addr_list_itr);
 
+	/* reprogram multicast list */
+	addr_count = netdev->mc_count;
+	if (addr_count)
+		addr_list = netdev->mc_list->dmi_addr;
+	ixgbe_update_mc_addr_list(hw, addr_list, addr_count,
+	                          ixgbe_addr_list_itr);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -1723,7 +1730,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
-	ixgbe_set_multi(netdev);
+	ixgbe_set_rx_mode(netdev);
 
 	ixgbe_restore_vlan(adapter);
 
@@ -3508,7 +3515,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->stop = &ixgbe_close;
 	netdev->hard_start_xmit = &ixgbe_xmit_frame;
 	netdev->get_stats = &ixgbe_get_stats;
-	netdev->set_multicast_list = &ixgbe_set_multi;
+	netdev->set_rx_mode = &ixgbe_set_rx_mode;
+	netdev->set_multicast_list = &ixgbe_set_rx_mode;
 	netdev->set_mac_address = &ixgbe_set_mac;
 	netdev->change_mtu = &ixgbe_change_mtu;
 	ixgbe_set_ethtool_ops(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 781f137..2f4d34e 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -822,10 +822,6 @@
 #define IXGBE_RAH_VIND_SHIFT    18
 #define IXGBE_RAH_AV            0x80000000
 
-/* Filters */
-#define IXGBE_MC_TBL_SIZE       128  /* Multicast Filter Table (4096 bits) */
-#define IXGBE_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
-
 /* Header split receive */
 #define IXGBE_RFCTL_ISCSI_DIS       0x00000001
 #define IXGBE_RFCTL_ISCSI_DWC_MASK  0x0000003E
@@ -1167,6 +1163,8 @@ struct ixgbe_addr_filter_info {
 	u32 rar_used_count;
 	u32 mc_addr_in_rar_count;
 	u32 mta_in_use;
+	u32 overflow_promisc;
+	bool user_set_promisc;
 };
 
 /* Flow control parameters */
@@ -1242,6 +1240,10 @@ struct ixgbe_hw_stats {
 /* forward declaration */
 struct ixgbe_hw;
 
+/* iterator type for walking multicast address lists */
+typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
+                                  u32 *vmdq);
+
 struct ixgbe_mac_operations {
 	s32 (*reset)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
@@ -1263,9 +1265,11 @@ struct ixgbe_mac_info {
 	u8				addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	u8				perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	s32				mc_filter_type;
+	u32				mcft_size;
+	u32				vft_size;
+	u32				num_rar_entries;
 	u32				num_rx_queues;
 	u32				num_tx_queues;
-	u32				num_rx_addrs;
 	u32				link_attach_type;
 	u32				link_mode_select;
 	bool				link_settings_loaded;

