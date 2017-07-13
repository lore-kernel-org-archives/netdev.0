From: <liujian56@huawei.com>
Subject: [PATCH net] net: hns: add acpi function of xge led control
Date: Thu, 13 Jul 2017 18:57:54 +0800
Message-ID: <1499943474-13976-1-git-send-email-liujian56@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <netdev@vger.kernel.org>,
        <linuxarm@huawei.com>, <liujian56@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:9763 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdGMLCs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 07:02:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: LiuJian <liujian56@huawei.com>

The current code only support DT method to control xge led.
This patch is the implementation of acpi method to control xge led.

Signed-off-by: LiuJian <liujian56@huawei.com>
Reviewed-by: John Garry <john.garry@huawei.com>
Reviewed-by: Yunsheng Lin <linyunsheng@huawei.com>
Reviewed-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 58 +++++++++++++++++++++-
 2 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index ff864a1..a37166e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -776,8 +776,9 @@ void hns_ae_update_led_status(struct hnae_handle *handle)
 
 	assert(handle);
 	mac_cb = hns_get_mac_cb(handle);
-	if (!mac_cb->cpld_ctrl)
+	if (mac_cb->media_type != HNAE_MEDIA_TYPE_FIBER)
 		return;
+
 	hns_set_led_opt(mac_cb);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 7a8addd..408b63f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -53,6 +53,34 @@ static u32 dsaf_read_sub(struct dsaf_device *dsaf_dev, u32 reg)
 	return ret;
 }
 
+static void hns_dsaf_acpi_ledctrl_by_port(struct hns_mac_cb *mac_cb, u8 op_type,
+                                      u32 link, u32 port, u32 act)
+{
+       union acpi_object *obj;
+       union acpi_object obj_args[3], argv4;
+
+       obj_args[0].integer.type = ACPI_TYPE_INTEGER;
+       obj_args[0].integer.value = link;
+       obj_args[1].integer.type = ACPI_TYPE_INTEGER;
+       obj_args[1].integer.value = port;
+       obj_args[2].integer.type = ACPI_TYPE_INTEGER;
+       obj_args[2].integer.value = act;
+
+       argv4.type = ACPI_TYPE_PACKAGE;
+       argv4.package.count = 3;
+       argv4.package.elements = obj_args;
+
+       obj = acpi_evaluate_dsm(ACPI_HANDLE(mac_cb->dev),
+                               &hns_dsaf_acpi_dsm_guid, 0, op_type, &argv4);
+       if (!obj) {
+               dev_warn(mac_cb->dev, "ledctrl fail, link:%d port:%d act:%d!\n",
+                        link, port, act);
+               return;
+       }
+
+       ACPI_FREE(obj);
+}
+
 static void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 			     u16 speed, int data)
 {
@@ -93,6 +121,18 @@ static void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 	}
 }
 
+static void hns_cpld_set_led_acpi(struct hns_mac_cb *mac_cb, int link_status,
+                            u16 speed, int data)
+{
+       if (!mac_cb) {
+               pr_err("cpld_led_set mac_cb is null!\n");
+               return;
+       }
+
+       hns_dsaf_acpi_ledctrl_by_port(mac_cb, HNS_OP_LED_SET_FUNC,
+               link_status, mac_cb->mac_id, data);
+}
+
 static void cpld_led_reset(struct hns_mac_cb *mac_cb)
 {
 	if (!mac_cb || !mac_cb->cpld_ctrl)
@@ -103,6 +143,20 @@ static void cpld_led_reset(struct hns_mac_cb *mac_cb)
 	mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
 }
 
+static void cpld_led_reset_acpi(struct hns_mac_cb *mac_cb)
+{
+       if (!mac_cb) {
+               pr_err("cpld_led_reset mac_cb is null!\n");
+               return;
+       }
+
+       if (mac_cb->media_type != HNAE_MEDIA_TYPE_FIBER)
+                return;
+
+       hns_dsaf_acpi_ledctrl_by_port(mac_cb, HNS_OP_LED_SET_FUNC,
+               0, mac_cb->mac_id, 0);
+}
+
 static int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 			   enum hnae_led_state status)
 {
@@ -604,8 +658,8 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 
 		misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback;
 	} else if (is_acpi_node(dsaf_dev->dev->fwnode)) {
-		misc_op->cpld_set_led = hns_cpld_set_led;
-		misc_op->cpld_reset_led = cpld_led_reset;
+		misc_op->cpld_set_led = hns_cpld_set_led_acpi;
+		misc_op->cpld_reset_led = cpld_led_reset_acpi;
 		misc_op->cpld_set_led_id = cpld_set_led_id;
 
 		misc_op->dsaf_reset = hns_dsaf_rst_acpi;
-- 
2.5.0
