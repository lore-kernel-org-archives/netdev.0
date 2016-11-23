From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Wed, 23 Nov 2016 13:00:47 +0100
Message-ID: <20161123120047.GC12698@gruene.netmodule.intranet>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
 <20161122183732.GD13973@gruene.netmodule.intranet>
 <20161122190206.GE14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stefan Eichenberger <eichest@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:34286 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933829AbcKWMAw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:00:52 -0500
Content-Disposition: inline
In-Reply-To: <20161122190206.GE14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 08:02:06PM +0100, Andrew Lunn wrote:
> On Tue, Nov 22, 2016 at 07:37:33PM +0100, Stefan Eichenberger wrote:
> > Hi Andrew
> > 
> > On Tue, Nov 22, 2016 at 04:03:30PM +0100, Andrew Lunn wrote:
> > > On Tue, Nov 22, 2016 at 11:39:44AM +0100, Stefan Eichenberger wrote:
> > > > Egress multicast and egress unicast is only enabled for CPU/DSA ports
> > > > but for switching operation it seems it should be enabled for all ports.
> > > > Do I miss something here?
> > > > 
> > > > I did the following test:
> > > > brctl addbr br0
> > > > brctl addif br0 lan0
> > > > brctl addif br0 lan1
> > > > 
> > > > In this scenario the unicast and multicast packets were not forwarded,
> > > > therefore ARP requests were not resolved, and no connection could be
> > > > established.
> > > 
> > > Hi Stefan
> > > 
> > > This is probably specific to the 6097 family. It works fine without
> > > this on other devices. Creating a bridge like above and pinging across
> > > it is one of my standard tests. But i only test modern devices like
> > > the 6165, 6352, 6351, 6390 families.
> > 
> > Okay perfect, I wasn't 100% sure if I would have to configure something
> > additionally.
> 
> No. The idea is you treat the interfaces as normal interfaces. You
> should not need to do anything additional to what you would do with a
> normal interface, when adding it to a bridge.
>  
> > > In fact, you might need to review all the code and look where
> > > mv88e6xxx_6095_family(chip) is used and consider if you need to add
> > > mv88e6xxx_6097_family(chip). e.g.
> > > 
> > >         if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
> > >                 /* Set the upstream port this port should use */
> > >                 reg |= dsa_upstream_port(ds);
> > >                 /* enable forwarding of unknown multicast addresses to
> > >                  * the upstream port
> > >                  */
> > >                 if (port == dsa_upstream_port(ds))
> > >                         reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
> > >         }
> > > 
> > > Maybe this is your problem?
> > 
> > I think I still don't understand exactly how the driver works.
> > 
> > My problem is that the multicast and broadcast frames are filtered and
> > the following counter is increasing in ethtool:
> > sw_in_filtered: 596
> 
> This is not what is supposed to happen. Broadcast and multicast frames
> should go to all ports in the bridge. There are two different ways
> this can happen:
> 
> 1) The mv88e6xxx driver started out with the host doing all bridge
> operations. The switch forwards all frames to the software bridge, and
> the software bridge then sends them out another port if needed.
> 
> 2) We later added support for hardware bridging. That is, the switch
> itself bridges frames between ports. It will only pass frames to the
> software bridge if it does not know what to do with a frame itself.

Thanks for this explanation it helped a lot.

> 
> Now, the different families are not 100% compatible with each
> other. We never had access to a 6097, so it has not been tested
> recently, and we have probably broken it... My guess would be,
> anywhere mv88e6xxx_6095_family(chip) is used, there also needs to be
> an mv88e6xxx_6097_family(chip). But i could be wrong.

I think I probably found the problem. For EDSA type switches the bit
PORT_CONTROL_FORWARD_UNKNOWN_MC is set on the cpu port but not for DSA 
type switches. Broadcast addresses are threaded as multicast addresses, 
so unknown frames will never leave the switch.

Do you know if there is a reason why this bit isn't set for DSA type
switches too? The patch would be extremely simple and it seems to work
perfectly with this bit set on the CPU port.

Thanks
Stefan
