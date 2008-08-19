From: Bastian Bloessl <basti@b-bl.de>
Subject: Re: [PATCH 5/9]: sch_netem: Use requeue list instead of ops->requeue()
Date: Tue, 19 Aug 2008 19:36:09 +0200
Message-ID: <48AB0489.8060107@b-bl.de>
References: <20080818.013702.111675433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp035.webpack.hosteurope.de ([80.237.132.42]:51471 "EHLO
	wp035.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753952AbYHSR7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 13:59:37 -0400
In-Reply-To: <20080818.013702.111675433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> sch_netem: Use requeue list instead of ops->requeue()
> 
> This code just wants to make this packet the "front" one, and that's
> just as simply done by queueing to the ->requeue list.
> 

Hi,
I think that might make some difference.
Suppose we have an upper qdisc that dequeues from netem and
puts the packet in it's requeue-list. But after that another
packet could arrive that should be send earlier (delay
distribution, reordering).
As far as I understand it the requeued packet would now
be send before the other.

> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -233,7 +233,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		 */
>  		cb->time_to_send = psched_get_time();
>  		q->counter = 0;
> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
> +		__skb_queue_tail(&q->qdisc->requeue, skb);

I think this should be __skb_queue_head() because in it's
requeue-list netem has packets that it doesn't want to send yet. So
their time_to_send is likely to be in the future. But reordered
packets have current time as time_to_send.

Or did I get it wrong?

Regards
Bastian Bloessl
