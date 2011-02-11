From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 02/14] net/fec: release mem_region requested in probe in error path and remove
Date: Fri, 11 Feb 2011 11:32:10 +0100
Message-ID: <1297420342-17739-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45135 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854Ab1BKKcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:45 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3e6e923..b079826 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1377,8 +1377,10 @@ fec_probe(struct platform_device *pdev)
=20
 	/* Init network device */
 	ndev =3D alloc_etherdev(sizeof(struct fec_enet_private));
-	if (!ndev)
-		return -ENOMEM;
+	if (!ndev) {
+		ret =3D -ENOMEM;
+		goto failed_alloc_etherdev;
+	}
=20
 	SET_NETDEV_DEV(ndev, &pdev->dev);
=20
@@ -1456,6 +1458,8 @@ failed_irq:
 	iounmap((void __iomem *)ndev->base_addr);
 failed_ioremap:
 	free_netdev(ndev);
+failed_alloc_etherdev:
+	release_mem_region(r->start, resource_size(r));
=20
 	return ret;
 }
@@ -1465,6 +1469,7 @@ fec_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev =3D platform_get_drvdata(pdev);
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	struct resource *r;
=20
 	platform_set_drvdata(pdev, NULL);
=20
@@ -1475,6 +1480,11 @@ fec_drv_remove(struct platform_device *pdev)
 	iounmap((void __iomem *)ndev->base_addr);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
+
+	r =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	BUG_ON(!r);
+	release_mem_region(r->start, resource_size(r));
+
 	return 0;
 }
=20
--=20
1.7.2.3

