From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu, 06 Mar 2014 14:24:25 -0500 (EST)
Message-ID: <20140306.142425.1675660751208500651.davem@davemloft.net>
References: <20140306095054.EEC5EE6E04@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbaCFTYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:24:31 -0500
In-Reply-To: <20140306095054.EEC5EE6E04@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu,  6 Mar 2014 10:50:54 +0100 (CET)

> If an IPv6 host route with metrics exists, an attempt to add a
> new route for the same target with different metrics fails but
> rewrites the metrics anyway:
> 
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  rto_min lock 1s
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1500
> RTNETLINK answers: File exists
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  rto_min lock 1.5s
> 
> This is caused by all IPv6 host routes using the metrics in
> their inetpeer (or the shared default). This also holds for the
> new route created in ip6_route_add() which shares the metrics
> with the already existing route and thus ip6_route_add()
> rewrites the metrics even if the new route ends up not being
> used at all.
> 
> Allocate separate metrics in ip6_route_add() and copy them into
> inetpeer (and update dst->_metrics) just before the new route is
> actually inserted in fib6_add_rt2node().
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Thanks for working on this.

> +static void rt6_metrics_to_peer(struct rt6_info *rt)
> +{
> +	struct inet_peer *peer = rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL;
> +	struct dst_entry *dst = &rt->dst;
> +	unsigned long old = dst->_metrics;
> +
> +	if (!(rt->dst.flags & DST_HOST) || dst_metrics_read_only(dst))
> +		return;
> +	if (peer && dst_metrics_ptr(dst) == peer->metrics)
> +		return;
> +
> +	dst->ops->cow_metrics(dst, old);
> +	if (dst->_metrics != old) {
> +		u32 *old_p = __DST_METRICS_PTR(old);
> +
> +		memcpy(dst_metrics_ptr(dst), old_p, RTAX_MAX * sizeof(u32));
> +		kfree(old_p);
> +	}
> +}

Hmmm...  if inet_metrics_new() is true then ->cow_metrics() will copy the
metrics from old to new.  So you therefore shouldn't have to do the copy
explicitly here.

If inet_metrics_new() is not true, you are overwriting non-new metrics.

If there is some reason why what rt6_metrics_to_peer() is doing is OK, I'd
like you to explain this in the commit message.

Thanks!
