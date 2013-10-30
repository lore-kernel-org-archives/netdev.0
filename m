From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next RFC 2/5] xen-netback: Change TX path
 from grant copy to mapping
Date: Wed, 30 Oct 2013 21:10:51 +0000
Message-ID: <527175DB.8070400@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com> <1383094220-14775-3-git-send-email-zoltan.kiss@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD015717A@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jonathan Davies <Jonathan.Davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD015717A@AMSPEX01CL01.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/10/13 09:11, Paul Durrant wrote:
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
>> netback/interface.c
>> index f5c3c57..fb16ede 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -336,8 +336,20 @@ struct xenvif *xenvif_alloc(struct device *parent,
>> domid_t domid,
>>   	vif->pending_prod = MAX_PENDING_REQS;
>>   	for (i = 0; i < MAX_PENDING_REQS; i++)
>>   		vif->pending_ring[i] = i;
>> -	for (i = 0; i < MAX_PENDING_REQS; i++)
>> -		vif->mmap_pages[i] = NULL;
>> +	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
>> +		vif->mmap_pages,
>> +		false);
>
> Since this is a per-vif allocation, is this going to scale?
Good question, I'll look after this.

>> @@ -1620,14 +1562,25 @@ static int xenvif_tx_submit(struct xenvif *vif, int
>> budget)
>>   		memcpy(skb->data,
>>   		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
>>   		       data_len);
>> +		vif->pending_tx_info[pending_idx].callback_struct.ctx =
>> NULL;
>>   		if (data_len < txp->size) {
>>   			/* Append the packet payload as a fragment. */
>>   			txp->offset += data_len;
>>   			txp->size -= data_len;
>> -		} else {
>> +			skb_shinfo(skb)->destructor_arg =
>> +				&vif-
>>> pending_tx_info[pending_idx].callback_struct;
>> +		} else if (!skb_shinfo(skb)->nr_frags) {
>>   			/* Schedule a response immediately. */
>> +			skb_shinfo(skb)->destructor_arg = NULL;
>> +			xenvif_idx_unmap(vif, pending_idx);
>>   			xenvif_idx_release(vif, pending_idx,
>>   					   XEN_NETIF_RSP_OKAY);
>> +		} else {
>> +			/* FIXME: first request fits linear space, I don't know
>> +			 * if any guest would do that, but I think it's possible
>> +			 */
>
> The Windows frontend, because it has to parse the packet headers, will coalesce everything up to the payload in a single frag and it would be a good idea to copy this directly into the linear area.
I forgot to clarify this comment: the problem I wanted to handle here if 
the first request's size is PKT_PROT_LEN and there is more fragments. 
Then skb->len will be PKT_PROT_LEN as well, and the if statement falls 
through to the else branch. That might be problematic if we release the 
slot of the first request separately from the others. Or am I 
overlooking something? Does that matter to netfront anyway?
And this problem, if it's true, applies to the previous, grant copy 
method as well.
However, as I think, it might be better to change the condition to 
(data_len <= txp->size), rather than putting an if-else statement into 
the else branch.

>> @@ -1635,13 +1588,19 @@ static int xenvif_tx_submit(struct xenvif *vif, int
>> budget)
>>   		else if (txp->flags & XEN_NETTXF_data_validated)
>>   			skb->ip_summed = CHECKSUM_UNNECESSARY;
>>
>> -		xenvif_fill_frags(vif, skb);
>> +		xenvif_fill_frags(vif, skb, pending_idx);
>>
>>   		if (skb_is_nonlinear(skb) && skb_headlen(skb) <
>> PKT_PROT_LEN) {
>>   			int target = min_t(int, skb->len, PKT_PROT_LEN);
>>   			__pskb_pull_tail(skb, target - skb_headlen(skb));
>>   		}
>>
>> +		/* Set this flag after __pskb_pull_tail, as it can trigger
>> +		 * skb_copy_ubufs, while we are still in control of the skb
>> +		 */
>
> You can't be sure that there will be no subsequent pullups. The v6 parsing code I added may need to do that on a (hopefully) rare occasion.
The only thing matters that it shouldn't happen between this and before 
calling netif_receive_skb. I think I will move this right before it, and 
expand the comment.

Zoli
