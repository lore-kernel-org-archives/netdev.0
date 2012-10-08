From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 3/3] ipv4: Don't report stale pmtu values to userspace
Date: Mon, 8 Oct 2012 12:38:12 +0200
Message-ID: <20121008103812.GA21577@secunet.com>
References: <20121008084642.GB15622@secunet.com>
 <20121008084853.GE15622@secunet.com>
 <1349690144.21172.3024.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48676 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833Ab2JHKiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 06:38:15 -0400
Content-Disposition: inline
In-Reply-To: <1349690144.21172.3024.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 08, 2012 at 11:55:44AM +0200, Eric Dumazet wrote:
> On Mon, 2012-10-08 at 10:48 +0200, Steffen Klassert wrote:
> > We report cached pmtu values even if they are already expired.
> > Change this to not report these values after they are expired.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv4/route.c |   17 +++++++++--------
> >  1 files changed, 9 insertions(+), 8 deletions(-)
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 741df67..24b52dd 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -2187,8 +2187,16 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
> >  	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
> >  		goto nla_put_failure;
> >  
> > +	expires = rt->dst.expires;
> > +	if (expires) {
> > +		if (time_before(jiffies, expires))
> > +			expires -= jiffies;
> 
> Seeing this racy code, we could fix it as well.

Sure, we can :)

> 
> jiffies is volatile and can change between the test and subtraction.
> 
> So we could in theory get strange result.
> 
> I suggest using :
> 
> if (expires) {
> 	unsigned long now = jiffies;
> 
> 	if (time_before(now, expires))
> 		expires -= now;
> 	else
> 		expires = 0;
> }

I'll go with the version above and send an updated patch.

Thanks.
