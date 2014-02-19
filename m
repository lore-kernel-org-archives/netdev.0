From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map definitions
Date: Wed, 19 Feb 2014 19:54:29 +0000
Message-ID: <53050BF5.1060009@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>		 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>	 <1392743214.23084.38.camel@kazak.uk.xensource.com>	 <5303C44D.4070500@citrix.com> <1392804319.23084.109.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392804319.23084.109.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/02/14 10:05, Ian Campbell wrote:
> On Tue, 2014-02-18 at 20:36 +0000, Zoltan Kiss wrote:
>> On 18/02/14 17:06, Ian Campbell wrote:
>>> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>>>> This patch contains the new definitions necessary for grant mapping.
>>>
>>> Is this just adding a bunch of (currently) unused functions? That's a
>>> slightly odd way to structure a series. They don't seem to be "generic
>>> helpers" or anything so it would be more normal to introduce these as
>>> they get used -- it's a bit hard to review them out of context.
>> I've created two patches because they are quite huge even now,
>> separately. Together they would be a ~500 line change. That was the best
>> I could figure out keeping in mind that bisect should work. But as I
>> wrote in the first email, I welcome other suggestions. If you and Wei
>> prefer this two patch in one big one, I merge them in the next version.
>
> I suppose it is hard to split a change like this up in a sensible way,
> but it is rather hard to review something which is split in two parts
> sensibly.
>
> If the combined patch too large to fit on the lists?
Well, it's ca. 30 kb, ~500 lines changed. I guess it's possible. It's up 
to you and Wei, if you would like them to be merged, I can do that.

