From: Willy Tarreau <w@1wt.eu>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Wed, 12 Sep 2007 00:37:08 +0200
Message-ID: <20070911223708.GB10199@1wt.eu>
References: <20070905102230.10b0bdcf@oldman> <782111.42803.qm@web90413.mail.mud.yahoo.com> <46E2DF74.7040307@tmr.com> <20070908191132.GD3563@stusta.de> <46E35D8C.1070909@krose.org> <20070909111326.GF3563@stusta.de> <20070911100526.6aa5d463@oldman> <20070911115456.GM3563@stusta.de> <46E6A65B.2050209@tmr.com> <20070911150357.GN3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Davidsen <davidsen@tmr.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kyle Rose <krose@krose.org>,
	James Corey <ploversegg@yahoo.com>,
	Rob Sims <lkml-z@robsims.com>, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2469 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757129AbXIKWhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 18:37:40 -0400
Content-Disposition: inline
In-Reply-To: <20070911150357.GN3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 11, 2007 at 05:03:57PM +0200, Adrian Bunk wrote:
> On Tue, Sep 11, 2007 at 10:29:47AM -0400, Bill Davidsen wrote:
> > So if you want people to try a new driver, I think it really has to have 
> > some benefits to the users, in terms of performance, reliability, or 
> > features. "Cleaner design" doesn't motivate, and it does raise the question 
> > of why the old driver wasn't just cleaned up. I've been doing software for 
> > decades, I appreciate why, but users in general just want to use their 
> > system. Which raises the question of why to delete drivers which work for 
> > many or even most users?
> 
> As I already explained, there is a long term advantage for all users if 
> there is only one driver in the kernel.

Not only that. You have to place the switch in its context with history.
Stephen, please correct me if I'm wrong, but sk98lin has been randomly
working for a very long time. Not 100% the driver's fault, because it
has had to workaround a lot of chips bugs. The fact that this driver
supports *all* chips in the family makes it harder to identify whether
problems are caused by the hardware or by the driver because it is
bloated with tons of if/else.

I've personally encountered random data corruption on the receive path
with PCI-E hardware with sk98lin, as well as random TX stops. Sometimes
it would require one terabyte of data, sometimes just a few hundreds
megs. On other hardware (skge now), UDP would simply stop being sent
and some TCP traffic was necessary to restart UDP! One guy at Marvell
once asked me for more information, but it was not easy to provide
much more, given the randomness of the problems!

Stephen has done an excellent (and thankless) job at restarting from
scratch, and the idea to separate the two chips was a good one IMHO.
The problem is that he might have thought that most of the bugs were
in the driver, while most of them are in the hardware, and this requires
a lot of workarounds, which do not always work the same for everybody
(I remember having tried to disable flow control with sk98lin because
it helped with sky2).

In parallel, sk98lin has improved on the vendor's site. v8 exhibited
all the problems I explained above, but v10 has fixed a lot of them,
making the new sk98lin more reliable. In parallel, sky2 and skge had
got wider acceptance and testing. The nastiest hardware bugs will
slowly surface, a good deal of driver bugs have been detected too
(and that's expected from any new driver).

It is possible that after 2 or 3 patches, a lot of the remaining
problems will suddenly vanish. But it's also possible that the driver
will still not work for 1% of people for 1 or 2 years because of some
obscure hardware combinations which trigger some obscure hardware bugs.

> Therefore all users should 
> switch away from obsolete drivers to the replacement drivers, and the 
> obsolete driver will be removed at some point in time. The only question 
> is how to do it.

Desktop users genreally have no problem experimenting with multiple kernels
or drivers. They can report feedback too, but generally, they're not very
good at downloading alternative drivers and patching their kernel with those.

Server users cannot experiment for a long time. After 2 or 3 losses of
service, they *have* to provide a definitive solution. For some of them
when sky2 fails, it may very well be to switch over to sk98lin. Downloading
from the vendor's site and patching is not a problem for those users, but
it causes them the trouble of updating the kernel for security fixes, so
the old driver must be shipped with the kernel.

However, I remember something which might constitute a solution. In 2.4,
there's a small bug in the kbuild process on alpha. One question is always
asked during make oldconfig. Its saved value is ignored because of the way
it is computed. I don't know if we could do this with 2.6 kbuild. It would
then be nice to always set sk98lin to unset if it was set to "Y" or "M",
so that at each build, the user has to explicitly state he wants it. It's
annoying enough to give the other one a try once in a while, without causing
too much trouble to people who really have no other choice right now.

What we need with this driver is people being fed up with it, not them
being unable to use it as a last resort. Also, given that it has improved
over the last years (probably due to competition pressure from sky2/skge),
users will even less understand why there is such incentive to remove it.

Another trick for obsolete drivers would be to simply remove them from
the usual build system, but have them being available for explicit build.
Eg: make modules will not build them, but make obsolete-modules would do.

> > Testing a new kernel is no longer a drop in a boot 
> > operation if modprobe.conf must be edited to get the network up, and the 
> > typical user isn't going to write that shell script to try one or the other 
> > driver.
> 
> The typical user will let his distribution handle this.
> 
> And MODULE_ALIAS can also handle this.

No system config should be edited to switch back to the alternative,
otherwise it remains in its working state.

> > Honestly, new drivers which offer little benefit to most users are the 
> > exception rather than the rule, so this may a corner case I would like to 
> > see sk98lin back in the kernel, for a while I can build my own kernels and 
> > patch it in, but until other drivers are drop-in, I probably won't change.
> 
> That a new driver offers benefits that cause most users to switch isn't 
> realistic.

Desktop users are curious and have plenty of time to kill. Server users
are frightened and lazy. So I think that annoying the user slightly is
a good solution (eg: make obsolete-modules).

> You mention e100 as an example - well, I'm using this driver in my 
> computer, but I doubt anything would be worse for me if I'd use the 
> obsolete eepro100 driver instead since I'm not using any of the fancy 
> e100 features you mentioned as advantages.

After having been happy with eepro100 for years, I discovered many problems
with its VLAN support in 2.4 (MTU, ...) for which e100 was a solution. It
was a good reason to switch. But the old e100 driver took ages to load (half
of the machine boot time), which was not satisfying. So having a new driver
load faster is another good reason to switch.

> There is a long term advantage for all users if there is only one driver 
> in the kernel. Therefore all users should switch away from obsolete 
> drivers to the replacement drivers, and the obsolete driver will be 
> removed at some point in time. The only question is how to do it.

Hmmm we already read this paragraph above :-)

> > Separate but related: why keep skge and sky2? Are we going through this 
> > again in a year? Is the benefit worth the effort?
> >...
> 
> skge and sky2 support distinct hardware.

... and as such are both smaller than sk98lin which supports both.

Cheers,
Willy

