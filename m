From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] route: Invalidate the peer metrics along with the
 routing cache
Date: Thu, 2 Feb 2012 11:14:09 +0100
Message-ID: <20120202101408.GG23142@secunet.com>
References: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48790 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab2BBKOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:14:16 -0500
Content-Disposition: inline
In-Reply-To: <20120202101141.GC23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We initialize the routing metrics with the cached values in
rt_init_metrics(). So if we have the metrics cached on the
inetpeer, we ignore the user configured fib_metrics. Therefore we
add a global peer_genid and a genid on the inetpeer. The metrics
on the inetpeer are valid as long as the global peer_genid and the
genid on the inetpeer are equal. The global peer_genid is incremented
by rt_cache_invalidate(). We reset the peer metrics with
inetpeer_reset_metrics() if the global peer_genid and the genid
on the inetpeer differ.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/inetpeer.h |    1 +
 include/net/ip.h       |    1 +
 net/ipv4/inetpeer.c    |    2 ++
 net/ipv4/route.c       |   20 ++++++++++++++++++--
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index d97211a..44dd34a 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -41,6 +41,7 @@ struct inet_peer {
 	struct inetpeer_metrics __rcu *metrics;
 	u32			rate_tokens;	/* rate limiting for ICMP */
 	int			redirect_genid;
+	int			genid;
 	unsigned long		rate_last;
 	unsigned long		pmtu_expires;
 	u32			pmtu_orig;
diff --git a/include/net/ip.h b/include/net/ip.h
index 775009f..80c6642 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -229,6 +229,7 @@ extern struct ctl_path net_ipv4_ctl_path[];
 extern int inet_peer_threshold;
 extern int inet_peer_minttl;
 extern int inet_peer_maxttl;
+extern int peer_genid;
 
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 2bf23a9..2218b3c 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -102,6 +102,7 @@ int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries m
 int inet_peer_minttl __read_mostly = 120 * HZ;	/* TTL under high load: 120 sec */
 int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min */
 
+int peer_genid = 0;
 
 /* Called from ip_output.c:ip_init  */
 void __init inet_initpeers(void)
@@ -457,6 +458,7 @@ relookup:
 		p->pmtu_expires = 0;
 		p->pmtu_orig = 0;
 		p->redirect_genid = 0;
+		p->genid = peer_genid;
 		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1a88484..4012e00 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -934,6 +934,7 @@ static void rt_cache_invalidate(struct net *net)
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
 	redirect_genid++;
+	peer_genid++;
 }
 
 /*
@@ -1933,9 +1934,18 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
+static void peer_reset_learned(struct inet_peer *peer)
+{
+	peer->pmtu_expires = 0;
+	if (inetpeer_reset_metrics(peer))
+		peer->genid = peer_genid;
+}
+
+/* called in rcu_read_lock() section */
 static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
+	u32 *peer_metrics;
 	struct inet_peer *peer;
 	int create = 0;
 
@@ -1947,11 +1957,17 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
 	if (peer) {
-		u32 *peer_metrics = inetpeer_metrics(peer);
+		if (peer->genid != peer_genid)
+			peer_reset_learned(peer);
+
+		peer_metrics = inetpeer_metrics(peer);
 		rt->rt_peer_genid = rt_peer_genid();
-		if (inet_metrics_new(peer))
+		if (inet_metrics_new(peer)) {
 			memcpy(peer_metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
+
+			peer->pmtu_orig = fi->fib_mtu;
+		}
 		dst_init_metrics(&rt->dst, peer_metrics, false);
 
 		check_peer_pmtu(&rt->dst, peer);
-- 
1.7.0.4
