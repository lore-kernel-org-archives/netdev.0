From: Zoltan Kiss <zoltan.kiss@schaman.hu>
Subject: Re: [PATCH net-next v5 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Sat, 22 Feb 2014 22:33:57 +0000
Message-ID: <530925D5.4010800@schaman.hu>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	 <1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com> <1392745235.23084.60.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392745235.23084.60.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/14 17:40, Ian Campbell wrote:
> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>> This patch changes the grant copy on the TX patch to grant mapping
>
> Both this and the previous patch had a single sentence commit message (I
> count them together since they are split weirdly and are a single
> logical change to my eyes).
>
> Really a change of this magnitude deserves a commit message to match,
> e.g. explaining the approach which is taken by the code at a high level,
> what it is doing, how it is doing it, the rationale for using a kthread
> etc etc.
Ok, I'll  improve that

>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index f0f0c3d..b3daae2 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -122,7 +122,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	BUG_ON(skb->dev != dev);
>>
>>   	/* Drop the packet if vif is not ready */
>> -	if (vif->task == NULL || !xenvif_schedulable(vif))
>> +	if (vif->task == NULL ||
>> +	    vif->dealloc_task == NULL ||
>
> Under what conditions could this be true? Would it not represent a
> rather serious failure?
xenvif_start_xmit can start after xenvif_open, while the threads are 
created when the ring connects. I haven't checked under what 
circumstances can that happen, but I guess if it worked like that 
before, that's fine. If not, that's the topic of a different patch(series).

>
>> +	    !xenvif_schedulable(vif))
>>   		goto drop;
>>
>>   	/* At best we'll need one slot for the header and one for each
>> @@ -344,8 +346,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>>   	vif->pending_prod = MAX_PENDING_REQS;
>>   	for (i = 0; i < MAX_PENDING_REQS; i++)
>>   		vif->pending_ring[i] = i;
>> -	for (i = 0; i < MAX_PENDING_REQS; i++)
>> -		vif->mmap_pages[i] = NULL;
>> +	spin_lock_init(&vif->dealloc_lock);
>> +	spin_lock_init(&vif->response_lock);
>> +	/* If ballooning is disabled, this will consume real memory, so you
>> +	 * better enable it.
>
> Almost no one who would be affected by this is going to read this
> comment. And it doesn't just require enabling ballooning, but actually
> booting with some maxmem "slack" to leave space.
Where should we document this? I mean, in case David doesn't fix this 
before acceptance of this patch series :)


>> @@ -432,6 +454,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>>
>>   	vif->task = task;
>>
>> +	task = kthread_create(xenvif_dealloc_kthread,
>> +					   (void *)vif,
>> +					   "%s-dealloc",
>> +					   vif->dev->name);
>
> This is separate to the existing kthread that handles rx stuff. If they
> cannot or should not be combined then I think the existing one needs
> renaming, both the function and the thread itself in a precursor patch.
I've explained in another email about the reasons why they are separate 
thread. I'll rename the existing thread and functions

>
>> @@ -494,6 +534,23 @@ void xenvif_disconnect(struct xenvif *vif)
>>
>>   void xenvif_free(struct xenvif *vif)
>>   {
>> +	int i, unmap_timeout = 0;
>> +
>> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
>> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>> +			unmap_timeout++;
>> +			schedule_timeout(msecs_to_jiffies(1000));
>
> What are we waiting for here? Have we taken any action to ensure that it
> is going to happen, like kicking something?
We are waiting for skb's to be freed so we can return the slots. They 
are not owned by us after we sent them, and we don't know who owns them. 
As discussed months ago, it is safe to assume that other devices won't 
sit on it indefinitely. If it goes to userspace or further up the stack 
to IP layer, we swap the pages out with local ones. The only place where 
things can go wrong is an another netback thread, that's handled in 
patch #8.

>
>> +			if (unmap_timeout > 9 &&
>
> Why 9? Why not rely on net_ratelimit to DTRT? Or is it normal for this
> to fail at least once?
As mentioned earlier, this is quite temporary here, it is improved in 
patch #8

>
>> +			    net_ratelimit())
>> +				netdev_err(vif->dev,
>
> I thought there was a ratelimited netdev printk which combined the
> limiting and the printing in one function call. Maybe I am mistaken.
There is indeed, net_err_ratelimited and friends. But they call pr_err 
instead of netdev_err, so we lose the vif name from the log entry, which 
could be quite important. If someone introduce a netdev_err_ratelimit 
which calls netdev_err, we can change this, but I would defer this to a 
later patch.


>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 195602f..747b428 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -646,9 +646,12 @@ static void xenvif_tx_err(struct xenvif *vif,
>>   			  struct xen_netif_tx_request *txp, RING_IDX end)
>>   {
>>   	RING_IDX cons = vif->tx.req_cons;
>> +	unsigned long flags;
>>
>>   	do {
>> +		spin_lock_irqsave(&vif->response_lock, flags);
>
> Looking at the callers you have added it would seem more natural to
> handle the locking within make_tx_response itself.
>
> What are you locking against here? Is this different to the dealloc
> lock? If the concern is the rx action stuff and the dealloc stuff
> conflicting perhaps a single vif lock would make sense?
I've improved the comment, as mentioned in another email, here is it:

	/* This prevents zerocopy callbacks  to race over dealloc_ring */
	spinlock_t callback_lock;
	/* This prevents dealloc thread and NAPI instance to race over response
	 * creation and pending_ring in xenvif_idx_release. In xenvif_tx_err
	 * it only protect response creation
	 */

>> @@ -936,18 +879,24 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>>   		head = tx_info->head;
>>
>>   		/* Check error status: if okay then remember grant handle. */
>> -		do {
>>   			newerr = (++gop)->status;
>> -			if (newerr)
>> -				break;
>> -			peek = vif->pending_ring[pending_index(++head)];
>> -		} while (!pending_tx_is_head(vif, peek));
>>
>>   		if (likely(!newerr)) {
>> +			if (vif->grant_tx_handle[pending_idx] !=
>> +			    NETBACK_INVALID_HANDLE) {
>> +				netdev_err(vif->dev,
>> +					   "Stale mapped handle! pending_idx %x handle %x\n",
>> +					   pending_idx,
>> +					   vif->grant_tx_handle[pending_idx]);
>> +				BUG();
>> +			}
>
> You had the same thing earlier. Perhaps a helper function would be
> useful?
Makes sense, I'll do that.

>
>> +			vif->grant_tx_handle[pending_idx] = gop->handle;
>>   			/* Had a previous error? Invalidate this fragment. */
>> -			if (unlikely(err))
>> +			if (unlikely(err)) {
>> +				xenvif_idx_unmap(vif, pending_idx);
>>   				xenvif_idx_release(vif, pending_idx,
>>   						   XEN_NETIF_RSP_OKAY);
>
> Would it make sense to unmap and release in a single function? (I
> Haven't looked to see if you ever do one without the other, but the next
> page of diff had two more occurrences of them together)
Yep, it's better call idx_release from unmap instead of doing it 
separately all the time.


>> @@ -960,9 +909,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>>
>>   		/* First error: invalidate header and preceding fragments. */
>>   		pending_idx = *((u16 *)skb->data);
>> +		xenvif_idx_unmap(vif, pending_idx);
>>   		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
>>   		for (j = start; j < i; j++) {
>>   			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
>> +			xenvif_idx_unmap(vif, pending_idx);
>>   			xenvif_idx_release(vif, pending_idx,
>>   					   XEN_NETIF_RSP_OKAY);
>>   		}
>
>>   	}
>> +	/* FIXME: __skb_fill_page_desc set this to true because page->pfmemalloc
>> +	 * overlaps with "index", and "mapping" is not set. I think mapping
>> +	 * should be set. If delivered to local stack, it would drop this
>> +	 * skb in sk_filter unless the socket has the right to use it.
>
> What is the plan to fix this?
Probably not using "index" during grant mapping. When it is solved 
somehow we can clean this up.

>
> Is this dropping not a significant issue (TBH I'm not sure what "has the
> right to use it" would entail).
It doesn't happen as we fix it up with this workaround.

>
>> +	 */
>> +	skb->pfmemalloc	= false;
>>   }
>>
>>   static int xenvif_get_extras(struct xenvif *vif,
>> @@ -1372,7 +1341,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>
>> @@ -1581,7 +1535,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   		else if (txp->flags & XEN_NETTXF_data_validated)
>>   			skb->ip_summed = CHECKSUM_UNNECESSARY;
>>
>> -		xenvif_fill_frags(vif, skb);
>> +		xenvif_fill_frags(vif,
>> +				  skb,
>> +				  skb_shinfo(skb)->destructor_arg ?
>> +				  pending_idx :
>> +				  INVALID_PENDING_IDX
>
> Couldn't xenvif_fill_frags calculate the 3rd argument itself given that
> it has skb in hand.
We still have to pass pending_idx, as it is no longer in skb->data. I 
have plans (I've already prototyped it, actually) to move that 
pending_idx from skb->data to skb->cb, if that happens, this won't be 
necessary.
On the other hand, it makes more sense just to just pass pending_idx, 
and in fill_frags we can decide based on destructor_arg whether do we 
need it or not.

>> @@ -1595,6 +1553,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   		if (checksum_setup(vif, skb)) {
>>   			netdev_dbg(vif->dev,
>>   				   "Can't setup checksum in net_tx_action\n");
>> +			/* We have to set this flag so the dealloc thread can
>> +			 * send the slots back
>
> Wouldn't it be more accurate to say that we need it so that the callback
> happens (which we then use to trigger the dealloc thread)?
Yep, I'll change that.

Zoli
