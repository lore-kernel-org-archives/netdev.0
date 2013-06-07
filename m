From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Fri, 7 Jun 2013 10:42:28 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5C77EC@DE02WEMBXB.internal.synopsys.com>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com>
 <1505761.5DsauZd6eq@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	"Mischa Jonker" <Mischa.Jonker@synopsys.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/07/2013 12:47 PM, Arnd Bergmann wrote:
> On Tuesday 04 June 2013 16:21:50 Alexey Brodkin wrote:
>
>>   drivers/net/ethernet/Kconfig             |    1 +
>>   drivers/net/ethernet/Makefile            |    1 +
>>   drivers/net/ethernet/arc/Kconfig         |   29 +
>>   drivers/net/ethernet/arc/Makefile        |    6 +
>>   drivers/net/ethernet/arc/arc_emac_main.c |  905 ++++++++++++++++++++++++++++++
>>   drivers/net/ethernet/arc/arc_emac_main.h |   82 +++
>>   drivers/net/ethernet/arc/arc_emac_mdio.c |  181 ++++++
>>   drivers/net/ethernet/arc/arc_emac_mdio.h |   22 +
>>   drivers/net/ethernet/arc/arc_emac_regs.h |   73 +++
>
> I wonder if it would be better to name the directory "synopsys" or
> "designware" rather than "arc" now. Is there a chance that the same
> controller is used on non-arc CPUs?

The thing is - "arc_emac" is a custom ARC's (that was implemented before 
acquisition of ARC by Synopsys) IP (it's not an IC - just a part of CPU) 
Ethernet controller that only exists in some legacy FPGA boards we 
(ex-ARC and our customers) still use a lot in development process.

Synopsys itself doesn't actively sell this device so there's no point in 
putting ARC EMAC into Synopsys folder.

And indeed we don't expect this device to be used with non-ARC CPU's.

I didn't add dependency on ARC in Kconfig just because I wanted to leave 
an ability to build this driver on x86 machine. I thought this is 
important requirement - allow anybody to at least build this driver to 
make sure it builds and doesn't cause tons of warnings to appear.

If it's totally fine to add dependency on ARC - then it would be even 
easier for me - refer to the next block of comments.

>> +static int arc_emac_probe(struct platform_device *pdev)
>> +{
>> +	struct net_device *net_dev;
>> +	struct arc_emac_priv *priv;
>> +	int err;
>> +	unsigned int clock_frequency;
>> +	unsigned int id;
>> +	struct resource res_regs;
>> +#ifdef CONFIG_OF_IRQ
>> +	struct resource res_irq;
>> +#endif
>> +	const char *mac_addr = NULL;
>
> Please remove the #ifdef here. The driver does not work without this
> anyway, so better make it 'depend on OF_IRQ' in Kconfig.

As stated above I wanted to make it possible to compile on x86.
And for this I needed to:
1. Add explicit mentions of "linux/platform_device.h" because with 
existence of OF "linux/of_platform.h" has "linux/platform_device.h" 
included internally.
2. Enclose "of_irq_to_resource" and "of_get_mac_address" in ifdefs 
because neither of them has a stub for non-OF situation.

So if I may depend on ARC then I'm sure OF is selected and no need to worry.
Otherwise do I need to add stubs for "of_irq_to_resource" and 
"of_get_mac_address" somewhere in "of/of_xxx.h"?

>
>> +	/* Get phy from device tree */
>> +	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
>> +	if (!priv->phy_node) {
>> +		dev_err(&pdev->dev,
>> +			"failed to retrieve phy description from device tree\n");
>> +		err = -ENODEV;
>> +		goto out;
>> +	}
>
> You should add a binding document in Documentation/devicetree/bindings that
> describes what properties are required.

Will do.

>
>> +	/* Get EMAC registers base address from device tree */
>> +	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
>> +	if (err) {
>> +		dev_err(&pdev->dev,
>> +			"failed to retrieve base register from device tree\n");
>> +		err = -ENODEV;
>> +		goto out;
>> +	}
>> +
>> +	if (!devm_request_mem_region(&pdev->dev, res_regs.start,
>> +			resource_size(&res_regs), pdev->name)) {
>> +		dev_err(&pdev->dev,
>> +			"failed to request memory region for base registers\n");
>> +		err = -ENXIO;
>> +		goto out;
>> +	}
>> +
>> +	priv->reg_base_addr = (void *) devm_ioremap_nocache(&pdev->dev,
>> +			res_regs.start, resource_size(&res_regs));
>> +	if (!priv->reg_base_addr) {
>> +		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
>> +		err = -ENXIO;
>> +		goto out;
>> +	}
>
> This block can be simplified to a single devm_ioremap_resource() now.

Thanks for pointing-out. Definitely will make code even simpler.

>
> The cast to 'void *' is wrong: please make sure that you always use '__iomem'
> pointers for MMIO mappings. You can use 'sparse' with 'make C=1' to check this
> at build time.

Makes sense.

Regards,
Alexey
