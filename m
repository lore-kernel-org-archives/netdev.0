From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Thu, 16 Dec 2010 22:17:45 +0100
Message-ID: <20101216211744.GA2191@del.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57960 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923Ab0LPVTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 16:19:19 -0500
Received: by wwi17 with SMTP id 17so794596wwi.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 13:19:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292428252.3427.342.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 04:50:52PM +0100, Eric Dumazet wrote:
> In commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in ingress
> netem timestamps.), Jarek added a logic to refresh timestamps of
> ingressed packets going through netem.
> 
> I believe we should generalize this, forcing a refresh of timestamps in
> dev_queue_xmit_nit() for all ingress packets, whatever qdisc/class they
> used before being delivered.
> 
> This way, we can have a good idea when packets are delivered to our
> stack (tcpdump -i ifb0), while a tcpdump on original device gives
> timestamps right before ingressing.

I don't think we should do it. IMHO netem on ingress is a special case,
obviously for testing, and otherwise the real (first) timestamp might
be valuable for some users.

Jarek P.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c        |    2 +-
>  net/sched/sch_netem.c |    8 --------
>  2 files changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d28b3a0..a2846f8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1506,7 +1506,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  	struct packet_type *ptype;
>  
>  #ifdef CONFIG_NET_CLS_ACT
> -	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
> +	if (!skb->tstamp.tv64 || (G_TC_FROM(skb->tc_verd) & AT_INGRESS))
>  		net_timestamp_set(skb);
>  #else
>  	net_timestamp_set(skb);
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index e5593c0..1c29cc0 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -281,14 +281,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
>  			if (unlikely(!skb))
>  				return NULL;
>  
> -#ifdef CONFIG_NET_CLS_ACT
> -			/*
> -			 * If it's at ingress let's pretend the delay is
> -			 * from the network (tstamp will be updated).
> -			 */
> -			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
> -				skb->tstamp.tv64 = 0;
> -#endif
>  			pr_debug("netem_dequeue: return skb=%p\n", skb);
>  			sch->q.qlen--;
>  			return skb;
> 
> 
