From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Fri, 28 Jul 2017 18:13:15 +0200
Message-ID: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:25028 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751633AbdG1QNV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 12:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_stop breaks RX in a way that ndo_open is unable to undo.
Work around the issue by resetting the HW in ndo_open.
This will provide the basis for suspend/resume support.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 40 +++++++++++++++++-------------------
 drivers/net/ethernet/aurora/nb8800.h |  1 +
 2 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index e94159507847..954a28542c3b 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -39,6 +39,7 @@
 
 #include "nb8800.h"
 
+static void nb8800_init(struct net_device *dev);
 static void nb8800_tx_done(struct net_device *dev);
 static int nb8800_dma_stop(struct net_device *dev);
 
@@ -957,6 +958,8 @@ static int nb8800_open(struct net_device *dev)
 	struct phy_device *phydev;
 	int err;
 
+	nb8800_init(dev);
+
 	/* clear any pending interrupts */
 	nb8800_writel(priv, NB8800_RXC_SR, 0xf);
 	nb8800_writel(priv, NB8800_TXC_SR, 0xf);
@@ -1350,6 +1353,20 @@ static const struct of_device_id nb8800_dt_ids[] = {
 };
 MODULE_DEVICE_TABLE(of, nb8800_dt_ids);
 
+static void nb8800_init(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	const struct nb8800_ops *ops = priv->ops;
+
+	if (ops && ops->reset)
+		ops->reset(dev);
+	nb8800_hw_init(dev);
+	if (ops && ops->init)
+		ops->init(dev);
+	nb8800_update_mac_addr(dev);
+	priv->speed = 0;
+}
+
 static int nb8800_probe(struct platform_device *pdev)
 {
 	const struct of_device_id *match;
@@ -1389,6 +1406,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 	priv->base = base;
+	priv->ops = ops;
 
 	priv->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (priv->phy_mode < 0)
@@ -1407,12 +1425,6 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->tx_lock);
 
-	if (ops && ops->reset) {
-		ret = ops->reset(dev);
-		if (ret)
-			goto err_disable_clk;
-	}
-
 	bus = devm_mdiobus_alloc(&pdev->dev);
 	if (!bus) {
 		ret = -ENOMEM;
@@ -1454,16 +1466,6 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv->mii_bus = bus;
 
-	ret = nb8800_hw_init(dev);
-	if (ret)
-		goto err_deregister_fixed_link;
-
-	if (ops && ops->init) {
-		ret = ops->init(dev);
-		if (ret)
-			goto err_deregister_fixed_link;
-	}
-
 	dev->netdev_ops = &nb8800_netdev_ops;
 	dev->ethtool_ops = &nb8800_ethtool_ops;
 	dev->flags |= IFF_MULTICAST;
@@ -1476,14 +1478,12 @@ static int nb8800_probe(struct platform_device *pdev)
 	if (!is_valid_ether_addr(dev->dev_addr))
 		eth_hw_addr_random(dev);
 
-	nb8800_update_mac_addr(dev);
-
 	netif_carrier_off(dev);
 
 	ret = register_netdev(dev);
 	if (ret) {
 		netdev_err(dev, "failed to register netdev\n");
-		goto err_free_dma;
+		goto err_deregister_fixed_link;
 	}
 
 	netif_napi_add(dev, &priv->napi, nb8800_poll, NAPI_POLL_WEIGHT);
@@ -1492,8 +1492,6 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	return 0;
 
-err_free_dma:
-	nb8800_dma_free(dev);
 err_deregister_fixed_link:
 	if (of_phy_is_fixed_link(pdev->dev.of_node))
 		of_phy_deregister_fixed_link(pdev->dev.of_node);
diff --git a/drivers/net/ethernet/aurora/nb8800.h b/drivers/net/ethernet/aurora/nb8800.h
index 6ec4a956e1e5..d5f4481a2c7b 100644
--- a/drivers/net/ethernet/aurora/nb8800.h
+++ b/drivers/net/ethernet/aurora/nb8800.h
@@ -305,6 +305,7 @@ struct nb8800_priv {
 	dma_addr_t			tx_desc_dma;
 
 	struct clk			*clk;
+	const struct nb8800_ops		*ops;
 };
 
 struct nb8800_ops {
-- 
2.11.0
