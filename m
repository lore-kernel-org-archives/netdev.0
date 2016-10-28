From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] lan78xx: Use irq_domain for phy interrupt from
 USB Int. EP
Date: Fri, 28 Oct 2016 12:01:30 -0700
Message-ID: <919da0a4-3a5c-8c88-bab5-6fc2bf557a48@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40956B56@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net,
        netdev@vger.kernel.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35544 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755815AbcJ1TBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:01:33 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so1952373pfj.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:01:33 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40956B56@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2016 11:54 AM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> To utilize phylib with interrupt fully than handling some of phy stuff in the MAC driver,
> create irq_domain for USB interrupt EP of phy interrupt and
> pass the irq number to phy_connect_direct() instead of PHY_IGNORE_INTERRUPT.
> 
> Idea comes from drivers/gpio/gpio-dl2.c
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---

> +static void lan78xx_irq_mask(struct irq_data *irqd)
> +{
> +	struct irq_domain_data *data = irq_data_get_irq_chip_data(irqd);
> +	struct lan78xx_net *dev =
> +			container_of(data, struct lan78xx_net, domain_data);
> +	u32 buf;
> +
> +	lan78xx_read_reg(dev, INT_EP_CTL, &buf);

lan78xx_read_reg() uses kmalloc() with GFP_KERNEL, while
irq_mask/irq_unmask can be called in atomic context AFAIR, you may need
to pass down a specific gfp_t to lan78xx_read_reg.

What about usb_submit_urb(), can that work in atomic context? Do you
need to have lan78xx_read_reg() acquire a raw spinlock or something to
serialize them?

> +	buf &= ~INT_EP_PHY_INT_EN_;

Even though you may have only one interrupt line to deal with at the
moment, better make this bit derived from irqd->hwirq instead of hard
coding it here.

> +	lan78xx_write_reg(dev, INT_EP_CTL, buf);
> +}
> +
> +static void lan78xx_irq_unmask(struct irq_data *irqd)
> +{
> +	struct irq_domain_data *data = irq_data_get_irq_chip_data(irqd);
> +	struct lan78xx_net *dev =
> +			container_of(data, struct lan78xx_net, domain_data);
> +	u32 buf;
> +
> +	lan78xx_read_reg(dev, INT_EP_CTL, &buf);
> +	buf |= INT_EP_PHY_INT_EN_;

Same here, this should come from irqd->hwirq.

> +	lan78xx_write_reg(dev, INT_EP_CTL, buf);
> +}
> +
> +static struct irq_chip lan78xx_irqchip = {
> +	.name		= "lan78xx-phyirq",
> +	.irq_mask	= lan78xx_irq_mask,
> +	.irq_unmask	= lan78xx_irq_unmask,
> +};
> +
> +static int lan78xx_setup_irq_domain(struct lan78xx_net *dev)
> +{
> +	struct device_node *of_node;
> +	struct irq_domain *irqdomain;
> +	unsigned int irq_base = 0;
> +	int ret = 0;
> +
> +	of_node = dev->udev->dev.parent->of_node;
> +
> +	dev->domain_data.irqchip = &lan78xx_irqchip;
> +	dev->domain_data.irq_handler = handle_simple_irq;
> +
> +	irqdomain = irq_domain_add_simple(of_node, 1, 0, &chip_domain_ops,
> +					  &dev->domain_data);

Is there really just one interrupt associated with this peripheral here?

>  
> +	if (lan78xx_setup_irq_domain(dev) < 0) {
> +		netdev_warn(dev->net, "lan78xx_setup_irq_domain() failed");
> +		return -EIO;
> +	}

Any reason not to propagate the error code from
lan78xx_setup_irq_domain() here?

-- 
Florian
