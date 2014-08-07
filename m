From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: mvneta: Fix reference counting for phy_node
Date: Thu,  7 Aug 2014 21:58:46 +0200
Message-ID: <1407441526-25711-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33666 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaHGT64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 15:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is a "phy" handle the probe function returns with holding a
reference to that node. Make sure that in the fixed phy case there is
also held a reference to yield a consistant state.

Also add the corresponding of_node_put in the error path and the remove
function.

=46ixes: 83895bedeee6 ("net: mvneta: add support for fixed links")
=46ixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP n=
etwork unit")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/marvell/mvneta.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethern=
et/marvell/mvneta.c
index dadd9a5f6323..c9f1d1b7ef37 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2969,14 +2969,14 @@ static int mvneta_probe(struct platform_device =
*pdev)
 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
 		 */
-		phy_node =3D dn;
+		phy_node =3D of_node_get(dn);
 	}
=20
 	phy_mode =3D of_get_phy_mode(dn);
 	if (phy_mode < 0) {
 		dev_err(&pdev->dev, "incorrect phy-mode\n");
 		err =3D -EINVAL;
-		goto err_free_irq;
+		goto err_put_phy_node;
 	}
=20
 	dev->tx_queue_len =3D MVNETA_MAX_TXD;
@@ -2992,7 +2992,7 @@ static int mvneta_probe(struct platform_device *p=
dev)
 	pp->clk =3D devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
 		err =3D PTR_ERR(pp->clk);
-		goto err_free_irq;
+		goto err_put_phy_node;
 	}
=20
 	clk_prepare_enable(pp->clk);
@@ -3071,6 +3071,8 @@ err_free_stats:
 	free_percpu(pp->stats);
 err_clk:
 	clk_disable_unprepare(pp->clk);
+err_put_phy_node:
+	of_node_put(phy_node);
 err_free_irq:
 	irq_dispose_mapping(dev->irq);
 err_free_netdev:
@@ -3088,6 +3090,7 @@ static int mvneta_remove(struct platform_device *=
pdev)
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->stats);
 	irq_dispose_mapping(dev->irq);
+	of_node_put(pp->phy_node);
 	free_netdev(dev);
=20
 	return 0;
--=20
2.0.1
