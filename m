From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map definitions
Date: Tue, 18 Feb 2014 20:36:29 +0000
Message-ID: <5303C44D.4070500@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com> <1392743214.23084.38.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39331 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaBRUgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 15:36:33 -0500
In-Reply-To: <1392743214.23084.38.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/14 17:06, Ian Campbell wrote:
> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>> This patch contains the new definitions necessary for grant mapping.
>
> Is this just adding a bunch of (currently) unused functions? That's a
> slightly odd way to structure a series. They don't seem to be "generic
> helpers" or anything so it would be more normal to introduce these as
> they get used -- it's a bit hard to review them out of context.
I've created two patches because they are quite huge even now, 
separately. Together they would be a ~500 line change. That was the best 
I could figure out keeping in mind that bisect should work. But as I 
wrote in the first email, I welcome other suggestions. If you and Wei 
prefer this two patch in one big one, I merge them in the next version.

>> v2:
>
> This sort of intraversion changelog should go after the S-o-b and a
> "---" marker. This way they are not included in the final commit
> message.
Ok, I'll do that.

>> @@ -226,6 +248,12 @@ bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed);
>>
>>   void xenvif_stop_queue(struct xenvif *vif);
>>
>> +/* Callback from stack when TX packet can be released */
>> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
>> +
>> +/* Unmap a pending page, usually has to be called before xenvif_idx_release */
>
> "usually" or always? How does one determine when it is or isn't
> appropriate to call it later?
If you haven't unmapped it before, then you have to call it. I'll 
clarify the comment


>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index 7669d49..f0f0c3d 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -38,6 +38,7 @@
>>
>>   #include <xen/events.h>
>>   #include <asm/xen/hypercall.h>
>> +#include <xen/balloon.h>
>
> What is this for?
For alloc/free_xenballooned_pages

