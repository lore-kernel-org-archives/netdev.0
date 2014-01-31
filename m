From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: Re: [PATCH v2 4/6] can: sja1000: fuse of_platform into platform
Date: Fri, 31 Jan 2014 13:45:30 +0100
Message-ID: <52EB9AEA.4010503@epfl.ch>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-5-git-send-email-florian.vaussard@epfl.ch> <52EB9824.2010703@pengutronix.de>
Reply-To: florian.vaussard@epfl.ch
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.epfl.ch ([128.178.224.219]:59607 "EHLO smtp4.epfl.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146AbaAaMpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 07:45:34 -0500
In-Reply-To: <52EB9824.2010703@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Marc,

On 01/31/2014 01:33 PM, Marc Kleine-Budde wrote:
> On 01/31/2014 11:35 AM, Florian Vaussard wrote:
>> The OpenFirmware probe can be merged into the standard platform
>> probe to leverage common code.
> 
> Good work, as we want to replace the existing driver, I'm quite picky on
> this patch, see more comments inline.
> 
> Please don't delete of of_platform driver, yet.
> 

Do you have any reason for not deleting of_platform? After this patch,
we will have duplicated functionalities, this may be misleading for
other people.

Regards,
Florian

>> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
>> ---
>>  drivers/net/can/sja1000/Kconfig               |  13 +-
>>  drivers/net/can/sja1000/Makefile              |   1 -
>>  drivers/net/can/sja1000/sja1000_of_platform.c | 218 --------------------------
>>  drivers/net/can/sja1000/sja1000_platform.c    | 141 +++++++++++++----
>>  4 files changed, 116 insertions(+), 257 deletions(-)
>>  delete mode 100644 drivers/net/can/sja1000/sja1000_of_platform.c
> [...]
> 
>> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
>> index 779679a..96a92a1 100644
>> --- a/drivers/net/can/sja1000/sja1000_platform.c
>> +++ b/drivers/net/can/sja1000/sja1000_platform.c
>> @@ -27,12 +27,16 @@
>>  #include <linux/can/dev.h>
>>  #include <linux/can/platform/sja1000.h>
>>  #include <linux/io.h>
>> +#include <linux/of.h>
>> +#include <linux/of_irq.h>
>>  
>>  #include "sja1000.h"
>>  
>>  #define DRV_NAME "sja1000_platform"
>> +#define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
> 
> This driver uses "SP" short for sja100_platform as namespace, please
> convert.
> 
>>  
>>  MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
>> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
>>  MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
>>  MODULE_ALIAS("platform:" DRV_NAME);
>>  MODULE_LICENSE("GPL v2");
>> @@ -67,24 +71,98 @@ static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
>>  	iowrite8(val, priv->reg_base + reg * 4);
>>  }
>>  
>> -static int sp_probe(struct platform_device *pdev)
>> +static void sp_populate(struct sja1000_priv *priv,
>> +			struct sja1000_platform_data *pdata,
>> +			unsigned long resource_mem_flags)
>> +{
>> +	/* The CAN clock frequency is half the oscillator clock frequency */
>> +	priv->can.clock.freq = pdata->osc_freq / 2;
>> +	priv->ocr = pdata->ocr;
>> +	priv->cdr = pdata->cdr;
>> +
>> +	switch (resource_mem_flags & IORESOURCE_MEM_TYPE_MASK) {
>> +	case IORESOURCE_MEM_32BIT:
>> +		priv->read_reg = sp_read_reg32;
>> +		priv->write_reg = sp_write_reg32;
>> +		break;
>> +	case IORESOURCE_MEM_16BIT:
>> +		priv->read_reg = sp_read_reg16;
>> +		priv->write_reg = sp_write_reg16;
>> +		break;
>> +	case IORESOURCE_MEM_8BIT:
>> +	default:
>> +		priv->read_reg = sp_read_reg8;
>> +		priv->write_reg = sp_write_reg8;
>> +		break;
>> +	}
>> +}
>> +
>> +#if defined(CONFIG_OF)
> 
> The driver also compiles on systems without CONFIG_OF without these
> defines. Please remove.
> 
>> +static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
>>  {
>>  	int err;
>> +	u32 prop;
>> +
>> +	priv->read_reg = sp_read_reg8;
>> +	priv->write_reg = sp_write_reg8;
>> +
>> +	err = of_property_read_u32(of, "nxp,external-clock-frequency", &prop);
>> +	if (!err)
>> +		priv->can.clock.freq = prop / 2;
>> +	else
>> +		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
>> +
>> +	err = of_property_read_u32(of, "nxp,tx-output-mode", &prop);
>> +	if (!err)
>> +		priv->ocr |= prop & OCR_MODE_MASK;
>> +	else
>> +		priv->ocr |= OCR_MODE_NORMAL; /* default */
>> +
>> +	err = of_property_read_u32(of, "nxp,tx-output-config", &prop);
>> +	if (!err)
>> +		priv->ocr |= (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
>> +	else
>> +		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
>> +
>> +	err = of_property_read_u32(of, "nxp,clock-out-frequency", &prop);
>> +	if (!err && prop) {
>> +		u32 divider = priv->can.clock.freq * 2 / prop;
>> +
>> +		if (divider > 1)
>> +			priv->cdr |= divider / 2 - 1;
>> +		else
>> +			priv->cdr |= CDR_CLKOUT_MASK;
>> +	} else {
>> +		priv->cdr |= CDR_CLK_OFF; /* default */
>> +	}
>> +
>> +	if (!of_property_read_bool(of, "nxp,no-comparator-bypass"))
>> +		priv->cdr |= CDR_CBP; /* default */
>> +}
>> +#else
>> +static void sp_populate_of(struct sja1000_priv *priv, device_node *of)
>> +{
>> +}
>> +#endif
>> +
>> +static int sp_probe(struct platform_device *pdev)
>> +{
>> +	int err, irq = 0;
>>  	void __iomem *addr;
>>  	struct net_device *dev;
>>  	struct sja1000_priv *priv;
>> -	struct resource *res_mem, *res_irq;
>> +	struct resource *res_mem, *res_irq = 0;
> 
> Please use NULL to initialize pointers.
> 
>>  	struct sja1000_platform_data *pdata;
>> +	struct device_node *of = pdev->dev.of_node;
>>  
>>  	pdata = dev_get_platdata(&pdev->dev);
>> -	if (!pdata) {
>> +	if (!pdata && !of) {
>>  		dev_err(&pdev->dev, "No platform data provided!\n");
>>  		return -ENODEV;
>>  	}
>>  
>>  	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> -	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>> -	if (!res_mem || !res_irq)
>> +	if (!res_mem)
>>  		return -ENODEV;
>>  
>>  	if (!devm_request_mem_region(&pdev->dev, res_mem->start,
>> @@ -96,36 +174,34 @@ static int sp_probe(struct platform_device *pdev)
>>  	if (!addr)
>>  		return -ENOMEM;
>>  
>> +	if (of)
>> +		irq = irq_of_parse_and_map(of, 0);
>> +	else
>> +		res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>> +
>> +	if (!irq && !res_irq)
>> +		return -ENODEV;
>> +
>>  	dev = alloc_sja1000dev(0);
>>  	if (!dev)
>>  		return -ENOMEM;
>>  	priv = netdev_priv(dev);
>>  
>> -	dev->irq = res_irq->start;
>> -	priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
>> -	if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
>> -		priv->irq_flags |= IRQF_SHARED;
>> +	if (res_irq) {
>> +		irq = res_irq->start;
>> +		priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
>> +		if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
>> +			priv->irq_flags |= IRQF_SHARED;
>> +	} else
>> +		priv->irq_flags = IRQF_SHARED;
> 
> Please add { } for else, too.
> 
>> +
>> +	dev->irq = irq;
>>  	priv->reg_base = addr;
>> -	/* The CAN clock frequency is half the oscillator clock frequency */
>> -	priv->can.clock.freq = pdata->osc_freq / 2;
>> -	priv->ocr = pdata->ocr;
>> -	priv->cdr = pdata->cdr;
>>  
>> -	switch (res_mem->flags & IORESOURCE_MEM_TYPE_MASK) {
>> -	case IORESOURCE_MEM_32BIT:
>> -		priv->read_reg = sp_read_reg32;
>> -		priv->write_reg = sp_write_reg32;
>> -		break;
>> -	case IORESOURCE_MEM_16BIT:
>> -		priv->read_reg = sp_read_reg16;
>> -		priv->write_reg = sp_write_reg16;
>> -		break;
>> -	case IORESOURCE_MEM_8BIT:
>> -	default:
>> -		priv->read_reg = sp_read_reg8;
>> -		priv->write_reg = sp_write_reg8;
>> -		break;
>> -	}
>> +	if (of)
>> +		sp_populate_of(priv, of);
>> +	else
>> +		sp_populate(priv, pdata, res_mem->flags);
>>  
>>  	platform_set_drvdata(pdev, dev);
>>  	SET_NETDEV_DEV(dev, &pdev->dev);
>> @@ -156,12 +232,21 @@ static int sp_remove(struct platform_device *pdev)
>>  	return 0;
>>  }
>>  
>> +#if defined(CONFIG_OF)
> 
> Please remove the ifdef.
> 
>> +static struct of_device_id sja1000_ofp_table[] = {
> 
> Please rename into sp_of_table or something similar.
> 
>> +	{.compatible = "nxp,sja1000"},
>> +	{},
>> +};
>> +MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
>> +#endif
>> +
>>  static struct platform_driver sp_driver = {
>>  	.probe = sp_probe,
>>  	.remove = sp_remove,
>>  	.driver = {
>>  		.name = DRV_NAME,
>>  		.owner = THIS_MODULE,
>> +		.of_match_table = of_match_ptr(sja1000_ofp_table),
> 
> The of_match_ptr is not needed anymore, please remove.
> 
>>  	},
>>  };
>>  
>>
> 
> Marc
> 
