From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: rt_cache_valid must check expired routes
Date: Wed, 25 Jul 2012 17:11:23 +0200
Message-ID: <1343229083.2626.11177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57437 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030247Ab2GYPL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 11:11:29 -0400
Received: by bkwj10 with SMTP id j10so606483bkw.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 08:11:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
introduced rt_cache_valid() helper. It unfortunately doesn't check if
route is expired before caching it.

I noticed sk_setup_caps() was constantly called on a tcp workload.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
This patch is bringed by an European guy, but its still July after
all ;)

 net/ipv4/route.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6bcb8fc..30e7021 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -444,7 +444,7 @@ static inline int ip_rt_proc_init(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-static inline int rt_is_expired(struct rtable *rth)
+static inline bool rt_is_expired(const struct rtable *rth)
 {
 	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
@@ -1222,9 +1222,11 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	}
 }
 
-static bool rt_cache_valid(struct rtable *rt)
+static bool rt_cache_valid(const struct rtable *rt)
 {
-	return (rt && rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK);
+	return	rt &&
+		rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
+		!rt_is_expired(rt);
 }
 
 static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
