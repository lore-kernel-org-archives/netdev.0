From: Tom Herbert <tom@herbertland.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 21:03:29 -0800
Message-ID: <CALx6S34ENTbUmCGx_4izNHoXbdy5UHuvUesbFGw+8kQSidesEg@mail.gmail.com>
References: <20140903165943.372b897b@redhat.com> <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com> <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com> <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117144248.23500001@redhat.com> <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com> <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117193021.580589ae@redhat.com> <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161121170351.50a09ee1@redhat.com> <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130123810.581ba21f@redhat.com> <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130201711.2f353a76@redhat.com> <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480552059.18162.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35UZcD+kXTTGeML4DdDYaUoArSfEPeUoTuFEeRWKsM7sQ@mail.gmail.com> <1480559566.18162.253.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Willem de Bruijn <willemb@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35300 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbcLAFDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 00:03:55 -0500
Received: by mail-qt0-f174.google.com with SMTP id c47so210207485qtc.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 21:03:31 -0800 (PST)
In-Reply-To: <1480559566.18162.253.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-11-30 at 17:16 -0800, Tom Herbert wrote:
>> On Wed, Nov 30, 2016 at 4:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> > Another issue I found during my tests last days, is a problem with BQL,
>> > and more generally when driver stops/starts the queue.
>> >
>> > When under stress and BQL stops the queue, driver TX completion does a
>> > lot of work, and servicing CPU also takes over further qdisc_run().
>> >
>> Hmm, hard to say if this is problem or a feature I think ;-). One way
>> to "solve" this would be to use IRQ round robin, that would spread the
>> load of networking across CPUs, but that gives us no additional
>> parallelism and reduces locality-- it's generally considered a bad
>> idea. The question might be: is it better to continuously ding one CPU
>> with all the networking work or try to artificially spread it out?
>> Note this is orthogonal to MQ also, so we should already have multiple
>> CPUs doing netif_schedule_queue for queues they manage.
>>
>> Do you have a test or application that shows this is causing pain?
>
> Yes, just launch enough TCP senders (more than 10,000) to fully utilize
> the NIC, with small messages.
>
> super_netperf is not good for that, because you would need 10,000
> processes and would spend too much cycles just dealing with an enormous
> working set, you would not activate BQL.
>
>
>>
>> > The work-flow is :
>> >
>> > 1) collect up to 64 (or 256 packets for mlx4) packets from TX ring, and
>> > unmap things, queue skbs for freeing.
>> >
>> > 2) Calls netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
>> >
>> > if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state))
>> >      netif_schedule_queue(dev_queue);
>> >
>> > This leaves a very tiny window where other cpus could grab __QDISC_STATE_SCHED
>> > (They absolutely have no chance to grab it)
>> >
>> > So we end up with one cpu doing the ndo_start_xmit() and TX completions,
>> > and RX work.
>> >
>> > This problem is magnified when XPS is used, if one mono-threaded application deals with
>> > thousands of TCP sockets.
>> >
>> Do you know of an application doing this? The typical way XPS and most
>> of the other steering mechanisms are configured assume that workloads
>> tend towards a normal distribution. Such mechanisms can become
>> problematic under asymmetric loads, but then I would expect these are
>> likely dedicated servers so that the mechanisms can be tuned
>> accordingly. For instance, XPS can be configured to map more than one
>> queue to a CPU. Alternatively, IIRC Windows has some functionality to
>> tune networking for the load (spin up queues, reconfigure things
>> similar to XPS/RPS, etc.)-- that's promising up the point that we need
>> a lot of heuristics and measurement; but then we lose determinism and
>> risk edge case where we get completely unsatisfied results (one of my
>> concerns with the recent attempt to put configuration in the kernel).
>
> We have thousands of applications, and some of them 'kind of multicast'
> events to a broad number of TCP sockets.
>
> Very often, applications writers use a single thread for doing this,
> when all they need is to send small packets to 10,000 sockets, and they
> do not really care of doing this very fast. They also do not want to
> hurt other applications sharing the NIC.
>
> Very often, process scheduler will also run this single thread in a
> single cpu, ie avoiding expensive migrations if they are not needed.
>
> Problem is this behavior locks one TX queue for the duration of the
> multicast, since XPS will force all the TX packets to go to one TX
> queue.
>
The fact that XPS is forcing TX packets to go over one CPU is a result
of how you've configured XPS. There are other potentially
configurations that present different tradeoffs. For instance, TX
queues are plentiful now days to the point that we could map a number
of queues to each CPU while respecting NUMA locality between the
sending CPU and where TX completions occur. If the set is sufficiently
large this would also helps to address device lock contention. The
other thing I'm wondering is if Willem's concepts distributing DOS
attacks in RPS might be applicable in XPS. If we could detect that a
TX queue is "under attack" maybe we can automatically backoff to
distributing the load to more queues in XPS somehow.

Tom

> Other flows that would share the locked CPU experience high P99
> latencies.
>
>
>>
>> > We should use an additional bit (__QDISC_STATE_PLEASE_GRAB_ME) or some way
>> > to allow another cpu to service the qdisc and spare us.
>> >
>> Wouldn't this need to be an active operation? That is to queue the
>> qdisc on another CPU's output_queue?
>
> I simply suggest we try to queue the qdisc for further servicing as we
> do today, from net_tx_action(), but we might use a different bit, so
> that we leave the opportunity for another cpu to get __QDISC_STATE_SCHED
> before we grab it from net_tx_action(), maybe 100 usec later (time to
> flush all skbs queued in napi_consume_skb() and maybe RX processing,
> since most NIC handle TX completion before doing RX processing from thei
> napi poll handler.
>
> Should be doable with few changes in __netif_schedule() and
> net_tx_action(), plus some control paths that will need to take care of
> the new bit at dismantle time, right ?
>
>
>
