From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/19] i40e: Add functions which apply correct PHY access method for read and write operation
Date: Wed,  7 Dec 2016 14:19:10 -0800
Message-ID: <20161207221918.57932-12-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Michal Kosiarz <michal.kosiarz@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42627 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932824AbcLGWUS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:18 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kosiarz <michal.kosiarz@intel.com>

Depending on external PHY type, register access method should be
different. Clause22 or Clause45 can be chosen for different PHYs.
Implemented functions apply correct access method for used device.

Change-ID: If39d5f0da9c0b905a8cbdc1ab89885535e7d0426
Signed-off-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 72 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  4 ++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  4 ++
 3 files changed, 80 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index f8c4c14..1287359 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -4676,6 +4676,78 @@ i40e_status i40e_write_phy_register_clause45(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_write_phy_register
+ * @hw: pointer to the HW structure
+ * @page: registers page number
+ * @reg: register address in the page
+ * @phy_adr: PHY address on MDIO interface
+ * @value: PHY register value
+ *
+ * Writes value to specified PHY register
+ **/
+i40e_status i40e_write_phy_register(struct i40e_hw *hw,
+				    u8 page, u16 reg, u8 phy_addr, u16 value)
+{
+	i40e_status status;
+
+	switch (hw->device_id) {
+	case I40E_DEV_ID_1G_BASE_T_X722:
+		status = i40e_write_phy_register_clause22(hw, reg, phy_addr,
+							  value);
+		break;
+	case I40E_DEV_ID_10G_BASE_T:
+	case I40E_DEV_ID_10G_BASE_T4:
+	case I40E_DEV_ID_10G_BASE_T_X722:
+	case I40E_DEV_ID_25G_B:
+	case I40E_DEV_ID_25G_SFP28:
+		status = i40e_write_phy_register_clause45(hw, page, reg,
+							  phy_addr, value);
+		break;
+	default:
+		status = I40E_ERR_UNKNOWN_PHY;
+		break;
+	}
+
+	return status;
+}
+
+/**
+ * i40e_read_phy_register
+ * @hw: pointer to the HW structure
+ * @page: registers page number
+ * @reg: register address in the page
+ * @phy_adr: PHY address on MDIO interface
+ * @value: PHY register value
+ *
+ * Reads specified PHY register value
+ **/
+i40e_status i40e_read_phy_register(struct i40e_hw *hw,
+				   u8 page, u16 reg, u8 phy_addr, u16 *value)
+{
+	i40e_status status;
+
+	switch (hw->device_id) {
+	case I40E_DEV_ID_1G_BASE_T_X722:
+		status = i40e_read_phy_register_clause22(hw, reg, phy_addr,
+							 value);
+		break;
+	case I40E_DEV_ID_10G_BASE_T:
+	case I40E_DEV_ID_10G_BASE_T4:
+	case I40E_DEV_ID_10G_BASE_T_X722:
+	case I40E_DEV_ID_25G_B:
+	case I40E_DEV_ID_25G_SFP28:
+		status = i40e_read_phy_register_clause45(hw, page, reg,
+							 phy_addr, value);
+		break;
+	default:
+		status = I40E_ERR_UNKNOWN_PHY;
+		break;
+	}
+
+	return status;
+}
+
+/**
  * i40e_get_phy_address
  * @hw: pointer to the HW structure
  * @dev_num: PHY port num that address we want
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 37d67e7..2551fc8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -373,6 +373,10 @@ i40e_status i40e_read_phy_register_clause45(struct i40e_hw *hw,
 				u8 page, u16 reg, u8 phy_addr, u16 *value);
 i40e_status i40e_write_phy_register_clause45(struct i40e_hw *hw,
 				u8 page, u16 reg, u8 phy_addr, u16 value);
+i40e_status i40e_read_phy_register(struct i40e_hw *hw, u8 page, u16 reg,
+				   u8 phy_addr, u16 *value);
+i40e_status i40e_write_phy_register(struct i40e_hw *hw, u8 page, u16 reg,
+				    u8 phy_addr, u16 value);
 u8 i40e_get_phy_address(struct i40e_hw *hw, u8 dev_num);
 i40e_status i40e_blink_phy_link_led(struct i40e_hw *hw,
 				    u32 time, u32 interval);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index d89d521..ba6c6bd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -115,6 +115,10 @@ i40e_status i40e_read_phy_register(struct i40e_hw *hw, u8 page,
 				   u16 reg, u8 phy_addr, u16 *value);
 i40e_status i40e_write_phy_register(struct i40e_hw *hw, u8 page,
 				    u16 reg, u8 phy_addr, u16 value);
+i40e_status i40e_read_phy_register(struct i40e_hw *hw, u8 page, u16 reg,
+				   u8 phy_addr, u16 *value);
+i40e_status i40e_write_phy_register(struct i40e_hw *hw, u8 page, u16 reg,
+				    u8 phy_addr, u16 value);
 u8 i40e_get_phy_address(struct i40e_hw *hw, u8 dev_num);
 i40e_status i40e_blink_phy_link_led(struct i40e_hw *hw,
 				    u32 time, u32 interval);
-- 
2.9.3
