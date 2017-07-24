From: Mason <slash.tmp@free.fr>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 17:01:21 +0200
Message-ID: <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:6262 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753170AbdGXPBh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 11:01:37 -0400
In-Reply-To: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/07/2017 13:07, Mason wrote:

> When I set the link down via 'ip link set eth0 down'
> (as opposed to pulling the Ethernet cable) things don't happen as expected:
> 
> The driver's adjust_link() callback is never called, and doesn't
> get a chance make some required changes. And when I set the link
> up again, there is no network connectivity.
> 
> I get this problem only if I enable interrupts on my PHY.
> If I use polling, things work as expected.
> 
> 
> When I set the link down, devinet_ioctl() eventually calls
> ndo_set_rx_mode() and ndo_stop()
> 
> In ndo_stop() the driver calls
> phy_stop(phydev);
> which disables interrupts and sets the state to HALTED.
> 
> In phy_state_machine()
> the PHY_HALTED case does call the adjust_link() callback:
> 
> 		if (phydev->link) {
> 			phydev->link = 0;
> 			netif_carrier_off(phydev->attached_dev);
> 			phy_adjust_link(phydev);
> 			do_suspend = true;
> 		}
> 
> But it's not called when I use interrupts...
> 
> Perhaps because there are no interrupts generated?
> Or even if there were, they have been turned off by phy_stop?
> 
> Basically, it seems like when I use interrupts,
> the phy_state_machine() is not called on link down,
> which breaks the MAC driver's expectations.
> 
> Am I barking up the wrong tree?

FWIW, the patch below solves my issue.
Basically, we reset the MAC in open(), instead of probe().

I also had to solve the issue of adjust_link() not being
called by calling it explicitly in stop() instead of
relying on phy_stop() to do it indirectly.

With this code, I think it is easy to handle suspend/resume:
on suspend, I will stop() and on resume, I will start(),
and everything should work as expected.

I'd like to hear comments on the patch, so I can turn it
into a formal submission.

Regards.



For the record, here is the debug output printed:

# ip addr add 172.27.64.45/18 brd 172.27.127.255 dev eth0
# ip link set eth0 up
[   10.460952] ENTER nb8800_tangox_reset
[   10.464680] ++ETH++ gw8  reg=f0026424 val=00
[   10.478521] ++ETH++ gw8  reg=f0026424 val=01
[   10.482837] ++ETH++ gw16 reg=f0026420 val=0050
[   10.487325] ENTER nb8800_hw_init
[   10.490571] ++ETH++ gw8  reg=f0026000 val=1c
[   10.494878] ++ETH++ gw8  reg=f0026001 val=05
[   10.499176] ++ETH++ gw8  reg=f0026004 val=22
[   10.503481] ++ETH++ gw8  reg=f0026008 val=04
[   10.507777] ++ETH++ gw8  reg=f0026014 val=0c
[   10.512082] ++ETH++ gw8  reg=f0026051 val=00
[   10.516377] ++ETH++ gw8  reg=f0026052 val=ff
[   10.520672] ++ETH++ gw8  reg=f0026054 val=40
[   10.524967] ++ETH++ gw8  reg=f0026060 val=00
[   10.529261] ++ETH++ gw8  reg=f0026061 val=c3
[   10.533555] ENTER nb8800_mc_init
[   10.536801] ++ETH++ gw8  reg=f002602e val=00
[   10.541094] ENTER nb8800_tangox_init
[   10.544690] ++ETH++ gw8  reg=f0026400 val=01
[   10.548985] ENTER nb8800_tango4_init
[   10.552580] ENTER nb8800_update_mac_addr
[   10.556523] ++ETH++ gw8  reg=f002606a val=00
[   10.560818] ++ETH++ gw8  reg=f002606b val=16
[   10.565112] ++ETH++ gw8  reg=f002606c val=e8
[   10.569407] ++ETH++ gw8  reg=f002606d val=5e
[   10.573700] ++ETH++ gw8  reg=f002606e val=65
[   10.577994] ++ETH++ gw8  reg=f002606f val=bc
[   10.582288] ++ETH++ gw8  reg=f002603c val=00
[   10.586582] ++ETH++ gw8  reg=f002603d val=16
[   10.590876] ++ETH++ gw8  reg=f002603e val=e8
[   10.595171] ++ETH++ gw8  reg=f002603f val=5e
[   10.599465] ++ETH++ gw8  reg=f0026040 val=65
[   10.603759] ++ETH++ gw8  reg=f0026041 val=bc
[   10.608051] ENTER nb8800_open
[   10.611034] ENTER nb8800_dma_init
[   10.614951] ++ETH++ gw8  reg=f0026004 val=23
[   10.619255] ++ETH++ gw8  reg=f0026000 val=1d
[   10.688912] ENTER nb8800_set_rx_mode
[   10.692515] ENTER nb8800_mc_init
[   10.695762] ++ETH++ gw8  reg=f002602e val=00
[   10.700384] PHY state change UP -> AN
[   10.704118] ENTER nb8800_set_rx_mode
[   10.707717] ENTER nb8800_mc_init
[   10.710963] ++ETH++ gw8  reg=f002602e val=00
[   10.715257] ++ETH++ gw8  reg=f0026028 val=01
[   10.719550] ++ETH++ gw8  reg=f0026029 val=00
[   10.723843] ++ETH++ gw8  reg=f002602a val=5e
[   10.728135] ++ETH++ gw8  reg=f002602b val=00
[   10.732428] ++ETH++ gw8  reg=f002602c val=00
[   10.736721] ++ETH++ gw8  reg=f002602d val=01
[   10.741013] ENTER nb8800_mc_init
[   10.744258] ++ETH++ gw8  reg=f002602e val=ff

