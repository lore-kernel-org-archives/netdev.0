From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v4 net-next 05/13] net: hns: use device_* APIs instead of of_* APIs
Date: Fri, 3 Jun 2016 10:55:13 +0800
Message-ID: <1464922521-30928-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

OF series functions can be used only for DT case. Use unified
device property function instead to support both DT and ACPI.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  9 +++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 11 +++--------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 1c2ddb2..9afc5e6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -50,7 +50,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	else
 		dsaf_dev->dsaf_ver = AE_VERSION_2;
 
-	ret = of_property_read_string(np, "mode", &mode_str);
+	ret = device_property_read_string(dsaf_dev->dev, "mode", &mode_str);
 	if (ret) {
 		dev_err(dsaf_dev->dev, "get dsaf mode fail, ret=%d!\n", ret);
 		return ret;
@@ -142,7 +142,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		}
 	}
 
-	ret = of_property_read_u32(np, "desc-num", &desc_num);
+	ret = device_property_read_u32(dsaf_dev->dev, "desc-num", &desc_num);
 	if (ret < 0 || desc_num < HNS_DSAF_MIN_DESC_CNT ||
 	    desc_num > HNS_DSAF_MAX_DESC_CNT) {
 		dev_err(dsaf_dev->dev, "get desc-num(%d) fail, ret=%d!\n",
@@ -151,14 +151,15 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	}
 	dsaf_dev->desc_num = desc_num;
 
-	ret = of_property_read_u32(np, "reset-field-offset", &reset_offset);
+	ret = device_property_read_u32(dsaf_dev->dev, "reset-field-offset",
+				       &reset_offset);
 	if (ret < 0) {
 		dev_dbg(dsaf_dev->dev,
 			"get reset-field-offset fail, ret=%d!\r\n", ret);
 	}
 	dsaf_dev->reset_offset = reset_offset;
 
-	ret = of_property_read_u32(np, "buf-size", &buf_size);
+	ret = device_property_read_u32(dsaf_dev->dev, "buf-size", &buf_size);
 	if (ret < 0) {
 		dev_err(dsaf_dev->dev,
 			"get buf-size fail, ret=%d!\r\n", ret);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index e621636..8851420 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1067,13 +1067,8 @@ void hns_nic_update_stats(struct net_device *netdev)
 static void hns_init_mac_addr(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
-	struct device_node *node = priv->dev->of_node;
-	const void *mac_addr_temp;
 
-	mac_addr_temp = of_get_mac_address(node);
-	if (mac_addr_temp && is_valid_ether_addr(mac_addr_temp)) {
-		memcpy(ndev->dev_addr, mac_addr_temp, ndev->addr_len);
-	} else {
+	if (!device_get_mac_address(priv->dev, ndev->dev_addr, ETH_ALEN)) {
 		eth_hw_addr_random(ndev);
 		dev_warn(priv->dev, "No valid mac, use random mac %pM",
 			 ndev->dev_addr);
@@ -1898,10 +1893,10 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 		goto out_read_prop_fail;
 	}
 	/* try to find port-idx-in-ae first */
-	ret = of_property_read_u32(node, "port-idx-in-ae", &port_id);
+	ret = device_property_read_u32(dev, "port-idx-in-ae", &port_id);
 	if (ret) {
 		/* only for old code compatible */
-		ret = of_property_read_u32(node, "port-id", &port_id);
+		ret = device_property_read_u32(dev, "port-id", &port_id);
 		if (ret)
 			goto out_read_prop_fail;
 		/* for old dts, we need to caculate the port offset */
-- 
1.9.1