>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index bb241d0..195602f 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -773,6 +773,20 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
>>   	return page;
>>   }
>>
>> +static inline void xenvif_tx_create_gop(struct xenvif *vif,
>> +					u16 pending_idx,
>> +					struct xen_netif_tx_request *txp,
>> +					struct gnttab_map_grant_ref *gop)
>> +{
>> +	vif->pages_to_map[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
>> +	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
>> +			  GNTMAP_host_map | GNTMAP_readonly,
>> +			  txp->gref, vif->domid);
>> +
>> +	memcpy(&vif->pending_tx_info[pending_idx].req, txp,
>> +	       sizeof(*txp));
>
> Can this not go in xenvif_tx_build_gops? Or conversely should the
> non-mapping code there be factored out?
>
> Given the presence of both kinds of gop the name of this function needs
> to be more specific I think.
It is called from tx_build_gop and get_requests, and the non-mapping 
code will go away. I have a patch on top of this series which does grant 
copy for the header part, but it doesn't create a separate function for 
the single copy operation, and you'll still call this function from 
build_gops to handle the rest of the first slot (if any)
So TX will have only one kind of gop.

>
>> +}
>> +
>>   static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
>>   					       struct sk_buff *skb,
>>   					       struct xen_netif_tx_request *txp,
>> @@ -1612,6 +1626,107 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   	return work_done;
>>   }
>>
>> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
>> +{
>> +	unsigned long flags;
>> +	pending_ring_idx_t index;
>> +	u16 pending_idx = ubuf->desc;
>> +	struct pending_tx_info *temp =
>> +		container_of(ubuf, struct pending_tx_info, callback_struct);
>> +	struct xenvif *vif = container_of(temp - pending_idx,
>
> This is subtracting a u16 from a pointer?
Yes. I moved this to an ubuf_to_vif helper for the next version of the 
patch series

>
>> +					  struct xenvif,
>> +					  pending_tx_info[0]);
>> +
>> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
>> +	do {
>> +		pending_idx = ubuf->desc;
>> +		ubuf = (struct ubuf_info *) ubuf->ctx;
>> +		index = pending_index(vif->dealloc_prod);
>> +		vif->dealloc_ring[index] = pending_idx;
>> +		/* Sync with xenvif_tx_dealloc_action:
>> +		 * insert idx then incr producer.
>> +		 */
>> +		smp_wmb();
>
> Is this really needed given that there is a lock held?
Yes, as the comment right above explains. This actually comes from 
classic kernel's netif_idx_release
>
> Or what is dealloc_lock protecting against?
The callbacks from each other. So it is checjed only in this function.
>
>> +		vif->dealloc_prod++;
>
> What happens if the dealloc ring becomes full, will this wrap and cause
> havoc?
Nope, if the dealloc ring is full, the value of the last increment won't 
be used to index the dealloc ring again until some space made available. 
Of course if something broke and we have more pending slots than tx ring 
or dealloc slots then it can happen. Do you suggest a 
BUG_ON(vif->dealloc_prod - vif->dealloc_cons >= MAX_PENDING_REQS)?

>
>> +	} while (ubuf);
>> +	wake_up(&vif->dealloc_wq);
>> +	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
>> +}
>> +
>> +static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>> +{
>> +	struct gnttab_unmap_grant_ref *gop;
>> +	pending_ring_idx_t dc, dp;
>> +	u16 pending_idx, pending_idx_release[MAX_PENDING_REQS];
>> +	unsigned int i = 0;
>> +
>> +	dc = vif->dealloc_cons;
>> +	gop = vif->tx_unmap_ops;
>> +
>> +	/* Free up any grants we have finished using */
>> +	do {
>> +		dp = vif->dealloc_prod;
>> +
>> +		/* Ensure we see all indices enqueued by all
>> +		 * xenvif_zerocopy_callback().
>> +		 */
>> +		smp_rmb();
>> +
>> +		while (dc != dp) {
>> +			pending_idx =
>> +				vif->dealloc_ring[pending_index(dc++)];
>> +
>> +			/* Already unmapped? */
>> +			if (vif->grant_tx_handle[pending_idx] ==
>> +				NETBACK_INVALID_HANDLE) {
>> +				netdev_err(vif->dev,
>> +					   "Trying to unmap invalid handle! "
>> +					   "pending_idx: %x\n", pending_idx);
>> +				BUG();
>> +			}
>> +
>> +			pending_idx_release[gop-vif->tx_unmap_ops] =
>> +				pending_idx;
>> +			vif->pages_to_unmap[gop-vif->tx_unmap_ops] =
>> +				vif->mmap_pages[pending_idx];
>> +			gnttab_set_unmap_op(gop,
>> +					    idx_to_kaddr(vif, pending_idx),
>> +					    GNTMAP_host_map,
>> +					    vif->grant_tx_handle[pending_idx]);
>> +			vif->grant_tx_handle[pending_idx] =
>> +				NETBACK_INVALID_HANDLE;
>> +			++gop;
>
> Can we run out of space in the gop array?
No, unless the same thing happen as at my previous answer. BUG_ON() here 
as well?
>
>> +		}
>> +
>> +	} while (dp != vif->dealloc_prod);
>> +
>> +	vif->dealloc_cons = dc;
>
> No barrier here?
dealloc_cons only used in the dealloc_thread. dealloc_prod is used by 
the callback and the thread as well, that's why we need mb() in 
previous. Btw. this function comes from classic's net_tx_action_dealloc

>
>> +	if (gop - vif->tx_unmap_ops > 0) {
>> +		int ret;
>> +		ret = gnttab_unmap_refs(vif->tx_unmap_ops,
>> +					vif->pages_to_unmap,
>> +					gop - vif->tx_unmap_ops);
>> +		if (ret) {
>> +			netdev_err(vif->dev, "Unmap fail: nr_ops %x ret %d\n",
>> +				   gop - vif->tx_unmap_ops, ret);
>> +			for (i = 0; i < gop - vif->tx_unmap_ops; ++i) {
>
> This seems liable to be a lot of spew on failure. Perhaps only log the
> ones where gop[i].status != success.
Ok, I'll change that.
>
> Have you considered whether or not the frontend can force this error to
> occur?
Not yet, good point. I guess if we successfully mapped the page, then 
there is no way a frontend to prevent unmapping. But worth further checking.
>
>> +				netdev_err(vif->dev,
>> +					   " host_addr: %llx handle: %x status: %d\n",
>> +					   gop[i].host_addr,
>> +					   gop[i].handle,
>> +					   gop[i].status);
>> +			}
>> +			BUG();
>> +		}
>> +	}
>> +
>> +	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
>> +		xenvif_idx_release(vif, pending_idx_release[i],
>> +				   XEN_NETIF_RSP_OKAY);
>> +}
>> +
>> +
>>   /* Called after netfront has transmitted */
>>   int xenvif_tx_action(struct xenvif *vif, int budget)
>>   {
>> @@ -1678,6 +1793,25 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>>   	vif->mmap_pages[pending_idx] = NULL;
>>   }
>>
>> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
>
> This is a single shot version of the batched xenvif_tx_dealloc_action
> version? Why not just enqueue the idx to be unmapped later?
This is called only from the NAPI instance. Using the dealloc ring 
require synchronization with the callback which can increase lock 
contention. On the other hand, if the guest sends small packets 
(<PAGE_SIZE), the TLB flushing can cause performance penalty. The above 
mentioned upcoming patch which gntcopy the header can prevent that 
(together with Malcolm's Xen side patch, which prevents TLB flush if the 
page were not touched in Dom0)

>> @@ -1826,6 +1965,28 @@ int xenvif_kthread(void *data)
>>   	return 0;
>>   }
>>
>> +int xenvif_dealloc_kthread(void *data)
>
> Is this going to be a thread per vif?
Yes. In the first versions I've put the dealloc in the NAPI instance 
(similarly as in classic, where it happened in tx_action), but that had 
an unexpected performance penalty: the callback has to notify whoever 
does the dealloc, that there is something to do. If it is the NAPI 
instance, it has to call napi_schedule. But if the packet were delivered 
to an another guest, the callback is called from thread context, and 
according to Eric Dumazet, napi_schedule from thread context can 
significantly delay softirq handling. So NAPI instance were delayed with 
miliseconds, and it caused terrible performance.
Moving this to the RX thread haven't seemed like a wise decision, so I 
made a new thread.
Actually in the next version of the patches I'll reintroduce 
__napi_schedule in the callback again, because if the NAPI instance 
still have unconsumed requests but not enough pending slots, it 
deschedule itself, and the callback has to schedule it again, if:
- unconsumed requests in the ring < XEN_NETBK_LEGACY_SLOTS_MAX
- there are enough free pending slots to handle them
- and the NAPI instance is not scheduled yet
This should really happen if netback is faster than target devices, but 
then it doesn't mean a bottleneck.

Zoli
