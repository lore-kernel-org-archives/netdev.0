From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Tue, 24 Apr 2012 14:05:58 -0500
Message-ID: <CAKWjMd4e07+guAJAEh1w2MrMGu5+deOYzBbmSMGPdjyE5jZjFQ@mail.gmail.com>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
	<1334753296.5185.3.camel@sakura.staff.proxad.net>
	<CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
	<1334842380.5185.29.camel@sakura.staff.proxad.net>
	<CAOiHx==f0czkaEVTe=+wabQMmifdaN00PMQwaR8f-602Dq56pA@mail.gmail.com>
	<1334852238.5185.40.camel@sakura.staff.proxad.net>
	<CAOiHx=nG_v11LWoc39236aPyFOjOPXJQz6BVNSVqmXhv_jKDVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mbizon@freebox.fr, Andy Fleming <afleming@freescale.com>,
	netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54119 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2DXTF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 15:05:59 -0400
Received: by pbbro12 with SMTP id ro12so453171pbb.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 12:05:59 -0700 (PDT)
In-Reply-To: <CAOiHx=nG_v11LWoc39236aPyFOjOPXJQz6BVNSVqmXhv_jKDVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 22, 2012 at 6:31 AM, Jonas Gorski <jonas.gorski@gmail.com> wrote:
> On 19 April 2012 18:17, Maxime Bizon <mbizon@freebox.fr> wrote:
>>
>> On Thu, 2012-04-19 at 16:52 +0200, Jonas Gorski wrote:
>>
>>> Yes, but none of the ethtool functions cause register writes in the
>>> priv->has_phy = true case when in PHY_READY or PHY_HALTED state. All
>>> they do is modify the phy_device's settings.
>>
>> unless I'm mistaken:
>>
>> phy_ethtool_sset() => phy_start_aneg()
>>
>> will kick the state machine even when state is PHY_READY
>
> Hmm. I see what you mean. I wonder if it is intended that you can do
> that without having phy_start() called first.
>
> @Andy, can you perhaps shed some light on this? How are ethernet
> drivers supposed to behave/when should they call
> phy_connect()/phy_start()? Currently most drivers call phy_connect()
> in their _probe(), and phy_start() in _open(), so many seem to have
> the issue that the phy state machine is in PHY_READY after _probe(),
> and can be kicked into running through ethtool even if the interface
> is down.
>
> This problem goes away after the first ifup/ifdown cycle, since the
> phy state machine is then in PHY_HALTED, which gets properly caught in
> phy_start_aneg().
>
> To me it looks like phy_start_aneg() should check for some more
> states, as it currently would also overwrite a PHY_STARTING or
> PHY_PENDING state, which looks definitely wrong to me.

Ugh, it looks like much has gone wrong with the state machine
(possibly from when I wrote it). I'm thinking that what we should
probably do is eliminate PHY_UP and PHY_READY, and have the PHY come
up to PHY_HALTED. For some reason, PHY_RESUMING always enables
interrupts, even if phydev->irq is in POLL mode, so that should be
fixed.

Other than that, it looks like PHY_RESUMING should work in the place
of PHY_UP, and PHY_HALTED should be the same as PHY_READY...

Andy
