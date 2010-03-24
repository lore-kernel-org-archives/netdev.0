From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] ixgbe: convert to use netdev_for_each_mc_addr
Date: Wed, 24 Mar 2010 01:58:01 -0700
Message-ID: <20100324085733.32706.70587.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:49971
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352Ab0CXI6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 04:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   16 +++++++---------
 drivers/net/ixgbe/ixgbe_common.h |    5 ++---
 drivers/net/ixgbe/ixgbe_main.c   |   24 ++----------------------
 drivers/net/ixgbe/ixgbe_type.h   |    3 +--
 4 files changed, 12 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index eb49020..4d1c3a4 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1484,26 +1484,24 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 /**
  *  ixgbe_update_mc_addr_list_generic - Updates MAC list of multicast addresses
  *  @hw: pointer to hardware structure
- *  @mc_addr_list: the list of new multicast addresses
- *  @mc_addr_count: number of addresses
- *  @next: iterator function to walk the multicast address list
+ *  @netdev: pointer to net device structure
  *
  *  The given list replaces any existing list. Clears the MC addrs from receive
  *  address registers and the multicast table. Uses unused receive address
  *  registers for the first multicast addresses, and hashes the rest into the
  *  multicast table.
  **/
-s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
-                                      u32 mc_addr_count, ixgbe_mc_addr_itr next)
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
+				      struct net_device *netdev)
 {
+	struct dev_addr_list *dmi;
 	u32 i;
-	u32 vmdq;
 
 	/*
 	 * Set the new number of MC addresses that we are being requested to
 	 * use.
 	 */
-	hw->addr_ctrl.num_mc_addrs = mc_addr_count;
+	hw->addr_ctrl.num_mc_addrs = netdev_mc_count(netdev);
 	hw->addr_ctrl.mta_in_use = 0;
 
 	/* Clear the MTA */
@@ -1512,9 +1510,9 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
 	/* Add the new addresses */
-	for (i = 0; i < mc_addr_count; i++) {
+	netdev_for_each_mc_addr(dmi, netdev) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
-		ixgbe_set_mta(hw, next(hw, &mc_addr_list, &vmdq));
+		ixgbe_set_mta(hw, dmi->dmi_addr);
 	}
 
 	/* Enable mta */
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 13606d4..264eef5 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -56,9 +56,8 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
                           u32 enable_addr);
 s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw);
-s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
-                                      u32 mc_addr_count,
-                                      ixgbe_mc_addr_itr func);
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
+				      struct net_device *netdev);
 s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 				      struct net_device *netdev);
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d75c46f..90565d8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2537,21 +2537,6 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 	}
 }
 
-static u8 *ixgbe_addr_list_itr(struct ixgbe_hw *hw, u8 **mc_addr_ptr, u32 *vmdq)
-{
-	struct dev_mc_list *mc_ptr;
-	u8 *addr = *mc_addr_ptr;
-	*vmdq = 0;
-
-	mc_ptr = container_of(addr, struct dev_mc_list, dmi_addr[0]);
-	if (mc_ptr->next)
-		*mc_addr_ptr = mc_ptr->next->dmi_addr;
-	else
-		*mc_addr_ptr = NULL;
-
-	return addr;
-}
-
 /**
  * ixgbe_set_rx_mode - Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
@@ -2566,8 +2551,6 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 fctrl, vlnctrl;
-	u8 *addr_list = NULL;
-	int addr_count = 0;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -2596,11 +2579,8 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	hw->mac.ops.update_uc_addr_list(hw, netdev);
 
 	/* reprogram multicast list */
-	addr_count = netdev_mc_count(netdev);
-	if (addr_count)
-		addr_list = netdev->mc_list->dmi_addr;
-	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
-	                                ixgbe_addr_list_itr);
+	hw->mac.ops.update_mc_addr_list(hw, netdev);
+
 	if (adapter->num_vfs)
 		ixgbe_restore_vf_multicasts(adapter);
 }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0ed5ab3..c574d0a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2416,8 +2416,7 @@ struct ixgbe_mac_operations {
 	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
 	s32 (*update_uc_addr_list)(struct ixgbe_hw *, struct net_device *);
-	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
-	                           ixgbe_mc_addr_itr);
+	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*enable_mc)(struct ixgbe_hw *);
 	s32 (*disable_mc)(struct ixgbe_hw *);
 	s32 (*clear_vfta)(struct ixgbe_hw *);

