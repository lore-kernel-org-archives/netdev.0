From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/2] net: davinci_mdio: allow to create phys from dt
Date: Thu, 10 Jul 2014 16:15:25 +0300
Message-ID: <53BE91ED.9020305@ti.com>
References: <1404911451-9921-1-git-send-email-grygorii.strashko@ti.com> <1404911451-9921-3-git-send-email-grygorii.strashko@ti.com> <53BD5066.4000500@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <prabhakar.csengg@gmail.com>, Sekhar Nori <nsekhar@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:41032 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbaGJM3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 08:29:03 -0400
In-Reply-To: <53BD5066.4000500@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 05:23 PM, Santosh Shilimkar wrote:
> On Wednesday 09 July 2014 09:10 AM, Grygorii Strashko wrote:
>> This patch allows to create PHYs from DT in case
>> if they are explicitly defined. The of_mdiobus_register() is
>> used for such purposes.
>>
>> For backward compatibility, call  of_mdiobus_register() only in case
>> if at least one PHY's child is defined in DT, otherwise rollback to
>> mdiobus_register().
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>   drivers/net/ethernet/ti/davinci_mdio.c |   18 ++++++++++++++++--
>>   1 file changed, 16 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
>> index 735dc53..22d3dab 100644
>> --- a/drivers/net/ethernet/ti/davinci_mdio.c
>> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
>> @@ -38,6 +38,7 @@
>>   #include <linux/davinci_emac.h>
>>   #include <linux/of.h>
>>   #include <linux/of_device.h>
>> +#include <linux/of_mdio.h>
>>   #include <linux/pinctrl/consumer.h>
>>   
>>   /*
>> @@ -95,6 +96,7 @@ struct davinci_mdio_data {
>>   	struct mii_bus	*bus;
>>   	bool		suspended;
>>   	unsigned long	access_time; /* jiffies */

	/*
	 * Indicates that driver shouldn't modify phy_mask in case
	 * if MDIO bus is registered from DT.
	 */

>> +	bool		skip_scan;
> The vairiable name is not too intutive so probably add a little
> bit description on what are you skipping with it.


Now the Davinci MDIO driver updates mii_bus->phy_mask from
its reset routine to limit number of phy addresses to be scanned.

The MDIO bus scanning has to be skipped at all in case of DT MDIO registration.
And of_mdiobus_register() maintain mii_bus->phy_mask by itself,
thus driver shouldn't touch it.

I'll add above comment. Is it ok?


> 
>>   };
>>   
>>   static void __davinci_mdio_reset(struct davinci_mdio_data *data)
>> @@ -144,6 +146,9 @@ static int davinci_mdio_reset(struct mii_bus *bus)
>>   	dev_info(data->dev, "davinci mdio revision %d.%d\n",
>>   		 (ver >> 8) & 0xff, ver & 0xff);
>>   
>> +	if (data->skip_scan)
>> +		return 0;
>> +
>>   	/* get phy mask from the alive register */
>>   	phy_mask = __raw_readl(&data->regs->alive);
>>   	if (phy_mask) {
>> @@ -369,8 +374,17 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>>   		goto bail_out;
>>   	}
>>   
>> -	/* register the mii bus */
>> -	ret = mdiobus_register(data->bus);
>> +	/* register the mii bus
>> +	 * Create PHYs from DT only in case if PHY child nodes are explicitly
>> +	 * defined to support backward compatibility with DTs which assume that
>> +	 * Davinci MDIO will always scan the bus for PHYs detection.
>> +	 */
> multi line comment is not as per coding style. Please fix that.
> Patch as such looks good to me so with those minor fixes, feel
> free to append my review tag.

will fix it.

> 
> Reviewed-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
>> +	if (dev->of_node && of_get_child_count(dev->of_node)) {
>> +		data->skip_scan = true;
>> +		ret = of_mdiobus_register(data->bus, dev->of_node);
>> +	} else {
>> +		ret = mdiobus_register(data->bus);
>> +	}
>>   	if (ret)
>>   		goto bail_out;
>>   
>>
> 
