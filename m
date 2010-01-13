From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] e1000e: genericize the update multicast
	address list
Date: Wed, 13 Jan 2010 04:05:38 -0800
Message-ID: <20100113120537.23715.75967.stgit@localhost.localdomain>
References: <20100113120416.23715.64354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:56600
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518Ab0AMMF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 07:05:56 -0500
In-Reply-To: <20100113120416.23715.64354.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Make updating the multicast address list generic for all families and
enforce the requirement to update the entire multicast table array all at
once instead of piecemeal which causes problems on some parts.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |   28 +--------------------
 drivers/net/e1000e/e1000.h  |    4 +--
 drivers/net/e1000e/hw.h     |    6 ++++
 drivers/net/e1000e/lib.c    |   58 +++++++++++--------------------------------
 drivers/net/e1000e/netdev.c |   20 ++++-----------
 5 files changed, 27 insertions(+), 89 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 7674a91..3c95acb 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1234,32 +1234,6 @@ static s32 e1000_led_on_82574(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_update_mc_addr_list_82571 - Update Multicast addresses
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
-static void e1000_update_mc_addr_list_82571(struct e1000_hw *hw,
-					    u8 *mc_addr_list,
-					    u32 mc_addr_count,
-					    u32 rar_used_count,
-					    u32 rar_count)
-{
-	if (e1000e_get_laa_state_82571(hw))
-		rar_count--;
-
-	e1000e_update_mc_addr_list_generic(hw, mc_addr_list, mc_addr_count,
-					   rar_used_count, rar_count);
-}
-
-/**
  *  e1000_setup_link_82571 - Setup flow control and link settings
  *  @hw: pointer to the HW structure
  *
@@ -1731,7 +1705,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	/* .get_link_up_info: media type dependent */
 	/* .led_on: mac type dependent */
 	.led_off		= e1000e_led_off_generic,
-	.update_mc_addr_list	= e1000_update_mc_addr_list_82571,
+	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.write_vfta		= e1000_write_vfta_generic,
 	.clear_vfta		= e1000_clear_vfta_82571,
 	.reset_hw		= e1000_reset_hw_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 8e6251e..e1a3b56 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -518,9 +518,7 @@ extern void e1000_clear_vfta_generic(struct e1000_hw *hw);
 extern void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
 extern void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
 					       u8 *mc_addr_list,
-					       u32 mc_addr_count,
-					       u32 rar_used_count,
-					       u32 rar_count);
+					       u32 mc_addr_count);
 extern void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 extern s32 e1000e_set_fc_watermarks(struct e1000_hw *hw);
 extern void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop);
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 9cac5d9..8bdcd5f 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -753,7 +753,7 @@ struct e1000_mac_operations {
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
 	s32  (*led_off)(struct e1000_hw *);
-	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32, u32, u32);
+	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
@@ -819,6 +819,10 @@ struct e1000_mac_info {
 	u16 ifs_ratio;
 	u16 ifs_step_size;
 	u16 mta_reg_count;
+
+	/* Maximum size of the MTA register table in all supported adapters */
+	#define MAX_MTA_REG 128
+	u32 mta_shadow[MAX_MTA_REG];
 	u16 rar_entry_count;
 
 	u8  forced_speed_duplex;
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 5f6b171..2425ed1 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -340,62 +340,34 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
- *  @rar_used_count: the first RAR register free to program
- *  @rar_count: total number of supported Receive Address Registers
  *
- *  Updates the Receive Address Registers and Multicast Table Array.
+ *  Updates entire Multicast Table Array.
  *  The caller must have a packed mc_addr_list of multicast addresses.
- *  The parameter rar_count will usually be hw->mac.rar_entry_count
- *  unless there are workarounds that change this.
  **/
 void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
-					u8 *mc_addr_list, u32 mc_addr_count,
-					u32 rar_used_count, u32 rar_count)
+					u8 *mc_addr_list, u32 mc_addr_count)
 {
-	u32 i;
-	u32 *mcarray = kzalloc(hw->mac.mta_reg_count * sizeof(u32), GFP_ATOMIC);
+	u32 hash_value, hash_bit, hash_reg;
+	int i;
 
-	if (!mcarray) {
-		printk(KERN_ERR "multicast array memory allocation failed\n");
-		return;
-	}
+	/* clear mta_shadow */
+	memset(&hw->mac.mta_shadow, 0, sizeof(hw->mac.mta_shadow));
 
-	/*
-	 * Load the first set of multicast addresses into the exact
-	 * filters (RAR).  If there are not enough to fill the RAR
-	 * array, clear the filters.
-	 */
-	for (i = rar_used_count; i < rar_count; i++) {
-		if (mc_addr_count) {
-			e1000e_rar_set(hw, mc_addr_list, i);
-			mc_addr_count--;
-			mc_addr_list += ETH_ALEN;
-		} else {
-			E1000_WRITE_REG_ARRAY(hw, E1000_RA, i << 1, 0);
-			e1e_flush();
-			E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1) + 1, 0);
-			e1e_flush();
-		}
-	}
-
-	/* Load any remaining multicast addresses into the hash table. */
-	for (; mc_addr_count > 0; mc_addr_count--) {
-		u32 hash_value, hash_reg, hash_bit, mta;
+	/* update mta_shadow from mc_addr_list */
+	for (i = 0; (u32) i < mc_addr_count; i++) {
 		hash_value = e1000_hash_mc_addr(hw, mc_addr_list);
-		e_dbg("Hash value = 0x%03X\n", hash_value);
+
 		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
 		hash_bit = hash_value & 0x1F;
-		mta = (1 << hash_bit);
-		mcarray[hash_reg] |= mta;
-		mc_addr_list += ETH_ALEN;
-	}
 
-	/* write the hash table completely */
-	for (i = 0; i < hw->mac.mta_reg_count; i++)
-		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, mcarray[i]);
+		hw->mac.mta_shadow[hash_reg] |= (1 << hash_bit);
+		mc_addr_list += (ETH_ALEN);
+	}
 
