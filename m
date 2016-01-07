From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/26] Phylink & SFP support
Date: Thu, 07 Jan 2016 12:42:56 -0800
Message-ID: <568ECDD0.7080307@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <20151215072621.GA6953@cumulusnetworks.com> <25790BAC-5B24-4702-87AF-0772F12630E3@gmail.com> <20151228233955.GB3796@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Dustin Byford <dustin@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36301 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbcAGUnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:43:31 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so174675067pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:43:31 -0800 (PST)
In-Reply-To: <20151228233955.GB3796@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/12/15 15:39, Dustin Byford wrote:
>> Using a phandle here allows for quite a lot of flexibility on how you want to associate a given SFP to its data plane partner. I do not think we need to get more strict than that strictly mandate an actual Ethernet controller node. These Marvell adapters typically have one or more " ports", each of them being backed by a netdev. The same could be true with a switch properly modeled.
> 
> On a switch though, the number of "ports" is often configurable.
> Physically the q/sfp cage to ASIC wiring is fixed, but when you've
> plugged in a breakout cable you get four "ports" for a single QSFP cage.
> They act like four separate devices in most ways, the notable exception
> is that they share a QSFP module eeprom and the discrete IOs to the cage
> like "reset" and "interrupt"  At the MAC layer, each port gets an
> independent set of resources and they act like separate netdevs.
> 
> A concrete proposal might be to add a "channel" or "lane" parameter to
> sfp,ethernet with a default of 0.
> 
> sfp,ethernet = <&eth2>
> 
> is equivalent to:
> sfp,ethernet = <&eth2 0>
> 
> 
> SFP on a switch0 device with 128 channels:
> 
> sfp,ethernet = <&switch0 42>
> consumes channel 42
> 
> qsfp,ethernet = <&switch0>
> consumes channels 0-3
> 
> qsfp,ethernet = <&switch0 124 125 126 127>
> consumes channels 124-127
> 
> alternatives:
> 
> (less explicit, assume adjacent channels)
> qsfp,ethernet = <&switch0 124> // consumes 124-127

Right, that does not sound specific enough, because the name is qsfp,
that means quad, and then you do 124 + 4 - 1 to know the last number,
what could possibly go wrong ;)?

> 
> (more explicit, don't assume the same device)
> qsfp,ethernet = <&switch0 124 &switch0 125 &switch0 126 &switch0 127>
> or:
> qsfp,ethernet0 = <&switch0 124>
> qsfp,ethernet1 = <&switch0 125>
> qsfp,ethernet2 = <&switch0 126>
> qsfp,ethernet3 = <&switch0 127>

That might be the best representation actually.

> 
> (move complexity to the NIC/ASIC, ensure one channel per handle on the
> NIC/ASIC side)
> qsfp,ethernet = <&switch0c124 &switch0c125 &switch0c126 &switch0c127>

So counting the number of cells tells you how the QSFP got broken out
into individual SFPs? That could work too, humm.

[snip]

>> Would this be something you expect to happen dynamically? Not that this does not seem reasonable but would these netdevs serve a different purpose than being control endpoints, or would they become real logical netdevs with separate data planes at the MAC they would be linked to?
> 
> Real netdevs with separate data planes.  Reconfiguring them dynamically
> seems like a good theoretical goal but is probably impractical in most
> cases.  Even if it's not dynamic I think it's a good example of why you
> might want a QSFP device to have an ethernet handle that points to four
> things instead of one.

Agreed.
-- 
Florian
