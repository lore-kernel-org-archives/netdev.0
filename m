From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 1/3] ipv4: properly refresh rtable entries on
 pmtu/redirect events
Date: Tue, 28 May 2013 11:25:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305281117190.1693@ja.ssi.bg>
References: <20130527.233844.2081972819091665848.davem@davemloft.net> <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="280144257-231941632-1369729555=:1693"
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52173 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933383Ab3E1IWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:22:20 -0400
In-Reply-To: <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--280144257-231941632-1369729555=:1693
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Tue, 28 May 2013, Timo Teräs wrote:

> This reverts commit 05ab86c5 (xfrm4: Invalidate all ipv4 routes on
> IPsec pmtu events). Flushing all cached entries is not needed.
> 
> Instead, invalidate only the related next hop dsts to recheck for
> the added next hop exception where needed. This also fixes a subtle
> race due to bumping generation id's before updating the pmtu.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Timo Teräs <timo.teras@iki.fi>
> ---

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 550781a..561a378 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -594,11 +594,25 @@ static inline u32 fnhe_hashfun(__be32 daddr)
>  	return hval & (FNHE_HASH_SIZE - 1);
>  }
>  
> +static void fill_route_from_fnhe(struct rtable *rt, struct fib_nh_exception *fnhe)
> +{
> +	rt->rt_pmtu = fnhe->fnhe_pmtu;
> +	rt->dst.expires = fnhe->fnhe_expires;

	The 'if (time_before' ... dst_set_expires() logic from
rt_bind_exception() is removed, may be it should be moved here,
i.e. fnhe_pmtu should be ignored if expired.

> @@ -627,8 +641,12 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
>  			fnhe->fnhe_gw = gw;
>  		if (pmtu) {
>  			fnhe->fnhe_pmtu = pmtu;
> -			fnhe->fnhe_expires = expires;
> +			fnhe->fnhe_expires = max(1UL, expires);
>  		}
> +		/* Update all cached dsts too */
> +		rt = rcu_dereference(fnhe->fnhe_rth);

	rt = rcu_dereference_protected(fnhe->fnhe_rth, 1);

Regards

--
Julian Anastasov <ja@ssi.bg>
--280144257-231941632-1369729555=:1693--
