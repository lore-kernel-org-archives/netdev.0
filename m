From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Fri, 07 Jun 2013 10:47:37 +0200
Message-ID: <1505761.5DsauZd6eq@wuerfel>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Steven J. Hill" <sjhill-8NJIiSa5LzA@public.gmane.org>, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vineet Gupta <Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Mischa Jonker <Mischa.Jonker-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
To: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1370348510-23754-1-git-send-email-abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tuesday 04 June 2013 16:21:50 Alexey Brodkin wrote:

>  drivers/net/ethernet/Kconfig             |    1 +
>  drivers/net/ethernet/Makefile            |    1 +
>  drivers/net/ethernet/arc/Kconfig         |   29 +
>  drivers/net/ethernet/arc/Makefile        |    6 +
>  drivers/net/ethernet/arc/arc_emac_main.c |  905 ++++++++++++++++++++++++++++++
>  drivers/net/ethernet/arc/arc_emac_main.h |   82 +++
>  drivers/net/ethernet/arc/arc_emac_mdio.c |  181 ++++++
>  drivers/net/ethernet/arc/arc_emac_mdio.h |   22 +
>  drivers/net/ethernet/arc/arc_emac_regs.h |   73 +++

I wonder if it would be better to name the directory "synopsys" or
"designware" rather than "arc" now. Is there a chance that the same
controller is used on non-arc CPUs?

> +static int arc_emac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *net_dev;
> +	struct arc_emac_priv *priv;
> +	int err;
> +	unsigned int clock_frequency;
> +	unsigned int id;
> +	struct resource res_regs;
> +#ifdef CONFIG_OF_IRQ
> +	struct resource res_irq;
> +#endif
> +	const char *mac_addr = NULL;

Please remove the #ifdef here. The driver does not work without this
anyway, so better make it 'depend on OF_IRQ' in Kconfig.

> +	/* Get phy from device tree */
> +	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
> +	if (!priv->phy_node) {
> +		dev_err(&pdev->dev,
> +			"failed to retrieve phy description from device tree\n");
> +		err = -ENODEV;
> +		goto out;
> +	}

You should add a binding document in Documentation/devicetree/bindings that
describes what properties are required.

> +	/* Get EMAC registers base address from device tree */
> +	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
> +	if (err) {
> +		dev_err(&pdev->dev,
> +			"failed to retrieve base register from device tree\n");
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	if (!devm_request_mem_region(&pdev->dev, res_regs.start,
> +			resource_size(&res_regs), pdev->name)) {
> +		dev_err(&pdev->dev,
> +			"failed to request memory region for base registers\n");
> +		err = -ENXIO;
> +		goto out;
> +	}
> +
> +	priv->reg_base_addr = (void *) devm_ioremap_nocache(&pdev->dev,
> +			res_regs.start, resource_size(&res_regs));
> +	if (!priv->reg_base_addr) {
> +		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
> +		err = -ENXIO;
> +		goto out;
> +	}

This block can be simplified to a single devm_ioremap_resource() now.

The cast to 'void *' is wrong: please make sure that you always use '__iomem'
pointers for MMIO mappings. You can use 'sparse' with 'make C=1' to check this
at build time.

> +	/* Get MAC address from device tree */
> +#ifdef CONFIG_OF_NET
> +	mac_addr = of_get_mac_address(pdev->dev.of_node);
> +#endif

Same as above, remove the #ifdef.

> diff --git a/drivers/net/ethernet/arc/arc_emac_main.h b/drivers/net/ethernet/arc/arc_emac_main.h
> new file mode 100644
> index 0000000..6f03d26
> --- /dev/null
> +++ b/drivers/net/ethernet/arc/arc_emac_main.h

This header seems to be included only in the main .c file, just
move the contents there and remove this file.

> +/**
> + * arc_mdio_probe - MDIO probe function.
> + * @dev_node:	Pointer to device node.
> + * @priv:		Pointer to ARC MDIO private data structure.
> + *
> + * returns:	0 on success, -ENOMEM when mdiobus_alloc
> + * (to allocate memory for MII bus structure) fails.
> + *
> + * Sets up and registers the MDIO interface.
> + */
> +int arc_mdio_probe(struct device_node *dev_node, struct arc_mdio_priv *priv)
> +{
> +	struct device_node *mdio_np;
> +	struct mii_bus *bus;
> +	int error;
> +
> +	bus = mdiobus_alloc();
> +	if (!bus) {
> +		error = -ENOMEM;
> +		goto cleanup;
> +	}
> +
> +	priv->bus = bus;
> +	bus->priv = priv;
> +	bus->name = "Synopsys MII Bus",
> +	bus->read = &arc_mdio_read;
> +	bus->write = &arc_mdio_write;
> +
> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x",
> +			(unsigned int)priv->reg_base_addr);
> +
> +	bus->parent = priv->dev;
> +
> +	mdio_np = of_find_node_by_name(NULL, "mdio");
> +	if (!mdio_np) {
> +		dev_err(priv->dev, "cannot find <mdio> in device tree\n");
> +		error = -ENODEV;
> +		goto cleanup;
> +	}

of_find_node_by_name() is probably not what you want here, the name should
not be used as a primary key. Maybe it's better to use a standalone driver
for the phy and put it into drivers/net/phy/. I don't know what the official
policy is here though, since the phy is only used in this one driver.

	Arnd
