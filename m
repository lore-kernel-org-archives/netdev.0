From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] igb: Enable EEE LP advertisement
Date: Thu,  4 Apr 2013 04:38:00 -0700
Message-ID: <1365075480-20183-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758781Ab3DDLiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:24 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

On EEE-capable devices, query the PHY to determine what the link partner is
advertising.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 35 ++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  1 +
 drivers/net/ethernet/intel/igb/e1000_defines.h |  4 ++
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 65 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.h    |  4 ++
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  4 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 30 +++++++++++-
 7 files changed, 142 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 9d83058..8ff938d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2285,6 +2285,41 @@ out:
 }
 
 /**
+ *  __igb_access_emi_reg - Read/write EMI register
+ *  @hw: pointer to the HW structure
+ *  @addr: EMI address to program
+ *  @data: pointer to value to read/write from/to the EMI address
+ *  @read: boolean flag to indicate read or write
+ **/
+static s32 __igb_access_emi_reg(struct e1000_hw *hw, u16 address,
+				  u16 *data, bool read)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	ret_val = hw->phy.ops.write_reg(hw, E1000_EMIADD, address);
+	if (ret_val)
+		return ret_val;
+
+	if (read)
+		ret_val = hw->phy.ops.read_reg(hw, E1000_EMIDATA, data);
+	else
+		ret_val = hw->phy.ops.write_reg(hw, E1000_EMIDATA, *data);
+
+	return ret_val;
+}
+
+/**
+ *  igb_read_emi_reg - Read Extended Management Interface register
+ *  @hw: pointer to the HW structure
+ *  @addr: EMI address to program
+ *  @data: value to be read from the EMI address
+ **/
+s32 igb_read_emi_reg(struct e1000_hw *hw, u16 addr, u16 *data)
+{
+	return __igb_access_emi_reg(hw, addr, data, true);
+}
+
+/**
  *  igb_set_eee_i350 - Enable/disable EEE support
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 73ab41f..0d318ac 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -263,6 +263,7 @@ void igb_vmdq_set_anti_spoofing_pf(struct e1000_hw *, bool, int);
 void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
 void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 u16 igb_rxpbs_adjust_82580(u32 data);
+s32 igb_read_emi_reg(struct e1000_hw *, u16 addr, u16 *data);
 s32 igb_set_eee_i350(struct e1000_hw *);
 s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *);
 s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 66a1df9..f3d87d7 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -885,6 +885,10 @@
 #define E1000_EEER_LPI_FC            0x00040000  /* EEE Enable on FC */
 #define E1000_EEE_SU_LPI_CLK_STP     0X00800000  /* EEE LPI Clock Stop */
 #define E1000_EEER_EEE_NEG           0x20000000  /* EEE capability nego */
+#define E1000_EEE_LP_ADV_ADDR_I350   0x040F      /* EEE LP Advertisement */
+#define E1000_EEE_LP_ADV_DEV_I210    7           /* EEE LP Adv Device */
+#define E1000_EEE_LP_ADV_ADDR_I210   61          /* EEE LP Adv Register */
+#define E1000_MMDAC_FUNC_DATA        0x4000      /* Data, no post increment */
 
 /* SerDes Control */
 #define E1000_GEN_CTL_READY             0x80000000
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 7df442a..9764cd3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -708,3 +708,68 @@ s32 igb_valid_led_default_i210(struct e1000_hw *hw, u16 *data)
 out:
 	return ret_val;
 }