[   14.141948] ENTER nb8800_link_reconfigure
[   14.145988] PRIV link=0 speed=0 duplex=0
[   14.150121] PHYDEV link=1 speed=1000 duplex=1
[   14.154589] ENTER nb8800_mac_config
[   14.158164] ++ETH++ gw8  reg=f0026050 val=01
[   14.162527] ++ETH++ gw8  reg=f002601c val=ff
[   14.166882] ++ETH++ gw8  reg=f0026044 val=81
[   14.171233] ENTER nb8800_pause_config
[   14.174981] ++ETH++ gw8  reg=f0026004 val=2b
[   14.179342] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   14.187193] PHY state change AN -> RUNNING

# ip link set eth0 down
[   21.577737] ENTER nb8800_set_rx_mode
[   21.581350] ENTER nb8800_mc_init
[   21.584598] ++ETH++ gw8  reg=f002602e val=00
[   21.588894] ++ETH++ gw8  reg=f0026028 val=01
[   21.593187] ++ETH++ gw8  reg=f0026029 val=00
[   21.597478] ++ETH++ gw8  reg=f002602a val=5e
[   21.601770] ++ETH++ gw8  reg=f002602b val=00
[   21.606060] ++ETH++ gw8  reg=f002602c val=00
[   21.610351] ++ETH++ gw8  reg=f002602d val=01
[   21.614641] ENTER nb8800_mc_init
[   21.617884] ++ETH++ gw8  reg=f002602e val=ff
[   21.622281] ENTER nb8800_stop
[   21.625326] ++ETH++ gw8  reg=f0026004 val=0b
[   21.629621] ++ETH++ gw8  reg=f0026044 val=85
[   21.834988] ++ETH++ gw8  reg=f0026004 val=2b
[   21.839283] ++ETH++ gw8  reg=f0026044 val=81
[   21.843595] ++ETH++ gw8  reg=f0026004 val=2a
[   21.847890] ++ETH++ gw8  reg=f0026000 val=1c
[   21.852199] ENTER nb8800_link_reconfigure
[   21.856234] PRIV link=1 speed=1000 duplex=1
[   21.860442] PHYDEV link=0 speed=1000 duplex=1
[   21.864830] nb8800 26000.ethernet eth0: Link is Down

