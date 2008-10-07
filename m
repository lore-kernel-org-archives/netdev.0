From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Tue, 7 Oct 2008 15:51:47 +1100
Message-ID: <20081007045145.GA23883@verge.net.au>
References: <20081007011551.GA28408@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33920 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbYJGEvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 00:51:49 -0400
Content-Disposition: inline
In-Reply-To: <20081007011551.GA28408@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 12:15:52PM +1100, Simon Horman wrote:
> Hi Dave, Hi Jarek,
> 
> I know that you guys were/are playing around a lot in here, but
> unfortunately I think that "pkt_sched: Always use q->requeue in
> dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
> introduced a performance regression for HTB.
> 
> My tc rules are below, but in a nutshell I have 3 leaf classes.
> One with a rate of 500Mbit/s and the other two with 100Mbit/s.
> The ceiling for all classes is 1Gb/s and that is also both
> the rate and ceiling for the parent class.
> 
>                           [ rate=1Gbit/s ]
>                           [ ceil=1Gbit/s ]
>                                  |
>             +--------------------+--------------------+
>             |                    |                    |
>      [ rate=500Mbit/s ]   [ rate=100Mbit/s ]   [ rate=100Mbit/s ]
>      [ ceil=  1Gbit/s ]   [ ceil=100Mbit/s ]   [ ceil=  1Gbit/s ]
> 
> The tc rules have an extra class for all other traffic,
> but its idle, so I left it out of the diagram.
> 
> In order to test this I set up filters so that traffic to
> each of port 10194, 10196 and 10197 is directed to one of the leaf-classes.
> I then set up a process on the same host for each port sending
> UDP as fast as it could in a while() { send(); } loop. On another
> host I set up processes listening for the UDP traffic in a
> while () { recv(); } loop. And I measured the results.
> 
> ( I should be able to provide the code used for testing,
>   but its not mine and my colleague who wrote it is off
>   with the flu today. )
> 
> Prior to this patch the result looks like this:
> 
> 10194: 545134589bits/s 545Mbits/s
> 10197: 205358520bits/s 205Mbits/s
> 10196: 205311416bits/s 205Mbits/s
> -----------------------------------
> total: 955804525bits/s 955Mbits/s
> 
> And after the patch the result looks like this:
> 10194: 384248522bits/s 384Mbits/s
> 10197: 284706778bits/s 284Mbits/s
> 10196: 288119464bits/s 288Mbits/s
> -----------------------------------
> total: 957074765bits/s 957Mbits/s
> 
> There is some noise in these results, but I think that its clear
> that before the patch all leaf-classes received at least their rate,
> and after the patch the rate=500Mbit/s class received much less than
> its rate. This I believe is a regression.
> 
> I do not believe that this happens at lower bit rates, for instance
> if you reduce the ceiling and rate of all classes by a factor of 10.
> I can produce some numbers on that if you want them.
> 
> The test machine with the tc rules and udp-sending processes
> has two Intel Xeon Quad-cores running at 1.86GHz. The kernel
> is SMP x86_64.

With the following patch (basically a reversal of ""pkt_sched: Always use
q->requeue in dev_requeue_skb()" forward ported to the current
net-next-2.6 tree (tcp: Respect SO_RCVLOWAT in tcp_poll()), I get some
rather nice numbers (IMHO).

10194: 666780666bits/s 666Mbits/s
10197: 141154197bits/s 141Mbits/s
10196: 141023090bits/s 141Mbits/s
-----------------------------------
total: 948957954bits/s 948Mbits/s

I'm not sure what evil things this patch does to other aspects
of the qdisc code.

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 31f6b61..d2e0da6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,7 +44,10 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	q->gso_skb = skb;
+	if (unlikely(skb->next))
+		q->gso_skb = skb;
+	else
+		q->ops->requeue(skb, q);
 	__netif_schedule(q);
 
 	return 0;
