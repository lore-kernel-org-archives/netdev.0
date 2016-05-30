From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 12/13] net: hns: implement the miscellaneous operation by asl
Date: Mon, 30 May 2016 20:34:23 +0800
Message-ID: <1464611664-93775-13-git-send-email-Yisen.Zhuang@huawei.com>
References: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

The miscellaneous operation is implemented in BIOS, the kernel can call
_DSM method help to call the implementation in ACPI case. Here is a patch
to do that.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v3: fix potential memory leak
     add Reviewed-by: Andy Shevchenko

 v2: use a serial function to implement the reset sequence
  link: https://lkml.org/lkml/2016/5/29/186

 v1: first submit
  link: https://lkml.org/lkml/2016/5/13/94
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 171 +++++++++++++++++++++
 1 file changed, 171 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index f21177b..6a75d81 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -12,6 +12,27 @@
 #include "hns_dsaf_ppe.h"
 #include "hns_dsaf_reg.h"
 
+enum _dsm_op_index {
+	HNS_OP_RESET_FUNC               = 0x1,
+	HNS_OP_SERDES_LP_FUNC           = 0x2,
+	HNS_OP_LED_SET_FUNC             = 0x3,
+	HNS_OP_GET_PORT_TYPE_FUNC       = 0x4,
+	HNS_OP_GET_SFP_STAT_FUNC        = 0x5,
+};
+
+enum _dsm_rst_type {
+	HNS_DSAF_RESET_FUNC     = 0x1,
+	HNS_PPE_RESET_FUNC      = 0x2,
+	HNS_XGE_CORE_RESET_FUNC = 0x3,
+	HNS_XGE_RESET_FUNC      = 0x4,
+	HNS_GE_RESET_FUNC       = 0x5,
+};
+
+const u8 hns_dsaf_acpi_dsm_uuid[] = {
+	0x1A, 0xAA, 0x85, 0x1A, 0x93, 0xE2, 0x5E, 0x41,
+	0x8E, 0x28, 0x8D, 0x69, 0x0A, 0x0F, 0x82, 0x0A
+};
+
 static void dsaf_write_sub(struct dsaf_device *dsaf_dev, u32 reg, u32 val)
 {
 	if (dsaf_dev->sub_ctrl)
@@ -109,6 +130,34 @@ static int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 
 #define RESET_REQ_OR_DREQ 1
 
+static void hns_dsaf_acpi_srst_by_port(struct dsaf_device *dsaf_dev, u8 op_type,
+				       u32 port_type, u32 port, u32 val)
+{
+	union acpi_object *obj;
+	union acpi_object obj_args[3], argv4;
+
+	obj_args[0].integer.type = ACPI_TYPE_INTEGER;
+	obj_args[0].integer.value = port_type;
+	obj_args[1].integer.type = ACPI_TYPE_INTEGER;
+	obj_args[1].integer.value = port;
+	obj_args[2].integer.type = ACPI_TYPE_INTEGER;
+	obj_args[2].integer.value = val;
+
+	argv4.type = ACPI_TYPE_PACKAGE;
+	argv4.package.count = 3;
+	argv4.package.elements = obj_args;
+
+	obj = acpi_evaluate_dsm(ACPI_HANDLE(dsaf_dev->dev),
+				hns_dsaf_acpi_dsm_uuid, 0, op_type, &argv4);
+	if (!obj) {
+		dev_warn(dsaf_dev->dev, "reset port_type%d port%d fail!",
+			 port_type, port);
+		return;
+	}
+
+	ACPI_FREE(obj);
+}
+
 static void hns_dsaf_rst(struct dsaf_device *dsaf_dev, bool dereset)
 {
 	u32 xbar_reg_addr;
@@ -126,6 +175,13 @@ static void hns_dsaf_rst(struct dsaf_device *dsaf_dev, bool dereset)
 	dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
 }
 
+static void hns_dsaf_rst_acpi(struct dsaf_device *dsaf_dev, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_DSAF_RESET_FUNC,
+				   0, dereset);
+}
+
 static void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 				      bool dereset)
 {
@@ -146,6 +202,13 @@ static void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
+static void hns_dsaf_xge_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
+					   u32 port, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_XGE_RESET_FUNC, port, dereset);
+}
+
 static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 					   u32 port, bool dereset)
 {
@@ -166,6 +229,14 @@ static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
+static void
+hns_dsaf_xge_core_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
+				    u32 port, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_XGE_CORE_RESET_FUNC, port, dereset);
+}
+
 static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 				     bool dereset)
 {
@@ -218,6 +289,13 @@ static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 	}
 }
 
