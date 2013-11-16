From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Fri, 15 Nov 2013 16:04:52 -0800
Message-ID: <CAGVrzcaKA7T7Cppg0g29wsUZBu4-6+AY+6teH1SWSiT=D7RQBQ@mail.gmail.com>
References: <523CEAD2.7030706@cogentembedded.com> <5271712A.6020105@cogentembedded.com>
 <52795282.20708@cogentembedded.com> <20131105.150153.251029756944194421.davem@davemloft.net>
 <5286C054.9090602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	nobuhiro.iwamatsu.yj@renesas.com, netdev <netdev@vger.kernel.org>,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5286C054.9090602@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/15 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 11/05/2013 11:01 PM, David Miller wrote:
>
>>>     David, will you ever reply to this mail?
>
>
>> I really haven't had the time with my backlog, and it's been so long ago
>> that I've forgotten all of the context.
>
>
>    Hm, I thought I provided enough context and also that's what mail
> archives are for... :-)
>
>
>> Sorry, someone will have to start the conversation up anew.

[snip]

>
>    Now, about the ways to deal with this issue that I see.
>    First I thought about using PHY platform fixup mechanism which is already
> hooked up to a PHY reset in phy_mii_ioctl() (the code is somewhat naive
> though as it doesn't wait for the reset completion before calling fixups and
> the driver's config_init() method).

That's something that needs fixing and also a dedicated helper or such
should be used because we are potentially messing up with the
configuration the PHY library thinks it has applied to the PHY (e.g:
disabling auto-negotiation etc...).

> All I needed is calling fixups after
> direct PHY reset done via phy_write() but I didn't want to add a hook there
> due to that reset completion wait loop that was obviously necessary (this
> function is simple *inline*), so went for a simplistic local
> phy_scan_fixups() call (that function was helpfully already exported
> although not called by anyone except phylib itself) after PHY reset in the
> 'sh_eth' driver which you saw in my patch and which you didn't like; I've
> also coded the PHY platform fixup which got successfully merged via
> arch/arm/mach-shmobile/ subtree at that time. Your argument was that the
> driver is going against the control flow provided by phylib (it's not alone
> doing PHY reset, I should note) and so you wanted me to embed everything
> into phylib control flow. I replied that I fear the unexpected consequencies
> of doing compulsory PHY reset for every driver using phylib (that's how I
> understood your idea at least)... then, after a long pause, I suggested to
> code phy_reset() function within phylib which the drivers that currently do
> reset their PHYs could use instead of open coding the reset bit polling
> loop, etc. and which would include a hook for the platform fixups and PHY
> driver config_init() call. I'd still like to hear your opinion on this
> approach -- which is less invasive.
>    What I can also do in this case is again ignore ETH_LINK signal in the
> 'sh_eth' driver and stop caring about the LED functions matching to what's
> designed for the boards. This doesn't need PHY platform fixup or any change
> in phylib and Ethernet driver.

This signal is probably present for a good reason: avoiding expensive
MDIO register access, and if that works for most platforms why not
keeping it?

>    What I also can do is stop resetting PHY in the 'sh_eth' driver (only
> getting it out of sleep for which the reset doesn't seem necessary),
> although we'd still need the PHY platform fixup for the PHY resets done via
> phy_mii_ioctl()... I'm not so much familiar with the driver to be sure it
> won't hurt (the driver is used on e.g. some SH platforms I don't get any
> access to) and I couldn't get any useful input from the driver's primary
> author -- but perhaps it's really not necessary. What do you think?

Quite a lot of PHYs actually require a reset through BMCR_RESET when
resuming from S2/S3 sleep states and even if they do not, it does not
hurt doing so, I would welcome a generic solution to do that which
would not circumvent the libphy state machine and APIs. So the general
idea would be to:

- provide a helper, e.g: phy_reset(phydev) which:
- toggles BMCR_RESET, waits for it to be clear
- call fixups on the phy_device
- call config_init on the phy_device
- restores any kind of duplex/autoneg settings we enabled/disabled
- resume the PHY state machine at the appropriate state
--
Florian
