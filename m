From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v6 4/10] xen-netback: Introduce TX grant mapping
Date: Wed, 5 Mar 2014 21:33:04 +0000
Message-ID: <53179810.3080907@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com> <1393972341-21135-5-git-send-email-zoltan.kiss@citrix.com> <20140305122814.GG19620@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140305122814.GG19620@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/14 12:28, Wei Liu wrote:
> On Tue, Mar 04, 2014 at 10:32:15PM +0000, Zoltan Kiss wrote:

>> - introduce xenvif_tx_pending_slots_available() as that code is used often
>
> It was introduced in other patch, not this one.
Yep, first I introduced here, but then I haven't updated the patch 
history accordingly :)

>> @@ -136,13 +141,31 @@ struct xenvif {
>>   	pending_ring_idx_t pending_cons;
>>   	u16 pending_ring[MAX_PENDING_REQS];
>>   	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
>> +	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
>>
>>   	/* Coalescing tx requests before copying makes number of grant
>>   	 * copy ops greater or equal to number of slots required. In
>>   	 * worst case a tx request consumes 2 gnttab_copy.
>>   	 */
>>   	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
>
> Forget to remove this?
No, it is removed in the next patch.

> [...]
>> @@ -431,6 +455,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>>
>>   	vif->task = task;
>>
>> +	task = kthread_create(xenvif_dealloc_kthread,
>> +					   (void *)vif,
>> +					   "%s-dealloc",
>> +					   vif->dev->name);
>
> Indentation.
Fixed


>> +static inline void xenvif_grant_handle_set(struct xenvif *vif,
>> +					   u16 pending_idx,
>> +					   grant_handle_t handle)
>> +{
>> +	if (unlikely(vif->grant_tx_handle[pending_idx] !=
>> +		     NETBACK_INVALID_HANDLE)) {
>> +		netdev_err(vif->dev,
>> +			   "Trying to unmap invalid handle! "
>> +			   "pending_idx: %x\n", pending_idx);
>
> This message is not very clear. I think it suits _reset but not here.
> In this function the bug should be the attempt to over-write existing
> handle, right?
Yes, I fixed that to "Trying to overwrite active handle!"

>>   static int xenvif_tx_check_gop(struct xenvif *vif,
>>   			       struct sk_buff *skb,
>> -			       struct gnttab_copy **gopp)
>> +			       struct gnttab_map_grant_ref **gopp)
>>   {
>> -	struct gnttab_copy *gop = *gopp;
>> +	struct gnttab_map_grant_ref *gop = *gopp;
>>   	u16 pending_idx = *((u16 *)skb->cb);
>>   	struct skb_shared_info *shinfo = skb_shinfo(skb);
>>   	struct pending_tx_info *tx_info;
>> @@ -927,6 +907,8 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>>   	err = gop->status;
>>   	if (unlikely(err))
>>   		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
>
> You don't need to replace this with xenvif_idx_unmap?
No, this slot was not successfully mapped, so you shouldn't unmap it.


>> @@ -993,6 +973,17 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
>>
>>   		pending_idx = frag_get_pending_idx(frag);
>>
>> +		/* If this is not the first frag, chain it to the previous*/
>> +		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
>> +			skb_shinfo(skb)->destructor_arg =
>> +				&vif->pending_tx_info[pending_idx].callback_struct;
>> +		else if (likely(pending_idx != prev_pending_idx))
>> +			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
>> +				&(vif->pending_tx_info[pending_idx].callback_struct);
>> +
>
> Could you document how these pending_tx_info'es are chained together? It
> looks like it's still the same mechanism in coalescing, but I'm not
> quite sure... And since you remove all definitions for coalescing in the
> next patch we eventually reach a point that there's no document about
> the mechanism at all, which is not good.
It is similar indeed. I'll document it in common.h

>
>> +		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
>> +		prev_pending_idx = pending_idx;
>> +
>>   		txp = &vif->pending_tx_info[pending_idx].req;
>>   		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
>>   		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
>> @@ -1000,10 +991,15 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
>>   		skb->data_len += txp->size;
>>   		skb->truesize += txp->size;
>>
>> -		/* Take an extra reference to offset xenvif_idx_release */
>> +		/* Take an extra reference to offset network stack's put_page */
>>   		get_page(vif->mmap_pages[pending_idx]);
>> -		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
>
> So when is this slot released? Your previous changes basically replace
> xenvif_idx_release with xenvif_idx_unmap, but not this one, why?
We are using grant mapping now, not copy. The slot is released when the 
callback is called and the dealloc thread unmapped the pages.

>> @@ -1406,48 +1497,40 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>>   			       u8 status)
>>   {
>>   	struct pending_tx_info *pending_tx_info;
>> -	pending_ring_idx_t head;
>> +	pending_ring_idx_t index;
>>   	u16 peek; /* peek into next tx request */
>> +	unsigned long flags;
>>
>> -	BUG_ON(vif->mmap_pages[pending_idx] == (void *)(~0UL));
>> -
>> -	/* Already complete? */
>> -	if (vif->mmap_pages[pending_idx] == NULL)
>> -		return;
>> -
>> -	pending_tx_info = &vif->pending_tx_info[pending_idx];
>> -
>> -	head = pending_tx_info->head;
>> -
>> -	BUG_ON(!pending_tx_is_head(vif, head));
>> -	BUG_ON(vif->pending_ring[pending_index(head)] != pending_idx);
>> -
>> -	do {
>> -		pending_ring_idx_t index;
>> -		pending_ring_idx_t idx = pending_index(head);
>> -		u16 info_idx = vif->pending_ring[idx];
>> -
>> -		pending_tx_info = &vif->pending_tx_info[info_idx];
>> +		pending_tx_info = &vif->pending_tx_info[pending_idx];
>
> Is there indentation with this hunk? I don't see left bracket in this
> function.
Hm, for some reason diff screws up this hunk: changes in 
xenvif_idx_release are overlapped with the new xenvif_idx_unmap 
function. I moved the latter after make_rx_response so now it is in a 
separate hunk.
Also, I kept the indentation of the make_tx_response(...) line, so it 
doesn't change here and diff will center the changes around it. I think 
it makes review easier, however this above mentioned diff madness 
screwed that up temporarily.

Zoli
