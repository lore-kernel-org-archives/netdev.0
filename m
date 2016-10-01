From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: qcom/emac: fix return value check in emac_sgmii_config()
Date: Sat,  1 Oct 2016 09:12:29 +0000
Message-ID: <1475313149-15233-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36342 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbcJAJMf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 05:12:35 -0400
Received: by mail-pa0-f67.google.com with SMTP id cd13so4002013pac.3
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 02:12:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

In case of error, the function ioremap() returns NULL pointer
not ERR_PTR(). The IS_ERR() test in the return value check
should be replaced with NULL test.

Also add check for return value of platform_get_resource().

Fixes: 54e19bc74f33 ("net: qcom/emac: do not use devm on internal
phy pdev")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 3d2c05a..75c1b53 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -740,9 +740,14 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 
 	/* Base address is the first address */
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		ret = -EINVAL;
+		goto error_put_device;
+	}
+
 	phy->base = ioremap(res->start, resource_size(res));
-	if (IS_ERR(phy->base)) {
-		ret = PTR_ERR(phy->base);
+	if (!phy->base) {
+		ret = -ENOMEM;
 		goto error_put_device;
 	}
 
@@ -750,8 +755,8 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 1);
 	if (res) {
 		phy->digital = ioremap(res->start, resource_size(res));
-		if (IS_ERR(phy->digital)) {
-			ret = PTR_ERR(phy->digital);
+		if (!phy->digital) {
+			ret = -ENOMEM;
 			goto error_unmap_base;
 		}
 	}
