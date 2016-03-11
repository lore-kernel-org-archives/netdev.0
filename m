From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Fri, 11 Mar 2016 15:41:59 -0800
Message-ID: <56E357C7.7090309@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <56D88757.7050803@gmail.com> <20160303202716.GQ15541@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32839 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcCKXnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:43:33 -0500
Received: by mail-pa0-f41.google.com with SMTP id fl4so110391249pad.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:43:32 -0800 (PST)
In-Reply-To: <20160303202716.GQ15541@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/16 12:27, Andrew Lunn wrote:
>> - first of all, the original design around the special platform device
>> did not allow multiple switch trees within the same system to coexist
>> (dsa platform device were not numbered (id = -1)), but such a thing
>> could exist and is desirable, you could have a single switch hanging off
>> eth0, and more switches hanging off eth1 for instance, and not be part
>> of the same tree
> 
> I have hardware i can test such a setup on. 
> 
>>
>> - the direction we want to move people to is to make them use DSA for
>> their switch needs and get the proven benefits from having a consistent
>> per-port slave network device model along with a good binding for
>> representing ports within a switch (and all thedetails associated with
>> that), the next step is to make this available to not just MDIO drivers,
>> which you are addressing here, but then, being able to call
>> dsa_switch_register() just becomes a service from the network stack with
>> DSA support included, if we need the special dsa platform device again,
>> we are not way better than where we were before
> 
> We are a bit better. dsa_switch_register() does not care about the
> communication channel to the switch. An SPI based switch should now be
> possible, as well as a cleaner way to do MMIO switches.

Right, thanks to your patch series and recent efforts, and that is
exactly the direction we want.

[snip]

> 
> The third switch is as you would expect, dsa,member = <0 2>;

I like that representation.

> 
> The probe order does not actually matter. You allocate the dst when
> the first switch arrives, and plug that switch in. You then evaluate
> the dst. Are all dsa links fulfilled. If yes, you have the full tree,
> and you can set it up and running. If no, wait until more switches are
> registered.

So does that mean you agree we do not need the DSA platform device
anymore :)? If not, why, and how much help from the Device Tree do we
need to instantiate that special "dsa" platform device?

> 
> This is quite a big change, so why not make it bigger...
> 
> One thing i don't like is the complexity we have in matching phys to
> ports, and fixed-link phys. Maybe we should consolidate this:

Very true, we support a wide variety of setups, and that creates a lot
of complexity that could probably be absorbed by a more generic helper
function?

> 
> 1) The switch device should use mdiobus_alloc()/mdiobus_register() for
> its own MDIO bus.

Agreed, possibly with the help of the DSA slave code, since some of that
is already doing its magic for most drivers here.

> 2) ports use phy-handle to point to phys on their own mdio bus.

I would refrain from needing that unless the mapping between Port and
built-in PHY is design/board-level configurable, or we connect to PHYs
external to the switch which are not located on its own internal MDIO
bus controller.
-- 
Florian
