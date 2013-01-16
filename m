From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] e1000e: helper functions for accessing EMI registers
Date: Wed, 16 Jan 2013 01:10:16 -0800
Message-ID: <1358327427-3146-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50334 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab3APJKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:10:40 -0500
In-Reply-To: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The Extended Management Interface (EMI) registers are accessed by first
writing the EMI register offset to the EMI_ADDR regiter and then either
reading or writing the data to/from the EMI_DATA register.  Add helper
functions for performing these steps and convert existing EMI register
accesses accordingly.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 84 ++++++++++++++++++++++-------
 1 file changed, 65 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 7d5f6b7..8004d71 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -153,7 +153,7 @@
 #define I82579_LPI_CTRL_ENABLE_MASK		0x6000
 #define I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT	0x80
 
-/* EMI Registers */
+/* Extended Management Interface (EMI) Registers */
 #define I82579_EMI_ADDR         0x10
 #define I82579_EMI_DATA         0x11
 #define I82579_LPI_UPDATE_TIMER 0x4805	/* in 40ns units + 40 ns base value */
@@ -789,6 +789,58 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  __e1000_access_emi_reg_locked - Read/write EMI register
+ *  @hw: pointer to the HW structure
+ *  @addr: EMI address to program
+ *  @data: pointer to value to read/write from/to the EMI address
+ *  @read: boolean flag to indicate read or write
+ *
+ *  This helper function assumes the SW/FW/HW Semaphore is already acquired.
+ **/
+static s32 __e1000_access_emi_reg_locked(struct e1000_hw *hw, u16 address,
+					 u16 *data, bool read)
+{
+	s32 ret_val = 0;
+
+	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, address);
+	if (ret_val)
+		return ret_val;
+
+	if (read)
+		ret_val = e1e_rphy_locked(hw, I82579_EMI_DATA, data);
+	else
+		ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, *data);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_read_emi_reg_locked - Read Extended Management Interface register
+ *  @hw: pointer to the HW structure
+ *  @addr: EMI address to program
+ *  @data: value to be read from the EMI address
+ *
+ *  Assumes the SW/FW/HW Semaphore is already acquired.
+ **/
+static s32 e1000_read_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 *data)
+{
+	return __e1000_access_emi_reg_locked(hw, addr, data, true);
+}
+
+/**
+ *  e1000_write_emi_reg_locked - Write Extended Management Interface register
+ *  @hw: pointer to the HW structure
+ *  @addr: EMI address to program
+ *  @data: value to be written to the EMI address
+ *
+ *  Assumes the SW/FW/HW Semaphore is already acquired.
+ **/
+static s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data)
+{
+	return __e1000_access_emi_reg_locked(hw, addr, &data, false);
+}
+
+/**
  *  e1000_set_eee_pchlan - Enable/disable EEE support
  *  @hw: pointer to the HW structure
  *
@@ -823,11 +875,11 @@ static s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
-		ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR,
-					  I217_EEE_LP_ABILITY);
+		ret_val = e1000_read_emi_reg_locked(hw,
+						    I217_EEE_LP_ABILITY,
+						    &dev_spec->eee_lp_ability);
 		if (ret_val)
 			goto release;
-		e1e_rphy_locked(hw, I82579_EMI_DATA, &dev_spec->eee_lp_ability);
 
 		/* EEE is not supported in 100Half, so ignore partner's EEE
 		 * in 100 ability if full-duplex is not advertised.
@@ -1987,18 +2039,12 @@ static s32 e1000_lv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, I82579_MSE_THRESHOLD);
-	if (ret_val)
-		goto release;
 	/* set MSE higher to enable link to stay up when noise is high */
-	ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x0034);
-	if (ret_val)
-		goto release;
-	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, I82579_MSE_LINK_DOWN);
+	ret_val = e1000_write_emi_reg_locked(hw, I82579_MSE_THRESHOLD, 0x0034);
 	if (ret_val)
 		goto release;
 	/* drop link after 5 times MSE threshold was reached */
-	ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x0005);
+	ret_val = e1000_write_emi_reg_locked(hw, I82579_MSE_LINK_DOWN, 0x0005);
 release:
 	hw->phy.ops.release(hw);
 
@@ -2172,10 +2218,9 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
-		ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR,
-					  I82579_LPI_UPDATE_TIMER);
-		if (!ret_val)
-			ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x1387);
+		ret_val = e1000_write_emi_reg_locked(hw,
+						     I82579_LPI_UPDATE_TIMER,
+						     0x1387);
 		hw->phy.ops.release(hw);
 	}
 
@@ -4013,11 +4058,12 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 		if (!dev_spec->eee_disable) {
 			u16 eee_advert;
 
-			ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR,
-						  I217_EEE_ADVERTISEMENT);
+			ret_val =
+			    e1000_read_emi_reg_locked(hw,
+						      I217_EEE_ADVERTISEMENT,
+						      &eee_advert);
 			if (ret_val)
 				goto release;
-			e1e_rphy_locked(hw, I82579_EMI_DATA, &eee_advert);
 
 			/* Disable LPLU if both link partners support 100BaseT
 			 * EEE and 100Full is advertised on both ends of the
-- 
1.7.11.7
