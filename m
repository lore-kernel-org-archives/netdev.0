From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Tue, 22 Nov 2016 20:02:06 +0100
Message-ID: <20161122190206.GE14947@lunn.ch>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
 <20161122183732.GD13973@gruene.netmodule.intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Eichenberger <eichest@gmail.com>,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48824 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756599AbcKVTCK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 14:02:10 -0500
Content-Disposition: inline
In-Reply-To: <20161122183732.GD13973@gruene.netmodule.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 07:37:33PM +0100, Stefan Eichenberger wrote:
> Hi Andrew
> 
> On Tue, Nov 22, 2016 at 04:03:30PM +0100, Andrew Lunn wrote:
> > On Tue, Nov 22, 2016 at 11:39:44AM +0100, Stefan Eichenberger wrote:
> > > Egress multicast and egress unicast is only enabled for CPU/DSA ports
> > > but for switching operation it seems it should be enabled for all ports.
> > > Do I miss something here?
> > > 
> > > I did the following test:
> > > brctl addbr br0
> > > brctl addif br0 lan0
> > > brctl addif br0 lan1
> > > 
> > > In this scenario the unicast and multicast packets were not forwarded,
> > > therefore ARP requests were not resolved, and no connection could be
> > > established.
> > 
> > Hi Stefan
> > 
> > This is probably specific to the 6097 family. It works fine without
> > this on other devices. Creating a bridge like above and pinging across
> > it is one of my standard tests. But i only test modern devices like
> > the 6165, 6352, 6351, 6390 families.
> 
> Okay perfect, I wasn't 100% sure if I would have to configure something
> additionally.

No. The idea is you treat the interfaces as normal interfaces. You
should not need to do anything additional to what you would do with a
normal interface, when adding it to a bridge.
 
> > In fact, you might need to review all the code and look where
> > mv88e6xxx_6095_family(chip) is used and consider if you need to add
> > mv88e6xxx_6097_family(chip). e.g.
> > 
> >         if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
> >                 /* Set the upstream port this port should use */
> >                 reg |= dsa_upstream_port(ds);
> >                 /* enable forwarding of unknown multicast addresses to
> >                  * the upstream port
> >                  */
> >                 if (port == dsa_upstream_port(ds))
> >                         reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
> >         }
> > 
> > Maybe this is your problem?
> 
> I think I still don't understand exactly how the driver works.
> 
> My problem is that the multicast and broadcast frames are filtered and
> the following counter is increasing in ethtool:
> sw_in_filtered: 596

This is not what is supposed to happen. Broadcast and multicast frames
should go to all ports in the bridge. There are two different ways
this can happen:

1) The mv88e6xxx driver started out with the host doing all bridge
operations. The switch forwards all frames to the software bridge, and
the software bridge then sends them out another port if needed.

2) We later added support for hardware bridging. That is, the switch
itself bridges frames between ports. It will only pass frames to the
software bridge if it does not know what to do with a frame itself.

Now, the different families are not 100% compatible with each
other. We never had access to a 6097, so it has not been tested
recently, and we have probably broken it... My guess would be,
anywhere mv88e6xxx_6095_family(chip) is used, there also needs to be
an mv88e6xxx_6097_family(chip). But i could be wrong.

What you might find useful is

https://github.com/vivien/linux.git 161b96bd7d16d21b0f046c935b70c3b2d277ccc2

although it might need some changes for recent commits.

With that, you can see deeper into the switches registers.

     Andrew
