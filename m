From: David Miller <davem@davemloft.net>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 01 Dec 2016 15:20:29 -0500 (EST)
Message-ID: <20161201.152029.2045474106824619667.davem@davemloft.net>
References: <1480602274.18162.285.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161201170443.28a8c032@redhat.com>
        <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, saeedm@dev.mellanox.co.il, rick.jones2@hpe.com,
        netdev@vger.kernel.org, saeedm@mellanox.com, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752609AbcLAUUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:20:34 -0500
In-Reply-To: <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2016 09:04:17 -0800

> On Thu, 2016-12-01 at 17:04 +0100, Jesper Dangaard Brouer wrote:
> 
>> When qdisc layer or trafgen/af_packet see this indication it knows it
>> should/must flush the queue when it don't have more work left.  Perhaps
>> through net_tx_action(), by registering itself and e.g. if qdisc_run()
>> is called and queue is empty then check if queue needs a flush. I would
>> also allow driver to flush and clear this bit.
> 
> net_tx_action() is not normally called, unless BQL limit is hit and/or
> some qdiscs with throttling (HTB, TBF, FQ, ...)

The one thing I wonder about is whether we should "ramp up" into a mode
where the NAPI poll does the doorbells instead of going directly there.

Maybe I misunderstand your algorithm, but it looks to me like if there
are any active packets in the TX queue at enqueue time you will defer
the doorbell to the interrupt handler.

Let's say we put 1 packet in, and hit the doorbell.

Then another packet comes in and we defer the doorbell to the IRQ.

At this point there are a couple things I'm unclear about.

For example, if we didn't hit the doorbell, will the chip still take a
peek at the second descriptor?  Depending upon how the doorbell works
it might, or it might not.

Either way, wouldn't there be a possible condition where the chip
wouldn't see the second enqueued packet and we'd thus have the wire
idle until the interrupt + NAPI runs and hits the doorbell?

This is why I think we should "ramp up" the doorbell deferral, in
order to avoid this potential wire idle time situation.

Maybe the situation I'm worried about is not possible, so please
explain it to me :-)
