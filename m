From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: refine early skb orphaning
Date: Sat, 14 Jul 2012 14:53:33 -0700
Message-ID: <20120714145333.2c441166@nehalam.linuxnetplumber.net>
References: <1342271787.3265.9632.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Mark Gordon <msg@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59679 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165Ab2GNVx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 17:53:56 -0400
In-Reply-To: <1342271787.3265.9632.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Jul 2012 15:16:27 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> netem does an early orphaning of skbs. Doing so breaks TCP Small Queue
> or any mechanism relying on socket sk_wmem_alloc feedback.
> 
> Ideally, we should perform this orphaning after the rate module and
> before the delay module, to mimic what happens on a real link :
> 
> skb orphaning is indeed normally done at TX completion, before the
> transit on the link.
> 
> +-------+   +--------+  +---------------+  +-----------------+
> + Qdisc +---> Device +--> TX completion +--> links / hops    +->
> +       +   +  xmit  +  + skb orphaning +  + propagation     +
> +-------+   +--------+  +---------------+  +-----------------+
>       < rate limiting >                  < delay, drops, reorders >
> 
> If netem is used without delay feature (drops, reorders, rate
> limiting), then we should avoid early skb orphaning, to keep pressure
> on sockets as long as packets are still in qdisc queue.
> 
> Ideally, netem should be refactored to implement delay module
> as the last stage. Current algorithm merges the two phases
> (rate limiting + delay) so its not correct.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Mark Gordon <msg@google.com>
> Cc: Andreas Terzis <aterzis@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/sched/sch_netem.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index c412ad0..298c0dd 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -380,7 +380,14 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
>  	}
>  
> -	skb_orphan(skb);
> +	/* If a delay is expected, orphan the skb. (orphaning usually takes
> +	 * place at TX completion time, so _before_ the link transit delay)
> +	 * Ideally, this orphaning should be done after the rate limiting
> +	 * module, because this breaks TCP Small Queue, and other mechanisms
> +	 * based on socket sk_wmem_alloc.
> +	 */
> +	if (q->latency || q->jitter)
> +		skb_orphan(skb);
>  
>  	/*
>  	 * If we need to duplicate packet, then re-insert at top of the
> 

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
