From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: switchdev and VLAN ranges
Date: Sat, 10 Oct 2015 12:33:02 -0400
Message-ID: <20151010163300.GC14572@ketchup>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <CAE4R7bBRySJZxq4HKfSkyLNHiC0oMUqb95E=fCHjKX6MpNUGBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54972 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbJJQdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 12:33:07 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bBRySJZxq4HKfSkyLNHiC0oMUqb95E=fCHjKX6MpNUGBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Friday 09 (41) 09:22 PM, Scott Feldman wrote:
> On Fri, Oct 9, 2015 at 4:30 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
> > Hi All,
> >
> > I understand that specifying a VLAN range on the command line is nice
> > for the user, and it makes no big deal for software implementation.
> 
> [Adding Roopa, since she did the original vlan range support in the
> kernel/iproute2]
> 
> > However, AFAICT a VLAN range does not make sense at all for hardware
> > such as Ethernet switch chips. Am I wrong?
> >
> > I would suggest to make switchdev directly answer to a bridge request
> > that the operation is not supported when the user asks for a VLAN range.
> >
> > That way, we can simply use a single "vid" member in struct
> > switchdev_obj_port_vlan instead of "vid_begin" and "vid_end" and thus
> > avoid making drivers heavier with iteration loops on such range.
> >
> > I have two concerns in mind:
> >
> > a) if we imagine that drivers like Rocker allocate memory in the prepare
> > phase for each VID, preparing a range like 100-4000 would definitely not
> > be recommended.
> 
> This call should be in process context so it doesn't seem to terrible
> for the driver to take its time to reserve/allocate resources in
> prepare phase, even for a vlan range.  I think I'm missing your point.

I'll try to give a concrete example. If I want to use the prepare phase
in the mv88e6xxx driver, I will allocate a struct mv88e6xxx_vtu_entry
(basically a row in the hardware VLAN table) in the prepare phase before
programming it in the commit phase.

With this VLAN range, the driver will allocate 3900 struct. This seems
pointless for drivers and error-prone.

> > b) imagine that you have two Linux bridges on a switch, one using the
> > hardware VLAN 100. If you request the VLAN range 99-101 for the other
> > bridge members, it is not possible for the driver to say "I can
> > accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUPP for
> > the whole range.
> 
> Well, it probably should return -ERANGE to indicate the range can't be
> added, but that's an aside.
> 
> The reason why vlan ranges need to work down to the switchdev driver
> is, from the user's perspective, it's an all-or-nothing request from
> the user to add the vlan range to the device.  So we need to ask the
> driver in the prepare phase, "can you support this range,
> completely?", and if yes, then commit it as a whole.  The netlink
> response back to the user isn't equipped to describe what subset of
> the range was added, and what subset was not.

I understand the all-or-nothing request, and I don't want to re-train
the user. I am basically suggesting that switchdev returns -ERANGE in
its code, if the device is a switch port and a VLAN range is requested.

I mean, I like the per-port paradigm of Linux, but an infrastructure
such as switchdev should not just forward user request to the device,
but also protect it and push consistent calls to the hardware.

> > That's why I think that avoiding VLAN range at the switchdev level would
> > be a good idea.
> 
> As a general rule with switchdev, we've tried to keep the user's
> experience the same when using {Linux} as a soft switch/router vs.
> using {Linux + offload device} as a hard switch/router.  So if native
> Linux supports some operation, for example vlan ranges, then we should
> try to extend that to the offload model.  In other words, we don't
> want to re-train the user when moving from soft switch to hard switch!
>  But there are physical limitations when dealing with an offload
> device....
> 
> Anyway, with your vlan range example, we've got a case where each soft
> bridge has an independent vlan set, and the vlan sets between soft
> bridges can overlap.  For the (typical) hard switch, there is one vlan
> set for the whole switch, and trying to overlay the soft bridges'
> (overlapping) vlan sets on the hard switch fails.  That failure is
> reported to the user.  We tried, but due to offload device
> limitations, we can't support that operation.  Of course, if the vlan
> sets didn't overlap, then we don't have a problem.
> 
> This will not be the only case where something we can do on a soft
> Linux switch/router can't be offloaded to some physical offload
> device.  But I think the philosophy has been to try offload what we
> can, up to the point of failure.  In some cases, we can mask that
> failure from the user by falling back to soft-switch only, but in
> other cases the failure will pop up right in the user's face, like in
> your example.
> 
> One idea to help mitigate the user's confusion would be to limit the
> number of bridges overlaid on the device to just one.  Our drivers
> know when ports are enslaved to bridges, so is there something we can
> do there to fail the enslave on a second bridge?  Exercise left to the
> reader.  If we had that, now vlan ranges work 1:1 with soft Linux
> because both soft bridge and device have single vlan set.
> 
> Sorry for the long-winded response.

I'm fine with the multiple software bridges on top of hardware switches.
IIRC, Andrew is actually using this feature. The user should be able to
request mixing of any ports like (s)he wants.

A use case I can imagine is a bridge on a router between a WAN interface
and a few switch ports, and an isolated group of ports (e.g. sandbox).

What I have done in net/dsa/slave.c:dsa_bridge_check_vlan_range() should
ideally be moved up to switchdev (this code prevents overlapping of VLAN
between bridges in DSA switches).

Thanks,
-v
