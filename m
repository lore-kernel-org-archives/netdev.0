From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V2 1/7] net: sxgbe: add basic framework for Samsung
 10Gb ethernet driver
Date: Wed, 12 Mar 2014 15:10:08 +0000
Message-ID: <20140312151008.GA5035@e106331-lin.cambridge.arm.com>
References: <005101cf3df6$e37664f0$aa632ed0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.kallam@samsung.com" <siva.kallam@samsung.com>,
	"vipul.pandya@samsung.com" <vipul.pandya@samsung.com>,
	"ks.giri@samsung.com" <ks.giri@samsung.com>,
	"ilho215.lee@samsung.com" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:47086 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750737AbaCLPKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:10:16 -0400
Content-Disposition: inline
In-Reply-To: <005101cf3df6$e37664f0$aa632ed0$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 01:28:00PM +0000, Byungho An wrote:
> From: Siva Reddy <siva.kallam@samsung.com>
> 
> This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> 
> - sxgbe core initialization
> - Tx and Rx support
> - MDIO support
> - ISRs for Tx and Rx
> - ifconfig support to driver
> 
> Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
> Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
> Signed-off-by: Girish K S <ks.giri@samsung.com>
> Neatening-by: Joe Perches <joe@perches.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---

[...]

> diff --git a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> new file mode 100644
> index 0000000..f2abf65
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt

Please split the binding into a separate patch from the code (it makes
it far easier for us DT guys to find that portions relevant to use).

Is there any public documentation?

> @@ -0,0 +1,39 @@
> +* Samsung 10G Ethernet driver (SXGBE)
> +
> +Required properties:
> +- compatible: Should be "samsung,sxgbe-v2.0a"
> +- reg: Address and length of the register set for the device
> +- interrupt-parent: Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- interrupts: Should contain the SXGBE interrupts

How many, in which order, what are each of them for?

> +- samsung,burst-map        Program the possible bursts supported by sxgbe
> +- samsung,fixed-burst  Program the DMA to use the fixed burst mode
> +- samsung,adv-addr-mode        program the DMA to use Enhanced address mode

What are valid values?

Units/types?

Please describe what these actually do.

> +- samsung,force_thresh_dma_mode        Force DMA to use the threshold mode
> for
> +                               both tx and rx

Odd formatting here.

s/_/-/ in property names please.

When and why should this property be set in a dt?

> +- samsung,force_sf_dma_mode    Force DMA to use the Store and Forward
> +                               mode for both tx and rx. This flag is
> +                               ignored if force_thresh_dma_mode is set.

Likewise, for all points.

[...]

> +/* Clean the tx descriptor as soon as the tx irq is received */
> +static void sxgbe_release_tx_desc(struct sxgbe_tx_norm_desc *p)
> +{
> +       memset(p, 0, sizeof(struct sxgbe_tx_norm_desc));

You can use sizeof(*p) here.

[...]

> +static int sxgbe_probe_config_dt(struct platform_device *pdev,
> +                                struct sxgbe_plat_data *plat,
> +                                const char **mac)
> +{
> +       struct device_node *np = pdev->dev.of_node;
> +       struct sxgbe_dma_cfg *dma_cfg;
> +       u32 phy_addr;
> +
> +       if (!np)
> +               return -ENODEV;
> +
> +       *mac = of_get_mac_address(np);

I see that of_get_mac_address returns a *void rather than *char, but
it's always a string of hex digits. Would it make sense to change the
of_get_mac_address prototype to return a char* ?

> +       plat->interface = of_get_phy_mode(np);
> +
> +       plat->bus_id = of_alias_get_id(np, "ethernet");
> +       if (plat->bus_id < 0)
> +               plat->bus_id = 0;

This wasn't mentioned in the binding.

> +
> +       of_property_read_u32(np, "samsung,phy-addr", &plat->phy_addr);

Neither was this.

> +
> +       plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
> +                                          sizeof(struct
> sxgbe_mdio_bus_data),
> +                                          GFP_KERNEL);
> +
> +       if (of_device_is_compatible(np, "samsung,sxgbe-v2.0a"))
> +               plat->pmt = 1;

Only one compatible string is documented. When would this _not_ be the
case?

[...]

> +static int sxgbe_platform_probe(struct platform_device *pdev)
> +{
> +       int ret = 0;
> +       int loop = 0;
> +       int index1, index2;
> +       struct resource *res;
> +       struct device *dev = &pdev->dev;
> +       void __iomem *addr = NULL;
> +       struct sxgbe_priv_data *priv = NULL;
> +       struct sxgbe_plat_data *plat_dat = NULL;
> +       const char *mac = NULL;
> +       int total_dma_channels = SXGBE_TX_QUEUES + SXGBE_RX_QUEUES;
> +
> +       /* Get memory resource */
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       if (!res)
> +               return -ENODEV;
> +
> +       addr = devm_ioremap_resource(dev, res);
> +       if (IS_ERR(addr))
> +               return PTR_ERR(addr);
> +
> +       plat_dat = pdev->dev.platform_data;

This is a new dt-driven driver. Why would you need additional platform
data? Why can this information not come from dt?

> +       if (pdev->dev.of_node) {
> +               if (!plat_dat)
> +                       plat_dat = devm_kzalloc(&pdev->dev,
> +                                               sizeof(struct
> sxgbe_plat_data),
> +                                               GFP_KERNEL);
> +               if (!plat_dat)
> +                       return  -ENOMEM;
> +
> +               ret = sxgbe_probe_config_dt(pdev, plat_dat, &mac);
> +               if (ret) {
> +                       pr_err("%s: main dt probe failed\n", __func__);
> +                       return ret;
> +               }
> +       }
> +
> +       priv = sxgbe_dvr_probe(&(pdev->dev), plat_dat, addr);
> +       if (!priv) {
> +               pr_err("%s: main driver probe failed\n", __func__);
> +               return -ENODEV;
> +       }
> +
> +       /* Get MAC address if available (DT) */
> +       if (mac)
> +               ether_addr_copy(priv->dev->dev_addr, mac);
> +
> +       /* Get the SXGBE common INT information */
> +       priv->dev->irq  = irq_of_parse_and_map(dev->of_node, loop++);
> +       if (priv->dev->irq <= 0) {
> +               dev_err(dev, "sxgbe common irq parsing failed\n");
> +               return -EINVAL;
> +       }

So the first IRQ is assumed to be a common interrupt...

> +
> +       /* Get the TX/RX IRQ numbers */
> +       for (index1 = 0, index2 = 0 ; loop < total_dma_channels; loop++) {
> +               if (loop < SXGBE_TX_QUEUES) {
> +                       (priv->txq[index1])->irq_no  =
> +                               irq_of_parse_and_map(dev->of_node, loop);

then there's a TX IRQ for each queue, in order...

> +                       if ((priv->txq[index1++])->irq_no <= 0) {
> +                               dev_err(dev, "sxgbe tx irq parsing
> failed\n");
> +                               return -EINVAL;
> +                       }
> +               } else {
> +                       (priv->rxq[index2])->irq_no  =
> +                               irq_of_parse_and_map(dev->of_node, loop);

then an RX IRQ for each queue, in order.

That should be in the binding document.

Cheers,
Mark.
