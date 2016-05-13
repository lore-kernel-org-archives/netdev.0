From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next 07/11] net: hns: dsaf adds support of acpi
Date: Fri, 13 May 2016 16:19:13 +0800
Message-ID: <1463127557-90824-8-git-send-email-Yisen.Zhuang@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Dsaf needs to get configuration parameter by ACPI, so this patch add
support of ACPI.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  80 +++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  86 ++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 259 ++++++++++++---------
 3 files changed, 244 insertions(+), 181 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 527b49d..6e8f2b3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -689,9 +689,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		return 0;
 	}
 
-	if (!is_of_node(mac_cb->fw_port))
-		return -EINVAL;
-
+	if (is_of_node(mac_cb->fw_port)) {
 	/* parse property from port subnode in dsaf */
 	np = of_parse_phandle(to_of_node(mac_cb->fw_port), "phy-handle", 0);
 	mac_cb->phy_dev = of_phy_find_device(np);
@@ -701,47 +699,49 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 			mac_cb->mac_id, np->name);
 		}
 
-	syscon = syscon_node_to_regmap(
-			of_parse_phandle(to_of_node(mac_cb->fw_port),
-					 "serdes-syscon", 0));
-	if (IS_ERR_OR_NULL(syscon)) {
-		dev_err(mac_cb->dev, "serdes-syscon is needed!\n");
-		return -EINVAL;
-	}
-	mac_cb->serdes_ctrl = syscon;
-
-	ret = fwnode_property_read_u32(mac_cb->fw_port,
-				       "port-rst-offset",
-				       &mac_cb->port_rst_off);
-	if (ret) {
-		dev_dbg(mac_cb->dev,
-			"mac%d port-rst-offset not found, use default value.\n",
-			mac_cb->mac_id);
-	}
+		syscon = syscon_node_to_regmap(
+				of_parse_phandle(to_of_node(mac_cb->fw_port),
+						 "serdes-syscon", 0));
+		if (IS_ERR_OR_NULL(syscon)) {
+			dev_err(mac_cb->dev, "serdes-syscon is needed!\n");
+			return -EINVAL;
+		}
+		mac_cb->serdes_ctrl = syscon;
 
-	ret = fwnode_property_read_u32(mac_cb->fw_port,
-				       "port-mode-offset",
-				       &mac_cb->port_mode_off);
-	if (ret) {
-		dev_dbg(mac_cb->dev,
-			"mac%d port-mode-offset not found, use default value.\n",
-			mac_cb->mac_id);
-	}
+		ret = fwnode_property_read_u32(mac_cb->fw_port,
+					       "port-rst-offset",
+					       &mac_cb->port_rst_off);
+		if (ret) {
+			dev_dbg(mac_cb->dev,
+				"mac%d port-rst-offset not found, use default value.\n",
+				mac_cb->mac_id);
+		}
 
-	ret = of_parse_phandle_with_fixed_args(to_of_node(mac_cb->fw_port),
-					       "cpld-syscon", 1, 0, &cpld_args);
-	if (ret) {
-		dev_dbg(mac_cb->dev, "mac%d no cpld-syscon found.\n",
-			mac_cb->mac_id);
-		mac_cb->cpld_ctrl = NULL;
-	} else {
-		syscon = syscon_node_to_regmap(cpld_args.np);
-		if (IS_ERR_OR_NULL(syscon)) {
-			dev_dbg(mac_cb->dev, "no cpld-syscon found!\n");
+		ret = fwnode_property_read_u32(mac_cb->fw_port,
+					       "port-mode-offset",
+					       &mac_cb->port_mode_off);
+		if (ret) {
+			dev_dbg(mac_cb->dev,
+				"mac%d port-mode-offset not found, use default value.\n",
+				mac_cb->mac_id);
+		}
+
+		ret = of_parse_phandle_with_fixed_args(
+			to_of_node(mac_cb->fw_port), "cpld-syscon", 1, 0,
+			&cpld_args);
+		if (ret) {
+			dev_dbg(mac_cb->dev, "mac%d no cpld-syscon found.\n",
+				mac_cb->mac_id);
 			mac_cb->cpld_ctrl = NULL;
 		} else {
-			mac_cb->cpld_ctrl = syscon;
-			mac_cb->cpld_ctrl_reg = cpld_args.args[0];
+			syscon = syscon_node_to_regmap(cpld_args.np);
+			if (IS_ERR_OR_NULL(syscon)) {
+				dev_dbg(mac_cb->dev, "no cpld-syscon found!\n");
+				mac_cb->cpld_ctrl = NULL;
+			} else {
+				mac_cb->cpld_ctrl = syscon;
+				mac_cb->cpld_ctrl_reg = cpld_args.args[0];
+			}
 		}
 	}
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9afc5e6..da878b1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -7,6 +7,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/acpi.h>
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
@@ -32,6 +33,13 @@ const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
 	[DSAF_MODE_DISABLE_SP] = "single-port",
 };
 
