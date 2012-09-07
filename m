From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: rt_cache_flush() cleanup
Date: Fri, 07 Sep 2012 22:27:11 +0200
Message-ID: <1347049631.1234.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53645 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756864Ab2IGU1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 16:27:16 -0400
Received: by eaac11 with SMTP id c11so1081036eaa.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 13:27:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We dont use jhash anymore since route cache removal,
so we can get rid of get_random_bytes() calls for rt_genid
changes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/route.c |   19 ++-----------------
 1 file changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ab1e7c7..d39edf1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -447,23 +447,9 @@ static inline bool rt_is_expired(const struct rtable *rth)
 	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
 
-/*
- * Perturbation of rt_genid by a small quantity [1..256]
- * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
- * many times (2^24) without giving recent rt_genid.
- * Jenkins hash is strong enough that litle changes of rt_genid are OK.
- */
-static void rt_cache_invalidate(struct net *net)
-{
-	unsigned char shuffle;
-
-	get_random_bytes(&shuffle, sizeof(shuffle));
-	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-}
-
 void rt_cache_flush(struct net *net)
 {
-	rt_cache_invalidate(net);
+	atomic_inc(&net->ipv4.rt_genid);
 }
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
@@ -2520,8 +2506,7 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 
 static __net_init int rt_genid_init(struct net *net)
 {
-	get_random_bytes(&net->ipv4.rt_genid,
-			 sizeof(net->ipv4.rt_genid));
+	atomic_set(&net->ipv4.rt_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
