From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next v4] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu, 27 Mar 2014 08:43:17 +0100
Message-ID: <1728201.2Lp3R0hfkV@alaris>
References: <20140326155047.GG22086@order.stressinduktion.org> <20140326160503.93B6FE6E05@unicorn.suse.cz> <20140327050618.GK22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58562 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbaC0HnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 03:43:20 -0400
In-Reply-To: <20140327050618.GK22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 of March 2014 06:06:18 Hannes Frederic Sowa wrote:
> On Wed, Mar 26, 2014 at 05:05:03PM +0100, Michal Kubecek wrote:
> > diff --git a/include/net/dst.h b/include/net/dst.h
> > index e01a826..8cf6772 100644
> > --- a/include/net/dst.h
> > +++ b/include/net/dst.h
> > @@ -57,6 +57,7 @@ struct dst_entry {
> > 
> >  #define DST_FAKE_RTABLE		0x0040
> >  #define DST_XFRM_TUNNEL		0x0080
> >  #define DST_XFRM_QUEUE		0x0100
> > 
> > +#define DST_KEEP_METRICS	0x0400
> 
> Minor nit: 0x0200
> 
> You jumped over one bit.

Oh yes. This is because of DST_NOPEER which is still in net but was
removed in net-next.

> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index fba54a4..4e5b19e 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -149,8 +149,10 @@ static u32 *ipv6_cow_metrics(struct dst_entry
> > *dst, unsigned long old)> 
> >  		unsigned long prev, new;
> >  		
> >  		p = peer->metrics;
> > 
> > -		if (inet_metrics_new(peer))
> > +		if (inet_metrics_new(peer) || (dst->flags & DST_KEEP_METRICS)) {
> > 
> >  			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> > 
> > +			dst->flags &= ~DST_KEEP_METRICS;
> > +		}
> 
> I wonder if we can make this more concurrency friendly:
> 
> The idea that came to my mind would be to store KEEP_METRICS flag in
> the metrics pointer and introduce new DST_METRICS_FORCE_OVERWRITE
> flag like DST_METRICS_READ_ONLY.

I was also considering this as logically the flag belongs here more
than into the dst_entry flags. For some reason I was afraid it would
be less efficient but now thinking about it again, I don't see why it
should be.

> __DST_METRICS_PTR would have to mask it out, too (so would the check
> in dst_metrics_write_ptr).

I believe the test in dst_metrics_write_ptr() should stay the way it is.
We want to call cow_metrics() whenever the metrics are read only and
consider DST_METRICS_FORCE_OVERWRITE only in ipv6_cow_metrics(). But I
better check again.

> Then cmpxchg would atomically change status of KEEP_METRICS flag, too.

That would be useful. However, I'm more concerned about 

> In fib6_commit_metrics we could then add the flag somehow if dst is
> DST_HOST and mx != NULL.

IMHO it should do so even if mx is null. Otherwise we could end up with
a dst using read only defaults but having old metrics hidden in inetpeer
which would get revived once cow_metrics() is called for any reason.

I'll prepare a patch and test it.

                                                         Michal Kubecek
