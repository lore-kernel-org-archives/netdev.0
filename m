From: Felipe Balbi <balbi@ti.com>
Subject: [PATCH 2/2] drivers: net: cpsw: fix for cpsw crash when build as modules
Date: Wed, 11 Dec 2013 22:09:05 -0600
Message-ID: <1386821345-30555-2-git-send-email-balbi@ti.com>
References: <1386821345-30555-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mugunthanvnm@ti.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:35118 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339Ab3LLEJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 23:09:48 -0500
In-Reply-To: <1386821345-30555-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>

When CPSW and Davinci MDIO are build as modules, CPSW crashes when
accessing CPSW registers in CPSW probe. The same is working in built-in
as the CPSW clocks are enabled in Davindi MDIO probe, SO Enabling the
clocks before accessing the version register and moving out the other
register access to cpsw device open.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a91f0c9..5120d9c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1151,6 +1151,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 * receive descs
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
+
+		if (cpts_register(&priv->pdev->dev, priv->cpts,
+				  priv->data.cpts_clock_mult,
+				  priv->data.cpts_clock_shift))
+			dev_err(priv->dev, "error registering cpts device\n");
+
 	}
 
 	/* Enable Interrupt pacing if configured */
@@ -1197,6 +1203,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_carrier_off(priv->ndev);
 
 	if (cpsw_common_res_usage_state(priv) <= 1) {
+		cpts_unregister(priv->cpts);
 		cpsw_intr_disable(priv);
 		cpdma_ctlr_int_ctrl(priv->dma, false);
 		cpdma_ctlr_stop(priv->dma);
@@ -1985,9 +1992,15 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 	priv->regs = ss_regs;
-	priv->version = __raw_readl(&priv->regs->id_ver);
 	priv->host_port = HOST_PORT_NUM;
 
+	/* Need to enable clocks with runtime PM api to access module
+	 * registers
+	 */
+	pm_runtime_get_sync(&pdev->dev);
+	priv->version = readl(&priv->regs->id_ver);
+	pm_runtime_put_sync(&pdev->dev);
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	priv->wr_regs = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(priv->wr_regs)) {
@@ -2157,8 +2170,6 @@ static int cpsw_remove(struct platform_device *pdev)
 		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
 	unregister_netdev(ndev);
 
-	cpts_unregister(priv->cpts);
-
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
 	cpdma_chan_destroy(priv->rxch);
-- 
1.8.4.GIT
