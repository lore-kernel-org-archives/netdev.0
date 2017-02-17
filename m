From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Fri, 17 Feb 2017 14:18:02 +0100
Message-ID: <20170217131802.GB24993@Red>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
 <20170216124859.14346-6-clabbe.montjoie@gmail.com>
 <20170216190524.l2ddzhwabzdpdphx@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216190524.l2ddzhwabzdpdphx@lukather>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 08:05:24PM +0100, Maxime Ripard wrote:
> Hi,
> 

[...]
> > +
> > +struct emac_variant {
> > +	u32 default_syscon_value;
> 
> Why do you need a default value? Can't you read it from the syscon
> directly?
> 

Why not, but you can see the default value as "value for disabled state".
My fear is that something (uboot) modify it (keep it activated) before driver load.

[...]
> > +static void sun8i_dwmac_dump_regs(void __iomem *ioaddr)
> > +{
> > +	int i;
> > +
> > +	pr_info(" DMA registers\n");
> 
> Logging this as pr_info is bad already...
> 
> > +	for (i = 0; i < 0xC8; i += 4) {
> > +		if (i == 0x32 || i == 0x3C)
> > +			continue;
> > +		pr_err("Reg 0x%x: 0x%08x\n", i, readl(ioaddr + i));
> 
> ... But this is worse.
> 
> Why do you need to do that? Can't you create a file in debugfs
> instead?
> 

I just do as other glue does. But yes this is uglyi, no excuse.
Reworking all stmmac register dump (ethtool, stmmac_ops->dump_regs and stmmac_dma_ops->dump_regs) was on my todo list,
but I postponed it.

I will propose something better based on debugfs.

[...]
> > +static void sun8i_dwmac_dma_start_tx(void __iomem *ioaddr)
> > +{
> > +	u32 v;
> > +
> > +	v = readl(ioaddr + EMAC_TX_CTL0);
> > +	v |= EMAC_TX_TRANSMITTER_EN;
> > +	writel(v, ioaddr + EMAC_TX_CTL0);
> > +
> > +	v = readl(ioaddr + EMAC_TX_CTL1);
> > +	v |= EMAC_TX_DMA_START;
> > +	v |= EMAC_TX_DMA_EN;
> > +	writel(v, ioaddr + EMAC_TX_CTL1);
> 
> This is a bit worrying. There's not a single lock in your driver,
> while you have a significant number of read / modify / write.
> 
> Where is the locking handled?
> 

All thoses function are handled by the "stmmac_ops framework", all other glue drivers does not lock anything.
The few functions that need locking already got it on the calling stmmac side.

[...]
> > +static int sun8i_dwmac_init(struct platform_device *pdev, void *priv)
> > +{
> > +	struct sunxi_priv_data *gmac = priv;
> > +	int ret;
> > +
> > +	if (gmac->regulator) {
> > +		ret = regulator_enable(gmac->regulator);
> > +		if (ret) {
> > +			dev_err(&pdev->dev, "Fail to enable regulator\n");
> > +			return ret;
> > +		}
> > +	}
> > +
> > +	ret = clk_prepare_enable(gmac->tx_clk);
> > +	if (ret) {
> > +		dev_err(&pdev->dev, "Could not enable AHB clock\n");
> 
> If that call fails, you leave the regulator (if there was any) enabled.
> 

I will fix it

> > +		return ret;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static void sun8i_dwmac_core_init(struct mac_device_info *hw, int mtu)
> > +{
> > +	void __iomem *ioaddr = hw->pcsr;
> > +	u32 v;
> > +
> > +	v = (8 << 24);/* burst len */
> > +	writel(v, ioaddr + EMAC_BASIC_CTL1);
> 
> do you need an intermediate value? you should make a define for that
> too.
> 

I will fix it

[...]
> > +static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
> > +{
> > +	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
> > +	struct device_node *node = priv->device->of_node;
> > +	int ret;
> > +	u32 reg, val;
> > +
> > +	reg = gmac->variant->default_syscon_value;
> > +
> > +	if (gmac->variant->internal_phy) {
> > +		if (!gmac->use_internal_phy) {
> > +			/* switch to external PHY interface */
> > +			reg &= ~H3_EPHY_SELECT;
> > +		} else {
> > +			reg |= H3_EPHY_SELECT;
> > +			reg &= ~H3_EPHY_SHUTDOWN;
> > +			dev_info(priv->device, "Select internal_phy %x\n", reg);
> 
> The logging level is too high
> 

I will reduce it

> > +
> > +			if (of_property_read_bool(priv->plat->phy_node,
> > +						  "allwinner,leds-active-low"))
> > +				reg |= H3_EPHY_LED_POL;
> > +			else
> > +				reg &= ~H3_EPHY_LED_POL;
> > +
> > +			ret = of_mdio_parse_addr(priv->device,
> > +						 priv->plat->phy_node);
> > +			if (ret < 0) {
> > +				dev_err(priv->device, "Could not parse MDIO addr\n");
> > +				return ret;
> > +			}
> > +			/* of_mdio_parse_addr returns a valid (0 ~ 31) PHY
> > +			 * address. No need to mask it again.
> > +			 */
> > +			reg |= ret << H3_EPHY_ADDR_SHIFT;
> > +		}
> > +	}
> > +
> > +	if (!of_property_read_u32(node, "allwinner,tx-delay", &val)) {
> 
> How do you compute it? Can't this be done through auto-training?
> 

The value is the same as used in vendor BSP kernel.
I do not understand what you mean by auto-training.

> > +		dev_info(priv->device, "set tx-delay to %x\n", val);
> 
> change the logging level here too.
> 

I agree

> > +		if (val <= SYSCON_ETXDC_MASK) {
> > +			reg &= ~(SYSCON_ETXDC_MASK << SYSCON_ETXDC_SHIFT);
> > +			reg |= (val << SYSCON_ETXDC_SHIFT);
> > +		} else {
> > +			dev_warn(priv->device, "Invalid TX clock delay: %d\n",
> > +				 val);
> 
> If it's invalid, why don't you treat it as an error and return?
> 

Ok

[...]
> > +static struct mac_device_info *sun8i_dwmac_setup(void __iomem *ioaddr,
> > +						 int mcbins,
> > +						 int perfect_uc_entries,
> > +						 int *synopsys_id)
> > +{
> > +	struct mac_device_info *mac;
> > +
> > +	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
> > +	if (!mac)
> > +		return NULL;
> 
> Do you ever free that memory?
> 

Good catch, I believed that the "stmmac framework" would free it.
I will send a fix for this memory leak.

[...]
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> > index 5ff6bc4..11db658 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> > @@ -450,6 +450,9 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
> >  		for (i = 0; i < 22; i++)
> >  			reg_space[i + 55] =
> >  			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
> > +	} else if (priv->plat->has_sun8i) {
> 
> Surely we don't want to add a new flag to the common structure for
> every new platform supported.
> 
> Can't you base that on the compatible instead?

This part will be fixed with the debugfs speaked early in the mail.

But yes I have tried to avoid use of has_sun8i at maximum.

> 
> Thanks a lot for your work,
> Maxime
> 

Thanks for the review

Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
