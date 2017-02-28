From: Alban Bedel <alban.bedel@avionic-design.de>
Subject: [PATCH] drivers: net: xgene: Fix crash on DT systems
Date: Tue, 28 Feb 2017 18:08:55 +0100
Message-ID: <20170228170855.8123-1-alban.bedel@avionic-design.de>
Cc: Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>, linux-kernel@vger.kernel.org,
        Alban Bedel <alban.bedel@avionic-design.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:63111 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdB1SDa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 13:03:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On DT systems the driver require a clock, but the probe just print a
warning and continue, leading to a crash when resetting the device.
To fix this crash and properly handle probe deferals only ignore the
missing clock if DT isn't used or if the clock doesn't exist.

Signed-off-by: Alban Bedel <alban.bedel@avionic-design.de>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d0d0d12b531f..68b48edc5921 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1756,6 +1756,12 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
+		/* Abort if the clock is defined but couldn't be retrived.
+		 * Always abort if the clock is missing on DT system as
+		 * the driver can't cope with this case.
+		 */
+		if (PTR_ERR(pdata->clk) != -ENOENT || dev->of_node)
+			return PTR_ERR(pdata->clk);
 		/* Firmware may have set up the clock already. */
 		dev_info(dev, "clocks have been setup already\n");
 	}
-- 
2.11.0