+	/* replace the entire MTA table */
+	for (i = hw->mac.mta_reg_count - 1; i >= 0; i--)
+		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, hw->mac.mta_shadow[i]);
 	e1e_flush();
-	kfree(mcarray);
 }
 
 /**
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0d5ef4c..3d57ca5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2536,22 +2536,14 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
- *  @rar_used_count: the first RAR register free to program
- *  @rar_count: total number of supported Receive Address Registers
  *
- *  Updates the Receive Address Registers and Multicast Table Array.
+ *  Updates the Multicast Table Array.
  *  The caller must have a packed mc_addr_list of multicast addresses.
- *  The parameter rar_count will usually be hw->mac.rar_entry_count
- *  unless there are workarounds that change this.  Currently no func pointer
- *  exists and all implementations are handled in the generic version of this
- *  function.
  **/
 static void e1000_update_mc_addr_list(struct e1000_hw *hw, u8 *mc_addr_list,
-				      u32 mc_addr_count, u32 rar_used_count,
-				      u32 rar_count)
+				      u32 mc_addr_count)
 {
-	hw->mac.ops.update_mc_addr_list(hw, mc_addr_list, mc_addr_count,
-				        rar_used_count, rar_count);
+	hw->mac.ops.update_mc_addr_list(hw, mc_addr_list, mc_addr_count);
 }
 
 /**
@@ -2567,7 +2559,6 @@ static void e1000_set_multi(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
 	u8  *mta_list;
 	u32 rctl;
@@ -2609,15 +2600,14 @@ static void e1000_set_multi(struct net_device *netdev)
 			mc_ptr = mc_ptr->next;
 		}
 
-		e1000_update_mc_addr_list(hw, mta_list, i, 1,
-					  mac->rar_entry_count);
+		e1000_update_mc_addr_list(hw, mta_list, i);
 		kfree(mta_list);
 	} else {
 		/*
 		 * if we're called from probe, we might not have
 		 * anything to do here, so clear out the list
 		 */
-		e1000_update_mc_addr_list(hw, NULL, 0, 1, mac->rar_entry_count);
+		e1000_update_mc_addr_list(hw, NULL, 0);
 	}
 }
 

