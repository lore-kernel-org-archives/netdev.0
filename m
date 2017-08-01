From: Mason <slash.tmp@free.fr>
Subject: [RFC PATCH v2 1/2] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Tue, 1 Aug 2017 18:37:15 +0200
Message-ID: <d817da35-f977-5985-4aae-73617004fac3@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:30746 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751755AbdHAQpO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:45:14 -0400
In-Reply-To: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all HW initializations to nb8800_init.
This provides the basis for suspend/resume support.
---
 drivers/net/ethernet/aurora/nb8800.c | 50 +++++++++++++++++-------------------
 drivers/net/ethernet/aurora/nb8800.h |  1 +
 2 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index e94159507847..aa18ea25d91f 100644
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
@@ -1246,11 +1249,6 @@ static int nb8800_hw_init(struct net_device *dev)
 	nb8800_writeb(priv, NB8800_PQ1, val >> 8);
 	nb8800_writeb(priv, NB8800_PQ2, val & 0xff);
 
-	/* Auto-negotiate by default */
-	priv->pause_aneg = true;
-	priv->pause_rx = true;
-	priv->pause_tx = true;
-
 	nb8800_mc_init(dev, 0);
 
 	return 0;
@@ -1350,6 +1348,20 @@ static const struct of_device_id nb8800_dt_ids[] = {
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
@@ -1389,6 +1401,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 	priv->base = base;
+	priv->ops = ops;
 
 	priv->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (priv->phy_mode < 0)
@@ -1407,12 +1420,6 @@ static int nb8800_probe(struct platform_device *pdev)
 
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
@@ -1454,21 +1461,16 @@ static int nb8800_probe(struct platform_device *pdev)
 
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
 	dev->irq = irq;
 
+	/* Auto-negotiate by default */
+	priv->pause_aneg = true;
+	priv->pause_rx = true;
+	priv->pause_tx = true;
+
 	mac = of_get_mac_address(pdev->dev.of_node);
 	if (mac)
 		ether_addr_copy(dev->dev_addr, mac);
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