# ip link set eth0 up
[   32.814417] ENTER nb8800_tangox_reset
[   32.818198] ++ETH++ gw8  reg=f0026424 val=00
[   32.831850] ++ETH++ gw8  reg=f0026424 val=01
[   32.836151] ++ETH++ gw16 reg=f0026420 val=0050
[   32.840638] ENTER nb8800_hw_init
[   32.843883] ++ETH++ gw8  reg=f0026000 val=1c
[   32.848180] ++ETH++ gw8  reg=f0026001 val=05
[   32.852474] ++ETH++ gw8  reg=f0026004 val=22
[   32.856770] ++ETH++ gw8  reg=f0026008 val=04
[   32.861067] ++ETH++ gw8  reg=f0026014 val=0c
[   32.865363] ++ETH++ gw8  reg=f0026051 val=00
[   32.869656] ++ETH++ gw8  reg=f0026052 val=ff
[   32.873950] ++ETH++ gw8  reg=f0026054 val=40
[   32.878244] ++ETH++ gw8  reg=f0026060 val=00
[   32.882539] ++ETH++ gw8  reg=f0026061 val=c3
[   32.886831] ENTER nb8800_mc_init
[   32.890078] ++ETH++ gw8  reg=f002602e val=00
[   32.894371] ENTER nb8800_tangox_init
[   32.897968] ++ETH++ gw8  reg=f0026400 val=01
[   32.902260] ENTER nb8800_tango4_init
[   32.905856] ENTER nb8800_update_mac_addr
[   32.909800] ++ETH++ gw8  reg=f002606a val=00
[   32.914095] ++ETH++ gw8  reg=f002606b val=16
[   32.918388] ++ETH++ gw8  reg=f002606c val=e8
[   32.922682] ++ETH++ gw8  reg=f002606d val=5e
[   32.926976] ++ETH++ gw8  reg=f002606e val=65
[   32.931270] ++ETH++ gw8  reg=f002606f val=bc
[   32.935564] ++ETH++ gw8  reg=f002603c val=00
[   32.939857] ++ETH++ gw8  reg=f002603d val=16
[   32.944151] ++ETH++ gw8  reg=f002603e val=e8
[   32.948444] ++ETH++ gw8  reg=f002603f val=5e
[   32.952738] ++ETH++ gw8  reg=f0026040 val=65
[   32.957031] ++ETH++ gw8  reg=f0026041 val=bc
[   32.961324] ENTER nb8800_open
[   32.964308] ENTER nb8800_dma_init
[   32.968212] ++ETH++ gw8  reg=f0026004 val=23
[   32.972514] ++ETH++ gw8  reg=f0026000 val=1d
[   33.042228] ENTER nb8800_set_rx_mode
[   33.045829] ENTER nb8800_mc_init
[   33.049077] ++ETH++ gw8  reg=f002602e val=00
[   33.053697] PHY state change UP -> AN
[   33.057427] ENTER nb8800_set_rx_mode
[   33.061024] ENTER nb8800_mc_init
[   33.064271] ++ETH++ gw8  reg=f002602e val=00
[   33.068565] ++ETH++ gw8  reg=f0026028 val=01
[   33.072858] ++ETH++ gw8  reg=f0026029 val=00
[   33.077152] ++ETH++ gw8  reg=f002602a val=5e
[   33.081444] ++ETH++ gw8  reg=f002602b val=00
[   33.085737] ++ETH++ gw8  reg=f002602c val=00
[   33.090030] ++ETH++ gw8  reg=f002602d val=01
[   33.094325] ENTER nb8800_mc_init
[   33.097571] ++ETH++ gw8  reg=f002602e val=ff

[   35.803026] ENTER nb8800_link_reconfigure
[   35.807077] PRIV link=0 speed=0 duplex=0
[   35.811025] PHYDEV link=1 speed=1000 duplex=1
[   35.815414] ENTER nb8800_mac_config
[   35.818931] ++ETH++ gw8  reg=f0026050 val=01
[   35.823229] ++ETH++ gw8  reg=f002601c val=ff
[   35.827528] ++ETH++ gw8  reg=f0026044 val=81
[   35.831824] ENTER nb8800_pause_config
[   35.835511] ++ETH++ gw8  reg=f0026004 val=2b
[   35.839817] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   35.847610] PHY state change AN -> RUNNING

