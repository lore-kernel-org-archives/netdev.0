From: Tom Herbert <tom@herbertland.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 17:16:25 -0800
Message-ID: <CALx6S35UZcD+kXTTGeML4DdDYaUoArSfEPeUoTuFEeRWKsM7sQ@mail.gmail.com>
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
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35509 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753868AbcLABQ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 20:16:27 -0500
Received: by mail-qt0-f175.google.com with SMTP id c47so206405940qtc.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 17:16:27 -0800 (PST)
In-Reply-To: <1480552059.18162.239.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 4:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Another issue I found during my tests last days, is a problem with BQL,
> and more generally when driver stops/starts the queue.
>
> When under stress and BQL stops the queue, driver TX completion does a
> lot of work, and servicing CPU also takes over further qdisc_run().
>
Hmm, hard to say if this is problem or a feature I think ;-). One way
to "solve" this would be to use IRQ round robin, that would spread the
load of networking across CPUs, but that gives us no additional
parallelism and reduces locality-- it's generally considered a bad
idea. The question might be: is it better to continuously ding one CPU
with all the networking work or try to artificially spread it out?
Note this is orthogonal to MQ also, so we should already have multiple
CPUs doing netif_schedule_queue for queues they manage.

Do you have a test or application that shows this is causing pain?

> The work-flow is :
>
> 1) collect up to 64 (or 256 packets for mlx4) packets from TX ring, and
> unmap things, queue skbs for freeing.
>
> 2) Calls netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
>
> if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state))
>      netif_schedule_queue(dev_queue);
>
> This leaves a very tiny window where other cpus could grab __QDISC_STATE_SCHED
> (They absolutely have no chance to grab it)
>
> So we end up with one cpu doing the ndo_start_xmit() and TX completions,
> and RX work.
>
> This problem is magnified when XPS is used, if one mono-threaded application deals with
> thousands of TCP sockets.
>
Do you know of an application doing this? The typical way XPS and most
of the other steering mechanisms are configured assume that workloads
tend towards a normal distribution. Such mechanisms can become
problematic under asymmetric loads, but then I would expect these are
likely dedicated servers so that the mechanisms can be tuned
accordingly. For instance, XPS can be configured to map more than one
queue to a CPU. Alternatively, IIRC Windows has some functionality to
tune networking for the load (spin up queues, reconfigure things
similar to XPS/RPS, etc.)-- that's promising up the point that we need
a lot of heuristics and measurement; but then we lose determinism and
risk edge case where we get completely unsatisfied results (one of my
concerns with the recent attempt to put configuration in the kernel).

> We should use an additional bit (__QDISC_STATE_PLEASE_GRAB_ME) or some way
> to allow another cpu to service the qdisc and spare us.
>
Wouldn't this need to be an active operation? That is to queue the
qdisc on another CPU's output_queue?

Tom

>
>
