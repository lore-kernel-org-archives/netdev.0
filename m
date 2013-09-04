From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Wed, 04 Sep 2013 10:25:59 +0800
Message-ID: <52269A37.7030600@oracle.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com> <20130903215328.GA13465@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	msw@amazon.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43237 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab3IDC0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:26:17 -0400
In-Reply-To: <20130903215328.GA13465@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-9-4 5:53, Wei Liu wrote:
> On Tue, Sep 03, 2013 at 06:29:50PM +0100, David Vrabel wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>>
>> When a VM is providing an iSCSI target and the LUN is used by the
>> backend domain, the generated skbs for direct I/O writes to the disk
>> have large, multi-page skb->data but no frags.
>>
>> With some lengths and starting offsets, xen_netbk_count_skb_slots()
>> would be one short because the simple calculation of
>> DIV_ROUND_UP(skb_headlen(), PAGE_SIZE) was not accounting for the
>> decisions made by start_new_rx_buffer() which does not guarantee
>> responses are fully packed.
>>
>> For example, a skb with length < 2 pages but which spans 3 pages would
>> be counted as requiring 2 slots but would actually use 3 slots.
>>
>> skb->data:
>>
>>      |        1111|222222222222|3333        |
>>
>> Fully packed, this would need 2 slots:
>>
>>      |111122222222|22223333    |
>>
>> But because the 2nd page wholy fits into a slot it is not split across
>> slots and goes into a slot of its own:
>>
>>      |1111        |222222222222|3333        |
>>
>> Miscounting the number of slots means netback may push more responses
>> than the number of available requests.  This will cause the frontend
>> to get very confused and report "Too many frags/slots".  The frontend
>> never recovers and will eventually BUG.
>>
>> Fix this by counting the number of required slots more carefully.  In
>> xen_netbk_count_skb_slots(), more closely follow the algorithm used by
>> xen_netbk_gop_skb() by introducing xen_netbk_count_frag_slots() which
>> is the dry-run equivalent of netbk_gop_frag_copy().
>>
> Phew! So this is backend miscounting bug. I thought it was a frontend
> bug so it didn't ring a bell when we had our face-to-face discussion,
> sorry. :-(
>
> This bug was discussed back in July among Annie, Matt, Ian and I. We
> finally agreed to take Matt's solution. Matt agreed to post final
> version within a week but obviously he's too busy to do so. I was away
> so I didn't follow closely. Eventually it fell through the crack. :-(

The fixes can be implemented in two ways, one is fix in 
xen_netbk_count_skb_slots to return correct slot count, my 
patch(http://lists.xen.org/archives/html/xen-devel/2013-07/msg00785.html) and 
David's fall in this way. The other way is fixed in netbk_gop_frag_copy 
which is 
Matt's(http://lists.xen.org/archives/html/xen-devel/2013-07/msg00760.html).

> Matt, do you fancy sending the final version? IIRC the commit message
> needs to be re-written. I personally still prefer Matt's solution as
> it a) make efficient use of the ring, b) uses ring pointers to
> calculate slots which is most accurate, c) removes the dependence on
> MAX_SKB_FRAGS in guest RX path.
>
> Anyway, we should get this fixed ASAP.

Totally agree. This issue is easy to be reproduced with large MTU. It is 
better to upstream the fix soon in case others hit it and waste time to 
fix it.

Thanks
Annie
>
> Thanks
> Wei.
>
> REF:
> <1373409659-22383-1-git-send-email-msw@amazon.com>
> <1373350520-19985-1-git-send-email-annie.li@oracle.com>
>
>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> ---
>> [Resend to actually Cc netdev, sorry.]
>> ---
>>   drivers/net/xen-netback/netback.c |   94 +++++++++++++++++++++++++------------
>>   1 files changed, 64 insertions(+), 30 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 64828de..f149ce5 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -361,6 +361,49 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>>   	return false;
>>   }
>>   
>> +struct xen_netbk_count_slot_state {
>> +	unsigned long copy_off;
>> +	bool head;
>> +};
>> +
>> +unsigned int xen_netbk_count_frag_slots(struct xenvif *vif,
>> +					unsigned long offset, unsigned long size,
>> +					struct xen_netbk_count_slot_state *state)
>> +{
>> +	unsigned count = 0;
>> +
>> +	offset &= ~PAGE_MASK;
>> +
>> +	while (size > 0) {
>> +		unsigned long bytes;
>> +
>> +		bytes = PAGE_SIZE - offset;
>> +
>> +		if (bytes > size)
>> +			bytes = size;
>> +
>> +		if (start_new_rx_buffer(state->copy_off, bytes, state->head)) {
>> +			count++;
>> +			state->copy_off = 0;
>> +		}
>> +
>> +		if (state->copy_off + bytes > MAX_BUFFER_OFFSET)
>> +			bytes = MAX_BUFFER_OFFSET - state->copy_off;
>> +
>> +		state->copy_off += bytes;
>> +
>> +		offset += bytes;
>> +		size -= bytes;
>> +
>> +		if (offset == PAGE_SIZE)
>> +			offset = 0;
>> +
>> +		state->head = false;
>> +	}
>> +
>> +	return count;
>> +}
>> +
>>   /*
>>    * Figure out how many ring slots we're going to need to send @skb to
>>    * the guest. This function is essentially a dry run of
>> @@ -368,48 +411,39 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>>    */
>>   unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>>   {
>> +	struct xen_netbk_count_slot_state state;
>>   	unsigned int count;
>> -	int i, copy_off;
>> +	unsigned char *data;
>> +	unsigned i;
>>   
>> -	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>> +	state.head = true;
>> +	state.copy_off = 0;
>>   
>> -	copy_off = skb_headlen(skb) % PAGE_SIZE;
>> +	/* Slot for the first (partial) page of data. */
>> +	count = 1;
>>   
>> +	/* Need a slot for the GSO prefix for GSO extra data? */
>>   	if (skb_shinfo(skb)->gso_size)
>>   		count++;
>>   
>> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>> -		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
>> -		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
>> -		unsigned long bytes;
>> -
>> -		offset &= ~PAGE_MASK;
>> -
>> -		while (size > 0) {
>> -			BUG_ON(offset >= PAGE_SIZE);
>> -			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>> -
>> -			bytes = PAGE_SIZE - offset;
>> -
>> -			if (bytes > size)
>> -				bytes = size;
>> +	data = skb->data;
>> +	while (data < skb_tail_pointer(skb)) {
>> +		unsigned long offset = offset_in_page(data);
>> +		unsigned long size = PAGE_SIZE - offset;
>>   
>> -			if (start_new_rx_buffer(copy_off, bytes, 0)) {
>> -				count++;
>> -				copy_off = 0;
>> -			}
>> +		if (data + size > skb_tail_pointer(skb))
>> +			size = skb_tail_pointer(skb) - data;
>>   
>> -			if (copy_off + bytes > MAX_BUFFER_OFFSET)
>> -				bytes = MAX_BUFFER_OFFSET - copy_off;
>> +		count += xen_netbk_count_frag_slots(vif, offset, size, &state);
>>   
>> -			copy_off += bytes;
>> +		data += size;
>> +	}
>>   
>> -			offset += bytes;
>> -			size -= bytes;
>> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>> +		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
>> +		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
>>   
>> -			if (offset == PAGE_SIZE)
>> -				offset = 0;
>> -		}
>> +		count += xen_netbk_count_frag_slots(vif, offset, size, &state);
>>   	}
>>   	return count;
>>   }
>> -- 
>> 1.7.2.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
