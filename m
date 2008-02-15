From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Fri, 15 Feb 2008 08:55:38 -0800
Message-ID: <1203094538.8142.23.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
	 <1202748429.8276.21.camel@nimitz.home.sr71.net>
	 <200802131617.58646.ossthema@de.ibm.com>
	 <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
	 <1203009163.19205.42.camel@nimitz.home.sr71.net>
	 <OF58A8E0B3.B5CC265E-ONC12573F0.00496E2B-C12573F0.0049850F@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: apw <apw@uk.ibm.com>, Greg KH <greg@kroah.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	ossthema@linux.vnet.ibm.com, Badari Pulavarty <pbadari@us.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:45619 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118AbYBOQzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 11:55:44 -0500
In-Reply-To: <OF58A8E0B3.B5CC265E-ONC12573F0.00496E2B-C12573F0.0049850F@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-15 at 14:22 +0100, Christoph Raisch wrote:
> A translation from kernel to ehea_bmap space should be fast and
> predictable
> (ruling out hashes).
> If a driver doesn't know anything else about the mapping structure,
> the normal solution in kernel for this type of problem is a multi
> level
> look up table
> like pgd->pud->pmd->pte
> This doesn't sound right to be implemented in a device driver.
> 
> We didn't see from the existing code that such a mapping to a
> contiguous
> space already exists.
> Maybe we've missed it.

I've been thinking about that, and I don't think you really *need* to
keep a comprehensive map like that.  

When the memory is in a particular configuration (range of memory
present along with unique set of holes) you get a unique ehea_bmap
configuration.  That layout is completely predictable.

So, if at any time you want to figure out what the ehea_bmap address for
a particular *Linux* virtual address is, you just need to pretend that
you're creating the entire ehea_bmap, use the same algorithm and figure
out host you would have placed things, and use that result.

Now, that's going to be a slow, crappy linear search (but maybe not as
slow as recreating the silly thing).  So, you might eventually run into
some scalability problems with a lot of packets going around.  But, I'd
be curious if you do in practice.

The other idea is that you create a mapping that is precisely 1:1 with
kernel memory.  Let's say you have two sections present, 0 and 100.  You
have a high_section_index of 100, and you vmalloc() a 100 entry array.

You need to create a *CONTIGUOUS* ehea map?  Create one like this:

EHEA_VADDR->Linux Section
0->0
1->0
2->0
3->0
...
100->100

It's contiguous.  Each area points to a valid Linux memory address.
It's also discernable in O(1) to what EHEA address a given Linux address
is mapped.  You just have a couple of duplicate entries.  

-- Dave

