From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] ixgbe: improve mac filter handling
Date: Wed, 23 Apr 2014 04:15:17 -0700
Message-ID: <1398251726-13638-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbaDWLPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:35 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Add mac_table API based on work done for igb, which includes functions
to add and delete mac filters. This simplifies code for various entities
that use MAC filters such as VMDQ, SR-IOV, MACVLAN, and such.

Reported-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  18 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 188 +++++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  34 +----
 3 files changed, 172 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 1a12c1d..0975742 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -155,7 +155,6 @@ struct vf_data_storage {
 struct vf_macvlans {
 	struct list_head l;
 	int vf;
-	int rar_entry;
 	bool free;
 	bool is_macvlan;
 	u8 vf_macvlan[ETH_ALEN];
@@ -614,6 +613,15 @@ static inline void ixgbe_write_tail(struct ixgbe_ring *ring, u32 value)
 #define MAX_MSIX_VECTORS_82598 18
 #define MAX_Q_VECTORS_82598 16
 
+struct ixgbe_mac_addr {
+	u8 addr[ETH_ALEN];
+	u16 queue;
+	u16 state; /* bitmask */
+};
+#define IXGBE_MAC_STATE_DEFAULT		0x1
+#define IXGBE_MAC_STATE_MODIFIED	0x2
+#define IXGBE_MAC_STATE_IN_USE		0x4
+
 #define MAX_Q_VECTORS MAX_Q_VECTORS_82599
 #define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82599
 
@@ -785,6 +793,7 @@ struct ixgbe_adapter {
 
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
+	struct ixgbe_mac_addr *mac_table;
 	struct kobject *info_kobj;
 #ifdef CONFIG_IXGBE_HWMON
 	struct hwmon_buff *ixgbe_hwmon_buff;
@@ -863,6 +872,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 			       u16 subdevice_id);
+#ifdef CONFIG_PCI_IOV
+void ixgbe_full_sync_mac_table(struct ixgbe_adapter *adapter);
+#endif
+int ixgbe_add_mac_filter(struct ixgbe_adapter *adapter,
+			 u8 *addr, u16 queue);
+int ixgbe_del_mac_filter(struct ixgbe_adapter *adapter,
+			 u8 *addr, u16 queue);
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *, struct ixgbe_adapter *,
 				  struct ixgbe_ring *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 84044ed..39a1c07 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3868,13 +3868,135 @@ static int ixgbe_write_mc_addr_list(struct net_device *netdev)
 		return -ENOMEM;
 
 #ifdef CONFIG_PCI_IOV
-	if (adapter->num_vfs)
-		ixgbe_restore_vf_multicasts(adapter);
+	ixgbe_restore_vf_multicasts(adapter);
 #endif
 
 	return netdev_mc_count(netdev);
 }
 
+#ifdef CONFIG_PCI_IOV
+void ixgbe_full_sync_mac_table(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		if (adapter->mac_table[i].state & IXGBE_MAC_STATE_IN_USE)
+			hw->mac.ops.set_rar(hw, i, adapter->mac_table[i].addr,
+					    adapter->mac_table[i].queue,
+					    IXGBE_RAH_AV);
+		else
+			hw->mac.ops.clear_rar(hw, i);
+
+		adapter->mac_table[i].state &= ~(IXGBE_MAC_STATE_MODIFIED);
+	}
+}
+#endif
+
+static void ixgbe_sync_mac_table(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		if (adapter->mac_table[i].state & IXGBE_MAC_STATE_MODIFIED) {
+			if (adapter->mac_table[i].state &
+			    IXGBE_MAC_STATE_IN_USE)
+				hw->mac.ops.set_rar(hw, i,
+						adapter->mac_table[i].addr,
+						adapter->mac_table[i].queue,
+						IXGBE_RAH_AV);
+			else
+				hw->mac.ops.clear_rar(hw, i);
+
+			adapter->mac_table[i].state &=
+						~(IXGBE_MAC_STATE_MODIFIED);
+		}
+	}
+}
+
+static void ixgbe_flush_sw_mac_table(struct ixgbe_adapter *adapter)
+{
+	int i;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		adapter->mac_table[i].state |= IXGBE_MAC_STATE_MODIFIED;
+		adapter->mac_table[i].state &= ~IXGBE_MAC_STATE_IN_USE;
+		memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
+		adapter->mac_table[i].queue = 0;
+	}
+	ixgbe_sync_mac_table(adapter);
+}
+
+static int ixgbe_available_rars(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i, count = 0;
+
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		if (adapter->mac_table[i].state == 0)
+			count++;
+	}
+	return count;
+}
+
+/* this function destroys the first RAR entry */
+static void ixgbe_mac_set_default_filter(struct ixgbe_adapter *adapter,
+					 u8 *addr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	memcpy(&adapter->mac_table[0].addr, addr, ETH_ALEN);
+	adapter->mac_table[0].queue = VMDQ_P(0);
+	adapter->mac_table[0].state = (IXGBE_MAC_STATE_DEFAULT |
+				       IXGBE_MAC_STATE_IN_USE);
+	hw->mac.ops.set_rar(hw, 0, adapter->mac_table[0].addr,
+			    adapter->mac_table[0].queue,
+			    IXGBE_RAH_AV);
+}
+
+int ixgbe_add_mac_filter(struct ixgbe_adapter *adapter, u8 *addr, u16 queue)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+
+	if (is_zero_ether_addr(addr))
+		return -EINVAL;
+
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		if (adapter->mac_table[i].state & IXGBE_MAC_STATE_IN_USE)
+			continue;
+		adapter->mac_table[i].state |= (IXGBE_MAC_STATE_MODIFIED |
+						IXGBE_MAC_STATE_IN_USE);
+		ether_addr_copy(adapter->mac_table[i].addr, addr);
+		adapter->mac_table[i].queue = queue;
+		ixgbe_sync_mac_table(adapter);
+		return i;
+	}
+	return -ENOMEM;
+}
+
+int ixgbe_del_mac_filter(struct ixgbe_adapter *adapter, u8 *addr, u16 queue)
+{
+	/* search table for addr, if found, set to 0 and sync */
+	int i;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (is_zero_ether_addr(addr))
+		return -EINVAL;
+
+	for (i = 0; i < hw->mac.num_rar_entries; i++) {
+		if (ether_addr_equal(addr, adapter->mac_table[i].addr) &&
+		    adapter->mac_table[i].queue == queue) {
+			adapter->mac_table[i].state |= IXGBE_MAC_STATE_MODIFIED;
+			adapter->mac_table[i].state &= ~IXGBE_MAC_STATE_IN_USE;
+			memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
+			adapter->mac_table[i].queue = 0;
+			ixgbe_sync_mac_table(adapter);
+			return 0;
+		}
+	}
+	return -ENOMEM;
+}
 /**
  * ixgbe_write_uc_addr_list - write unicast addresses to RAR table
  * @netdev: network interface device structure
@@ -3884,39 +4006,23 @@ static int ixgbe_write_mc_addr_list(struct net_device *netdev)
  *                0 on no addresses written
  *                X on writing X addresses to the RAR table
  **/
