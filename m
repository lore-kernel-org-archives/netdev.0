From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 19:34:59 -0500
Message-ID: <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Sullivan <nathan.sullivan@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160428212315.GC12753@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 11:23:15PM +0200, Andrew Lunn wrote:
> On Thu, Apr 28, 2016 at 04:03:57PM -0500, Josh Cartwright wrote:
> > On Thu, Apr 28, 2016 at 08:59:32PM +0200, Andrew Lunn wrote:
> > > On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
> > > > On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
> > > > > > I agree that is a valid fix for AT91, however it won't solve our problem, since
> > > > > > we have no children on the second ethernet MAC in our devices' device trees. I'm
> > > > > > starting to feel like our second MAC shouldn't even really register the MDIO bus
> > > > > > since it isn't being used - maybe adding a DT property to not have a bus is a
> > > > > > better option?
> > > > > 
> > > > > status = "disabled"
> > > > > 
> > > > > would be the unusual way.
> > > > > 
> > > > >       Andrew
> > > > 
> > > > Oh, sorry, I meant we use both MACs on Zynq, however the PHYs are on the MDIO
> > > > bus of the first MAC.  So, the second MAC is used for ethernet but not for MDIO,
> > > > and so it does not have any PHYs under its DT node.  It would be nice if there
> > > > were a way to tell macb not to bother with MDIO for the second MAC, since that's
> > > > handled by the first MAC.
> > > 
> > > Yes, exactly, add support for status = "disabled" in the mdio node.
> > 
> > Unfortunately, the 'macb' doesn't have a "mdio node", or alternatively:
> > the node representing the mdio bus is the same node which represents the
> > macb instance itself.  Setting 'status = "disabled"' on this node will
> > just prevent the probing of the macb instance.
> 
> :-(
> 
> It is very common to have an mdio node within the MAC node, for example imx6sx-sdb.dtsi

Okay, I think that makes sense.  I think, then, perhaps the solution to
our problem is to:

  1. Modify the macb driver to support an 'mdio' node. (And adjust the
     binding document accordingly).  If the node is found, it's used for
     of_mdiobus_register() w/o any of the manual scan madness.
  2. For backwards compatibility, in the case where an 'mdio' node does
     not exist, leave the existing behavior the way it is now
     (of_mdiobus_register() followed by manual scan) [perhaps warn of
     deprecation as well?]
  3. Update binding docs to reflect the above.

In this way, for our usecase, the 'status = "disabled"' in the newly
created 'mdio' node isn't necessary.  It's sufficient for the node to
exist and be empty.

> &fec1 {
>         pinctrl-names = "default";
>         pinctrl-0 = <&pinctrl_enet1>;
>         phy-supply = <&reg_enet_3v3>;
>         phy-mode = "rgmii";
>         phy-handle = <&ethphy1>;
>         status = "okay";
> 
>         mdio {
>                 #address-cells = <1>;
>                 #size-cells = <0>;
> 
>                 ethphy1: ethernet-phy@1 {
>                         reg = <1>;
>                 };
> 
>                 ethphy2: ethernet-phy@2 {
>                         reg = <2>;
>                 };
>         };
> };
> 
> &fec2 {
>         pinctrl-names = "default";
>         pinctrl-0 = <&pinctrl_enet2>;
>         phy-mode = "rgmii";
>         phy-handle = <&ethphy2>;
>         status = "okay";
> };
> 
> This even has the two phys on one bus, as you described...

Yep...looks nearly exactly the same case.

Thanks,
  Josh
