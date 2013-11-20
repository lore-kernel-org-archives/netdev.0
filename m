From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix race in concurrent ip_route_input_slow()
Date: Wed, 20 Nov 2013 15:29:18 -0500 (EST)
Message-ID: <20131120.152918.493706024928330813.davem@davemloft.net>
References: <1384917154-11049-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965Ab3KTU3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:29:20 -0500
In-Reply-To: <1384917154-11049-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 19 Nov 2013 19:12:34 -0800

> CPUs can ask for local route via ip_route_input_noref() concurrently.
> if nh_rth_input is not cached yet, CPUs will proceed to allocate
> equivalent DSTs on 'lo' and then will try to cache them in nh_rth_input
> via rt_cache_route()
> Most of the time they succeed, but on occasion the following two lines:
> 	orig = *p;
> 	prev = cmpxchg(p, orig, rt);
> in rt_cache_route() do race and one of the cpus fails to complete cmpxchg.
> But ip_route_input_slow() doesn't check the return code of rt_cache_route(),
> so dst is leaking. dst_destroy() is never called and 'lo' device
> refcnt doesn't go to zero, which can be seen in the logs as:
> 	unregister_netdevice: waiting for lo to become free. Usage count = 1
> Adding mdelay() between above two lines makes it easily reproducible.
> Fix it similar to nh_pcpu_rth_output case.
> 
> Fixes: d2d68ba9fe8b ("ipv4: Cache input routes in fib_info nexthops.")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> 
> David,
> 
> looks like caacf05e5ad1 ("ipv4: Properly purge netdev references on uncached routes.")
> fixed the race for nexthop/rth_output, but missed it for rth_input.
> I'm not sure what was the assumption why it's not needed there.
> We're definitely seeing it every 12-24hr during nightly tests.
> There are several bugs on ubuntu and debian forums with similar description.
> Some were closed, since folks struggled to reproduce it.
> It took us more than a month to debug it.
> Please queue for stable.

Your analysis is accurate and your fix is absolutely correct, applied
and queued up for -stable, thanks!