# ping 172.27.64.1
PING 172.27.64.1 (172.27.64.1) 56(84) bytes of data.
64 bytes from 172.27.64.1: icmp_seq=1 ttl=64 time=0.256 ms
64 bytes from 172.27.64.1: icmp_seq=2 ttl=64 time=0.130 ms



diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index e94159507847..22e1dd41962d 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -41,6 +41,7 @@
 
 static void nb8800_tx_done(struct net_device *dev);
 static int nb8800_dma_stop(struct net_device *dev);
+static int mac_init(struct net_device *dev);
 
 static inline u8 nb8800_readb(struct nb8800_priv *priv, int reg)
 {
@@ -54,16 +55,20 @@ static inline u32 nb8800_readl(struct nb8800_priv *priv, int reg)
 
 static inline void nb8800_writeb(struct nb8800_priv *priv, int reg, u8 val)
 {
+	printk("++ETH++ gw8  reg=%p val=%02x\n", priv->base + reg, val);
 	writeb_relaxed(val, priv->base + reg);
 }
 
 static inline void nb8800_writew(struct nb8800_priv *priv, int reg, u16 val)
 {
+	printk("++ETH++ gw16 reg=%p val=%04x\n", priv->base + reg, val);
 	writew_relaxed(val, priv->base + reg);
 }
 
 static inline void nb8800_writel(struct nb8800_priv *priv, int reg, u32 val)
 {
+	if (reg != 0x20 && reg < 0x100)
+		printk("++ETH++ gw32 reg=%p val=%08x\n", priv->base + reg, val);
 	writel_relaxed(val, priv->base + reg);
 }
 
@@ -605,6 +610,7 @@ static void nb8800_mac_config(struct net_device *dev)
 	u32 phy_clk;
 	u32 ict;
 
+	printk("ENTER %s\n", __func__);
 	if (!priv->duplex)
 		mac_mode |= HALF_DUPLEX;
 
@@ -635,6 +641,7 @@ static void nb8800_pause_config(struct net_device *dev)
 	struct phy_device *phydev = dev->phydev;
 	u32 rxcr;
 
+	printk("ENTER %s\n", __func__);
 	if (priv->pause_aneg) {
 		if (!phydev || !phydev->link)
 			return;
@@ -668,6 +675,11 @@ static void nb8800_link_reconfigure(struct net_device *dev)
 	struct phy_device *phydev = dev->phydev;
 	int change = 0;
 
+	printk("ENTER %s\n", __func__);
+	printk("PRIV link=%d speed=%d duplex=%d\n",
+			priv->link, priv->speed, priv->duplex);
+	printk("PHYDEV link=%d speed=%d duplex=%d\n",
+			phydev->link, phydev->speed, phydev->duplex);
 	if (phydev->link) {
 		if (phydev->speed != priv->speed) {
 			priv->speed = phydev->speed;
@@ -699,6 +711,7 @@ static void nb8800_update_mac_addr(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	int i;
 
+	printk("ENTER %s\n", __func__);
 	for (i = 0; i < ETH_ALEN; i++)
 		nb8800_writeb(priv, NB8800_SRC_ADDR(i), dev->dev_addr[i]);
 
@@ -710,6 +723,7 @@ static int nb8800_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sock = addr;
 
+	printk("ENTER %s\n", __func__);
 	if (netif_running(dev))
 		return -EBUSY;
 
@@ -723,6 +737,7 @@ static void nb8800_mc_init(struct net_device *dev, int val)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
 
+	printk("ENTER %s\n", __func__);
 	nb8800_writeb(priv, NB8800_MC_INIT, val);
 	readb_poll_timeout_atomic(priv->base + NB8800_MC_INIT, val, !val,
 				  1, 1000);
@@ -734,6 +749,7 @@ static void nb8800_set_rx_mode(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int i;
 
+	printk("ENTER %s\n", __func__);
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
 		nb8800_mac_af(dev, false);
 		return;
@@ -840,6 +856,7 @@ static int nb8800_dma_init(struct net_device *dev)
 	unsigned int i;
 	int err;
 
+	printk("ENTER %s\n", __func__);
 	priv->rx_descs = dma_alloc_coherent(dev->dev.parent, RX_DESC_SIZE,
 					    &priv->rx_desc_dma, GFP_KERNEL);
 	if (!priv->rx_descs)
@@ -957,6 +974,9 @@ static int nb8800_open(struct net_device *dev)
 	struct phy_device *phydev;
 	int err;
 
+	mac_init(dev);
+
+	printk("ENTER %s\n", __func__);
 	/* clear any pending interrupts */
 	nb8800_writel(priv, NB8800_RXC_SR, 0xf);
 	nb8800_writel(priv, NB8800_TXC_SR, 0xf);
@@ -1004,7 +1024,7 @@ static int nb8800_stop(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 
-	phy_stop(phydev);
+	printk("ENTER %s\n", __func__);
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
@@ -1013,7 +1033,11 @@ static int nb8800_stop(struct net_device *dev)
 	nb8800_mac_rx(dev, false);
 	nb8800_mac_tx(dev, false);
 
+	phydev->link = 0;
+	netif_carrier_off(dev);
+	nb8800_link_reconfigure(dev);
 	phy_disconnect(phydev);
+	priv->duplex = priv->speed = 0;
 
 	free_irq(dev->irq, dev);
 
@@ -1171,6 +1195,7 @@ static int nb8800_hw_init(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	u32 val;
 
+	printk("ENTER %s\n", __func__);
 	val = TX_RETRY_EN | TX_PAD_EN | TX_APPEND_FCS;
 	nb8800_writeb(priv, NB8800_TX_CTL1, val);
 
@@ -1261,6 +1286,7 @@ static int nb8800_tangox_init(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	u32 pad_mode = PAD_MODE_MII;
 
+	printk("ENTER %s\n", __func__);
 	switch (priv->phy_mode) {
 	case PHY_INTERFACE_MODE_MII:
 	case PHY_INTERFACE_MODE_GMII:
@@ -1290,6 +1316,7 @@ static int nb8800_tangox_reset(struct net_device *dev)
 	struct nb8800_priv *priv = netdev_priv(dev);
 	int clk_div;
 
+	printk("ENTER %s\n", __func__);
 	nb8800_writeb(priv, NB8800_TANGOX_RESET, 0);
 	usleep_range(1000, 10000);
 	nb8800_writeb(priv, NB8800_TANGOX_RESET, 1);
@@ -1316,6 +1343,7 @@ static int nb8800_tango4_init(struct net_device *dev)
 	if (err)
 		return err;
 
+	printk("ENTER %s\n", __func__);
 	/* On tango4 interrupt on DMA completion per frame works and gives
 	 * better performance despite generating more rx interrupts.
 	 */
@@ -1350,6 +1378,21 @@ static int nb8800_tango4_init(struct net_device *dev)
 };
 MODULE_DEVICE_TABLE(of, nb8800_dt_ids);
 
+static int mac_init(struct net_device *dev)
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
@@ -1363,6 +1406,7 @@ static int nb8800_probe(struct platform_device *pdev)
 	int irq;
 	int ret;
 
+	printk("ENTER %s\n", __func__);
 	match = of_match_device(nb8800_dt_ids, &pdev->dev);
 	if (match)
 		ops = match->data;
@@ -1389,6 +1433,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 	priv->base = base;
+	priv->ops = ops;
 
 	priv->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (priv->phy_mode < 0)
@@ -1407,11 +1452,13 @@ static int nb8800_probe(struct platform_device *pdev)
 
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
@@ -1454,6 +1501,7 @@ static int nb8800_probe(struct platform_device *pdev)
 
 	priv->mii_bus = bus;
 
+#ifdef RESET_IN_PROBE
 	ret = nb8800_hw_init(dev);
 	if (ret)
 		goto err_deregister_fixed_link;
@@ -1463,6 +1511,7 @@ static int nb8800_probe(struct platform_device *pdev)
 		if (ret)
 			goto err_deregister_fixed_link;
 	}
+#endif
 
 	dev->netdev_ops = &nb8800_netdev_ops;
 	dev->ethtool_ops = &nb8800_ethtool_ops;
@@ -1476,7 +1525,9 @@ static int nb8800_probe(struct platform_device *pdev)
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
