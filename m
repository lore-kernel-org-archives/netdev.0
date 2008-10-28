From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 09:46:00 +0200
Message-ID: <4906C338.6010300@teltonika.lt>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <20081027143734.GA13565@secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:47759 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752577AbYJ1HqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 03:46:20 -0400
In-Reply-To: <20081027143734.GA13565@secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely wrote:
> On Mon, Oct 27, 2008 at 12:53:22PM +0200, Paulius Zaleckas wrote:
>> Useful for machines where PHY control is connected to GPIO.
>> This driver also supports interrupts from PHY.
>>
>> Changes since v1:
>> - fixed releasing of gpio (thanks to Sascha Hauer)
>> - fixed compiling due to bus->dev to bus->parent change
>>
>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
>> ---
> 
> Well structured driver.  Comments below.

Thanks for review.

>> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
>> new file mode 100644
>> index 0000000..585897b
>> --- /dev/null
>> +++ b/drivers/net/phy/mdio-gpio.c

[...]

> 
>> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
>> +{
>> +	struct mii_bus *new_bus;
>> +	struct mdio_gpio_info *bitbang;
>> +	struct mdio_gpio_platform_data *pdata;
>> +	int ret = -ENOMEM;
>> +	int i;
>> +
>> +	pdata = pdev->dev.platform_data;
>> +	if (pdata == NULL)
>> +		goto out;
>> +
>> +	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
>> +	if (!bitbang)
>> +		goto out;
>> +
>> +	bitbang->ctrl.ops = &mdio_gpio_ops;
>> +	bitbang->mdc = pdata->mdc;
>> +	bitbang->mdio = pdata->mdio;
>> +
>> +	if (gpio_request(bitbang->mdc, "mdc"))
>> +		goto out_free_bitbang;
>> +
>> +	if (gpio_request(bitbang->mdio, "mdio"))
>> +		goto out_free_mdc;
>> +
>> +	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
>> +	if (!new_bus)
>> +		goto out_free_gpio;
>> +
>> +	new_bus->name = "GPIO Bitbanged MII",
>> +	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
>> +
>> +	new_bus->phy_mask = ~0;
>> +	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
>> +	if (!new_bus->irq)
>> +		goto out_free_bus;
> 
> The IRQ array is fixed size.  You can add it to the mdio_gpio_info
> structure and then just set the pointer here so that only one kzalloc
> is needed.

It can be put in mdio_gpio_info, but please note that mdio_gpio_info is
allocated with kzalloc() and irq with kmalloc(), because there is no need
to fill this array with zeros(see below).

>> +
>> +	for (i = 0; i < PHY_MAX_ADDR; i++)
>> +		new_bus->irq[i] = PHY_POLL;
>> +
>> +	for (i = 0; i < pdata->nr_phys; i++) {
>> +		unsigned int phy_addr = pdata->phys[i].addr;
>> +
>> +		BUG_ON(phy_addr >= PHY_MAX_ADDR);
> 
> Is it really worth bringing down the whole kernel when too many phys are
> specified in pdata?
> 
>> +
>> +		new_bus->phy_mask &= ~(1 << phy_addr);
>> +		new_bus->irq[phy_addr] = pdata->phys[i].irq;
>> +	}
>> +
>> +	new_bus->parent = &pdev->dev;
>> +	platform_set_drvdata(pdev, new_bus);
>> +
>> +	ret = mdiobus_register(new_bus);
>> +	if (ret)
>> +		goto out_free_all;
>> +
>> +	return 0;
