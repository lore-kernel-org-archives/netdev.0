From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 13:59:53 +0800
Message-ID: <52D77559.5010106@oracle.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com> <52D66F11.204@citrix.com> <20140115114208.GK5698@zion.uk.xensource.com> <52D67677.4050407@citrix.com> <52D69864.9030207@oracle.com> <52D6A5B7.40503@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21862 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaAPGAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 01:00:08 -0500
In-Reply-To: <52D6A5B7.40503@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/1/15 23:13, David Vrabel wrote:
> On 15/01/14 14:17, annie li wrote:
>> I am thinking of two ways, and they can be implemented in new patches.
>> 1. If gnttab_end_foreign_access_ref succeeds, then kfree_skb is called
>> to free skb. Otherwise, using gnttab_end_foreign_access to release ref
>> and pages.
>> 2. Add a similar deferred way of gnttab_end_foreign_access in
>> gnttab_end_foreign_access_ref.
> Something like the following (untested!) patch is what I'm thinking of.
>
> Fixups to existing drivers (except netfront) are included but may not be
> quite correct.

Part of it implements the 1 above, if gnttab_end_foreign_access_ref 
fails and then use gnttab_end_foreign_access to end the grant. Another 
is splitting __free_page from gnttab_end_foreign_access. This is 
improvement for current grant end access, and all drivers that involve 
gnttab_end_foreign_access needs to do corresponding change.
I think it can be a separate patch from my clean up patch which fixes 
grant leaking in netfront.

