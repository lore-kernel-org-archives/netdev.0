From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv4 2/5] net: phy: extend fixed driver with
 fixed_phy_register()
Date: Thu, 3 Sep 2015 22:55:25 +0300
Message-ID: <55E8A5AD.4050908@cogentembedded.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1400249647-4643-3-git-send-email-thomas.petazzoni@free-electrons.com>
 <55E89D83.1090401@cogentembedded.com> <55E8A17C.5010401@cogentembedded.com>
 <55E8A1AB.305@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34881 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbICTza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 15:55:30 -0400
Received: by lagj9 with SMTP id j9so146714lag.2
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 12:55:28 -0700 (PDT)
In-Reply-To: <55E8A1AB.305@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2015 10:38 PM, Florian Fainelli wrote:

>>>> The existing fixed_phy_add() function has several drawbacks that
>>>> prevents it from being used as is for OF-based declaration of fixed
>>>> PHYs:
>>>>
>>>>    * The address of the PHY on the fake bus needs to be passed, while a
>>>>      dynamic allocation is desired.
>>>>
>>>>    * Since the phy_device instantiation is post-poned until the next
>>>>      mdiobus scan, there is no way to associate the fixed PHY with its
>>>>      OF node, which later prevents of_phy_connect() from finding this
>>>>      fixed PHY from a given OF node.
>>>>
>>>> To solve this, this commit introduces fixed_phy_register(), which will
>>>> allocate an available PHY address, add the PHY using fixed_phy_add()
>>>> and instantiate the phy_device structure associated with the provided
>>>> OF node.
>>>>
>>>> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>>>> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
>>>> Acked-by: Grant Likely <grant.likely@linaro.org>
>>>> ---
>>>>    drivers/net/phy/fixed.c   | 61
>>>> +++++++++++++++++++++++++++++++++++++++++++++++
>>>>    include/linux/phy_fixed.h | 11 +++++++++
>>>>    2 files changed, 72 insertions(+)
>>>>
>>>> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
>>>> index e41546d..d60d875 100644
>>>> --- a/drivers/net/phy/fixed.c
>>>> +++ b/drivers/net/phy/fixed.c
>>> [...]
>>>> @@ -203,6 +204,66 @@ err_regs:
>>> [...]
>>>> +int fixed_phy_register(unsigned int irq,
>>>> +               struct fixed_phy_status *status,
>>>> +               struct device_node *np)
>>>> +{
>>>> +    struct fixed_mdio_bus *fmb = &platform_fmb;
>>>> +    struct phy_device *phy;
>>>> +    int phy_addr;
>>>> +    int ret;
>>>> +
>>>> +    /* Get the next available PHY address, up to PHY_MAX_ADDR */
>>>> +    spin_lock(&phy_fixed_addr_lock);
>>>> +    if (phy_fixed_addr == PHY_MAX_ADDR) {
>>>> +        spin_unlock(&phy_fixed_addr_lock);
>>>> +        return -ENOSPC;
>>>> +    }
>>>> +    phy_addr = phy_fixed_addr++;
>>>> +    spin_unlock(&phy_fixed_addr_lock);
>>>> +
>>>> +    ret = fixed_phy_add(PHY_POLL, phy_addr, status);
>>>
>>>      Was rummaging in the fixed_phy driver and a bug sprang right at
>>> me: 'phy'
>>
>>     Sorry, s/phy/irq/ of course. Just noticed. :-/

    I've reported the bug on #miplsinux, there I used the correct word. :-)

> Ok, that makes sense then, and yes, this "irq" argument should have been
> passed down to fixed_phy_add(). Might be worth adding a WARN_ON(irq !=
> PHY_POLL) just to catch callers that expect something else.

    In-tree callers all seem to pass PHY_POLL to fixed_phy_register(). Do we 
care about out of tree stuff?

> Thanks!
> --
> Florian

MBR, Sergei