+
+/**
+ *  __igb_access_xmdio_reg - Read/write XMDIO register
+ *  @hw: pointer to the HW structure
+ *  @address: XMDIO address to program
+ *  @dev_addr: device address to program
+ *  @data: pointer to value to read/write from/to the XMDIO address
+ *  @read: boolean flag to indicate read or write
+ **/
+static s32 __igb_access_xmdio_reg(struct e1000_hw *hw, u16 address,
+				  u8 dev_addr, u16 *data, bool read)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	ret_val = hw->phy.ops.write_reg(hw, E1000_MMDAC, dev_addr);
+	if (ret_val)
+		return ret_val;
+
+	ret_val = hw->phy.ops.write_reg(hw, E1000_MMDAAD, address);
+	if (ret_val)
+		return ret_val;
+
+	ret_val = hw->phy.ops.write_reg(hw, E1000_MMDAC, E1000_MMDAC_FUNC_DATA |
+							 dev_addr);
+	if (ret_val)
+		return ret_val;
+
+	if (read)
+		ret_val = hw->phy.ops.read_reg(hw, E1000_MMDAAD, data);
+	else
+		ret_val = hw->phy.ops.write_reg(hw, E1000_MMDAAD, *data);
+	if (ret_val)
+		return ret_val;
+
+	/* Recalibrate the device back to 0 */
+	ret_val = hw->phy.ops.write_reg(hw, E1000_MMDAC, 0);
+	if (ret_val)
+		return ret_val;
+
+	return ret_val;
+}
+
+/**
+ *  igb_read_xmdio_reg - Read XMDIO register
+ *  @hw: pointer to the HW structure
+ *  @addr: XMDIO address to program
+ *  @dev_addr: device address to program
+ *  @data: value to be read from the EMI address
+ **/
+s32 igb_read_xmdio_reg(struct e1000_hw *hw, u16 addr, u8 dev_addr, u16 *data)
+{
+	return __igb_access_xmdio_reg(hw, addr, dev_addr, data, true);
+}
+
+/**
+ *  igb_write_xmdio_reg - Write XMDIO register
+ *  @hw: pointer to the HW structure
+ *  @addr: XMDIO address to program
+ *  @dev_addr: device address to program
+ *  @data: value to be written to the XMDIO address
+ **/
+s32 igb_write_xmdio_reg(struct e1000_hw *hw, u16 addr, u8 dev_addr, u16 data)
+{
+	return __igb_access_xmdio_reg(hw, addr, dev_addr, &data, false);
+}
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index e4e1a73..bfc08e0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -45,6 +45,10 @@ extern s32 igb_read_nvm_i211(struct e1000_hw *hw, u16 offset, u16 words,
 			       u16 *data);
 extern s32 igb_read_invm_version(struct e1000_hw *hw,
 				 struct e1000_fw_version *invm_ver);
+extern s32 igb_read_xmdio_reg(struct e1000_hw *hw, u16 addr, u8 dev_addr,
+			      u16 *data);
+extern s32 igb_write_xmdio_reg(struct e1000_hw *hw, u16 addr, u8 dev_addr,
+			       u16 data);
 
 #define E1000_STM_OPCODE		0xDB00
 #define E1000_EEPROM_FLASH_SIZE_WORD	0x11
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 971b638..bdfc040 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -365,6 +365,10 @@
 #define E1000_IPCNFG	0x0E38 /* Internal PHY Configuration */
 #define E1000_EEER	0x0E30 /* Energy Efficient Ethernet */
 #define E1000_EEE_SU	0X0E34 /* EEE Setup */
+#define E1000_EMIADD	0x10   /* Extended Memory Indirect Address */
+#define E1000_EMIDATA	0x11   /* Extended Memory Indirect Data */
+#define E1000_MMDAC	13     /* MMD Access Control */
+#define E1000_MMDAAD	14     /* MMD Access Address/Data */
 
 /* Thermal Sensor Register */
 #define E1000_THSTAT	0x08110 /* Thermal Sensor Status */
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 0409274..97ee34e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/pm_runtime.h>
 #include <linux/highmem.h>
+#include <linux/mdio.h>
 
 #include "igb.h"
 
@@ -2533,7 +2534,8 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 ipcnfg, eeer;
+	u32 ipcnfg, eeer, ret_val;
+	u16 phy_data;
 
 	if ((hw->mac.type < e1000_i350) ||
 	    (hw->phy.media_type != e1000_media_type_copper))
@@ -2552,6 +2554,32 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 	if (ipcnfg & E1000_IPCNFG_EEE_100M_AN)
 		edata->advertised |= ADVERTISED_100baseT_Full;
 
+	/* EEE Link Partner Advertised */
+	switch (hw->mac.type) {
+	case e1000_i350:
+		ret_val = igb_read_emi_reg(hw, E1000_EEE_LP_ADV_ADDR_I350,
+					   &phy_data);
+		if (ret_val)
+			return -ENODATA;
+
+		edata->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(phy_data);
+
+		break;
+	case e1000_i210:
+	case e1000_i211:
+		ret_val = igb_read_xmdio_reg(hw, E1000_EEE_LP_ADV_ADDR_I210,
+					     E1000_EEE_LP_ADV_DEV_I210,
+					     &phy_data);
+		if (ret_val)
+			return -ENODATA;
+
+		edata->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(phy_data);
+
+		break;
+	default:
+		break;
+	}
+
 	if (eeer & E1000_EEER_EEE_NEG)
 		edata->eee_active = true;
 
-- 
1.7.11.7
