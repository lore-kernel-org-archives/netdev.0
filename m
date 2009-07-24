From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/13] igb: move all multicast addresses into
	multicast table array
Date: Thu, 23 Jul 2009 21:08:54 -0700
Message-ID: <20090724040853.30709.97954.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:48262
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbZGXEJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:09:10 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves all of the multicast addresses out of the free Receive
address registers and instead programs them all into the multicast table
array.  As a result the multicast filtering may not be as precise, but it
also greatly reduces the overhead for multicast addresses.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   59 -----------------------------------------
 drivers/net/igb/e1000_82575.h |    1 -
 drivers/net/igb/e1000_hw.h    |    4 +++
 drivers/net/igb/e1000_mac.c   |   35 ++++++++++++++++++++++++
 drivers/net/igb/e1000_mac.h   |    2 +
 drivers/net/igb/igb_main.c    |   44 ++++++++++---------------------
 6 files changed, 56 insertions(+), 89 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index c4506bf..5d2c2fb 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -798,65 +798,6 @@ static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count)
 }
 
 /**
- *  igb_update_mc_addr_list - Update Multicast addresses
- *  @hw: pointer to the HW structure
- *  @mc_addr_list: array of multicast addresses to program
- *  @mc_addr_count: number of multicast addresses to program
- *  @rar_used_count: the first RAR register free to program
- *  @rar_count: total number of supported Receive Address Registers
- *
- *  Updates the Receive Address Registers and Multicast Table Array.
- *  The caller must have a packed mc_addr_list of multicast addresses.
- *  The parameter rar_count will usually be hw->mac.rar_entry_count
- *  unless there are workarounds that change this.
- **/
-void igb_update_mc_addr_list(struct e1000_hw *hw,
-                             u8 *mc_addr_list, u32 mc_addr_count,
-                             u32 rar_used_count, u32 rar_count)
-{
-	u32 hash_value;
-	u32 i;
-	u8 addr[6] = {0,0,0,0,0,0};
-	/*
-	 * This function is essentially the same as that of 
-	 * igb_update_mc_addr_list_generic. However it also takes care 
-	 * of the special case where the register offset of the 
-	 * second set of RARs begins elsewhere. This is implicitly taken care by 
-	 * function e1000_rar_set_generic.
-	 */
-
-	/*
-	 * Load the first set of multicast addresses into the exact
-	 * filters (RAR).  If there are not enough to fill the RAR
-	 * array, clear the filters.
-	 */
-	for (i = rar_used_count; i < rar_count; i++) {
-		if (mc_addr_count) {
-			igb_rar_set(hw, mc_addr_list, i);
-			mc_addr_count--;
-			mc_addr_list += ETH_ALEN;
-		} else {
-			igb_rar_set(hw, addr, i);
-		}
-	}
-
-	/* Clear the old settings from the MTA */
-	hw_dbg("Clearing MTA\n");
-	for (i = 0; i < hw->mac.mta_reg_count; i++) {
-		array_wr32(E1000_MTA, i, 0);
-		wrfl();
-	}
-
-	/* Load any remaining multicast addresses into the hash table. */
-	for (; mc_addr_count > 0; mc_addr_count--) {
-		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
-		hw_dbg("Hash value = 0x%03X\n", hash_value);
-		igb_mta_set(hw, hash_value);
-		mc_addr_list += ETH_ALEN;
-	}
-}
-
-/**
  *  igb_shutdown_fiber_serdes_link_82575 - Remove link during power down
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index b674417..8a1e659 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -28,7 +28,6 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
 
-void igb_update_mc_addr_list(struct e1000_hw*, u8*, u32, u32, u32);
 extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index eb41f3b..83f9b4f 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -338,6 +338,10 @@ struct e1000_mac_info {
 	u16 ifs_ratio;
 	u16 ifs_step_size;
 	u16 mta_reg_count;
+
+	/* Maximum size of the MTA register table in all supported adapters */
+	#define MAX_MTA_REG 128
+	u32 mta_shadow[MAX_MTA_REG];
 	u16 rar_entry_count;
 
 	u8  forced_speed_duplex;
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 60343b5..46e27e9 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -261,6 +261,41 @@ void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 }
 
 /**
+ *  igb_update_mc_addr_list - Update Multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @mc_addr_list: array of multicast addresses to program
+ *  @mc_addr_count: number of multicast addresses to program
+ *
+ *  Updates entire Multicast Table Array.
+ *  The caller must have a packed mc_addr_list of multicast addresses.
+ **/
+void igb_update_mc_addr_list(struct e1000_hw *hw,
+                             u8 *mc_addr_list, u32 mc_addr_count)
+{
+	u32 hash_value, hash_bit, hash_reg;
+	int i;
+
+	/* clear mta_shadow */
+	memset(&hw->mac.mta_shadow, 0, sizeof(hw->mac.mta_shadow));
+
+	/* update mta_shadow from mc_addr_list */
+	for (i = 0; (u32) i < mc_addr_count; i++) {
+		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
+
+		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
+		hash_bit = hash_value & 0x1F;
+
+		hw->mac.mta_shadow[hash_reg] |= (1 << hash_bit);
+		mc_addr_list += (ETH_ALEN);
+	}
+
+	/* replace the entire MTA table */
+	for (i = hw->mac.mta_reg_count - 1; i >= 0; i--)
+		array_wr32(E1000_MTA, i, hw->mac.mta_shadow[i]);
+	wrfl();
+}
+
+/**
  *  igb_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 1d690b4..f9ebfb3 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -51,6 +51,8 @@ s32  igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 				       u16 *duplex);
 s32  igb_id_led_init(struct e1000_hw *hw);
 s32  igb_led_off(struct e1000_hw *hw);
+void igb_update_mc_addr_list(struct e1000_hw *hw,
+	                     u8 *mc_addr_list, u32 mc_addr_count);
 s32  igb_setup_link(struct e1000_hw *hw);
 s32  igb_validate_mdi_setting(struct e1000_hw *hw);
 s32  igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2cb5460..e4f4526 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -127,7 +127,7 @@ static void igb_restore_vlan(struct igb_adapter *);
 static void igb_ping_all_vfs(struct igb_adapter *);
 static void igb_msg_task(struct igb_adapter *);
 static int igb_rcv_msg_from_vf(struct igb_adapter *, u32);
-static void igb_set_mc_list_pools(struct igb_adapter *, int, u16);
+static inline void igb_set_rah_pool(struct e1000_hw *, int , int);
 static void igb_vmm_control(struct igb_adapter *);
 static int igb_set_vf_mac(struct igb_adapter *adapter, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
@@ -2535,7 +2535,6 @@ static void igb_set_multi(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
 	u8  *mta_list = NULL;
 	u32 rctl;
@@ -2558,13 +2557,18 @@ static void igb_set_multi(struct net_device *netdev)
 	}
 	wr32(E1000_RCTL, rctl);
 
-	if (netdev->mc_count) {
-		mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
-		if (!mta_list) {
-			dev_err(&adapter->pdev->dev,
-			        "failed to allocate multicast filter list\n");
-			return;
-		}
+	if (!netdev->mc_count) {
+		/* nothing to program, so clear mc list */
+		igb_update_mc_addr_list(hw, NULL, 0);
+		igb_restore_vf_multicasts(adapter);
+		return;
+	}
+
+	mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (!mta_list) {
+		dev_err(&adapter->pdev->dev,
+		        "failed to allocate multicast filter list\n");
+		return;
 	}
 
 	/* The shared function expects a packed array of only addresses. */
