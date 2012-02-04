From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 4 Feb 2012 17:48:50 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
References: <4F2B7DF1.5050303@oktetlabs.ru>  <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1328358402.2731.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1741720319-1328370532=:1496"
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41191 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069Ab2BDPsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 10:48:15 -0500
In-Reply-To: <1328358402.2731.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1741720319-1328370532=:1496
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 4 Feb 2012, Eric Dumazet wrote:

> Le vendredi 03 février 2012 à 16:15 +0100, Eric Dumazet a écrit :
> 
> > We omit to send RST packet in tcp_v4_send_reset()
> > 
> > because of this test :
> > 
> > if (skb_rtable(skb)->rt_type != RTN_LOCAL)
> > 	return
> > 
> > At this point rt_type is RTN_UNICAST
> 
> Here is the fix, thanks again !
> 
> [PATCH] ipv4: fix a route regression
> 
> commit 813b3b5db83 (ipv4: Use caller's on-stack flowi as-is in output
> route lookups.) added a regression.
> 
> Some callers of ip_route_output_slow() assumed their flow argument was
> constant.

	Problem with ip_route_connect?

> ip_route_output_slow() must leave with original content of various
> fields.

	There were attempts to provide more results for
xfrm purposes:

http://marc.info/?t=132251214300008&r=1&w=2

	So, may be we need to go in this direction, not
to restore original values but to provide more results.
And callers should initialize all input arguments.

> Thanks to Yurij M. Plotnikov for providing a bug report including a
> program to reproduce the problem.
> 
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/route.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index bcacf54..0f63240 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2633,19 +2633,15 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
>  	unsigned int flags = 0;
>  	struct fib_result res;
>  	struct rtable *rth;
> -	__be32 orig_daddr;
> -	__be32 orig_saddr;
> -	int orig_oif;
> +	__be32 orig_daddr = fl4->daddr;
> +	__be32 orig_saddr = fl4->saddr;
> +	int orig_oif = fl4->flowi4_oif;
>  
>  	res.fi		= NULL;
>  #ifdef CONFIG_IP_MULTIPLE_TABLES
>  	res.r		= NULL;
>  #endif
>  
> -	orig_daddr = fl4->daddr;
> -	orig_saddr = fl4->saddr;
> -	orig_oif = fl4->flowi4_oif;
> -
>  	fl4->flowi4_iif = net->loopback_dev->ifindex;
>  	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
>  	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
> @@ -2816,6 +2812,9 @@ make_route:
>  
>  out:
>  	rcu_read_unlock();
> +	fl4->flowi4_oif = orig_oif;
> +	fl4->daddr = orig_daddr;
> +	fl4->saddr = orig_saddr;

	flowi4_tos is missing from this list but anyways,
it looks wrong because __ip_route_output_key returns data
in saddr and daddr, such change will break source address
autoselection and destination address autoselection. That is
what ip_route_connect is trying to do. May be
ip_route_connect should be fixed instead?

>  	return rth;
>  }

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1741720319-1328370532=:1496--
