From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/3] ipv4: rate limit updating of next hop
 exceptions with same pmtu
Date: Thu, 30 May 2013 01:49:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305300013240.1951@ja.ssi.bg>
References: <20130527.233844.2081972819091665848.davem@davemloft.net> <1369723593-5307-1-git-send-email-timo.teras@iki.fi> <1369723593-5307-2-git-send-email-timo.teras@iki.fi> <alpine.LFD.2.00.1305281127340.1693@ja.ssi.bg> <20130528130757.4bf59c6b@vostro>
 <alpine.LFD.2.00.1305282245340.1713@ja.ssi.bg> <20130529080725.5de3477b@vostro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44540 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755938Ab3E2WpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 18:45:25 -0400
In-Reply-To: <20130529080725.5de3477b@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 29 May 2013, Timo Teras wrote:

> On Wed, 29 May 2013 00:04:47 +0300 (EEST)
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > 	So, my idea is something like this. If cached
> > route detects change in gw on redirect, it calls
> > update_or_create_fnhe but FNHE can already know this gw,
> > we should invalidate the fnhe_rth only if gw changes.
> > As caller has some stale cache route, it should be
> > invalidated as before, I assume 'kill_route' is properly
> > provided.
> > 
> > 	if (fnhe) {
> > 		if (fnhe->fnhe_gw != gw && gw) {
> > 			rt =
> > rcu_dereference_protected(fnhe->fnhe_rth, 1); if (rt)
> > 				rt->dst.obsolete = DST_OBSOLETE_KILL;
> > 			fnhe->fnhe_gw = gw;
> > 		}
> > 		...
> > 	}
> > 	...
> > }
> 
> This is already done by the caller of update_or_create_fnhe for the
> case of gw change. It might be worth to put all this to the same place,
> but would be worth of separate patch.

	Looking at do_redirect() for TCP and __sk_dst_check
may be such race is very small because first gw change
for another socket will invalidate our cached entry and
our socket will fail to deliver the new gw to FNHE
without a two-step validation as done in inet_csk_update_pmtu().
Still, it should be more safe to change and invalidate
at the same place - update_or_create_fnhe. But we can
investigate it later.

> > 	Also, I don't know the XFRM code well but
> > xfrm_bundle_ok() calls dst_check. Now ipv4_dst_check
> > will not give any indication for recent change in
> > rt_pmtu. I hope this is not a problem because I see
> > some comparisons with cached pmtus. I.e. the main
> > question is: are there any dst_check and ->check users
> > that needs to know for changes in rt_pmtu or all
> > of them just use dst_mtu().
> 
> In XFRM case, xfrm_bundle_ok() will propagate the pmtu by calling
> dst_mtu() for each target. All caching users need to use dst_mtu() to
> check it, so the route.c code is correct - this is how it worked before
> my patches too.

	Aha, so nobody needs DST_OBSOLETE_KILL when
fnhe_pmtu changes. Thanks for answering my questions!

Regards

--
Julian Anastasov <ja@ssi.bg>
