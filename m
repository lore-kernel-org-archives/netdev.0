From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] ipv4: fix race in concurrent ip_route_input_slow()
Date: Tue, 19 Nov 2013 19:12:34 -0800
Message-ID: <1384917154-11049-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52839 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab3KTDMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 22:12:39 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so6112119pad.40
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 19:12:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPUs can ask for local route via ip_route_input_noref() concurrently.
if nh_rth_input is not cached yet, CPUs will proceed to allocate
equivalent DSTs on 'lo' and then will try to cache them in nh_rth_input
via rt_cache_route()
Most of the time they succeed, but on occasion the following two lines:
	orig = *p;
	prev = cmpxchg(p, orig, rt);
in rt_cache_route() do race and one of the cpus fails to complete cmpxchg.
But ip_route_input_slow() doesn't check the return code of rt_cache_route(),
so dst is leaking. dst_destroy() is never called and 'lo' device
refcnt doesn't go to zero, which can be seen in the logs as:
	unregister_netdevice: waiting for lo to become free. Usage count = 1
Adding mdelay() between above two lines makes it easily reproducible.
Fix it similar to nh_pcpu_rth_output case.

Fixes: d2d68ba9fe8b ("ipv4: Cache input routes in fib_info nexthops.")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

David,

looks like caacf05e5ad1 ("ipv4: Properly purge netdev references on uncached routes.")
fixed the race for nexthop/rth_output, but missed it for rth_input.
I'm not sure what was the assumption why it's not needed there.
We're definitely seeing it every 12-24hr during nightly tests.
There are several bugs on ubuntu and debian forums with similar description.
Some were closed, since folks struggled to reproduce it.
It took us more than a month to debug it.
Please queue for stable.

Alternative fix:
	rt_free(rth);
	goto local_input;
imo is uglier.
Just like rt_free(rth) followed by re-read of nh_rth_input and re-check_valid

 net/ipv4/route.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f428935..f8da282 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1776,8 +1776,12 @@ local_input:
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
-	if (do_cache)
-		rt_cache_route(&FIB_RES_NH(res), rth);
+	if (do_cache) {
+		if (unlikely(!rt_cache_route(&FIB_RES_NH(res), rth))) {
+			rth->dst.flags |= DST_NOCACHE;
+			rt_add_uncached_list(rth);
+		}
+	}
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
-- 
1.7.9.5
