From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] ixgbe: Reorder search to work from the top down instead of bottom up
Date: Sat, 12 Dec 2015 03:14:45 -0800
Message-ID: <1449918890-145243-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbbLLLPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:03 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch is meant to reduce the complexity of the search function used
for finding a VLVF entry associated with a given VLAN ID.  The previous
code was searching from bottom to top.  I reordered it to search from top
to bottom.  In addition I pulled an AND statement out of the loop and
instead replaced it with an OR statement outside the loop.  This should
help to reduce the overall size and complexity of the function.

There was also some formatting I cleaned up in regards to whitespace and
such.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 42 +++++++++++--------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 5fd860a..73dcc0a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3002,7 +3002,7 @@ s32 ixgbe_init_uta_tables_generic(struct ixgbe_hw *hw)
 static s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan, bool vlvf_bypass)
 {
 	s32 regindex, first_empty_slot;
-	u32 bits = 0;
+	u32 bits;
 
 	/* short cut the special case */
 	if (vlan == 0)
@@ -3014,33 +3014,29 @@ static s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan, bool vlvf_bypass)
 	 */
 	first_empty_slot = vlvf_bypass ? IXGBE_ERR_NO_SPACE : 0;
 
-	/*
-	  * Search for the vlan id in the VLVF entries. Save off the first empty
-	  * slot found along the way
-	  */
-	for (regindex = 1; regindex < IXGBE_VLVF_ENTRIES; regindex++) {
+	/* add VLAN enable bit for comparison */
+	vlan |= IXGBE_VLVF_VIEN;
+
+	/* Search for the vlan id in the VLVF entries. Save off the first empty
+	 * slot found along the way.
+	 *
+	 * pre-decrement loop covering (IXGBE_VLVF_ENTRIES - 1) .. 1
+	 */
+	for (regindex = IXGBE_VLVF_ENTRIES; --regindex;) {
 		bits = IXGBE_READ_REG(hw, IXGBE_VLVF(regindex));
-		if (!bits && !(first_empty_slot))
+		if (bits == vlan)
+			return regindex;
+		if (!first_empty_slot && !bits)
 			first_empty_slot = regindex;
-		else if ((bits & 0x0FFF) == vlan)
-			break;
 	}
 
-	/*
-	  * If regindex is less than IXGBE_VLVF_ENTRIES, then we found the vlan
-	  * in the VLVF. Else use the first empty VLVF register for this
-	  * vlan id.
-	  */
-	if (regindex >= IXGBE_VLVF_ENTRIES) {
-		if (first_empty_slot)
-			regindex = first_empty_slot;
-		else {
-			hw_dbg(hw, "No space in VLVF.\n");
-			regindex = IXGBE_ERR_NO_SPACE;
-		}
-	}
+	/* If we are here then we didn't find the VLAN.  Return first empty
+	 * slot we found during our search, else error.
+	 */
+	if (!first_empty_slot)
+		hw_dbg(hw, "No space in VLVF.\n");
 
-	return regindex;
+	return first_empty_slot ? : IXGBE_ERR_NO_SPACE;
 }
 
 /**
-- 
2.5.0
