From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Fri, 27 Aug 2010 08:26:49 -0700
Message-ID: <4C77D939.2050807@candelatech.com>
References: <4C774B8F.2030805@candelatech.com>	<20100826.223604.48516081.davem@davemloft.net>	<4C775411.1000302@candelatech.com> <20100826.231110.260096663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49088 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab0H0P0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 11:26:53 -0400
In-Reply-To: <20100826.231110.260096663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 11:11 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 26 Aug 2010 22:58:41 -0700
>
>> And if it does that, then something must know how to restart the
>> transmit logic.
>
> When SKBs get freed up, space opens up in the socket send buffer,
> waking up the process or signalling it from poll() so it can write
> more.

Seems there is still room for problems:

*  There may be zero frames already in the qdisc for this UDP connection,
    so aside from the one that failed to enqueue, none other will be freed.

*  If deleting that single SKB that was to be enqueued opens space, then it's
    not really throttling, just busy-spinning on deleting skbs, but I think
    that the wakeup heuristics won't wake the queue until it's about 1/2 full
    anyway, so that single skb isn't going to wake any queues in most cases.

I'll look through the code later today and see how much churn it would take
to support the BUSY return code from dev_queue_xmit, without adding any new
qdisc API methods.

For the trivial case, I can just kfree_skb when BUSY is returned, for the
same overall behaviour as today.  For something like UDP, I might be able
to poke the SKB back into the queue instead of freeing it.

> pktgen eliminates this whole layer of queueing and signalling, which
> is why it continually succeptible this behavior you dislike.

Proper backoff on error codes from hard_start_xmit and some wake logic
when the unerlying netdevice wakes up again fixes this.  You can make pktgen
run w/out busy spinning.  It's a big messy patch (as I coded it up)
though.

I think we could concentrate on allowing qdisc to return some sort of
congestion notification w/out always freeing the skb first, and once
that seems workable, go back to worrying about how to properly propagate
that through macvlans.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
