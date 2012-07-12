From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] ipv4: Pull redirect instantiation out into a
 helper function.
Date: Thu, 12 Jul 2012 01:59:33 -0700
Message-ID: <1342083573.7969.3.camel@joe2Laptop>
References: <20120712.011056.1351038732588424856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42859 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932106Ab2GLI7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 04:59:34 -0400
In-Reply-To: <20120712.011056.1351038732588424856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 01:10 -0700, David Miller wrote:
[]
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c

just a trivial style note:

> @@ -1271,6 +1271,26 @@ static void rt_del(unsigned int hash, struct rtable *rt)
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>  }
>  
> +static void ip_do_redirect(struct rtable *rt, __be32 old_gw, __be32 new_gw)
> +{
> +	struct neighbour *n;
> +
> +	if (rt->rt_gateway != old_gw)
> +		return;
> +
> +	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
> +	if (n) {

Might as well use
	if (!n)
		return;
and save an indent level.

> +		if (!(n->nud_state & NUD_VALID)) {
> +			neigh_event_send(n, NULL);
> +		} else {
> +			rt->rt_gateway = new_gw;
> +			rt->rt_flags |= RTCF_REDIRECTED;
> +			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
> +		}
> +		neigh_release(n);
> +	}
> +}
> +
