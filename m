From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/13 net-3.1-stable] ipv4: Perform peer validation on
 cached route lookup.
Date: Tue, 06 Dec 2011 16:33:55 -0500 (EST)
Message-ID: <20111206.163355.2051008820794564225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431Ab1LFVd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:57 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXtTm024327
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:56 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: "David S. Miller" <davem@davemloft.net>

[ Upstream commit efbc368dcc6426d5430b9b8eeda944cf2cb74b8c,
  incorporating a follow-on change to prevent an OOPS ]

Otherwise we won't notice the peer GENID change.

Reported-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   41 ++++++++++++++++++++++-------------------
 1 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 65d2572..5c9b20f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1311,7 +1311,7 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
+static void check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
@@ -1322,21 +1322,19 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	rt->rt_gateway = peer->redirect_learned.a4;
 
 	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
+	if (IS_ERR(n)) {
+		rt->rt_gateway = orig_gw;
+		return;
+	}
 	old_n = xchg(&rt->dst._neighbour, n);
 	if (old_n)
 		neigh_release(old_n);
-	if (!n || !(n->nud_state & NUD_VALID)) {
-		if (n)
-			neigh_event_send(n, NULL);
-		rt->rt_gateway = orig_gw;
-		return -EAGAIN;
+	if (!(n->nud_state & NUD_VALID)) {
+		neigh_event_send(n, NULL);
 	} else {
 		rt->rt_flags |= RTCF_REDIRECTED;
 		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 	}
-	return 0;
 }
 
 /* called in rcu_read_lock() section */
@@ -1694,12 +1692,8 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 }
 
 
-static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
+static void ipv4_validate_peer(struct rtable *rt)
 {
-	struct rtable *rt = (struct rtable *) dst;
-
-	if (rt_is_expired(rt))
-		return NULL;
 	if (rt->rt_peer_genid != rt_peer_genid()) {
 		struct inet_peer *peer;
 
@@ -1708,19 +1702,26 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 
 		peer = rt->peer;
 		if (peer) {
-			check_peer_pmtu(dst, peer);
+			check_peer_pmtu(&rt->dst, peer);
 
 			if (peer->redirect_genid != redirect_genid)
 				peer->redirect_learned.a4 = 0;
 			if (peer->redirect_learned.a4 &&
-			    peer->redirect_learned.a4 != rt->rt_gateway) {
-				if (check_peer_redir(dst, peer))
-					return NULL;
-			}
+			    peer->redirect_learned.a4 != rt->rt_gateway)
+				check_peer_redir(&rt->dst, peer);
 		}
 
 		rt->rt_peer_genid = rt_peer_genid();
 	}
+}
+
+static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
+{
+	struct rtable *rt = (struct rtable *) dst;
+
+	if (rt_is_expired(rt))
+		return NULL;
+	ipv4_validate_peer(rt);
 	return dst;
 }
 
@@ -2370,6 +2371,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			ipv4_validate_peer(rth);
 			if (noref) {
 				dst_use_noref(&rth->dst, jiffies);
 				skb_dst_set_noref(skb, &rth->dst);
@@ -2745,6 +2747,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			ipv4_validate_peer(rth);
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
-- 
1.7.7.3
