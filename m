From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 08:54:25 +0200
Message-ID: <20121018065425.GC27385@secunet.com>
References: <20121018052730.GB27385@secunet.com>
 <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38124 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754078Ab2JRGyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 02:54:31 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 09:52:37AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 18 Oct 2012, Steffen Klassert wrote:
> 
> > Currently we can not flush cached pmtu/redirect informations via
> > the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
> > of the old route and reset the nh exeption if the old route is
> > expired when we bind a new route to a nh exeption.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv4/route.c |   16 ++++++++++------
> >  1 files changed, 10 insertions(+), 6 deletions(-)
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 432f4bb..defb98d 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1163,8 +1163,17 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
> >  	spin_lock_bh(&fnhe_lock);
> >  
> >  	if (daddr == fnhe->fnhe_daddr) {
> > -		struct rtable *orig;
> > +		struct rtable *orig = rcu_dereference(fnhe->fnhe_rth);
> > +		rcu_assign_pointer(fnhe->fnhe_rth, rt);
> 
> 	May be the above rcu_assign_pointer should be after
> 
> 	... if (!rt->rt_gateway)
> 		rt->rt_gateway = daddr;
> 
> 	part. It is possible another __mkroute_output
> caller to get the cached fnhe->fnhe_rth without valid
> rt->rt_gateway. rcu_assign_pointer should be after all
> writes to rt.

Right, I'll send an updated version.

Thanks!
