From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Wed, 10 Jul 2013 18:23:30 +0100
Message-ID: <CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
References: <20130709183312.6c4d052d@skate> <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
 <1733937.SiPWt3mDlH@lenovo> <20130710182216.0dcfaaaf@skate>
 <CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com> <20130710183951.09a0bcea@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"grant.likely" <grant.likely@secretlab.ca>, afleming@freescale.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:45262 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab3GJRYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 13:24:21 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so6529308pdj.8
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 10:24:20 -0700 (PDT)
In-Reply-To: <20130710183951.09a0bcea@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/10 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> Dear Florian Fainelli,
>
> On Wed, 10 Jul 2013 17:29:44 +0100, Florian Fainelli wrote:
[snip]

>
>> >                 };
>> >
>> >                 phy1: ethernet-phy@1 {
>> >                         ... all the properties you listed ...
>> >                         ... maybe the "id" property is not needed
>> >                             because of the phandle ...
>> >                 };
>> >         };
>> >
>> >         soc {
>> >                 ethernet@0 {
>> >                         phy = <&phy0>;
>> >                         ...
>> >                 };
>> >
>> >                 ethernet@1 {
>> >                         phy = <&phy1>;
>> >                         ...
>> >                 };
>> >         };
>> >
>> > or do you have in mind another representation?
>>
>> Not really this is more or less what I had in mind. I am wondering
>> whether we should really declare the "mdio-fixed" node, or if we
>> should not rather make the following:
>>
>> - declare all PHY nodes in the system as sub nodes of their belonging
>> real hardware MDIO bus node
>> - flag specific PHY nodes as "fixed" with a "fixed-link" boolean for instance
>> - if we see that flag, make that specific PHY node bind to the
>> fixed-phy driver instead
>
> So the fixed PHY driver is going to travel through *all* nodes of the
> DT, and whenever some random node has a "fixed" property, it's going to
> say it corresponds to a fixed PHY? That doesn't seem like a good idea.

Why not? Since we are already have to scan the entire MDIO bus we are
attached to, when we encounter such a PHY node with the special
"fixed" properties, we just call fixed_phy_add() with the right
parameters and voila. Which is also the reason why I was suggesting to
put the "fixed" PHY nodes as sub-nodes of the real MDIO node such that
we have this logic only in one place.

>
> So that's really what I was asking: how is the fixed PHY driver going
> to know which DT nodes to look at. Is it a platform_driver, where the
> corresponding DT node has sub-nodes? Is it something else? Or a
> specific compatible string?

Without DT at play here, the usual way to register a fixed PHY is:

1) make your arch code or whatever runs before the fixed MDIO bus
probing to call fixed_phy_add() with the expected parameters
2) when your ethernet driver probes its PHY devices, format the phy
name to be bound to the fixed bus with the expected address by then
the fixed MDIO bus would have already been probed and would find the
fixed PHY nodes because of the first step
3) call of_phy_connect() from your driver to attach to the fixed PHY

>
>> What do you think? I suspect someone might rightfully say that the
>> "fixed-mdio" is not a real piece of hardware and is just a software
>> concept. A PHY in the real world may very well have a fixed link
>> speed/duplex/pause settings on the other end.
>
> I agree that the mdio-fixed idea is clearly moving away from the
> hardware representation. But see my question above: we need a way of
> letting the fixed PHY driver know which DT nodes it should have a look
> at. And just saying "those nodes will have property 'foo' is not
> sufficient".
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
