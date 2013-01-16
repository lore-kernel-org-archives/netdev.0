From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Remove output route check in ipv4_mtu
Date: Wed, 16 Jan 2013 10:58:13 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301160915030.1621@ja.ssi.bg>
References: <20130116063645.GC18940@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54530 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932108Ab3APIzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 03:55:25 -0500
In-Reply-To: <20130116063645.GC18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 16 Jan 2013, Steffen Klassert wrote:

> The output route check was introduced with git commit 261663b0
> (ipv4: Don't use the cached pmtu informations for input routes)
> during times when we cached the pmtu informations on the
> inetpeer. Now the pmtu informations are back in the routes,
> so this check is obsolete. It also had some unwanted side effects,
> as reported by Timo Teras and Lukas Tribus.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 844a9ef..6e4a89c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1120,7 +1120,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
>  	if (!mtu || time_after_eq(jiffies, rt->dst.expires))
>  		mtu = dst_metric_raw(dst, RTAX_MTU);
>  
> -	if (mtu && rt_is_output_route(rt))
> +	if (mtu)
>  		return mtu;

	This fix looks good to me. But I see that we
have another problem here. doc/ip-cref.tex in iproute2
claims that a locked MTU value has priority and
PMTU should not be considered.

	IIRC, rt_pmtu is valid only for output routes but
we do not check the lock flag here. What about such
variant:

static unsigned int ipv4_mtu(const struct dst_entry *dst)
{
	const struct rtable *rt = (const struct rtable *) dst;
	unsigned int mtu = rt->rt_pmtu;

	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
		mtu = dst_metric_raw(dst, RTAX_MTU);
		if (!mtu) {
			mtu = dst->dev->mtu;
			if (rt->rt_uses_gateway && mtu > 576)
				mtu = 576;
		}
	} else if (!mtu || time_after_eq(jiffies, rt->dst.expires)) {
		mtu = dst_metric_raw(dst, RTAX_MTU);
		if (!mtu)
			mtu = dst->dev->mtu;
	}
	if (mtu > IP_MAX_MTU)
		mtu = IP_MAX_MTU;

	return mtu;
}

	I.e. order becomes:

mtu lock non-zero => fixed fib_mtu
mtu lock 0 => device MTU, up to 576 if via GW, ignore PMTU
PMTU (output routes)
mtu non-zero => fib_mtu
device MTU

	Also, it seems __ip_rt_update_pmtu should start
with such dst_metric_locked(dst, RTAX_MTU) check?

>  	mtu = dst->dev->mtu;
> -- 
> 1.7.9.5

Regards

--
Julian Anastasov <ja@ssi.bg>
