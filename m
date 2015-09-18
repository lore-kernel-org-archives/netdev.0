From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 09:14:59 +0100
Message-ID: <20150918081459.GZ21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
 <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FB4E8C.6050307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch, stsp@list.ru,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:57358 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbIRIPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 04:15:20 -0400
Content-Disposition: inline
In-Reply-To: <55FB4E8C.6050307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 04:36:44PM -0700, Florian Fainelli wrote:
> On 17/09/15 16:14, Russell King - ARM Linux wrote:
> 
> [snip]
> 
> >    with _no_ phy node.
> > 
> > 4. Going back to the SFP problem, the link is only up when the SFP
> >    module pins indicate that there's no transmitter fault, no loss of
> >    signal _and_ the PCS layer at the MAC indicates that it has completed
> >    negotiation.  This pretty much rules out trying to emulate a SFP cage
> >    as a software-based PHY.  I've code right now doing exactly that, and
> >    it results in netif_carrier_on() being called far too early.
> 
> Andrew recently added support for having the fixed PHY emulated PHY poll
> a GPIO to determine link status. If this information comes differently
> (e.g: via MMIO/MAC registers) in your case, I guess we could either
> extend the fixed PHY to support that scheme, or just open-code the
> carrier state change in the mvneta driver.

It's not that simple.  The "is the carrier up" is the logical and of:
- no TX fault (at SFP level)
- no RX loss (at SFP level)
- Serdes says link is up (at MAC level)

If TX fault is asserted, then there is error recovery that can be done,
so it's not as simple as the MAC monitoring that GPIO - unless we want
to do what's already been done in other MAC drivers, and integrate the
SFP driver logic into the MAC driver rather than doing the same thing
and having it as a library.

> This is a fair conclusion, the PHY library is really designed to support
> well 10/100/1000 PHYs, anything else, including 10Gbits PHY are not that
> well supported. Anything that is not MDIO is not that well supported,
> and the fixed PHY has its limitations.
> 
> It is unclear to me how much of the PHY library: state machine, link
> management, device abstraction, and ethtool interface is going to be
> useful if you have a SFP instead of a MDIO-connected PHY.

Well, it gets even _more_ fun when you consider these, which are all
a very real possibility thanks to the hardware designs out there:

MAC ---SGMII---> Phy ---> Copper
MAC ---1000baseX---> Phy ---> 1000baseT Copper
MAC ---SGMII---> SFP ---> Phy ---> Copper
MAC ---SGMII---> SFP ---> Phy ---> Optical
MAC ---1000baseX---> SFP ---> Optical

                    .---1000base-X---> SFP ---> Optical
MAC ---SGMII---> Phy
                    `---> Copper

                    .---SGMII---> SFP ---> Phy ---> Optical
MAC ---SGMII---> Phy
                    `---> Copper

                    .---1000base-X---> SFP ---> Phy ---> 1000baseT Copper
MAC ---SGMII---> Phy
                    `---> Copper

                    .---SGMII---> SFP ---> Phy ---> Copper
MAC ---SGMII---> Phy
                    `---> Copper

and when you realise that you can talk to all the PHYs in those trees.
In the last four cases, the first level phy decides between the copper
connection and the "other" connection based on programmable priority.

At the moment, I only have two optical SFP modules, which fall into
the 5th setup above - you can't use SGMII with "dumb" optical modules
as SGMII's control word is an instruction from the PHY to the MAC
about the link properties, it isn't any sort of negotiation.

What I'm worried about is having to redo the DT properties, and if
the change makes it into stable trees, then we have to support the
existing design as well as whatever solution to this problem.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
