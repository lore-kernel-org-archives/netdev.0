From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link' property
Date: Tue, 23 Jul 2013 12:39:56 +0100
Message-ID: <CAGVrzcaAw4TNLUKw6L52jXY0KTHShZWS7tnP5mHHky9eFVKsYg@mail.gmail.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com> <20130723112259.GE4833@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49872 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332Ab3GWLkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 07:40:37 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so8301519pbb.19
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 04:40:36 -0700 (PDT)
In-Reply-To: <20130723112259.GE4833@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2013/7/23 Mark Rutland <mark.rutland@arm.com>:
[snip]

>> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
>> @@ -0,0 +1,26 @@
>> +Fixed link Device Tree binding
>> +------------------------------
>> +
>> +Some Ethernet MACs have a "fixed link", and are not connected to a
>> +normal MDIO-managed PHY device. For those situations, a Device Tree
>> +binding allows to describe a "fixed link".
>
> Are partictular MACs fixed link, or can some either be either fixed link
> or wired to an MDIO-managed PHY? i.e. can we assume a given MAC is
> fixed-link from its compatible string?

There are different use-cases out there:

- you lack or do not want to have a proper switch/PHY library driver
for an Ethernet switch, but that specific switch may still be
accessible on the MDIO bus, yet you just want to expose a link UP from
the CPU port perspective, that specific use case should dissapear in
favor of a simplified PHY library driver which just eventually makes
the link appear as UP from the CPU port perspective

- you have absolutely no control over the PHY on the MDIO bus
        * for switches, it could be SPI, I2C, GPIO whatever, so to
avoid any dependency, you might just want to let the link appear as UP
        * or you could have a very different PHY whose data-path is
Ethernet, but the control-path is something else, e.g: MoCA (which is
more the kind of use-case I am interested in)

>
>> +
>> +Such a fixed link situation is described within an Ethernet device
>> +Device Tree node using a 'fixed-link' property, composed of 5
>> +elements:
>
> I'm not sure grouping these values together is the best way of handling
> this. It's rather opaque, and inflexible for future extension.

Well, I proposed making them look like a "standard" Ethernet PHY node
but this somehow got rejected, see at the very bottom.

>
>> +
>> + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
>> +    the system.
>
> Is there any reason this couldn't be allocated dynamically within the
> kernel as needed? I don't see why an arbitrary unique value should be a
> dt binding requirement; it seems like a leak of Linux implementation
> details.

Honestly, I do not really think actually letting this be configurable
is a good idea because it would become some sort of user-space ABI. If
we want to expose some PHY identification registers, we could use some
ID2 and ID3 values which are not allocated to any vendor, or allocated
to the Linux foundation (e.g; like what USB does with Linux HUBs).

>
>> + 2. The duplex (1 for full-duplex, 0 for half-duplex)
>
> Will this change for a given MAC?
>
> Could we not have a boolean property for each of these, and require one
> to be present?
>
> Possibly fixed-link-full-duplex / fix-link-half-duplex?
>
>> + 3. The speed (10, 100, 1000)
>
> fixed-link-speed?
>
>> + 4. The pause setting (1 for enabled, 0 for disabled)
>> + 5. The asym pause setting (1 for enabled, 0 for disabled)
>
> Boolean properties for both of these?
>
> Thanks,
> Mark.
>
>> +
>> +Example:
>> +
>> +ethernet@0 {
>> +     ...
>> +     fixed-link = <1 1 1000 0 0>;
>> +     ...
>> +};
>> +

The initial proposal that I had suggested was this:

ethernet-phy@0 {
     reg = <0>;
     id = <0xdeadbeef>;
     speed = <1000>;
     full-duplex;
     pause;
     asym-pause;
};

which looks more or less what you seem to want as well but this
somehow makes it look like a real PHY device, so we could argue that
this has nowhere to be in the Device Tree. Arguably there are a
gazillions of other bindings which imho should also not be in a Device
Tree.
--
Florian
