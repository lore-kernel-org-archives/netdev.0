From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Fri, 15 Feb 2008 14:22:55 +0100
Message-ID: <OF58A8E0B3.B5CC265E-ONC12573F0.00496E2B-C12573F0.0049850F@de.ibm.com>
References: <200802111724.12416.ossthema@de.ibm.com>	 <1202748429.8276.21.camel@nimitz.home.sr71.net>
	 <200802131617.58646.ossthema@de.ibm.com>	 <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com> <1203009163.19205.42.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: apw <apw@uk.ibm.com>, Greg KH <greg@kroah.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	ossthema@linux.vnet.ibm.com, Badari Pulavarty <pbadari@us.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: Dave Hansen <haveblue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:34401 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbYBOPTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 10:19:08 -0500
In-Reply-To: <1203009163.19205.42.camel@nimitz.home.sr71.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dave Hansen <haveblue@us.ibm.com> wrote on 14.02.2008 18:12:43:

> On Thu, 2008-02-14 at 09:46 +0100, Christoph Raisch wrote:
> > Dave Hansen <haveblue@us.ibm.com> wrote on 13.02.2008 18:05:00:
> > > On Wed, 2008-02-13 at 16:17 +0100, Jan-Bernd Themann wrote:
> > > > Constraints imposed by HW / FW:
> > > > - eHEA has own MMU
> > > > - eHEA  Memory Regions (MRs) are used by the eHEA MMU  to translate
> > virtual
> > > >   addresses to absolute addresses (like DMA mapped memory on a PCI
bus)
> > > > - The number of MRs is limited (not enough to have one MR per
packet)
> > >
> > > Are there enough to have one per 16MB section?
> >
> > Unfortunately this won't work. This was one of our first ideas we
tossed
> > out,
> > but the number of MRs will not be sufficient.
>
> Can you give a ballpark of how many there are to work with? 10? 100?
> 1000?
>
It depends on HMC configuration, but in worst case the upper limit is in
the 2 digits range.

> > > But, I'm really not convinced that you can actually keep this map
> > > yourselves.  It's not as simple as you think.  What happens if you
get
> > > on an LPAR with two sections, one 256MB@0x0 and another
> > > 16MB@0x1000000000000000.  That's quite possible.  I think your
vmalloc'd
> > > array will eat all of memory.
> > I'm glad you mention this part. There are many algorithms out there to
> > handle this problem,
> > hashes/trees/... all of these trade speed for smaller memory footprint.
> > We based the table decission on the existing implementations of the
> > architecture.
> > Do you see such a case coming along for the next generation POWER
systems?
>
> Dude.  It exists *TODAY*.  Go take a machine, add tens of gigabytes of
> memory to it.  Then, remove all of the sections of memory in the middle.
> You'll be left with a very sparse memory configuration that we *DO*
> handle today in the core VM.  We handle it quite well, actually.
>
> The hypervisor does not shrink memory from the top down.  It pulls
> things out of the middle and shuffles things around.  In fact, a NUMA
> node's memory isn't even contiguous.
>
> Your code will OOM the machine in this case.  I consider the ehea driver
> buggy in this regard.

Your comment indicates that the upper limit for memory to be set on HMC
does not influence
the upper limit of the partition physical address space.
So our base assumption we discussed internally is wrong here.
(conclusion see below)
>
> > I would guess these drastic changes would also require changes in base
> > kernel.
>
> No, we actually solved those a couple years ago.
>
> > Will you provide a generic mapping system with a contiguous virtual
address
> > space
> > like the ehea_bmap we can query? This would need to be a "stable" part
of
> > the implementation,
> > including translation functions from kernel to
nextgen_ehea_generic_bmap
> > like virt_to_abs.
>
> Yes, that's a real possibility, especially if some other users for it
> come forward.  We could definitely add something like that to the
> generic code.  But, you'll have to be convincing that what we have now
> is insufficient.
>
> Does this requirement:
> "- MRs cover a contiguous virtual memory block (no holes)"
> come from the hardware?
>
yes
> Is that *EACH* MR?  OR all MRs?
>
each
> Where does EHEA_BUSMAP_START come from?  Is that defined in the
> hardware?  Have you checked to ensure that no other users might want a
> chunk of memory in that area?
>
EHEA_BUSMAP_START is a value which has to match between the wqe
virtual addresses and the MR used in them.
Fortunately there's a simple answer on that one. Each MR has a own address
space,
so there's no need to check.
A HEA MR actually has exactly the same attributes as a Infiniband MR with
this hardware.
send/receive processing is pretty much comparable to a Infiniband UD queue.

> Can you query the existing MRs?
no
> Not change them in place, but can you
> query their contents?
no
>
> > > That's why we have SPARSEMEM_EXTREME and SPARSEMEM_VMEMMAP
implemented
> > > in the core, so that we can deal with these kinds of problems, once
and
> > > *NOT* in every single little driver out there.
> > >
> > > > Functions to use while building ehea_bmap + MRs:
> > > > - Use either the functions that are used by the memory hotplug
system
> > as
> > > >   well, that means using the section defines + functions
> > (section_nr_to_pfn,
> > > >   pfn_valid)
> > >
> > > Basically, you can't use anything related to sections outside of the
> > > core code.  You can use things like pfn_valid(), or you can create
new
> > > interfaces that are properly abstracted.
> >
> > We picked sections instead of PFNs because this keeps the ehea_bmap in
a
> > reasonable range
> > on the existing systems.
> > But if you provide a abstract method handling exactly the problem we
> > mention
> > we'll be happy to use that and dump our private implementation.
>
> One thing you can guarantee today is that things are contiguous up to
> MAX_ORDER_NR_PAGES.  That's a symbol that is unlikely to change and is
> much more appropriate than using sparsemem.  We could also give you a
> nice new #define like MINIMUM_CONTIGUOUS_PAGES or something.  I think
> that's what you really want.

That's definitely the right direction.

>From this mail thread I would conclude....
memory space can have holes, and drivers shouldn't make any assumption when
where and how.

A translation from kernel to ehea_bmap space should be fast and predictable
(ruling out hashes).
If a driver doesn't know anything else about the mapping structure,
the normal solution in kernel for this type of problem is a multi level
look up table
like pgd->pud->pmd->pte
This doesn't sound right to be implemented in a device driver.

We didn't see from the existing code that such a mapping to a contiguous
space already exists.
Maybe we've missed it.

If the mapping is less random, the translation gets much simpler.
MAX_ORDER_NR_PAGES helps here, is there more like that?


Gruss / Regards
Christoph Raisch + Jan-Bernd Themann

