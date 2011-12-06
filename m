From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/13 net-3.1-stable] ipv4: fix redirect handling
Date: Tue, 06 Dec 2011 16:33:43 -0500 (EST)
Message-ID: <20111206.163343.2097498336010891947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1LFVdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:46 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXhLj024243
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:44 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Eric Dumazet <eric.dumazet@gmail.com>

[ Upstream commit 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc ]

commit f39925dbde77 (ipv4: Cache learned redirect information in
inetpeer.) introduced a regression in ICMP redirect handling.

It assumed ipv4_dst_check() would be called because all possible routes
were attached to the inetpeer we modify in ip_rt_redirect(), but thats
not true.

commit 7cc9150ebe (route: fix ICMP redirect validation) tried to fix
this but solution was not complete. (It fixed only one route)

So we must lookup existing routes (including different TOS values) and
call check_peer_redir() on them.

Reported-by: Ivan Zahariev <famzah@icdsoft.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Flavio Leitner <fbl@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |  110 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 59 insertions(+), 51 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e9b273b..b2e9544 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1309,16 +1309,42 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
+{
+	struct rtable *rt = (struct rtable *) dst;
+	__be32 orig_gw = rt->rt_gateway;
+	struct neighbour *n, *old_n;
+
+	dst_confirm(&rt->dst);
+
+	rt->rt_gateway = peer->redirect_learned.a4;
+
+	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	old_n = xchg(&rt->dst._neighbour, n);
+	if (old_n)
+		neigh_release(old_n);
+	if (!n || !(n->nud_state & NUD_VALID)) {
+		if (n)
+			neigh_event_send(n, NULL);
+		rt->rt_gateway = orig_gw;
+		return -EAGAIN;
+	} else {
+		rt->rt_flags |= RTCF_REDIRECTED;
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
+	}
+	return 0;
+}
+
 /* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
 	int s, i;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct rtable *rt;
 	__be32 skeys[2] = { saddr, 0 };
 	int    ikeys[2] = { dev->ifindex, 0 };
-	struct flowi4 fl4;
 	struct inet_peer *peer;
 	struct net *net;
 
@@ -1341,33 +1367,42 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.daddr = daddr;
 	for (s = 0; s < 2; s++) {
 		for (i = 0; i < 2; i++) {
-			fl4.flowi4_oif = ikeys[i];
-			fl4.saddr = skeys[s];
-			rt = __ip_route_output_key(net, &fl4);
-			if (IS_ERR(rt))
-				continue;
-
-			if (rt->dst.error || rt->dst.dev != dev ||
-			    rt->rt_gateway != old_gw) {
-				ip_rt_put(rt);
-				continue;
-			}
+			unsigned int hash;
+			struct rtable __rcu **rthp;
+			struct rtable *rt;
+
+			hash = rt_hash(daddr, skeys[s], ikeys[i], rt_genid(net));
+
+			rthp = &rt_hash_table[hash].chain;
+
+			while ((rt = rcu_dereference(*rthp)) != NULL) {
+				rthp = &rt->dst.rt_next;
+
+				if (rt->rt_key_dst != daddr ||
+				    rt->rt_key_src != skeys[s] ||
+				    rt->rt_oif != ikeys[i] ||
+				    rt_is_input_route(rt) ||
+				    rt_is_expired(rt) ||
+				    !net_eq(dev_net(rt->dst.dev), net) ||
+				    rt->dst.error ||
+				    rt->dst.dev != dev ||
+				    rt->rt_gateway != old_gw)
+					continue;
 
-			if (!rt->peer)
-				rt_bind_peer(rt, rt->rt_dst, 1);
+				if (!rt->peer)
+					rt_bind_peer(rt, rt->rt_dst, 1);
 
-			peer = rt->peer;
-			if (peer) {
-				peer->redirect_learned.a4 = new_gw;
-				atomic_inc(&__rt_peer_genid);
+				peer = rt->peer;
+				if (peer) {
+					if (peer->redirect_learned.a4 != new_gw) {
+						peer->redirect_learned.a4 = new_gw;
+						atomic_inc(&__rt_peer_genid);
+					}
+					check_peer_redir(&rt->dst, peer);
+				}
 			}
-
-			ip_rt_put(rt);
-			return;
 		}
 	}
 	return;
@@ -1654,33 +1689,6 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
-static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
-{
-	struct rtable *rt = (struct rtable *) dst;
-	__be32 orig_gw = rt->rt_gateway;
-	struct neighbour *n, *old_n;
-
-	dst_confirm(&rt->dst);
-
-	rt->rt_gateway = peer->redirect_learned.a4;
-
-	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
-	old_n = xchg(&rt->dst._neighbour, n);
-	if (old_n)
-		neigh_release(old_n);
-	if (!n || !(n->nud_state & NUD_VALID)) {
-		if (n)
-			neigh_event_send(n, NULL);
-		rt->rt_gateway = orig_gw;
-		return -EAGAIN;
-	} else {
-		rt->rt_flags |= RTCF_REDIRECTED;
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-	}
-	return 0;
-}
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
-- 
1.7.7.3
