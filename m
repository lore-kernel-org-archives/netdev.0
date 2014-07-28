From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Multiqueue TX
Date: Mon, 28 Jul 2014 16:03:37 -0700
Message-ID: <53D6D6C9.2070607@gmail.com>
References: <CAJzFV37uOC15X+3PR0UJDsBGvMzRP9JRDp16CH8-OiiTv2NM7g@mail.gmail.com> <CAJzFV36cL9=qNcF-cb0OSx1A39FP2Gaa98HBqr9D35fQ3BfU=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:49409 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaG1XDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 19:03:49 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so9586205oag.28
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 16:03:49 -0700 (PDT)
In-Reply-To: <CAJzFV36cL9=qNcF-cb0OSx1A39FP2Gaa98HBqr9D35fQ3BfU=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2014 03:37 PM, Sharat Masetty wrote:
> Hi David,
>
> Can you please answer my question when you get a chance?
>
> Regards,
> Sharat

Little patience ;) Monday's are always a bit busy.

>
> On Sat, Jul 26, 2014 at 1:31 AM, Sharat Masetty <sharat04@gmail.com> wrote:
>> I have a question from this David's nice presentation
>> http://vger.kernel.org/~davem/davem_nyc09.pdf on multiqueue TX. My
>> questions are on the slide named "PICTURE WITH NON-TRIVIAL QDISC"
>>
>> 1)  What is the rationale behind such an arrangement, where one would
>> have multiple TX queues pointing to the on single Qdisc?

The simplest example is to take a look at sch_tbf and try to work out
how we could rate limit a device. Here you have a single qdisc being
used for all TX queues. HTB as you note below is another example.

How would you propose creating rate limits across entire interfaces
without a single Qdisc.

Its ongoing work to create queuing disciplines that don't bottleneck
on the qdisc lock and distribute the state.

>> 2)  If the Qdisc in this illustration was a non trivial Qdisc such as
>> htb, which has multiple leaf Qdisc's, how would the traffic shaping be
>> preserved?

Not sure I follow. Using HTB as a root qdisc on an interface works the
same if the interface has 1 queue or 128 queues.

Maybe you need to review netdev_pick_tx and follow skb->queue_mapping
through the device notice that it is not really used by the qdisc.

>> 3) How would the back pressure/flow control of these individual TX
>> queues work in this case?

To sort this out look into netif_stop_subqueue() and how the ethernet
drivers use this call. Then look at how it is used in ./net/sch_generic
by the dequeue_skb() call. I think it should be clear by reviewing this
usage how the back pressure works from the driver to the qdisc. Its
fairly straight forward and uses a bit to indicate to the qdisc stack
the driver can not consume more skbs.

>>
>> Thanks
>> Sharat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
