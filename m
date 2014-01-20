From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v4 6/9] xen-netback: Handle guests with too many
 frags
Date: Mon, 20 Jan 2014 17:26:40 +0000
Message-ID: <52DD5C50.7010101@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com> <1389731995-9887-7-git-send-email-zoltan.kiss@citrix.com> <20140116000314.GD5331@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140116000314.GD5331@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/01/14 00:03, Wei Liu wrote:
> On Tue, Jan 14, 2014 at 08:39:52PM +0000, Zoltan Kiss wrote:
> [...]
>>   	/* Skip first skb fragment if it is on same page as header fragment. */
>> @@ -832,6 +851,29 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>>
>>   	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
>>
>> +	if (frag_overflow) {
>> +		struct sk_buff *nskb = xenvif_alloc_skb(0);
>> +		if (unlikely(nskb == NULL)) {
>> +			netdev_err(vif->dev,
>> +				   "Can't allocate the frag_list skb.\n");
>
> This, and other occurences of netdev_* logs need to be rate limit.
> Otherwise you risk flooding kernel log when system is under memory
> pressure.
Done.

>> @@ -1537,6 +1613,32 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   				  pending_idx :
>>   				  INVALID_PENDING_IDX);
>>
>> +		if (skb_shinfo(skb)->frag_list) {
>> +			nskb = skb_shinfo(skb)->frag_list;
>> +			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
>> +			skb->len += nskb->len;
>> +			skb->data_len += nskb->len;
>> +			skb->truesize += nskb->truesize;
>> +			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> +			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> +			vif->tx_zerocopy_sent += 2;
>> +			nskb = skb;
>> +
>> +			skb = skb_copy_expand(skb,
>> +					      0,
>> +					      0,
>> +					      GFP_ATOMIC | __GFP_NOWARN);
>> +			if (!skb) {
>> +				netdev_dbg(vif->dev,
>> +					   "Can't consolidate skb with too many fragments\n");
>
> Rate limit.
>
>> +				if (skb_shinfo(nskb)->destructor_arg)
>> +					skb_shinfo(nskb)->tx_flags |=
>> +						SKBTX_DEV_ZEROCOPY;
>
> Why is this needed? nskb is the saved pointer to original skb, which has
> already had SKBTX_DEV_ZEROCOPY in tx_flags. Did I miss something?
Indeed. This actually belongs to the header grant copy patches I've sent 
in as well. I move it there.
