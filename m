From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: config PHY via software after resets
Date: Thu, 29 Oct 2009 16:45:45 -0700
Message-ID: <20091029234545.5413.9667.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:54729
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752960AbZJ2Xp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 19:45:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On PCH-based (82577/82578) and some ICH8-based parts (82566) there is an
issue with the hardware automatically configuring the PHY with contents
from the EEPROM after the PHY is reset, so do the configuration by the
driver instead.  This was already similarly done for some 82566 parts in
e1000_phy_hw_reset_ich8lan() but needs to be done after other resets,
so move the PHY configuration code to its own function and call after
all PHY resets.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/ich8lan.c |  295 +++++++++++++++++++++++++++++++-----------
 2 files changed, 218 insertions(+), 78 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index c0f185b..4741ef9 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -347,6 +347,7 @@
 /* Extended Configuration Control and Size */
 #define E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP      0x00000020
 #define E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE       0x00000001
+#define E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE       0x00000008
 #define E1000_EXTCNF_CTRL_SWFLAG                 0x00000020
 #define E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK   0x00FF0000
 #define E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT          16
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b6388b9..095ffa5 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -124,9 +124,20 @@
 
 #define SW_FLAG_TIMEOUT    1000 /* SW Semaphore flag timeout in milliseconds */
 
+/* SMBus Address Phy Register */
+#define HV_SMB_ADDR            PHY_REG(768, 26)
+#define HV_SMB_ADDR_PEC_EN     0x0200
+#define HV_SMB_ADDR_VALID      0x0080
+
+/* Strapping Option Register - RO */
+#define E1000_STRAP                     0x0000C
+#define E1000_STRAP_SMBUS_ADDRESS_MASK  0x00FE0000
+#define E1000_STRAP_SMBUS_ADDRESS_SHIFT 17
+
 /* OEM Bits Phy Register */
 #define HV_OEM_BITS            PHY_REG(768, 25)
 #define HV_OEM_BITS_LPLU       0x0004 /* Low Power Link Up */
+#define HV_OEM_BITS_GBE_DIS    0x0040 /* Gigabit Disable */
 #define HV_OEM_BITS_RESTART_AN 0x0400 /* Restart Auto-negotiation */
 
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
@@ -208,6 +219,7 @@ static s32 e1000_cleanup_led_pchlan(struct e1000_hw *hw);
 static s32 e1000_led_on_pchlan(struct e1000_hw *hw);
 static s32 e1000_led_off_pchlan(struct e1000_hw *hw);
 static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active);
