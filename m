From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 04/16] net: ethernet: aurora: nb8800: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:24:57 +0100
Message-ID: <1480357509-28074-5-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger@opensource.altera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Li Yang <leoli@freescale.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Lars Persson <lars.persson@axis.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36295 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbcK1S12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:27:28 -0500
In-Reply-To: <1480357509-28074-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to deregister and free any fixed-link PHY registered using
of_phy_register_fixed_link() on probe errors and on driver unbind.

Fixes: c7dfe3abf40e ("net: ethernet: nb8800: support fixed-link DT
node")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/aurora/nb8800.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 00c38bf151e6..e078d8da978c 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1466,12 +1466,12 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	ret = nb8800_hw_init(dev);
 	if (ret)
-		goto err_free_bus;
+		goto err_deregister_fixed_link;
 
 	if (ops && ops->init) {
 		ret = ops->init(dev);
 		if (ret)
-			goto err_free_bus;
+			goto err_deregister_fixed_link;
 	}
 
 	dev->netdev_ops = &nb8800_netdev_ops;
@@ -1504,6 +1504,9 @@ static int nb8800_probe(struct platform_device *pdev)
 
 err_free_dma:
 	nb8800_dma_free(dev);
+err_deregister_fixed_link:
+	if (of_phy_is_fixed_link(pdev->dev.of_node))
+		of_phy_deregister_fixed_link(pdev->dev.of_node);
 err_free_bus:
 	of_node_put(priv->phy_node);
 	mdiobus_unregister(bus);
@@ -1521,6 +1524,8 @@ static int nb8800_remove(struct platform_device *pdev)
 	struct nb8800_priv *priv = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
+	if (of_phy_is_fixed_link(pdev->dev.of_node))
+		of_phy_deregister_fixed_link(pdev->dev.of_node);
 	of_node_put(priv->phy_node);
 
 	mdiobus_unregister(priv->mii_bus);
-- 
2.7.3
