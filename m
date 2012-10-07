From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 3/6] ipv4: add check if nh_pcpu_rth_output is
 allocated
Date: Sun, 7 Oct 2012 20:24:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210071813190.9927@ja.ssi.bg>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>  <1349609168-9848-4-git-send-email-ja@ssi.bg> <1349616863.21172.2376.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53268 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab2JGRT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 13:19:29 -0400
In-Reply-To: <1349616863.21172.2376.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 7 Oct 2012, Eric Dumazet wrote:

> On Sun, 2012-10-07 at 14:26 +0300, Julian Anastasov wrote:
> > 	Avoid NULL ptr dereference and caching if
> > nh_pcpu_rth_output is not allocated.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  net/ipv4/route.c |   12 +++++++++---
> >  1 files changed, 9 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 488a8bb..0a600cc 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1798,18 +1798,24 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
> >  	fnhe = NULL;
> >  	if (fi) {
> >  		struct rtable __rcu **prth;
> > +		struct fib_nh *nh = &FIB_RES_NH(*res);
> >  
> > -		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
> > +		fnhe = find_exception(nh, fl4->daddr);
> >  		if (fnhe)
> >  			prth = &fnhe->fnhe_rth;
> > -		else
> > -			prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
> > +		else {
> > +			if (!nh->nh_pcpu_rth_output)
> > +				goto add;
> > +			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
> > +		}
> >  		rth = rcu_dereference(*prth);
> >  		if (rt_cache_valid(rth)) {
> >  			dst_hold(&rth->dst);
> >  			return rth;
> >  		}
> >  	}
> > +
> > +add:
> >  	rth = rt_dst_alloc(dev_out,
> >  			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
> >  			   IN_DEV_CONF_GET(in_dev, NOXFRM),
> 
> Alternative would be to make sure the allocation succeeded in
> fib_create_info(), but I have no idea on the maximal number of fib_info
> a complex routing setup might need ?

	I too preferred not to touch there because I don't
know how much we can want from alloc_percpu.

> I guess a typical machine needs less than 30 fib_info...

	May be, I guess it all depends on the present primary
addresses, gateways and devices. Thousands of routes 
do not look so scary because they will use small number
of fib_infos.

	But it is a problem that we allocate memory
that may never be used, there is no chance to expire it.
Not sure how good is the idea to create fib_infos without
percpu allocations and the first traffic to notify some
thread to attach such arrays? We can safe memory if the
local/broadcast fib_infos are not used for output routes.
But such idea will cost many checks in fast path.
Another hack could be to use 1 entry for local/broadcast/mcast
and array for unicast. Type RTN_BROADCAST is actually not
cached at all, so we do not need to allocate array.

Regards

--
Julian Anastasov <ja@ssi.bg>
