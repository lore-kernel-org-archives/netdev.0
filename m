From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/4] bridge: multicast port group RCU fix
Date: Wed, 28 Apr 2010 11:07:09 +0800
Message-ID: <20100428030709.GA12910@gondor.apana.org.au>
References: <20100428010103.386761596@vyatta.com> <20100428010336.237294971@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35619 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754118Ab0D1DHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 23:07:18 -0400
Content-Disposition: inline
In-Reply-To: <20100428010336.237294971@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 06:01:06PM -0700, Stephen Hemminger wrote:
> The recently introduced bridge mulitcast port group list was only
> partially using RCU correctly. It was missing rcu_dereference()
> and missing the necessary barrier on deletion.
> 
> The code should have used one of the standard list methods (list or hlist)
> instead of open coding a RCU based link list.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/bridge/br_forward.c	2010-04-27 17:51:27.909588950 -0700
> +++ b/net/bridge/br_forward.c	2010-04-27 17:53:18.790721091 -0700
> @@ -217,7 +217,7 @@ static void br_multicast_flood(struct ne
>  	prev = NULL;
>  
>  	rp = rcu_dereference(br->router_list.first);
> -	p = mdst ? mdst->ports : NULL;
> +	p = mdst ? rcu_dereference(mdst->ports) : NULL;
>  	while (p || rp) {
>  		lport = p ? p->port : NULL;
>  		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
> @@ -231,7 +231,7 @@ static void br_multicast_flood(struct ne
>  			goto out;
>  
>  		if ((unsigned long)lport >= (unsigned long)port)
> -			p = p->next;
> +			p = rcu_dereference(p->next);
>  		if ((unsigned long)rport >= (unsigned long)port)
>  			rp = rcu_dereference(rp->next);
>  	}

Thanks for catching this!

> --- a/net/bridge/br_multicast.c	2010-04-27 17:51:31.509593914 -0700
> +++ b/net/bridge/br_multicast.c	2010-04-27 17:52:48.209243982 -0700
> @@ -259,7 +259,7 @@ static void br_multicast_del_pg(struct n
>  		if (p != pg)
>  			continue;
>  
> -		*pp = p->next;
> +		rcu_assign_pointer(*pp, p->next);

But this is bogus.  br_multicast_del_pg is removing an entry from
the RCU list.

You only need write barriers when you're putting a new entry in
it, and only if there is no other barrier between the code filling
in the new entry and the line adding it to the RCU list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