+static const struct acpi_device_id hns_dsaf_acpi_match[] = {
+	{ "HISI00B1", 0 },
+	{ "HISI00B2", 0 },
+	{ },
+};
+MODULE_DEVICE_TABLE(acpi, hns_dsaf_acpi_match);
+
 int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 {
 	int ret, i;
@@ -43,12 +51,25 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	struct regmap *syscon;
 	struct resource *res;
 	struct device_node *np = dsaf_dev->dev->of_node;
+	struct fwnode_handle *fwnode = dsaf_dev->dev->fwnode;
+	struct acpi_device *adev;
 	struct platform_device *pdev = to_platform_device(dsaf_dev->dev);
 
-	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
-		dsaf_dev->dsaf_ver = AE_VERSION_1;
-	else
-		dsaf_dev->dsaf_ver = AE_VERSION_2;
+	if (IS_ENABLED(CONFIG_OF) && np) {
+		if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
+			dsaf_dev->dsaf_ver = AE_VERSION_1;
+		else
+			dsaf_dev->dsaf_ver = AE_VERSION_2;
+	} else if (ACPI_COMPANION(dsaf_dev->dev)) {
+		adev = to_acpi_device_node(fwnode);
+		if (!acpi_match_device_ids(adev, &hns_dsaf_acpi_match[1]))
+			dsaf_dev->dsaf_ver = AE_VERSION_2;
+		else
+			dsaf_dev->dsaf_ver = AE_VERSION_1;
+	} else {
+		dev_err(dsaf_dev->dev, "cannot get cfd data from of or acpi\n");
+		return -ENXIO;
+	}
 
 	ret = device_property_read_string(dsaf_dev->dev, "mode", &mode_str);
 	if (ret) {
@@ -80,32 +101,40 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	else
 		dsaf_dev->dsaf_tc_mode = HRD_DSAF_4TC_MODE;
 
-	syscon = syscon_node_to_regmap(
-			of_parse_phandle(np, "subctrl-syscon", 0));
-	if (IS_ERR_OR_NULL(syscon)) {
-		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
-		if (!res) {
-			dev_err(dsaf_dev->dev, "subctrl info is needed!\n");
-			return -ENOMEM;
-		}
-		dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev, res);
-		if (!dsaf_dev->sc_base) {
-			dev_err(dsaf_dev->dev, "subctrl can not map!\n");
-			return -ENOMEM;
-		}
+	if (IS_ENABLED(CONFIG_OF) && np) {
+		syscon = syscon_node_to_regmap(
+				of_parse_phandle(np, "subctrl-syscon", 0));
+		if (IS_ERR_OR_NULL(syscon)) {
+			res = platform_get_resource(pdev, IORESOURCE_MEM,
+						    res_idx++);
+			if (!res) {
+				dev_err(dsaf_dev->dev, "subctrl info is needed!\n");
+				return -ENOMEM;
+			}
 
-		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
-		if (!res) {
-			dev_err(dsaf_dev->dev, "serdes-ctrl info is needed!\n");
-			return -ENOMEM;
-		}
-		dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev, res);
-		if (!dsaf_dev->sds_base) {
-			dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
-			return -ENOMEM;
+			dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev,
+								  res);
+			if (!dsaf_dev->sc_base) {
+				dev_err(dsaf_dev->dev, "subctrl can not map!\n");
+				return -ENOMEM;
+			}
+
+			res = platform_get_resource(pdev, IORESOURCE_MEM,
+						    res_idx++);
+			if (!res) {
+				dev_err(dsaf_dev->dev, "serdes-ctrl info is needed!\n");
+				return -ENOMEM;
+			}
+
+			dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev,
+								   res);
+			if (!dsaf_dev->sds_base) {
+				dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
+				return -ENOMEM;
+			}
+		} else {
+			dsaf_dev->sub_ctrl = syscon;
 		}
-	} else {
-		dsaf_dev->sub_ctrl = syscon;
 	}
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ppe-base");
@@ -2681,6 +2710,7 @@ static struct platform_driver g_dsaf_driver = {
 	.driver = {
 		.name = DSAF_DRV_NAME,
 		.of_match_table = g_dsaf_match,
+		.acpi_match_table = hns_dsaf_acpi_match,
 	},
 };
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a843a86..ed96d7b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -114,16 +114,18 @@ void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
 	u32 xbar_reg_addr;
 	u32 nt_reg_addr;
 
-	if (!val) {
-		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
-		nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
-	} else {
-		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_DREQ_REG;
-		nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
-	}
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		if (!val) {
+			xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
+			nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
+		} else {
+			xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_DREQ_REG;
+			nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
+		}
 
