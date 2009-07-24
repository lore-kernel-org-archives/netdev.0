From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/13] igb: cleanup receive address register
	initialization
Date: Thu, 23 Jul 2009 21:09:12 -0700
Message-ID: <20090724040911.30709.18472.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:55490
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbZGXEJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:09:28 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update cleans up the receive address register initialization.  The
main purpose of this is to clean out some redundancy that was introduced
due to having multiple ways of setting the receive address registers.
Instead of having a specialized function to set one register and one to set
all of them it makes more sense to just go through the list calling the
function that is needed to set the individual registers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   39 ++++-----------------------------------
 drivers/net/igb/e1000_mac.c   |   25 +++++++++++++++++++++++++
 drivers/net/igb/e1000_mac.h   |    1 +
 3 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 5d2c2fb..95360dc 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -765,39 +765,6 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  igb_init_rx_addrs_82575 - Initialize receive address's
- *  @hw: pointer to the HW structure
- *  @rar_count: receive address registers
- *
- *  Setups the receive address registers by setting the base receive address
- *  register to the devices MAC address and clearing all the other receive
- *  address registers to 0.
- **/
-static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count)
-{
-	u32 i;
-	u8 addr[6] = {0,0,0,0,0,0};
-	/*
-	 * This function is essentially the same as that of
-	 * e1000_init_rx_addrs_generic. However it also takes care
-	 * of the special case where the register offset of the
-	 * second set of RARs begins elsewhere. This is implicitly taken care by
-	 * function e1000_rar_set_generic.
-	 */
-
-	hw_dbg("e1000_init_rx_addrs_82575");
-
-	/* Setup the receive address */
-	hw_dbg("Programming MAC Address into RAR[0]\n");
-	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
-
-	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
-	for (i = 1; i < rar_count; i++)
-	    hw->mac.ops.rar_set(hw, addr, i);
-}
-
-/**
  *  igb_shutdown_fiber_serdes_link_82575 - Remove link during power down
  *  @hw: pointer to the HW structure
  *
@@ -889,7 +856,8 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 	wr32(E1000_IMC, 0xffffffff);
 	icr = rd32(E1000_ICR);
 
-	igb_check_alt_mac_addr(hw);
+	/* Install any alternate MAC address into RAR0 */
+	ret_val = igb_check_alt_mac_addr(hw);
 
 	return ret_val;
 }
@@ -918,7 +886,8 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	igb_clear_vfta(hw);
 
 	/* Setup the receive address */
-	igb_init_rx_addrs_82575(hw, rar_count);
+	igb_init_rx_addrs(hw, rar_count);
+
 	/* Zero out the Multicast HASH table */
 	hw_dbg("Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 46e27e9..a1e3da7 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -104,6 +104,31 @@ static void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 }
 
 /**
+ *  igb_init_rx_addrs - Initialize receive address's
+ *  @hw: pointer to the HW structure
+ *  @rar_count: receive address registers
+ *
+ *  Setups the receive address registers by setting the base receive address
+ *  register to the devices MAC address and clearing all the other receive
+ *  address registers to 0.
+ **/
+void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
+{
+	u32 i;
+	u8 mac_addr[ETH_ALEN] = {0};
+
+	/* Setup the receive address */
+	hw_dbg("Programming MAC Address into RAR[0]\n");
+
+	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
+
+	/* Zero out the other (rar_entry_count - 1) receive addresses */
+	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	for (i = 1; i < rar_count; i++)
+		hw->mac.ops.rar_set(hw, mac_addr, i);
+}
+
+/**
  *  igb_vfta_set - enable or disable vlan in VLAN filter table
  *  @hw: pointer to the HW structure
  *  @vid: VLAN id to add or remove
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index f9ebfb3..7518af8 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -62,6 +62,7 @@ void igb_clear_hw_cntrs_base(struct e1000_hw *hw);
 void igb_clear_vfta(struct e1000_hw *hw);
 s32  igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add);
 void igb_config_collision_dist(struct e1000_hw *hw);
+void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
 void igb_mta_set(struct e1000_hw *hw, u32 hash_value);
 void igb_put_hw_semaphore(struct e1000_hw *hw);
 void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);

