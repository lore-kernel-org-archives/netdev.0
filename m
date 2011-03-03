From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 14/24] ixgbe: Bounds checking for set_rar, clear_rar, set_vmdq, clear_vmdq
Date: Thu,  3 Mar 2011 05:03:39 -0800
Message-ID: <1299157429-15878-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758205Ab1CCNEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:23 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change makes it so that out of bounds requests to these calls will
now return IXGBE_ERR_INVALID_ARGUMENT instead of returning 0.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |   24 ++++--
 drivers/net/ixgbe/ixgbe_common.c |  153 +++++++++++++++++++-------------------
 drivers/net/ixgbe/ixgbe_type.h   |    1 -
 3 files changed, 95 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 291b1e6..bff7011 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -858,6 +858,13 @@ reset_hw_out:
 static s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 {
 	u32 rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	/* Make sure we are using a valid rar index range */
+	if (rar >= rar_entries) {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
 
 	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
 	rar_high &= ~IXGBE_RAH_VIND_MASK;
@@ -877,14 +884,17 @@ static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 	u32 rar_high;
 	u32 rar_entries = hw->mac.num_rar_entries;
 
-	if (rar < rar_entries) {
-		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
-		if (rar_high & IXGBE_RAH_VIND_MASK) {
-			rar_high &= ~IXGBE_RAH_VIND_MASK;
-			IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
-		}
-	} else {
+
+	/* Make sure we are using a valid rar index range */
+	if (rar >= rar_entries) {
 		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
+	if (rar_high & IXGBE_RAH_VIND_MASK) {
+		rar_high &= ~IXGBE_RAH_VIND_MASK;
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
 	}
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 7e3bb55..882a350 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1239,37 +1239,37 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
 	u32 rar_low, rar_high;
 	u32 rar_entries = hw->mac.num_rar_entries;
 
+	/* Make sure we are using a valid rar index range */
+	if (index >= rar_entries) {
+		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
+
 	/* setup VMDq pool selection before this RAR gets enabled */
 	hw->mac.ops.set_vmdq(hw, index, vmdq);
 
-	/* Make sure we are using a valid rar index range */
-	if (index < rar_entries) {
-		/*
-		 * HW expects these in little endian so we reverse the byte
-		 * order from network order (big endian) to little endian
-		 */
-		rar_low = ((u32)addr[0] |
-		           ((u32)addr[1] << 8) |
-		           ((u32)addr[2] << 16) |
-		           ((u32)addr[3] << 24));
-		/*
-		 * Some parts put the VMDq setting in the extra RAH bits,
-		 * so save everything except the lower 16 bits that hold part
-		 * of the address and the address valid bit.
-		 */
-		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
-		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
-		rar_high |= ((u32)addr[4] | ((u32)addr[5] << 8));
+	/*
+	 * HW expects these in little endian so we reverse the byte
+	 * order from network order (big endian) to little endian
+	 */
+	rar_low = ((u32)addr[0] |
+		   ((u32)addr[1] << 8) |
+		   ((u32)addr[2] << 16) |
+		   ((u32)addr[3] << 24));
+	/*
+	 * Some parts put the VMDq setting in the extra RAH bits,
+	 * so save everything except the lower 16 bits that hold part
+	 * of the address and the address valid bit.
+	 */
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+	rar_high |= ((u32)addr[4] | ((u32)addr[5] << 8));
 
-		if (enable_addr != 0)
-			rar_high |= IXGBE_RAH_AV;
+	if (enable_addr != 0)
+		rar_high |= IXGBE_RAH_AV;
 
-		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
-		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
-	} else {
-		hw_dbg(hw, "RAR index %d is out of range.\n", index);
-		return IXGBE_ERR_RAR_INDEX;
-	}
+	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 
 	return 0;
 }
@@ -1287,22 +1287,22 @@ s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index)
 	u32 rar_entries = hw->mac.num_rar_entries;
 
 	/* Make sure we are using a valid rar index range */
-	if (index < rar_entries) {
-		/*
-		 * Some parts put the VMDq setting in the extra RAH bits,
-		 * so save everything except the lower 16 bits that hold part
-		 * of the address and the address valid bit.
-		 */
-		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
-		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
-
-		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
-	} else {
+	if (index >= rar_entries) {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
-		return IXGBE_ERR_RAR_INDEX;
+		return IXGBE_ERR_INVALID_ARGUMENT;
 	}
 
+	/*
+	 * Some parts put the VMDq setting in the extra RAH bits,
+	 * so save everything except the lower 16 bits that hold part
+	 * of the address and the address valid bit.
+	 */
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+
+	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+
 	/* clear VMDq pool/queue selection for this RAR */
 	hw->mac.ops.clear_vmdq(hw, index, IXGBE_CLEAR_VMDQ_ALL);
 
@@ -2468,37 +2468,38 @@ s32 ixgbe_clear_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 	u32 mpsar_lo, mpsar_hi;
 	u32 rar_entries = hw->mac.num_rar_entries;
 
-	if (rar < rar_entries) {
-		mpsar_lo = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
-		mpsar_hi = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
+	/* Make sure we are using a valid rar index range */
+	if (rar >= rar_entries) {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
 
-		if (!mpsar_lo && !mpsar_hi)
-			goto done;
+	mpsar_lo = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
+	mpsar_hi = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
 
-		if (vmdq == IXGBE_CLEAR_VMDQ_ALL) {
-			if (mpsar_lo) {
-				IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), 0);
-				mpsar_lo = 0;
-			}
-			if (mpsar_hi) {
-				IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), 0);
-				mpsar_hi = 0;
-			}
-		} else if (vmdq < 32) {
-			mpsar_lo &= ~(1 << vmdq);
-			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar_lo);
-		} else {
-			mpsar_hi &= ~(1 << (vmdq - 32));
-			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar_hi);
-		}
+	if (!mpsar_lo && !mpsar_hi)
+		goto done;
 
