From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: shouldn't dump the expired routes
Date: Thu, 26 Dec 2013 14:00:25 +0800
Message-ID: <52BBC5F9.4050904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:35254 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab3LZGAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Dec 2013 01:00:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we execute the command "ip -6 route show table all", those routes
that have been expired will be dumped.  But as everyone knows, those
expired routes will not be used, and they will be deleted by the kernel.
So why we still need to dump they, and just don't dump them.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 include/net/ip6_route.h | 2 ++
 net/ipv6/ip6_fib.c      | 3 +++
 net/ipv6/route.c        | 2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index c2626ce..32fa188 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -103,6 +103,8 @@ void fib6_force_start_gc(struct net *net);
 struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr, bool anycast);
 
+bool rt6_check_expired(const struct rt6_info *rt);
+
 /*
  *	support functions for ND
  *
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 5550a81..f57a6bb 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -278,6 +278,9 @@ static int fib6_dump_node(struct fib6_walker_t *w)
 	struct rt6_info *rt;
 
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
+		if (rt6_check_expired(rt))
+			continue;
+
 		res = rt6_dump_route(rt, w->args);
 		if (res < 0) {
 			/* Frame is full, suspend walking */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 89b2735..abf5f05 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -348,7 +348,7 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	}
 }
 
-static bool rt6_check_expired(const struct rt6_info *rt)
+bool rt6_check_expired(const struct rt6_info *rt)
 {
 	if (rt->rt6i_flags & RTF_EXPIRES) {
 		if (time_after(jiffies, rt->dst.expires))
-- 
1.8.3.1
