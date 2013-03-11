From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/2] fec: Use devm_request_and_ioremap()
Date: Mon, 11 Mar 2013 14:32:55 -0300
Message-ID: <1363023175-17597-2-git-send-email-fabio.estevam@freescale.com>
References: <1363023175-17597-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:40512
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752462Ab3CKRdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 13:33:47 -0400
In-Reply-To: <1363023175-17597-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using devm_request_and_ioremap() can make the code cleaner and simpler.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 89c27e6..559b3d9 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1733,16 +1733,10 @@ fec_probe(struct platform_device *pdev)
 	if (!r)
 		return -ENXIO;
 
-	r = request_mem_region(r->start, resource_size(r), pdev->name);
-	if (!r)
-		return -EBUSY;
-
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
-	if (!ndev) {
-		ret = -ENOMEM;
-		goto failed_alloc_etherdev;
-	}
+	if (!ndev)
+		return -ENOMEM;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
@@ -1754,7 +1748,7 @@ fec_probe(struct platform_device *pdev)
 	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
 
-	fep->hwp = ioremap(r->start, resource_size(r));
+	fep->hwp = devm_request_and_ioremap(&pdev->dev, r);
 	fep->pdev = pdev;
 	fep->dev_id = dev_id++;
 
@@ -1876,11 +1870,8 @@ failed_regulator:
 		clk_disable_unprepare(fep->clk_ptp);
 failed_pin:
 failed_clk:
-	iounmap(fep->hwp);
 failed_ioremap:
 	free_netdev(ndev);
-failed_alloc_etherdev:
-	release_mem_region(r->start, resource_size(r));
 
 	return ret;
 }
@@ -1890,7 +1881,6 @@ fec_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct resource *r;
 	int i;
 
 	unregister_netdev(ndev);
@@ -1906,13 +1896,8 @@ fec_drv_remove(struct platform_device *pdev)
 		if (irq > 0)
 			free_irq(irq, ndev);
 	}
-	iounmap(fep->hwp);
 	free_netdev(ndev);
 
-	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	BUG_ON(!r);
-	release_mem_region(r->start, resource_size(r));
-
 	platform_set_drvdata(pdev, NULL);
 
 	return 0;
-- 
1.7.9.5
