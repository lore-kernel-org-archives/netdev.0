From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Mon, 21 Nov 2016 10:10:57 -0800
Message-ID: <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117144248.23500001@redhat.com>
         <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117155753.17b76f5a@redhat.com>
         <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117193021.580589ae@redhat.com>
         <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161121170351.50a09ee1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33481 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcKUSLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 13:11:00 -0500
Received: by mail-pf0-f195.google.com with SMTP id 144so18723647pfv.0
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 10:10:59 -0800 (PST)
In-Reply-To: <20161121170351.50a09ee1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-21 at 17:03 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 17 Nov 2016 10:51:23 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2016-11-17 at 19:30 +0100, Jesper Dangaard Brouer wrote:
> > 
> > > The point is I can see a socket Send-Q forming, thus we do know the
> > > application have something to send. Thus, and possibility for
> > > non-opportunistic bulking. Allowing/implementing bulk enqueue from
> > > socket layer into qdisc layer, should be fairly simple (and rest of
> > > xmit_more is already in place).    
> > 
> > 
> > As I said, you are fooled by TX completions.
> 
> Obviously TX completions play a role yes, and I bet I can adjust the
> TX completion to cause xmit_more to happen, at the expense of
> introducing added latency.
> 
> The point is the "bloated" spinlock in __dev_queue_xmit is still caused
> by the MMIO tailptr/doorbell.  The added cost occurs when enqueueing
> packets, and result in the inability to get enough packets into the
> qdisc for xmit_more going (on my system).  I argue that a bulk enqueue
> API would allow us to get past the hurtle of transitioning into
> xmit_more mode more easily.
> 


This is very nice, but we already have bulk enqueue, it is called
xmit_more.

Kernel does not know your application is sending a packet after the one
you send.

xmit_more is not often used applications/stacks send many small packets.

qdisc is empty (one enqueued packet is immediately dequeued so
skb->xmit_more is 0), and even bypassed (TCQ_F_CAN_BYPASS)

Not sure it this has been tried before, but the doorbell avoidance could
be done by the driver itself, because it knows a TX completion will come
shortly (well... if softirqs are not delayed too much !)

Doorbell would be forced only if :

(    "skb->xmit_more is not set" AND "TX engine is not 'started yet'" )
OR
( too many [1] packets were put in TX ring buffer, no point deferring
more)

Start the pump, but once it is started, let the doorbells being done by
TX completion.

ndo_start_xmit and TX completion handler would have to maintain a shared
state describing if packets were ready but doorbell deferred.


Note that TX completion means "if at least one packet was drained",
otherwise busy polling, constantly calling napi->poll() would force a
doorbell too soon for devices sharing a NAPI for both RX and TX.

But then, maybe busy poll would like to force a doorbell...

I could try these ideas on mlx4 shortly.


[1] limit could be derived from active "ethtool -c" params, eg tx-frames
