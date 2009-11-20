From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 14:32:18 -0800 (PST)
Message-ID: <20091120.143218.252563862.davem@davemloft.net>
References: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754786AbZKTWcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:32:01 -0500
In-Reply-To: <4B05D8DC.7020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Nov 2009 00:46:36 +0100

> Goal of XPS is to free TX completed skbs by the cpu that submitted
> the transmit.
> 
> Because I chose to union skb->iif with skb->sending_cpu, I chose
> to introduce a new xps_consume_skb(skb), and not generalize consume_skb() itself.
> 
> This means that selected drivers must use new function to benefit from XPS
> 
> Preliminary tests are quite good, especially on NUMA machines.
> 
> Only NAPI drivers can use this new infrastructure (xps_consume_skb() cannot
> be called from hardirq context, only from softirq)
> 
> I converted tg3 and pktgen for my tests
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I like this work.  But as you know it still needs a little bit
more work :-)

Let's also pick a more decent name for the free function since
tons of drivers are going to call this thing.  How about
dev_kfree_tx_skb()? :-)

I see Jarek and you have come to a mutual understanding about the
locking.  Since you need to change it anyways to fix the deadlock,
what using a netchannel like scheme to do remote SKB queueing?

PAGE_SIZE queue arrays, lockless access to head and tail pointers, and
if queue is full we local free.

I think that's a reasonable policy and the only detail to work out is
to make sure we never race on the IPI send and thus miss processing
the queue.

What do you think?

