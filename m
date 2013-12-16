From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Mon, 16 Dec 2013 15:38:05 +0000
Message-ID: <52AF1E5D.20801@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com> <20131213153612.GM21900@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131213153612.GM21900@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/12/13 15:36, Wei Liu wrote:
> On Thu, Dec 12, 2013 at 11:48:10PM +0000, Zoltan Kiss wrote:
>> This patch changes the grant copy on the TX patch to grant mapping
>>
>> v2:
>> - delete branch for handling fragmented packets fit PKT_PROT_LINE sized first
>                                                        ^ PKT_PROT_LEN
>>    request
>> - mark the effect of using ballooned pages in a comment
>> - place setting of skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY right
>>    before netif_receive_skb, and mark the importance of it
>> - grab dealloc_lock before __napi_complete to avoid contention with the
>>    callback's napi_schedule
>> - handle fragmented packets where first request < PKT_PROT_LINE
>                                                      ^ PKT_PROT_LEN
Oh, some dyskleksia of mine, I will fix that :)

>> - fix up error path when checksum_setup failed
>> - check before teardown for pending grants, and start complain if they are
>>    there after 10 second
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
> [...]
>>   void xenvif_free(struct xenvif *vif)
>>   {
>> +	int i, unmap_timeout = 0;
>> +
>> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
>> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>> +			i = 0;
>> +			unmap_timeout++;
>> +			msleep(1000);
>> +			if (unmap_timeout > 9 &&
>> +				net_ratelimit())
>> +				netdev_err(vif->dev,
>> +					"Page still granted! Index: %x\n", i);
>> +		}
>> +	}
>> +
>> +	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
>> +
>
> If some pages are stuck and you just free them will it cause Dom0 to
> crash? I mean, if those pages are recycled by other balloon page users.
>
> Even if it will not cause Dom0 to crash, will it leak any resource in
> Dom0? At plain sight it looks like at least grant table entry is leaked,
> isn't it? We need to be careful about this because a malicious might be
> able to DoS Dom0 with resource leakage.
Yes, if we call free_xenballooned_pages while something is still mapped, 
Xen kills Dom0 because balloon driver tries to touch the PTE of a grant 
mapped page. That's why we make sure before that everything is unmapped, 
and repeat an error message if it's not. I'm afraid we can't do anything 
better here, that means a serious netback bug.
But a malicious guest cannot take advantage of this unless it's find a 
way to screw up netback's internal bookkeeping. Then it can block here 
indefinitely the teardown of the VIF, and it's associated resources.

>
>>   	netif_napi_del(&vif->napi);
>>
>>   	unregister_netdev(vif->dev);
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 3ddc474..20352be 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -645,9 +645,12 @@ static void xenvif_tx_err(struct xenvif *vif,
>>   			  struct xen_netif_tx_request *txp, RING_IDX end)
>>   {
>>   	RING_IDX cons = vif->tx.req_cons;
>> +	unsigned long flags;
>>
>>   	do {
>> +		spin_lock_irqsave(&vif->response_lock, flags);
>>   		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
>> +		spin_unlock_irqrestore(&vif->response_lock, flags);
>
> You only hold the lock for one function call is this intentional?
Yes, make_tx_response can be called from xenvif_tx_err or 
xenvif_idx_release, and they can be called from the NAPI instance and 
the dealloc thread. (xenvif_tx_err only from NAPI)

>
>>   		netif_receive_skb(skb);
>>   	}
>>
>> @@ -1711,7 +1677,7 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>>   int xenvif_tx_action(struct xenvif *vif, int budget)
>>   {
>>   	unsigned nr_gops;
>> -	int work_done;
>> +	int work_done, ret;
>>
>>   	if (unlikely(!tx_work_todo(vif)))
>>   		return 0;
>> @@ -1721,7 +1687,13 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>>   	if (nr_gops == 0)
>>   		return 0;
>>
>> -	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
>> +	if (nr_gops) {
>
> Surely you can remove this "if". At this point nr_gops cannot be zero --
> see two lines above.

>>   void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
>>   {
>>   	int ret;
>> +	struct gnttab_unmap_grant_ref tx_unmap_op;
>> +
>>   	if (vif->grant_tx_handle[pending_idx] == NETBACK_INVALID_HANDLE) {
>>   		netdev_err(vif->dev,
>>   				"Trying to unmap invalid handle! pending_idx: %x\n",
>>   				pending_idx);
>>   		return;
>>   	}
>> -	gnttab_set_unmap_op(&vif->tx_unmap_ops[0],
>> +	gnttab_set_unmap_op(&tx_unmap_op,
>>   			idx_to_kaddr(vif, pending_idx),
>>   			GNTMAP_host_map,
>>   			vif->grant_tx_handle[pending_idx]);
>> -	ret = gnttab_unmap_refs(vif->tx_unmap_ops,
>> +	ret = gnttab_unmap_refs(&tx_unmap_op,
>>   			NULL,
>>   			&vif->mmap_pages[pending_idx],
>>   			1);
>
> This change should be squashed to patch 1. Or as I suggested the changes
> in patch 1 should be moved here.
>
>> @@ -1845,7 +1793,6 @@ static inline int rx_work_todo(struct xenvif *vif)
>>
>>   static inline int tx_work_todo(struct xenvif *vif)
>>   {
>> -
>
> Stray blank line change.
Agreed on previous 3 comments, I will apply them.

Zoli
