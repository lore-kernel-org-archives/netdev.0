From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 2/6] net: davinci_emac: Fix runtime pm calls for davinci_emac
Date: Thu, 15 Jan 2015 14:45:10 -0800
Message-ID: <1421361914-4612-3-git-send-email-tony@atomide.com>
References: <1421361914-4612-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421361914-4612-1-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support")
added support for runtime PM, but it causes issues on omap3 related devices
that actually gate the clocks:

Unhandled fault: external abort on non-linefetch (0x1008)
...
[<c04160f0>] (emac_dev_getnetstats) from [<c04d6a3c>] (dev_get_stats+0x78/0xc8)
[<c04d6a3c>] (dev_get_stats) from [<c04e9ccc>] (rtnl_fill_ifinfo+0x3b8/0x938)
[<c04e9ccc>] (rtnl_fill_ifinfo) from [<c04eade4>] (rtmsg_ifinfo+0x68/0xd8)
[<c04eade4>] (rtmsg_ifinfo) from [<c04dd35c>] (register_netdevice+0x3a0/0x4ec)
[<c04dd35c>] (register_netdevice) from [<c04dd4bc>] (register_netdev+0x14/0x24)
[<c04dd4bc>] (register_netdev) from [<c041755c>] (davinci_emac_probe+0x408/0x5c8)
[<c041755c>] (davinci_emac_probe) from [<c0396d78>] (platform_drv_probe+0x48/0xa4)

Let's fix it by moving the pm_runtime_get() call earlier, and also add it to
the emac_dev_getnetstats(). Also note that we want to use pm_runtime_get_sync()
as we don't want to have deferred_resume happen. And let's also check the
return value for pm_runtime_get_sync() as noted by Felipe Balbi <balbi@ti.com>.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Acked-by: Mark A. Greer <mgreer@animalcreek.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 33 +++++++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 383ed52..5df339e 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1538,7 +1538,13 @@ static int emac_dev_open(struct net_device *ndev)
 	int i = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
 
-	pm_runtime_get(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		dev_err(&priv->pdev->dev, "%s: failed to get_sync(%d)\n",
+			__func__, ret);
+		return ret;
+	}
 
 	netif_carrier_off(ndev);
 	for (cnt = 0; cnt < ETH_ALEN; cnt++)
@@ -1725,6 +1731,15 @@ static struct net_device_stats *emac_dev_getnetstats(struct net_device *ndev)
 	struct emac_priv *priv = netdev_priv(ndev);
 	u32 mac_control;
 	u32 stats_clear_mask;
+	int err;
+
+	err = pm_runtime_get_sync(&priv->pdev->dev);
+	if (err < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		dev_err(&priv->pdev->dev, "%s: failed to get_sync(%d)\n",
+			__func__, err);
+		return &ndev->stats;
+	}
 
 	/* update emac hardware stats and reset the registers*/
 
@@ -1767,6 +1782,8 @@ static struct net_device_stats *emac_dev_getnetstats(struct net_device *ndev)
 	ndev->stats.tx_fifo_errors += emac_read(EMAC_TXUNDERRUN);
 	emac_write(EMAC_TXUNDERRUN, stats_clear_mask);
 
+	pm_runtime_put(&priv->pdev->dev);
+
 	return &ndev->stats;
 }
 
@@ -1981,12 +1998,22 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &ethtool_ops;
 	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
 
+	pm_runtime_enable(&pdev->dev);
+	rc = pm_runtime_get_sync(&pdev->dev);
+	if (rc < 0) {
+		pm_runtime_put_noidle(&pdev->dev);
+		dev_err(&pdev->dev, "%s: failed to get_sync(%d)\n",
+			__func__, rc);
+		goto no_cpdma_chan;
+	}
+
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	rc = register_netdev(ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "error in register_netdev\n");
 		rc = -ENODEV;
+		pm_runtime_put(&pdev->dev);
 		goto no_cpdma_chan;
 	}
 
@@ -1996,9 +2023,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 			   "(regs: %p, irq: %d)\n",
 			   (void *)priv->emac_base_phys, ndev->irq);
 	}
-
-	pm_runtime_enable(&pdev->dev);
-	pm_runtime_resume(&pdev->dev);
+	pm_runtime_put(&pdev->dev);
 
 	return 0;
 
-- 
2.1.4

