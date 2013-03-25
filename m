From: Wei Liu <liuw@liuw.name>
Subject: Re: [PATCH 5/6] xen-netback: coalesce slots before
	copying
Date: Mon, 25 Mar 2013 16:58:12 +0000
Message-ID: <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <51507C9B.3080109@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 25, 2013 at 4:34 PM, David Vrabel <david.vrabel@citrix.com> wrote:
> On 25/03/13 15:47, Wei Liu wrote:
>> On Mon, Mar 25, 2013 at 3:13 PM, David Vrabel <david.vrabel@citrix.com> wrote:
>>> On 25/03/13 11:08, Wei Liu wrote:
>>>> This patch tries to coalesce tx requests when constructing grant copy
>>>> structures. It enables netback to deal with situation when frontend's
>>>> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
>>>>
>>>> It defines max_skb_slots, which is a estimation of the maximum number of slots
>>>> a guest can send, anything bigger than that is considered malicious. Now it is
>>>> set to 20, which should be enough to accommodate Linux (16 to 19).
>>>
>>> This maximum needs to be defined as part of the protocol and added to
>>> the interface header.
>>>
>>
>> No, this is not part of the protocol and not a hard limit. It is
>> configurable by system administrator.
>
> There is no mechanism by which the front and back ends can negotiate
> this value, so it does need to be a fixed value that is equal or greater
> than the max from any front or back end that has ever existed.
>

Are you suggesting move the default macro value to header file? It is
just an estimation, I have no knowledge of the accurate maximum value,
so I think make it part of the protocol a bad idea.

Do you have a handle on the maximum value?

> The reason for this patch is that this wasn't properly specified and
> changes outside of netback broke the protocol.
>
>>>> +
>>>> +                             if (unlikely(!first)) {
>>>
>>> This isn't unlikely is it?
>>>
>>
>> For big packet the chance is 1 in max_skb_slots, so 5% (1/20) in default case.
>
> I don't understand your reasoning here.  The "if (!first)" branch is
> taken once per page.  It will be 100% if each slot goes into its own
> page and only 5% if the packet is less than PAGE_SIZE in length but
> split into 20 slots.
>

My mistake. Should be a small packet split into multiple slots.

>>> [...]
>>>> +             /* Setting any number other than
>>>> +              * INVALID_PENDING_RING_IDX indicates this slot is
>>>> +              * starting a new packet / ending a previous packet.
>>>> +              */
>>>> +             pending_tx_info->head = 0;
>>>
>>> This doesn't look needed.  It will be initialized again when reusing t
>>> his pending_tx_info again, right?
>>>
>>
>> Yes, it is needed. Otherwise netback responses to invalid tx_info and
>> cause netfront to crash before coming into the re-initialization path.
>
> Maybe I'm missing something but this is after the make_tx_reponse()
> call, and immediately after this pending_tx_info is returned to the
> pending ring as free.
>

So it is a bit tricky here. Let me clarify this, the head field is
used to indicate the start of a new tx requests queue and the end of
previous queue.

Imagine a sequence of head fileds(I = INVALID_PENDING_RING_IDX below),
the number is the starting index of pending ring.

  .... 0 I I I 5 I I ...

consume all tx_info but not setting I to 0 (or any number other then
I) makes the sequence remains the same as before. The in subsequent
call to process next SKB, which has 3 extra slots, which makes the
sequence look like

  .... 8 I I I I I I ...

but in fact the correct sequence should be

  .... 8 I I I 0 I I ...

The wrong sequence makes netbk_idx_release responses to more slots
than required, which causes netfront to crash miserably.


Wei.


> David
