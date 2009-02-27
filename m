From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 13:52:11 +0100
Message-ID: <20090227125211.GV17040@xi.wantstofly.org>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:58602 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbZB0MwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 07:52:14 -0500
Content-Disposition: inline
In-Reply-To: <49A7DBA2.8060605@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 05:25:06AM -0700, Gary Thomas wrote:

> >>>>>>>> Is there support for this device anywhere?  In particular,
> >>>>>>>> the M88E6095 switch.
> >>>>>>> Not at the moment, but it should be easy enough to add.  If your
> >>>>>>> board already runs on 2.6.28+, I can whip up some patches for you
> >>>>>>> to try from the docs I have for that part.
> >>>>>> That would be much appreciated, thanks.
> >>>>> I noticed that the 6095/6095F are quite similar to the 6131 as far
> >>>>> as the register set goes.  So something along these lines (hacky
> >>>>> patch, breaks 6131, not for mainline) might just work to detect
> >>>>> single 6095s (cascading DSA chips is something that needs more work,
> >>>>> let's get the single-chip case working first).
> >>>>>
> >>>>> The other thing you'll need to do is create dsa platform devices
> >>>>> for your switch chips, a la how it's done in arch/arm/mach-orion5x/
> >>>>> or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
> >>>>> device * for your network device, a struct device * for your mii bus,
> >>>>> the switch MII address on the MII bus, and names of the individual
> >>>>> ports (where you'll specify "cpu" for the port on the switch chip that
> >>>>> the CPU is connected to).
> >>>>>
> >>>>> Let me know if this works.
> >>>> Thanks, I'll give it a try.  It will take a little effort
> >>>> to get setup as I have to work within the open firmware
> >>>> structure (that's how all the various components are
> >>>> specified).
> >>> Right, we don't have OF bindings yet.  I guess this would make sense
> >>> to do generically at some point, since there are quite a few PPC
> >>> platforms with DSA switch chips.
> >> Here's what I tried - (patch attached) - a trulyhorrible hack,
> >> but I've not figured out how to get the correct device pointers
> >> from the OF world yet.  The boot log shows that it's trying, but
> >> I don't see the DSA layer (M88E690x driver) doing the MII indirection
> >> that's needed for this device.
> >>
> >> I'm probably not starting it up correctly, but I think I followed
> >> the examples you cited.  Any ideas?
> > 
> > "indirection needed for this device" -- does that mean that your
> > switch chip is configured to use the multi-chip addressing mode?
> > (It looks like it, as most of the MII addresses return ffff in
> > their ID registers.)  If yes, you should set ->sw_addr to whatever
> > MII address the chip has been assigned.
> 
> Much better, my switch seems to be found now.
> 
>   Distributed Switch Architecture driver version 0.1
>   gfar_mdio_read(cf9db400, 1, 0) = 1811
>   gfar_mdio_write(cf9db400, 1, 0, 9a03) = 0
>   gfar_mdio_read(cf9db400, 1, 0) = 1a03
>   gfar_mdio_read(cf9db400, 1, 1) = 953
>   mv88e6131_probe(cf9db400, 1) = 2387

That looks like the proper indirect access sequence.


>   eth0: detected a Marvell 88E6095/88E6095F switch

Yay.


>   root@ppc_target:~ ls /sys/bus/mdio_bus/devices/
>   24520:01:00  24520:01:02  24520:01:04  24520:01:06
>   24520:01:01  24520:01:03  24520:01:05  24520:01:07

That looks good too.


> However, the network subsystem still can't locate it.  It may be
> a complication of the OF stuff and how the [gianfar] network
> device knows what PHY to look at.
> 
>   starting network interfaces...
>   24520:01 not found
>   eth0: Could not attach to PHY

It's correct that eth0 should not associate with a PHY -- since the
MAC connects to the switch chip over GMII/RGMII/SGMII, there is no
PHY involved.

Is the gianfar driver refusing to up the interface without a PHY?
It shouldn't do that -- IMHO it's perfectly fine to not have a PHY
on your ethernet MAC.


> Also, how do I specify the [implicit] route within the switch
> that connects '24520:01:00' to the CPU port '24520:01:0A' (if
> there was such a thing)?  My boot loader has configured the
> switch for this path - I've not looked through the log to see
> what the DSA layer did.

Just specify "cpu" as the port name of port 10 in your dsa platform
data (assuming that there's where your CPU is), that'll take care of
it.

Does it give you Linux network interfaces for the other switch chip
ports (1-8)?


thanks,
Lennert