>>>
>>>> +					  struct xenvif,
>>>> +					  pending_tx_info[0]);
>>>> +
>>>> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
>>>> +	do {
>>>> +		pending_idx = ubuf->desc;
>>>> +		ubuf = (struct ubuf_info *) ubuf->ctx;
>>>> +		index = pending_index(vif->dealloc_prod);
>>>> +		vif->dealloc_ring[index] = pending_idx;
>>>> +		/* Sync with xenvif_tx_dealloc_action:
>>>> +		 * insert idx then incr producer.
>>>> +		 */
>>>> +		smp_wmb();
>>>
>>> Is this really needed given that there is a lock held?
>> Yes, as the comment right above explains.
>
> My question is why do you need this sync if you are holding a lock, the
> comment doesn't tell me that. I suppose xenvif_tx_dealloc_action doesn't
> hold the dealloc_lock, but that is non-obvious from the names.
Ok, I'll clarify that in the comment.

>>>
>>>> +		vif->dealloc_prod++;
>>>
>>> What happens if the dealloc ring becomes full, will this wrap and cause
>>> havoc?
>> Nope, if the dealloc ring is full, the value of the last increment won't
>> be used to index the dealloc ring again until some space made available.
>
> I don't follow -- what makes this the case?
The dealloc ring has the same size as the pending ring, and you can only 
add slots to it which are already on the pending ring (the pending_idx 
comes from ubuf->desc), as you are essentially free up slots here on the 
pending ring.
So if the dealloc ring becomes full, vif->dealloc_prod - 
vif->dealloc_cons will be 256, which would be bad. But the while loop 
should exit here, as we shouldn't have any more pending slots. And if we 
dealloc and create free pending slots in dealloc_action, dealloc_cons 
will also advance.

>> Of course if something broke and we have more pending slots than tx ring
>> or dealloc slots then it can happen. Do you suggest a
>> BUG_ON(vif->dealloc_prod - vif->dealloc_cons >= MAX_PENDING_REQS)?
>
> A
>           BUG_ON(space in dealloc ring < number of slots needed to dealloc this skb)
> would seem to be the right thing, if that really is the invariant the
> code is supposed to be implementing.
Not exactly, it means BUG_ON(number of slots to dealloc > 
MAX_PENDING_REQS), and it should be at the end of the loop, without '='.

>>>> +static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>>>> +{
>>>> +	struct gnttab_unmap_grant_ref *gop;
>>>> +	pending_ring_idx_t dc, dp;
>>>> +	u16 pending_idx, pending_idx_release[MAX_PENDING_REQS];
>>>> +	unsigned int i = 0;
>>>> +
>>>> +	dc = vif->dealloc_cons;
>>>> +	gop = vif->tx_unmap_ops;
>>>> +
>>>> +	/* Free up any grants we have finished using */
>>>> +	do {
>>>> +		dp = vif->dealloc_prod;
>>>> +
>>>> +		/* Ensure we see all indices enqueued by all
>>>> +		 * xenvif_zerocopy_callback().
>>>> +		 */
>>>> +		smp_rmb();
>>>> +
>>>> +		while (dc != dp) {
>>>> +			pending_idx =
>>>> +				vif->dealloc_ring[pending_index(dc++)];
>>>> +
>>>> +			/* Already unmapped? */
>>>> +			if (vif->grant_tx_handle[pending_idx] ==
>>>> +				NETBACK_INVALID_HANDLE) {
>>>> +				netdev_err(vif->dev,
>>>> +					   "Trying to unmap invalid handle! "
>>>> +					   "pending_idx: %x\n", pending_idx);
>>>> +				BUG();
>>>> +			}
>>>> +
>>>> +			pending_idx_release[gop-vif->tx_unmap_ops] =
>>>> +				pending_idx;
>>>> +			vif->pages_to_unmap[gop-vif->tx_unmap_ops] =
>>>> +				vif->mmap_pages[pending_idx];
>>>> +			gnttab_set_unmap_op(gop,
>>>> +					    idx_to_kaddr(vif, pending_idx),
>>>> +					    GNTMAP_host_map,
>>>> +					    vif->grant_tx_handle[pending_idx]);
>>>> +			vif->grant_tx_handle[pending_idx] =
>>>> +				NETBACK_INVALID_HANDLE;
>>>> +			++gop;
>>>
>>> Can we run out of space in the gop array?
>> No, unless the same thing happen as at my previous answer. BUG_ON() here
>> as well?
>
> Yes, or at the very least a comment explaining how/why gop is bounded
> elsewhere.
Ok, I'll do that.

>
>>>
>>>> +		}
>>>> +
>>>> +	} while (dp != vif->dealloc_prod);
>>>> +
>>>> +	vif->dealloc_cons = dc;
>>>
>>> No barrier here?
>> dealloc_cons only used in the dealloc_thread. dealloc_prod is used by
>> the callback and the thread as well, that's why we need mb() in
>> previous. Btw. this function comes from classic's net_tx_action_dealloc
>
> Is this code close enough to that code architecturally that you can
> infer correctness due to that though?
Nope, I've just mentioned it because knowing that old code can help to 
understand this new, as their logic is very similar some places, like here.

> So long as you have considered the barrier semantics in the context of
> the current code and you think it is correct to not have one here then
> I'm ok. But if you have just assumed it is OK because some older code
> didn't have it then I'll have to ask you to consider it again...
Nope, as I mentioned above, dealloc_cons only accessed in that funcion, 
from the same thread. Dealloc_prod is written in the callback and read 
out here, that's why we need the barrier there.

>
>>>> +				netdev_err(vif->dev,
>>>> +					   " host_addr: %llx handle: %x status: %d\n",
>>>> +					   gop[i].host_addr,
>>>> +					   gop[i].handle,
>>>> +					   gop[i].status);
>>>> +			}
>>>> +			BUG();
>>>> +		}
>>>> +	}
>>>> +
>>>> +	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
>>>> +		xenvif_idx_release(vif, pending_idx_release[i],
>>>> +				   XEN_NETIF_RSP_OKAY);
>>>> +}
>>>> +
>>>> +
>>>>    /* Called after netfront has transmitted */
>>>>    int xenvif_tx_action(struct xenvif *vif, int budget)
>>>>    {
>>>> @@ -1678,6 +1793,25 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>>>>    	vif->mmap_pages[pending_idx] = NULL;
>>>>    }
>>>>
>>>> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
>>>
>>> This is a single shot version of the batched xenvif_tx_dealloc_action
>>> version? Why not just enqueue the idx to be unmapped later?
>> This is called only from the NAPI instance. Using the dealloc ring
>> require synchronization with the callback which can increase lock
>> contention. On the other hand, if the guest sends small packets
>> (<PAGE_SIZE), the TLB flushing can cause performance penalty.
>
> Right. When/How often is this called from the NAPI instance?
When grant mapping error detected in xenvif_tx_check_gop, and if a 
packet smaller than PKT_PROT_LEN is sent. The latter would be removed if 
we will grant copy such packets entirely.

> Is the locking contention from this case so severe that it out weighs
> the benefits of batching the unmaps? That would surprise me. After all
> the locking contention is there for the zerocopy_callback case too
>
>>   The above
>> mentioned upcoming patch which gntcopy the header can prevent that
>
> So this is only called when doing the pull-up to the linear area?
Yes, as mentioned above.

Zoli
