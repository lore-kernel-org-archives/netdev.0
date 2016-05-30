From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v2 net-next 10/13] net: hns: dsaf adds support of acpi
Date: Mon, 30 May 2016 10:10:19 +0800
Message-ID: <1464574222-69608-11-git-send-email-yankejian@huawei.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dsaf needs to get configuration parameter by ACPI, so this patch add
support of ACPI.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v2:
  1. use dev_of_node() instead of IS_ENABLED() to check if it is in
DT case,
  2. split a new patch to implement misc operation method,
  3. use acpi_dev_found() instead of acpi_match_device_ids() to
check which hw version it is,
  4. use is_acpi_node instead of ACPI_COMPANION to check if it is
work in ACPI case.

 v1: first submit
  link: https://lkml.org/lkml/2016/5/13/108
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 80 ++++++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 85 +++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 32 ++++----
 3 files changed, 114 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 2ebf14a..3ef0c9b 100644
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
index 28bde08..ac03c4a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -7,6 +7,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/acpi.h>
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
@@ -33,6 +34,13 @@ const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
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
@@ -46,10 +54,22 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	struct device_node *np = dsaf_dev->dev->of_node;
 	struct platform_device *pdev = to_platform_device(dsaf_dev->dev);
 
-	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
-		dsaf_dev->dsaf_ver = AE_VERSION_1;
-	else
-		dsaf_dev->dsaf_ver = AE_VERSION_2;
+	if (dev_of_node(dsaf_dev->dev)) {
+		if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
+			dsaf_dev->dsaf_ver = AE_VERSION_1;
+		else
+			dsaf_dev->dsaf_ver = AE_VERSION_2;
+	} else if (is_acpi_node(dsaf_dev->dev->fwnode)) {
+		if (acpi_dev_found(hns_dsaf_acpi_match[0].id))
+			dsaf_dev->dsaf_ver = AE_VERSION_1;
+		else if (acpi_dev_found(hns_dsaf_acpi_match[1].id))
+			dsaf_dev->dsaf_ver = AE_VERSION_2;
+		else
+			return -ENXIO;
+	} else {
+		dev_err(dsaf_dev->dev, "cannot get cfg data from of or acpi\n");
+		return -ENXIO;
+	}
 
 	ret = device_property_read_string(dsaf_dev->dev, "mode", &mode_str);
 	if (ret) {
@@ -81,32 +101,40 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
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
+	if (dev_of_node(dsaf_dev->dev)) {
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
@@ -2686,6 +2714,7 @@ static struct platform_driver g_dsaf_driver = {
 	.driver = {
 		.name = DSAF_DRV_NAME,
 		.of_match_table = g_dsaf_match,
+		.acpi_match_table = hns_dsaf_acpi_match,
 	},
 };
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index e1c3e0d..f21177b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -362,21 +362,23 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 	if (!misc_op)
 		return NULL;
 
-	misc_op->cpld_set_led = hns_cpld_set_led;
-	misc_op->cpld_reset_led = cpld_led_reset;
-	misc_op->cpld_set_led_id = cpld_set_led_id;
-
-	misc_op->dsaf_reset = hns_dsaf_rst;
-	misc_op->xge_srst = hns_dsaf_xge_srst_by_port;
-	misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port;
-	misc_op->ge_srst = hns_dsaf_ge_srst_by_port;
-	misc_op->ppe_srst = hns_ppe_srst_by_port;
-	misc_op->ppe_comm_srst = hns_ppe_com_srst;
-
-	misc_op->get_phy_if = hns_mac_get_phy_if;
-	misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
-
-	misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback;
+	if (dev_of_node(dsaf_dev->dev)) {
+		misc_op->cpld_set_led = hns_cpld_set_led;
+		misc_op->cpld_reset_led = cpld_led_reset;
+		misc_op->cpld_set_led_id = cpld_set_led_id;
+
+		misc_op->dsaf_reset = hns_dsaf_rst;
+		misc_op->xge_srst = hns_dsaf_xge_srst_by_port;
+		misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port;
+		misc_op->ge_srst = hns_dsaf_ge_srst_by_port;
+		misc_op->ppe_srst = hns_ppe_srst_by_port;
+		misc_op->ppe_comm_srst = hns_ppe_com_srst;
+
+		misc_op->get_phy_if = hns_mac_get_phy_if;
+		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
+
+		misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback;
+	}
 
 	return (void *)misc_op;
 }
-- 
1.9.1
