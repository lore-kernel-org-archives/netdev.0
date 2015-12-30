From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 7/8] ixgbe: Correct X550EM_x revision check
Date: Tue, 29 Dec 2015 19:23:28 -0800
Message-ID: <1451445809-70497-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27547 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064AbbL3DXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:23:36 -0500
In-Reply-To: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The X550EM_x revision check needs to check a value, not just a bit.
Use a mask and check the value. Also remove the redundant check
inside the ixgbe_enter_lplu_t_x550em, because it can only be called
when both the mac type and revision check pass.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 9 +++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 06add27..5f53cc6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3520,7 +3520,7 @@ struct ixgbe_info {
 
 #define IXGBE_FUSES0_GROUP(_i)		(0x11158 + ((_i) * 4))
 #define IXGBE_FUSES0_300MHZ		BIT(5)
-#define IXGBE_FUSES0_REV1		BIT(6)
+#define IXGBE_FUSES0_REV_MASK		(3 << 6)
 
 #define IXGBE_KRM_PORT_CAR_GEN_CTRL(P)	((P) ? 0x8010 : 0x4010)
 #define IXGBE_KRM_LINK_CTRL_1(P)	((P) ? 0x820C : 0x420C)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index f4ef0d1..87aca3f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1857,10 +1857,6 @@ static s32 ixgbe_enter_lplu_t_x550em(struct ixgbe_hw *hw)
 	u32 save_autoneg;
 	bool link_up;
 
-	/* SW LPLU not required on later HW revisions. */
-	if (IXGBE_FUSES0_REV1 & IXGBE_READ_REG(hw, IXGBE_FUSES0_GROUP(0)))
-		return 0;
-
 	/* If blocked by MNG FW, then don't restart AN */
 	if (ixgbe_check_reset_blocked(hw))
 		return 0;
@@ -2000,8 +1996,9 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 					      ixgbe_setup_internal_phy_t_x550em;
 
 		/* setup SW LPLU only for first revision */
-		if (!(IXGBE_FUSES0_REV1 & IXGBE_READ_REG(hw,
-							IXGBE_FUSES0_GROUP(0))))
+		if (hw->mac.type == ixgbe_mac_X550EM_x &&
+		    !(IXGBE_READ_REG(hw, IXGBE_FUSES0_GROUP(0)) &
+		      IXGBE_FUSES0_REV_MASK))
 			phy->ops.enter_lplu = ixgbe_enter_lplu_t_x550em;
 
 		phy->ops.handle_lasi = ixgbe_handle_lasi_ext_t_x550em;
-- 
2.5.0
