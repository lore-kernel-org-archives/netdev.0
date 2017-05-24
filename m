From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 21:34:50 +0200
Message-ID: <20170524193450.GC1788@lunn.ch>
References: <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
 <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
 <20170524140929.GC26577@lunn.ch>
 <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43606 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936992AbdEXTez (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 15:34:55 -0400
Content-Disposition: inline
In-Reply-To: <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 01:58:09PM -0500, Timur Tabi wrote:
> On 05/24/2017 09:09 AM, Andrew Lunn wrote:
> > It could be, the copper side is up, but the SGMII side is down, at the
> > point at803x_aneg_done() is called. So it is correctly returning
> > 0. Sometime later the SGMII side goes up, but there is not a second
> > interrupt. Hence the phy core does not know that the full, 2 stage MAC
> > to PHY to peer PHY link is now up.
> 
> Ok, I'm going to debug this some more.  It turns out that the MAC side of
> the SGMII link can send an interrupt when it thinks that auto-negotiation is
> done.  I might be able to use this.

You can use this for your board. But it still leaves the phy driver
broken for everybody else.
 
> What function should my MAC driver call when it wants the phy core to call
> at803x_aneg_done again to see if autonegotiation is done?

You want to trigger the PHY state machine. There is only one exported
API call to do this, phy_mac_interrupt(). But you are supposed to pass
the new link state. And your MAC driver has no idea of that, it does
not know if the copper side of the PHY is up.

So it might be better if you export phy_trigger_machine().

> Also, is there a way for the MAC driver to know that at803x_aneg_done()
> previously returned 0, and that it needs to tell the phy core to check again?

Not that i know of. The MAC layer is not supposed to be messing around
in the PHY layer. However, just triggering the PHY state machine
should be enough.

   Andrew
