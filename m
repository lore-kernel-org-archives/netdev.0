From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] bridge: fix multicast router rlist endless loop
Date: Tue, 9 Jun 2015 23:12:50 +0800
Message-ID: <20150609151250.GA15284@gondor.apana.org.au>
References: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <razor@blackwall.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52684 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbFIPM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 11:12:56 -0400
Content-Disposition: inline
In-Reply-To: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 02:32:28AM -0700, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <razor@blackwall.org>
> 
> Since the addition of sysfs multicast router support if one set
> multicast_router to "2" more than once, then the port would be added to the
> hlist every time and could end up linking to itself and thus causing an
> endless loop for rlist walkers.
> So to reproduce just do:
> echo 2 > multicast_router; echo 2 > multicast_router;
> in a bridge port and let some igmp traffic flow, for me it hangs up
> in br_multicast_flood().
> Fix this by removing the "val < 2" check, and just do the hlist_del
> always.
> We can remove the "!hlist_unhashed" check because it's already done by
> hlist_del_init_rcu(), in fact this can also be done for
> br_multicast_disable_port() but that is net-next material.
> The reason this didn't happen before the addition of multicast_router
> sysfs entries is because there's a !hlist_unhashed check that prevents
> it.
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
> Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")

Good catch!

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 22fd0419b314..ecdd13512320 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1993,8 +1993,7 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
>  		p->multicast_router = val;
>  		err = 0;
>  
> -		if (val < 2 && !hlist_unhashed(&p->rlist))
> -			hlist_del_init_rcu(&p->rlist);
> +		hlist_del_init_rcu(&p->rlist);

This should work but removing it and readding seems strange.

How about moving the hlist_unhashed test that's currently in
br_multicast_mark_router into br_multicast_add_router instead?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
