From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 14:55:43 -0700
Message-ID: <008801cf4619$7b443cb0$71ccb610$@samsung.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
 <532D9032.1040209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'Tomasz Figa' <tomasz.figa@gmail.com>, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <532D9032.1040209@gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Tomasz Figa <tomasz.figa@gmail.com> :
> Hi,
> 
> I have reviewed the non-net-specific parts of this driver, e.g. platform
driver
> and Device Tree code. Please see my comments inline.
> 
> On 22.03.2014 07:23, Byungho An wrote:
> > From: Siva Reddy <siva.kallam@samsung.com>
> >
> > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> >

[snip]

> > +	struct device_node *np = pdev->dev.of_node;
> > +	struct sxgbe_dma_cfg *dma_cfg;
> > +
> > +	if (!np)
> > +		return -ENODEV;
> > +
> > +	*mac = of_get_mac_address(np);
> > +	plat->interface = of_get_phy_mode(np);
> > +
> > +	plat->bus_id = of_alias_get_id(np, "ethernet");
> > +	if (plat->bus_id < 0)
> > +		plat->bus_id = 0;
> > +
> > +	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
> > +					   sizeof(struct sxgbe_mdio_bus_data),
> > +					   GFP_KERNEL);
> 
> If plat->mdio_bus_data is assumed to be of the same type as the data
> allocated here, then the following would be preferred:
> 
> sizeof(*plat->mdio_bus_data)
> 
> Also you should probably check for allocation failure.
OK and it is same type.
 
> 
> > +
> > +	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
> GFP_KERNEL);
> > +	if (!dma_cfg)
> > +		return -ENOMEM;
> > +
> > +	plat->dma_cfg = dma_cfg;
> > +	of_property_read_u32(np, "samsung,pbl", &dma_cfg->pbl);
> > +	if (of_property_read_u32(np, "samsung,burst-map", &dma_cfg-
> >burst_map) == 0)
> > +		dma_cfg->fixed_burst = true;
> > +
> > +	return 0;
> > +}
> 
> [snip]
> 
> > +static int sxgbe_platform_probe(struct platform_device *pdev) {
> > +	int ret;
> > +	int loop = 0;
> > +	int i, chan;
> > +	struct resource *res;
> > +	struct device *dev = &pdev->dev;
> > +	void __iomem *addr;
> > +	struct sxgbe_priv_data *priv = NULL;
> > +	struct sxgbe_plat_data *plat_dat = NULL;
> > +	const char *mac = NULL;
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	struct device_node *node = dev->of_node;
> > +
> > +	/* Get memory resource */
> > +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	if (!res)
> > +		return -ENODEV;
> > +
> > +	addr = devm_ioremap_resource(dev, res);
> > +	if (IS_ERR(addr))
> > +		return PTR_ERR(addr);
> > +
> > +	if (pdev->dev.of_node) {
> > +		plat_dat = devm_kzalloc(&pdev->dev,
> > +					sizeof(struct sxgbe_plat_data),
> > +					GFP_KERNEL);
> > +		if (!plat_dat)
> > +			return  -ENOMEM;
> > +
> > +		ret = sxgbe_probe_config_dt(pdev, plat_dat, &mac);
> > +		if (ret) {
> > +			pr_err("%s: main dt probe failed\n", __func__);
> > +			return ret;
> > +		}
> > +	}
> > +
> > +	priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
> > +	if (!priv) {
> > +		pr_err("%s: main driver probe failed\n", __func__);
> > +		return -ENODEV;
> > +	}
> > +
> > +	/* Get MAC address if available (DT) */
> > +	if (mac)
> > +		ether_addr_copy(priv->dev->dev_addr, mac);
> > +
> > +	/* Get the SXGBE common INT information */
> > +	priv->irq  = platform_get_irq(pdev, loop++);
> 
> The name "loop" of the variable is quite misleading here. Probably something
> like "irq_num", would be more meaningful.
> 
> Anyway, it doesn't look like it's used anywhere else in this function, so
> platform_get_irq(pdev, 0) could be simply used.
> 
> > +	if (priv->irq <= 0) {
> > +		dev_err(dev, "sxgbe common irq parsing failed\n");
> > +		sxgbe_drv_remove(ndev);
> > +		return -EINVAL;
> > +	}
> > +
> > +	/* Get the TX/RX IRQ numbers */
> > +	for (i = 0, chan = 0; i < SXGBE_TX_QUEUES; i++) {
> > +		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> 
> Hmm, this call looks suspicious. The "chan" variable starts here as 0 and so
the
> first call to irq_of_parse_and_map() will end up with parsing the first
(zeroth)
> entry of "interrupts" property, which would be the same as returned by
> platform_get_irq(..., 0) above. Maybe this was the point where the "loop"
> variable should be used?
OK. it will be chan instead of loop.
thanks I missed.

> 
> Anyway, why you couldn't simply use platform_get_irq() here as well?
I'll change platform_get_irq to irq_of_parse_and_map because latter can
support PCI and nonPCI

> 
> > +		if (priv->txq[i]->irq_no <= 0) {
> > +			dev_err(dev, "sxgbe tx irq parsing failed\n");
> 
> Shouldn't you do some clean-up here, like calling sxgbe_drv_remove()?
OK. I'll add it

> Maybe moving the call to sxgbe_drv_probe() after all the resources are
> successfully retrieved would be a better idea?
OK, I'll consider.

> 
> > +			return -EINVAL;
> > +		}
> > +	}
> > +
> > +	for (i = 0; i < SXGBE_RX_QUEUES; i++) {
> > +		priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> > +		if (priv->rxq[i]->irq_no <= 0) {
> > +			dev_err(dev, "sxgbe rx irq parsing failed\n");
> 
> Same comments as for TX IRQs above.
OK.

> 
> Best regards,
> Tomasz
