From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Thu, 30 Nov 2006 16:48:27 -0800 (PST)
Message-ID: <20061130.164827.57154936.davem@davemloft.net>
References: <20061124143839.8559449b.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:63977
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031653AbWLAAsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:48:25 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061124143839.8559449b.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 24 Nov 2006 14:38:39 +0900

What is going on here?

> +			/* Without this, the atomic inc below segfaults */
> +			if (encap_family == AF_INET6) {
> +				rt->peer = NULL;
> +				rt_bind_peer(rt,1);
> +			}
 ...
> -		dst_prev->output	= xfrm4_output;
> +		if (dst_prev->xfrm->props.family == AF_INET)
> +			dst_prev->output = xfrm4_output;
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +		else
> +			dst_prev->output = xfrm6_output;
> +#endif
>  		if (rt->peer)
>  			atomic_inc(&rt->peer->refcnt);

If it's non-NULL and you get a segfault for atomic_inc() that
means there is garbage here, and it seems that if you're
setting it to NULL explicitly then it's just a workaround
for whatever problem is causing it to be non-NULL to begin
with.

What is putting a non-valid pointer value there?  Is this an IPV6 or
IPSEC dst route by chance?  If so, that makes this change really
wrong, and we are corrupting the route by running rt_bind_peer() on
it.  rt_bind_peer() is only valid on ipv4 route entries.
