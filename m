From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Tue, 13 May 2014 21:18:04 +0100
Message-ID: <53727DFC.70107@citrix.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com> <1399996028.21867.34.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:49747 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbaEMUSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 16:18:09 -0400
In-Reply-To: <1399996028.21867.34.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/05/14 16:47, Ian Campbell wrote:
> On Tue, 2014-05-13 at 15:31 +0100, Zoltan Kiss wrote:
>> The original series for reintroducing grant mapping for netback had a patch [1]
>> to handle receiving of packets from an another VIF. Grant copy on the receiving
>> side needs the grant ref of the page to set up the op.
>> The original patch assumed (wrongly) that the frags array haven't changed. In
>> the case reported by Sander, the sending guest sent a packet where the linear
>> buffer and the first frag were under PKT_PROT_LEN (=128) bytes.
>> xenvif_tx_submit() then pulled up the linear area to 128 bytes, and ditched the
>> first frag. The receiving side had an off-by-one problem when gathered the grant
>> refs.
>
> The grant refs are gather here from the ubuf_info * link list stored in
> skb->destructor_arg, is that right?
Yes
>
> And the issue is that pulling up can consume a frag (e.g. and shift
> everything up) without adjusting that linked list?
Yes. Or any kind of change on the frags list (expect changing size and 
offset of an entry) breaks this part of the code at the moment.

>
> I think the commit message should make explicit reference to this linked
> list and where it lives and make the implications of doing a pull up on
> that list clear.
Ok, I'll add a reference to the description in common.h
>
> So the fix is when walking the list instead of assuming a 1:1
> relationship between frags and list elements you need to traverse the
> list looking for one which matches?
Yes.
>
> The ubuf's themselves are part of pending_tx_info -- is it the case that
> the pending entries are retained until the skb completes even when the
> corresponding frag is pulled up?
Yes. Pulling does remove the page from the frag list and put_page it, 
and when the callback called, it'll make sure it is given back to the 
sender.
>
> I suppose the network stack does pull ups itself -- so we can't fix this
> by just fixing up the ubuf list as we do the initial PKT_PROT_LEN pull
> up because there will be other pull ups which we don't control?
Yes. And I guess it's better to assume that other things can happen, 
e.g. see pskb_trim
>
>> This patch fixes that by checking whether the actual frag's page pointer is the
>> same as the page in the original frag list. It can handle any kind of changes on
>> the original frags array, like:
>> - removing granted frags from the beginning or the end
>> - adding local pages to the frags list
>> To keep it optimized to the most common cases, it doesn't handle when the order
>> of the original frags changed. That would require ubuf to be reseted to the
>> beginning of the chain (skb_shinfo(skb)->destructor_arg), and reiterating
>> through the list every time.
>
> Do we need to keep the ubuf list around after this operation or could it
> be destructive? I ask because by removing the entries from the list as
> they are consumed the optimal case will then always have the next frag
> in the head but it will handle reordering.
Yes, we need this chained list until the zerocopy callback walks through 
it and add the pending_idx's to the dealloc queue. I was tinkering with 
the idea of moving the not matching entries back to the head of the 
list, as the callback doesn't really care about the order, and I guess 
the guest neither. But that would look even scarier.
>
>> OPEN QUESTIONS:
>> - Is it a safe assumption that nothing changes the order of the original frags?
>>    Removing them from the array or injecting new pages anywhere is not a problem.
>> - I used UINT_MAX as a kind of INVALID_GRANT_REF, however there is no such thing
>>    in the grant mapping API. Should we codify this or is it better if we just
>>    find another way to distinguish whether a frag is local or not?
>
> I think UINT_MAX is probably OK, but can't you avoid this by doing the
> search in the existing loop over the frags which calls
> xenvif_gop_frag_copy? If you do that then you can pass foreign_vif as
> NULL in the cases where there is no ubuf entry.
Yes, that sounds better! That would make a lot of things easier.

I've reworked the patch to include frag reordering as well.

Zoli
