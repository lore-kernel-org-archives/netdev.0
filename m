From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: set dst.obsolete when a cached route has expired
Date: Sat, 26 Aug 2017 20:10:10 +0800
Message-ID: <cd3d9312a3d31ee72b9377e7200898c30f73ab8e.1503749410.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38787 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752129AbdHZMKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 08:10:20 -0400
Received: by mail-pg0-f66.google.com with SMTP id t3so2684583pgt.5
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 05:10:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now it doesn't check for the cached route expiration in ipv6's
dst_ops->check(), because it trusts dst_gc that would clean the
cached route up when it's expired.

The problem is in dst_gc, it would clean the cached route only
when it's refcount is 1. If some other module (like xfrm) keeps
holding it and the module only release it when dst_ops->check()
fails.

But without checking for the cached route expiration, .check()
may always return true. Meanwhile, without releasing the cached
route, dst_gc couldn't del it. It will cause this cached route
never to expire.

This patch is to set dst.obsolete with DST_OBSOLETE_KILL in .gc
when it's expired, and check obsolete != DST_OBSOLETE_FORCE_CHK
in .check.

Note that this is even needed when ipv6 dst_gc timer is removed
one day. It would set dst.obsolete in .redirect and .update_pmtu
instead, and check for cached route expiration when getting it,
just like what ipv4 route does.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 4 +++-
 net/ipv6/route.c   | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index a5ebf86..18567b8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1792,8 +1792,10 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		}
 		gc_args->more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
+		if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout))
+			rt->dst.obsolete = DST_OBSOLETE_KILL;
 		if (atomic_read(&rt->dst.__refcnt) == 1 &&
-		    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
+		    rt->dst.obsolete == DST_OBSOLETE_KILL) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if (rt->rt6i_flags & RTF_GATEWAY) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 48c8c92..7c634b6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -440,7 +440,8 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 		if (time_after(jiffies, rt->dst.expires))
 			return true;
 	} else if (rt->dst.from) {
-		return rt6_check_expired((struct rt6_info *) rt->dst.from);
+		return rt->dst.obsolete != DST_OBSOLETE_FORCE_CHK ||
+		       rt6_check_expired((struct rt6_info *)rt->dst.from);
 	}
 	return false;
 }
-- 
2.1.0
