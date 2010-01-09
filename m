From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/13] ixgbe: Add SR-IOV feature enablement code
Date: Sat, 09 Jan 2010 04:26:26 -0800
Message-ID: <20100109122624.4462.26671.stgit@localhost.localdomain>
References: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:57524 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907Ab0AIM0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:26:45 -0500
In-Reply-To: <20100109120719.4462.66489.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Adds code to the core 82599 module to support SR-IOV features of the 82599
network controller

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |  126 +++++++++++++++++++++------------------
 1 files changed, 68 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5383405..9ec296c 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -31,6 +31,7 @@
 
 #include "ixgbe.h"
 #include "ixgbe_phy.h"
+#include "ixgbe_mbx.h"
 
 #define IXGBE_82599_MAX_TX_QUEUES 128
 #define IXGBE_82599_MAX_RX_QUEUES 128
@@ -951,8 +952,6 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 
 	msleep(50);
 
-
-
 	/*
 	 * Store the original AUTOC/AUTOC2 values if they have not been
 	 * stored off yet.  Otherwise restore the stored original
@@ -1095,9 +1094,11 @@ static s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
                                 bool vlan_on)
 {
 	u32 regindex;
+	u32 vlvf_index;
 	u32 bitindex;
 	u32 bits;
 	u32 first_empty_slot;
+	u32 vt_ctl;
 
 	if (vlan > 4095)
 		return IXGBE_ERR_PARAM;
@@ -1124,76 +1125,84 @@ static s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 
 
 	/* Part 2
-	 * If the vind is set
+	 * If VT mode is set
 	 *   Either vlan_on
 	 *     make sure the vlan is in VLVF
 	 *     set the vind bit in the matching VLVFB
 	 *   Or !vlan_on
 	 *     clear the pool bit and possibly the vind
 	 */
-	if (vind) {
-		/* find the vlanid or the first empty slot */
-		first_empty_slot = 0;
-
-		for (regindex = 1; regindex < IXGBE_VLVF_ENTRIES; regindex++) {
-			bits = IXGBE_READ_REG(hw, IXGBE_VLVF(regindex));
-			if (!bits && !first_empty_slot)
-				first_empty_slot = regindex;
-			else if ((bits & 0x0FFF) == vlan)
-				break;
-		}
+	vt_ctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
+	if (!(vt_ctl & IXGBE_VT_CTL_VT_ENABLE))
+		goto out;
 
-		if (regindex >= IXGBE_VLVF_ENTRIES) {
-			if (first_empty_slot)
-				regindex = first_empty_slot;
-			else {
-				hw_dbg(hw, "No space in VLVF.\n");
-				goto out;
-			}
+	/* find the vlanid or the first empty slot */
+	first_empty_slot = 0;
+
+	for (vlvf_index = 1; vlvf_index < IXGBE_VLVF_ENTRIES; vlvf_index++) {
+		bits = IXGBE_READ_REG(hw, IXGBE_VLVF(vlvf_index));
+		if (!bits && !first_empty_slot)
+			first_empty_slot = vlvf_index;
+		else if ((bits & 0x0FFF) == vlan)
+			break;
+	}
+
+	if (vlvf_index >= IXGBE_VLVF_ENTRIES) {
+		if (first_empty_slot)
+			vlvf_index = first_empty_slot;
+		else {
+			hw_dbg(hw, "No space in VLVF.\n");
+			goto out;
 		}
+	}
 
-		if (vlan_on) {
-			/* set the pool bit */
-			if (vind < 32) {
-				bits = IXGBE_READ_REG(hw,
-				                    IXGBE_VLVFB(regindex * 2));
-				bits |= (1 << vind);
-				IXGBE_WRITE_REG(hw,
-				              IXGBE_VLVFB(regindex * 2), bits);
-			} else {
-				bits = IXGBE_READ_REG(hw,
-				              IXGBE_VLVFB((regindex * 2) + 1));
-				bits |= (1 << vind);
-				IXGBE_WRITE_REG(hw,
-				        IXGBE_VLVFB((regindex * 2) + 1), bits);
-			}
+	if (vlan_on) {
+		/* set the pool bit */
+		if (vind < 32) {
+			bits = IXGBE_READ_REG(hw,
+					      IXGBE_VLVFB(vlvf_index * 2));
+			bits |= (1 << vind);
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB(vlvf_index * 2), bits);
 		} else {
-			/* clear the pool bit */
-			if (vind < 32) {
-				bits = IXGBE_READ_REG(hw,
-				     IXGBE_VLVFB(regindex * 2));
+			bits = IXGBE_READ_REG(hw,
+				IXGBE_VLVFB((vlvf_index * 2) + 1));
+			bits |= (1 << (vind - 32));
+			IXGBE_WRITE_REG(hw,
+				IXGBE_VLVFB((vlvf_index * 2) + 1), bits);
+		}
+	} else {
+		/* clear the pool bit */
+		if (vind < 32) {
+			bits = IXGBE_READ_REG(hw,
+					      IXGBE_VLVFB(vlvf_index * 2));
 			bits &= ~(1 << vind);
-				IXGBE_WRITE_REG(hw,
-				              IXGBE_VLVFB(regindex * 2), bits);
-				bits |= IXGBE_READ_REG(hw,
-				              IXGBE_VLVFB((regindex * 2) + 1));
-			} else {
-				bits = IXGBE_READ_REG(hw,
-				              IXGBE_VLVFB((regindex * 2) + 1));
-				bits &= ~(1 << vind);
-				IXGBE_WRITE_REG(hw,
-				        IXGBE_VLVFB((regindex * 2) + 1), bits);
-				bits |= IXGBE_READ_REG(hw,
-				                    IXGBE_VLVFB(regindex * 2));
-			}
+			IXGBE_WRITE_REG(hw,
+					IXGBE_VLVFB(vlvf_index * 2), bits);
+			bits |= IXGBE_READ_REG(hw,
+					IXGBE_VLVFB((vlvf_index * 2) + 1));
+		} else {
+			bits = IXGBE_READ_REG(hw,
+				IXGBE_VLVFB((vlvf_index * 2) + 1));
+			bits &= ~(1 << (vind - 32));
+			IXGBE_WRITE_REG(hw,
+				IXGBE_VLVFB((vlvf_index * 2) + 1), bits);
+			bits |= IXGBE_READ_REG(hw,
+					       IXGBE_VLVFB(vlvf_index * 2));
 		}
+	}
 
-		if (bits)
-			IXGBE_WRITE_REG(hw, IXGBE_VLVF(regindex),
-			                (IXGBE_VLVF_VIEN | vlan));
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_VLVF(regindex), 0);
+	if (bits) {
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index),
+				(IXGBE_VLVF_VIEN | vlan));
+		/* if bits is non-zero then some pools/VFs are still
+		 * using this VLAN ID.  Force the VFTA entry to on */
+		bits = IXGBE_READ_REG(hw, IXGBE_VFTA(regindex));
+		bits |= (1 << bitindex);
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(regindex), bits);
 	}
+	else
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(vlvf_index), 0);
 
 out:
 	return 0;
@@ -2655,4 +2664,5 @@ struct ixgbe_info ixgbe_82599_info = {
 	.mac_ops                = &mac_ops_82599,
 	.eeprom_ops             = &eeprom_ops_82599,
 	.phy_ops                = &phy_ops_82599,
+	.mbx_ops                = &mbx_ops_82599,
 };

