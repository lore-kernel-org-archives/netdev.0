From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Thu, 17 Sep 2015 16:36:44 -0700
Message-ID: <55FB4E8C.6050307@gmail.com>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk> <55F6AA25.2070603@list.ru> <20150914114209.GL21084@n2100.arm.linux.org.uk> <20150917.151247.2129216999071943354.davem@davemloft.net> <20150917231422.GY21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, stsp@list.ru, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33765 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbIQXgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:36:49 -0400
Received: by pacex6 with SMTP id ex6so32421674pac.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 16:36:48 -0700 (PDT)
In-Reply-To: <20150917231422.GY21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/09/15 16:14, Russell King - ARM Linux wrote:

[snip]

>    with _no_ phy node.
> 
> 4. Going back to the SFP problem, the link is only up when the SFP
>    module pins indicate that there's no transmitter fault, no loss of
>    signal _and_ the PCS layer at the MAC indicates that it has completed
>    negotiation.  This pretty much rules out trying to emulate a SFP cage
>    as a software-based PHY.  I've code right now doing exactly that, and
>    it results in netif_carrier_on() being called far too early.

Andrew recently added support for having the fixed PHY emulated PHY poll
a GPIO to determine link status. If this information comes differently
(e.g: via MMIO/MAC registers) in your case, I guess we could either
extend the fixed PHY to support that scheme, or just open-code the
carrier state change in the mvneta driver.

> 
> What I don't know is how many generations of the mvneta hardware have
> support for both serdes modes, but what I'm basically saying is that
> the solution we now have seems to be somewhat lacking - maybe it should
> have been "auto", "in-band-sgmii" and "in-band-1000base-x" with the
> ability to add additional modes later.

Staas and I had quite some discussions about this topic, and I think I
changed my mind at least once about his initial proposal, but I seem to
recall that I suggested making the auto-negotiation property something
more flexible than it currently is (or maybe Staas did, and my mind
plays tricks on me).

> 
> The other point I'm making above is that I'm forming the opinion that
> the existing PHY layer isn't flexible enough for supporting SFP, and I
> need some way to represent at least part of the autonegotiation at the
> MAC level without involving the PHY level - especially when considering
> that a real PHY might be inside the SFP cage which can be talked to
> over I2C.

This is a fair conclusion, the PHY library is really designed to support
well 10/100/1000 PHYs, anything else, including 10Gbits PHY are not that
well supported. Anything that is not MDIO is not that well supported,
and the fixed PHY has its limitations.

It is unclear to me how much of the PHY library: state machine, link
management, device abstraction, and ethtool interface is going to be
useful if you have a SFP instead of a MDIO-connected PHY.

> 
> This is the problem I'm presently grappling with, and it's taking lots
> of thought right now.  I'm aware of other drivers in the kernel which
> support SFP, each using their own implementations to support that.
> 
> 
> Lastly, while looking at this, I've a small stack of patches for the PHY
> code resolving some of the issues I've mentioned above, and fixing broken
> reference counting and mdio bus module removal issues:
> 
>  phy: fixed-phy: properly validate phy in fixed_phy_update_state()
>  net: fix phy refcounting in a bunch of drivers
>  of_mdio: fix MDIO phy device refcounting
>  phy: add proper phy struct device refcounting
>  phy: fix mdiobus module safety
>  phy: fix of_mdio_find_bus() device refcount leak
> 
> I hope to be able to send those out in the next few days - they have
> nothing to do with SFP itself but are the results of looking through the
> PHY code.
> 
-- 
Florian
