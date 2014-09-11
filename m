From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: dual_emac: in suspend/resume bring down/up all the netdev
Date: Thu, 11 Sep 2014 22:52:38 +0530
Message-ID: <1410456158-6215-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53440 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbaIKRXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 13:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During suspend and resume in Dual EMAC, second port is not working as in
suspend/resume only the first slave netdev is closed and opened. So bring
down and up all the interfaces that are up during suspend/resume.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Tested-by: Nishanth Menon <nm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 411232f..e2a0028 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2334,10 +2334,19 @@ static int cpsw_suspend(struct device *dev)
 	struct net_device	*ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 
-	if (netif_running(ndev))
-		cpsw_ndo_stop(ndev);
+	if (priv->data.dual_emac) {
+		int i;
 
-	for_each_slave(priv, soft_reset_slave);
+		for (i = 0; i < priv->data.slaves; i++) {
+			if (netif_running(priv->slaves[i].ndev))
+				cpsw_ndo_stop(priv->slaves[i].ndev);
+			soft_reset_slave(priv->slaves + i);
+		}
+	} else {
+		if (netif_running(ndev))
+			cpsw_ndo_stop(ndev);
+		for_each_slave(priv, soft_reset_slave);
+	}
 
 	pm_runtime_put_sync(&pdev->dev);
 
@@ -2351,14 +2360,24 @@ static int cpsw_resume(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
+	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	pm_runtime_get_sync(&pdev->dev);
 
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	if (netif_running(ndev))
-		cpsw_ndo_open(ndev);
+	if (priv->data.dual_emac) {
+		int i;
+
+		for (i = 0; i < priv->data.slaves; i++) {
+			if (netif_running(priv->slaves[i].ndev))
+				cpsw_ndo_open(priv->slaves[i].ndev);
+		}
+	} else {
+		if (netif_running(ndev))
+			cpsw_ndo_open(ndev);
+	}
 	return 0;
 }
 
-- 
2.1.0
