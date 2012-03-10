From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipv4: Allow administrative updates of inetpeer cache metrics
Date: Sun, 11 Mar 2012 00:49:05 +1100
Message-ID: <20120310134905.GA3703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:47990 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753637Ab2CJNtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 08:49:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Sorry, I totally forgot about this issue that we talked about
previously.

ipv4: Allow administrative updates of inetpeer cache metrics

As it stands we only ever copy the metrics from fib table once
for a given inetpeer cache entry.  This means that if the fib
table is subsequently changed by the administrator then that
will never make it into the existing inetpeer cache entry.

This patch fixes this by recording the genid and checking it
every time we use the inetpeer entry.

I have no idea why we still have this code in IPv6 when we no
longer store metrics in the inetpeer cache.  The changes to
IPv6 should result in exactly the same semantics as before.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 06b795d..b4a7694 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -40,6 +40,7 @@ struct inet_peer {
 	unsigned long		pmtu_expires;
 	u32			pmtu_orig;
 	u32			pmtu_learned;
+	int			metrics_genid;
 	struct inetpeer_addr_base redirect_learned;
 	/*
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
@@ -66,9 +67,16 @@ void			inet_initpeers(void) __init;
 
 #define INETPEER_METRICS_NEW	(~(u32) 0)
 
-static inline bool inet_metrics_new(const struct inet_peer *p)
+static inline void inet_metrics_init(struct inet_peer *p, u32 *metrics,
+				     int genid)
 {
-	return p->metrics[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
+	if (p->metrics[RTAX_LOCK-1] != INETPEER_METRICS_NEW &&
+	    p->metrics_genid == genid)
+
+		return;
+
+	p->metrics_genid = genid;
+	memcpy(p->metrics, metrics, sizeof(u32) * RTAX_MAX);
 }
 
 /* can be called with or without local BH being disabled */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcacf54..896b95f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -150,6 +150,11 @@ static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
 
+static inline int rt_genid(struct net *net)
+{
+	return atomic_read(&net->ipv4.rt_genid);
+}
+
 static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			    int how)
 {
@@ -170,8 +175,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 		unsigned long prev, new;
 
 		p = peer->metrics;
-		if (inet_metrics_new(peer))
-			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+		inet_metrics_init(peer, old_p, rt_genid(dev_net(rt->dst.dev)));
 
 		new = (unsigned long) p;
 		prev = cmpxchg(&dst->_metrics, old, new);
@@ -310,11 +314,6 @@ static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx,
 		& rt_hash_mask;
 }
 
-static inline int rt_genid(struct net *net)
-{
-	return atomic_read(&net->ipv4.rt_genid);
-}
-
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;
@@ -1952,9 +1951,8 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
 	if (peer) {
 		rt->rt_peer_genid = rt_peer_genid();
-		if (inet_metrics_new(peer))
-			memcpy(peer->metrics, fi->fib_metrics,
-			       sizeof(u32) * RTAX_MAX);
+		inet_metrics_init(peer, fi->fib_metrics,
+				  rt_genid(dev_net(rt->dst.dev)));
 		dst_init_metrics(&rt->dst, peer->metrics, false);
 
 		check_peer_pmtu(&rt->dst, peer);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c2e3ab..580b20b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -106,8 +106,7 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 		unsigned long prev, new;
 
 		p = peer->metrics;
-		if (inet_metrics_new(peer))
-			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+		inet_metrics_init(peer, old_p, 0);
 
 		new = (unsigned long) p;
 		prev = cmpxchg(&dst->_metrics, old, new);

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
