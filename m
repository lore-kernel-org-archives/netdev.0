From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Sun, 22 Apr 2012 13:31:48 +0200
Message-ID: <CAOiHx=nG_v11LWoc39236aPyFOjOPXJQz6BVNSVqmXhv_jKDVA@mail.gmail.com>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
 <1334753296.5185.3.camel@sakura.staff.proxad.net> <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
 <1334842380.5185.29.camel@sakura.staff.proxad.net> <CAOiHx==f0czkaEVTe=+wabQMmifdaN00PMQwaR8f-602Dq56pA@mail.gmail.com>
 <1334852238.5185.40.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: mbizon@freebox.fr, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45845 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2DVLcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 07:32:09 -0400
Received: by iadi9 with SMTP id i9so730503iad.19
        for <netdev@vger.kernel.org>; Sun, 22 Apr 2012 04:32:08 -0700 (PDT)
In-Reply-To: <1334852238.5185.40.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 April 2012 18:17, Maxime Bizon <mbizon@freebox.fr> wrote:
>
> On Thu, 2012-04-19 at 16:52 +0200, Jonas Gorski wrote:
>
>> Yes, but none of the ethtool functions cause register writes in the
>> priv->has_phy = true case when in PHY_READY or PHY_HALTED state. All
>> they do is modify the phy_device's settings.
>
> unless I'm mistaken:
>
> phy_ethtool_sset() => phy_start_aneg()
>
> will kick the state machine even when state is PHY_READY

Hmm. I see what you mean. I wonder if it is intended that you can do
that without having phy_start() called first.

@Andy, can you perhaps shed some light on this? How are ethernet
drivers supposed to behave/when should they call
phy_connect()/phy_start()? Currently most drivers call phy_connect()
in their _probe(), and phy_start() in _open(), so many seem to have
the issue that the phy state machine is in PHY_READY after _probe(),
and can be kicked into running through ethtool even if the interface
is down.

This problem goes away after the first ifup/ifdown cycle, since the
phy state machine is then in PHY_HALTED, which gets properly caught in
phy_start_aneg().

To me it looks like phy_start_aneg() should check for some more
states, as it currently would also overwrite a PHY_STARTING or
PHY_PENDING state, which looks definitely wrong to me.


Jonas
