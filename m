From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 1/2] TI DaVinci EMAC: Add EMAC PHY clock handling.
Date: Thu, 11 Mar 2010 19:54:50 +0530
Message-ID: <1268317491-3822-2-git-send-email-srk@ti.com>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
Cc: nsekhar@ti.com, Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:41847 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937Ab0CKOY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 09:24:59 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id o2BEOu7u011083
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 08:24:58 -0600
In-Reply-To: <1268317491-3822-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Source for the EMAC PHY clock can be different from the
module clock and driver needs to request/enable the EMAC
phy clock explicitly. This was not required earlier as on
most Davinci platforms the phy clock is always on . On AM35x
platform the phy clock needs to be managed explicitly , hence
adding clock management for phy clock.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 drivers/net/davinci_emac.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 8a42dbe..d9ae6ee 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -491,6 +491,7 @@ struct emac_priv {
 
 /* clock frequency for EMAC */
 static struct clk *emac_clk;
+static struct clk *emac_phy_clk;
 static unsigned long emac_bus_frequency;
 static unsigned long mdio_max_freq;
 
@@ -2637,18 +2638,28 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	struct emac_platform_data *pdata;
 	struct device *emac_dev;
 
-	/* obtain emac clock from kernel */
-	emac_clk = clk_get(&pdev->dev, NULL);
+	/* obtain emac module clock from kernel */
+	emac_clk = clk_get(&pdev->dev, "emac_clk");
 	if (IS_ERR(emac_clk)) {
 		printk(KERN_ERR "DaVinci EMAC: Failed to get EMAC clock\n");
 		return -EBUSY;
 	}
+
+	/* obtain emac phy clock from kernel */
+	emac_phy_clk = clk_get(&pdev->dev, "phy_clk");
+	if (IS_ERR(emac_phy_clk)) {
+		printk(KERN_ERR "DaVinci EMAC: Failed to get PHY clock\n");
+		clk_put(emac_clk);
+		return -EBUSY;
+	}
+
 	emac_bus_frequency = clk_get_rate(emac_clk);
 	/* TODO: Probe PHY here if possible */
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
 	if (!ndev) {
 		printk(KERN_ERR "DaVinci EMAC: Error allocating net_device\n");
+		clk_put(emac_phy_clk);
 		clk_put(emac_clk);
 		return -ENOMEM;
 	}
@@ -2734,6 +2745,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
 
 	clk_enable(emac_clk);
+	clk_enable(emac_phy_clk);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -2783,6 +2795,7 @@ mdiobus_quit:
 
 netdev_reg_err:
 mdio_alloc_err:
+	clk_disable(emac_phy_clk);
 	clk_disable(emac_clk);
 no_irq_res:
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2790,6 +2803,7 @@ no_irq_res:
 	iounmap(priv->remap_addr);
 
 probe_quit:
+	clk_put(emac_phy_clk);
 	clk_put(emac_clk);
 	free_netdev(ndev);
 	return rc;
@@ -2821,7 +2835,9 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	free_netdev(ndev);
 	iounmap(priv->remap_addr);
 
+	clk_disable(emac_phy_clk);
 	clk_disable(emac_clk);
+	clk_put(emac_phy_clk);
 	clk_put(emac_clk);
 
 	return 0;
@@ -2835,6 +2851,7 @@ static int davinci_emac_suspend(struct device *dev)
 	if (netif_running(ndev))
 		emac_dev_stop(ndev);
 
+	clk_disable(emac_phy_clk);
 	clk_disable(emac_clk);
 
 	return 0;
@@ -2846,6 +2863,7 @@ static int davinci_emac_resume(struct device *dev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
 	clk_enable(emac_clk);
+	clk_enable(emac_phy_clk);
 
 	if (netif_running(ndev))
 		emac_dev_open(ndev);
-- 
1.6.2.4