Thanks
Annie
>
> 8<----------
>  From 76c254c8e020f4427e8f37c867622f0bfd5ac85f Mon Sep 17 00:00:00 2001
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Wed, 15 Jan 2014 15:04:52 +0000
> Subject: [PATCH] HACK! xen/gnttab: make gnttab_end_foreign_access() more
> useful
>
> This is UNTESTED and is an example of the sort of change I'm looking
> for.
>
> Freeing the page in gnttab_end_foreign_access() means it cannot be
> used where the pages are freed in some other way (e.g., as part of a
> kfree_skb()).
>
> Leave the freeing of the page to the caller.  If the page still has
> foreign users, take an additional reference before adding it to the
> deferred list.
>
> Hack all the users of the call to do something resembling the right
> thing.  Not quite sure on the blkfront changes.
> ---
>   drivers/block/xen-blkfront.c    |   22 +++++++++++++---------
>   drivers/char/tpm/xen-tpmfront.c |    3 +--
>   drivers/pci/xen-pcifront.c      |    3 +--
>   drivers/xen/grant-table.c       |   19 +++++++++++--------
>   include/xen/grant_table.h       |   11 ++++++-----
>   5 files changed, 32 insertions(+), 26 deletions(-)
>
> diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
> index aa846a4..a586496 100644
> --- a/drivers/xen/grant-table.c
> +++ b/drivers/xen/grant-table.c
> @@ -504,7 +504,7 @@ static void gnttab_handle_deferred(unsigned long unused)
>   			if (entry->page) {
>   				pr_debug("freeing g.e. %#x (pfn %#lx)\n",
>   					 entry->ref, page_to_pfn(entry->page));
> -				__free_page(entry->page);
> +				put_page(entry->page);
>   			} else
>   				pr_info("freeing g.e. %#x\n", entry->ref);
>   			kfree(entry);
> @@ -555,15 +555,18 @@ static void gnttab_add_deferred(grant_ref_t ref,
> bool readonly,
>   }
>
>   void gnttab_end_foreign_access(grant_ref_t ref, int readonly,
> -			       unsigned long page)
> +			       struct page *page)
>   {
> -	if (gnttab_end_foreign_access_ref(ref, readonly)) {
> +	if (gnttab_end_foreign_access_ref(ref, readonly))
>   		put_free_entry(ref);
> -		if (page != 0)
> -			free_page(page);
> -	} else
> -		gnttab_add_deferred(ref, readonly,
> -				    page ? virt_to_page(page) : NULL);
> +	else {
> +		/*
> +		 * Take a reference to the page so it's not freed
> +		 * while the foreign domain still has access to it.
> +		 */
> +		get_page(page);
> +		gnttab_add_deferred(ref, readonly, page);
> +	}
>   }
>   EXPORT_SYMBOL_GPL(gnttab_end_foreign_access);
>
> diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
> index 694dcaf..ffa3ce6 100644
> --- a/include/xen/grant_table.h
> +++ b/include/xen/grant_table.h
> @@ -91,13 +91,14 @@ bool gnttab_trans_grants_available(void);
>   int gnttab_end_foreign_access_ref(grant_ref_t ref, int readonly);
>
>   /*
> - * Eventually end access through the given grant reference, and once that
> - * access has been ended, free the given page too.  Access will be ended
> - * immediately iff the grant entry is not in use, otherwise it will happen
> - * some time later.  page may be 0, in which case no freeing will occur.
> + * Eventually end access through the given grant reference, if the
> + * page is still in use an additional reference is taken and released
> + * when access has ended.  Access will be ended immediately iff the
> + * grant entry is not in use, otherwise it will happen some time
> + * later.
>    */
>   void gnttab_end_foreign_access(grant_ref_t ref, int readonly,
> -			       unsigned long page);
> +			       struct page *page);
>
>   int gnttab_grant_foreign_transfer(domid_t domid, unsigned long pfn);
>
> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index c4a4c90..45a2a01 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -931,14 +931,16 @@ static void blkif_free(struct blkfront_info *info,
> int suspend)
>   	if (!list_empty(&info->grants)) {
>   		list_for_each_entry_safe(persistent_gnt, n,
>   		                         &info->grants, node) {
> +			struct page *page = pfn_to_page(persistent_gnt->pfn);
> +
>   			list_del(&persistent_gnt->node);
>   			if (persistent_gnt->gref != GRANT_INVALID_REF) {
>   				gnttab_end_foreign_access(persistent_gnt->gref,
> -				                          0, 0UL);
> +				                          0, page);
>   				info->persistent_gnts_c--;
>   			}
>   			if (info->feature_persistent)
> -				__free_page(pfn_to_page(persistent_gnt->pfn));
> +				__free_page(page);
>   			kfree(persistent_gnt);
>   		}
>   	}
> @@ -970,10 +972,13 @@ static void blkif_free(struct blkfront_info *info,
> int suspend)
>   		       info->shadow[i].req.u.indirect.nr_segments :
>   		       info->shadow[i].req.u.rw.nr_segments;
>   		for (j = 0; j < segs; j++) {
> +			struct page *page;
> +
>   			persistent_gnt = info->shadow[i].grants_used[j];
> -			gnttab_end_foreign_access(persistent_gnt->gref, 0, 0UL);
> +			page = pfn_to_page(persistent_gnt->pfn);
> +			gnttab_end_foreign_access(persistent_gnt->gref, 0, page);
>   			if (info->feature_persistent)
> -				__free_page(pfn_to_page(persistent_gnt->pfn));
> +				__free_page(page);
>   			kfree(persistent_gnt);
>   		}
>
> @@ -1010,10 +1015,11 @@ free_shadow:
>   	/* Free resources associated with old device channel. */
>   	if (info->ring_ref != GRANT_INVALID_REF) {
>   		gnttab_end_foreign_access(info->ring_ref, 0,
> -					  (unsigned long)info->ring.sring);
> +					  virt_to_page(info->ring.sring));
>   		info->ring_ref = GRANT_INVALID_REF;
>   		info->ring.sring = NULL;
>   	}
> +	free_page((unsigned long)info->ring.sring);
>   	if (info->irq)
>   		unbind_from_irqhandler(info->irq, info);
>   	info->evtchn = info->irq = 0;
> @@ -1053,7 +1059,7 @@ static void blkif_completion(struct blk_shadow *s,
> struct blkfront_info *info,
>   	}
>   	/* Add the persistent grant into the list of free grants */
>   	for (i = 0; i < nseg; i++) {
> -		if (gnttab_query_foreign_access(s->grants_used[i]->gref)) {
> +		if (gnttab_end_foreign_access_ref(s->grants_used[i]->gref, 0)) {
>   			/*
>   			 * If the grant is still mapped by the backend (the
>   			 * backend has chosen to make this grant persistent)
> @@ -1072,14 +1078,13 @@ static void blkif_completion(struct blk_shadow
> *s, struct blkfront_info *info,
>   			 * so it will not be picked again unless we run out of
>   			 * persistent grants.
>   			 */
> -			gnttab_end_foreign_access(s->grants_used[i]->gref, 0, 0UL);
>   			s->grants_used[i]->gref = GRANT_INVALID_REF;
>   			list_add_tail(&s->grants_used[i]->node, &info->grants);
>   		}
>   	}
>   	if (s->req.operation == BLKIF_OP_INDIRECT) {
>   		for (i = 0; i < INDIRECT_GREFS(nseg); i++) {
> -			if (gnttab_query_foreign_access(s->indirect_grants[i]->gref)) {
> +			if (gnttab_end_foreign_access_ref(s->indirect_grants[i]->gref, 0)) {
>   				if (!info->feature_persistent)
>   					pr_alert_ratelimited("backed has not unmapped grant: %u\n",
>   							     s->indirect_grants[i]->gref);
> @@ -1088,7 +1093,6 @@ static void blkif_completion(struct blk_shadow *s,
> struct blkfront_info *info,
>   			} else {
>   				struct page *indirect_page;
>
> -				gnttab_end_foreign_access(s->indirect_grants[i]->gref, 0, 0UL);
>   				/*
>   				 * Add the used indirect page back to the list of
>   				 * available pages for indirect grefs.
> diff --git a/drivers/char/tpm/xen-tpmfront.c
> b/drivers/char/tpm/xen-tpmfront.c
> index c8ff4df..00d1132 100644
> --- a/drivers/char/tpm/xen-tpmfront.c
> +++ b/drivers/char/tpm/xen-tpmfront.c
> @@ -315,8 +315,7 @@ static void ring_free(struct tpm_private *priv)
>   	if (priv->ring_ref)
>   		gnttab_end_foreign_access(priv->ring_ref, 0,
>   				(unsigned long)priv->shr);
> -	else
> -		free_page((unsigned long)priv->shr);
> +	free_page((unsigned long)priv->shr);
>
>   	if (priv->chip && priv->chip->vendor.irq)
>   		unbind_from_irqhandler(priv->chip->vendor.irq, priv);
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index f7197a7..253a129 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -759,8 +759,7 @@ static void free_pdev(struct pcifront_device *pdev)
>   	if (pdev->gnt_ref != INVALID_GRANT_REF)
>   		gnttab_end_foreign_access(pdev->gnt_ref, 0 /* r/w page */,
>   					  (unsigned long)pdev->sh_info);
> -	else
> -		free_page((unsigned long)pdev->sh_info);
> +	free_page((unsigned long)pdev->sh_info);
>
>   	dev_set_drvdata(&pdev->xdev->dev, NULL);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
