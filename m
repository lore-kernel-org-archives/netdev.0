From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mdio: of_mdio: check for already registered phy
 before creating new instances
Date: Wed, 7 May 2014 10:26:14 -0700
Message-ID: <CAGVrzcZL7w8vRQ6-3NEqLK3VFHa-c1BMUVoaWSKmD2RXRedMCw@mail.gmail.com>
References: <1399389711-32716-1-git-send-email-zonque@gmail.com>
 <CAGVrzcY+3xeDzMAe1683+ypF59eMN9oTss6LC_rLShuEpmC4NA@mail.gmail.com> <536A58EF.4070206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:42260 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaEGR0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 13:26:55 -0400
Received: by mail-qa0-f42.google.com with SMTP id j5so1335961qaq.29
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 10:26:54 -0700 (PDT)
In-Reply-To: <536A58EF.4070206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

2014-05-07 9:01 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> (+ Mugunthan V N)
>
> Hi Florian,
>
> On 05/07/2014 02:55 AM, Florian Fainelli wrote:
>> 2014-05-06 8:21 GMT-07:00 Daniel Mack <zonque@gmail.com>:
>>> In of_mdiobus_register_phy(), check if the phy with the given address is
>>> already registered within the mii bus before calling phy_device_create()
>>> or get_phy_device().
>>
>> I am not exactly sure how you could be in that sort of situation.
>> of_mdiobus_register() handles two different cases at the moment:
>>
>> 1) PHY child nodes have a valid 'reg' property, and this property is
>> used to register the PHY at the given address
>> 2) if a PHY child node does not have a valid 'reg' property, which
>> will trigger an auto-scan and then we iterate through all 32 addresses
>> of the bus, we skip over PHYs that are already registered
>>
>>>
>>> This allows us to augment auto-probed phy devices with extra information
>>> via DT. Without this patch, a second instance of the phydev is created
>>> unnecessarily.
>>
>> Which piece of code is doing the auto-probing in your case? One of the
>> very first things that of_mdiobus_register() does is set the PHY mask
>> to 0xffffffff to prevent the default PHY probing method to trigger,
>> since we are using information from the Device Tree right after that.
>
> Ah, ok. So what happens here is that of_mdiobus_register() sets the
> phy_mask to ~0, but mdiobus_register() calls bus->reset(), which resets
> the mask to ffffffef in my case. bus->reset is davinci_mdio_reset() in
> my case.

I see, something similar exists with TI's CPMAC driver too, where the
MDIO bus can tell you which MDIO slave is alive.

>
> Is the davinci mdio driver doing anything wrong by touching
> bus->phy_mask?

Not really, I think it is valid to do this as part of the
mdiobus_reset() callback. This worked much better with non-DT
configurations because nothing would override the phy_mask.

> Another solution would be to split mdiobus_register() and
> create a mdiobus_register_noscan() or something, and then call that from
> of_mdiobus_register().

That, or have a specific MDIO bus controller node boolean property
such as  "mdio-bus-autoscan" or something similar which will tell
of_mdiobus_register() not to override the phy_mask since the MDIO bus
controller is capable of auto-detecting the PHYs present.

This should not be too controversial as we should really be describing
a feature of the hardware here.

What do you think?
-- 
Florian
