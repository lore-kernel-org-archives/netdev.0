From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 05/13] net: ethernet: ti: cpsw: don't check slave num in runtime
Date: Wed, 10 Aug 2016 02:22:36 +0300
Message-ID: <1470784964-26440-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to check const slave num in runtime for every packet,
and ndev for slaves w/o ndev is anyway NULL. So remove redundant
check and macro.

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0b6958d..cfbb1f2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -497,9 +497,6 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 					n; n--)				\
 				(func)(slave++, ##arg);			\
 	} while (0)
-#define cpsw_get_slave_ndev(priv, __slave_no__)				\
-	((__slave_no__ < priv->data.slaves) ?				\
-		priv->slaves[__slave_no__].ndev : NULL)
 #define cpsw_get_slave_priv(priv, __slave_no__)				\
 	(((__slave_no__ < priv->data.slaves) &&				\
 		(priv->slaves[__slave_no__].ndev)) ?			\
@@ -510,11 +507,11 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 		if (!priv->data.dual_emac)				\
 			break;						\
 		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
-			ndev = cpsw_get_slave_ndev(priv, 0);		\
+			ndev = priv->slaves[0].ndev;			\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
-			ndev = cpsw_get_slave_ndev(priv, 1);		\
+			ndev = priv->slaves[1].ndev;			\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		}							\
@@ -2561,7 +2558,7 @@ static int cpsw_remove(struct platform_device *pdev)
 	}
 
 	if (priv->data.dual_emac)
-		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
+		unregister_netdev(priv->slaves[1].ndev);
 	unregister_netdev(ndev);
 
 	cpsw_ale_destroy(priv->ale);
@@ -2570,7 +2567,7 @@ static int cpsw_remove(struct platform_device *pdev)
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	if (priv->data.dual_emac)
-		free_netdev(cpsw_get_slave_ndev(priv, 1));
+		free_netdev(priv->slaves[1].ndev);
 	free_netdev(ndev);
 	return 0;
 }
-- 
1.9.1
