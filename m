From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 12:56:19 -0500
Message-ID: <20160428175619.GA8791@nathan3500-linux-VM>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160428163207.GP29024@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 06:32:07PM +0200, Andrew Lunn wrote:
> > Hmm, are AT91 platforms special in this regard? As far as I can tell, this
> > driver (macb) and Marvell PXA are the only ethernet drivers that call
> > mdiobus_scan directly, and PXA does it on a known address. I do see that there
> > are trees that use macb and don't have a phy listed, which is unfortunate.
> 
> How it is supposed to work is that you do one of two things:
> 
> 1) Your device tree does not have an mdio node. In this case, you call
> mdiobus_register() and it will perform a scan of the bus, and find the
> phys.
> 
> 2) Your device tree does have an MDIO node, and you list your PHYs.
> 
> Having an MDIO node and not listing the PHYs is broken...
> 
> There are however, a few broken device trees around, and a few drivers
> have workarounds. e.g. davinci_mdio.c
> 
>        /* register the mii bus
>          * Create PHYs from DT only in case if PHY child nodes are explicitly
>          * defined to support backward compatibility with DTs which assume that
>          * Davinci MDIO will always scan the bus for PHYs detection.
>          */
>         if (dev->of_node && of_get_child_count(dev->of_node)) {
>                 data->skip_scan = true;
>                 ret = of_mdiobus_register(data->bus, dev->of_node);
>         } else {
>                 ret = mdiobus_register(data->bus);
>         }
> 
> You probably need to do the same for AT91, count the number of
> children, and it if it zero, fall back to the non-DT way. It would
> also be good to print a warning to get people to fix their device
> tree.
> 
>     Andrew

I agree that is a valid fix for AT91, however it won't solve our problem, since
we have no children on the second ethernet MAC in our devices' device trees. I'm
starting to feel like our second MAC shouldn't even really register the MDIO bus
since it isn't being used - maybe adding a DT property to not have a bus is a
better option?
