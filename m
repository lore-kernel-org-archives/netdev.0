From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Tue, 7 Oct 2008 12:20:52 +0000
Message-ID: <20081007122052.GA4328@ff.dom.local>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:3400 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbYJGMVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:21:02 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1019846eyi.37
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 05:21:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081007045145.GA23883@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 03:51:47PM +1100, Simon Horman wrote:
> On Tue, Oct 07, 2008 at 12:15:52PM +1100, Simon Horman wrote:
> > Hi Dave, Hi Jarek,
> > 
> > I know that you guys were/are playing around a lot in here, but
> > unfortunately I think that "pkt_sched: Always use q->requeue in
> > dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
> > introduced a performance regression for HTB.

Since this looks to me as possibly theoretical problem I added
Martin and Patrick to Cc.

> > 
> > My tc rules are below, but in a nutshell I have 3 leaf classes.
> > One with a rate of 500Mbit/s and the other two with 100Mbit/s.
> > The ceiling for all classes is 1Gb/s and that is also both
> > the rate and ceiling for the parent class.
> > 
> >                           [ rate=1Gbit/s ]
> >                           [ ceil=1Gbit/s ]
> >                                  |
> >             +--------------------+--------------------+
> >             |                    |                    |
> >      [ rate=500Mbit/s ]   [ rate=100Mbit/s ]   [ rate=100Mbit/s ]
> >      [ ceil=  1Gbit/s ]   [ ceil=100Mbit/s ]   [ ceil=  1Gbit/s ]

?!       [ ceil=  1Gbit/s ]   [ ceil=1Gbit/s ]     [ ceil=  1Gbit/s ]

> > 
> > The tc rules have an extra class for all other traffic,
> > but its idle, so I left it out of the diagram.
> > 
> > In order to test this I set up filters so that traffic to
> > each of port 10194, 10196 and 10197 is directed to one of the leaf-classes.
> > I then set up a process on the same host for each port sending
> > UDP as fast as it could in a while() { send(); } loop. On another
> > host I set up processes listening for the UDP traffic in a
> > while () { recv(); } loop. And I measured the results.
> > 
> > ( I should be able to provide the code used for testing,
> >   but its not mine and my colleague who wrote it is off
> >   with the flu today. )
> > 
> > Prior to this patch the result looks like this:
> > 
> > 10194: 545134589bits/s 545Mbits/s
> > 10197: 205358520bits/s 205Mbits/s
> > 10196: 205311416bits/s 205Mbits/s
> > -----------------------------------
> > total: 955804525bits/s 955Mbits/s
> > 
> > And after the patch the result looks like this:
> > 10194: 384248522bits/s 384Mbits/s
> > 10197: 284706778bits/s 284Mbits/s
> > 10196: 288119464bits/s 288Mbits/s
> > -----------------------------------
> > total: 957074765bits/s 957Mbits/s
> > 

So, in short, the results with requeuing off show the first class
doesn't get its rate while the others can borrow.

My first (maybe wrong) idea is that requeuing could be used here for
something it wasn't probably meant to. The scenario could be like this:
the first (and most privileged) class is sending until the card limit,
and when the xmit is stopped and requeuing on, it slows the others
(while it has to wait anyway) with requeuing procedures plus gets
"additional" packet in its queue.

In the "requeuing off" case there should be a bit more time for others
and each packet seen only once.

Since it looks like HTB was lending unused rate, it had to try the first
class first, so if it didn't use this, probably there were not enough
packets in its queue, and as mentioned above, requeuing code could help
to get them, and so to prevent lending to others, when there is not
enough enqueuing in the meantime.

So, maybe my diagnose is totally wrong, but there are the questions:

1) Is HTB or other similar scheduling code expected to limit correctly
   while we substantially overlimit (since requeuing should be used so
   much)?
2) Should requeuing be considered as such important factor of
   controlling the rates?

I've some doubts it should work like this.

Jarek P.


> > There is some noise in these results, but I think that its clear
> > that before the patch all leaf-classes received at least their rate,
> > and after the patch the rate=500Mbit/s class received much less than
> > its rate. This I believe is a regression.
> > 
> > I do not believe that this happens at lower bit rates, for instance
> > if you reduce the ceiling and rate of all classes by a factor of 10.
> > I can produce some numbers on that if you want them.
> > 
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


-------------------------

tc qdisc del dev eth0 root

tc qdisc add dev eth0 root handle 1: htb default 10 r2q 10000

tc class add dev eth0 parent 1:  classid 1:1   htb \
	rate 1Gbit ceil 1Gbit

tc class add dev eth0 parent 1:1 classid 1:10 htb \
	rate 1Gbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:11 htb \
	rate 500Mbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:12 htb \
	rate 100Mbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:13 htb \
	rate 100Mbit ceil 1Gbit

tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10194 0xffff flowid 1:11
tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10196 0xffff flowid 1:12
tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10197 0xffff flowid 1:13

