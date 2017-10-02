From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: Add support for 'ethtool -m'
Date: Mon,  2 Oct 2017 12:48:42 -0700
Message-ID: <20171002194852.71970-6-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39749 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751102AbdJBTtS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:18 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

This patch adds support for 'ethtool -m' command which displays
information about (Q)SFP+ module plugged into NIC's cage.

Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  18 +++
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  69 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 154 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   9 ++
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  13 ++
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  18 +++
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  69 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   9 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  12 ++
 9 files changed, 371 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5d0291c1337e..ed7bbe14bc6e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -244,6 +244,8 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_set_phy_debug		= 0x0622,
 	i40e_aqc_opc_upload_ext_phy_fm		= 0x0625,
 	i40e_aqc_opc_run_phy_activity		= 0x0626,
+	i40e_aqc_opc_set_phy_register		= 0x0628,
+	i40e_aqc_opc_get_phy_register		= 0x0629,
 
 	/* NVM commands */
 	i40e_aqc_opc_nvm_read			= 0x0701,
@@ -2053,6 +2055,22 @@ struct i40e_aqc_run_phy_activity {
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_run_phy_activity);
 
+/* Set PHY Register command (0x0628) */
+/* Get PHY Register command (0x0629) */
+struct i40e_aqc_phy_register_access {
+	u8	phy_interface;
+#define I40E_AQ_PHY_REG_ACCESS_INTERNAL	0
+#define I40E_AQ_PHY_REG_ACCESS_EXTERNAL	1
+#define I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE	2
+	u8	dev_address;
+	u8	reserved1[2];
+	__le32	reg_address;
+	__le32	reg_value;
+	u8	reserved2[4];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_phy_register_access);
+
 /* NVM Read command (indirect 0x0701)
  * NVM Erase commands (direct 0x0702)
  * NVM Update commands (indirect 0x0703)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 64c15f4c9d2b..fada03799850 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -5062,6 +5062,75 @@ void i40e_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
 		wr32(hw, reg_addr, reg_val);
 }
 
+/**
+ * i40e_aq_set_phy_register
+ * @hw: pointer to the hw struct
+ * @phy_select: select which phy should be accessed
+ * @dev_addr: PHY device address
+ * @reg_addr: PHY register address
+ * @reg_val: new register value
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Write the external PHY register.
+ **/
+i40e_status i40e_aq_set_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 reg_val,
+				     struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_phy_register_access *cmd =
+		(struct i40e_aqc_phy_register_access *)&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_set_phy_register);
+
+	cmd->phy_interface = phy_select;
+	cmd->dev_address = dev_addr;
+	cmd->reg_address = cpu_to_le32(reg_addr);
+	cmd->reg_value = cpu_to_le32(reg_val);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
+ * i40e_aq_get_phy_register
+ * @hw: pointer to the hw struct
+ * @phy_select: select which phy should be accessed
+ * @dev_addr: PHY device address
+ * @reg_addr: PHY register address
+ * @reg_val: read register value
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Read the external PHY register.
+ **/
+i40e_status i40e_aq_get_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 *reg_val,
+				     struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_phy_register_access *cmd =
+		(struct i40e_aqc_phy_register_access *)&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_get_phy_register);
+
+	cmd->phy_interface = phy_select;
+	cmd->dev_address = dev_addr;
+	cmd->reg_address = cpu_to_le32(reg_addr);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+	if (!status)
+		*reg_val = le32_to_cpu(cmd->reg_value);
+
+	return status;
+}
+
 /**
  * i40e_aq_write_ppp - Write pipeline personalization profile (ppp)
  * @hw: pointer to the hw struct
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 05e89864f781..1136d02e2e95 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -4196,6 +4196,158 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	return 0;
 }
 
+/**
+ * i40e_get_module_info - get (Q)SFP+ module type info
+ * @netdev: network interface device structure
+ * @modinfo: module EEPROM size and layout information structure
+ **/
+static int i40e_get_module_info(struct net_device *netdev,
+				struct ethtool_modinfo *modinfo)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 sff8472_comp = 0;
+	u32 sff8472_swap = 0;
+	u32 sff8636_rev = 0;
+	i40e_status status;
+	u32 type = 0;
+
+	/* Check if firmware supports reading module EEPROM. */
+	if (!(hw->flags & I40E_HW_FLAG_AQ_PHY_ACCESS_CAPABLE)) {
+		netdev_err(vsi->netdev, "Module EEPROM memory read not supported. Please update the NVM image.\n");
+		return -EINVAL;
+	}
+
+	status = i40e_update_link_info(hw);
+	if (status)
+		return -EIO;
+
+	if (hw->phy.link_info.phy_type == I40E_PHY_TYPE_EMPTY) {
+		netdev_err(vsi->netdev, "Cannot read module EEPROM memory. No module connected.\n");
+		return -EINVAL;
+	}
+
+	type = hw->phy.link_info.module_type[0];
+
+	switch (type) {
+	case I40E_MODULE_TYPE_SFP:
+		status = i40e_aq_get_phy_register(hw,
+				I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE,
+				I40E_I2C_EEPROM_DEV_ADDR,
+				I40E_MODULE_SFF_8472_COMP,
+				&sff8472_comp, NULL);
+		if (status)
+			return -EIO;
+
+		status = i40e_aq_get_phy_register(hw,
+				I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE,
+				I40E_I2C_EEPROM_DEV_ADDR,
+				I40E_MODULE_SFF_8472_SWAP,
+				&sff8472_swap, NULL);
+		if (status)
+			return -EIO;
+
+		/* Check if the module requires address swap to access
+		 * the other EEPROM memory page.
+		 */
+		if (sff8472_swap & I40E_MODULE_SFF_ADDR_MODE) {
+			netdev_warn(vsi->netdev, "Module address swap to access page 0xA2 is not supported.\n");
+			modinfo->type = ETH_MODULE_SFF_8079;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+		} else if (sff8472_comp == 0x00) {
+			/* Module is not SFF-8472 compliant */
+			modinfo->type = ETH_MODULE_SFF_8079;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+		} else {
+			modinfo->type = ETH_MODULE_SFF_8472;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
+		}
+		break;
+	case I40E_MODULE_TYPE_QSFP_PLUS:
+		/* Read from memory page 0. */
+		status = i40e_aq_get_phy_register(hw,
+				I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE,
+				0,
+				I40E_MODULE_REVISION_ADDR,
+				&sff8636_rev, NULL);
+		if (status)
+			return -EIO;
+		/* Determine revision compliance byte */
+		if (sff8636_rev > 0x02) {
+			/* Module is SFF-8636 compliant */
+			modinfo->type = ETH_MODULE_SFF_8636;
+			modinfo->eeprom_len = I40E_MODULE_QSFP_MAX_LEN;
+		} else {
+			modinfo->type = ETH_MODULE_SFF_8436;
+			modinfo->eeprom_len = I40E_MODULE_QSFP_MAX_LEN;
+		}
+		break;
+	case I40E_MODULE_TYPE_QSFP28:
+		modinfo->type = ETH_MODULE_SFF_8636;
+		modinfo->eeprom_len = I40E_MODULE_QSFP_MAX_LEN;
+		break;
+	default:
+		netdev_err(vsi->netdev, "Module type unrecognized\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/**
+ * i40e_get_module_eeprom - fills buffer with (Q)SFP+ module memory contents
+ * @netdev: network interface device structure
+ * @ee: EEPROM dump request structure
+ * @data: buffer to be filled with EEPROM contents
+ **/
+static int i40e_get_module_eeprom(struct net_device *netdev,
+				  struct ethtool_eeprom *ee,
+				  u8 *data)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	bool is_sfp = false;
+	i40e_status status;
+	u32 value = 0;
+	int i;
+
+	if (!ee || !ee->len || !data)
+		return -EINVAL;
+
+	if (hw->phy.link_info.module_type[0] == I40E_MODULE_TYPE_SFP)
+		is_sfp = true;
+
+	for (i = 0; i < ee->len; i++) {
+		u32 offset = i + ee->offset;
+		u32 addr = is_sfp ? I40E_I2C_EEPROM_DEV_ADDR : 0;
+
+		/* Check if we need to access the other memory page */
+		if (is_sfp) {
+			if (offset >= ETH_MODULE_SFF_8079_LEN) {
+				offset -= ETH_MODULE_SFF_8079_LEN;
+				addr = I40E_I2C_EEPROM_DEV_ADDR2;
+			}
+		} else {
+			while (offset >= ETH_MODULE_SFF_8436_LEN) {
+				/* Compute memory page number and offset. */
+				offset -= ETH_MODULE_SFF_8436_LEN / 2;
+				addr++;
+			}
+		}
+
+		status = i40e_aq_get_phy_register(hw,
+				I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE,
+				addr, offset, &value, NULL);
+		if (status)
+			return -EIO;
+		data[i] = value;
+	}
+	return 0;
+}
+
 static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_drvinfo		= i40e_get_drvinfo,
 	.get_regs_len		= i40e_get_regs_len,
@@ -4228,6 +4380,8 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.set_rxfh		= i40e_set_rxfh,
 	.get_channels		= i40e_get_channels,
 	.set_channels		= i40e_set_channels,
+	.get_module_info	= i40e_get_module_info,
+	.get_module_eeprom	= i40e_get_module_eeprom,
 	.get_ts_info		= i40e_get_ts_info,
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index a39b13197891..01502561035c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -360,6 +360,15 @@ i40e_status i40e_aq_rx_ctl_write_register(struct i40e_hw *hw,
 				u32 reg_addr, u32 reg_val,
 				struct i40e_asq_cmd_details *cmd_details);
 void i40e_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val);
