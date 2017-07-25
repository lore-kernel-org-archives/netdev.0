From: Mason <slash.tmp@free.fr>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Tue, 25 Jul 2017 13:41:32 +0200
Message-ID: <e2f4ef4a-c667-3bdf-e4ea-2767dc6a4922@free.fr>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
 <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
 <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr>
 <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com>
 <eb09bda5-c972-0c2c-2693-982c02c8c87c@gmail.com>
 <1c00935b-3a3c-4268-db99-a0487ddece76@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:31532 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750897AbdGYLlu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 07:41:50 -0400
In-Reply-To: <1c00935b-3a3c-4268-db99-a0487ddece76@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/07/2017 12:51, Mason wrote:

> Moving the call to phy_stop() down after all the MAC tear down
> avoids the hang.
> 
> As far as I understand, when we are shutting everything down,
> we don't need the phy_state_machine to run asynchronously.
> We can run it synchronously one last time after the delayed
> stuff has been disabled.

Below is my current WIP diff. (It conflates the two issues
I've been discussing. Splitting the diff required.)

Tested in interrupt mode:

# ip link set eth0 up
[   11.107547] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change UP -> AN
[   14.530329] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   14.538136] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change AN -> RUNNING
# ip link set eth0 down
[   23.801018] nb8800 26000.ethernet eth0: Link is Down
# ip link set eth0 up
[   28.740870] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change UP -> AN
[   31.431528] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   31.439350] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change AN -> RUNNING

Works as expected.

Tested in polling mode:

# ip link set eth0 up
[   23.001199] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change UP -> AN
[   24.024315] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change AN -> NOLINK
[   27.064355] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   27.072156] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change NOLINK -> RUNNING
# ip link set eth0 down
[   42.134617] nb8800 26000.ethernet eth0: Link is Down
# ip link set eth0 up
[   48.381185] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change UP -> AN
[   49.410976] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change AN -> NOLINK
[   51.437686] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   51.445486] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change NOLINK -> RUNNING

Works as expected.

Also tested on my old board, no regression seen.

Can you confirm that the changes to drivers/net/phy/phy.c
look reasonable?

Regards.


diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index e94159507847..b5eba7958871 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -41,6 +41,7 @@
 
 static void nb8800_tx_done(struct net_device *dev);
 static int nb8800_dma_stop(struct net_device *dev);
+static int nb8800_init(struct net_device *dev);
 
 static inline u8 nb8800_readb(struct nb8800_priv *priv, int reg)
 {
@@ -957,6 +958,9 @@ static int nb8800_open(struct net_device *dev)
 	struct phy_device *phydev;
 	int err;
 
+	nb8800_init(dev);
+	priv->speed = 0;
+
 	/* clear any pending interrupts */
 	nb8800_writel(priv, NB8800_RXC_SR, 0xf);
 	nb8800_writel(priv, NB8800_TXC_SR, 0xf);
@@ -1004,8 +1008,6 @@ static int nb8800_stop(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 
-	phy_stop(phydev);
-
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 
@@ -1013,6 +1015,7 @@ static int nb8800_stop(struct net_device *dev)
 	nb8800_mac_rx(dev, false);
 	nb8800_mac_tx(dev, false);
 
+	phy_stop(phydev);
 	phy_disconnect(phydev);
 
 	free_irq(dev->irq, dev);
@@ -1350,6 +1353,21 @@ static int nb8800_tango4_init(struct net_device *dev)
 };
 MODULE_DEVICE_TABLE(of, nb8800_dt_ids);
 
+static int nb8800_init(struct net_device *dev)
+{
+#ifndef RESET_IN_PROBE
+	struct nb8800_priv *priv = netdev_priv(dev);
+	const struct nb8800_ops *ops = priv->ops;
+
+	ops->reset(dev);
+	nb8800_hw_init(dev);
+	ops->init(dev);
+	nb8800_update_mac_addr(dev);
+#endif
+
+	return 0;
+}
+
 static int nb8800_probe(struct platform_device *pdev)
 {
 	const struct of_device_id *match;
@@ -1389,6 +1407,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 	priv->base = base;
+	priv->ops = ops;
 
 	priv->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (priv->phy_mode < 0)
@@ -1407,11 +1426,13 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->tx_lock);
 
+#ifdef RESET_IN_PROBE
 	if (ops && ops->reset) {
 		ret = ops->reset(dev);
 		if (ret)
 			goto err_disable_clk;
 	}
+#endif
 
 	bus = devm_mdiobus_alloc(&pdev->dev);
 	if (!bus) {
@@ -1454,6 +1475,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv->mii_bus = bus;
 
+#ifdef RESET_IN_PROBE
 	ret = nb8800_hw_init(dev);
 	if (ret)
 		goto err_deregister_fixed_link;
@@ -1463,6 +1485,7 @@ static int nb8800_probe(struct platform_device *pdev)
 		if (ret)
 			goto err_deregister_fixed_link;
 	}
+#endif
 
 	dev->netdev_ops = &nb8800_netdev_ops;
 	dev->ethtool_ops = &nb8800_ethtool_ops;
@@ -1476,7 +1499,9 @@ static int nb8800_probe(struct platform_device *pdev)
 	if (!is_valid_ether_addr(dev->dev_addr))
 		eth_hw_addr_random(dev);
 
+#ifdef RESET_IN_PROBE
 	nb8800_update_mac_addr(dev);
+#endif
 
 	netif_carrier_off(dev);
 
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
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..3bc505b56c71 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -14,6 +14,7 @@
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define DEBUG
 
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -743,12 +744,16 @@ void phy_trigger_machine(struct phy_device *phydev, bool sync)
  */
 void phy_stop_machine(struct phy_device *phydev)
 {
+	flush_delayed_work(&phydev->state_queue);
 	cancel_delayed_work_sync(&phydev->state_queue);
 
 	mutex_lock(&phydev->lock);
 	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
+
+	/* Now we can run the state machine synchronously */
+	phy_state_machine(&phydev->state_queue.work);
 }
 
 /**