+static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -794,6 +806,191 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_sw_lcd_config_ich8lan - SW-based LCD Configuration
+ *  @hw:   pointer to the HW structure
+ *
+ *  SW should configure the LCD from the NVM extended configuration region
+ *  as a workaround for certain parts.
+ **/
+static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	u32 i, data, cnf_size, cnf_base_addr, sw_cfg_mask;
+	s32 ret_val;
+	u16 word_addr, reg_data, reg_addr, phy_page = 0;
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
+	/*
+	 * Initialize the PHY from the NVM on ICH platforms.  This
+	 * is needed due to an issue where the NVM configuration is
+	 * not properly autoloaded after power transitions.
+	 * Therefore, after each PHY reset, we will load the
+	 * configuration data out of the NVM manually.
+	 */
+	if ((hw->mac.type == e1000_ich8lan && phy->type == e1000_phy_igp_3) ||
+		(hw->mac.type == e1000_pchlan)) {
+		struct e1000_adapter *adapter = hw->adapter;
+
+		/* Check if SW needs to configure the PHY */
+		if ((adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M_AMT) ||
+		    (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M) ||
+		    (hw->mac.type == e1000_pchlan))
+			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
+		else
+			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
+
+		data = er32(FEXTNVM);
+		if (!(data & sw_cfg_mask))
+			goto out;
+
+		/* Wait for basic configuration completes before proceeding */
+		e1000_lan_init_done_ich8lan(hw);
+
+		/*
+		 * Make sure HW does not configure LCD from PHY
+		 * extended configuration before SW configuration
+		 */
+		data = er32(EXTCNF_CTRL);
+		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
+			goto out;
+
+		cnf_size = er32(EXTCNF_SIZE);
+		cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
+		cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
+		if (!cnf_size)
+			goto out;
+
+		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
+		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
+
+		if (!(data & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE) &&
+		    (hw->mac.type == e1000_pchlan)) {
+			/*
+			 * HW configures the SMBus address and LEDs when the
+			 * OEM and LCD Write Enable bits are set in the NVM.
+			 * When both NVM bits are cleared, SW will configure
+			 * them instead.
+			 */
+			data = er32(STRAP);
+			data &= E1000_STRAP_SMBUS_ADDRESS_MASK;
+			reg_data = data >> E1000_STRAP_SMBUS_ADDRESS_SHIFT;
+			reg_data |= HV_SMB_ADDR_PEC_EN | HV_SMB_ADDR_VALID;
+			ret_val = e1000_write_phy_reg_hv_locked(hw, HV_SMB_ADDR,
+			                                        reg_data);
+			if (ret_val)
+				goto out;
+
+			data = er32(LEDCTL);
+			ret_val = e1000_write_phy_reg_hv_locked(hw,
+			                                        HV_LED_CONFIG,
+			                                        (u16)data);
+			if (ret_val)
+				goto out;
+		}
+		/* Configure LCD from extended configuration region. */
+
+		/* cnf_base_addr is in DWORD */
+		word_addr = (u16)(cnf_base_addr << 1);
+
+		for (i = 0; i < cnf_size; i++) {
+			ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1,
+			                           &reg_data);
+			if (ret_val)
+				goto out;
+
+			ret_val = e1000_read_nvm(hw, (word_addr + i * 2 + 1),
+			                           1, &reg_addr);
+			if (ret_val)
+				goto out;
+
+			/* Save off the PHY page for future writes. */
+			if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
+				phy_page = reg_data;
+				continue;
+			}
+
+			reg_addr &= PHY_REG_MASK;
+			reg_addr |= phy_page;
+
+			ret_val = phy->ops.write_phy_reg_locked(hw,
+			                                    (u32)reg_addr,
+			                                    reg_data);
+			if (ret_val)
+				goto out;
+		}
+	}
+
+out:
+	hw->phy.ops.release_phy(hw);
+	return ret_val;
+}
+
+/**
+ *  e1000_oem_bits_config_ich8lan - SW-based LCD Configuration
+ *  @hw:       pointer to the HW structure
+ *  @d0_state: boolean if entering d0 or d3 device state
+ *
+ *  SW will configure Gbe Disable and LPLU based on the NVM. The four bits are
+ *  collectively called OEM bits.  The OEM Write Enable bit and SW Config bit
+ *  in NVM determines whether HW should configure LPLU and Gbe Disable.
+ **/
+static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
+{
+	s32 ret_val = 0;
+	u32 mac_reg;
+	u16 oem_reg;
+
+	if (hw->mac.type != e1000_pchlan)
+		return ret_val;
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
+	mac_reg = er32(EXTCNF_CTRL);
+	if (mac_reg & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE)
+		goto out;
+
+	mac_reg = er32(FEXTNVM);
+	if (!(mac_reg & E1000_FEXTNVM_SW_CONFIG_ICH8M))
+		goto out;
+
+	mac_reg = er32(PHY_CTRL);
+
+	ret_val = hw->phy.ops.read_phy_reg_locked(hw, HV_OEM_BITS, &oem_reg);
+	if (ret_val)
+		goto out;
+
+	oem_reg &= ~(HV_OEM_BITS_GBE_DIS | HV_OEM_BITS_LPLU);
+
+	if (d0_state) {
+		if (mac_reg & E1000_PHY_CTRL_GBE_DISABLE)
+			oem_reg |= HV_OEM_BITS_GBE_DIS;
+
+		if (mac_reg & E1000_PHY_CTRL_D0A_LPLU)
+			oem_reg |= HV_OEM_BITS_LPLU;
+	} else {
+		if (mac_reg & E1000_PHY_CTRL_NOND0A_GBE_DISABLE)
+			oem_reg |= HV_OEM_BITS_GBE_DIS;
+
+		if (mac_reg & E1000_PHY_CTRL_NOND0A_LPLU)
+			oem_reg |= HV_OEM_BITS_LPLU;
+	}
+	/* Restart auto-neg to activate the bits */
+	oem_reg |= HV_OEM_BITS_RESTART_AN;
+	ret_val = hw->phy.ops.write_phy_reg_locked(hw, HV_OEM_BITS, oem_reg);
+
+out:
+	hw->phy.ops.release_phy(hw);
+
+	return ret_val;
+}
+
+
+/**
  *  e1000_hv_phy_workarounds_ich8lan - A series of Phy workarounds to be
  *  done after every PHY reset.
  **/
