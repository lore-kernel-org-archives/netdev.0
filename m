From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Mon, 07 Apr 2014 07:07:42 -0700
Message-ID: <1396879662.12330.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <<20140407075347.GA26461@gondor.apana.org.au>
	 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:57194 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbaDGOHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 10:07:44 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so6731983pab.5
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 07:07:43 -0700 (PDT)
In-Reply-To: <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-07 at 15:55 +0800, Herbert Xu wrote:
> Currently broadcasts are handled in network RX context, where
> the packets are sent through netif_rx.  This means that the number
> of macvlans will be constrained by the capacity of netif_rx.
> 
> For example, setting up 4096 macvlans practically causes all
> broadcast packets to be dropped as the default netif_rx queue
> size simply can't handle 4096 skbs being stuffed into it all
> at once.
> 
> Fundamentally, we need to ensure that the amount of work handled
> in each netif_rx backlog run is constrained.  As broadcasts are
> anything but constrained, it either needs to be limited per run
> or moved to process context.
> 
> This patch picks the second option and moves all broadcast handling
> bar the trivial case of packets going to a single interface into
> a work queue.  Obviously there also needs to be a limit on how
> many broadcast packets we postpone in this way.  I've arbitrarily
> chosen tx_queue_len of the master device as the limit (act_mirred
> also happens to use this parameter in a similar way).
> 
> In order to ensure we don't exceed the backlog queue we will use
> netif_rx_ni instead of netif_rx for broadcast packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 

Hi Herbert.

I suppose its a net-next material ?

Memory allocations (one incoming message -> ~4096 duplications) probably
should use GFP_KERNEL. This might need a change from rcu to simple mutex
for macvlan_broadcast() scan of all macvlans.

cond_resched() could help macvlan_process_broadcast() to not hog cpu.

Anyway, 4.000 incoming messages are duplicated into 16.000.000 messages,
it takes half a minute to process on a single cpu. You might need
multiple workqueue to split the load on all online cpus ;)

Thanks !
