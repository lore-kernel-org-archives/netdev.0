From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Wed, 28 Apr 2010 09:51:14 +0800
Message-ID: <20100428015114.GB12165@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuX-00021m-Bq@gondolin.me.apana.org.au> <20100427101311.2f445227@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:36429 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755749Ab0D1BvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 21:51:23 -0400
Content-Disposition: inline
In-Reply-To: <20100427101311.2f445227@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 10:13:11AM -0700, Stephen Hemminger wrote:
> I prefer that the hlist be only accessed through the hlist macro
> objects. Explicit twiddling of links (especially with RCU) exposes
> the code to future bugs.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/net/bridge/br_multicast.c	2010-04-27 09:54:02.180531924 -0700
> +++ b/net/bridge/br_multicast.c	2010-04-27 10:07:19.188688664 -0700
> @@ -1041,21 +1041,21 @@ static int br_ip6_multicast_mld2_report(
>  static void br_multicast_add_router(struct net_bridge *br,
>  				    struct net_bridge_port *port)
>  {
> -	struct hlist_node *p;
> -	struct hlist_node **h;
> +	struct net_bridge_port *p;
> +	struct hlist_node *n, *last = NULL;
>  
> -	for (h = &br->router_list.first;
> -	     (p = *h) &&
> -	     (unsigned long)container_of(p, struct net_bridge_port, rlist) >
> -	     (unsigned long)port;
> -	     h = &p->next)
> -		;
> -
> -	port->rlist.pprev = h;
> -	port->rlist.next = p;
> -	rcu_assign_pointer(*h, &port->rlist);
> -	if (p)
> -		p->pprev = &port->rlist.next;
> +	hlist_for_each_entry(p, n, &br->router_list, rlist) {
> +		if ((unsigned long) port >= (unsigned long) p) {
> +			hlist_add_before_rcu(n, &port->rlist);
> +			return;
> +		}
> +		last = n;
> +	}
> +
> +	if (last)
> +		hlist_add_after_rcu(last, &port->rlist);
> +	else
> +		hlist_add_head_rcu(&port->rlist, &br->router_list);
>  }

Thanks Stephen, this looks good to me too.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
