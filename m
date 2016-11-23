From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Wed, 23 Nov 2016 17:50:23 +0100
Message-ID: <20161123165022.GD12698@gruene.netmodule.intranet>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
 <20161122183732.GD13973@gruene.netmodule.intranet>
 <20161122190206.GE14947@lunn.ch>
 <20161123120047.GC12698@gruene.netmodule.intranet>
 <87shqi89wu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:24695 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752700AbcKWQvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:51:18 -0500
Content-Disposition: inline
In-Reply-To: <87shqi89wu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

On Wed, Nov 23, 2016 at 10:59:13AM -0500, Vivien Didelot wrote:
> Hi Stefan,
> 
> Stefan Eichenberger <stefan.eichenberger@netmodule.com> writes:
> 
> >> Now, the different families are not 100% compatible with each
> >> other. We never had access to a 6097, so it has not been tested
> >> recently, and we have probably broken it... My guess would be,
> >> anywhere mv88e6xxx_6095_family(chip) is used, there also needs to be
> >> an mv88e6xxx_6097_family(chip). But i could be wrong.
> >
> > I think I probably found the problem. For EDSA type switches the bit
> > PORT_CONTROL_FORWARD_UNKNOWN_MC is set on the cpu port but not for DSA 
> > type switches. Broadcast addresses are threaded as multicast addresses, 
> > so unknown frames will never leave the switch.
> 
> The Port Control Register (0x04) is one of these registers which changes
> almost completely among chip models.
> 
> Are you able to give us the layout of the port register 0x04 on your
> 88E6097? I don't have access to its datasheet.

Yes sure, the layout of the Port Control Register for the 88E6097 is the same
as for the 88E6352:

15:14: SA Filtering: 00 -> SA filtering disabled
                     01 -> Drop on lock
                     10 -> Drop on Unlock
                     11 -> Drop to CPU
13:12: Egress Mode:  00 -> default unmodified mode
                     01 -> default to transmit all frames untagged
                     10 -> default to transmit all frames tagged
                     11 -> reserved for future use
11:    Header:       Ingress&Egress header mode (PORT_CONTROL_HEADER)
10:    IGMP Snoop:   IGMP/MLD Snooping (PORT_CONTROL_IGMP_MLD_SNOOP)
9:8    Frame Mode:   00 -> Normal Network
                     01 -> DSA (FRAME_MODE_DSA)
                     10 -> Provider (FRAME_MODE_PROVIDER)
                     11 -> Ether Type DSA (FRAME_ETHER_TYPE_DSA)
7:     VLAN Tunnel:  VLAN Tunnel (VLAN_TUNNEL)
6:     TagIfBoth:    Use tag info for QPri
5:4:   InitialPri:   00 -> Use Port defaults for FPri and QPri
                     01 -> Use Tag Priority
                     10 -> Use IP Priority
                     11 -> Use Tag & IP Priority
3:2:   Egress Floods:00 -> Do not egress any frame with unknown DA
                     01 -> Do not egress any frame with an unknown mc DA
                     10 -> Do not egress any frame with an unknown DA
                     11 -> Egress all frames with an unknown DA
                     Broadcasts are threaded as multicast if FloodBC in
                     global2 register is not set.
1:0:   PortState:    00 -> Disabled
                     01 -> Blocking/Listening
                     10 -> Learning
                     11 -> Forwarding

I hope this helps, feel free to ask for more infos.

> 
> For instance on 88E6185 bit 3 is reserved, on 88E6352 and 88E6390 bit
> 3:2 are "Egress Floods" and 0x2 means "Do not egress any frame with an
> unknown unicast DA".
> 
> > Do you know if there is a reason why this bit isn't set for DSA type
> > switches too? The patch would be extremely simple and it seems to work
> > perfectly with this bit set on the CPU port.
> 
> All these family checks for bit masking are quite messy and ideally need
> proper abstraction...
> 
> Can you give us the chunk of patch you are refering to?

I will send the patch in a few minutes.

Regards,
Stefan
