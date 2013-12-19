From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/9] fixed-phy: register fixed PHY as platform driver
Date: Thu, 19 Dec 2013 09:49:58 -0800
Message-ID: <CAGVrzcaHwd=jEd75NuRUAEaJC_hYyDTu-=+skPv9TTB+ShZy5Q@mail.gmail.com>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
 <1387416526-7394-2-git-send-email-hauke@hauke-m.de> <CAGVrzcYfhu1fatpPH8njc_Wh5PVpSG92aGwgsSqkaoNxEFPXxw@mail.gmail.com>
 <52B2D71E.5070101@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	netdev <netdev@vger.kernel.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:61510 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab3LSRul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 12:50:41 -0500
Received: by mail-qe0-f51.google.com with SMTP id 1so1343065qee.10
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 09:50:40 -0800 (PST)
In-Reply-To: <52B2D71E.5070101@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/19 Hauke Mehrtens <hauke@hauke-m.de>:
> On 12/19/2013 02:48 AM, Florian Fainelli wrote:
>> 2013/12/18 Hauke Mehrtens <hauke@hauke-m.de>:
>>> This changes the fixed phy driver from registering the mdio bus when
>>> the module gets loaded to registering it when a device was registered.
>>> A phy has to get registered to this driver before it registered the
>>> mdio bus, but this only worked when the phys are registered in some
>>> arch code before the system booted completely. Now we want to do so
>>> when the Ethernet driver gets initialized which could be happen every
>>> time.
>>>
>>> To make this driver work with such a case, convert it to a platform
>>> driver which could be registered every time with the phys which should
>>> be on the bus.
>>>
>>> This was only tested on BCM47XX, but not on AR7 because I do not have
>>> such a device.
>>
>> I do understand why you would want to do it that way, but I believe
>> this is should be addressed separately, outside of the actual b44
>> changes. Converting the fixed PHY driver into a platform driver also
>> has an impact on how Device Tree callers such as PowerPC would be
>> dealing with this.
>
> For the ADM switch we could initialize the fixed phy in the arch code,
> because with that switch fixed phys are always needed, but this is also
> needed for some Broadcom switches and I can not automatically detect if
> that is the case. The detection could be done  based on the board the
> kernel was booted on, but there are some hundreds different ones for
> BCM47XX.

Cannot we unconditionally register a fixed PHY at address 0 and use it whether:

- we are connected to an ADM switch
- we have a dual-MAC configuration

It seems to me like this would always work, the driver is the one
deciding which MDIO bus to bind the PHY to.

>
> Sorry I missed some calls to fixed_phy_ads() in the arch code where it
> is used by the device tree platforms, but that could be easily converted
> to a platform device as well.
>
>> Can you submit the required changes to arch/mips/bcm47xx/ for now and
>> get this change merged via David's tree? This would buy us some time
>> to discuss how to best deal with fixed PHY, and also take Device Tree
>> aware platform into account since that part has been an on-going
>> discussion for a while.
>
> What changes to arch/mips/bcm47xx/ are you talking about?

I am talking about the call to fixed_phy_add() which have to happen
early enough before the fixed MDIO bus is probed, just like what AR7
does currently.

I do agree though that something needs to be done because the fixed
MDIO bus usage comes from days where it was easy to add a call to
fixed_phy_add() early enough in your platform code, this is no longer
the case with Device Tree and such.

> Do you mean I should send the b44 patches without the fixed phy stuff
> first and then we can discuss the fixed phy stuff separately, that would
> be my next strategy? ;-)
--
Florian
