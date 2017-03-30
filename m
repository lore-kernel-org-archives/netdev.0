From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net] net: hns: Add ACPI support to check SFP present
Date: Thu, 30 Mar 2017 16:37:41 +0100
Message-ID: <20170330153741.13528-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:4832 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S933979AbdC3PiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 11:38:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

The current code only supports DT to check SFP present.
This patch adds ACPI support as well.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 11 +++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 28 +++++++++++++++++++++-
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 696f2ae..0c1f56e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -82,9 +82,12 @@ void hns_mac_get_link_status(struct hns_mac_cb *mac_cb, u32 *link_status)
 	else
 		*link_status = 0;
 
-	ret = mac_cb->dsaf_dev->misc_op->get_sfp_prsnt(mac_cb, &sfp_prsnt);
-	if (!ret)
-		*link_status = *link_status && sfp_prsnt;
+	if (mac_cb->media_type == HNAE_MEDIA_TYPE_FIBER) {
+		ret = mac_cb->dsaf_dev->misc_op->get_sfp_prsnt(mac_cb,
+							       &sfp_prsnt);
+		if (!ret)
+			*link_status = *link_status && sfp_prsnt;
+	}
 
 	mac_cb->link = *link_status;
 }
@@ -816,7 +819,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		of_node_put(np);
 
 		np = of_parse_phandle(to_of_node(mac_cb->fw_port),
-					"serdes-syscon", 0);
+				      "serdes-syscon", 0);
 		syscon = syscon_node_to_regmap(np);
 		of_node_put(np);
 		if (IS_ERR_OR_NULL(syscon)) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a2c22d0..e13aa06 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -461,6 +461,32 @@ int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
 	return 0;
 }
 
+int hns_mac_get_sfp_prsnt_acpi(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
+{
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
+				HNS_OP_GET_SFP_STAT_FUNC, &argv4);
+
+	if (!obj || obj->type != ACPI_TYPE_INTEGER)
+		return -ENODEV;
+
+	*sfp_prsnt = obj->integer.value;
+
+	ACPI_FREE(obj);
+
+	return 0;
+}
+
 /**
  * hns_mac_config_sds_loopback - set loop back for serdes
  * @mac_cb: mac control block
@@ -592,7 +618,7 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 		misc_op->hns_dsaf_roce_srst = hns_dsaf_roce_srst_acpi;
 
 		misc_op->get_phy_if = hns_mac_get_phy_if_acpi;
-		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
+		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt_acpi;
 
 		misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback_acpi;
 	} else {
-- 
2.7.4
