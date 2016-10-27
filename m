From: Ray Jui <ray.jui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 4/5] net: ethernet: bgmac: add NS2 support
Date: Thu, 27 Oct 2016 15:32:34 -0700
Message-ID: <96c28572-cefd-5aff-024e-33089bf31e2f@broadcom.com>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
 <1477510561-17035-5-git-send-email-jon.mason@broadcom.com>
 <eff0c717-ec4b-1dce-992a-ad5e958800f5@gmail.com>
 <20161027205117.GA24397@broadcom.com>
 <ccbaf726-b1fc-975a-215c-17e2870328a6@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ccbaf726-b1fc-975a-215c-17e2870328a6-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 10/27/2016 3:21 PM, Ray Jui wrote:
> 
> 
> On 10/27/2016 1:51 PM, Jon Mason wrote:
>> On Wed, Oct 26, 2016 at 02:50:39PM -0700, Florian Fainelli wrote:
>>> On 10/26/2016 12:36 PM, Jon Mason wrote:
>>>> Add support for the variant of amac hardware present in the Broadcom
>>>> Northstar2 based SoCs.  Northstar2 requires an additional register to be
>>>> configured with the port speed/duplexity (NICPM).  This can be added to
>>>> the link callback to hide it from the instances that do not use this.
>>>> Also, the bgmac_chip_reset() was intentionally removed to prevent the
>>>> resetting of the chip to the default values on open.  Finally, clearing
>>>> of the pending interrupts on init is required due to observed issues on
>>>> some platforms.
>>>>
>>>> Signed-off-by: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>>>> ---
>>>
>>>> +static void bgmac_nicpm_speed_set(struct net_device *net_dev)
>>>> +{
>>>> +	struct bgmac *bgmac = netdev_priv(net_dev);
>>>> +	u32 val;
>>>> +
>>>> +	if (!bgmac->plat.nicpm_base)
>>>> +		return;
>>>> +
>>>> +	val = NICPM_IOMUX_CTRL_INIT_VAL;
>>>> +	switch (bgmac->net_dev->phydev->speed) {
>>>> +	default:
>>>> +		pr_err("Unsupported speed.  Defaulting to 1000Mb\n");
>>>> +	case SPEED_1000:
>>>> +		val |= NICPM_IOMUX_CTRL_SPD_1000M << NICPM_IOMUX_CTRL_SPD_SHIFT;
>>>> +		break;
>>>> +	case SPEED_100:
>>>> +		val |= NICPM_IOMUX_CTRL_SPD_100M << NICPM_IOMUX_CTRL_SPD_SHIFT;
>>>> +		break;
>>>> +	case SPEED_10:
>>>> +		val |= NICPM_IOMUX_CTRL_SPD_10M << NICPM_IOMUX_CTRL_SPD_SHIFT;
>>>> +		break;
>>>> +	}
>>>> +
>>>> +	writel(val, bgmac->plat.nicpm_base + NICPM_IOMUX_CTRL);
>>>> +
>>>> +	usleep_range(10, 100);
>>>
>>> Does not seem like a good idea, do you need that sleep?
>>
>> Oops, that's not supposed to be there.  Removed.
>>
>>
>>>> +
>>>> +	bgmac_adjust_link(bgmac->net_dev);
>>>> +}
>>>> +
>>>>  static int platform_phy_connect(struct bgmac *bgmac)
>>>>  {
>>>>  	struct phy_device *phy_dev;
>>>>  
>>>> -	phy_dev = of_phy_get_and_connect(bgmac->net_dev, bgmac->dev->of_node,
>>>> -					 bgmac_adjust_link);
>>>> +	if (bgmac->plat.nicpm_base)
>>>> +		phy_dev = of_phy_get_and_connect(bgmac->net_dev,
>>>> +						 bgmac->dev->of_node,
>>>> +						 bgmac_nicpm_speed_set);
>>>> +	else
>>>> +		phy_dev = of_phy_get_and_connect(bgmac->net_dev,
>>>> +						 bgmac->dev->of_node,
>>>> +						 bgmac_adjust_link);
>>>>  	if (!phy_dev) {
>>>>  		dev_err(bgmac->dev, "Phy connect failed\n");
>>>>  		return -ENODEV;
>>>>  	}
>>>>  
>>>> +	if (bgmac->feature_flags & BGMAC_FEAT_LANE_SWAP)
>>>> +		phy_dev->dev_flags |= PHY_BRCM_EXP_LANE_SWAP;
>>>> +
>>>>  	return 0;
>>>>  }
>>>>  
>>>> @@ -140,6 +188,9 @@ static int bgmac_probe(struct platform_device *pdev)
>>>>  
>>>>  	platform_set_drvdata(pdev, bgmac);
>>>>  
>>>> +	if (of_property_read_bool(np, "brcm,enet-phy-lane-swap"))
>>>> +		bgmac->feature_flags |= BGMAC_FEAT_LANE_SWAP;
>>>> +
>>>>  	/* Set the features of the 4707 family */
>>>>  	bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
>>>>  	bgmac->feature_flags |= BGMAC_FEAT_NO_RESET;
>>>> @@ -182,6 +233,14 @@ static int bgmac_probe(struct platform_device *pdev)
>>>>  	if (IS_ERR(bgmac->plat.idm_base))
>>>>  		return PTR_ERR(bgmac->plat.idm_base);
>>>>  
>>>> +	regs = platform_get_resource_byname(pdev, IORESOURCE_MEM, "nicpm_base");
>>>> +	if (regs) {
>>>> +		bgmac->plat.nicpm_base = devm_ioremap_resource(&pdev->dev,
>>>> +							       regs);
>>>> +		if (IS_ERR(bgmac->plat.nicpm_base))
>>>> +			return PTR_ERR(bgmac->plat.nicpm_base);
>>>> +	}
>>>> +
>>>>  	bgmac->read = platform_bgmac_read;
>>>>  	bgmac->write = platform_bgmac_write;
>>>>  	bgmac->idm_read = platform_bgmac_idm_read;
>>>> @@ -213,6 +272,7 @@ static int bgmac_remove(struct platform_device *pdev)
>>>>  static const struct of_device_id bgmac_of_enet_match[] = {
>>>>  	{.compatible = "brcm,amac",},
>>>>  	{.compatible = "brcm,nsp-amac",},
>>>> +	{.compatible = "brcm,ns2-amac",},
>>>>  	{},
>>>>  };
>>>>  
>>>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
>>>> index 38876ec..1796208 100644
>>>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>>>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>>>> @@ -1082,6 +1082,9 @@ static void bgmac_enable(struct bgmac *bgmac)
>>>>  /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipinit */
>>>>  static void bgmac_chip_init(struct bgmac *bgmac)
>>>>  {
>>>> +	/* Clear any erroneously pending interrupts */
>>>> +	bgmac_write(bgmac, BGMAC_INT_STATUS, ~0);
>>>> +
>>>>  	/* 1 interrupt per received frame */
>>>>  	bgmac_write(bgmac, BGMAC_INT_RECV_LAZY, 1 << BGMAC_IRL_FC_SHIFT);
>>>>  
>>>> @@ -1158,8 +1161,6 @@ static int bgmac_open(struct net_device *net_dev)
>>>>  	struct bgmac *bgmac = netdev_priv(net_dev);
>>>>  	int err = 0;
>>>>  
>>>> -	bgmac_chip_reset(bgmac);
>>>> -
>>>
>>> Is this removal intentional? Maybe it should be special cased with
>>> checking for a NS2 BGMAC instance and not do it in that case?
>>
>> The reset seems completely unnecessary.  There is already 2 resets in
>> the probe routine, another reset serves no purpose.  I can add it
>> back, as it does not seem to have the negative effect I was seeing
>> before.
> 
> After repeated ifconfig down/up, does Ethernet still work with this
> reset removed?
> 
> Thanks.
> 

Sorry, I meant to say, after removing both reset calls in the open and
close functions, does Ethernet still work after repeated ifconfig
down/up with data traffic in the background?

I would guess this reset is required, to flush out and clean up the
internal memories and state machine of the AMAC core each time before
you bring up the interface. It might also be required in the close
function, such that after the interface bring down, there's no staled
data coming out of the AMAC core. But I cannot say for sure since I do
not try this out myself.

Thanks.

>>
>> Of course, if I remove this one I should remove the reset in the close
>> too (which seems even more unnecessary, but I didn't remove it).
>>
>> Thanks,
>> Jon
>>
>>> -- 
>>> Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
