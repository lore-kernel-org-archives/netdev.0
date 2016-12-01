From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 01 Dec 2016 14:10:11 -0800
Message-ID: <1480630211.18162.344.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480602274.18162.285.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201170443.28a8c032@redhat.com>
         <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201.152029.2045474106824619667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, saeedm@dev.mellanox.co.il, rick.jones2@hpe.com,
        netdev@vger.kernel.org, saeedm@mellanox.com, tariqt@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35854 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757525AbcLAWLO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:11:14 -0500
Received: by mail-pf0-f195.google.com with SMTP id c4so12455482pfb.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 14:11:14 -0800 (PST)
In-Reply-To: <20161201.152029.2045474106824619667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 15:20 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 01 Dec 2016 09:04:17 -0800
> 
> > On Thu, 2016-12-01 at 17:04 +0100, Jesper Dangaard Brouer wrote:
> > 
> >> When qdisc layer or trafgen/af_packet see this indication it knows it
> >> should/must flush the queue when it don't have more work left.  Perhaps
> >> through net_tx_action(), by registering itself and e.g. if qdisc_run()
> >> is called and queue is empty then check if queue needs a flush. I would
> >> also allow driver to flush and clear this bit.
> > 
> > net_tx_action() is not normally called, unless BQL limit is hit and/or
> > some qdiscs with throttling (HTB, TBF, FQ, ...)
> 
> The one thing I wonder about is whether we should "ramp up" into a mode
> where the NAPI poll does the doorbells instead of going directly there.
> 
> Maybe I misunderstand your algorithm, but it looks to me like if there
> are any active packets in the TX queue at enqueue time you will defer
> the doorbell to the interrupt handler.
> 
> Let's say we put 1 packet in, and hit the doorbell.
> 
> Then another packet comes in and we defer the doorbell to the IRQ.
> 
> At this point there are a couple things I'm unclear about.


> 
> For example, if we didn't hit the doorbell, will the chip still take a
> peek at the second descriptor?  Depending upon how the doorbell works
> it might, or it might not.

It might depend on the hardware. I can easily check on mlx4, by
increasing tx-usecs and tx-frames, and sending 2 packets back to back.

> 
> Either way, wouldn't there be a possible condition where the chip
> wouldn't see the second enqueued packet and we'd thus have the wire
> idle until the interrupt + NAPI runs and hits the doorbell?
> 
> This is why I think we should "ramp up" the doorbell deferral, in
> order to avoid this potential wire idle time situation.


> 
> Maybe the situation I'm worried about is not possible, so please
> explain it to me :-)

This is absolutely the problem. We might need to enable this mode only
above a given load. We could have an EWMA of the number of packets
that TX completion runs can dequeue. And enable auto doorbell only if we
have that many packets in the TX ring (instead of the  "1 packet
threshold" of the WIP)
