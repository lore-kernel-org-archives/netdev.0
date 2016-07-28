From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 2/4] drivers: net: cpsw: fix wrong regs access in cpsw_remove
Date: Thu, 28 Jul 2016 20:50:35 +0300
Message-ID: <20160728175037.22053-3-grygorii.strashko@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:41533 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932692AbcG1Ruu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 13:50:50 -0400
In-Reply-To: <20160728175037.22053-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The L3 error will be generated and system will crash during unloading
of CPSW driver if CPSW is used as module and ethX devices are down.
This happens because CPSW can be power off by PM runtime now when ethX
devices are down.

Hence, ensure that CPSW powered up by PM runtime before performing any
deinitialization actions which require CPSW registers access. In case
of PM runtime error just leave cpsw_remove() as we can't do anything
anymore.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8f1eab9..ec6f473 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2579,6 +2579,13 @@ static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = pm_runtime_get_sync(&pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&pdev->dev);
+		return ret;
+	}
 
 	if (priv->data.dual_emac)
 		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
@@ -2586,8 +2593,9 @@ static int cpsw_remove(struct platform_device *pdev)
 
 	cpsw_ale_destroy(priv->ale);
 	cpdma_ctlr_destroy(priv->dma);
-	pm_runtime_disable(&pdev->dev);
 	device_for_each_child(&pdev->dev, NULL, cpsw_remove_child_device);
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
 	if (priv->data.dual_emac)
 		free_netdev(cpsw_get_slave_ndev(priv, 1));
 	free_netdev(ndev);
-- 
2.9.2
