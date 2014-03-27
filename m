From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu, 27 Mar 2014 17:30:46 +0100
Message-ID: <20140327163046.GA11063@order.stressinduktion.org>
References: <20140327050618.GK22086@order.stressinduktion.org> <20140327120408.03BECE66C2@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35510 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806AbaC0Qar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:30:47 -0400
Content-Disposition: inline
In-Reply-To: <20140327120408.03BECE66C2@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 01:04:08PM +0100, Michal Kubecek wrote:
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
> Another problem is that old metrics in inetpeer can reappear
> unexpectedly for a new route, e.g.
> 
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
> 12sp0:~ # ip route del fec0::1
> 12sp0:~ # ip route add fec0::1 dev eth0
> 12sp0:~ # ip route change fec0::1 dev eth0 hoplimit 10
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  hoplimit 10 rto_min lock 1s
> 
> Resolve the first problem by moving the setting of metrics down
> into fib6_add_rt2node() to the point we are sure we are
> inserting the new route into the tree. Second problem is
> addressed by introducing new flag DST_METRICS_FORCE_OVERWRITE
> which is set for a new host route in ip6_route_add() and makes
> ipv6_cow_metrics() always overwrite the metrics in inetpeer
> (even if they are not "new"); it is reset after that.
> 
> v5: use a flag in _metrics member rather than one in flags
> 
> v4: fix a typo making a condition always true (thanks to Hannes
> Frederic Sowa)
> 
> v3: rewritten based on David Miller's idea to move setting the
> metrics (and allocation in non-host case) down to the point we
> already know the route is to be inserted. Also rebased to
> net-next as it is quite late in the cycle.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

I like your patch! :)

Actually I was a bit surprised how easy it turned out.

Thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
