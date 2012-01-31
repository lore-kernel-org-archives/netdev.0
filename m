From: Heiko Schocher <hs@denx.de>
Subject: Re: [RFC PATCH 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Tue, 31 Jan 2012 12:27:11 +0100
Message-ID: <4F27D00F.4040807@denx.de>
References: <1327308967-8092-1-git-send-email-hs@denx.de>
 <1327308967-8092-5-git-send-email-hs@denx.de>
 <20120130202208.GW28397@ponder.secretlab.ca>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>, Wolfgang Denk <wd@denx.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.relay.invitel.net ([62.77.203.4]:36982 "EHLO
	b.relay.invitel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2AaL1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 06:27:17 -0500
In-reply-to: <20120130202208.GW28397@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Grant,

Grant Likely wrote:
> On Mon, Jan 23, 2012 at 09:56:04AM +0100, Heiko Schocher wrote:
>> add of support for the davinci_emac driver.
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> Cc: davinci-linux-open-source@linux.davincidsp.com
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: devicetree-discuss@lists.ozlabs.org
>> Cc: netdev@vger.kernel.org
>> Cc: Grant Likely <grant.likely@secretlab.ca>
>> Cc: Sekhar Nori <nsekhar@ti.com>
>> Cc: Wolfgang Denk <wd@denx.de>
>> ---
>>  .../bindings/arm/davinci/davinci_emac.txt          |   46 ++++++++
>>  drivers/net/ethernet/ti/davinci_emac.c             |  111 +++++++++++++++++++-
>>  2 files changed, 156 insertions(+), 1 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>>
>> diff --git a/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>> new file mode 100644
>> index 0000000..4e5dc8d
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>> @@ -0,0 +1,46 @@
>> +* Texas Instruments Davinci EMAC
>> +
>> +This file provides information, what the davice node
>> +for the davinci_emac interface contain.
>> +
>> +Required properties:
>> +- compatible: "ti,davinci-emac";
>> +- reg: Offset and length of the register set for the device
>> +- ctrl_reg_offset: offset to control register
>> +- ctrl_mod_reg_offset: offset to control module register
>> +- ctrl_ram_offset: offset to control module ram
> 
> Should these be explicit properties, or can they be discerned from the
> compatible string (which should include the hardware version; see
> below).

Hmm.. I do not know all davinci SoCs ... maybe someone from TI
could answer this? But I think, we could discern this from
the compatible string. I prepare this for v2. Maybe it is Ok,
if I do this only for my hardwareversion and others add this,
if needed? (maybe the better approach, as I can code it, but
have no hw for testing it ... so it maybe is buggy)

> Also, any custom properties that are specific to a binding really
> should include a vendor prefix ('ti,') to avoid namespace collisions
> with common bindings.

Yep, is "ti,davinci-" ok? Also I should use dashes instead
underscores, right?

>> +- hw_ram_addr: hardware ram addr
> 
> Can this be added as a second tuple in the reg property?

No, if I know this right, this is used for DMA, and also could be RAM.

>> +- ctrl_ram_size: size of control module ram
>> +- version: 1 (EMAC_VERSION_1 for DM644x)
>> +           2 (EMAC_VERSION_2 for DM646x)
> 
> Don't use a version property.  Encode it into the compatible property.  ie:
> 
> compatible = "ti,davinci-dm6440-emac"; or
> compatible = "ti,davinci-dm6460-emac";
> 
> You'll also note that I did not use a 'x' as a wildcard.  It is always
> safer to be explicit about the part number.  And have newer parts
> claim compatibility with older ones like so:
> 
> compatible = "ti,davinci-dm6443-emac", "ti,davinci-dm6440-emac"; (I am
> obviously making up numbers here.  Fill in appropriate numbers for
> your device.

Ok.

[...]
>> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
>> index 794ac30..cad7a96 100644
>> --- a/drivers/net/ethernet/ti/davinci_emac.c
>> +++ b/drivers/net/ethernet/ti/davinci_emac.c
>> @@ -58,6 +58,12 @@
[...]
>> +	pdata = pdev->dev.platform_data;
>> +	if (!pdata) {
>> +		pdata = kzalloc(sizeof(struct emac_platform_data), GFP_KERNEL);
> 
> devm_kzalloc()

fixed.

>> +		if (!pdata)
>> +			goto nodata;
>> +	}
>> +
>> +	mac_addr = of_get_mac_address(np);
>> +	if (mac_addr)
>> +		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
>> +
>> +	ret = of_property_read_u32(np, "ctrl_reg_offset", &data);
>> +	if (!ret)
>> +		pdata->ctrl_reg_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "ctrl_mod_reg_offset", &data);
>> +	if (!ret)
>> +		pdata->ctrl_mod_reg_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "ctrl_ram_offset", &data);
>> +	if (!ret)
>> +		pdata->ctrl_ram_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "hw_ram_addr", &data);
>> +	if (!ret)
>> +		pdata->hw_ram_addr = data;
>> +
>> +	ret = of_property_read_u32(np, "ctrl_ram_size", &data);
>> +	if (!ret)
>> +		pdata->ctrl_ram_size = data;
>> +
>> +	ret = of_property_read_u32(np, "rmii_en", &data);
>> +	if (!ret)
>> +		pdata->rmii_en = data;
>> +
>> +	ret = of_property_read_u32(np, "version", &data);
>> +	if (!ret)
>> +		pdata->version = data;
>> +
>> +	ret = of_property_read_u32(np, "no_bd_ram", &data);
>> +	if (!ret)
>> +		pdata->ctrl_mod_reg_offset = data;
> 
> Not all these properties are mentioned in the documentation.

