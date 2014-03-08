From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Sat, 8 Mar 2014 09:06:16 +0100
Message-ID: <20140308080616.GB5493@order.stressinduktion.org>
References: <20140306095054.EEC5EE6E04@unicorn.suse.cz> <20140306.142425.1675660751208500651.davem@davemloft.net> <20140306200658.GA32699@unicorn.suse.cz> <20140307.155258.463380957582451300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49732 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaCHIGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 03:06:18 -0500
Content-Disposition: inline
In-Reply-To: <20140307.155258.463380957582451300.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2014 at 03:52:58PM -0500, David Miller wrote:
> Thank you for explaining all of this, I would like to think about this
> some more.
> 
> My initial suspicion is that the something about the test in cow
> metrics might need to be adjusted.

Hmm, you mean we can do the check when looking up the route and testing that
on cloning or cowing and maybe do the copy then?

Just trying to think out loud:

I think we always should have the metrics (if we have them) in inet_peer
in case the dst is a DST_HOST. We cannot do that directly in ip6_route_add
because we would also publish the metrics in case we don't actually
install the route because of an error.  So this is a no-go, we need to
stage them first.

In case we do that in ip6_rt_copy / ip6_pol_route:

We don't reinsert DST_HOST routes into fib so they will never go through
ip6_rt_copy, as such they are never pushed through ipv6_cow_metrics logic.

A new check would be needed in ip6_pol_route for DST_HOST routes and
check inet_peer metrics pointer with dst->metrics one. As we don't set
RTF_CACHE in rt6i_flags afterwards we would need to do that on every DST_HOST
result every time (if metrics pointer is writable).

So moving the metrics from staging area into inet_peer metrics in
rt2node seems like the best solution to me so far. I am fine with the
current approach. I also agree that current patch should not have a
performance impact, as we don't reinsert DST_HOST nodes into the fib,
so the new inline rt6_metrics_to_peer should be ok to protect against
this common case.

> The conceptual attributes we have built for inetpeer metrics, that of
> "newness" and "read-only", might not be built adequately for the task
> at hand here.

One question regarding the patch:

In case fc_mx is set we now always kzalloc a non-inet-peer region to
store the metrics for staging. I would find it a bit easier to switch
away from dst_metric_set and use array notation to make it more clear we
don't operate on inet_peer metrics below the install_route: mark in
ip6_route_add. This shouldn't alter the behaviour but just make it clear we
don't operate on inet_peer metric storage.

Hope this made any sense,

  Hannes