@@ -2576,14 +2580,9 @@ static void igb_set_multi(struct net_device *netdev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr = mc_ptr->next;
 	}
-	igb_update_mc_addr_list(hw, mta_list, i,
-	                        adapter->vfs_allocated_count + 1,
-	                        mac->rar_entry_count);
-
-	igb_set_mc_list_pools(adapter, i, mac->rar_entry_count);
-	igb_restore_vf_multicasts(adapter);
-
+	igb_update_mc_addr_list(hw, mta_list, i);
 	kfree(mta_list);
+	igb_restore_vf_multicasts(adapter);
 }
 
 /* Need to wait a few seconds after link up to get diagnostic information from
@@ -5468,19 +5467,6 @@ static void igb_io_resume(struct pci_dev *pdev)
 	igb_get_hw_control(adapter);
 }
 
-static void igb_set_mc_list_pools(struct igb_adapter *adapter,
-				  int entry_count, u16 total_rar_filters)
-{
-	struct e1000_hw *hw = &adapter->hw;
-	int i = adapter->vfs_allocated_count + 1;
-
-	if ((i + entry_count) < total_rar_filters)
-		total_rar_filters = i + entry_count;
-
-	for (; i < total_rar_filters; i++)
-		igb_set_rah_pool(hw, adapter->vfs_allocated_count, i);
-}
-
 static int igb_set_vf_mac(struct igb_adapter *adapter,
                           int vf, unsigned char *mac_addr)
 {

