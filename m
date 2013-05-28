From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/3] ipv4: rate limit updating of next hop
 exceptions with same pmtu
Date: Wed, 29 May 2013 00:04:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305282245340.1713@ja.ssi.bg>
References: <20130527.233844.2081972819091665848.davem@davemloft.net> <1369723593-5307-1-git-send-email-timo.teras@iki.fi> <1369723593-5307-2-git-send-email-timo.teras@iki.fi> <alpine.LFD.2.00.1305281127340.1693@ja.ssi.bg> <20130528130757.4bf59c6b@vostro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43852 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756217Ab3E1VBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 17:01:06 -0400
In-Reply-To: <20130528130757.4bf59c6b@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 28 May 2013, Timo Teras wrote:

> > > --- a/net/ipv4/route.c
> > > +++ b/net/ipv4/route.c
> > > @@ -947,6 +947,10 @@ static void __ip_rt_update_pmtu(struct rtable
> > > *rt, struct flowi4 *fl4, u32 mtu) if (mtu < ip_rt_min_pmtu)
> > >  		mtu = ip_rt_min_pmtu;
> > >  
> > > +	if (rt->rt_pmtu == mtu &&
> > > +	    time_before(jiffies, dst->expires -
> > > ip_rt_mtu_expires / 2))
> > > +		return;
> > > +
> > 
> > 	Can we also add logic in this patch in
> > update_or_create_fnhe, so that we avoid invalidation for cached
> > routes when only pmtu expiration is updated (same pmtu), i.e.:
> > 
> > +	if (gw || pmtu != fnhe->fnhe_pmtu) {
> > +		/* Exception created; mark the cached routes for the
> > nexthop
> > +		...
> > +	}
> > 
> > 	BTW, I now see that previous patch should
> > call for_each_possible_cpu for the both cases, not
> > only when fnhe is created but also on update:
> 
> Why would this be needed?
> 
> The idea is that if there is no next hop exception, everyone is using
> the next hop's dsts. If there is a next hop exception hashed, they will
> be using those routes in the exception entry.
> 
> When the exception is created, we need to invalidate the nexthop's
> routes, to force relookup of these dst's if should go to the exception.
> Basically it flushes the nexthop's 'default' dst.
> 
> But if we have a valid exception, and we are just updating it. Everyone
> is already using the right dst. The update_or_create_fnhe() updates all
> exception's dst's that are effected. Since the set of hosts to which
> that exception applies is the same, I don't see why we would need to
> invalidate the nexthop's 'default' dst.

	Agreed for the NH route. But there is another case:
when fnhe exists for fnhe_pmtu!=0 and fnhe_gw=0 and the cached
FNHE route has just rt_pmtu!=0 and rt_uses_gateway=0. In the
event of redirect we should invalidate fnhe_rth.
Users should come again to get the new gw from the
same fnhe. As you note, nh_pcpu_rth_output does not need
to be invalidated, it was already invalidated when
fnhe was created.

	So, my idea is something like this. If cached
route detects change in gw on redirect, it calls
update_or_create_fnhe but FNHE can already know this gw,
we should invalidate the fnhe_rth only if gw changes.
As caller has some stale cache route, it should be
invalidated as before, I assume 'kill_route' is properly
provided.

	if (fnhe) {
		if (fnhe->fnhe_gw != gw && gw) {
			rt = rcu_dereference_protected(fnhe->fnhe_rth, 1);
			if (rt)
				rt->dst.obsolete = DST_OBSOLETE_KILL;
			fnhe->fnhe_gw = gw;
		}
		...
	}
	...
}

	Also, I don't know the XFRM code well but
xfrm_bundle_ok() calls dst_check. Now ipv4_dst_check
will not give any indication for recent change in
rt_pmtu. I hope this is not a problem because I see
some comparisons with cached pmtus. I.e. the main
question is: are there any dst_check and ->check users
that needs to know for changes in rt_pmtu or all
of them just use dst_mtu().

Regards

--
Julian Anastasov <ja@ssi.bg>
