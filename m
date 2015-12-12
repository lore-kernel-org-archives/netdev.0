From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] ixgbe: Simplify definitions for regidx and bit in set_vfta
Date: Sat, 12 Dec 2015 03:14:41 -0800
Message-ID: <1449918890-145243-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbbLLLPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:01 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch simplifies the logic for setting the VFTA register by removing
the number of conditional checks needed.  Instead we just use some boolean
logic to generate vfta_delta, and if that is set then we xor the vfta by
that value and write it back.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 48 ++++++++++---------------
 1 file changed, 19 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index daec6ae..027c1ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3050,13 +3050,9 @@ static s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan)
 s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			   bool vlan_on)
 {
-	s32 regindex;
-	u32 bitindex;
-	u32 vfta;
+	u32 regidx, vfta_delta, vfta;
 	u32 bits;
 	u32 vt;
-	u32 targetbit;
-	bool vfta_changed = false;
 
 	if (vlan > 4095)
 		return IXGBE_ERR_PARAM;
@@ -3073,22 +3069,16 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	 *    bits[11-5]: which register
 	 *    bits[4-0]:  which bit in the register
 	 */
-	regindex = (vlan >> 5) & 0x7F;
-	bitindex = vlan & 0x1F;
-	targetbit = (1 << bitindex);
-	vfta = IXGBE_READ_REG(hw, IXGBE_VFTA(regindex));
-
-	if (vlan_on) {
-		if (!(vfta & targetbit)) {
-			vfta |= targetbit;
-			vfta_changed = true;
-		}
-	} else {
-		if ((vfta & targetbit)) {
-			vfta &= ~targetbit;
-			vfta_changed = true;
-		}
-	}
+	regidx = vlan / 32;
+	vfta_delta = 1 << (vlan % 32);
+	vfta = IXGBE_READ_REG(hw, IXGBE_VFTA(regidx));
+
+	/* vfta_delta represents the difference between the current value
+	 * of vfta and the value we want in the register.  Since the diff
+	 * is an XOR mask we can just update vfta using an XOR.
+	 */
+	vfta_delta &= vlan_on ? ~vfta : vfta;
+	vfta ^= vfta_delta;
 
 	/* Part 2
 	 * If VT Mode is set
@@ -3164,19 +3154,19 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 		if (bits) {
 			IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index),
 					(IXGBE_VLVF_VIEN | vlan));
-			if (!vlan_on) {
-				/* someone wants to clear the vfta entry
-				 * but some pools/VFs are still using it.
-				 * Ignore it. */
-				vfta_changed = false;
-			}
+
+			/* if someone wants to clear the vfta entry but
+			 * some pools/VFs are still using it.  Ignore it.
+			 */
+			if (!vlan_on)
+				vfta_delta = 0;
 		} else {
 			IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
 		}
 	}
 
-	if (vfta_changed)
-		IXGBE_WRITE_REG(hw, IXGBE_VFTA(regindex), vfta);
+	if (vfta_delta)
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(regidx), vfta);
 
 	return 0;
 }
-- 
2.5.0
