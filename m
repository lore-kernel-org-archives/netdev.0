From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] net: add IFLA_NUM_TXQ attribute
Date: Fri, 17 Sep 2010 16:29:58 -0700 (PDT)
Message-ID: <20100917.162958.221590019.davem@davemloft.net>
References: <1284712288.3391.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136Ab0IQX3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:29:39 -0400
In-Reply-To: <1284712288.3391.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Sep 2010 10:31:28 +0200

> In order to enable multiqueue support on some devices,
> add IFLA_NUM_TXQ attribute, number of transmit queues, that "ip link"
> can use, at creation and show time :
> 
> # ip link add gre34 txqueues 8 type gre remote 192.168.20.80
> 
> # ip link sho dev gre34
> 8: gre34: <POINTOPOINT,NOARP> mtu 1476 qdisc noop state DOWN txqueues 8 
>     link/gre 0.0.0.0 peer 192.168.20.80
> 
> Drivers not yet multiqueue aware are supported, because core network
> temporary sets real_num_tx_queues to one.
> 
> Multiqueue enabled drivers must then sets real_num_tx_queues to
> num_tx_queues in their newlink() method.
> 
> Limits number of queues to 256 for the moment.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This is one way to solve the problem, but I think we can do a lot
better.

What is the true barrier for full parallel processing over GRE tunnels
at the moment?

It seems to me that the only issue that exists is the TXQ->lock done
by dev_queue_xmit() for the GRE tunnel xmit.

This is something we should have fixed ages ago, and we tried with the
ugly LLTX thing.  In my opinion all paths leading to a non-queueing
device should not take the TX lock, because by definition there is no
queueing state or synchronization to be cognizant of.

Actually, statistics can matter but we already have to address that
problem seperately for the sake of 64-bit stats on 32-bit machines.

Alexey even open condones this in the huge comment that sits in
the "!q->enqueue" path of dev_queue_xmit().

If we take care of this, then TX multi-queue works transparently for
all software devices layered on top of suitably capable hardware,
without us having to make any explicit multi-queue changes to the
software device code.

Eric, if you can demonstrate a real need for this once we solve the
fundamental issue, as I have outlined above, I am happy to add this
netlink attribute and tunable.  But for now I'm deferring these
two patches.

Thanks!
