From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] e1000e: workaround EEPROM configuration change on 82579
Date: Wed,  2 May 2012 02:13:39 -0700
Message-ID: <1335950025-13294-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19601 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236Ab2EBJOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 05:14:02 -0400
In-Reply-To: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

An update to the EEPROM on 82579 will extend a delay in hardware to fix an
issue with WoL not working after a G3->S5 transition which is unrelated to
the driver.  However, this extended delay conflicts with nominal operation
of the device when it is initialized by the driver and after every reset
of the hardware (i.e. the driver starts configuring the device before the
hardware is done with it's own configuration work).  The workaround for
when the driver is in control of the device is to tell the hardware after
every reset the configuration delay should be the original shorter one.

Some pre-existing variables are renamed generically to be re-used with
new register accesses.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h      |    1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   48 ++++++++++++++++++--------
 2 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 7ca1b68..3a5acb5 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -51,6 +51,7 @@ enum e1e_registers {
 	E1000_FEXTNVM  = 0x00028, /* Future Extended NVM - RW */
 	E1000_FCT      = 0x00030, /* Flow Control Type - RW */
 	E1000_VET      = 0x00038, /* VLAN Ether Type - RW */
+	E1000_FEXTNVM3 = 0x0003C, /* Future Extended NVM 3 - RW */
 	E1000_ICR      = 0x000C0, /* Interrupt Cause Read - R/clr */
 	E1000_ITR      = 0x000C4, /* Interrupt Throttling Rate - RW */
 	E1000_ICS      = 0x000C8, /* Interrupt Cause Set - WO */
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index d7fd1e8..2506ee2 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -105,6 +105,9 @@
 #define E1000_FEXTNVM_SW_CONFIG		1
 #define E1000_FEXTNVM_SW_CONFIG_ICH8M (1 << 27) /* Bit redefined for ICH8M :/ */
 
+#define E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK    0x0C000000
+#define E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC  0x08000000
+
 #define E1000_FEXTNVM4_BEACON_DURATION_MASK    0x7
 #define E1000_FEXTNVM4_BEACON_DURATION_8USEC   0x7
 #define E1000_FEXTNVM4_BEACON_DURATION_16USEC  0x3
@@ -286,16 +289,23 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 
 static void e1000_toggle_lanphypc_value_ich8lan(struct e1000_hw *hw)
 {
-	u32 ctrl;
+	u32 reg;
 
-	ctrl = er32(CTRL);
-	ctrl |= E1000_CTRL_LANPHYPC_OVERRIDE;
-	ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
-	ew32(CTRL, ctrl);
+	/* Set Phy Config Counter to 50msec */
+	reg = er32(FEXTNVM3);
+	reg &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
+	reg |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
+	ew32(FEXTNVM3, reg);
+
+	/* Toggle LANPHYPC Value bit */
+	reg = er32(CTRL);
+	reg |= E1000_CTRL_LANPHYPC_OVERRIDE;
+	reg &= ~E1000_CTRL_LANPHYPC_VALUE;
+	ew32(CTRL, reg);
 	e1e_flush();
 	udelay(10);
-	ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
-	ew32(CTRL, ctrl);
+	reg &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
+	ew32(CTRL, reg);
 }
 
 /**
@@ -3071,8 +3081,8 @@ static s32 e1000_get_bus_info_ich8lan(struct e1000_hw *hw)
 static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
-	u16 reg;
-	u32 ctrl, kab;
+	u16 kum_cfg;
+	u32 ctrl, reg;
 	s32 ret_val;
 
 	/*
@@ -3106,12 +3116,12 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	}
 
 	if (hw->mac.type == e1000_pchlan) {
-		/* Save the NVM K1 bit setting*/
-		ret_val = e1000_read_nvm(hw, E1000_NVM_K1_CONFIG, 1, &reg);
+		/* Save the NVM K1 bit setting */
+		ret_val = e1000_read_nvm(hw, E1000_NVM_K1_CONFIG, 1, &kum_cfg);
 		if (ret_val)
 			return ret_val;
 
-		if (reg & E1000_NVM_K1_ENABLE)
+		if (kum_cfg & E1000_NVM_K1_ENABLE)
 			dev_spec->nvm_k1_enabled = true;
 		else
 			dev_spec->nvm_k1_enabled = false;
@@ -3141,6 +3151,14 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	/* cannot issue a flush here because it hangs the hardware */
 	msleep(20);
 
+	/* Set Phy Config Counter to 50msec */
+	if (hw->mac.type == e1000_pch2lan) {
+		reg = er32(FEXTNVM3);
+		reg &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
+		reg |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
+		ew32(FEXTNVM3, reg);
+	}
+
 	if (!ret_val)
 		clear_bit(__E1000_ACCESS_SHARED_RESOURCE, &hw->adapter->state);
 
@@ -3165,9 +3183,9 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(IMC, 0xffffffff);
 	er32(ICR);
 
-	kab = er32(KABGTXD);
-	kab |= E1000_KABGTXD_BGSQLBIAS;
-	ew32(KABGTXD, kab);
+	reg = er32(KABGTXD);
+	reg |= E1000_KABGTXD_BGSQLBIAS;
+	ew32(KABGTXD, reg);
 
 	return 0;
 }
-- 
1.7.7.6
