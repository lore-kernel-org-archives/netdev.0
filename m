From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: Allow configuration of CPU & DSA
 port speeds/duplex
Date: Mon, 24 Aug 2015 10:41:25 -0700
Message-ID: <55DB5745.6010605@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-5-git-send-email-andrew@lunn.ch> <55DA1340.9080604@gmail.com> <20150823212404.GD20710@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33685 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbbHXRny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:54 -0400
Received: by pacti10 with SMTP id ti10so28808975pac.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:54 -0700 (PDT)
In-Reply-To: <20150823212404.GD20710@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/15 14:24, Andrew Lunn wrote:
>>> +		port_dn = cd->port_dn[port];
>>> +		if (of_phy_is_fixed_link(port_dn)) {
>>> +			ret = of_phy_register_fixed_link(port_dn);
>>> +			if (ret) {
>>> +				netdev_err(master,
>>> +					   "failed to register fixed PHY\n");
>>> +				return ret;
>>> +			}
>>> +			phydev = of_phy_find_device(port_dn);
>>> +			genphy_config_init(phydev);
>>> +			genphy_read_status(phydev);
>>> +			if (ds->drv->adjust_link)
>>> +				ds->drv->adjust_link(ds, port, phydev);
>>
>> This kind of hack here because what you really need is just the link
>> parameters, but you cannot obtain such information without first
>> configuring the PHY up to a certain point in genphy_config_init(), and
>> then have genphy_read_status() copy these values in your phydev structure.
>>
>> Maybe we should really consider something like this after all:
>>
>> https://lkml.org/lkml/2015/8/5/490
> 
> Hi Florian
> 
> This half solves the problem. The nice thing about using the
> fixed_link, is that i can just call the adjust_link function with it.
> The fixed_phy_status cannot be passed directly to adjust_link. Some
> code refactoring or duplication would be needed.

Right, and using an adjust_link callback seems a little cleaner anyway
since you get an abstracted PHY device to work with.

>  
>> Or maybe, we should really introduce this "cpu" network device after all
>> with a dropping xmit function, such that we get ethtool counters to work
>> on it, and we can also attach it to a PHY device to configure link
>> parameters?
> 
> I keep humming and harring about this. I don't really like the idea of
> having an interface which you cannot send/receive packets. Yet it
> solves a number of problems like this, and gives you access to
> statistics and registers in the usual way.

Right that would be my primary motivation and use case as well.

> If we do it for the CPU
> port, we should also do it for the DSA ports. And we probably want the
> call for up to return -ENOSUP, just to make it clear it cannot be used
> for anything.

We should definitively start a separate thread for this, as there might
be real uses cases that are not yet covered that would need a network
device.

Let's go ahead with your patch for now:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