+i40e_status i40e_aq_set_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 reg_val,
+				     struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_get_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 *reg_val,
+				     struct i40e_asq_cmd_details *cmd_details);
+
 i40e_status i40e_read_phy_register_clause22(struct i40e_hw *hw,
 					    u16 reg, u8 phy_addr, u16 *value);
 i40e_status i40e_write_phy_register_clause22(struct i40e_hw *hw,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index fd4bbdd88b57..8b0b9f826b7f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -428,6 +428,18 @@ struct i40e_nvm_access {
 	u8 data[1];
 };
 
+/* (Q)SFP module access definitions */
+#define I40E_I2C_EEPROM_DEV_ADDR	0xA0
+#define I40E_I2C_EEPROM_DEV_ADDR2	0xA2
+#define I40E_MODULE_TYPE_ADDR		0x00
+#define I40E_MODULE_REVISION_ADDR	0x01
+#define I40E_MODULE_SFF_8472_COMP	0x5E
+#define I40E_MODULE_SFF_8472_SWAP	0x5C
+#define I40E_MODULE_SFF_ADDR_MODE	0x04
+#define I40E_MODULE_TYPE_QSFP_PLUS	0x0D
+#define I40E_MODULE_TYPE_QSFP28		0x11
+#define I40E_MODULE_QSFP_MAX_LEN	640
+
 /* PCI bus types */
 enum i40e_bus_type {
 	i40e_bus_type_unknown = 0,
@@ -598,6 +610,7 @@ struct i40e_hw {
 	struct i40e_dcbx_config desired_dcbx_config; /* CEE Desired Cfg */
 
 #define I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE BIT_ULL(0)
+#define I40E_HW_FLAG_AQ_PHY_ACCESS_CAPABLE  BIT_ULL(2)
 	u64 flags;
 
 	/* debug mask */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 709d114fc305..eee7ece42b39 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -244,6 +244,8 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_set_phy_debug		= 0x0622,
 	i40e_aqc_opc_upload_ext_phy_fm		= 0x0625,
 	i40e_aqc_opc_run_phy_activity		= 0x0626,
+	i40e_aqc_opc_set_phy_register		= 0x0628,
+	i40e_aqc_opc_get_phy_register		= 0x0629,
 
 	/* NVM commands */
 	i40e_aqc_opc_nvm_read			= 0x0701,
@@ -2046,6 +2048,22 @@ struct i40e_aqc_run_phy_activity {
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_run_phy_activity);
 
+/* Set PHY Register command (0x0628) */
+/* Get PHY Register command (0x0629) */
+struct i40e_aqc_phy_register_access {
+	u8	phy_interface;
+#define I40E_AQ_PHY_REG_ACCESS_INTERNAL	0
+#define I40E_AQ_PHY_REG_ACCESS_EXTERNAL	1
+#define I40E_AQ_PHY_REG_ACCESS_EXTERNAL_MODULE	2
+	u8	dev_address;
+	u8	reserved1[2];
+	__le32	reg_address;
+	__le32	reg_value;
+	u8	reserved2[4];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_phy_register_access);
+
 /* NVM Read command (indirect 0x0701)
  * NVM Erase commands (direct 0x0702)
  * NVM Update commands (indirect 0x0703)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 8d3a2bfe186a..7d70bf69b249 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -1041,6 +1041,75 @@ void i40evf_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
 		wr32(hw, reg_addr, reg_val);
 }
 
+/**
+ * i40evf_aq_set_phy_register
+ * @hw: pointer to the hw struct
+ * @phy_select: select which phy should be accessed
+ * @dev_addr: PHY device address
+ * @reg_addr: PHY register address
+ * @reg_val: new register value
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Reset the external PHY.
+ **/
+i40e_status i40evf_aq_set_phy_register(struct i40e_hw *hw,
+				       u8 phy_select, u8 dev_addr,
+				       u32 reg_addr, u32 reg_val,
+				       struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_phy_register_access *cmd =
+		(struct i40e_aqc_phy_register_access *)&desc.params.raw;
+	i40e_status status;
+
+	i40evf_fill_default_direct_cmd_desc(&desc,
+					    i40e_aqc_opc_set_phy_register);
+
+	cmd->phy_interface = phy_select;
+	cmd->dev_address = dev_addr;
+	cmd->reg_address = cpu_to_le32(reg_addr);
+	cmd->reg_value = cpu_to_le32(reg_val);
+
+	status = i40evf_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
+ * i40evf_aq_get_phy_register
+ * @hw: pointer to the hw struct
+ * @phy_select: select which phy should be accessed
+ * @dev_addr: PHY device address
+ * @reg_addr: PHY register address
+ * @reg_val: read register value
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Reset the external PHY.
+ **/
+i40e_status i40evf_aq_get_phy_register(struct i40e_hw *hw,
+				       u8 phy_select, u8 dev_addr,
+				       u32 reg_addr, u32 *reg_val,
+				       struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_phy_register_access *cmd =
+		(struct i40e_aqc_phy_register_access *)&desc.params.raw;
+	i40e_status status;
+
+	i40evf_fill_default_direct_cmd_desc(&desc,
+					    i40e_aqc_opc_get_phy_register);
+
+	cmd->phy_interface = phy_select;
+	cmd->dev_address = dev_addr;
+	cmd->reg_address = cpu_to_le32(reg_addr);
+
+	status = i40evf_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+	if (!status)
+		*reg_val = le32_to_cpu(cmd->reg_value);
+
+	return status;
+}
+
 /**
  * i40e_aq_send_msg_to_pf
  * @hw: pointer to the hardware structure
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index c9836bba487d..b624b5994075 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -111,6 +111,15 @@ i40e_status i40evf_aq_rx_ctl_write_register(struct i40e_hw *hw,
 				u32 reg_addr, u32 reg_val,
 				struct i40e_asq_cmd_details *cmd_details);
 void i40evf_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val);
+i40e_status i40e_aq_set_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 reg_val,
+				     struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_get_phy_register(struct i40e_hw *hw,
+				     u8 phy_select, u8 dev_addr,
+				     u32 reg_addr, u32 *reg_val,
+				     struct i40e_asq_cmd_details *cmd_details);
+
 i40e_status i40e_read_phy_register(struct i40e_hw *hw, u8 page,
 				   u16 reg, u8 phy_addr, u16 *value);
 i40e_status i40e_write_phy_register(struct i40e_hw *hw, u8 page,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 2ea919d9cdcf..b53584e3d580 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -401,6 +401,18 @@ struct i40e_nvm_access {
 	u8 data[1];
 };
 
+/* (Q)SFP module access definitions */
+#define I40E_I2C_EEPROM_DEV_ADDR	0xA0
+#define I40E_I2C_EEPROM_DEV_ADDR2	0xA2
+#define I40E_MODULE_TYPE_ADDR		0x00
+#define I40E_MODULE_REVISION_ADDR	0x01
+#define I40E_MODULE_SFF_8472_COMP	0x5E
+#define I40E_MODULE_SFF_8472_SWAP	0x5C
+#define I40E_MODULE_SFF_ADDR_MODE	0x04
+#define I40E_MODULE_TYPE_QSFP_PLUS	0x0D
+#define I40E_MODULE_TYPE_QSFP28		0x11
+#define I40E_MODULE_QSFP_MAX_LEN	640
+
 /* PCI bus types */
 enum i40e_bus_type {
 	i40e_bus_type_unknown = 0,
-- 
2.14.2
