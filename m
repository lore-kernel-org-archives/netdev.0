From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: Correctly set SAN MAC RAR pool to default pool of PF
Date: Thu, 19 Jul 2012 18:24:04 -0700
Message-ID: <1342747446-16132-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9033 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732Ab2GTBYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:15 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects an issue in which an FCoE enabled adapter was always
setting the FCoE SAN MAC MPSAR register to 0x1.  This results in the first
VF being assigned the SAN MAC address in the case of SR-IOV and as such is
incorrect.  To resolve this I am adding a new function that will update the
SAN MAC pool address after reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |    4 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   25 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   13 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    4 ++++
 6 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index e7dddfd..50fc137 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1025,6 +1025,9 @@ mac_reset_top:
 		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
 		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
 
+		/* Save the SAN MAC RAR index */
+		hw->mac.san_mac_rar_index = hw->mac.num_rar_entries - 1;
+
 		/* Reserve the last RAR for the SAN MAC address */
 		hw->mac.num_rar_entries--;
 	}
@@ -2106,6 +2109,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
+	.set_vmdq_san_mac	= &ixgbe_set_vmdq_san_mac_generic,
 	.clear_vmdq             = &ixgbe_clear_vmdq_generic,
 	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
 	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index bb7fde4..bbe9d45 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2848,6 +2848,31 @@ s32 ixgbe_set_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 }
 
 /**
+ *  This function should only be involved in the IOV mode.
+ *  In IOV mode, Default pool is next pool after the number of
+ *  VFs advertized and not 0.
+ *  MPSAR table needs to be updated for SAN_MAC RAR [hw->mac.san_mac_rar_index]
+ *
+ *  ixgbe_set_vmdq_san_mac - Associate default VMDq pool index with a rx address
+ *  @hw: pointer to hardware struct
+ *  @vmdq: VMDq pool index
+ **/
+s32 ixgbe_set_vmdq_san_mac_generic(struct ixgbe_hw *hw, u32 vmdq)
+{
+	u32 rar = hw->mac.san_mac_rar_index;
+
+	if (vmdq < 32) {
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), 1 << vmdq);
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), 0);
+	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), 1 << (vmdq - 32));
+	}
+
+	return 0;
+}
+
+/**
  *  ixgbe_init_uta_tables_generic - Initialize the Unicast Table Array
  *  @hw: pointer to hardware structure
  **/
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 6222fdb..d813d11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -85,6 +85,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 s32 ixgbe_get_san_mac_addr_generic(struct ixgbe_hw *hw, u8 *san_mac_addr);
 s32 ixgbe_set_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
+s32 ixgbe_set_vmdq_san_mac_generic(struct ixgbe_hw *hw, u32 vmdq);
 s32 ixgbe_clear_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
 s32 ixgbe_init_uta_tables_generic(struct ixgbe_hw *hw);
 s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e006c05..aa01558 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4119,6 +4119,10 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 
 	/* reprogram the RAR[0] in case user changed it. */
 	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, VMDQ_P(0), IXGBE_RAH_AV);
+
+	/* update SAN MAC vmdq pool selection */
+	if (hw->mac.san_mac_rar_index)
+		hw->mac.ops.set_vmdq_san_mac(hw, VMDQ_P(0));
 }
 
 /**
@@ -6509,12 +6513,15 @@ static int ixgbe_add_sanmac_netdev(struct net_device *dev)
 {
 	int err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	struct ixgbe_mac_info *mac = &adapter->hw.mac;
+	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (is_valid_ether_addr(mac->san_addr)) {
+	if (is_valid_ether_addr(hw->mac.san_addr)) {
 		rtnl_lock();
-		err = dev_addr_add(dev, mac->san_addr, NETDEV_HW_ADDR_T_SAN);
+		err = dev_addr_add(dev, hw->mac.san_addr, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
+
+		/* update SAN MAC vmdq pool selection */
+		hw->mac.ops.set_vmdq_san_mac(hw, VMDQ_P(0));
 	}
 	return err;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 482a33b..d26e07a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2847,6 +2847,7 @@ struct ixgbe_mac_operations {
 	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32, u32);
 	s32 (*clear_rar)(struct ixgbe_hw *, u32);
 	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
+	s32 (*set_vmdq_san_mac)(struct ixgbe_hw *, u32);
 	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
@@ -2922,6 +2923,7 @@ struct ixgbe_mac_info {
 	bool                            orig_link_settings_stored;
 	bool                            autotry_restart;
 	u8                              flags;
+	u8				san_mac_rar_index;
 	struct ixgbe_thermal_sensor_data  thermal_sensor_data;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index f90ec07..de4da52 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -156,6 +156,9 @@ mac_reset_top:
 		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
 		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
 
+		/* Save the SAN MAC RAR index */
+		hw->mac.san_mac_rar_index = hw->mac.num_rar_entries - 1;
+
 		/* Reserve the last RAR for the SAN MAC address */
 		hw->mac.num_rar_entries--;
 	}
@@ -832,6 +835,7 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
+	.set_vmdq_san_mac	= &ixgbe_set_vmdq_san_mac_generic,
 	.clear_vmdq             = &ixgbe_clear_vmdq_generic,
 	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
 	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
-- 
1.7.10.4
