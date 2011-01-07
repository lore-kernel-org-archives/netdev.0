From: jeffrey.t.kirsher@intel.com
Subject: [net-next 06/12] e1000e: add custom set_d[0|3]_lplu_state function pointer for 82574
Date: Thu,  6 Jan 2011 16:29:53 -0800
Message-ID: <1294360199-9860-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33065 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997Ab1AGAat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:49 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

82574 needs to configure Low Power Link Up (or LPLU) differently than
the other parts in the 8257x family supported by the driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c |   56 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/e1000e/hw.h    |    1 +
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 11a273e..cb6c7b1 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -78,6 +78,8 @@ static void e1000_power_down_phy_copper_82571(struct e1000_hw *hw);
 static void e1000_put_hw_semaphore_82573(struct e1000_hw *hw);
 static s32 e1000_get_hw_semaphore_82574(struct e1000_hw *hw);
 static void e1000_put_hw_semaphore_82574(struct e1000_hw *hw);
+static s32 e1000_set_d0_lplu_state_82574(struct e1000_hw *hw, bool active);
+static s32 e1000_set_d3_lplu_state_82574(struct e1000_hw *hw, bool active);
 
 /**
  *  e1000_init_phy_params_82571 - Init PHY func ptrs.
@@ -113,6 +115,8 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 		phy->type		 = e1000_phy_bm;
 		phy->ops.acquire = e1000_get_hw_semaphore_82574;
 		phy->ops.release = e1000_put_hw_semaphore_82574;
+		phy->ops.set_d0_lplu_state = e1000_set_d0_lplu_state_82574;
+		phy->ops.set_d3_lplu_state = e1000_set_d3_lplu_state_82574;
 		break;
 	default:
 		return -E1000_ERR_PHY;
@@ -656,6 +660,58 @@ static void e1000_put_hw_semaphore_82574(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_set_d0_lplu_state_82574 - Set Low Power Linkup D0 state
+ *  @hw: pointer to the HW structure
+ *  @active: true to enable LPLU, false to disable
+ *
+ *  Sets the LPLU D0 state according to the active flag.
+ *  LPLU will not be activated unless the
+ *  device autonegotiation advertisement meets standards of
+ *  either 10 or 10/100 or 10/100/1000 at all duplexes.
+ *  This is a function pointer entry point only called by
+ *  PHY setup routines.
+ **/
+static s32 e1000_set_d0_lplu_state_82574(struct e1000_hw *hw, bool active)
+{
+	u16 data = er32(POEMB);
+
+	if (active)
+		data |= E1000_PHY_CTRL_D0A_LPLU;
+	else
+		data &= ~E1000_PHY_CTRL_D0A_LPLU;
+
+	ew32(POEMB, data);
+	return 0;
+}
+
+/**
+ *  e1000_set_d3_lplu_state_82574 - Sets low power link up state for D3
+ *  @hw: pointer to the HW structure
+ *  @active: boolean used to enable/disable lplu
+ *
+ *  The low power link up (lplu) state is set to the power management level D3
+ *  when active is true, else clear lplu for D3. LPLU
+ *  is used during Dx states where the power conservation is most important.
+ *  During driver activity, SmartSpeed should be enabled so performance is
+ *  maintained.
+ **/
+static s32 e1000_set_d3_lplu_state_82574(struct e1000_hw *hw, bool active)
+{
+	u16 data = er32(POEMB);
+
+	if (!active) {
+		data &= ~E1000_PHY_CTRL_NOND0A_LPLU;
+	} else if ((hw->phy.autoneg_advertised == E1000_ALL_SPEED_DUPLEX) ||
+		   (hw->phy.autoneg_advertised == E1000_ALL_NOT_GIG) ||
+		   (hw->phy.autoneg_advertised == E1000_ALL_10_SPEED)) {
+		data |= E1000_PHY_CTRL_NOND0A_LPLU;
+	}
+
+	ew32(POEMB, data);
+	return 0;
+}
+
+/**
  *  e1000_acquire_nvm_82571 - Request for access to the EEPROM
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index ba302a5..e774380 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -83,6 +83,7 @@ enum e1e_registers {
 	E1000_EXTCNF_CTRL  = 0x00F00, /* Extended Configuration Control */
 	E1000_EXTCNF_SIZE  = 0x00F08, /* Extended Configuration Size */
 	E1000_PHY_CTRL     = 0x00F10, /* PHY Control Register in CSR */
+#define E1000_POEMB	E1000_PHY_CTRL	/* PHY OEM Bits */
 	E1000_PBA      = 0x01000, /* Packet Buffer Allocation - RW */
 	E1000_PBS      = 0x01008, /* Packet Buffer Size */
 	E1000_EEMNGCTL = 0x01010, /* MNG EEprom Control */
-- 
1.7.3.4