-	dsaf_write_sub(dsaf_dev, xbar_reg_addr, RESET_REQ_OR_DREQ);
-	dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
+		dsaf_write_sub(dsaf_dev, xbar_reg_addr, RESET_REQ_OR_DREQ);
+		dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
+	}
 }
 
 void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
@@ -134,15 +136,18 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	if (port >= DSAF_XGE_NUM)
 		return;
 
-	reg_val |= RESET_REQ_OR_DREQ;
-	reg_val |= 0x2082082 << dsaf_dev->mac_cb[port]->port_rst_off;
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		reg_val |= RESET_REQ_OR_DREQ;
 
-	if (val == 0)
-		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
-	else
-		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
+		reg_val |= 0x2082082 << dsaf_dev->mac_cb[port]->port_rst_off;
 
-	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+		if (val == 0)
+			reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
+		else
+			reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
+
+		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	}
 }
 
 void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
@@ -153,16 +158,17 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 
 	if (port >= DSAF_XGE_NUM)
 		return;
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		reg_val |= XGMAC_TRX_CORE_SRST_M
+			<< dsaf_dev->mac_cb[port]->port_rst_off;
 
-	reg_val |= XGMAC_TRX_CORE_SRST_M
-		<< dsaf_dev->mac_cb[port]->port_rst_off;
-
-	if (val == 0)
-		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
-	else
-		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
+		if (val == 0)
+			reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
+		else
+			reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
 
-	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	}
 }
 
 void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
@@ -174,44 +180,54 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	if (port >= DSAF_GE_NUM)
 		return;
 
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
-		reg_val_1  = 0x1 << port;
-		port_rst_off = dsaf_dev->mac_cb[port]->port_rst_off;
-		/* there is difference between V1 and V2 in register.*/
-		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
-			reg_val_2  = 0x1041041 << port_rst_off;
-		else
-			reg_val_2  = 0x2082082 << port_rst_off;
-
-		if (val == 0) {
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
-				       reg_val_1);
-
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ0_REG,
-				       reg_val_2);
-		} else {
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ0_REG,
-				       reg_val_2);
-
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ1_REG,
-				       reg_val_1);
-		}
-	} else {
-		reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
-		reg_val_2 = 0x100 << dsaf_dev->reset_offset;
-
-		if (val == 0) {
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
-				       reg_val_1);
-
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_PPE_RESET_REQ_REG,
-				       reg_val_2);
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
+			reg_val_1  = 0x1 << port;
+			port_rst_off = dsaf_dev->mac_cb[port]->port_rst_off;
+			/* there is difference between V1 and V2 in register.*/
+			if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+				reg_val_2  = 0x1041041 << port_rst_off;
+			else
+				reg_val_2  = 0x2082082 << port_rst_off;
+
+			if (val == 0) {
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+					       reg_val_1);
+
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_REQ0_REG,
+					       reg_val_2);
+			} else {
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_DREQ0_REG,
+					       reg_val_2);
+
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+					       reg_val_1);
+			}
 		} else {
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ1_REG,
-				       reg_val_1);
-
-			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_PPE_RESET_DREQ_REG,
-				       reg_val_2);
+			reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
+			reg_val_2 = 0x100 << dsaf_dev->reset_offset;
+
+			if (val == 0) {
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+					       reg_val_1);
+
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_PPE_RESET_REQ_REG,
+					       reg_val_2);
+			} else {
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+					       reg_val_1);
+
+				dsaf_write_sub(dsaf_dev,
+					       DSAF_SUB_SC_PPE_RESET_DREQ_REG,
+					       reg_val_2);
+			}
 		}
 	}
 }
@@ -221,14 +237,18 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	u32 reg_val = 0;
 	u32 reg_addr;
 
-	reg_val |= RESET_REQ_OR_DREQ <<	dsaf_dev->mac_cb[port]->port_rst_off;
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		struct hns_mac_cb *mac_cb = dsaf_dev->mac_cb[port];
 
-	if (val == 0)
-		reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
-	else
-		reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
+		reg_val |= RESET_REQ_OR_DREQ << mac_cb->port_rst_off;
 
-	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+		if (val == 0)
+			reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
+		else
+			reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
+
+		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	}
 }
 
 void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
@@ -237,6 +257,9 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 	u32 reg_val;
 	u32 reg_addr;
 
+	if (!(IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node))
+		return;
+
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val = RESET_REQ_OR_DREQ;
 		if (val == 0)
@@ -267,29 +290,31 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	u32 reg;
 	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 	int mac_id = mac_cb->mac_id;
-	phy_interface_t phy_if;
+	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
 
