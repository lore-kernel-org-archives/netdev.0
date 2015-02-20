From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Thu, 19 Feb 2015 16:09:35 -0800
Message-ID: <20150220000935.GA30118@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:44123 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbbBTAJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 19:09:40 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YObA3-000Oqo-Av
	for netdev@vger.kernel.org; Fri, 20 Feb 2015 00:09:39 +0000
Content-Disposition: inline
In-Reply-To: <54E676DD.9090003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 03:50:53PM -0800, Florian Fainelli wrote:
> On 19/02/15 09:46, Guenter Roeck wrote:
> > On Thu, Feb 19, 2015 at 09:27:23AM -0800, Florian Fainelli wrote:
> >> On 18/02/15 21:59, Guenter Roeck wrote:
> >>> On Wed, Feb 18, 2015 at 06:48:19PM -0800, Florian Fainelli wrote:
> >>>> On 17/02/15 11:26, Florian Fainelli wrote:
> >>>>> Update the Broadcom Starfighter 2 switch driver to implement the
> >>>>> join/leave/stp_update callbacks required for basic hardware bridging
> >>>>> support.
> >>>>>
> >>>>> There is not much to be done at the driver level but translating the
> >>>>> STP state from Linux to their HW values.
> >>>>>
> >>>>> Joining a bridge means that the joining port and the other port members
> >>>>> need to be in the same VLAN membership as the CPU, while leaving the
> >>>>> bridge puts the port back into a separate VLAN membership with only the
> >>>>> CPU.
> >>>>
> >>>> I found a couple additional issues while testing:
> >>>>
> >>>> - manipulating UP/DOWN state of interfaces that are part of a bridge
> >>>> would not restore their bridge membership
> >>>>
> >>>> - removing an interface from a bridge and bringing it back up would
> >>>> leave it in blocked state
> >>>>
> >>> Is this a problem with your implementation for sf2 or a generic problem
> >>> with the first patch, such as some missing state transitions ?
> >>
> >> This is more of a side effect of having HW (an Ethernet switch) that can
> >> really block a given port, based on last night's discussion with Roopa,
> >> we can either fix this at the DSA level (in our case) or better fix this
> >> at the bridge layer, I will propose a fix for this shortly.
> >>
> >>>
> >>> For sf2, you might have to set the port state as well as the bridge
> >>> association in the port_setup function. That is of course just a
> >>> wild guess.
> >>
> >> Right, that's what I ended up doing. Thanks!
> > 
> > Great.
> > 
> > Another question: How do you handle flushing the forwarding database ?
> > 
> > My current code for mv88e6352 flushes the forwarding database for a bridge
> > group if the port association for that group changes (whenever a port joins
> > or leaves a group, or whenever the state of a port in a group changes).
> > There is, however, another situation where the forwarding database may
> > have to be flushed - essentially on each topology change.
> > 
> > How do you handle this situation ? Is it a real problem or do I just
> > imagine that it is ?
> 
> This is a real problem, for once I was working under the assumption that
> the SF2 hardware was doing an automatic FDB flushing, but after
> re-reading the documentation, this is not the case. My lab network does
> not have many stations and I certainly did not catch that case.

The rocker code implements the fdb flush operation pretty much the same
way I do, so I seem to be doing something right.

Not sure yet what to do about setting the fdb aging time. I don't see a
mechanism to do that. No idea how important that is.

I think we'll also need support for ndo_vlan_rx_add_vid, ndo_vlan_rx_kill_vid,
ndo_fdb_add, ndo_fdb_del, and ndo_fdb_dump. Have you thought about those ?

Thanks,
Guenter
