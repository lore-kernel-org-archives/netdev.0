From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 2/5] e1000e: workaround EEPROM configuration change on 82579 on kernel 2.6.x
Date: Tue, 16 Dec 2014 18:28:17 +0800
Message-ID: <1418725700-31465-3-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:40027 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaLPK2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:28:44 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so13636317pdi.31
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:28:43 -0800 (PST)
In-Reply-To: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit 62bc813 
[e1000e: workaround EEPROM configuration change on 82579] introduces
for newer kernels.

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

[e1000_toggle_lanphypc_value_ich8lan does not exist. Its implementations
exist in e1000_init_phy_params_pchlan. Renamed variables remain unchanged]

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/e1000e/hw.h      |  1 +
 drivers/net/e1000e/ich8lan.c | 17 +++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 11f3b7c..b055d78 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -60,6 +60,7 @@ enum e1e_registers {
 	E1000_FEXTNVM  = 0x00028, /* Future Extended NVM - RW */
 	E1000_FCT      = 0x00030, /* Flow Control Type - RW */
 	E1000_VET      = 0x00038, /* VLAN Ether Type - RW */
+	E1000_FEXTNVM3 = 0x0003C, /* Future Extended NVM 3 - RW */
 	E1000_ICR      = 0x000C0, /* Interrupt Cause Read - R/clr */
 	E1000_ITR      = 0x000C4, /* Interrupt Throttling Rate - RW */
 	E1000_ICS      = 0x000C8, /* Interrupt Cause Set - WO */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 020657c..c4b2d15 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -108,6 +108,9 @@
 #define E1000_FEXTNVM_SW_CONFIG		1
 #define E1000_FEXTNVM_SW_CONFIG_ICH8M (1 << 27) /* Bit redefined for ICH8M :/ */
 
+#define E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK    0x0C000000
+#define E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC  0x08000000
+
 #define PCIE_ICH8_SNOOP_ALL		PCIE_NO_SNOOP_ALL
 
 #define E1000_ICH_RAR_ENTRIES		7
@@ -278,6 +281,12 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
 	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+		/*Set Phy Config Counter to 50msec */
+		ctrl = er32(FEXTNVM3);
+		ctrl &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
+		ctrl |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
+		ew32(FEXTNVM3, ctrl);
+
 		/*
 		 * The MAC-PHY interconnect may still be in SMBus mode
 		 * after Sx->S0.  Toggle the LANPHYPC Value bit to force
@@ -2685,6 +2694,14 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
 	msleep(20);
 
+	/* Set Phy Config Counter to 50msec */
+	if (hw->mac.type == e1000_pch2lan) {
+		u32 phycc_reg = er32(FEXTNVM3);
+		phycc_reg &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
+		phycc_reg |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
+		ew32(FEXTNVM3, phycc_reg);
+	}
+
 	if (!ret_val)
 		e1000_release_swflag_ich8lan(hw);
 
-- 
1.9.1
