From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/4] net/cpsw: make sure modules remove does not leak any ressources
Date: Wed, 24 Apr 2013 20:48:23 +0200
Message-ID: <1366829305-9752-3-git-send-email-bigeasy@linutronix.de>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41169 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757357Ab3DXSsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:48:36 -0400
In-Reply-To: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver does not clean up properly after leaving. Here is a list:
- Use unregister_netdev(). free_netdev() is good but not enough
- Use the above also on the other ndev in case of dual mac
- Free data.slave_data. The name of the strucre makes it look like
  it is platform_data but it is not. It is just a trick!
- Free all irqs. Again: freeing one irq is good start, but freeing all
  of them is better.

With this rmmod & modprobe of cpsw seems to work. The remaining issue
is:
|WARNING: at fs/sysfs/dir.c:536 sysfs_add_one+0x9c/0xd4()
|sysfs: cannot create duplicate filename '/devices/ocp.2/4a100000.ethernet/4a101000.mdio'
|WARNING: at lib/kobject.c:196 kobject_add_internal+0x1a4/0x1c8()

comming from of_platform_populate() and I am not sure that this belongs
here.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f91c8ab..1983f23 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1636,7 +1636,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 
 static int cpsw_probe(struct platform_device *pdev)
 {
-	struct cpsw_platform_data	*data = pdev->dev.platform_data;
+	struct cpsw_platform_data	*data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv;
 	struct cpdma_params		dma_params;
@@ -1849,7 +1849,7 @@ static int cpsw_probe(struct platform_device *pdev)
 				goto clean_ale_ret;
 			}
 			priv->irqs_table[k] = i;
-			priv->num_irqs = k;
+			priv->num_irqs = k + 1;
 		}
 		k++;
 	}
@@ -1887,7 +1887,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	return 0;
 
 clean_irq_ret:
-	free_irq(ndev->irq, priv);
+	for (i = 0; i < priv->num_irqs; i++)
+		free_irq(priv->irqs_table[i], priv);
 clean_ale_ret:
 	cpsw_ale_destroy(priv->ale);
 clean_dma_ret:
@@ -1910,7 +1911,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	pm_runtime_disable(&pdev->dev);
 	kfree(priv->slaves);
 clean_ndev_ret:
-	free_netdev(ndev);
+	kfree(priv->data.slave_data);
+	free_netdev(priv->ndev);
 	return ret;
 }
 
@@ -1918,12 +1920,17 @@ static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int i;
 
-	pr_info("removing device");
 	platform_set_drvdata(pdev, NULL);
+	if (priv->data.dual_emac)
+		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
+	unregister_netdev(ndev);
 
 	cpts_unregister(priv->cpts);
-	free_irq(ndev->irq, priv);
+	for (i = 0; i < priv->num_irqs; i++)
+		free_irq(priv->irqs_table[i], priv);
+
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
 	cpdma_chan_destroy(priv->rxch);
@@ -1937,8 +1944,10 @@ static int cpsw_remove(struct platform_device *pdev)
 	pm_runtime_disable(&pdev->dev);
 	clk_put(priv->clk);
 	kfree(priv->slaves);
+	kfree(priv->data.slave_data);
+	if (priv->data.dual_emac)
+		free_netdev(cpsw_get_slave_ndev(priv, 1));
 	free_netdev(ndev);
-
 	return 0;
 }
 
-- 
1.7.10.4
