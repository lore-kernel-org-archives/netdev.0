From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v6 7/10] xen-netback: Handle guests with too
 many frags
Date: Wed, 5 Mar 2014 22:56:53 +0000
Message-ID: <5317ABB5.8010005@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com> <1393972341-21135-8-git-send-email-zoltan.kiss@citrix.com> <20140305123514.GH19620@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140305123514.GH19620@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/14 12:35, Wei Liu wrote:
> On Tue, Mar 04, 2014 at 10:32:18PM +0000, Zoltan Kiss wrote:
>> Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
>> handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
>> - create a new skb
>> - map the leftover slots to its frags (no linear buffer here!)
>> - chain it to the previous through skb_shinfo(skb)->frag_list
>> - map them
>> - copy and coalesce the frags into a brand new one and send it to the stack
>> - unmap the 2 old skb's pages
>>
>
> IIRC you once said there's problem with some NICs sending out SKBs with
> large linear area. Is that solved?
That was a red herring, the problem was around NAPI scheduling, and it 
is solved.

> [...]
>> v6:
>> - move out handling from tx_submit into a new funciont, as it became quite long
>> - skb_copy[_expand] allocate a new skb with a huge linear buffer, which is bad
>>    in times of memory pressure. Just make a new frags array and do the copy and
>>    coalesce with skb_copy_bits
>>
>
> And with this change, the above issue is solved?
Yes.

>> +static inline struct sk_buff *xenvif_alloc_skb(unsigned int size)
>> +{
>> +	struct sk_buff *skb =
>> +		alloc_skb(size + NET_SKB_PAD + NET_IP_ALIGN,
>> +			  GFP_ATOMIC | __GFP_NOWARN);
>> +	if (unlikely(skb == NULL))
>> +		return NULL;
>> +
>> +	/* Packets passed to netif_rx() must have some headroom. */
>> +	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
>> +
>> +	/* Initialize it here to avoid later surprises */
>> +	skb_shinfo(skb)->destructor_arg = NULL;
>> +
>> +	return skb;
>> +}
>
> This hunk can probably be moved to previous where you introduce mapping
> mechanism.
In that patch we would use it only once. This patch is the one where we 
allocate skb's twice. Plus, that prev patch is already big enough.

>
>> +
>>   static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>>   							struct sk_buff *skb,
>>   							struct xen_netif_tx_request *txp,
>> @@ -802,11 +820,16 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>>   	u16 pending_idx = *((u16 *)skb->cb);
>>   	int start;
>>   	pending_ring_idx_t index;
>> -	unsigned int nr_slots;
>> +	unsigned int nr_slots, frag_overflow = 0;
>>
>>   	/* At this point shinfo->nr_frags is in fact the number of
>>   	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
>>   	 */
>> +	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
>> +		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
>> +		BUG_ON(frag_overflow > MAX_SKB_FRAGS);
>> +		shinfo->nr_frags = MAX_SKB_FRAGS;
>> +	}
>>   	nr_slots = shinfo->nr_frags;
>>
>>   	/* Skip first skb fragment if it is on same page as header fragment. */
>> @@ -822,6 +845,30 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>>
>>   	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
>>
>
> This BUG_ON is pointless as shinfo->nr_frags is guaranteed to be not
> larger than MAX_SKB_FRAGS a few lines above.
Ok

>> +	if (skb_has_frag_list(skb)) {
>> +		first_skb = skb;
>> +		skb = shinfo->frag_list;
>> +		shinfo = skb_shinfo(skb);
>> +		nr_frags = shinfo->nr_frags;
>> +		start = 0;
>> +
>> +		goto check_frags;
>> +	}
>> +
>> +	/* There was a mapping error in the frag_list skb. We have to unmap
>> +	 * the first skb's frags
>> +	 */
>> +	if (first_skb && err) {
>> +		int j;
>> +		shinfo = skb_shinfo(first_skb);
>> +		pending_idx = *((u16 *)first_skb->cb);
>> +		start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
>> +		for (j = start; j < shinfo->nr_frags; j++) {
>> +			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
>> +			xenvif_idx_unmap(vif, pending_idx);
>> +			xenvif_idx_release(vif, pending_idx,
>> +					   XEN_NETIF_RSP_OKAY);
>
> _unmap and _release at the same time? IIRC _unmap calls _release.
Yes, that remained here from old times, thanks for pointing it out.

>> +static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
>> +{
>> +	unsigned int offset = skb_headlen(skb);
>> +	skb_frag_t frags[MAX_SKB_FRAGS];
>> +	int i;
>> +	struct ubuf_info *uarg;
>> +	struct sk_buff *nskb = skb_shinfo(skb)->frag_list;
>> +
>> +	vif->tx_zerocopy_sent += 2;
>> +	vif->tx_frag_overflow++;
>> +
>> +	xenvif_fill_frags(vif, nskb);
>> +	/* Subtract frags size, we will correct it later */
>> +	skb->truesize -= skb->data_len;
>> +	skb->len += nskb->len;
>> +	skb->data_len += nskb->len;
>> +
>> +	/* create a brand new frags array and coalesce there */
>> +	for (i = 0; offset < skb->len; i++) {
>> +		struct page *page;
>> +		void *vaddr;
>> +		unsigned int len;
>> +
>> +		BUG_ON(i >= MAX_SKB_FRAGS);
>> +		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
>> +		if (!page) {
>> +			int j;
>> +			skb->truesize += skb->data_len;
>> +			for (j = 0; j < i; j++)
>> +				put_page(frags[j].page.p);
>> +			return -ENOMEM;
>> +		}
>> +
>> +		vaddr = kmap_atomic(page);
>
> Why do you need this? The page is not allocated with __GFP_HIGHMEM.
Indeed. I took core networking code as example, but the the gfp comes as 
a parameter.

>
>> +	}
>> +	/* swap out with old one */
>> +	memcpy(skb_shinfo(skb)->frags,
>> +	       frags,
>> +	       i * sizeof(skb_frag_t));
>
> The old frags array is over-written, when do you pages in old frags
> array?
You mean release? uarg->callback does that, we don't need the original 
frags array to do that.

>
>> +	skb_shinfo(skb)->nr_frags = i;
>> +	skb->truesize += i * PAGE_SIZE;
>> +
>> +	/* remove traces of mapped pages and frag_list */
>> +	skb_frag_list_init(skb);
>> +	uarg = skb_shinfo(skb)->destructor_arg;
>> +	uarg->callback(uarg, true);
>> +	skb_shinfo(skb)->destructor_arg = NULL;
>> +
>> +	skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> +	kfree_skb(nskb);
>> +
>> +	return 0;
>> +}
>>
>>   static int xenvif_tx_submit(struct xenvif *vif)
>>   {
>> @@ -1258,7 +1400,6 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   				&vif->pending_tx_info[pending_idx].callback_struct;
>>   		} else {
>>   			/* Schedule a response immediately. */
>> -			skb_shinfo(skb)->destructor_arg = NULL;
>
> Why? You added this in previous patch but remove it here.
xenvif_alloc_skb does this now.
