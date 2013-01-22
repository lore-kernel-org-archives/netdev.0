From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/2] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Tue, 22 Jan 2013 09:42:23 +0100
Message-ID: <20130122084223.GC9147@secunet.com>
References: <20130121115911.GE30530@secunet.com>
 <alpine.LFD.2.00.1301212245170.1886@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33074 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263Ab3AVIm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 03:42:26 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1301212245170.1886@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 11:18:27PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 21 Jan 2013, Steffen Klassert wrote:
> 
> > +{
> > +	const struct iphdr *iph = (const struct iphdr *) skb->data;
> > +	struct flowi4 fl4;
> > +	struct rtable *rt;
> > +	struct dst_entry *dst;
> > +
> > +	bh_lock_sock(sk);
> > +	rt = (struct rtable *) __sk_dst_get(sk);
> 
> 	I just saw another problem, sorry that
> I missed it the first time. Here __sk_dst_get
> does not get reference...
> 

Somehow I thought that I can reuse the the refcount
from the socket, but __sk_dst_set() will release it
when we continue to use the same route.

> > +
> > +	if (sock_owned_by_user(sk) || !rt) {
> > +		__ipv4_sk_update_pmtu(skb, sk, mtu);
> > +		goto out;
> > +	}
> > +
> > +	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
> > +
> > +	if (!__sk_dst_check(sk, 0)) {
> > +		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
> > +		if (IS_ERR(rt))
> > +			goto out;
> 
> 		but here rt->dst comes with reference.
> 
> > +	}
> 
> 	May be here we can use 'else dst_hold(&rt->dst);' ?
> It is needed for __sk_dst_set.
> 
> > +
> > +	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
> > +
> > +	dst = dst_check(&rt->dst, 0);
> > +	if (!dst) {
> 
> 		dst_release(&rt->dst);
> 
> > +		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
> > +		if (IS_ERR(rt))
> > +			goto out;
> > +
> > +		dst = &rt->dst;
> 
> 		Remove above line...
> 
> > +	}
> > +
> 
> 	and use here __sk_dst_set(sk, &rt->dst) instead:
> 
> > +	 __sk_dst_set(sk, dst);
> 
> 	Another variant is to remember with flag 'new_rt'
> that we should call __sk_dst_set, eg. when rt comes from
> ip_route_output_flow. By this way we can avoid some of
> the dst_hold/dst_release calls if sk_dst_cache is not
> changed. IIRC, according to sk_dst_check, dst_check can
> not return different dst from the ->check method.
> 

With this variant, we also need to check the new_rt flag
before we call the dst_release() function you mentioned
above, right?

I think we should avoid refcounts whenever we can,
so I prefer this variant. I'll do a patch.

Thanks!
