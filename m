From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] ip6: Do not expire uncached routes for mtu
 invalidation
Date: Mon, 08 Sep 2014 10:20:26 -0700
Message-ID: <1410196826.11872.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410165283-29337-1-git-send-email-agartrell@fb.com>
	 <1410172253.11872.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540DE380.1000302@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	kernel-team@fb.com, ps@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:56497 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449AbaIHRUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 13:20:33 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so8236078pdj.24
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 10:20:32 -0700 (PDT)
In-Reply-To: <540DE380.1000302@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 10:12 -0700, Alex Gartrell wrote:
> Thank you for taking a look, Eric.
> 
> I'll admit that I have a distinct lack of confidence that I've got the 
> right solution to the problem here, but I've made it about as far as I 
> can without getting your collective comments, so it's much appreciated.
..
> >>
> >>   static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
> >> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> >> index f74b041..a509a06 100644
> >> --- a/net/ipv6/route.c
> >> +++ b/net/ipv6/route.c
> >> @@ -947,8 +947,19 @@ restart:
> >>   		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> >>   	else if (!(rt->dst.flags & DST_HOST))
> >>   		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> >> -	else
> >> +	else {
> >> +		if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.expires &&
> >> +		    time_after(jiffies, rt->dst.expires)) {
> >> +			/* Uncached routes may have expires set if we
> >> +			 * intend to expire the MTU but not the dest
> >> +			 * itself.  In that case, we should reset the mtu
> >> +			 * before handing it back */
> >> +			dst_metric_set(&rt->dst, RTAX_MTU, 0);
> >> +			rt6_clean_expires(rt);
> >> +			rt->rt6i_flags &= ~RTF_MODIFIED;
> >
> > Many cpus can perform this at the same time on same route, this looks
> > racy.
> 
> Initially I was just going to agree with you here, but taking another 
> look at ip_vs_xmit at least, there doesn't appear to be any special 
> locking before invoking ->update_pmtu, which is playing with rt6i_flags 
> and dst.expires as well.  Is that racy as well or is there something 
> else I'm missing here?
> 
> There are other ways to skin this particular cat though, and I've got no 
> specific attachment to any of them.  The most logical thing to do IMO is 
> clone the route when it may be necessary to do so, but given the fact 
> that that was very deliberately undone in 7343ff3 "ipv6: Don't create 
> clones of host routes," I'm not sure that it's the right thing to do or 
> that it won't require major surgery.

Have you followed thread started yesterday ?

https://patchwork.ozlabs.org/patch/386739/

Reverting 7343ff3 "ipv6: Don't create clones of host routes" was
considered as a matter of fact, when I replied :

"This means we have to clone all routes."
