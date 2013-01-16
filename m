From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv4: Remove output route check in ipv4_mtu
Date: Wed, 16 Jan 2013 10:59:09 +0100
Message-ID: <20130116095909.GD18940@secunet.com>
References: <20130116063645.GC18940@secunet.com>
 <alpine.LFD.2.00.1301160915030.1621@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38531 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756483Ab3APJ7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:59:12 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1301160915030.1621@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2013 at 10:58:13AM +0200, Julian Anastasov wrote:
> 
> 	This fix looks good to me. But I see that we
> have another problem here. doc/ip-cref.tex in iproute2
> claims that a locked MTU value has priority and
> PMTU should not be considered.
> 
> 	IIRC, rt_pmtu is valid only for output routes but
> we do not check the lock flag here. What about such
> variant:
> 
> static unsigned int ipv4_mtu(const struct dst_entry *dst)
> {
> 	const struct rtable *rt = (const struct rtable *) dst;
> 	unsigned int mtu = rt->rt_pmtu;
> 
> 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
> 		mtu = dst_metric_raw(dst, RTAX_MTU);
> 		if (!mtu) {
> 			mtu = dst->dev->mtu;
> 			if (rt->rt_uses_gateway && mtu > 576)
> 				mtu = 576;
> 		}
> 	} else if (!mtu || time_after_eq(jiffies, rt->dst.expires)) {
> 		mtu = dst_metric_raw(dst, RTAX_MTU);
> 		if (!mtu)
> 			mtu = dst->dev->mtu;
> 	}
> 	if (mtu > IP_MAX_MTU)
> 		mtu = IP_MAX_MTU;
> 
> 	return mtu;
> }
> 
> 	I.e. order becomes:
> 
> mtu lock non-zero => fixed fib_mtu
> mtu lock 0 => device MTU, up to 576 if via GW, ignore PMTU
> PMTU (output routes)
> mtu non-zero => fib_mtu
> device MTU

If this is the desired order, I'm fine with the above variant.

> 
> 	Also, it seems __ip_rt_update_pmtu should start
> with such dst_metric_locked(dst, RTAX_MTU) check?
> 

Not absolutely sure what you want to do if the mtu is locked.
But if you don't want to genetate a nh exception and don't update
rt->rt_pmtu in this case, rt->rt_pmtu is never set on routes with
locked mtu. We probably would not need to change ipv4_mtu() to the
above variant.