-		/* was that the last pool using this rar? */
-		if (mpsar_lo == 0 && mpsar_hi == 0 && rar != 0)
-			hw->mac.ops.clear_rar(hw, rar);
+	if (vmdq == IXGBE_CLEAR_VMDQ_ALL) {
+		if (mpsar_lo) {
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), 0);
+			mpsar_lo = 0;
+		}
+		if (mpsar_hi) {
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), 0);
+			mpsar_hi = 0;
+		}
+	} else if (vmdq < 32) {
+		mpsar_lo &= ~(1 << vmdq);
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar_lo);
 	} else {
-		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+		mpsar_hi &= ~(1 << (vmdq - 32));
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar_hi);
 	}
 
+	/* was that the last pool using this rar? */
+	if (mpsar_lo == 0 && mpsar_hi == 0 && rar != 0)
+		hw->mac.ops.clear_rar(hw, rar);
 done:
 	return 0;
 }
@@ -2514,18 +2515,20 @@ s32 ixgbe_set_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 	u32 mpsar;
 	u32 rar_entries = hw->mac.num_rar_entries;
 
-	if (rar < rar_entries) {
-		if (vmdq < 32) {
-			mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
-			mpsar |= 1 << vmdq;
-			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar);
-		} else {
-			mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
-			mpsar |= 1 << (vmdq - 32);
-			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar);
-		}
-	} else {
+	/* Make sure we are using a valid rar index range */
+	if (rar >= rar_entries) {
 		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
+
+	if (vmdq < 32) {
+		mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
+		mpsar |= 1 << vmdq;
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar);
+	} else {
+		mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
+		mpsar |= 1 << (vmdq - 32);
+		IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar);
 	}
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index a737b13..b1ae185 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2689,7 +2689,6 @@ struct ixgbe_info {
 #define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_ERR_NO_SPACE                      -25
 #define IXGBE_ERR_OVERTEMP                      -26
-#define IXGBE_ERR_RAR_INDEX                     -27
 #define IXGBE_ERR_SFP_SETUP_NOT_COMPLETE        -30
 #define IXGBE_ERR_PBA_SECTION                   -31
 #define IXGBE_ERR_INVALID_ARGUMENT              -32
-- 
1.7.4

