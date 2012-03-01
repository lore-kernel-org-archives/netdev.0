From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] route: Remove redirect_genid
Date: Thu, 1 Mar 2012 07:23:16 +0100
Message-ID: <20120301062316.GD15404@secunet.com>
References: <20120301062159.GB15404@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52580 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757073Ab2CAGXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 01:23:33 -0500
Content-Disposition: inline
In-Reply-To: <20120301062159.GB15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we invalidate the inetpeer tree along with the routing cache now,
we don't need a genid to reset the redirect handling when the routing
cache is flushed.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/inetpeer.h |    1 -
 net/ipv4/inetpeer.c    |    1 -
 net/ipv4/route.c       |   19 +++++--------------
 3 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index ff04a33..b94765e 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -35,7 +35,6 @@ struct inet_peer {
 
 	u32			metrics[RTAX_MAX];
 	u32			rate_tokens;	/* rate limiting for ICMP */
-	int			redirect_genid;
 	unsigned long		rate_last;
 	unsigned long		pmtu_expires;
 	u32			pmtu_orig;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 897953d..4b7c16a 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -498,7 +498,6 @@ relookup:
 		p->rate_last = 0;
 		p->pmtu_expires = 0;
 		p->pmtu_orig = 0;
-		p->redirect_genid = 0;
 		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 		INIT_LIST_HEAD(&p->gc_list);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 23ce0c1..a796017 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -132,7 +132,6 @@ static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
 static int rt_chain_length_max __read_mostly	= 20;
-static int redirect_genid;
 
 static struct delayed_work expires_work;
 static unsigned long expires_ljiffies;
@@ -937,7 +936,6 @@ static void rt_cache_invalidate(struct net *net)
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-	redirect_genid++;
 	inetpeer_invalidate_tree(AF_INET);
 }
 
@@ -1485,15 +1483,11 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 					rt_bind_peer(rt, rt->rt_dst, 1);
 
 				peer = rt->peer;
-				if (peer) {
-					if (peer->redirect_learned.a4 != new_gw ||
-					    peer->redirect_genid != redirect_genid) {
-						peer->redirect_learned.a4 = new_gw;
-						peer->redirect_genid = redirect_genid;
-						atomic_inc(&__rt_peer_genid);
-					}
-					check_peer_redir(&rt->dst, peer);
+				if (peer && peer->redirect_learned.a4 != new_gw) {
+					peer->redirect_learned.a4 = new_gw;
+					atomic_inc(&__rt_peer_genid);
 				}
+				check_peer_redir(&rt->dst, peer);
 			}
 		}
 	}
@@ -1794,8 +1788,6 @@ static void ipv4_validate_peer(struct rtable *rt)
 		if (peer) {
 			check_peer_pmtu(&rt->dst, peer);
 
-			if (peer->redirect_genid != redirect_genid)
-				peer->redirect_learned.a4 = 0;
 			if (peer->redirect_learned.a4 &&
 			    peer->redirect_learned.a4 != rt->rt_gateway)
 				check_peer_redir(&rt->dst, peer);
@@ -1959,8 +1951,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 		dst_init_metrics(&rt->dst, peer->metrics, false);
 
 		check_peer_pmtu(&rt->dst, peer);
-		if (peer->redirect_genid != redirect_genid)
-			peer->redirect_learned.a4 = 0;
+
 		if (peer->redirect_learned.a4 &&
 		    peer->redirect_learned.a4 != rt->rt_gateway) {
 			rt->rt_gateway = peer->redirect_learned.a4;
-- 
1.7.0.4
