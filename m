From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] net: phy: smsc: disable energy detect mode
Date: Wed, 14 Oct 2015 06:17:13 +0200
Message-ID: <561DD749.9000802@denx.de>
References: <1444713189-23063-1-git-send-email-hs@denx.de>
 <561D5AC8.7040801@gmail.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, Georg.Soffel@bosch-si.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:40159 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbJNERY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 00:17:24 -0400
In-Reply-To: <561D5AC8.7040801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

Am 13.10.2015 um 21:26 schrieb Florian Fainelli:
> On 12/10/15 22:13, Heiko Schocher wrote:
>> On some boards the energy enable detect mode leads in
>> trouble with some switches, so make the enabling of
>> this mode configurable through DT.
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> ---
>>
>>   .../devicetree/bindings/net/smsc-lan87xx.txt       | 19 +++++++++++++++++
>>   drivers/net/phy/smsc.c                             | 24 +++++++++++++++++-----
>>   2 files changed, 38 insertions(+), 5 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/smsc-lan87xx.txt b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>> new file mode 100644
>> index 0000000..39aa1dc
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>> @@ -0,0 +1,19 @@
>> +SMSC LAN87xx Ethernet PHY
>> +
>> +Some boards require special tuning values. Configure them
>> +through an Ethernet OF device node.
>> +
>> +Optional properties:
>> +
>> +- disable-energy-detect:
>> +  If set, do not enable energy detect mode for the SMSC phy.
>> +  default: enable energy detect mode
>
> Although energy detection is something that is implemented by many PHYs,
> I am not sure a generic property is suitable here, I would prefix that
> with the SMSC vendor prefix here to make it clear this only applies to
> this PHY.

Hmm... but all PHYs should be able to enable, disable it in some way, or?

> Would not you want to make it a reverse property here though, something
> like this:
>
> smsc,energy-detect: boolean, when present indicates the PHY reliably
> supports energy detection

Yes, that was also my first thought, but currently, on this PHYs
energy detect mode is on ... and if I introduce such a property,
it will disable it for all existing boards, because property is
missing ... so, maybe I break boards ...

>> +
>> +Examples:
>> +
>> +	/* Attach to an Ethernet device with autodetected PHY */
>> +	&cpsw_emac0 {
>> +		phy_id = <&davinci_mdio>, <0>;
>> +		phy-mode = "mii";
>> +		disable-energy-detect;
>> +	};
>> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
>> index 70b0895..f90fbf3 100644
>> --- a/drivers/net/phy/smsc.c
>> +++ b/drivers/net/phy/smsc.c
>> @@ -43,16 +43,30 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
>>
>>   static int smsc_phy_config_init(struct phy_device *phydev)
>>   {
>> +#ifdef CONFIG_OF
>> +	int len;
>> +	struct device *dev = &phydev->dev;
>> +	struct device_node *of_node = dev->of_node;
>
> That does not need to be ifdefd out, at best annontate with __maybe_unused?

Yes, I try it.

>> +#endif
>>   	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
>> +	int enable_energy = 1;
>>
>>   	if (rc < 0)
>>   		return rc;
>>
>> -	/* Enable energy detect mode for this SMSC Transceivers */
>> -	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
>> -		       rc | MII_LAN83C185_EDPWRDOWN);
>> -	if (rc < 0)
>> -		return rc;
>> +#ifdef CONFIG_OF
>> +	if (!of_node && dev->parent->of_node)
>> +		of_node = dev->parent->of_node;
>
> That looks strange, why would the property be placed at the parent level
> when this is a PHY device tree node property?

Hmm.. I recheck this.

>> +	if (of_find_property(of_node, "disable-energy-detect", &len))
>> +		enable_energy = 0;
>> +#endif
>> +	if (enable_energy) {
>> +		/* Enable energy detect mode for this SMSC Transceivers */
>> +		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
>> +			       rc | MII_LAN83C185_EDPWRDOWN);
>> +		if (rc < 0)
>> +			return rc;
>> +	}
>>
>>   	return smsc_phy_ack_interrupt(phydev);
>>   }
>>

Thanks for your review.

bye,
Heiko

-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
