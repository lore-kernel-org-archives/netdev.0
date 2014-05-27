From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Tue, 27 May 2014 15:02:36 +0200
Message-ID: <20140527130236.GA26163@distanz.ch>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
 <1401194667-14445-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:47530 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbaE0NCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 09:02:39 -0400
Content-Disposition: inline
In-Reply-To: <1401194667-14445-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-27 at 14:44:27 +0200, Zhangfei Gao <zhangfei.gao@linaro.org> wrote:
> Add support for the hix5hd2 XGMAC 1Gb ethernet device.
> The controller requires two queues for tx and two queues for rx.
> Controller fetch buffer from free queue and then push to used queue.
> Diver should prepare free queue and free buffer from used queue.
> 
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  drivers/net/ethernet/hisilicon/Kconfig        |   27 +
>  drivers/net/ethernet/hisilicon/Makefile       |    5 +
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 1057 +++++++++++++++++++++++++
>  5 files changed, 1091 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
>  create mode 100644 drivers/net/ethernet/hisilicon/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c

[...]

> diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
> new file mode 100644
> index 0000000..6655986
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
> @@ -0,0 +1,1057 @@

[...]

> +static struct net_device_stats *hix5hd2_net_get_stats(struct net_device *dev)
> +{
> +	return &dev->stats;
> +}

This function can be omitted, since it corresponds to the default
behavior if neither .ndo_get_stats or .ndo_get_stats64 is set.

