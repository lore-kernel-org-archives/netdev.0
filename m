From: Michael Ma <make0818@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Fri, 23 Sep 2016 16:21:33 -0700
Message-ID: <CAAmHdhzv0Vqmc7gguSv34+kvEWRiHndLbOyWhvw0eUrV06x6_Q@mail.gmail.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
 <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
 <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
 <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
 <1473830571.22679.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhzKyZ0M_L6OSxaOoLwf4u-T+yFOvBckaiq9OpVJA7Ca0A@mail.gmail.com>
 <CAAmHdhyhywBPhHgB5ySXwhvvSAnxUwkCNQrhnLY9WxoMbAYqoQ@mail.gmail.com>
 <CAAmHdhx7uvg_q49oz_u8q6NYmv=okxmKg1Tc5ny6oRCvaxbnww@mail.gmail.com>
 <1474055639.22679.74.camel@edumazet-glaptop3.roam.corp.google.com> <CAAmHdhwZUeKd_GKj8JdbXtdAZxn8sfbaGx+1Mjzn08rT3yf=+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34944 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758775AbcIWXVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 19:21:35 -0400
Received: by mail-io0-f178.google.com with SMTP id m186so132944532ioa.2
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:21:34 -0700 (PDT)
In-Reply-To: <CAAmHdhwZUeKd_GKj8JdbXtdAZxn8sfbaGx+1Mjzn08rT3yf=+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-16 15:00 GMT-07:00 Michael Ma <make0818@gmail.com>:
> 2016-09-16 12:53 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2016-09-16 at 10:57 -0700, Michael Ma wrote:
>>
>>> This is actually the problem - if flows from different RX queues are
>>> switched to the same RX queue in IFB, they'll use different processor
>>> context with the same tasklet, and the processor context of different
>>> tasklets might be the same. So multiple tasklets in IFB competes for
>>> the same core when queue is switched.
>>>
>>> The following simple fix proved this - with this change even switching
>>> the queue won't affect small packet bandwidth/latency anymore:
>>>
>>> in ifb.c:
>>>
>>> -       struct ifb_q_private *txp = dp->tx_private + skb_get_queue_mapping(skb);
>>> +       struct ifb_q_private *txp = dp->tx_private +
>>> (smp_processor_id() % dev->num_tx_queues);
>>>
>>> This should be more efficient since we're not sending the task to a
>>> different processor, instead we try to queue the packet to an
>>> appropriate tasklet based on the processor ID. Will this cause any
>>> packet out-of-order problem? If packets from the same flow are queued
>>> to the same RX queue due to RSS, and processor affinity is set for RX
>>> queues, I assume packets from the same flow will end up in the same
>>> core when tasklet is scheduled. But I might have missed some uncommon
>>> cases here... Would appreciate if anyone can provide more insights.
>>
>> Wait, don't you have proper smp affinity for the RX queues on your NIC ?
>>
>> ( Documentation/networking/scaling.txt RSS IRQ Configuration )
>>
> Yes - what I was trying to say is that this change will be more
> efficient than using smp_call_function_single() to schedule the
> tasklet to a different processor.
>
> RSS IRQ should be set properly already. The issue here is that I'll
> need to switch the queue mapping for NIC RX to a different TXQ on IFB,
> which allows me to classify the flows at the IFB TXQ layer and avoid
> qdisc lock contention.
>
> When that switch happens, ideally processor core shouldn't be switched
> because all the thread context isn't changed. The work in tasklet
> should be scheduled to the same processor as well. That's why I tried
> this change. Also conceptually IFB is a software device which should
> be able to schedule its workload independent from how NIC is
> configured for the interrupt handling.
>
>> A driver ndo_start_xmit() MUST use skb_get_queue_mapping(skb), because
>> the driver queue is locked before ndo_start_xmit())  (for non
>> NETIF_F_LLTX drivers at least)
>>
>
> Thanks a lot for pointing out this! I was expecting this kind of
> guidance... Then the options would be:
>
> 1. Use smp_call_function_single() to schedule the tasklet to a core
> statically mapped to the IFB TXQ, which is very similar to how TX/RX
> IRQ is configured.

This actually won't help with the throughput because ultimately load
will still be concentrated to some particular cores after packets are
concentrated to a TXQ due to queue level classification.

> 2. As you suggested below add some additional action to do the
> rescheduling before entering IFB - for example when receiving the
> packet we could just use RSS to redirect to the desired RXQ, however
> this doesn't seem to be easy, especially compared with the way how
> mqprio chooses the queue. The challenge here is that IFB queue
> selection is based on queue_mapping when skb arrives at IFB and core
> selection is based on RXQ on NIC and so it's also based on
> queue_mapping when skb arrives at NIC. Then these two queue_mappings
> must be the same so that there is no core conflict of processing two
> TXQs of IFB. Then this essentially means we have to change queue
> mapping of the NIC on the receiver side which can't be achieved using
> TC.
>

I tried to explore this further - there is actually XPS on ifb which
can be used to specify the processor cores that will be used to
process each TXQ of ifb, however the problem is similar as above -
eventually I'll have a few cores processing these queues instead of
having all the cores processing together with relatively light
contention. And this again reduces the throughput. So there isn't a
good place to do this. The ultimate problem is that we're trying to
workaround the qdisc spin lock problem by leveraging the independence
of TXQs, but at the same time after qdisc phase we also want to
maximize the utilization of cores across whatever TXQs that are used.

>> In case of ifb, __skb_queue_tail(&txp->rq, skb); could corrupt the skb
>> list.
>>
>> In any case, you could have an action to do this before reaching IFB.
>>
>>
>>

So here is another solution - for packets coming from the NIC ingress
path the context is already a tasklet and there is no need of starting
another tasklet based on the queue selected, right? All the RQ
handling and netif_tx_stop/wakeup stuff in ifb module is unnecessary
in this case. Then we can just do transmit/receive in ifb_xmit()
directly to simplify the problem here - there is no synchronization
issue for the RQ anymore since there is no RQ indeed.

Eric, would appreciate if you can share your thoughts here.
