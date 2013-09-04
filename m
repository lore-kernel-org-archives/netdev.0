From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Wed, 4 Sep 2013 15:02:01 +0100
Message-ID: <52273D59.2020205@citrix.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com> <20130903215328.GA13465@zion.uk.xensource.com> <52271DFF.3070008@citrix.com> <20130904131459.GO14104@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15366 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755216Ab3IDOCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 10:02:05 -0400
In-Reply-To: <20130904131459.GO14104@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/13 14:14, Wei Liu wrote:
> On Wed, Sep 04, 2013 at 12:48:15PM +0100, David Vrabel wrote:
>> On 03/09/13 22:53, Wei Liu wrote:
>>> On Tue, Sep 03, 2013 at 06:29:50PM +0100, David Vrabel wrote:
>>>> From: David Vrabel <david.vrabel@citrix.com>
>>>>
>>>> When a VM is providing an iSCSI target and the LUN is used by the
>>>> backend domain, the generated skbs for direct I/O writes to the disk
>>>> have large, multi-page skb->data but no frags.
>>>>
>>>> With some lengths and starting offsets, xen_netbk_count_skb_slots()
>>>> would be one short because the simple calculation of
>>>> DIV_ROUND_UP(skb_headlen(), PAGE_SIZE) was not accounting for the
>>>> decisions made by start_new_rx_buffer() which does not guarantee
>>>> responses are fully packed.
>>>>
>>>> For example, a skb with length < 2 pages but which spans 3 pages would
>>>> be counted as requiring 2 slots but would actually use 3 slots.
>>>>
>>>> skb->data:
>>>>
>>>>     |        1111|222222222222|3333        |
>>>>
>>>> Fully packed, this would need 2 slots:
>>>>
>>>>     |111122222222|22223333    |
>>>>
>>>> But because the 2nd page wholy fits into a slot it is not split across
>>>> slots and goes into a slot of its own:
>>>>
>>>>     |1111        |222222222222|3333        |
>>>>
>>>> Miscounting the number of slots means netback may push more responses
>>>> than the number of available requests.  This will cause the frontend
>>>> to get very confused and report "Too many frags/slots".  The frontend
>>>> never recovers and will eventually BUG.
>>>>
>>>> Fix this by counting the number of required slots more carefully.  In
>>>> xen_netbk_count_skb_slots(), more closely follow the algorithm used by
>>>> xen_netbk_gop_skb() by introducing xen_netbk_count_frag_slots() which
>>>> is the dry-run equivalent of netbk_gop_frag_copy().
>>>>
>>>
>>> Phew! So this is backend miscounting bug. I thought it was a frontend
>>> bug so it didn't ring a bell when we had our face-to-face discussion,
>>> sorry. :-(
>>>
>>> This bug was discussed back in July among Annie, Matt, Ian and I. We
>>> finally agreed to take Matt's solution. Matt agreed to post final
>>> version within a week but obviously he's too busy to do so. I was away
>>> so I didn't follow closely. Eventually it fell through the crack. :-(
>>
>> I think I prefer fixing the counting for backporting to stable kernels.
> 
> The original patch has coding style change. Sans that contextual change
> it's not a very long patch.

The size of the patch isn't the main concern for backport-ability.  It's
the frontend visible changes and thus any (unexpected) impacts on
frontends -- this is especially important as only a small fraction of
frontends in use will be tested with these changes.

>>  Xi's approach of packing the ring differently is a change in frontend
>> visible behaviour and seems more risky. e.g., possible performance
>> impact so I would like to see some performance analysis of that approach.
>>
> 
> With Xi's approach it is more efficient for backend to process. As we
> now use one less grant copy operation which means we copy the same
> amount of data with less grant ops.

It think it uses more grant ops because the copies of the linear
portion are in chunks that do not cross source page boundaries.

i.e., in netbk_gop_skb():

	data = skb->data;
	while (data < skb_tail_pointer(skb)) {
		unsigned int offset = offset_in_page(data);
		unsigned int len = PAGE_SIZE - offset;
                [...]

It wasn't clear from the patch that this had been considered and that
any extra space needed in the grant op array was made available.

> From frontend's PoV I think the impact is minimal. Frontend is involved
> in assembling the packets. It only takes what's in the ring and chain
> them together. The operation involves copying so far is the
> __pskb_pull_tail which happens a) in rare case when there's more frags
> than frontend's MAX_SKB_FRAGS, b) when pull_to > skb_headlen which
> happens. With Xi's change the rare case a) will even be rarer than
> before as we use less slots. b) happens the same as it happens before
> Xi's change, because the pull is guarded by "if (pull_to >
> skb_headlen(skb))" and Xi's change doesn't affect skb_headlen.
> 
> So overall I don't see obvious downside.

The obvious downside is it doesn't exist (in a form that can be applied
now), it hasn't been tested and I think there may well be a subtle bug
that would need a careful review or testing to confirm/deny.

You are free to work on this as a future improvements but I really don't
see why this critical bug fix needs to be delayed any further.

David
