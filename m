From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 18:01:24 +0200
Message-ID: <20170824160124.GA18700@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824155241.GF28443@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 05:52:41PM +0200, Antoine Tenart wrote:
> Hi Andrew,
> 
> On Thu, Aug 24, 2017 at 04:56:09PM +0200, Andrew Lunn wrote:
> > On Thu, Aug 24, 2017 at 10:38:19AM +0200, Antoine Tenart wrote:
> > > This patch adds logic to reconfigure the comphy/gop when the link status
> > > change at runtime. This is very useful on boards such as the mcbin which
> > > have SFP and Ethernet ports connected to the same MAC port: depending on
> > > what the user connects the driver will automatically reconfigure the
> > > link mode.
> > 
> > I would expect each of these external Ethernet ports to have its own
> > Ethernet PHY. Don't you need to disconnect from one Ethernet phy and
> > connect to the other Ethernet PHY when you change external Ethernet
> > port?
> 
> That's the other way around. The engines outputs (say GoP#) are
> connected to the comphy inputs. In the SoC. Then there's a single output
> of this comphy lane to the board. So when switching modes, you do not
> have to connect to a different Ethernet PHY, it's the same.

Hi Antoine

I think there is a mixup here between generic PHY and Ethernet PHY.

When you swap from the copper RJ45 to the fibre SFP, the phylib needs
to swap from the Copper Ethernet PHY driving the RJ45, to the PHY
driving the SFP module, which is probably a fixed-phy.

I actually think this is why you have the carrier_on/off calls in the
link modify callback.

Imagine phylib is using the copper Ethernet PHY, but the MAC is using
the SFP port. Somebody pulls out the copper cable, phylib says the
link is down, turns the carrier off and calls the callback. Not good,
since your SFP cable is still plugged in...  Ethtool is
returning/setting stuff in the Copper Ethernet PHY, when in fact you
intend to be setting SFP settings.

       Andrew
