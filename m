From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Tue, 7 Oct 2008 07:44:35 +0000
Message-ID: <20081007074435.GA2700@ff.dom.local>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:36102 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYJGHol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 03:44:41 -0400
Received: by ug-out-1314.google.com with SMTP id k3so155290ugf.37
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 00:44:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081007045145.GA23883@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 03:51:47PM +1100, Simon Horman wrote:
> On Tue, Oct 07, 2008 at 12:15:52PM +1100, Simon Horman wrote:
> > Hi Dave, Hi Jarek,

Hi Simon,

> > I know that you guys were/are playing around a lot in here, but
> > unfortunately I think that "pkt_sched: Always use q->requeue in
> > dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
> > introduced a performance regression for HTB.
...
> > The test machine with the tc rules and udp-sending processes
> > has two Intel Xeon Quad-cores running at 1.86GHz. The kernel
> > is SMP x86_64.
> 
> With the following patch (basically a reversal of ""pkt_sched: Always use
> q->requeue in dev_requeue_skb()" forward ported to the current
> net-next-2.6 tree (tcp: Respect SO_RCVLOWAT in tcp_poll()), I get some
> rather nice numbers (IMHO).
> 
> 10194: 666780666bits/s 666Mbits/s
> 10197: 141154197bits/s 141Mbits/s
> 10196: 141023090bits/s 141Mbits/s
> -----------------------------------
> total: 948957954bits/s 948Mbits/s
> 
> I'm not sure what evil things this patch does to other aspects
> of the qdisc code.

I'd like to establish this too. This patch was meant to remove some
other problems possibly the simplest way. Maybe it's too simple.
Anyway, it's kind of RFC, so the rest of the requeuing code is left
unchanged, just for easy revoking like below. But first we should
try to understand this more.

So, thanks for testing and reporting this. (BTW, what network card
do you use and is there multiqueuing on?)

Jarek P.

> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 31f6b61..d2e0da6 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -44,7 +44,10 @@ static inline int qdisc_qlen(struct Qdisc *q)
>  
>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  {
> -	q->gso_skb = skb;
> +	if (unlikely(skb->next))
> +		q->gso_skb = skb;
> +	else
> +		q->ops->requeue(skb, q);
>  	__netif_schedule(q);
>  
>  	return 0;
