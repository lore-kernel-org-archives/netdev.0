From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Thu, 18 Mar 2010 20:11:46 +0800
Message-ID: <20100318121146.GA13307@gondor.apana.org.au>
References: <1268912902-27050-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52313 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751035Ab0CRMLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 08:11:49 -0400
Content-Disposition: inline
In-Reply-To: <1268912902-27050-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 01:48:22PM +0200, Timo Teras wrote:
> Xfrm_dst keeps a reference to ipv4 rtable entries on each
> cached bundle. The only we to renew xfrm_dst when the underlying
> route has changed, is to implement dst_check for this. This is
> what ipv6 side does too.
> 
> The problems started after 87c1e12b5eeb7b30b4b41291bef8e0b41fc3dde9
> which fixed a bug causing xfrm_dst to not get reused, until that all
> lookups always generated new xfrm_dst with new route reference
> and path mtu worked. But after the fix, the old routes started
> to get reused even after they were expired causing pmtu to break
> (well it would occationally work if the rtable gc has ran recently
> and marked the route obsolete causing dst_check to get called).
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

I completely agree with your assessment and patch.  The null
dst_check only worked when we purged IPv4 route cache entries
synchronously.  So this should've be done when asynchronous
deletion through genid was introduced.

> @@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
>  
>  static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
>  {
> -	return NULL;
> +	if (dst && dst->dev && rt_is_expired((struct rtable *) dst))
> +		return NULL;
> +	return dst;
>  }

Can dst->dev ever be NULL? I'm pretty sure that we disallow that
from ever happening through the use of the loopback device.  A
quick grep also fails to find any other dst->dev NULL checks in
this file.

Otherwise

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
