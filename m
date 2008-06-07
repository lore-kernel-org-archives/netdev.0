From: Ben Dooks <ben-linux@fluff.org>, g@trinity.fluff.org
Subject: Re: DM9000 issue with mem resource management
Date: Sat, 7 Jun 2008 22:35:04 +0100
Message-ID: <20080607213504.GA31817@trinity.fluff.org>
References: <200806051743.00614.laurentp@cse-semaphore.com> <20080605174030.GM11277@trinity.fluff.org> <200806061101.44638.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.fluff.org ([89.145.97.151]:46305 "EHLO
	trinity.fluff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbYFGVen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 17:34:43 -0400
Content-Disposition: inline
In-Reply-To: <200806061101.44638.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2008 at 11:01:42AM +0200, Laurent Pinchart wrote:
> Hi Ben,
> 
> On Thursday 05 June 2008 19:40, Ben Dooks wrote:
> > On Thu, Jun 05, 2008 at 05:42:58PM +0200, Laurent Pinchart wrote:
> > > Hi everybody,
> > > 
> > > I ran into a resource-related bug in the DM9000 driver.
> > > 
> > > When the platform device has only 2 resources, dm9000_probe() doesn't set 
> > > db->irq_res, which results in a segfault when the pointer gets
> > > dereferenced in dm9000_open().
> > > 
> > > I tried to fix the issue, and found out that the resource management code
> > > is quite broken.
> > 
> > Personally, I'm thinking about just removing the case for 2, and making it
> > three resources only. The following in-kernel machines use the following
> > resources:
> > 
> > arch/arm/mach-at91/board-sam9261ek.c			3
> > arch/arm/mach-pxa/cm-x270.c				3
> > arch/arm/mach-pxa/em-x270.c				3
> > arch/arm/mach-pxa/trizeps4.c				3
> > arch/arm/mach-pxa/colibri.c				3
> > arch/arm/mach-s3c2410/mach-bast.c			3
> > arch/arm/mach-s3c2410/mach-vr1000.c			3
> > arch/blackfin/mach-bf527/boards/ezkit.c			2
> > arch/blackfin/mach-bf533/boards/H8606.c			2
> > arch/blackfin/mach-bf533/boards/ip0x.c			3
> > arch/blackfin/mach-bf537/boards/generic_board.c		2
> > arch/blackfin/mach-bf537/boards/stamp.c			2
> > 
> > As you can see, the #3 outweigh the #2. Unless anyone else objects, I
> > will add a patch to reduce this to the case where the driver expects
> > 3 resources, and ask the users of #2 to submit changes for their
> > bots.
> >  
> > > If I understand things correctly, specifying 3 resources makes the DM9000 
> > > driver ioremap() the memory, while specifying 2 resources implies that the 
> > > platform code already ioremap()ed the memory. Is that right ?
> > > 
> > > If so, why does dm9000_probe() call request_mem_region() on ioremap()ed 
> > > memory ?
> > 
> > Hmm, dunno. I really have no idea why this happened. I don't think this
> > was my fault!
> >  
> > > Wouldn't it also be simpler to use release_mem_region() in 
> > > dm9000_release_board() instead of release_resource() + kfree() ?
> > 
> > If you already have the resource, this is a reasonably simple way of
> > ensuring you're disposing of the right resource.
> >  
> > > I'd be grateful if someone could confirm my assumptions. I'll then submit
> > > a patch to fix those issues.
> > 
> > My recommendation is that we remove the 2 case completely, so I'd not bother
> > trying to fix this.
> 
> I'm not too sure on that one.

Well, having thought about it some more, the 2 address case is also an
abuse of the IORESOURCE mechanism with platform devices, as the core
driver code uses the .start and .end to register with the relevant
iomem reservation code. I'm going more strongly on removing the #2 case
unless anyone can come up with a really compelling reason to keep it. 
 
> I have DM9000 chips on a custom bus. The bus code remaps the whole address 
> range (32 bytes per card x 32 slots) in one go and initializes the resource 
> with a subset of the remapped range.
>
> Converting that to per-slot ioremaps would create many more mappings. Is that 
> an issue (performance-wise, or in term of a maximum number of mappings if 
> there is a limit) ? I will still need a global mapping, as the bus code needs 
> to access configuration registers on the individual cards, so I won't be able 
> to request_mem_region both the global mapping and the individual mappings. 
> I'm not sure if that's an issue.

That sounds like a problem with the bus code mapping too much of the memory
and thus causing a problem for any subsequent drivers. Having an extra
mapping in is only a minor problem compared with the other travesty the
2 region case is currently causing.

-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.

