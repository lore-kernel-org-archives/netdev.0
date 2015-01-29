From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 1/2] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Thu, 29 Jan 2015 11:44:17 +0100
Message-ID: <20150129104416.GP13046@secunet.com>
References: <54C78B8D.1070104@huawei.com>
 <20150128121026.GM13046@secunet.com>
 <20150128121150.GN13046@secunet.com>
 <1422527211.2861.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38434 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759326AbbA2KoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 05:44:21 -0500
Content-Disposition: inline
In-Reply-To: <1422527211.2861.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 11:26:51AM +0100, Hannes Frederic Sowa wrote:
> On Mi, 2015-01-28 at 13:11 +0100, Steffen Klassert wrote:
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
> >  	else
> >  		goto out2;
> 
> My approach was to suppress mtu updates on the loopback interface.
> Hmm...

Maybe we need to do this too. My patch fixes just the case
where we get a valid pmtu update from a remote host.
