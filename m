From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 5/5] ipv4: Cache learned redirect information in
 inetpeer.
Date: Wed, 09 Feb 2011 22:13:48 -0800 (PST)
Message-ID: <20110209.221348.48502368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57754
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751047Ab1BJGNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:13:12 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CFCB924C088
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:13:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Note that we do not generate the redirect netevent any longer,
because we don't create a new cached route.

Instead, once the new neighbour is bound to the cached route,
we emit a neigh update event instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |  136 +++++++++++++++++-------------------------------------
 1 files changed, 42 insertions(+), 94 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 11faf14..756f544 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1294,13 +1294,8 @@ static void rt_del(unsigned hash, struct rtable *rt)
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
-	int i, k;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct rtable *rth;
-	struct rtable __rcu **rthp;
-	__be32  skeys[2] = { saddr, 0 };
-	int  ikeys[2] = { dev->ifindex, 0 };
-	struct netevent_redirect netevent;
+	struct inet_peer *peer;
 	struct net *net;
 
 	if (!in_dev)
@@ -1312,9 +1307,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	    ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
-	if (!rt_caching(net))
-		goto reject_redirect;
-
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
@@ -1325,93 +1317,13 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	for (i = 0; i < 2; i++) {
-		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k],
-						rt_genid(net));
-
-			rthp = &rt_hash_table[hash].chain;
-
-			while ((rth = rcu_dereference(*rthp)) != NULL) {
-				struct rtable *rt;
-
-				if (rth->fl.fl4_dst != daddr ||
-				    rth->fl.fl4_src != skeys[i] ||
-				    rth->fl.oif != ikeys[k] ||
-				    rt_is_input_route(rth) ||
-				    rt_is_expired(rth) ||
-				    !net_eq(dev_net(rth->dst.dev), net)) {
-					rthp = &rth->dst.rt_next;
-					continue;
-				}
-
-				if (rth->rt_dst != daddr ||
-				    rth->rt_src != saddr ||
-				    rth->dst.error ||
-				    rth->rt_gateway != old_gw ||
-				    rth->dst.dev != dev)
-					break;
-
-				dst_hold(&rth->dst);
-
-				rt = dst_alloc(&ipv4_dst_ops);
-				if (rt == NULL) {
-					ip_rt_put(rth);
-					return;
-				}
-
-				/* Copy all the information. */
-				*rt = *rth;
-				rt->dst.__use		= 1;
-				atomic_set(&rt->dst.__refcnt, 1);
-				rt->dst.child		= NULL;
-				if (rt->dst.dev)
-					dev_hold(rt->dst.dev);
-				rt->dst.obsolete	= -1;
-				rt->dst.lastuse	= jiffies;
-				rt->dst.path		= &rt->dst;
-				rt->dst.neighbour	= NULL;
-				rt->dst.hh		= NULL;
-#ifdef CONFIG_XFRM
-				rt->dst.xfrm		= NULL;
-#endif
-				rt->rt_genid		= rt_genid(net);
-				rt->rt_flags		|= RTCF_REDIRECTED;
-
-				/* Gateway is different ... */
-				rt->rt_gateway		= new_gw;
-
-				/* Redirect received -> path was valid */
-				dst_confirm(&rth->dst);
-
-				if (rt->peer)
-					atomic_inc(&rt->peer->refcnt);
-				if (rt->fi)
-					atomic_inc(&rt->fi->fib_clntref);
-
-				if (arp_bind_neighbour(&rt->dst) ||
-				    !(rt->dst.neighbour->nud_state &
-					    NUD_VALID)) {
-					if (rt->dst.neighbour)
-						neigh_event_send(rt->dst.neighbour, NULL);
-					ip_rt_put(rth);
-					rt_drop(rt);
-					goto do_next;
-				}
+	peer = inet_getpeer_v4(daddr, 1);
+	if (peer) {
+		peer->redirect_learned.a4 = new_gw;
 
-				netevent.old = &rth->dst;
-				netevent.new = &rt->dst;
-				call_netevent_notifiers(NETEVENT_REDIRECT,
-							&netevent);
+		inet_putpeer(peer);
 
-				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt, NULL, rt->fl.oif))
-					ip_rt_put(rt);
-				goto do_next;
-			}
-		do_next:
-			;
-		}
+		atomic_inc(&__rt_peer_genid);
 	}
 	return;
 
@@ -1678,6 +1590,31 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
+static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
+{
+	struct rtable *rt = (struct rtable *) dst;
+	__be32 orig_gw = rt->rt_gateway;
+
+	dst_confirm(&rt->dst);
+
+	neigh_release(rt->dst.neighbour);
+	rt->dst.neighbour = NULL;
+
+	rt->rt_gateway = peer->redirect_learned.a4;
+	if (arp_bind_neighbour(&rt->dst) ||
+	    !(rt->dst.neighbour->nud_state & NUD_VALID)) {
+		if (rt->dst.neighbour)
+			neigh_event_send(rt->dst.neighbour, NULL);
+		rt->rt_gateway = orig_gw;
+		return -EAGAIN;
+	} else {
+		rt->rt_flags |= RTCF_REDIRECTED;
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE,
+					rt->dst.neighbour);
+	}
+	return 0;
+}
+
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rtable *rt = (struct rtable *) dst;
@@ -1694,6 +1631,12 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 		if (peer && peer->pmtu_expires)
 			check_peer_pmtu(dst, peer);
 
+		if (peer && peer->redirect_learned.a4 &&
+		    peer->redirect_learned.a4 != rt->rt_gateway) {
+			if (check_peer_redir(dst, peer))
+				return NULL;
+		}
+
 		rt->rt_peer_genid = rt_peer_genid();
 	}
 	return dst;
@@ -1830,6 +1773,11 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 
 		if (peer->pmtu_expires)
 			check_peer_pmtu(&rt->dst, peer);
+		if (peer->redirect_learned.a4 &&
+		    peer->redirect_learned.a4 != rt->rt_gateway) {
+			rt->rt_gateway = peer->redirect_learned.a4;
+			rt->rt_flags |= RTCF_REDIRECTED;
+		}
 	} else {
 		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
 			rt->fi = fi;
-- 
1.7.4

