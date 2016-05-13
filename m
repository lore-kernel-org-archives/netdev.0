From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next 10/11] net: hns: implement the reset sequence by asl
Date: Fri, 13 May 2016 16:19:16 +0800
Message-ID: <1463127557-90824-11-git-send-email-Yisen.Zhuang@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:1660 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbcEMIAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 04:00:48 -0400
In-Reply-To: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

The reset sequence is implemented in BIOS, the kernel can call _DSM
method help to call the implementation in ACPI case. Here is a patch
to do that.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 113 +++++++++++++++++++++
 1 file changed, 113 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index ed96d7b..9edf4f7 100644
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
@@ -109,6 +130,34 @@ int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 
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
 void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
 {
 	u32 xbar_reg_addr;
@@ -125,6 +174,10 @@ void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
 
 		dsaf_write_sub(dsaf_dev, xbar_reg_addr, RESET_REQ_OR_DREQ);
 		dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+					   HNS_DSAF_RESET_FUNC,
+					   0, val);
 	}
 }
 
@@ -147,6 +200,9 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 			reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
 
 		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+					   HNS_XGE_RESET_FUNC, port, val);
 	}
 }
 
@@ -168,6 +224,9 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 			reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
 
 		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+					   HNS_XGE_CORE_RESET_FUNC, port, val);
 	}
 }
 
@@ -229,6 +288,9 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 					       reg_val_2);
 			}
 		}
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+					   HNS_GE_RESET_FUNC, port, val);
 	}
 }
 
@@ -248,6 +310,9 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 			reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
 
 		dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+					   HNS_PPE_RESET_FUNC, port, val);
 	}
 }
 
@@ -313,6 +378,30 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 			phy_if = PHY_INTERFACE_MODE_XGMII;
 		else
 			phy_if = PHY_INTERFACE_MODE_SGMII;
+	} else if (is_acpi_device_node(mac_cb->dev->fwnode)) {
+		union acpi_object *obj;
+		union acpi_object obj_args, argv4;
+
+		obj_args.integer.type = ACPI_TYPE_INTEGER;
+		obj_args.integer.value = mac_cb->mac_id;
+
+		argv4.type = ACPI_TYPE_PACKAGE,
+		argv4.package.count = 1,
+		argv4.package.elements = &obj_args,
+
+		obj = acpi_evaluate_dsm(ACPI_HANDLE(mac_cb->dev),
+					hns_dsaf_acpi_dsm_uuid, 0,
+					HNS_OP_GET_PORT_TYPE_FUNC, &argv4);
+
+		if (!obj || obj->type != ACPI_TYPE_INTEGER)
+			return phy_if;
+
+		phy_if = obj->integer.value ?
+			PHY_INTERFACE_MODE_XGMII : PHY_INTERFACE_MODE_SGMII;
+
+		dev_dbg(mac_cb->dev, "mac_id=%d, phy_if=%d\n", mac_id, phy_if);
+
+		ACPI_FREE(obj);
 	}
 
 	return phy_if;
@@ -380,6 +469,30 @@ int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
 			dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10,
 					   10, !!en);
 		}
+	} else if (is_acpi_device_node(dsaf_dev->dev->fwnode)) {
+		union acpi_object *obj;
+		union acpi_object obj_args[3], argv4;
+
+		obj_args[0].integer.type = ACPI_TYPE_INTEGER;
+		obj_args[0].integer.value = mac_cb->mac_id;
+		obj_args[1].integer.type = ACPI_TYPE_INTEGER;
+		obj_args[1].integer.value = !!en;
+
+		argv4.type = ACPI_TYPE_PACKAGE;
+		argv4.package.count = 2;
+		argv4.package.elements = obj_args;
+
+		obj = acpi_evaluate_dsm(ACPI_HANDLE(dsaf_dev->dev),
+					hns_dsaf_acpi_dsm_uuid, 0,
+					HNS_OP_SERDES_LP_FUNC, &argv4);
+		if (!obj) {
+			dev_warn(dsaf_dev->dev, "set port%d serdes lp fail!",
+				 mac_cb->mac_id);
+
+			return -ENOTSUPP;
+		}
+
+		ACPI_FREE(obj);
 	}
 
 	return 0;
-- 
1.9.1
