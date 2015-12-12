From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] ixgbe: Reduce VT code indent in set_vfta by introducing jump label
Date: Sat, 12 Dec 2015 03:14:42 -0800
Message-ID: <1449918890-145243-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30916 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbbLLLPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:03 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

In order to clear the way for upcoming work I thought it best to drop the
level of indent in the ixgbe_set_vfta_generic function.  Most of the code
is held in the virtualization specific section.  So the easiest approach is
to just add a jump label and jump past the bulk of the code if it is not
enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 142 ++++++++++++------------
 1 file changed, 70 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 027c1ad..f608973 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3051,8 +3051,8 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			   bool vlan_on)
 {
 	u32 regidx, vfta_delta, vfta;
+	s32 vlvf_index;
 	u32 bits;
-	u32 vt;
 
 	if (vlan > 4095)
 		return IXGBE_ERR_PARAM;
@@ -3088,83 +3088,81 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	 *   Or !vlan_on
 	 *     clear the pool bit and possibly the vind
 	 */
-	vt = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
-	if (vt & IXGBE_VT_CTL_VT_ENABLE) {
-		s32 vlvf_index;
-
-		vlvf_index = ixgbe_find_vlvf_slot(hw, vlan);
-		if (vlvf_index < 0)
-			return vlvf_index;
-
-		if (vlan_on) {
-			/* set the pool bit */
-			if (vind < 32) {
-				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2));
-				bits |= (1 << vind);
-				IXGBE_WRITE_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2),
-						bits);
-			} else {
-				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1));
-				bits |= (1 << (vind-32));
-				IXGBE_WRITE_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1),
-						bits);
-			}
+	if (!(IXGBE_READ_REG(hw, IXGBE_VT_CTL) & IXGBE_VT_CTL_VT_ENABLE))
+		goto vfta_update;
+
+	vlvf_index = ixgbe_find_vlvf_slot(hw, vlan);
+	if (vlvf_index < 0)
+		return vlvf_index;
+
+	if (vlan_on) {
+		/* set the pool bit */
+		if (vind < 32) {
+			bits = IXGBE_READ_REG(hw,
+					IXGBE_VLVFB(vlvf_index*2));
+			bits |= (1 << vind);
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB(vlvf_index*2),
+					bits);
 		} else {
-			/* clear the pool bit */
-			if (vind < 32) {
-				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2));
-				bits &= ~(1 << vind);
-				IXGBE_WRITE_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2),
-						bits);
-				bits |= IXGBE_READ_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1));
-			} else {
-				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1));
-				bits &= ~(1 << (vind-32));
-				IXGBE_WRITE_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1),
-						bits);
-				bits |= IXGBE_READ_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2));
-			}
+			bits = IXGBE_READ_REG(hw,
+					IXGBE_VLVFB((vlvf_index*2)+1));
+			bits |= (1 << (vind-32));
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB((vlvf_index*2)+1),
+					bits);
 		}
-
-		/*
-		 * If there are still bits set in the VLVFB registers
-		 * for the VLAN ID indicated we need to see if the
-		 * caller is requesting that we clear the VFTA entry bit.
-		 * If the caller has requested that we clear the VFTA
-		 * entry bit but there are still pools/VFs using this VLAN
-		 * ID entry then ignore the request.  We're not worried
-		 * about the case where we're turning the VFTA VLAN ID
-		 * entry bit on, only when requested to turn it off as
-		 * there may be multiple pools and/or VFs using the
-		 * VLAN ID entry.  In that case we cannot clear the
-		 * VFTA bit until all pools/VFs using that VLAN ID have also
-		 * been cleared.  This will be indicated by "bits" being
-		 * zero.
-		 */
-		if (bits) {
-			IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index),
-					(IXGBE_VLVF_VIEN | vlan));
-
-			/* if someone wants to clear the vfta entry but
-			 * some pools/VFs are still using it.  Ignore it.
-			 */
-			if (!vlan_on)
-				vfta_delta = 0;
+	} else {
+		/* clear the pool bit */
+		if (vind < 32) {
+			bits = IXGBE_READ_REG(hw,
+					IXGBE_VLVFB(vlvf_index*2));
+			bits &= ~(1 << vind);
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB(vlvf_index*2),
+					bits);
+			bits |= IXGBE_READ_REG(hw,
+					IXGBE_VLVFB((vlvf_index*2)+1));
 		} else {
-			IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
+			bits = IXGBE_READ_REG(hw,
+					IXGBE_VLVFB((vlvf_index*2)+1));
+			bits &= ~(1 << (vind-32));
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB((vlvf_index*2)+1),
+					bits);
+			bits |= IXGBE_READ_REG(hw,
+					IXGBE_VLVFB(vlvf_index*2));
 		}
 	}
 
+	/* If there are still bits set in the VLVFB registers
+	 * for the VLAN ID indicated we need to see if the
+	 * caller is requesting that we clear the VFTA entry bit.
+	 * If the caller has requested that we clear the VFTA
+	 * entry bit but there are still pools/VFs using this VLAN
+	 * ID entry then ignore the request.  We're not worried
+	 * about the case where we're turning the VFTA VLAN ID
+	 * entry bit on, only when requested to turn it off as
+	 * there may be multiple pools and/or VFs using the
+	 * VLAN ID entry.  In that case we cannot clear the
+	 * VFTA bit until all pools/VFs using that VLAN ID have also
+	 * been cleared.  This will be indicated by "bits" being
+	 * zero.
+	 */
+	if (bits) {
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index),
+				(IXGBE_VLVF_VIEN | vlan));
+
+		/* if someone wants to clear the vfta entry but
+		 * some pools/VFs are still using it.  Ignore it.
+		 */
+		if (!vlan_on)
+			vfta_delta = 0;
+	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
+	}
+
+vfta_update:
 	if (vfta_delta)
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(regidx), vfta);
 
-- 
2.5.0
