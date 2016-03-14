From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Mon, 14 Mar 2016 12:36:18 -0700
Message-ID: <56E712B2.9010905@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <56D88757.7050803@gmail.com> <20160303202716.GQ15541@lunn.ch>
 <56E357C7.7090309@gmail.com> <20160312170827.GA2186@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33744 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbcCNThz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:37:55 -0400
Received: by mail-pf0-f177.google.com with SMTP id 124so143053092pfg.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 12:37:55 -0700 (PDT)
In-Reply-To: <20160312170827.GA2186@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/16 09:08, Andrew Lunn wrote:
>> [snip]
>>
>>>
>>> The third switch is as you would expect, dsa,member = <0 2>;
>>
>> I like that representation.
>>
> 
> ...
> 
>> So does that mean you agree we do not need the DSA platform device
>> anymore :)?
> 
> It looks like it can be	done without the DSA platform device.
> 
> My previous approach was to keep the new binding as similar as
> possible to the current one. If however, we decide we are going for
> something totally new, we can remove this platform device.

The old binding can and should remain available, we just don't want to
match it anymore using a generic DSA platform device, but that does not
prevent a driver using the old binding to get a struct dsa_platform_data
to be properly filed if it was using it through dsa_of_probe(). With the
networking stack offfering resident code to deal with DSA, we could also
warn if we see a node in tree with "marvell,dsa".

The new binding looks very similar to the previous one and this is
certainly a good thing to do. With that in mind the new binding should
probably be keeping the per-port Device Tree node representation and
properties, because that one seems correct, the parts that had gone
wrong were definitively the "reg" property and the dsa,mii-bus property
if not the dsa,ethernet as well, but code will talk.

> 
> It probably means we need to turn slave.c and parts of dsa.c into a
> library. Add a new dsa_v2.c file, containing the new binding
> code. With things like having the switch devices instantiate there own
> MDIO bus, fixed phys on a compatible MDIO bus referenced via phandles,
> etc, I hope we can make parts of the dsa_v2 simpler.

Looks like we still need to get this one ironed out.

> 
>> Very true, we support a wide variety of setups, and that creates a lot
>> of complexity that could probably be absorbed by a more generic helper
>> function?
> 
> No, i want to go the other direction. Make all these phy setups look
> identical. It is just a phy-handle=<&phandle> property. With my MDIO
> fixed-phy bus patches, it just works for user ports, and the only
> thing we need to deal with is phy-mode.
> 
> DSA and CPU ports are harder, due to a lack of a netdev. Horrible, but
> maybe would could do a alloc_netdev(), but never register_netdev()?
> It gives us something to attach the phy to.

Humm, I suppose that could work, in practice, having a full-fledged
"cpu" network device would be more useful than having e.g: eth0, now
being the conduit interface, because that one, really is useless to
applications because it needs a tag to be applied and there is nothing
doing that. Food for thought.

> 
>>> 1) The switch device should use mdiobus_alloc()/mdiobus_register() for
>>> its own MDIO bus.
>>
>> Agreed, possibly with the help of the DSA slave code, since some of that
>> is already doing its magic for most drivers here.
> 
> I think the switch driver should instantiate the MDIO bus, not the
> core. The core could however offer some helper code.

Works for me.
-- 
Florian
