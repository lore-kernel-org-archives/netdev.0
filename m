From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before	copying
Date: Mon, 25 Mar 2013 18:29:29 +0000
Message-ID: <51509789.8090608@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>	<5150699C.6080209@citrix.com>	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>	<51507C9B.3080109@citrix.com> <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:28434 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932767Ab3CYS3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 14:29:32 -0400
In-Reply-To: <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 16:58, Wei Liu wrote:
> On Mon, Mar 25, 2013 at 4:34 PM, David Vrabel <david.vrabel@citrix.com> wrote:
>> On 25/03/13 15:47, Wei Liu wrote:
>>> On Mon, Mar 25, 2013 at 3:13 PM, David Vrabel <david.vrabel@citrix.com> wrote:
>>>> On 25/03/13 11:08, Wei Liu wrote:
>>>>> This patch tries to coalesce tx requests when constructing grant copy
>>>>> structures. It enables netback to deal with situation when frontend's
>>>>> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
>>>>>
>>>>> It defines max_skb_slots, which is a estimation of the maximum number of slots
>>>>> a guest can send, anything bigger than that is considered malicious. Now it is
>>>>> set to 20, which should be enough to accommodate Linux (16 to 19).
>>>>
>>>> This maximum needs to be defined as part of the protocol and added to
>>>> the interface header.
>>>>
>>>
>>> No, this is not part of the protocol and not a hard limit. It is
>>> configurable by system administrator.
>>
>> There is no mechanism by which the front and back ends can negotiate
>> this value, so it does need to be a fixed value that is equal or greater
>> than the max from any front or back end that has ever existed.
>>
> 
> Are you suggesting move the default macro value to header file? It is
> just an estimation, I have no knowledge of the accurate maximum value,
> so I think make it part of the protocol a bad idea.

How is the author of a new frontend supposed to know how many slots they
can use per packet if it is not precisely defined?

> Do you have a handle on the maximum value?

Backends should provide the value to the frontend via a xenstore key
(e.g., max-slots-per-frame).  This value should be at least 18 (the
historical value of MAX_SKB_FRAGS).

The frontend may use up to this specified value or 17 if the
max-slots-per-frame key is missing.

Supporting at least 18 in the backend is required for existing
frontends.  Limiting frontends to 17 allows them to work with all
backends (including recent Linux version that only supported 17).

It's not clear why 19 or 20 were suggested as possible values.  I
checked back to 2.6.18 and MAX_SKB_FRAGS there is (65536/PAGE_SIZE + 2)
== 18.

Separately, it may be sensible for the backend to drop packets with more
frags than max-slots-per-frame up to some threshold where anything more
is considered malicious (i.e., 1 - 18 slots is a valid packet, 19-20 are
dropped and 21 or more is a fatal error).

>> The reason for this patch is that this wasn't properly specified and
>> changes outside of netback broke the protocol.
>>
>>>> [...]
>>>>> +             /* Setting any number other than
>>>>> +              * INVALID_PENDING_RING_IDX indicates this slot is
>>>>> +              * starting a new packet / ending a previous packet.
>>>>> +              */
>>>>> +             pending_tx_info->head = 0;
>>>>
>>>> This doesn't look needed.  It will be initialized again when reusing t
>>>> his pending_tx_info again, right?
>>>>
>>>
>>> Yes, it is needed. Otherwise netback responses to invalid tx_info and
>>> cause netfront to crash before coming into the re-initialization path.
>>
>> Maybe I'm missing something but this is after the make_tx_reponse()
>> call, and immediately after this pending_tx_info is returned to the
>> pending ring as free.
>>
> 
> So it is a bit tricky here. Let me clarify this, the head field is
> used to indicate the start of a new tx requests queue and the end of
> previous queue.

Ok, I get this now.

David
