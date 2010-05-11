From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/12] e1000e: Cleanup
	e1000_sw_lcd_config_ich8lan()
Date: Mon, 10 May 2010 18:01:10 -0700
Message-ID: <20100511010108.30827.47964.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:43958
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757406Ab0EKBB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:01:29 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

After every reset all ICH/PCH parts call this function which acquires the
swflag, performs a workaround on applicable parts and releases the swflag.
There is no reason for parts for which this workaround is not applicable
to acquire and release the swflag so the function should just return
without doing anything for these parts.  This also provides for the
indentation of most of the function contents to be shifted left cleaning up
the code.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |  152 +++++++++++++++++++++---------------------
 1 files changed, 75 insertions(+), 77 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 448e123..61f8927 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -815,11 +815,16 @@ static s32 e1000_check_reset_block_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 {
+	struct e1000_adapter *adapter = hw->adapter;
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 i, data, cnf_size, cnf_base_addr, sw_cfg_mask;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 word_addr, reg_data, reg_addr, phy_page = 0;
 
+	if (!(hw->mac.type == e1000_ich8lan && phy->type == e1000_phy_igp_3) &&
+		!(hw->mac.type == e1000_pchlan))
+		return ret_val;
+
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
@@ -831,97 +836,90 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	 * Therefore, after each PHY reset, we will load the
 	 * configuration data out of the NVM manually.
 	 */
-	if ((hw->mac.type == e1000_ich8lan && phy->type == e1000_phy_igp_3) ||
-		(hw->mac.type == e1000_pchlan)) {
-		struct e1000_adapter *adapter = hw->adapter;
-
-		/* Check if SW needs to configure the PHY */
-		if ((adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M_AMT) ||
-		    (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M) ||
-		    (hw->mac.type == e1000_pchlan))
-			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
-		else
-			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
+	if ((adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M_AMT) ||
+	    (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M) ||
+	    (hw->mac.type == e1000_pchlan))
+		sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
+	else
+		sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
 
-		data = er32(FEXTNVM);
-		if (!(data & sw_cfg_mask))
-			goto out;
+	data = er32(FEXTNVM);
+	if (!(data & sw_cfg_mask))
+		goto out;
 
-		/* Wait for basic configuration completes before proceeding */
-		e1000_lan_init_done_ich8lan(hw);
+	/* Wait for basic configuration completes before proceeding */
+	e1000_lan_init_done_ich8lan(hw);
 
+	/*
+	 * Make sure HW does not configure LCD from PHY
+	 * extended configuration before SW configuration
+	 */
+	data = er32(EXTCNF_CTRL);
+	if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
+		goto out;
+
+	cnf_size = er32(EXTCNF_SIZE);
+	cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
+	cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
+	if (!cnf_size)
+		goto out;
+
+	cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
+	cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
+
+	if (!(data & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE) &&
+	    (hw->mac.type == e1000_pchlan)) {
 		/*
-		 * Make sure HW does not configure LCD from PHY
-		 * extended configuration before SW configuration
+		 * HW configures the SMBus address and LEDs when the
+		 * OEM and LCD Write Enable bits are set in the NVM.
+		 * When both NVM bits are cleared, SW will configure
+		 * them instead.
 		 */
-		data = er32(EXTCNF_CTRL);
-		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
+		data = er32(STRAP);
+		data &= E1000_STRAP_SMBUS_ADDRESS_MASK;
+		reg_data = data >> E1000_STRAP_SMBUS_ADDRESS_SHIFT;
+		reg_data |= HV_SMB_ADDR_PEC_EN | HV_SMB_ADDR_VALID;
+		ret_val = e1000_write_phy_reg_hv_locked(hw, HV_SMB_ADDR,
+							reg_data);
+		if (ret_val)
 			goto out;
 
-		cnf_size = er32(EXTCNF_SIZE);
-		cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
-		cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
-		if (!cnf_size)
+		data = er32(LEDCTL);
+		ret_val = e1000_write_phy_reg_hv_locked(hw, HV_LED_CONFIG,
+							(u16)data);
+		if (ret_val)
 			goto out;
+	}
 
-		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
-		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
-
-		if (!(data & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE) &&
-		    (hw->mac.type == e1000_pchlan)) {
-			/*
-			 * HW configures the SMBus address and LEDs when the
-			 * OEM and LCD Write Enable bits are set in the NVM.
-			 * When both NVM bits are cleared, SW will configure
-			 * them instead.
-			 */
-			data = er32(STRAP);
-			data &= E1000_STRAP_SMBUS_ADDRESS_MASK;
-			reg_data = data >> E1000_STRAP_SMBUS_ADDRESS_SHIFT;
-			reg_data |= HV_SMB_ADDR_PEC_EN | HV_SMB_ADDR_VALID;
-			ret_val = e1000_write_phy_reg_hv_locked(hw, HV_SMB_ADDR,
-			                                        reg_data);
-			if (ret_val)
-				goto out;
-
-			data = er32(LEDCTL);
-			ret_val = e1000_write_phy_reg_hv_locked(hw,
-			                                        HV_LED_CONFIG,
-			                                        (u16)data);
-			if (ret_val)
-				goto out;
-		}
-		/* Configure LCD from extended configuration region. */
+	/* Configure LCD from extended configuration region. */
 
-		/* cnf_base_addr is in DWORD */
-		word_addr = (u16)(cnf_base_addr << 1);
+	/* cnf_base_addr is in DWORD */
+	word_addr = (u16)(cnf_base_addr << 1);
 
-		for (i = 0; i < cnf_size; i++) {
-			ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1,
-			                           &reg_data);
-			if (ret_val)
-				goto out;
+	for (i = 0; i < cnf_size; i++) {
+		ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1,
+					 &reg_data);
+		if (ret_val)
+			goto out;
 
-			ret_val = e1000_read_nvm(hw, (word_addr + i * 2 + 1),
-			                           1, &reg_addr);
-			if (ret_val)
-				goto out;
+		ret_val = e1000_read_nvm(hw, (word_addr + i * 2 + 1),
+					 1, &reg_addr);
+		if (ret_val)
+			goto out;
 
-			/* Save off the PHY page for future writes. */
-			if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
-				phy_page = reg_data;
-				continue;
-			}
+		/* Save off the PHY page for future writes. */
+		if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
+			phy_page = reg_data;
+			continue;
+		}
 
-			reg_addr &= PHY_REG_MASK;
-			reg_addr |= phy_page;
+		reg_addr &= PHY_REG_MASK;
+		reg_addr |= phy_page;
 
-			ret_val = phy->ops.write_reg_locked(hw,
-			                                    (u32)reg_addr,
-			                                    reg_data);
-			if (ret_val)
-				goto out;
-		}
+		ret_val = phy->ops.write_reg_locked(hw, (u32)reg_addr,
+						    reg_data);
+		if (ret_val)
+			goto out;
 	}
 
 out:

