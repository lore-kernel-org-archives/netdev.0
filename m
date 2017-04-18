From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 2/3] net: hns: support deferred probe when no mdio
Date: Tue, 18 Apr 2017 18:12:33 +0800
Message-ID: <1492510354-11300-3-git-send-email-yankejian@huawei.com>
References: <1492510354-11300-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <allenhuangsz10@gmail.com>,
        <lipeng321@huawei.com>, <huangdaode@hisilicon.com>,
        <hjat.hejun@huawei.com>, <zhangping5@huawei.com>,
        <qichengming@huawei.com>, <qumingguang@hisilicon.com>,
        <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5773 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754926AbdDRJw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 05:52:28 -0400
In-Reply-To: <1492510354-11300-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

In the hip06 and hip07 SoCs, phy connect to mdio bus.The mdio
module is probed with module_init, and, as such,
is not guaranteed to probe before the HNS driver. So we need
to support deferred probe.

We check for probe deferral in the mac init, so we not init DSAF
when there is no mdio, and free all resource, to later learn that
we need to defer the probe.

Signed-off-by: lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 34 +++++++++++++++++++----
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index bdd8cdd..284ebfe 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -735,6 +735,8 @@ static int hns_mac_init_ex(struct hns_mac_cb *mac_cb)
 	rc = phy_device_register(phy);
 	if (rc) {
 		phy_device_free(phy);
+		dev_err(&mdio->dev, "registered phy fail at address %i\n",
+			addr);
 		return -ENODEV;
 	}
 
@@ -745,7 +747,7 @@ static int hns_mac_init_ex(struct hns_mac_cb *mac_cb)
 	return 0;
 }
 
-static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
+static int hns_mac_register_phy(struct hns_mac_cb *mac_cb)
 {
 	struct acpi_reference_args args;
 	struct platform_device *pdev;
@@ -755,24 +757,39 @@ static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
 
 	/* Loop over the child nodes and register a phy_device for each one */
 	if (!to_acpi_device_node(mac_cb->fw_port))
-		return;
+		return 0;
 
 	rc = acpi_node_get_property_reference(
 			mac_cb->fw_port, "mdio-node", 0, &args);
 	if (rc)
-		return;
+		return 0;
 
 	addr = hns_mac_phy_parse_addr(mac_cb->dev, mac_cb->fw_port);
 	if (addr < 0)
-		return;
+		return 0;
 
 	/* dev address in adev */
 	pdev = hns_dsaf_find_platform_device(acpi_fwnode_handle(args.adev));
+	if (!pdev) {
+		dev_err(mac_cb->dev, "mac%d mdio pdev is NULL\n",
+			mac_cb->mac_id);
+		return 0;
+	}
+
 	mii_bus = platform_get_drvdata(pdev);
+	if (!mii_bus) {
+		dev_err(mac_cb->dev,
+			"mac%d mdio is NULL, dsaf will probe again later\n",
+			mac_cb->mac_id);
+		return -EPROBE_DEFER;
+	}
+
 	rc = hns_mac_register_phydev(mii_bus, mac_cb, addr);
 	if (!rc)
 		dev_dbg(mac_cb->dev, "mac%d register phy addr:%d\n",
 			mac_cb->mac_id, addr);
+
+	return rc;
 }
 
 #define MAC_MEDIA_TYPE_MAX_LEN		16
@@ -793,7 +810,7 @@ static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
  *@np:device node
  * return: 0 --success, negative --fail
  */
-static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
+static int hns_mac_get_info(struct hns_mac_cb *mac_cb)
 {
 	struct device_node *np;
 	struct regmap *syscon;
@@ -903,7 +920,10 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 			}
 		}
 	} else if (is_acpi_node(mac_cb->fw_port)) {
-		hns_mac_register_phy(mac_cb);
+		ret = hns_mac_register_phy(mac_cb);
+
+		if (ret)
+			return ret;
 	} else {
 		dev_err(mac_cb->dev, "mac%d cannot find phy node\n",
 			mac_cb->mac_id);
@@ -1065,6 +1085,7 @@ int hns_mac_init(struct dsaf_device *dsaf_dev)
 			dsaf_dev->mac_cb[port_id] = mac_cb;
 		}
 	}
+
 	/* init mac_cb for all port */
 	for (port_id = 0; port_id < max_port_num; port_id++) {
 		mac_cb = dsaf_dev->mac_cb[port_id];
@@ -1074,6 +1095,7 @@ int hns_mac_init(struct dsaf_device *dsaf_dev)
 		ret = hns_mac_get_cfg(dsaf_dev, mac_cb);
 		if (ret)
 			return ret;
+
 		ret = hns_mac_init_ex(mac_cb);
 		if (ret)
 			return ret;
-- 
1.9.1