+static void hns_dsaf_ge_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
+					  u32 port, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_GE_RESET_FUNC, port, dereset);
+}
+
 static void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 				 bool dereset)
 {
@@ -234,11 +312,21 @@ static void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
+static void
+hns_ppe_srst_by_port_acpi(struct dsaf_device *dsaf_dev, u32 port, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_PPE_RESET_FUNC, port, dereset);
+}
+
 static void hns_ppe_com_srst(struct dsaf_device *dsaf_dev, bool dereset)
 {
 	u32 reg_val;
 	u32 reg_addr;
 
+	if (!(dev_of_node(dsaf_dev->dev)))
+		return;
+
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val = RESET_REQ_OR_DREQ;
 		if (!dereset)
@@ -295,6 +383,40 @@ static phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	return phy_if;
 }
 
+static phy_interface_t hns_mac_get_phy_if_acpi(struct hns_mac_cb *mac_cb)
+{
+	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
+	union acpi_object *obj;
+	union acpi_object obj_args, argv4;
+
+	obj_args.integer.type = ACPI_TYPE_INTEGER;
+	obj_args.integer.value = mac_cb->mac_id;
+
+	argv4.type = ACPI_TYPE_PACKAGE,
+	argv4.package.count = 1,
+	argv4.package.elements = &obj_args,
+
+	obj = acpi_evaluate_dsm(ACPI_HANDLE(mac_cb->dev),
+				hns_dsaf_acpi_dsm_uuid, 0,
+				HNS_OP_GET_PORT_TYPE_FUNC, &argv4);
+
+	if (!obj)
+		return phy_if;
+
+	if (obj->type != ACPI_TYPE_INTEGER)
+		goto exit_free;
+
+	phy_if = obj->integer.value ?
+		PHY_INTERFACE_MODE_XGMII : PHY_INTERFACE_MODE_SGMII;
+
+	dev_dbg(mac_cb->dev, "mac_id=%d, phy_if=%d\n", mac_cb->mac_id, phy_if);
+
+exit_free:
+	ACPI_FREE(obj);
+
+	return phy_if;
+}
+
 int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
 {
 	if (!mac_cb->cpld_ctrl)
@@ -354,6 +476,36 @@ static int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, bool en)
 	return 0;
 }
 
+static int
+hns_mac_config_sds_loopback_acpi(struct hns_mac_cb *mac_cb, bool en)
+{
+	union acpi_object *obj;
+	union acpi_object obj_args[3], argv4;
+
+	obj_args[0].integer.type = ACPI_TYPE_INTEGER;
+	obj_args[0].integer.value = mac_cb->mac_id;
+	obj_args[1].integer.type = ACPI_TYPE_INTEGER;
+	obj_args[1].integer.value = !!en;
+
+	argv4.type = ACPI_TYPE_PACKAGE;
+	argv4.package.count = 2;
+	argv4.package.elements = obj_args;
+
+	obj = acpi_evaluate_dsm(ACPI_HANDLE(mac_cb->dsaf_dev->dev),
+				hns_dsaf_acpi_dsm_uuid, 0,
+				HNS_OP_SERDES_LP_FUNC, &argv4);
+	if (!obj) {
+		dev_warn(mac_cb->dsaf_dev->dev, "set port%d serdes lp fail!",
+			 mac_cb->mac_id);
+
+		return -ENOTSUPP;
+	}
+
+	ACPI_FREE(obj);
+
+	return 0;
+}
+
 struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 {
 	struct dsaf_misc_op *misc_op;
@@ -378,6 +530,25 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
 
 		misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback;
+	} else if (is_acpi_node(dsaf_dev->dev->fwnode)) {
+		misc_op->cpld_set_led = hns_cpld_set_led;
+		misc_op->cpld_reset_led = cpld_led_reset;
+		misc_op->cpld_set_led_id = cpld_set_led_id;
+
+		misc_op->dsaf_reset = hns_dsaf_rst_acpi;
+		misc_op->xge_srst = hns_dsaf_xge_srst_by_port_acpi;
+		misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port_acpi;
+		misc_op->ge_srst = hns_dsaf_ge_srst_by_port_acpi;
+		misc_op->ppe_srst = hns_ppe_srst_by_port_acpi;
+		misc_op->ppe_comm_srst = hns_ppe_com_srst;
+
+		misc_op->get_phy_if = hns_mac_get_phy_if_acpi;
+		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
+
+		misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback_acpi;
+	} else {
+		devm_kfree(dsaf_dev->dev, (void *)misc_op);
+		misc_op = NULL;
 	}
 
 	return (void *)misc_op;
-- 
1.9.1