-static int ixgbe_write_uc_addr_list(struct net_device *netdev)
+static int ixgbe_write_uc_addr_list(struct net_device *netdev, int vfn)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-	unsigned int rar_entries = hw->mac.num_rar_entries - 1;
 	int count = 0;
 
-	/* In SR-IOV/VMDQ modes significantly less RAR entries are available */
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		rar_entries = IXGBE_MAX_PF_MACVLANS - 1;
-
 	/* return ENOMEM indicating insufficient memory for addresses */
-	if (netdev_uc_count(netdev) > rar_entries)
+	if (netdev_uc_count(netdev) > ixgbe_available_rars(adapter))
 		return -ENOMEM;
 
 	if (!netdev_uc_empty(netdev)) {
 		struct netdev_hw_addr *ha;
-		/* return error if we do not support writing to RAR table */
-		if (!hw->mac.ops.set_rar)
-			return -ENOMEM;
-
 		netdev_for_each_uc_addr(ha, netdev) {
-			if (!rar_entries)
-				break;
-			hw->mac.ops.set_rar(hw, rar_entries--, ha->addr,
-					    VMDQ_P(0), IXGBE_RAH_AV);
+			ixgbe_del_mac_filter(adapter, ha->addr, vfn);
+			ixgbe_add_mac_filter(adapter, ha->addr, vfn);
 			count++;
 		}
 	}
-	/* write the addresses in reverse order to avoid write combining */
-	for (; rar_entries > 0 ; rar_entries--)
-		hw->mac.ops.clear_rar(hw, rar_entries);
-
 	return count;
 }
 
@@ -3975,7 +4081,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	 * sufficient space to store all the addresses then enable
 	 * unicast promiscuous mode
 	 */
-	count = ixgbe_write_uc_addr_list(netdev);
+	count = ixgbe_write_uc_addr_list(netdev, VMDQ_P(0));
 	if (count < 0) {
 		fctrl |= IXGBE_FCTRL_UPE;
 		vmolr |= IXGBE_VMOLR_ROPE;
@@ -4287,20 +4393,10 @@ static void ixgbe_macvlan_set_rx_mode(struct net_device *dev, unsigned int pool,
 		vmolr |= IXGBE_VMOLR_ROMPE;
 		hw->mac.ops.update_mc_addr_list(hw, dev);
 	}
-	ixgbe_write_uc_addr_list(adapter->netdev);
+	ixgbe_write_uc_addr_list(adapter->netdev, pool);
 	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(pool), vmolr);
 }
 
