From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: resolve namespacecheck warning for
	igb_hash_mc_addr
Date: Thu, 17 Sep 2009 17:52:29 -0700
Message-ID: <20090918005219.25329.94906.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:49185
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752220AbZIRAwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 20:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves a warning seen when doing namespace checking via
"make namespacecheck"

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |   72 ++++++++++++++++++++++---------------------
 drivers/net/igb/e1000_mac.h |    1 -
 2 files changed, 36 insertions(+), 37 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index a0231cd..7d76bb0 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -286,41 +286,6 @@ void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 }
 
 /**
- *  igb_update_mc_addr_list - Update Multicast addresses
- *  @hw: pointer to the HW structure
- *  @mc_addr_list: array of multicast addresses to program
- *  @mc_addr_count: number of multicast addresses to program
- *
- *  Updates entire Multicast Table Array.
- *  The caller must have a packed mc_addr_list of multicast addresses.
- **/
-void igb_update_mc_addr_list(struct e1000_hw *hw,
-                             u8 *mc_addr_list, u32 mc_addr_count)
-{
-	u32 hash_value, hash_bit, hash_reg;
-	int i;
-
-	/* clear mta_shadow */
-	memset(&hw->mac.mta_shadow, 0, sizeof(hw->mac.mta_shadow));
-
-	/* update mta_shadow from mc_addr_list */
-	for (i = 0; (u32) i < mc_addr_count; i++) {
-		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
-
-		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
-		hash_bit = hash_value & 0x1F;
-
-		hw->mac.mta_shadow[hash_reg] |= (1 << hash_bit);
-		mc_addr_list += (ETH_ALEN);
-	}
-
-	/* replace the entire MTA table */
-	for (i = hw->mac.mta_reg_count - 1; i >= 0; i--)
-		array_wr32(E1000_MTA, i, hw->mac.mta_shadow[i]);
-	wrfl();
-}
-
-/**
  *  igb_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
@@ -329,7 +294,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
  *  the multicast filter table array address and new table value.  See
  *  igb_mta_set()
  **/
-u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
+static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 {
 	u32 hash_value, hash_mask;
 	u8 bit_shift = 0;
@@ -392,6 +357,41 @@ u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
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
  *  igb_clear_hw_cntrs_base - Clear base hardware counters
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 7518af8..bca17d8 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -88,6 +88,5 @@ enum e1000_mng_mode {
 #define E1000_MNG_DHCP_COOKIE_STATUS_VLAN    0x2
 
 extern void e1000_init_function_pointers_82575(struct e1000_hw *hw);
-extern u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
 #endif

