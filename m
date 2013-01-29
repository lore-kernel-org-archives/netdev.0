From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 3/5] net: mvmdio: enhance driver to support SMI
 error/done interrupts
Date: Tue, 29 Jan 2013 16:39:57 +0100
Message-ID: <20130129163957.79815ff7@skate>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
	<1359473048-26551-4-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1359473048-26551-4-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Florian Fainelli,

On Tue, 29 Jan 2013 16:24:06 +0100, Florian Fainelli wrote:

>  #define MVMDIO_SMI_DATA_SHIFT              0
>  #define MVMDIO_SMI_PHY_ADDR_SHIFT          16
> @@ -36,12 +40,28 @@
>  #define MVMDIO_SMI_WRITE_OPERATION         0
>  #define MVMDIO_SMI_READ_VALID              BIT(27)
>  #define MVMDIO_SMI_BUSY                    BIT(28)
> +#define MVMDIO_ERR_INT_CAUSE		   0x007C
> +#define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
> +#define MVMDIO_ERR_INT_MASK		   0x0080
>  
>  struct orion_mdio_dev {
>  	struct mutex lock;
>  	void __iomem *regs;
> +	/*
> +	 * If we have access to the error interrupt pin (which is
> +	 * somewhat misnamed as it not only reflects internal errors
> +	 * but also reflects SMI completion), use that to wait for
> +	 * SMI access completion instead of polling the SMI busy bit.
> +	 */
> +	int err_interrupt;
> +	wait_queue_head_t smi_busy_wait;
>  };
>  
> +static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
> +{
> +	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
> +}
> +
>  /* Wait for the SMI unit to be ready for another operation
>   */
>  static int orion_mdio_wait_ready(struct mii_bus *bus)
> @@ -50,19 +70,30 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
>  	int count;
>  	u32 val;
>  
> -	count = 0;
> -	while (1) {
> -		val = readl(dev->regs);
> -		if (!(val & MVMDIO_SMI_BUSY))
> -			break;
> -
> -		if (count > 100) {
> -			dev_err(bus->parent, "Timeout: SMI busy for too long\n");
> -			return -ETIMEDOUT;
> +	if (dev->err_interrupt == NO_IRQ) {
> +		count = 0;
> +		while (1) {
> +			val = readl(dev->regs);
> +			if (!(val & MVMDIO_SMI_BUSY))
> +				break;

What about using your new orion_mdio_smi_is_done() function here?

> +
> +			if (count > 100) {
> +				dev_err(bus->parent,
> +					"Timeout: SMI busy for too long\n");
> +				return -ETIMEDOUT;
> +			}
> +
> +			udelay(10);
> +			count++;
>  		}
> +	}
>  
> -		udelay(10);
> -		count++;
> +	if (!orion_mdio_smi_is_done(dev)) {

Maybe it should be in an else if block so that the waitqueue case is
only considered if there is an IRQ registered? Of course practically
speaking, it's OK because if there is no IRQ, we'll wait in the polling
loop above, and either exit from the function on timeout, or continue
on success. But it still would make the code a little bit clearer, I'd
say.

>  static int orion_mdio_probe(struct platform_device *pdev)
>  {
>  	struct device_node *np = pdev->dev.of_node;
> @@ -181,6 +227,19 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  		return -ENODEV;
>  	}
>  
> +	dev->err_interrupt = NO_IRQ;

Not needed, you already do dev->err_interrupt = something() below.

> +	init_waitqueue_head(&dev->smi_busy_wait);
> +
> +	dev->err_interrupt = irq_of_parse_and_map(pdev->dev.of_node, 0);
> +	if (dev->err_interrupt != NO_IRQ) {
> +		ret = devm_request_irq(&pdev->dev, dev->err_interrupt,
> +					orion_mdio_err_irq,
> +					IRQF_SHARED, pdev->name, dev);
> +		if (!ret)
> +			writel(MVMDIO_ERR_INT_SMI_DONE,
> +					dev->regs + MVMDIO_ERR_INT_MASK);
> +	}
> +
>  	mutex_init(&dev->lock);
>  
>  	ret = of_mdiobus_register(bus, np);
> @@ -202,6 +261,8 @@ static int orion_mdio_remove(struct platform_device *pdev)
>  	struct mii_bus *bus = platform_get_drvdata(pdev);
>  	struct orion_mdio_dev *dev = bus->priv;
>  
> +	writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
> +	free_irq(dev->err_interrupt, dev);

free_irq() not needed since the IRQ handler is registered with
devm_request_irq().

>  	mdiobus_unregister(bus);
>  	kfree(bus->irq);
>  	mdiobus_free(bus);

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
