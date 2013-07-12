From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Fri, 12 Jul 2013 13:05:59 +0100
Message-ID: <CAGVrzcax7gWCbdDKLdDjQDV_fOsShh+VZ9ODKO2KUBPm-zQgpQ@mail.gmail.com>
References: <20130709183312.6c4d052d@skate> <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
 <1733937.SiPWt3mDlH@lenovo> <20130710182216.0dcfaaaf@skate>
 <CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
 <20130710183951.09a0bcea@skate> <CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
 <20130712135612.0f230c1d@skate>
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
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33427 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932851Ab3GLMGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 08:06:40 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so8532017pdc.19
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 05:06:39 -0700 (PDT)
In-Reply-To: <20130712135612.0f230c1d@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/12 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:

>> Why not? Since we are already have to scan the entire MDIO bus we are
>> attached to, when we encounter such a PHY node with the special
>> "fixed" properties, we just call fixed_phy_add() with the right
>> parameters and voila. Which is also the reason why I was suggesting to
>> put the "fixed" PHY nodes as sub-nodes of the real MDIO node such that
>> we have this logic only in one place.
>
> I'm still not sure to understand you here. Scanning the *entire* DT
> tree and consider all nodes having a property named "fixed" as fixed
> PHYs is definitely not acceptable. So I suppose you have a different
> idea, but I'm still not getting it. Where in the DT would the fixed PHY
> driver start looking for fixed PHYs ?

I am talking about scanning the MDIO bus DT nodes, not the entire DT.
That job is already done by of_mdiobus_probe() to register PHY
devices, so having a central point where the knowledge of how to treat
PHY deivces could be here I guess.

>
>> > So that's really what I was asking: how is the fixed PHY driver going
>> > to know which DT nodes to look at. Is it a platform_driver, where the
>> > corresponding DT node has sub-nodes? Is it something else? Or a
>> > specific compatible string?
>>
>> Without DT at play here, the usual way to register a fixed PHY is:
>>
>> 1) make your arch code or whatever runs before the fixed MDIO bus
>> probing to call fixed_phy_add() with the expected parameters
>> 2) when your ethernet driver probes its PHY devices, format the phy
>> name to be bound to the fixed bus with the expected address by then
>> the fixed MDIO bus would have already been probed and would find the
>> fixed PHY nodes because of the first step
>> 3) call of_phy_connect() from your driver to attach to the fixed PHY
>
> Right, but that's still doesn't answer the question of how the fixed
> PHY driver discovers from the DT which PHYs to instantiate.
>
> For example, we would probably have something:
>
>         phys {
>                 phy0: phy@0 {
>                         ... PHY properties ...
>                 };
>                 phy1: phy@1 {
>                         ... PHY properties ...
>                 };
>         };
>
>         soc {
>                 ethernet@0 {
>                         compatible = "...";
>                         ...
>                         phy = <&phy0>;
>                 };
>                 ethernet@1 {
>                         compatible = "...";
>                         ...
>                         phy = <&phy1>;
>                 };
>         };
>
> How will the fixed PHY driver know that it should instantiate
> phy@0 and phy@1 as PHY devices?

Well either we go with some specific compatible property like
"ethernet-phy-fixed" for instance, or we simply add a boolean property
to the node, so a fixed PHY would either look like this:

phy {
         compatible = "linux,ethernet-phy-fixed";
         speed = <1000>;
         duplex = <1>;
         pause;
         asym-pause;
};

or respectively, something like this:

phy {
         fixed;
         speed = <1000>;
         duplex = <1>;
         pause;
         asym-pause;
};
--
Florian
