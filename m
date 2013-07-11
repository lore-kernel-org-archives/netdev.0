From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH v2 1/1] xen/netback: correctly calculate required slots
 of skb.
Date: Thu, 11 Jul 2013 16:34:05 +0800
Message-ID: <51DE6DFD.9080007@oracle.com>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com> <1373530274.5453.148.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	wei.liu2@citrix.com, konrad.wilk@oracle.com, msw@amazon.com
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30572 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867Ab3GKId7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:33:59 -0400
In-Reply-To: <1373530274.5453.148.camel@hastur.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-7-11 16:11, Ian Campbell wrote:
> On Wed, 2013-07-10 at 17:15 +0800, Annie Li wrote:
>> +static int netbk_count_slots(struct xenvif *vif, struct sk_buff *skb,
>> +			    int *copy_off, unsigned long size,
>> +			    unsigned long offset, int *head)
>>   {
>> -	unsigned int count;
>> -	int i, copy_off;
>> +	unsigned long bytes;
>> +	int count = 0;
>>   
>> -	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>> +	offset &= ~PAGE_MASK;
>>   
>> -	copy_off = skb_headlen(skb) % PAGE_SIZE;
>> +	while (size > 0) {
>> +		BUG_ON(offset >= PAGE_SIZE);
>> +		BUG_ON(*copy_off > MAX_BUFFER_OFFSET);
>>   
>> -	if (skb_shinfo(skb)->gso_size)
>> -		count++;
>> +		bytes = PAGE_SIZE - offset;
>>   
>> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>> -		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
>> -		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
>> -		unsigned long bytes;
>> +		if (bytes > size)
>> +			bytes = size;
>>   
>> -		offset &= ~PAGE_MASK;
>> +		if (start_new_rx_buffer(*copy_off, bytes, *head)) {
>> +			count++;
>> +			*copy_off = 0;
>> +		}
>>   
>> -		while (size > 0) {
>> -			BUG_ON(offset >= PAGE_SIZE);
>> -			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>> +		if (*copy_off + bytes > MAX_BUFFER_OFFSET)
>> +			bytes = MAX_BUFFER_OFFSET - *copy_off;
>>   
>> -			bytes = PAGE_SIZE - offset;
>> +		*copy_off += bytes;
>>   
>> -			if (bytes > size)
>> -				bytes = size;
>> +		offset += bytes;
>> +		size -= bytes;
>>   
>> -			if (start_new_rx_buffer(copy_off, bytes, 0)) {
>> -				count++;
>> -				copy_off = 0;
>> -			}
>> +		/* Next frame */
>> +		if (offset == PAGE_SIZE && size)
>> +			offset = 0;
>> +
>> +		if (*head)
>> +			count++;
> This little bit corresponds to the "/* Leave a gap for the GSO
> descriptor. */" in gop_frag_copy?

No, it does not correspond to this in gop_frag_copy. The code here only 
increase count for the first time. I thought to initialize the count in 
xen_netbk_count_skb_slots with 1 to avoid this. But thinking of the 
extreme case when the header size is zero(not sure whether this case 
could be true), I increase the count here to keep safe in case header 
size is zero.

There is code correspond to that in gop_frag_copy in 
xen_netbk_count_skb_slots, see following,

+	if (skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+		count++;
(The original code does not have gso_prefix, I added it in this patch too based on Wei's suggestion)


>
> If so then it would be useful to duplicate the comment, but more
> importantly the condition on gop_frag_copy is:
>          (head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> why the difference?

Actually it is similar with that in xen_netbk_count_skb_slots, see above 
comments.

Thanks
Annie
