From: weiyj_lk@163.com
Subject: [PATCH -next] net: hns: fix return value check in hns_dsaf_get_cfg()
Date: Mon,  4 Jul 2016 15:00:58 +0000
Message-ID: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
	Salil Mehta <salil.mehta@huawei.com>,
	Kejian Yan <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:51751 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbcGDPBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 11:01:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, function devm_ioremap_resource() returns ERR_PTR()
and never returns NULL. The NULL test in the return value check should
be replaced with IS_ERR().
Also removed unneeded error handling on the result of call to
platform_get_resource() and redundant dev_err call.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 49 +++++-----------------
 1 file changed, 10 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 86ce28a..b09d56a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -107,68 +107,39 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		if (IS_ERR_OR_NULL(syscon)) {
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
 						    res_idx++);
-			if (!res) {
-				dev_err(dsaf_dev->dev, "subctrl info is needed!\n");
-				return -ENOMEM;
-			}
-
 			dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev,
 								  res);
-			if (!dsaf_dev->sc_base) {
-				dev_err(dsaf_dev->dev, "subctrl can not map!\n");
-				return -ENOMEM;
-			}
+			if (IS_ERR(dsaf_dev->sc_base))
+				return PTR_ERR(dsaf_dev->sc_base);
 
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
 						    res_idx++);
-			if (!res) {
-				dev_err(dsaf_dev->dev, "serdes-ctrl info is needed!\n");
-				return -ENOMEM;
-			}
-
 			dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev,
 								   res);
-			if (!dsaf_dev->sds_base) {
-				dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
-				return -ENOMEM;
-			}
+			if (IS_ERR(dsaf_dev->sds_base))
+				return PTR_ERR(dsaf_dev->sds_base);
 		} else {
 			dsaf_dev->sub_ctrl = syscon;
 		}
 	}
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ppe-base");
-	if (!res) {
+	if (!res)
 		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
-		if (!res) {
-			dev_err(dsaf_dev->dev, "ppe-base info is needed!\n");
-			return -ENOMEM;
-		}
-	}
 	dsaf_dev->ppe_base = devm_ioremap_resource(&pdev->dev, res);
-	if (!dsaf_dev->ppe_base) {
-		dev_err(dsaf_dev->dev, "ppe-base resource can not map!\n");
-		return -ENOMEM;
-	}
+	if (IS_ERR(dsaf_dev->ppe_base))
+		return PTR_ERR(dsaf_dev->ppe_base);
 	dsaf_dev->ppe_paddr = res->start;
 
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 						   "dsaf-base");
-		if (!res) {
+		if (!res)
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
 						    res_idx);
-			if (!res) {
-				dev_err(dsaf_dev->dev,
-					"dsaf-base info is needed!\n");
-				return -ENOMEM;
-			}
-		}
 		dsaf_dev->io_base = devm_ioremap_resource(&pdev->dev, res);
-		if (!dsaf_dev->io_base) {
-			dev_err(dsaf_dev->dev, "dsaf-base resource can not map!\n");
-			return -ENOMEM;
-		}
+		if (IS_ERR(dsaf_dev->io_base))
+			return PTR_ERR(dsaf_dev->io_base);
 	}
 
 	ret = device_property_read_u32(dsaf_dev->dev, "desc-num", &desc_num);
