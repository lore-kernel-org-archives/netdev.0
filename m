From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: [PATCH v3 2/2] net: ethernet: davinci_emac: add pm_runtime support
Date: Fri, 20 Jul 2012 18:19:22 -0700
Message-ID: <1342833562-3435-3-git-send-email-mgreer@animalcreek.com>
References: <1342833562-3435-1-git-send-email-mgreer@animalcreek.com>
Cc: linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"Mark A. Greer" <mgreer@animalcreek.com>,
	Sekhar Nori <nsekhar@ti.com>, Kevin Hilman <khilman@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1342833562-3435-1-git-send-email-mgreer@animalcreek.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mark A. Greer" <mgreer@animalcreek.com>

Add pm_runtime support to the TI Davinci EMAC driver.

CC: Sekhar Nori <nsekhar@ti.com>
CC: Kevin Hilman <khilman@ti.com>
Signed-off-by: Mark A. Greer <mgreer@animalcreek.com>
---
a) Sorry for the bad patch earlier.

b) Now applies on top of net-next.

c) This patch depends on a patch by Kevin Hilman that has been
   accepted for 3.6 and is waiting in arm-soc/for-next:
   ce9dcb8784611c50974d1c6b600c71f5c0a29308
   (ARM: davinci: add runtime PM support for clock management)

 drivers/net/ethernet/ti/davinci_emac.c | 43 +++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 1a9c43f..fce89a0 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -57,6 +57,7 @@
 #include <linux/bitops.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/pm_runtime.h>
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
@@ -353,10 +354,6 @@ struct emac_priv {
 	void (*int_disable) (void);
 };
 
-/* clock frequency for EMAC */
-static struct clk *emac_clk;
-static unsigned long emac_bus_frequency;
-
 /* EMAC TX Host Error description strings */
 static char *emac_txhost_errcodes[16] = {
 	"No error", "SOP error", "Ownership bit not set in SOP buffer",
@@ -1540,6 +1537,8 @@ static int emac_dev_open(struct net_device *ndev)
 	int k = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
 
+	pm_runtime_get(&priv->pdev->dev);
+
 	netif_carrier_off(ndev);
 	for (cnt = 0; cnt < ETH_ALEN; cnt++)
 		ndev->dev_addr[cnt] = priv->mac_addr[cnt];
@@ -1609,7 +1608,7 @@ static int emac_dev_open(struct net_device *ndev)
 				priv->phy_id);
 			ret = PTR_ERR(priv->phydev);
 			priv->phydev = NULL;
-			return ret;
+			goto err;
 		}
 
 		priv->link = 0;
@@ -1650,7 +1649,11 @@ rollback:
 		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
 		m = res->end;
 	}
-	return -EBUSY;
+
+	ret = -EBUSY;
+err:
+	pm_runtime_put(&priv->pdev->dev);
+	return ret;
 }
 
 /**
@@ -1692,6 +1695,7 @@ static int emac_dev_stop(struct net_device *ndev)
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: %s stopped\n", ndev->name);
 
+	pm_runtime_put(&priv->pdev->dev);
 	return 0;
 }
 
@@ -1856,6 +1860,9 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	struct emac_platform_data *pdata;
 	struct device *emac_dev;
 	struct cpdma_params dma_params;
+	struct clk *emac_clk;
+	unsigned long emac_bus_frequency;
+
 
 	/* obtain emac clock from kernel */
 	emac_clk = clk_get(&pdev->dev, NULL);
@@ -1864,12 +1871,14 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 		return -EBUSY;
 	}
 	emac_bus_frequency = clk_get_rate(emac_clk);
+	clk_put(emac_clk);
+
 	/* TODO: Probe PHY here if possible */
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
 	if (!ndev) {
 		rc = -ENOMEM;
-		goto free_clk;
+		goto no_ndev;
 	}
 
 	platform_set_drvdata(pdev, ndev);
@@ -1985,15 +1994,13 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &ethtool_ops);
 	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
 
-	clk_enable(emac_clk);
-
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	rc = register_netdev(ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "error in register_netdev\n");
 		rc = -ENODEV;
-		goto netdev_reg_err;
+		goto no_irq_res;
 	}
 
 
@@ -2002,10 +2009,12 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 			   "(regs: %p, irq: %d)\n",
 			   (void *)priv->emac_base_phys, ndev->irq);
 	}
+
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_resume(&pdev->dev);
+
 	return 0;
 
-netdev_reg_err:
-	clk_disable(emac_clk);
 no_irq_res:
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
@@ -2019,8 +2028,7 @@ no_dma:
 
 probe_quit:
 	free_netdev(ndev);
-free_clk:
-	clk_put(emac_clk);
+no_ndev:
 	return rc;
 }
 
@@ -2054,9 +2062,6 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	iounmap(priv->remap_addr);
 	free_netdev(ndev);
 
-	clk_disable(emac_clk);
-	clk_put(emac_clk);
-
 	return 0;
 }
 
@@ -2068,8 +2073,6 @@ static int davinci_emac_suspend(struct device *dev)
 	if (netif_running(ndev))
 		emac_dev_stop(ndev);
 
-	clk_disable(emac_clk);
-
 	return 0;
 }
 
@@ -2078,8 +2081,6 @@ static int davinci_emac_resume(struct device *dev)
 	struct platform_device *pdev = to_platform_device(dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
-	clk_enable(emac_clk);
-
 	if (netif_running(ndev))
 		emac_dev_open(ndev);
 
-- 
1.7.11.2

