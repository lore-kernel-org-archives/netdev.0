From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH 3.0.y] route: release dst_entry.hh_cache when handling redirects
Date: Tue, 4 Dec 2012 11:09:13 +0100
Message-ID: <20121204110503.202EFC7E6F@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45961 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287Ab2LDLFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 06:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stable-3.0 commit 42ab5316 (ipv4: fix redirect handling) was
backport of mainline commit 9cc20b26 from 3.2-rc3 where hh
member of struct dst_entry was already gone.

However, in 3.0 we still have it and we have to clean it as
well, otherwise it keeps pointing to the cleaned up (and
unusable) hh_cache entry and packets cannot be sent out.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/route.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6b95f74..5ff2614 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1374,6 +1374,7 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
 	struct neighbour *n, *old_n;
+	struct hh_cache *old_hh;
 
 	dst_confirm(&rt->dst);
 
@@ -1381,6 +1382,9 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	n = __arp_bind_neighbour(&rt->dst, rt->rt_gateway);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
+	old_hh = xchg(&rt->dst.hh, NULL);
+	if (old_hh)
+		hh_cache_put(old_hh);
 	old_n = xchg(&rt->dst._neighbour, n);
 	if (old_n)
 		neigh_release(old_n);
-- 
1.7.10.4