-	if (is_ver1) {
-		if (HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev))
-			return PHY_INTERFACE_MODE_SGMII;
+	if (IS_ENABLED(CONFIG_OF) && mac_cb->dev->of_node) {
+		if (is_ver1) {
+			if (HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev))
+				return PHY_INTERFACE_MODE_SGMII;
 
-		if (mac_id >= 0 && mac_id <= 3)
-			reg = HNS_MAC_HILINK4_REG;
-		else
-			reg = HNS_MAC_HILINK3_REG;
-	} else{
-		if (!HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev) && mac_id <= 3)
-			reg = HNS_MAC_HILINK4V2_REG;
+			if (mac_id >= 0 && mac_id <= 3)
+				reg = HNS_MAC_HILINK4_REG;
+			else
+				reg = HNS_MAC_HILINK3_REG;
+		} else {
+			if (!HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev) && mac_id <= 3)
+				reg = HNS_MAC_HILINK4V2_REG;
+			else
+				reg = HNS_MAC_HILINK3V2_REG;
+		}
+
+		mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
+		if (dsaf_get_bit(mode, mac_cb->port_mode_off))
+			phy_if = PHY_INTERFACE_MODE_XGMII;
 		else
-			reg = HNS_MAC_HILINK3V2_REG;
+			phy_if = PHY_INTERFACE_MODE_SGMII;
 	}
 
-	mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
-	if (dsaf_get_bit(mode, mac_cb->port_mode_off))
-		phy_if = PHY_INTERFACE_MODE_XGMII;
-	else
-		phy_if = PHY_INTERFACE_MODE_SGMII;
-
 	return phy_if;
 }
 
@@ -311,42 +336,50 @@ int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
  */
 int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
 {
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+
 	/* port 0-3 hilink4 base is serdes_vaddr + 0x00280000
 	 * port 4-7 hilink3 base is serdes_vaddr + 0x00200000
 	 */
-	u8 *base_addr = (u8 *)mac_cb->serdes_vaddr +
-		       (mac_cb->mac_id <= 3 ? 0x00280000 : 0x00200000);
-	const u8 lane_id[] = {
-		0,	/* mac 0 -> lane 0 */
-		1,	/* mac 1 -> lane 1 */
-		2,	/* mac 2 -> lane 2 */
-		3,	/* mac 3 -> lane 3 */
-		2,	/* mac 4 -> lane 2 */
-		3,	/* mac 5 -> lane 3 */
-		0,	/* mac 6 -> lane 0 */
-		1	/* mac 7 -> lane 1 */
-	};
+
+	if (IS_ENABLED(CONFIG_OF) && dsaf_dev->dev->of_node) {
+		u8 *base_addr = (u8 *)mac_cb->serdes_vaddr +
+			(mac_cb->mac_id <= 3 ? 0x00280000 : 0x00200000);
+		const u8 lane_id[] = {
+			0,	/* mac 0 -> lane 0 */
+			1,	/* mac 1 -> lane 1 */
+			2,	/* mac 2 -> lane 2 */
+			3,	/* mac 3 -> lane 3 */
+			2,	/* mac 4 -> lane 2 */
+			3,	/* mac 5 -> lane 3 */
+			0,	/* mac 6 -> lane 0 */
+			1	/* mac 7 -> lane 1 */
+		};
 #define RX_CSR(lane, reg) ((0x4080 + (reg) * 0x0002 + (lane) * 0x0200) * 2)
-	u64 reg_offset = RX_CSR(lane_id[mac_cb->mac_id], 0);
+		u64 reg_offset = RX_CSR(lane_id[mac_cb->mac_id], 0);
 
-	int sfp_prsnt;
-	int ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
+		int sfp_prsnt;
+		int ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
 
-	if (!mac_cb->phy_dev) {
-		if (ret)
-			pr_info("please confirm sfp is present or not\n");
-		else
-			if (!sfp_prsnt)
-				pr_info("no sfp in this eth\n");
-	}
+		if (!mac_cb->phy_dev) {
+			if (ret)
+				pr_info("please confirm sfp is present or not\n");
+			else
+				if (!sfp_prsnt)
+					pr_info("no sfp in this eth\n");
+		}
 
-	if (mac_cb->serdes_ctrl) {
-		u32 origin = dsaf_read_syscon(mac_cb->serdes_ctrl, reg_offset);
+		if (mac_cb->serdes_ctrl) {
+			u32 origin = dsaf_read_syscon(mac_cb->serdes_ctrl,
+						      reg_offset);
 
-		dsaf_set_field(origin, 1ull << 10, 10, !!en);
-		dsaf_write_syscon(mac_cb->serdes_ctrl, reg_offset, origin);
-	} else {
-		dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, !!en);
+			dsaf_set_field(origin, 1ull << 10, 10, !!en);
+			dsaf_write_syscon(mac_cb->serdes_ctrl, reg_offset,
+					  origin);
+		} else {
+			dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10,
+					   10, !!en);
+		}
 	}
 
 	return 0;
-- 
1.9.1
