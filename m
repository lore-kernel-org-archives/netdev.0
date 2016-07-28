From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 3/4] drivers: net: cpsw: use of_platform_depopulate()
Date: Thu, 28 Jul 2016 20:50:36 +0300
Message-ID: <20160728175037.22053-4-grygorii.strashko@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:52895 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932725AbcG1Ruv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 13:50:51 -0400
In-Reply-To: <20160728175037.22053-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of_platform_depopulate() in cpsw_remove() instead of
of_device_unregister(), because CSPW child devices will not be
recreated otherwise on next insmod. of_platform_depopulate() is
correct way now as it will ensure that all steps done in
of_platform_populate() are reverted, including cleaning up of
OF_POPULATED flag.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ec6f473..f0ed470 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2566,15 +2566,6 @@ clean_ndev_ret:
 	return ret;
 }
 
-static int cpsw_remove_child_device(struct device *dev, void *c)
-{
-	struct platform_device *pdev = to_platform_device(dev);
-
-	of_device_unregister(pdev);
-
-	return 0;
-}
-
 static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -2593,7 +2584,7 @@ static int cpsw_remove(struct platform_device *pdev)
 
 	cpsw_ale_destroy(priv->ale);
 	cpdma_ctlr_destroy(priv->dma);
-	device_for_each_child(&pdev->dev, NULL, cpsw_remove_child_device);
+	of_platform_depopulate(&pdev->dev);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	if (priv->data.dual_emac)
-- 
2.9.2
