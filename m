From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 05/11] ixgbe: Simplify configuration of setting VLVF
 and VLVFB
Date: Mon, 02 Nov 2015 17:09:54 -0800
Message-ID: <20151103010954.28233.65503.stgit@localhost.localdomain>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33822 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055AbbKCBJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 20:09:56 -0500
Received: by padec8 with SMTP id ec8so2069155pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 17:09:55 -0800 (PST)
In-Reply-To: <20151103005850.28233.63113.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses several issues within the VLVF and VLVFB
configuration

First was the fact that code was overly complicated with multiple
conditional paths depending on if we adding or removing and which bit we
were going to add or remove.  Instead of messing with all that I have
simplified it by using (vid / 32) and (1 - vid / 32) to identify our
register and the other vlvfb register.

Second was the fact that we were likely leaking a few packets into the PF
in cases where we were deleting an entry and the VFTA filter for that entry
as the ordering was such that we deleted the pool and then the VLAN filter
instead of the other way around.  I have updated that by adding a check for
no bits being set and if that occurs we clear things up in the proper
order.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   88 +++++++++--------------
 1 file changed, 34 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index f608973ae73e..3f5fe60fdc11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3050,11 +3050,10 @@ static s32 ixgbe_find_vlvf_slot(struct ixgbe_hw *hw, u32 vlan)
 s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			   bool vlan_on)
 {
-	u32 regidx, vfta_delta, vfta;
+	u32 regidx, vfta_delta, vfta, bits;
 	s32 vlvf_index;
-	u32 bits;
 
-	if (vlan > 4095)
+	if ((vlan > 4095) || (vind > 63))
 		return IXGBE_ERR_PARAM;
 
 	/*
@@ -3095,44 +3094,30 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	if (vlvf_index < 0)
 		return vlvf_index;
 
-	if (vlan_on) {
-		/* set the pool bit */
-		if (vind < 32) {
-			bits = IXGBE_READ_REG(hw,
-					IXGBE_VLVFB(vlvf_index*2));
-			bits |= (1 << vind);
-			IXGBE_WRITE_REG(hw,
-					IXGBE_VLVFB(vlvf_index*2),
-					bits);
-		} else {
-			bits = IXGBE_READ_REG(hw,
-					IXGBE_VLVFB((vlvf_index*2)+1));
-			bits |= (1 << (vind-32));
-			IXGBE_WRITE_REG(hw,
-					IXGBE_VLVFB((vlvf_index*2)+1),
-					bits);
-		}
-	} else {
-		/* clear the pool bit */
-		if (vind < 32) {
-			bits = IXGBE_READ_REG(hw,
-					IXGBE_VLVFB(vlvf_index*2));
-			bits &= ~(1 << vind);
-			IXGBE_WRITE_REG(hw,
-					IXGBE_VLVFB(vlvf_index*2),
-					bits);
-			bits |= IXGBE_READ_REG(hw,
-					IXGBE_VLVFB((vlvf_index*2)+1));
-		} else {
-			bits = IXGBE_READ_REG(hw,
-					IXGBE_VLVFB((vlvf_index*2)+1));
-			bits &= ~(1 << (vind-32));
-			IXGBE_WRITE_REG(hw,
-					IXGBE_VLVFB((vlvf_index*2)+1),
-					bits);
-			bits |= IXGBE_READ_REG(hw,
-					IXGBE_VLVFB(vlvf_index*2));
-		}
+	bits = IXGBE_READ_REG(hw, IXGBE_VLVFB(vlvf_index * 2 + vind / 32));
+
+	/* set the pool bit */
+	bits |= 1 << (vind % 32);
+	if (vlan_on)
+		goto vlvf_update;
+
+	/* clear the pool bit */
+	bits ^= 1 << (vind % 32);
+
+	if (!bits &&
+	    !IXGBE_READ_REG(hw, IXGBE_VLVFB(vlvf_index * 2 + 1 - vind / 32))) {
+		/* Clear VFTA first, then disable VLVF.  Otherwise
+		 * we run the risk of stray packets leaking into
+		 * the PF via the default pool
+		 */
+		if (vfta_delta)
+			IXGBE_WRITE_REG(hw, IXGBE_VFTA(regidx), vfta);
+
+		/* disable VLVF and clear remaining bit from pool */
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(vlvf_index * 2 + vind / 32), 0);
+
+		return 0;
 	}
 
 	/* If there are still bits set in the VLVFB registers
@@ -3149,20 +3134,15 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	 * been cleared.  This will be indicated by "bits" being
 	 * zero.
 	 */
-	if (bits) {
-		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index),
-				(IXGBE_VLVF_VIEN | vlan));
+	vfta_delta = 0;
 
-		/* if someone wants to clear the vfta entry but
-		 * some pools/VFs are still using it.  Ignore it.
-		 */
-		if (!vlan_on)
-			vfta_delta = 0;
-	} else {
-		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
-	}
+vlvf_update:
+	/* record pool change and enable VLAN ID if not already enabled */
+	IXGBE_WRITE_REG(hw, IXGBE_VLVFB(vlvf_index * 2 + vind / 32), bits);
+	IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), IXGBE_VLVF_VIEN | vlan);
 
 vfta_update:
+	/* Update VFTA now that we are ready for traffic */
 	if (vfta_delta)
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(regidx), vfta);
 
@@ -3184,8 +3164,8 @@ s32 ixgbe_clear_vfta_generic(struct ixgbe_hw *hw)
 
 	for (offset = 0; offset < IXGBE_VLVF_ENTRIES; offset++) {
 		IXGBE_WRITE_REG(hw, IXGBE_VLVF(offset), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(offset*2), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_VLVFB((offset*2)+1), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(offset * 2), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(offset * 2 + 1), 0);
 	}
 
 	return 0;
