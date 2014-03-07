From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH v2] sky2: allow mac to come from dt
Date: Fri, 7 Mar 2014 12:08:29 -0800
Message-ID: <CAJ+vNU0uM_-EMe9nqbyEqMkNQ1j0uRf5giO=n0NvA5Ao5Twjxw@mail.gmail.com>
References: <1394059512-1691-1-git-send-email-tharvey@gateworks.com>
	<20140307.143622.1002770704528601574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:52719 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbaCGUIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 15:08:31 -0500
Received: by mail-we0-f172.google.com with SMTP id t61so5737289wes.17
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 12:08:30 -0800 (PST)
In-Reply-To: <20140307.143622.1002770704528601574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 7, 2014 at 11:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Tim Harvey <tharvey@gateworks.com>
> Date: Wed,  5 Mar 2014 14:45:12 -0800
>
>> @@ -4748,6 +4750,7 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>>  {
>>       struct sky2_port *sky2;
>>       struct net_device *dev = alloc_etherdev(sizeof(*sky2));
>> +     unsigned char *iap, tmpaddr[ETH_ALEN];
>>
>>       if (!dev)
>>               return NULL;
>> @@ -4805,8 +4808,17 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>>
>>       dev->features |= dev->hw_features;
>>
>> -     /* read the mac address */
>> -     memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
>> +     /* try to get mac address in the following order:
>> +      * 1) from device tree data
>> +      * 2) from internal registers set by bootloader
>> +      */
>> +     iap = of_get_mac_address(hw->pdev->dev.of_node);
>> +     if (!iap) {
>> +             memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
>> +                           ETH_ALEN);
>> +             iap = tmpaddr;
>> +     }
>> +     ether_addr_copy(dev->dev_addr, iap);
>
> As Stephen Hemminger suggested do this like:
>
>         iap = of_get_mac_address(hw->pdev->dev.of_node);
>         if (iap)
>                 memcpy(dev->dev_addr, iap, ETH_ALEN);
>         else
>                 memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
>                               ETH_ALEN);
>
> That way you don't need the on-stack buffer.

Thanks for the suggestion - I will re-send a v3 shortly.

Tim
