From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 1/2] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Mon, 9 Feb 2015 11:26:21 +0100
Message-ID: <20150209102620.GC13046@secunet.com>
References: <54C78B8D.1070104@huawei.com>
 <20150128121026.GM13046@secunet.com>
 <20150128121150.GN13046@secunet.com>
 <20150205235628.GA1916791@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60123 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759491AbbBIK02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:26:28 -0500
Content-Disposition: inline
In-Reply-To: <20150205235628.GA1916791@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2015 at 03:56:29PM -0800, Martin Lau wrote:
> On Wed, Jan 28, 2015 at 01:11:51PM +0100, Steffen Klassert wrote:
> > We currently don't clone host routes before we use them.
> > If a pmtu event is received on such a route, it gets
> > an expires value. As soon as the expiration time is
> > elapsed, the route is deleted. As a result, the host
> > is not reachable any more.
> > 
> > We fix this by cloning host routes if they are gatewayed,
> > i.e. if pmtu events can happen.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv6/route.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index c910831..3e864e7 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -961,7 +961,7 @@ redo_rt6_select:
> >  
> >  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> >  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> > -	else if (!(rt->dst.flags & DST_HOST))
> > +	else if (!(rt->dst.flags & DST_HOST) || (rt->rt6i_flags & RTF_GATEWAY))
> >  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> The del path may also require changes.  I am thinking:
> 1. Create a /128 via gateway route
> 2. Send some traffic and RTF_CACHE rt is created
> 3. Delete the /128 route by ip route del.  I suspect the RTF_CACHE route may be
>    deleted and the route added in (1) stays.

Good point.

Both routes are on the same fib node. The cached one has the better
metric, so I guess this one will be found and deleted.

I'll check this. Thanks for the hint!
