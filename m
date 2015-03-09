From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 1/2] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Mon, 9 Mar 2015 10:00:01 +0100
Message-ID: <20150309090001.GB3311@secunet.com>
References: <54C78B8D.1070104@huawei.com>
 <20150128121026.GM13046@secunet.com>
 <20150128121150.GN13046@secunet.com>
 <20150205235628.GA1916791@devbig242.prn2.facebook.com>
 <20150209102620.GC13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46870 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbbCIJAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 05:00:05 -0400
Content-Disposition: inline
In-Reply-To: <20150209102620.GC13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2015 at 11:26:20AM +0100, Steffen Klassert wrote:
> On Thu, Feb 05, 2015 at 03:56:29PM -0800, Martin Lau wrote:
> > On Wed, Jan 28, 2015 at 01:11:51PM +0100, Steffen Klassert wrote:
> > > We currently don't clone host routes before we use them.
> > > If a pmtu event is received on such a route, it gets
> > > an expires value. As soon as the expiration time is
> > > elapsed, the route is deleted. As a result, the host
> > > is not reachable any more.
> > > 
> > > We fix this by cloning host routes if they are gatewayed,
> > > i.e. if pmtu events can happen.
> > > 
> > > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > > ---
> > >  net/ipv6/route.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > > index c910831..3e864e7 100644
> > > --- a/net/ipv6/route.c
> > > +++ b/net/ipv6/route.c
> > > @@ -961,7 +961,7 @@ redo_rt6_select:
> > >  
> > >  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> > >  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> > > -	else if (!(rt->dst.flags & DST_HOST))
> > > +	else if (!(rt->dst.flags & DST_HOST) || (rt->rt6i_flags & RTF_GATEWAY))
> > >  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> > The del path may also require changes.  I am thinking:
> > 1. Create a /128 via gateway route
> > 2. Send some traffic and RTF_CACHE rt is created
> > 3. Delete the /128 route by ip route del.  I suspect the RTF_CACHE route may be
> >    deleted and the route added in (1) stays.
> 
> Good point.
> 
> Both routes are on the same fib node. The cached one has the better
> metric, so I guess this one will be found and deleted.
> 
> I'll check this. Thanks for the hint!

I finally got around to test this. It is as you say, we delete
the clone but not the original route.

I was able to fix this by adding the following:

---
 net/ipv6/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c20186f..e4f6a56 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1814,6 +1814,8 @@ static int ip6_route_del(struct fib6_config *cfg)
 				continue;
 			if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
 				continue;
+			if (rt->rt6i_flags & RTF_CACHE)
+				continue;
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 

It should be ok to ignore cached routes here because they are
removed with the original route. With this patch applied both
routes, the cached and the original go away when deleting.

I'll send an updated version of my patchset if this survives
some advanced testing.
