From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/40] ixgbe: consolidate MRQC and MTQC handling
Date: Tue,  7 Jun 2011 05:32:48 -0700
Message-ID: <1307449995-9458-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43685 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab1FGMdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:24 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The MRQC and MTQC registers are configured in the main
setup path but are also reconfigured in the DCB setup
path. The DCB path fixes the DCB configuration by configuring
the SECTXMINIFG gap which is required for DCB pause
to operate correctly.

This patch reduces the duplicate code and does all setup
in ixgbe_setup_mtqc() and ixgbe_setup_mrqc().

Additionally, this removes the IXGBE_QDE. This write never
set the WRITE bit in the register so the write was not
actually doing anything. Also this was to clear the register
but, it is never set and defaults to zero. If this is
needed for SRIOV it should be added correctly in a follow
up patch. But it's never been working so removing it here
should be OK.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   57 -----------------------------------
 drivers/net/ixgbe/ixgbe_main.c      |    7 ++++
 2 files changed, 7 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index befe8ad..ade9820 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -319,62 +319,6 @@ static s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
 }
 
 /**
- * ixgbe_dcb_config_82599 - Configure general DCB parameters
- * @hw: pointer to hardware structure
- *
- * Configure general DCB parameters.
- */
-static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
-{
-	u32 reg;
-	u32 q;
-
-	/* Disable the Tx desc arbiter so that MTQC can be changed */
-	reg = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
-	reg |= IXGBE_RTTDCS_ARBDIS;
-	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
-
-	/* Enable DCB for Rx with 8 TCs */
-	reg = IXGBE_READ_REG(hw, IXGBE_MRQC);
-	switch (reg & IXGBE_MRQC_MRQE_MASK) {
-	case 0:
-	case IXGBE_MRQC_RT4TCEN:
-		/* RSS disabled cases */
-		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RT8TCEN;
-		break;
-	case IXGBE_MRQC_RSSEN:
-	case IXGBE_MRQC_RTRSS4TCEN:
-		/* RSS enabled cases */
-		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RTRSS8TCEN;
-		break;
-	default:
-		/* Unsupported value, assume stale data, overwrite no RSS */
-		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RT8TCEN;
-	}
-	IXGBE_WRITE_REG(hw, IXGBE_MRQC, reg);
-
-	/* Enable DCB for Tx with 8 TCs */
-	reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
-	IXGBE_WRITE_REG(hw, IXGBE_MTQC, reg);
-
-	/* Disable drop for all queues */
-	for (q = 0; q < 128; q++)
-		IXGBE_WRITE_REG(hw, IXGBE_QDE, q << IXGBE_QDE_IDX_SHIFT);
-
-	/* Enable the Tx desc arbiter */
-	reg = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
-	reg &= ~IXGBE_RTTDCS_ARBDIS;
-	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
-
-	/* Enable Security TX Buffer IFG for DCB */
-	reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
-	reg |= IXGBE_SECTX_DCB;
-	IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
-
-	return 0;
-}
-
-/**
  * ixgbe_dcb_hw_config_82599 - Configure and enable DCB
  * @hw: pointer to hardware structure
  * @refill: refill credits index by traffic class
@@ -388,7 +332,6 @@ static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw, u8 pfc_en, u16 *refill,
 			      u16 *max, u8 *bwg_id, u8 *prio_type, u8 *prio_tc)
 {
-	ixgbe_dcb_config_82599(hw);
 	ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max, bwg_id,
 					  prio_type, prio_tc);
 	ixgbe_dcb_config_tx_desc_arbiter_82599(hw, refill, max,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ff813eb..66fc94a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2815,6 +2815,7 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rttdcs;
 	u32 mask;
+	u32 reg;
 
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
@@ -2837,6 +2838,12 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 		/* We enable 8 traffic classes, DCB only */
 		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
 			      (IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ));
+
+		/* Enable Security TX Buffer IFG for DCB */
+		reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
+		reg |= IXGBE_SECTX_DCB;
+		IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
+
 		break;
 
 	default:
-- 
1.7.5.2

