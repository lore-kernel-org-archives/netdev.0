From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net v2 1/3] net: hns: support deferred probe when can not obtain irq
Date: Fri, 21 Apr 2017 15:44:42 +0800
Message-ID: <1492760684-117205-2-git-send-email-yankejian@huawei.com>
References: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <lipeng321@huawei.com>,
        <huangdaode@hisilicon.com>, <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5377 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1035963AbdDUHYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 03:24:38 -0400
In-Reply-To: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

In the hip06 and hip07 SoCs, the interrupt lines from the
DSAF controllers are connected to mbigen hw module.
The mbigen module is probed with module_init, and, as such,
is not guaranteed to probe before the HNS driver. So we need
to support deferred probe.

We check for probe deferral in the hw layer probe, so we not
probe into the main layer and memories, etc., to later learn
that we need to defer the probe.

Signed-off-by: lipeng <lipeng321@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 403ea9d..2da5b42 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2971,6 +2971,18 @@ static int hns_dsaf_probe(struct platform_device *pdev)
 	struct dsaf_device *dsaf_dev;
 	int ret;
 
+	/*
+	 * Check if we should defer the probe before we probe the
+	 * dsaf, as it's hard to defer later on.
+	 */
+	ret = platform_get_irq(pdev, 0);
+	if (ret < 0) {
+		if (ret != -EPROBE_DEFER)
+			dev_err(&pdev->dev, "Cannot obtain irq\n");
+
+		return ret;
+	}
+
 	dsaf_dev = hns_dsaf_alloc_dev(&pdev->dev, sizeof(struct dsaf_drv_priv));
 	if (IS_ERR(dsaf_dev)) {
 		ret = PTR_ERR(dsaf_dev);
-- 
1.9.1
