From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 1/3] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Wed, 1 Apr 2015 10:09:45 +0200
Message-ID: <20150401080944.GF20559@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
 <20150205072125.GY13046@secunet.com>
 <54EFD87A.5080907@huawei.com>
 <20150330103210.GI3311@secunet.com>
 <20150330103313.GJ3311@secunet.com>
 <20150330182433.GC2303816@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: shengyong <shengyong1@huawei.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <yangyingliang@huawei.com>,
	<hannes@redhat.com>, Kernel Team <Kernel-team@fb.com>
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37463 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701AbbDAIJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 04:09:53 -0400
Content-Disposition: inline
In-Reply-To: <20150330182433.GC2303816@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 11:24:33AM -0700, Martin Lau wrote:
> On Mon, Mar 30, 2015 at 12:33:13PM +0200, Steffen Klassert wrote:
> > ---
> >  net/ipv6/route.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 4688bd4..4318626 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -961,7 +961,7 @@ redo_rt6_select:
> >  
> >  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> >  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> > -	else if (!(rt->dst.flags & DST_HOST))
> > +	else if (!(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
> >  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> I suspect the nrt and rt will share the same inetpeer.  Hence, after the nrt is
> removed, the MTU (obtained from PMTU update) will stay.

I used a route with default metrics in my tests, therefore the
merics were copied for nrt. But if the route has a mtu set,
the metrics are not copied. So we overwrite the route mtu
with the pmtu value. Maybe we should make sure to always
copy the metrics if we do a pmtu update.

Something like this:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e0c6ac9..675bc42 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1182,6 +1182,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 
+		dst_cow_metrics_generic(dst, dst->_metrics);
 		dst_metric_set(dst, RTAX_MTU, mtu);
 		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}

This could fix the pmtu case, but what are we going to do if
we have multiple routes with different mtu values to the same
host? Adding a second hostroute will overwrite the mtu value
of the first hostroute.

This reminds me at the times when we removed the ipv4 routing cache.
The first approach to handle pmtu updates was to cache the pmtu
values at the inetpeer, but we never got it to work. We swiched
then to use exceptional routes in this case.
