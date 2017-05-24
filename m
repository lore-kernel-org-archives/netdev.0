From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 23:15:20 +0200
Message-ID: <20170524211520.GJ1788@lunn.ch>
References: <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
 <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
 <20170524140929.GC26577@lunn.ch>
 <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
 <20170524193450.GC1788@lunn.ch>
 <d6a23db1-2465-b315-f520-63aba0341fbe@quicinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@qti.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43694 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032657AbdEXVP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 17:15:29 -0400
Content-Disposition: inline
In-Reply-To: <d6a23db1-2465-b315-f520-63aba0341fbe@quicinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 03:57:06PM -0500, Timur Tabi wrote:
> On 05/24/2017 02:34 PM, Andrew Lunn wrote:
> >>Ok, I'm going to debug this some more.  It turns out that the MAC side of
> >>the SGMII link can send an interrupt when it thinks that auto-negotiation is
> >>done.  I might be able to use this.
> >
> >You can use this for your board. But it still leaves the phy driver
> >broken for everybody else.
> 
> Wait, I thought you said the at803x driver was not broken, since it
> returns 0 when the SGMII side of the link hasn't finished
> auto-negotiating?

It is correct so far. But to work, it needs to interrupt again once
the SGMII side has come up. Only then have we link.

> My NIC has a feature called autopolling where it takes over the MDIO
> bus and regularly polls the link state.  When it detects that the
> link state has changed, it generates a MAC interrupt.  This is when
> I call phy_mac_interrupt() normally.

Unfortunately, you need to keep this feature turned off. It will not
respect the phydev mutex. It has no idea what page has been currently
selected. It probably has no way to flip the page and see if the SGMII
link is up. etc.

> Can you tell my how PHY_HAS_INTERRUPT is supposed to work?  How does
> the PHY send an interrupt?

Generally, the PHY interrupt pin is connected to a GPIO. You then use
the GPIO as an interrupt source. So it has an interrupt number. Put
that in phydev->irq, eg using the interrupts property in device tree.
The core will register an interrupt handler, and enable the
interrupt. When it receives an interrupt, it calls the phy driver to
service the interrupt.

	Andrew
