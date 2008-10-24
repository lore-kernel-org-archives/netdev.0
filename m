From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Add hugepage detection
Date: Fri, 24 Oct 2008 11:55:37 -0700
Message-ID: <1224874537.12673.47.camel@nimitz>
References: <200810241307.31072.>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>, badari@us.ibm.com,
	haveblue@us.ibm.com, tollefso@us.ibm.com
To: Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:49096 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205AbYJXSzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 14:55:42 -0400
In-Reply-To: <200810241307.31072.>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-24 at 13:07 +0200, Thomas Klein wrote:
> 16GB hugepages may not be part of a memory region (firmware restriction). This patch
> modifies the walk_memory_resource callback fn to filter hugepages and add only standard
> memory to the busmap which is later on used for MR registration.

Does this support a case where a userspace app is reading network
packets into a 16GB page backed area?  I think you need to elaborate on
what kind of memory you need to have registered in these memory regions.
It's hard to review what you've done here otherwise.

> --- linux-2.6.27/drivers/net/ehea/ehea_qmr.c	2008-10-24 09:29:19.000000000 +0200
> +++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-10-24 09:45:15.000000000 +0200
> @@ -636,6 +636,9 @@ static int ehea_update_busmap(unsigned l
>  {
>  	unsigned long i, start_section, end_section;
> 
> +	if (!pgnum)
> +		return 0;

This probably needs a comment.  It's not obvious what it is doing.

>  	if (!ehea_bmap) {
>  		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
>  		if (!ehea_bmap)
> @@ -692,10 +695,47 @@ int ehea_rem_sect_bmap(unsigned long pfn
>  	return ret;
>  }
> 
> -static int ehea_create_busmap_callback(unsigned long pfn,
> -				       unsigned long nr_pages, void *arg)
> +static int ehea_is_hugepage(unsigned long pfn)
> +{
> +	return ((((pfn << PAGE_SHIFT) & (EHEA_HUGEPAGE_SIZE - 1)) == 0)
> +		&& (compound_order(pfn_to_page(pfn)) + PAGE_SHIFT
> +		    == EHEA_HUGEPAGESHIFT) );
> +}

Whoa.  That's dense.  Can you actually read that in less than 5 minutes?
Seriously.

I'm not sure what else you use EHEA_HUGEPAGE_SIZE for or if this gets
duplicated, but this would look nicer if you just had a:

#define EHEA_HUGEPAGE_PFN_MASK ((EHEA_HUGEPAGE_SIZE - 1) >> PAGE_SHIFT)

	if (pfn & EHEA_HUGEPAGE_PFN_MASK)
		return 0;

Or, with no new macro:

	if ((pfn << PAGE_SHIFT) & (EHEA_HUGEPAGE_SIZE - 1) != 0)
		return 0;

	page_order = compound_order(pfn_to_page(pfn));
	if (page_order + PAGE_SHIFT != EHEA_HUGEPAGESHIFT)
		return 0;
	return 1;
}

Please break that up into something that is truly readable.  gcc will
generate the exact same code.

> +static int ehea_create_busmap_callback(unsigned long initial_pfn,
> +				       unsigned long total_nr_pages, void *arg)
>  {
> -	return ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
> +	int ret;
> +	unsigned long pfn, start_pfn, end_pfn, nr_pages;
> +
> +	if ((total_nr_pages * PAGE_SIZE) < EHEA_HUGEPAGE_SIZE)
> +		return ehea_update_busmap(initial_pfn, total_nr_pages,
> +					  EHEA_BUSMAP_ADD_SECT);
> +
> +	/* Given chunk is >= 16GB -> check for hugepages */
> +	start_pfn = initial_pfn;
> +	end_pfn = initial_pfn + total_nr_pages;
> +	pfn = start_pfn;
> +
> +	while (pfn < end_pfn) {
> +		if (ehea_is_hugepage(pfn)) {
> +			/* Add mem found in front of the hugepage */
> +			nr_pages = pfn - start_pfn;
> +			ret = ehea_update_busmap(start_pfn, nr_pages,
> +						 EHEA_BUSMAP_ADD_SECT);
> +			if (ret)
> +				return ret;
> +
> +			/* Skip the hugepage */
> +			pfn += (EHEA_HUGEPAGE_SIZE / PAGE_SIZE);
> +			start_pfn = pfn;
> +		} else
> +			pfn += (EHEA_SECTSIZE / PAGE_SIZE);
> +	}
> +
> +	/* Add mem found behind the hugepage(s)  */
> +	nr_pages = pfn - start_pfn;
> +	return ehea_update_busmap(start_pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
>  }
> 
>  int ehea_create_busmap(void)
> diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
> --- linux-2.6.27/drivers/net/ehea/ehea_qmr.h	2008-10-24 09:29:19.000000000 +0200
> +++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2008-10-24 09:45:15.000000000 +0200
> @@ -40,6 +40,8 @@
>  #define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
>  #define EHEA_SECTSIZE          (1UL << 24)
>  #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
> +#define EHEA_HUGEPAGESHIFT     34
> +#define EHEA_HUGEPAGE_SIZE     (1UL << EHEA_HUGEPAGESHIFT)

I'm a bit worried that you're basically duplicating hugetlb.h here.  Why
not just use the existing 16GB page macros?  While you're at it please
expand these to give some more useful macros so you don't have to do
arithmetic on them in the code as much.

#define EHEA_SECT_NR_PAGES (EHEA_SECTSIZE / PAGE_SIZE)

for instance.

-- Dave

