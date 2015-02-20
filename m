From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Fri, 20 Feb 2015 10:33:27 -0800
Message-ID: <CAHA+R7P172Sewip80a0_+jY2Ozat_HKdxgJLPdjahGN-T_wskw@mail.gmail.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	<CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
	<CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
	<1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PbLRw-oA4v9ivZ0s-++ALx99zddJLDqDoemyBTc2XZ1g@mail.gmail.com>
	<54E68E59.6020401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:46827 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbbBTSd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 13:33:28 -0500
Received: by iecvy18 with SMTP id vy18so9818714iec.13
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 10:33:27 -0800 (PST)
In-Reply-To: <54E68E59.6020401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 5:31 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 02/18/2015 03:57 PM, Cong Wang wrote:
>>
>> On Wed, Feb 18, 2015 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>>
>>> On Wed, 2015-02-18 at 14:11 -0800, Cong Wang wrote:
>>>>
>>>> On Wed, Feb 18, 2015 at 1:18 PM, Cong Wang <cwang@twopensource.com>
>>>> wrote:
>>>>>
>>>>>
>>>>> 2) This breaks the queue mapping specified by an skbedit action,
>>>>> since for TX queues the index starts with 0 while for RX it starts with
>>>>> 1
>>>>> (for some reason I don't see yet). There is at least a mismatch.
>>>>
>>>>
>>>> So queue 0 is reserved for TX, at least for bonding queue mapping.
>>>
>>>
>>> It seems you missed that bonding ndo_select_queue() is rather special.
>>>
>>>
>>
>> I am aware of it. I even would guess (means not digging the history)
>> skb_edit was invented for bonding queue mapping, since I don't see it
>> even works as a general TC action on the physical interface. We pick
>> the tx queue prior to getting the Qdisc, therefore too late to set
>> skb->queue_mapping to specify a hardware TX queue. This is
>> another story I planned to bring it up to David.
>
>
> At one point I proposed a pre-enqueue hook to call before entering
> the qdisc where filters/actions could be attached.
>
>
> https://github.com/jrfastab/Linux-Kernel-QOS/commit/67746f95acd77cf15d7ce34f644b76058ce19813
>
> the idea was to drop select_queue() altogether and force any queue
> selection onto a visible action chain.

That is one quick solution. Ideally, for long term, I think we should
move the TX queues down below the Qdisc layer, or at least separate
them with a clear boundary, rather than mixing in such a way, especially
sch_mq. This is essentially hard since Qdisc's are scheduled in TX softirq,
probably due to historical reason (Qdisc's were invented before multiqueue?).
Anyway, I am still working on it and still trying to find a better solution.

>>
>> However, this still doesn't seem to be a reason to break people who
>> don't use bonding at all? At least we just want to map skb's to different
>> hardware TX queues by setting skb->queue_mapping (before
>> dev_queue_xmit() of course) and sysfs reports the queues starting with
>> index 0. This is why I complain. :)
>
>
> for historical info take a look at multiq qdisc. It was added at
> some point (i think before all the multiple queue nics were there?).
> It does use the select_queue field to select a queue but I doubt anyone
> uses it today with mq and mqprio. I would argue no one should be using
> it there are better ways to get the same thing.

Sure, multiq accepts filters, we have to use our own filters to classify
the flows. Using skbedit is much simpler since we only need to mark
skb->queue_mapping before delivering skb to the physical interface,
no need to add more filters at all (we already have many filters).

Thanks.