> +
> +static const struct net_device_ops hix5hd2_netdev_ops = {
> +	.ndo_open		= hix5hd2_net_open,
> +	.ndo_stop		= hix5hd2_net_close,
> +	.ndo_start_xmit		= hix5hd2_net_xmit,
> +	.ndo_tx_timeout		= hix5hd2_net_timeout,
> +	.ndo_set_mac_address	= hix5hd2_net_set_mac_address,
> +	.ndo_get_stats		= hix5hd2_net_get_stats,

Thus the line above can then be omitted as well.

> +};
> +
> +static int hix5hd2_get_settings(struct net_device *net_dev,
> +		struct ethtool_cmd *cmd)
> +{
> +	struct hix5hd2_priv *priv = netdev_priv(net_dev);
> +
> +	if (!priv->phy)
> +		return -ENODEV;
> +
> +	return phy_ethtool_gset(priv->phy, cmd);
> +}
> +
> +static int hix5hd2_set_settings(struct net_device *net_dev,
> +		struct ethtool_cmd *cmd)
> +{
> +	struct hix5hd2_priv *priv = netdev_priv(net_dev);
> +
> +	if (!priv->phy)
> +		return -ENODEV;
> +
> +	return phy_ethtool_sset(priv->phy, cmd);
> +}
> +
> +static struct ethtool_ops hix5hd2_ethtools_ops = {
> +	.get_link		= ethtool_op_get_link,
> +	.get_settings		= hix5hd2_get_settings,
> +	.set_settings		= hix5hd2_set_settings,
> +};
> +
> +static int hix5hd2_mdio_wait_ready(struct mii_bus *bus)
> +{
> +	struct hix5hd2_priv *priv = bus->priv;
> +	void __iomem *base = priv->base;
> +	int i, timeout = 10000;
> +
> +	for (i = 0; readl_relaxed(base + MDIO_SINGLE_CMD) & MDIO_START; i++) {
> +		if (i == timeout)
> +			return -ETIMEDOUT;
> +		udelay(1);
> +	}
> +
> +	return 0;
> +}
> +
> +static int hix5hd2_mdio_read(struct mii_bus *bus, int phy, int reg)
> +{
> +	struct hix5hd2_priv *priv = bus->priv;
> +	void __iomem *base = priv->base;
> +	int val, ret;
> +
> +	ret = hix5hd2_mdio_wait_ready(bus);
> +	if (ret < 0)
> +		goto out;
> +
> +	writel_relaxed(MDIO_READ | phy << 8 | reg, base + MDIO_SINGLE_CMD);
> +	ret = hix5hd2_mdio_wait_ready(bus);
> +	if (ret < 0)
> +		goto out;
> +
> +	val = readl_relaxed(base + MDIO_RDATA_STATUS);
> +	if (val & MDIO_R_VALID) {
> +		dev_err(bus->parent, "SMI bus read not valid\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	val = readl_relaxed(priv->base + MDIO_SINGLE_DATA);
> +	ret = (val >> 16) & 0xFFFF;
> +out:
> +	return ret;
> +}
> +
> +static int hix5hd2_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
> +{
> +	struct hix5hd2_priv *priv = bus->priv;
> +	void __iomem *base = priv->base;
> +	int ret;
> +
> +	ret = hix5hd2_mdio_wait_ready(bus);
> +	if (ret < 0)
> +		goto out;
> +
> +	writel_relaxed(val, base + MDIO_SINGLE_DATA);
> +	writel_relaxed(MDIO_WRITE | phy << 8 | reg, base + MDIO_SINGLE_CMD);
> +	ret = hix5hd2_mdio_wait_ready(bus);
> +out:
> +	return ret;
> +}
> +
> +static void hix5hd2_destroy_hw_desc_queue(struct hix5hd2_priv *priv)
> +{
> +	int i;
> +
> +	for (i = 0; i < QUEUE_NUMS; i++) {
> +		if (priv->pool[i].desc) {
> +			dma_free_coherent(priv->dev, priv->pool[i].size,
> +					priv->pool[i].desc,
> +					priv->pool[i].phys_addr);
> +			priv->pool[i].desc = NULL;
> +		}
> +	}
> +}
> +
> +static int hix5hd2_init_hw_desc_queue(struct hix5hd2_priv *priv)
> +{
> +	struct device *dev = priv->dev;
> +	struct hix5hd2_desc *virt_addr;
> +	dma_addr_t phys_addr;
> +	int size, i;
> +
> +	priv->rx_fq.count = RX_DESC_NUM;
> +	priv->rx_bq.count = RX_DESC_NUM;
> +	priv->tx_bq.count = TX_DESC_NUM;
> +	priv->tx_rq.count = TX_DESC_NUM;
> +
> +	for (i = 0; i < QUEUE_NUMS; i++) {
> +		size = priv->pool[i].count * sizeof(struct hix5hd2_desc);
> +		virt_addr = dma_alloc_coherent(dev, size, &phys_addr,
> +				GFP_KERNEL);
> +		if (virt_addr == NULL)
> +			goto error_free_pool;
> +
> +		memset(virt_addr, 0, size);
> +		priv->pool[i].size = size;
> +		priv->pool[i].desc = virt_addr;
> +		priv->pool[i].phys_addr = phys_addr;
> +	}
> +	return 0;
> +
> +error_free_pool:
> +	hix5hd2_destroy_hw_desc_queue(priv);
> +
> +	return -ENOMEM;
> +}
> +
> +static int hix5hd2_dev_probe(struct platform_device *pdev)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct device_node *node = dev->of_node;
> +	struct net_device *ndev;
> +	struct hix5hd2_priv *priv;
> +	struct resource *res;
> +	struct mii_bus *bus;
> +	const char *mac_addr;
> +	int ret;
> +
> +	ndev = alloc_etherdev(sizeof(struct hix5hd2_priv));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, ndev);
> +
> +	priv = netdev_priv(ndev);
> +	priv->dev = dev;
> +	priv->netdev = ndev;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	priv->base = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(priv->base)) {
> +		ret = PTR_ERR(priv->base);
> +		goto out_free_netdev;
> +	}
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	priv->ctrl_base = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(priv->ctrl_base)) {
> +		ret = PTR_ERR(priv->ctrl_base);
> +		goto out_free_netdev;
> +	}
> +
> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk)) {
> +		netdev_err(ndev, "failed to get clk\n");
> +		ret = -ENODEV;
> +		goto out_free_netdev;
> +	}
> +
> +	ret = clk_prepare_enable(priv->clk);
> +	if (ret < 0) {
> +		netdev_err(ndev, "failed to enable clk %d\n", ret);
> +		goto out_free_netdev;
> +	}
> +
> +	bus = mdiobus_alloc();
> +	if (bus == NULL) {
> +		ret = -ENOMEM;
> +		goto out_free_netdev;
> +	}
> +
> +	bus->priv = priv;
> +	bus->name = "hix5hd2_mii_bus";
> +	bus->read = hix5hd2_mdio_read;
> +	bus->write = hix5hd2_mdio_write;
> +	bus->parent = &pdev->dev;
> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
> +	priv->bus = bus;
> +
> +	ret = of_mdiobus_register(bus, node);
> +	if (ret)
> +		goto err_free_mdio;
> +
> +	priv->phy_mode = of_get_phy_mode(node);
> +	if (priv->phy_mode < 0) {
> +		netdev_err(ndev, "not find phy-mode\n");
> +		ret = -EINVAL;
> +		goto err_mdiobus;
> +	}
> +
> +	priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
> +	if (!priv->phy_node) {
> +		netdev_err(ndev, "not find phy-handle\n");
> +		ret = -EINVAL;
> +		goto err_mdiobus;
> +	}
> +
> +	ndev->irq = platform_get_irq(pdev, 0);
> +	if (ndev->irq <= 0) {
> +		netdev_err(ndev, "No irq resource\n");
> +		ret = -EINVAL;
> +		goto out_phy_node;
> +	}
> +
> +	ret = devm_request_irq(dev, ndev->irq, hix5hd2_interrupt,
> +				0, pdev->name, ndev);
> +	if (ret) {
> +		netdev_err(ndev, "devm_request_irq failed\n");
> +		goto out_phy_node;
> +	}
> +
> +	mac_addr = of_get_mac_address(node);
> +	if (mac_addr)
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		eth_hw_addr_random(ndev);
> +		netdev_warn(ndev, "using random MAC address %pM\n",
> +			 ndev->dev_addr);
> +	}
> +
> +	INIT_WORK(&priv->tx_timeout_task, hix5hd2_tx_timeout_task);
> +	ndev->watchdog_timeo = 6 * HZ;
> +	ndev->priv_flags |= IFF_UNICAST_FLT;
> +	ndev->netdev_ops = &hix5hd2_netdev_ops;
> +	ndev->ethtool_ops = &hix5hd2_ethtools_ops;
> +	SET_NETDEV_DEV(ndev, dev);
> +
> +	ret = hix5hd2_init_hw_desc_queue(priv);
> +	if (ret)
> +		goto out_phy_node;
> +
> +	netif_napi_add(ndev, &priv->napi, hix5hd2_poll, NAPI_POLL_WEIGHT);
> +	ret = register_netdev(priv->netdev);
> +	if (ret) {
> +		netdev_err(ndev, "register_netdev failed!");
> +		goto out_destroy_queue;
> +	}
> +
> +	clk_disable_unprepare(priv->clk);
> +
> +	return ret;
> +
> +out_destroy_queue:
> +	netif_napi_del(&priv->napi);
> +	hix5hd2_destroy_hw_desc_queue(priv);
> +out_phy_node:
> +	of_node_put(priv->phy_node);
> +err_mdiobus:
> +	mdiobus_unregister(bus);
> +err_free_mdio:
> +	mdiobus_free(bus);
> +out_free_netdev:
> +	free_netdev(ndev);
> +
> +	return ret;
> +}
> +
> +static int hix5hd2_dev_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct hix5hd2_priv *priv = netdev_priv(ndev);
> +
> +	netif_napi_del(&priv->napi);
> +	unregister_netdev(ndev);
> +	mdiobus_unregister(priv->bus);
> +	mdiobus_free(priv->bus);
> +
> +	hix5hd2_destroy_hw_desc_queue(priv);
> +	of_node_put(priv->phy_node);
> +	cancel_work_sync(&priv->tx_timeout_task);
> +	free_netdev(ndev);
> +
> +	return 0;
> +}
> +
> +static const struct of_device_id hix5hd2_of_match[] = {
> +	{.compatible = "hisilicon,hix5hd2-gmac",},
> +	{},
> +};
> +
> +MODULE_DEVICE_TABLE(of, hix5hd2_of_match);
> +
> +static struct platform_driver hix5hd2_dev_driver = {
> +	.driver = {
> +		.name = "hix5hd2-gmac",
> +		.of_match_table = hix5hd2_of_match,
> +	},
> +	.probe = hix5hd2_dev_probe,
> +	.remove = hix5hd2_dev_remove,
> +};
> +
> +module_platform_driver(hix5hd2_dev_driver);
> +
> +MODULE_DESCRIPTION("HISILICON HIX5HD2 Ethernet driver");
> +MODULE_LICENSE("GPL v2");
> +MODULE_ALIAS("platform:hix5hd2-gmac");
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