-static void ixgbe_add_mac_filter(struct ixgbe_adapter *adapter,
-				 u8 *addr, u16 pool)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	unsigned int entry;
-
-	entry = hw->mac.num_rar_entries - pool;
-	hw->mac.ops.set_rar(hw, entry, addr, VMDQ_P(pool), IXGBE_RAH_AV);
-}
-
 static void ixgbe_fwd_psrtype(struct ixgbe_fwd_adapter *vadapter)
 {
 	struct ixgbe_adapter *adapter = vadapter->real_adapter;
@@ -4780,7 +4876,9 @@ void ixgbe_up(struct ixgbe_adapter *adapter)
 void ixgbe_reset(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 	int err;
+	u8 old_addr[ETH_ALEN];
 
 	if (ixgbe_removed(hw->hw_addr))
 		return;
@@ -4816,9 +4914,10 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	}
 
 	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
-
-	/* reprogram the RAR[0] in case user changed it. */
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, VMDQ_P(0), IXGBE_RAH_AV);
+	/* do not flush user set addresses */
+	memcpy(old_addr, &adapter->mac_table[0].addr, netdev->addr_len);
+	ixgbe_flush_sw_mac_table(adapter);
+	ixgbe_mac_set_default_filter(adapter, old_addr);
 
 	/* update SAN MAC vmdq pool selection */
 	if (hw->mac.san_mac_rar_index)
@@ -5064,6 +5163,10 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #endif /* CONFIG_IXGBE_DCB */
 #endif /* IXGBE_FCOE */
 
+	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
+				     hw->mac.num_rar_entries,
+				     GFP_ATOMIC);
+
 	/* Set MAC specific capability flags and exceptions */
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
@@ -7210,16 +7313,17 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
+	int ret;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	ixgbe_del_mac_filter(adapter, hw->mac.addr, VMDQ_P(0));
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, VMDQ_P(0), IXGBE_RAH_AV);
-
-	return 0;
+	ret = ixgbe_add_mac_filter(adapter, hw->mac.addr, VMDQ_P(0));
+	return ret > 0 ? 0 : ret;
 }
 
 static int
@@ -8225,6 +8329,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	ixgbe_mac_set_default_filter(adapter, hw->mac.perm_addr);
+
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
 		    (unsigned long) adapter);
 
@@ -8357,6 +8463,7 @@ err_sw_init:
 	ixgbe_disable_sriov(adapter);
 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
 	iounmap(adapter->io_addr);
+	kfree(adapter->mac_table);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
@@ -8430,6 +8537,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 
 	e_dev_info("complete\n");
 
+	kfree(adapter->mac_table);
 	free_netdev(netdev);
 
 	pci_disable_pcie_error_reporting(pdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 2885cb0..a01417c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -72,8 +72,6 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		for (i = 0; i < num_vf_macvlans; i++) {
 			mv_list->vf = -1;
 			mv_list->free = true;
-			mv_list->rar_entry = hw->mac.num_rar_entries -
-				(i + adapter->num_vfs + 1);
 			list_add(&mv_list->l, &adapter->vf_mvs.l);
 			mv_list++;
 		}
@@ -361,21 +359,6 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 }
 
 #ifdef CONFIG_PCI_IOV
-static void ixgbe_restore_vf_macvlans(struct ixgbe_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	struct list_head *pos;
-	struct vf_macvlans *entry;
-
-	list_for_each(pos, &adapter->vf_mvs.l) {
-		entry = list_entry(pos, struct vf_macvlans, l);
-		if (!entry->free)
-			hw->mac.ops.set_rar(hw, entry->rar_entry,
-					    entry->vf_macvlan,
-					    entry->vf, IXGBE_RAH_AV);
-	}
-}
-
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -405,7 +388,7 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 	}
 
 	/* Restore any VF macvlans */
-	ixgbe_restore_vf_macvlans(adapter);
+	ixgbe_full_sync_mac_table(adapter);
 }
 #endif
 
@@ -525,7 +508,6 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
-	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
 	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
 
 	/* add PF assigned VLAN or VLAN 0 */
@@ -555,7 +537,7 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	/* Flush and reset the mta with the new values */
 	ixgbe_set_rx_mode(adapter->netdev);
 
-	hw->mac.ops.clear_rar(hw, rar_entry);
+	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
 
 	/* reset VF api back to unknown */
 	adapter->vfinfo[vf].vf_api = ixgbe_mbox_api_10;
@@ -564,11 +546,9 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 			    int vf, unsigned char *mac_addr)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
-	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
-
+	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
 	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
-	hw->mac.ops.set_rar(hw, rar_entry, mac_addr, vf, IXGBE_RAH_AV);
+	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
 
 	return 0;
 }
@@ -576,7 +556,6 @@ static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 				int vf, int index, unsigned char *mac_addr)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
 	struct list_head *pos;
 	struct vf_macvlans *entry;
 
@@ -587,7 +566,8 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 				entry->vf = -1;
 				entry->free = true;
 				entry->is_macvlan = false;
-				hw->mac.ops.clear_rar(hw, entry->rar_entry);
+				ixgbe_del_mac_filter(adapter,
+						     entry->vf_macvlan, vf);
 			}
 		}
 	}
@@ -623,7 +603,7 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 	entry->vf = vf;
 	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
 
-	hw->mac.ops.set_rar(hw, entry->rar_entry, mac_addr, vf, IXGBE_RAH_AV);
+	ixgbe_add_mac_filter(adapter, mac_addr, vf);
 
 	return 0;
 }
-- 
1.9.0
