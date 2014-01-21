From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [Xen-devel] [PATCH v3] xen/grant-table: Avoid m2p_override during
 mapping
Date: Tue, 21 Jan 2014 12:26:22 +0000
Message-ID: <alpine.DEB.2.02.1401211217510.21510@kaball.uk.xensource.com>
References: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53425 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448AbaAUM13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 07:27:29 -0500
In-Reply-To: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jan 2014, Zoltan Kiss wrote:
> The grant mapping API does m2p_override unnecessarily: only gntdev needs it,
> for blkback and future netback patches it just cause a lock contention, as
> those pages never go to userspace. Therefore this series does the following:
> - the original functions were renamed to __gnttab_[un]map_refs, with a new
>   parameter m2p_override
> - based on m2p_override either they follow the original behaviour, or just set
>   the private flag and call set_phys_to_machine
> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs with
>   m2p_override false
> - a new function gnttab_[un]map_refs_userspace provides the old behaviour
> 
> v2:
> - move the storing of the old mfn in page->index to gnttab_map_refs
> - move the function header update to a separate patch
> 
> v3:
> - a new approach to retain old behaviour where it needed
> - squash the patches into one
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Suggested-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/block/xen-blkback/blkback.c |   15 +++----
>  drivers/xen/gntdev.c                |   13 +++---
>  drivers/xen/grant-table.c           |   81 +++++++++++++++++++++++++++++------
>  include/xen/grant_table.h           |    8 +++-
>  4 files changed, 87 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
> index aa846a4..87ded60 100644
> --- a/drivers/xen/grant-table.c
> +++ b/drivers/xen/grant-table.c
> @@ -880,15 +880,17 @@ void gnttab_batch_copy(struct gnttab_copy *batch, unsigned count)
>  }
>  EXPORT_SYMBOL_GPL(gnttab_batch_copy);
>  
> -int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
> +int __gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>  		    struct gnttab_map_grant_ref *kmap_ops,
> -		    struct page **pages, unsigned int count)
> +		    struct page **pages, unsigned int count,
> +		    bool m2p_override)
>  {
>  	int i, ret;
>  	bool lazy = false;
>  	pte_t *pte;
>  	unsigned long mfn;
>  
> +	BUG_ON(kmap_ops && !m2p_override);
>  	ret = HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, map_ops, count);
>  	if (ret)
>  		return ret;
> @@ -907,10 +909,12 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>  			set_phys_to_machine(map_ops[i].host_addr >> PAGE_SHIFT,
>  					map_ops[i].dev_bus_addr >> PAGE_SHIFT);
>  		}
> -		return ret;
> +		return 0;
>  	}
>  
> -	if (!in_interrupt() && paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
> +	if (m2p_override &&
> +	    !in_interrupt() &&
> +	    paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
>  		arch_enter_lazy_mmu_mode();
>  		lazy = true;
>  	}
> @@ -927,8 +931,18 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>  		} else {
>  			mfn = PFN_DOWN(map_ops[i].dev_bus_addr);
>  		}
> -		ret = m2p_add_override(mfn, pages[i], kmap_ops ?
> -				       &kmap_ops[i] : NULL);
> +		if (m2p_override)
> +			ret = m2p_add_override(mfn, pages[i], kmap_ops ?
> +					       &kmap_ops[i] : NULL);
> +		else {
> +			unsigned long pfn = page_to_pfn(pages[i]);
> +			WARN_ON(PagePrivate(pages[i]));
> +			SetPagePrivate(pages[i]);
> +			set_page_private(pages[i], mfn);
> +			pages[i]->index = pfn_to_mfn(pfn);
> +			if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn))))
> +				return -ENOMEM;

What happens if the page is PageHighMem?

This looks like a subset of m2p_add_override, but it is missing some
relevant bits, like the PageHighMem check, or the p2m(m2p(mfn)) == mfn
check.  Maybe we can find a way to avoid duplicating the code.
We could split m2p_add_override in two functions or add yet another
parameter to it.


> +		}
>  		if (ret)
>  			goto out;
>  	}
> @@ -937,17 +951,33 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>  	if (lazy)
>  		arch_leave_lazy_mmu_mode();
>  
> -	return ret;
> +	return 0;
> +}
> +
> +int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
> +		    struct page **pages, unsigned int count)
> +{
> +	return __gnttab_map_refs(map_ops, NULL, pages, count, false);
>  }
>  EXPORT_SYMBOL_GPL(gnttab_map_refs);
>  
> -int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
> +int gnttab_map_refs_userspace(struct gnttab_map_grant_ref *map_ops,
> +			      struct gnttab_map_grant_ref *kmap_ops,
> +			      struct page **pages, unsigned int count)
> +{
> +	return __gnttab_map_refs(map_ops, kmap_ops, pages, count, true);
> +}
> +EXPORT_SYMBOL_GPL(gnttab_map_refs_userspace);
> +
> +int __gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>  		      struct gnttab_map_grant_ref *kmap_ops,
> -		      struct page **pages, unsigned int count)
> +		      struct page **pages, unsigned int count,
> +		      bool m2p_override)
>  {
>  	int i, ret;
>  	bool lazy = false;
>  
> +	BUG_ON(kmap_ops && !m2p_override);
>  	ret = HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, unmap_ops, count);
>  	if (ret)
>  		return ret;
> @@ -958,17 +988,26 @@ int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>  			set_phys_to_machine(unmap_ops[i].host_addr >> PAGE_SHIFT,
>  					INVALID_P2M_ENTRY);
>  		}
> -		return ret;
> +		return 0;
>  	}
>  
> -	if (!in_interrupt() && paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
> +	if (m2p_override &&
> +	    !in_interrupt() &&
> +	    paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
>  		arch_enter_lazy_mmu_mode();
>  		lazy = true;
>  	}
>  
>  	for (i = 0; i < count; i++) {
> -		ret = m2p_remove_override(pages[i], kmap_ops ?
> -				       &kmap_ops[i] : NULL);
> +		if (m2p_override)
> +			ret = m2p_remove_override(pages[i], kmap_ops ?
> +						  &kmap_ops[i] : NULL);
> +		else {
> +			unsigned long pfn = page_to_pfn(pages[i]);
> +			WARN_ON(!PagePrivate(pages[i]));
> +			ClearPagePrivate(pages[i]);
> +			set_phys_to_machine(pfn, pages[i]->index);

same here: let's try to avoid code duplication


> +		}
>  		if (ret)
>  			goto out;
>  	}
> @@ -977,10 +1016,24 @@ int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>  	if (lazy)
>  		arch_leave_lazy_mmu_mode();
>  
> -	return ret;
> +	return 0;
> +}
> +
> +int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *map_ops,
> +		    struct page **pages, unsigned int count)
> +{
> +	return __gnttab_unmap_refs(map_ops, NULL, pages, count, false);
>  }
>  EXPORT_SYMBOL_GPL(gnttab_unmap_refs);
>  
> +int gnttab_unmap_refs_userspace(struct gnttab_unmap_grant_ref *map_ops,
> +				struct gnttab_map_grant_ref *kmap_ops,
> +				struct page **pages, unsigned int count)
> +{
> +	return __gnttab_unmap_refs(map_ops, kmap_ops, pages, count, true);
> +}
> +EXPORT_SYMBOL_GPL(gnttab_unmap_refs_userspace);
> +
>  static unsigned nr_status_frames(unsigned nr_grant_frames)
>  {
>  	BUG_ON(grefs_per_grant_frame == 0);
