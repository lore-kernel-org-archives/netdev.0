From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH] TI DaVinci EMAC: Handle emac module clock correctly.
Date: Thu,  7 Jan 2010 15:52:37 +0530
Message-ID: <1262859757-2809-1-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:56928 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab0AGKWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 05:22:45 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id o07AMgl2025616
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 04:22:44 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the driver probe function the emac module clock needs to
be enabled before calling register_netdev(). As soon as the
device is registered the driver get_stats function can be invoked
by the core - the module clock must be switched on to be able to
read from stats registers. Also explicitly call matching clk_disable
for failure conditions in probe function.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
This patch has been generated against tip of net-2.6.git

 drivers/net/davinci_emac.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 34e0310..33c4fe2 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2711,6 +2711,8 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &ethtool_ops);
 	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
 
+	clk_enable(emac_clk);
+
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	rc = register_netdev(ndev);
@@ -2720,7 +2722,6 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 		goto netdev_reg_err;
 	}
 
-	clk_enable(emac_clk);
 
 	/* MII/Phy intialisation, mdio bus registration */
 	emac_mii = mdiobus_alloc();
@@ -2760,6 +2761,7 @@ mdiobus_quit:
 
 netdev_reg_err:
 mdio_alloc_err:
+	clk_disable(emac_clk);
 no_irq_res:
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, res->end - res->start + 1);
-- 
1.6.2.4

