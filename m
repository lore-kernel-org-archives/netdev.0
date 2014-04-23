From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: [PATCH 1/2] arc_emac: fix probe error path
Date: Wed, 23 Apr 2014 14:21:55 +0200
Message-ID: <2479609.DglKFY1Bsn@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, Max Schwarz <max.schwarz@online.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:33687 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356AbaDWMUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 08:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The probe function at the moment only frees the netdev but does not disconnect
the phy or removes the mdio bus it registered.

Signed-off-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/net/ethernet/arc/emac_main.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9f45782..0cba97a 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -683,7 +683,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	priv->regs = devm_ioremap_resource(&pdev->dev, &res_regs);
 	if (IS_ERR(priv->regs)) {
 		err = PTR_ERR(priv->regs);
-		goto out;
+		goto out_netdev;
 	}
 	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs);
 
@@ -693,7 +693,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
 		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
 		err = -ENODEV;
-		goto out;
+		goto out_netdev;
 	}
 	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
 
@@ -708,7 +708,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 			       ndev->name, ndev);
 	if (err) {
 		dev_err(&pdev->dev, "could not allocate IRQ\n");
-		goto out;
+		goto out_netdev;
 	}
 
 	/* Get MAC address from device tree */
@@ -729,7 +729,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!priv->rxbd) {
 		dev_err(&pdev->dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
-		goto out;
+		goto out_netdev;
 	}
 
 	priv->txbd = priv->rxbd + RX_BD_NUM;
@@ -741,7 +741,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	err = arc_mdio_probe(pdev, priv);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe MII bus\n");
-		goto out;
+		goto out_netdev;
 	}
 
 	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
@@ -749,7 +749,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!priv->phy_dev) {
 		dev_err(&pdev->dev, "of_phy_connect() failed\n");
 		err = -ENODEV;
-		goto out;
+		goto out_mdio;
 	}
 
 	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
@@ -761,12 +761,18 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (err) {
 		netif_napi_del(&priv->napi);
 		dev_err(&pdev->dev, "failed to register network device\n");
-		goto out;
+		goto out_netif_api;
 	}
 
 	return 0;
 
-out:
+out_netif_api:
+	netif_napi_del(&priv->napi);
+	phy_disconnect(priv->phy_dev);
+	priv->phy_dev = NULL;
+out_mdio:
+	arc_mdio_remove(priv);
+out_netdev:
 	free_netdev(ndev);
 	return err;
 }
-- 
1.9.0