fixed.

>> +
>> +	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
>> +	if (!priv->phy_node)
>> +		pdata->phy_id = "";
>> +
>> +	if (!of_address_to_resource(np, 0, &temp_res))
>> +		memcpy(&pdev->resource[0], &temp_res, sizeof(struct resource));
> 
> Don't use of_address_to_resource.  The platform device resource table
> will already be populated by the core code so you don't need to call
> it here.  Besides, it is illegal for drivers to overwrite the
> pdev->resource[] table.

fix this.

>> +
>> +	index = 0;
>> +	while (index < 4) {
>> +		irq = irq_of_parse_and_map(np, index);
>> +		if (irq > 0) {
>> +			temp_res.start = irq;
>> +			temp_res.end = irq;
>> +			temp_res.flags = IORESOURCE_IRQ;
>> +			memcpy(&pdev->resource[index + 1], &temp_res,
>> +				sizeof(struct resource));
> 
> Same here, the core code will have already populated the irqs into the
> resource table for you.

and this. Currently it don't work after this fix, searching
for the reason ...

>> +		}
>> +		index++;
>> +	}
>> +
>> +	pinmux_np = of_parse_phandle(np, "pinmux-handle", 0);
>> +	if (pinmux_np)
>> +		davinci_cfg_reg_of(pinmux_np);
>> +
>> +	pdev->dev.platform_data = pdata;
>> +nodata:
>> +	return  pdata;
>> +}
>> +#else
>> +static struct emac_platform_data
>> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
>> +	struct emac_priv *priv)
>> +{
>> +	return  pdev->dev.platform_data;
>> +}
>> +#endif
>>  /**
>>   * davinci_emac_probe: EMAC device probe
>>   * @pdev: The DaVinci EMAC device that we are removing
>> @@ -1802,7 +1910,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>>  
>>  	spin_lock_init(&priv->lock);
>>  
>> -	pdata = pdev->dev.platform_data;
>> +	pdata = davinci_emac_of_get_pdata(pdev, priv);
>>  	if (!pdata) {
>>  		dev_err(&pdev->dev, "no platform data\n");
>>  		rc = -ENODEV;
>> @@ -1811,6 +1919,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>>  
>>  	/* MAC addr and PHY mask , RMII enable info from platform_data */
>>  	memcpy(priv->mac_addr, pdata->mac_addr, 6);
>> +
> 
> Nit: There are a few instances of unrelated whitespace changes in this
> patch.

fixed.

Thanks for the review!

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
