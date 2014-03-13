From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 4/9] xen-netback: Introduce TX grant mapping
Date: Thu, 13 Mar 2014 13:17:58 +0000
Message-ID: <5321B006.9070608@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>	 <1394142511-14827-5-git-send-email-zoltan.kiss@citrix.com> <1394706812.25873.28.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394706812.25873.28.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/14 10:33, Ian Campbell wrote:
> On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
>> @@ -135,13 +146,31 @@ struct xenvif {
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
>> -
>> +	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
>> +	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
>
> I wonder if we should break some of these arrays into separate
> allocations? Wasn't there a problem with sizeof(struct xenvif) at one
> point?
tx_copy_ops will be removed in the next patch. Yes, for grant_copy_op we 
allocate it separately, because it has MAX_SKB_FRAGS * 
XEN_NETIF_RX_RING_SIZE elements, but that's for the RX thread

>
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index bc32627..1fe9fe5 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -493,6 +533,23 @@ void xenvif_disconnect(struct xenvif *vif)
>>
>>   void xenvif_free(struct xenvif *vif)
>>   {
>> +	int i, unmap_timeout = 0;
>> +
>> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
>> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>> +			unmap_timeout++;
>> +			schedule_timeout(msecs_to_jiffies(1000));
>> +			if (unmap_timeout > 9 &&
>> +			    net_ratelimit())
>
> Does this really reach 80 columns when unwrapped?
Not here, but in a later patch 9 will be replaced with 
worst_case_skb_lifetime.

>
> (there seems to my eye to be a lot of overaggressive wrapping in this
> patch, but nevermind)
I tried to fix every warning and error noticed by checkpatch.pl, however 
there are still a few lines longer than 80, just because I couldn't 
reasonably wrap them.
>
>> +				netdev_err(vif->dev,
>> +					   "Page still granted! Index: %x\n",
>> +					   i);
>> +			i = -1;
>
> Should there not be a break here? Otherwise don't we restart the for
> loop from 0 again? If that is intentional then a comment would be very
> useful.
Yes, that's intentional, we shouldn't exit this loop until everything is 
unmapped. An i-- would be fine as well. I will put a comment there.

>
>> @@ -919,11 +873,38 @@ err:
>>   	return NULL;
>>   }
>>
>> +static inline void xenvif_grant_handle_set(struct xenvif *vif,
>> +					   u16 pending_idx,
>> +					   grant_handle_t handle)
>> +{
>> +	if (unlikely(vif->grant_tx_handle[pending_idx] !=
>> +		     NETBACK_INVALID_HANDLE)) {
>> +		netdev_err(vif->dev,
>
> Is this in any way guest triggerable? Needs to be ratelimited in that
> case (and arguably even if not?)
It shouldn't be guest triggerable. It only means netback really screwed 
up the accounting of granted pages. There is a BUG right after it, and 
the kernel should panic here. David suggested to replace this whole 
stuff with a BUG_ON. One counterargument is that there is a slight 
chance printing pending_idx can provide some useful info. At least back 
in the beginning when I tried to fix some basic mistakes it was useful.
>
>> +			   "Trying to overwrite active handle! pending_idx: %x\n",
>> +			   pending_idx);
>> +		BUG();
>> +	}
>> +	vif->grant_tx_handle[pending_idx] = handle;
>> +}
>> +
>> +static inline void xenvif_grant_handle_reset(struct xenvif *vif,
>> +					     u16 pending_idx)
>> +{
>> +	if (unlikely(vif->grant_tx_handle[pending_idx] ==
>> +		     NETBACK_INVALID_HANDLE)) {
>> +		netdev_err(vif->dev,
>
> Likewise.
>
>> +			   "Trying to unmap invalid handle! pending_idx: %x\n",
>> +			   pending_idx);
>> +		BUG();
>> +	}
>> +	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
>> +}
>> +
>> @@ -1001,6 +982,17 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
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
>
> #define callback_for(vif, pending_idx) .... would make this and a bunch
> of other places a lot less verbose IMHO.
Yeah, I was thinking about that, but it's really used here and 2 places 
in tx_submit, so I didn't bother to do it.

>
>> +		index = pending_index(vif->pending_prod);
>> +		vif->pending_ring[index] = pending_idx;
>> +		/* TX shouldn't use the index before we give it back here */
>
> I hope this comment refers to the pending_prod++ and not the mb(), since
> the barrier only guarantees visibility after that point, but not
> invisibility before this point.
Yes, the NAPI instance will use vif->pending_ring[index] only after 
vif->pending_prod++, so the memory barrier makes sure that we set the 
element in the ring first and then increase the producer.

>
> [...]
>> +	/* Btw. already unmapped? */
>
> What does this comment mean? Is it a fixme? An indicator that
> xenvif_grant_handle_reset is supposed to handle this case or something
> else?
It comes from the time when xenvif_grant_handle_reset was not a 
standalone function. Yes, it refers to the check in the beginning of 
that function, and it should go there.
>
> I think there was another such comment earlier too.
>
>> +	xenvif_grant_handle_reset(vif, pending_idx);
>> +
>> +	ret = gnttab_unmap_refs(&tx_unmap_op, NULL,
>> +				&vif->mmap_pages[pending_idx], 1);
>> +	BUG_ON(ret);
>> +
>> +	xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
>> +}
>> +
>>   static inline int rx_work_todo(struct xenvif *vif)
>>   {
>>   	return !skb_queue_empty(&vif->rx_queue) &&
>
>
