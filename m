From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link' property
Date: Tue, 30 Jul 2013 11:26:14 +0100
Message-ID: <CAGVrzcbQSKp=UCp=6HeA1XZkuzaopUNH2wX4=xgus5BNiMaXXg@mail.gmail.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130723112259.GE4833@e106331-lin.cambridge.arm.com> <20130730111604.76fd5b6e@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland@arm.com>,
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
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:33314 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab3G3K0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 06:26:55 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so100775pbc.2
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 03:26:54 -0700 (PDT)
In-Reply-To: <20130730111604.76fd5b6e@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/30 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> Dear Mark Rutland,
>
> On Tue, 23 Jul 2013 12:22:59 +0100, Mark Rutland wrote:
>
>> > +Some Ethernet MACs have a "fixed link", and are not connected to a
>> > +normal MDIO-managed PHY device. For those situations, a Device Tree
>> > +binding allows to describe a "fixed link".
>>
>> Are partictular MACs fixed link, or can some either be either fixed link
>> or wired to an MDIO-managed PHY? i.e. can we assume a given MAC is
>> fixed-link from its compatible string?
>
> No, you can't. The case that I have is that the mvneta Ethernet MAC
> (of Marvell 370/XP SOCs) is sometimes used with a MDIO-managed PHY, and
> sometimes used with a switch that isn't manageable at all and should be
> considered as a fixed link.
>
> So no, the compatible string of the Ethernet MAC cannot be used to
> determine whether we're wired fixed link or to a classical MDIO-managed
> PHY.
>
>> > +Such a fixed link situation is described within an Ethernet device
>> > +Device Tree node using a 'fixed-link' property, composed of 5
>> > +elements:
>>
>> I'm not sure grouping these values together is the best way of handling
>> this. It's rather opaque, and inflexible for future extension.
>
> That's the DT binding that has been used by PowerPC platforms since
> several years, and I've simply re-used it. See 'git grep fixed-link
> arch/powerpc/boot/dts'.
>
> I have nothing against creating another DT binding, but for a start, I
> thought using existing bindings would be the best idea.
>
>> > + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
>> > +    the system.
>>
>> Is there any reason this couldn't be allocated dynamically within the
>> kernel as needed? I don't see why an arbitrary unique value should be a
>> dt binding requirement; it seems like a leak of Linux implementation
>> details.
>
> As I pointed out in my reply to Grant, this value is used both as the
> PHY address on the fake fixed MDIO bus, and as the PHY identifier as
> reported by MII registers PHYS_ID1 and PHYS_ID2. If we can get assigned
> a proper PHY identifier that is used statically by the driver (it
> doesn't have to be different per fixed PHY instance), then we can
> allocate the PHY address dynamically. It requires a little bit of API
> changes but that's certainly doable. See my reply to Grant for a
> proposal about this.
>
>> > + 2. The duplex (1 for full-duplex, 0 for half-duplex)
>>
>> Will this change for a given MAC?
>>
>> Could we not have a boolean property for each of these, and require one
>> to be present?
>>
>> Possibly fixed-link-full-duplex / fix-link-half-duplex?
>>
>> > + 3. The speed (10, 100, 1000)
>>
>> fixed-link-speed?
>>
>> > + 4. The pause setting (1 for enabled, 0 for disabled)
>> > + 5. The asym pause setting (1 for enabled, 0 for disabled)
>>
>> Boolean properties for both of these?
>
> As Florian already answered, he already proposed something like this in
> the past, and it was rejected because a fixed PHY is not a piece of
> hardware and should therefore not be represented in the Device Tree.
> However, the fact that the MAC is not connected to a MDIO-manageable
> PHY but to some fixed-link thing is a property of the MAC hardware
> layout, and can therefore be expressed as a property of the MAC
> hardware.

True, what I *did* not like about this "fixed-link" 5 integer property
is that it does not present a consistent view of a PHY device and puts
some properties in the Ethernet MAC node, while some other are in the
Ethernet PHY node. From a hardware perspective, the Ethernet MAC and
the Ethernet PHY are two pieces of hardware, so both should get their
own node.

That said, since "fixed PHY" devices are not connected on the MDIO
bus, they cannot be represented as Ethernet PHY nodes as leafs of a
parent MDIO bus node, so maybe what we could do is having the fixed
PHY nodes child nodes of the Ethernet MAC but still make them look
like a "relatively" conventional Ethernet PHY node?

>
> See the thread that starts at
> http://article.gmane.org/gmane.linux.network/275771, and specifically
> Grant answers to Florian suggestions of having DT nodes to represent
> fixed PHY: http://article.gmane.org/gmane.linux.network/276208. Grant's
> answer was:
>
> """
> I think this discussion is going in the wrong direction. The concept
> of a dummy phy is really a Linux kernel internal detail. Creating some
> kind of dummy MDIO bus node does not describe the hardware. There is
> already support in the kernel for Ethernet MACs connected directly to
> a switch or other device. It is far better to describe how the MAC
> needs to be configured than to invent a non-existent phy. Search for
> "fixed-link" in the kernel tree to see how it is used.
> """
>
> Best regards,
>
> Thomas
> --
> Thomas Petazzoni, Free Electrons
> Kernel, drivers, real-time and embedded Linux
> development, consulting, training and support.
> http://free-electrons.com



-- 
Florian