@@ -882,11 +1079,8 @@ static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 {
-	struct e1000_phy_info *phy = &hw->phy;
-	u32 i;
-	u32 data, cnf_size, cnf_base_addr, sw_cfg_mask;
-	s32 ret_val;
-	u16 reg, word_addr, reg_data, reg_addr, phy_page = 0;
+	s32 ret_val = 0;
+	u16 reg;
 
 	ret_val = e1000e_phy_hw_reset_generic(hw);
 	if (ret_val)
@@ -905,81 +1099,16 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	if (hw->mac.type == e1000_pchlan)
 		e1e_rphy(hw, BM_WUC, &reg);
 
-	/*
-	 * Initialize the PHY from the NVM on ICH platforms.  This
-	 * is needed due to an issue where the NVM configuration is
-	 * not properly autoloaded after power transitions.
-	 * Therefore, after each PHY reset, we will load the
-	 * configuration data out of the NVM manually.
-	 */
-	if (hw->mac.type == e1000_ich8lan && phy->type == e1000_phy_igp_3) {
-		struct e1000_adapter *adapter = hw->adapter;
-
-		/* Check if SW needs configure the PHY */
-		if ((adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M_AMT) ||
-		    (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M))
-			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
-		else
-			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
-
-		data = er32(FEXTNVM);
-		if (!(data & sw_cfg_mask))
-			return 0;
-
-		/* Wait for basic configuration completes before proceeding */
-		e1000_lan_init_done_ich8lan(hw);
-
-		/*
-		 * Make sure HW does not configure LCD from PHY
-		 * extended configuration before SW configuration
-		 */
-		data = er32(EXTCNF_CTRL);
-		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
-			return 0;
-
-		cnf_size = er32(EXTCNF_SIZE);
-		cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
-		cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
-		if (!cnf_size)
-			return 0;
-
-		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
-		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
-
-		/* Configure LCD from extended configuration region. */
-
-		/* cnf_base_addr is in DWORD */
-		word_addr = (u16)(cnf_base_addr << 1);
-
-		for (i = 0; i < cnf_size; i++) {
-			ret_val = e1000_read_nvm(hw,
-						(word_addr + i * 2),
-						1,
-						&reg_data);
-			if (ret_val)
-				return ret_val;
-
-			ret_val = e1000_read_nvm(hw,
-						(word_addr + i * 2 + 1),
-						1,
-						&reg_addr);
-			if (ret_val)
-				return ret_val;
-
-			/* Save off the PHY page for future writes. */
-			if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
-				phy_page = reg_data;
-				continue;
-			}
-
-			reg_addr |= phy_page;
+	/* Configure the LCD with the extended configuration region in NVM */
+	ret_val = e1000_sw_lcd_config_ich8lan(hw);
+	if (ret_val)
+		goto out;
 
-			ret_val = e1e_wphy(hw, (u32)reg_addr, reg_data);
-			if (ret_val)
-				return ret_val;
-		}
-	}
+	/* Configure the LCD with the OEM bits in NVM */
+	if (hw->mac.type == e1000_pchlan)
+		ret_val = e1000_oem_bits_config_ich8lan(hw, true);
 
+out:
 	return 0;
 }
 
@@ -2386,6 +2515,15 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	if (hw->mac.type == e1000_pchlan)
 		e1e_rphy(hw, BM_WUC, &reg);
 
+	ret_val = e1000_sw_lcd_config_ich8lan(hw);
+	if (ret_val)
+		goto out;
+
+	if (hw->mac.type == e1000_pchlan) {
+		ret_val = e1000_oem_bits_config_ich8lan(hw, true);
+		if (ret_val)
+			goto out;
+	}
 	/*
 	 * For PCH, this write will make sure that any noise
 	 * will be detected as a CRC error and be dropped rather than show up
@@ -2404,6 +2542,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	if (hw->mac.type == e1000_pchlan)
 		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
 
+out:
 	return ret_val;
 }
 

