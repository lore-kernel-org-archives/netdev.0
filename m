From: Michael Ma <make0818@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Thu, 15 Sep 2016 17:51:37 -0700
Message-ID: <CAAmHdhyhywBPhHgB5ySXwhvvSAnxUwkCNQrhnLY9WxoMbAYqoQ@mail.gmail.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
 <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
 <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
 <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
 <1473830571.22679.4.camel@edumazet-glaptop3.roam.corp.google.com> <CAAmHdhzKyZ0M_L6OSxaOoLwf4u-T+yFOvBckaiq9OpVJA7Ca0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35783 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753525AbcIPAvi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 20:51:38 -0400
Received: by mail-io0-f179.google.com with SMTP id m186so9835831ioa.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 17:51:38 -0700 (PDT)
In-Reply-To: <CAAmHdhzKyZ0M_L6OSxaOoLwf4u-T+yFOvBckaiq9OpVJA7Ca0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-14 10:46 GMT-07:00 Michael Ma <make0818@gmail.com>:
> 2016-09-13 22:22 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Tue, 2016-09-13 at 22:13 -0700, Michael Ma wrote:
>>
>>> I don't intend to install multiple qdisc - the only reason that I'm
>>> doing this now is to leverage MQ to workaround the lock contention,
>>> and based on the profile this all worked. However to simplify the way
>>> to setup HTB I wanted to use TXQ to partition HTB classes so that a
>>> HTB class only belongs to one TXQ, which also requires mapping skb to
>>> TXQ using some rules (here I'm using priority but I assume it's
>>> straightforward to use other information such as classid). And the
>>> problem I found here is that when using priority to infer the TXQ so
>>> that queue_mapping is changed, bandwidth is affected significantly -
>>> the only thing I can guess is that due to queue switch, there are more
>>> cache misses assuming processor cores have a static mapping to all the
>>> queues. Any suggestion on what to do next for the investigation?
>>>
>>> I would also guess that this should be a common problem if anyone
>>> wants to use MQ+IFB to workaround the qdisc lock contention on the
>>> receiver side and classful qdisc is used on IFB, but haven't really
>>> found a similar thread here...
>>
>> But why are you changing the queue ?
>>
>> NIC already does the proper RSS thing, meaning all packets of one flow
>> should land on one RX queue. No need to ' classify yourself and risk
>> lock contention'
>>
>> I use IFB + MQ + netem every day, and it scales to 10 Mpps with no
>> problem.
>>
>> Do you really need to rate limit flows ? Not clear what are your goals,
>> why for example you use HTB to begin with.
>>
> Yes. My goal is to set different min/max bandwidth limits for
> different processes, so we started with HTB. However with HTB the
> qdisc root lock contention caused some unintended correlation between
> flows in different classes. For example if some flows belonging to one
> class have large amount of small packets, other flows in a different
> class will get their effective bandwidth reduced because they'll wait
> longer for the root lock. Using MQ this can be avoided because I'll
> just put flows belonging to one class to its dedicated TXQ. Then
> classes within one HTB on a TXQ will still have the lock contention
> problem but classes in different HTB will use different root locks so
> the contention doesn't exist.
>
> This also means that I'll need to classify packets to different
> TXQ/HTB based on some skb metadata (essentially similar to what mqprio
> is doing). So TXQ might need to be switched to achieve this.

My current theory to this problem is that tasklets in IFB might be
scheduled to the same cpu core if the RXQ happens to be the same for
two different flows. When queue_mapping is modified and multiple flows
are concentrated to the same IFB TXQ because they need to be
controlled by the same HTB, they'll have to use the same tasklet
because of the way IFB is implemented. So if other flows belonging to
a different TXQ/tasklet happens to be scheduled on the same core, that
core can be overloaded and becomes the bottleneck. Without modifying
the queue_mapping the chance of this contention is much lower.

This is a speculation based on the increased si time in softirqd
process. I'll try to affinitize each tasklet with a cpu core to verify
whether this is the problem. I also noticed that in the past there was
a similar proposal of scheduling the tasklet to a dedicated core which
was not committed(https://patchwork.ozlabs.org/patch/38486/). I'll try
something similar to verify this theory.
