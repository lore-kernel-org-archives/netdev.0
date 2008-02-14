From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Thu, 14 Feb 2008 09:12:43 -0800
Message-ID: <1203009163.19205.42.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
	 <1202748429.8276.21.camel@nimitz.home.sr71.net>
	 <200802131617.58646.ossthema@de.ibm.com>
	 <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ossthema@linux.vnet.ibm.com, apw <apw@uk.ibm.com>,
	Greg KH <greg@kroah.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51055 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbYBNRMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 12:12:52 -0500
In-Reply-To: <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-14 at 09:46 +0100, Christoph Raisch wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote on 13.02.2008 18:05:00:
> > On Wed, 2008-02-13 at 16:17 +0100, Jan-Bernd Themann wrote:
> > > Constraints imposed by HW / FW:
> > > - eHEA has own MMU
> > > - eHEA  Memory Regions (MRs) are used by the eHEA MMU  to translate
> virtual
> > >   addresses to absolute addresses (like DMA mapped memory on a PCI bus)
> > > - The number of MRs is limited (not enough to have one MR per packet)
> >
> > Are there enough to have one per 16MB section?
> 
> Unfortunately this won't work. This was one of our first ideas we tossed
> out,
> but the number of MRs will not be sufficient.

Can you give a ballpark of how many there are to work with? 10? 100?
1000? 

> We understand that the add/remove area is not as
> settled in the kernel like for example f_ops ;-)
> Are there already base working assumptions which are very unlikely to
> change?

If you use good interfaces, and someone changes them, they'll likely
also fix your driver.

If you use bad interfaces, people may not even notice when they break.
As I showed you with those compile failures, you're using bad interfaces
that don't even compile on some .configs.  

> I'm a little confused here....
> ...the existing add/remove code depends on sparse mem.
> Other pieces on the POWER6 version of the architecture do as well.
> So we could either chose to disable add/remove if sparsemem is not there,
> or disable the driver by Kconfig in this case.

Technically, you can do this.  But, it's not a sign of a professionally
written driver that is going to get its patches accepted into mainline.
Technically, you can also use lots of magic numbers and not obey
CodingStyle.  But, you'll probably get review comments asking you to
change it.

> > > - a way to iterate over all kernel pages and a way to detect holes in
> the
> > >   kernel memory layout in order to build up our own ehea_bmap.
> >
> > Look at kernel/resource.c
> >
> > But, I'm really not convinced that you can actually keep this map
> > yourselves.  It's not as simple as you think.  What happens if you get
> > on an LPAR with two sections, one 256MB@0x0 and another
> > 16MB@0x1000000000000000.  That's quite possible.  I think your vmalloc'd
> > array will eat all of memory.
> I'm glad you mention this part. There are many algorithms out there to
> handle this problem,
> hashes/trees/... all of these trade speed for smaller memory footprint.
> We based the table decission on the existing implementations of the
> architecture.
> Do you see such a case coming along for the next generation POWER systems?

Dude.  It exists *TODAY*.  Go take a machine, add tens of gigabytes of
memory to it.  Then, remove all of the sections of memory in the middle.
You'll be left with a very sparse memory configuration that we *DO*
handle today in the core VM.  We handle it quite well, actually.

The hypervisor does not shrink memory from the top down.  It pulls
things out of the middle and shuffles things around.  In fact, a NUMA
node's memory isn't even contiguous.

Your code will OOM the machine in this case.  I consider the ehea driver
buggy in this regard.

> I would guess these drastic changes would also require changes in base
> kernel.

No, we actually solved those a couple years ago.  

> Will you provide a generic mapping system with a contiguous virtual address
> space
> like the ehea_bmap we can query? This would need to be a "stable" part of
> the implementation,
> including translation functions from kernel to nextgen_ehea_generic_bmap
> like virt_to_abs.

Yes, that's a real possibility, especially if some other users for it
come forward.  We could definitely add something like that to the
generic code.  But, you'll have to be convincing that what we have now
is insufficient.

Does this requirement:
"- MRs cover a contiguous virtual memory block (no holes)"
come from the hardware?

Is that *EACH* MR?  OR all MRs?

Where does EHEA_BUSMAP_START come from?  Is that defined in the
hardware?  Have you checked to ensure that no other users might want a
chunk of memory in that area?

Can you query the existing MRs?  Not change them in place, but can you
query their contents?

> > That's why we have SPARSEMEM_EXTREME and SPARSEMEM_VMEMMAP implemented
> > in the core, so that we can deal with these kinds of problems, once and
> > *NOT* in every single little driver out there.
> >
> > > Functions to use while building ehea_bmap + MRs:
> > > - Use either the functions that are used by the memory hotplug system
> as
> > >   well, that means using the section defines + functions
> (section_nr_to_pfn,
> > >   pfn_valid)
> >
> > Basically, you can't use anything related to sections outside of the
> > core code.  You can use things like pfn_valid(), or you can create new
> > interfaces that are properly abstracted.
> 
> We picked sections instead of PFNs because this keeps the ehea_bmap in a
> reasonable range
> on the existing systems.
> But if you provide a abstract method handling exactly the problem we
> mention
> we'll be happy to use that and dump our private implementation.

One thing you can guarantee today is that things are contiguous up to
MAX_ORDER_NR_PAGES.  That's a symbol that is unlikely to change and is
much more appropriate than using sparsemem.  We could also give you a
nice new #define like MINIMUM_CONTIGUOUS_PAGES or something.  I think
that's what you really want.

> > > - Use currently other not exported functions in kernel/resource.c, like
> > >   walk_memory_resource (where we would still need the maximum
> > possible number
> > >   of pages NR_MEM_SECTIONS)
> >
> > It isn't the act of exporting that's the problem.  It's making sure that
> > the exports won't be prone to abuse and that people are using them
> > properly.  You should assume that you can export and use
> > walk_memory_resource().
> 
> So this seems to come down to a basic question:
> New hardware seems to have a tendency to get "private MMUs",
> which need private mappings from the kernel address space into a
> "HW defined address space with potentially unique characteristics"
> RDMA in Openfabrics with global MR is the most prominent example heading
> there

That's not a question. ;)

Please explain to me why walk_memory_resource() is insufficient for your
needs.  I've now pointed it out to you at least 3 times.  

> > Do you know what other operating systems do with this hardware?
> 
> We're not aware of another open source Operating system trying to address
> this topic.

What about AIX?  Do you know who wrote its driver?  Perhaps you should
go ask them.

-- Dave

