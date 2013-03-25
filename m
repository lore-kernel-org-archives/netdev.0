From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 16:34:35 +0000
Message-ID: <51507C9B.3080109@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-6-git-send-email-wei.liu2@citrix.com> <5150699C.6080209@citrix.com>  <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39282 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758576Ab3CYQei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:34:38 -0400
In-Reply-To: <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 15:47, Wei Liu wrote:
> On Mon, Mar 25, 2013 at 3:13 PM, David Vrabel <david.vrabel@citrix.com> wrote:
>> On 25/03/13 11:08, Wei Liu wrote:
>>> This patch tries to coalesce tx requests when constructing grant copy
>>> structures. It enables netback to deal with situation when frontend's
>>> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
>>>
>>> It defines max_skb_slots, which is a estimation of the maximum number of slots
>>> a guest can send, anything bigger than that is considered malicious. Now it is
>>> set to 20, which should be enough to accommodate Linux (16 to 19).
>>
>> This maximum needs to be defined as part of the protocol and added to
>> the interface header.
>>
> 
> No, this is not part of the protocol and not a hard limit. It is
> configurable by system administrator.

There is no mechanism by which the front and back ends can negotiate
this value, so it does need to be a fixed value that is equal or greater
than the max from any front or back end that has ever existed.

The reason for this patch is that this wasn't properly specified and
changes outside of netback broke the protocol.

>>> +
>>> +                             if (unlikely(!first)) {
>>
>> This isn't unlikely is it?
>>
> 
> For big packet the chance is 1 in max_skb_slots, so 5% (1/20) in default case.

I don't understand your reasoning here.  The "if (!first)" branch is
taken once per page.  It will be 100% if each slot goes into its own
page and only 5% if the packet is less than PAGE_SIZE in length but
split into 20 slots.

>>> +                                     first = &pending_tx_info[pending_idx];
>>> +                                     start_idx = index;
>>> +                                     head_idx = pending_idx;
>>> +                             }
>>
>> Instead of setting first here why not move the code below here?
>>
> 
> Because first->req.size needs to be set to dst_offset, it has to be
> here anyway. So I put other fields here as well.

Hmmm, I'd probably accumulate first->req.size but ok. It was a minor
point anyway.

>>> +             first->req.offset = 0;
>>> +             first->req.size = dst_offset;
>>> +             first->head = start_idx;
>>> +             set_page_ext(page, netbk, head_idx);
>>> +             netbk->mmap_pages[head_idx] = page;
>>> +             frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
>>
>>> @@ -1548,13 +1649,34 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
>> [...]
>>> +             /* Setting any number other than
>>> +              * INVALID_PENDING_RING_IDX indicates this slot is
>>> +              * starting a new packet / ending a previous packet.
>>> +              */
>>> +             pending_tx_info->head = 0;
>>
>> This doesn't look needed.  It will be initialized again when reusing t
>> his pending_tx_info again, right?
>>
> 
> Yes, it is needed. Otherwise netback responses to invalid tx_info and
> cause netfront to crash before coming into the re-initialization path.

Maybe I'm missing something but this is after the make_tx_reponse()
call, and immediately after this pending_tx_info is returned to the
pending ring as free.

David
