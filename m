From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Thu, 14 Feb 2008 09:46:10 +0100
Message-ID: <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
References: <200802111724.12416.ossthema@de.ibm.com> <1202748429.8276.21.camel@nimitz.home.sr71.net> <200802131617.58646.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: apw <apw@uk.ibm.com>, Greg KH <greg@kroah.com>,
	Dave Hansen <haveblue@us.ibm.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: ossthema@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:7609 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901AbYBNIqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 03:46:15 -0500
In-Reply-To: <200802131617.58646.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dave Hansen <haveblue@us.ibm.com> wrote on 13.02.2008 18:05:00:

> On Wed, 2008-02-13 at 16:17 +0100, Jan-Bernd Themann wrote:
> > Constraints imposed by HW / FW:
> > - eHEA has own MMU
> > - eHEA  Memory Regions (MRs) are used by the eHEA MMU  to translate
virtual
> >   addresses to absolute addresses (like DMA mapped memory on a PCI bus)
> > - The number of MRs is limited (not enough to have one MR per packet)
>
> Are there enough to have one per 16MB section?

Unfortunately this won't work. This was one of our first ideas we tossed
out,
but the number of MRs will not be sufficient.

>
> > Our current understanding about the current Memory Hotplug System are
> > (please correct me if I'm wrong):
> >
> > - depends on sparse mem
>
> You're wrong ;).  In mainline, this is true.  There was a version of the
> SUSE kernel that did otherwise.  But you can not and should not depend
> on this never changing.  But, someone is perfectly free to go out an
> implement something better than sparsemem for memory hotplug.  If they
> go and do this, your driver may get left behind.

We understand that the add/remove area is not as
settled in the kernel like for example f_ops ;-)
Are there already base working assumptions which are very unlikely to
change?

>
> > - only whole memory sections are added / removed
> > - for each section a memory resource is registered
>
> True, and true. (There might be exceptions to the whole sections one,
> but that's blatant abuse and should be fixed. :)
>
> > From the driver side we need:
> > - some kind of memory notification mechanism.
> >   For memory add we can live without any external memory notification
> >   event. For memory remove we do need an external trigger (see
explanation
> >   above).
>
> You can export and use (un)register_memory_notifier.  You just need to
> do it in a reasonable way that compiles for randconfig on your
> architecture.  Believe me, we don't want to start teaching drivers about
> sparsemem.

I'm a little confused here....
...the existing add/remove code depends on sparse mem.
Other pieces on the POWER6 version of the architecture do as well.
So we could either chose to disable add/remove if sparsemem is not there,
or disable the driver by Kconfig in this case.


> > - a way to iterate over all kernel pages and a way to detect holes in
the
> >   kernel memory layout in order to build up our own ehea_bmap.
>
> Look at kernel/resource.c
>
> But, I'm really not convinced that you can actually keep this map
> yourselves.  It's not as simple as you think.  What happens if you get
> on an LPAR with two sections, one 256MB@0x0 and another
> 16MB@0x1000000000000000.  That's quite possible.  I think your vmalloc'd
> array will eat all of memory.
I'm glad you mention this part. There are many algorithms out there to
handle this problem,
hashes/trees/... all of these trade speed for smaller memory footprint.
We based the table decission on the existing implementations of the
architecture.
Do you see such a case coming along for the next generation POWER systems?
I would guess these drastic changes would also require changes in base
kernel.

Will you provide a generic mapping system with a contiguous virtual address
space
like the ehea_bmap we can query? This would need to be a "stable" part of
the implementation,
including translation functions from kernel to nextgen_ehea_generic_bmap
like virt_to_abs.

>
> That's why we have SPARSEMEM_EXTREME and SPARSEMEM_VMEMMAP implemented
> in the core, so that we can deal with these kinds of problems, once and
> *NOT* in every single little driver out there.
>
> > Functions to use while building ehea_bmap + MRs:
> > - Use either the functions that are used by the memory hotplug system
as
> >   well, that means using the section defines + functions
(section_nr_to_pfn,
> >   pfn_valid)
>
> Basically, you can't use anything related to sections outside of the
> core code.  You can use things like pfn_valid(), or you can create new
> interfaces that are properly abstracted.

We picked sections instead of PFNs because this keeps the ehea_bmap in a
reasonable range
on the existing systems.
But if you provide a abstract method handling exactly the problem we
mention
we'll be happy to use that and dump our private implementation.

>
> > - Use currently other not exported functions in kernel/resource.c, like
> >   walk_memory_resource (where we would still need the maximum
> possible number
> >   of pages NR_MEM_SECTIONS)
>
> It isn't the act of exporting that's the problem.  It's making sure that
> the exports won't be prone to abuse and that people are using them
> properly.  You should assume that you can export and use
> walk_memory_resource().

So this seems to come down to a basic question:
New hardware seems to have a tendency to get "private MMUs",
which need private mappings from the kernel address space into a
"HW defined address space with potentially unique characteristics"
RDMA in Openfabrics with global MR is the most prominent example heading
there


>
> Do you know what other operating systems do with this hardware?

We're not aware of another open source Operating system trying to address
this topic.

>
> In the future, please make an effort to get review from knowledgeable
> people about these kinds of things before using them in your driver.
> Your company has many, many resources available, and all you need to do
> is ask.  All that you have to do is look to the tops of the files of the
> functions you are calling.
>

So we're glad we finally found the right person who takes responsibility
for this topic!


> -- Dave
>
Gruss / Regards
Christoph Raisch + Jan-Bernd Themann


