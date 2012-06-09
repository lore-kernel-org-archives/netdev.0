From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] inet: Create and use rt{,6}_get_peer_create().
Date: Fri, 08 Jun 2012 23:39:43 -0700 (PDT)
Message-ID: <20120608.233943.1669701655411882794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab2FIGjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 02:39:46 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 32CDA583E79
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 23:39:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There's a lot of places that open-code rt{,6}_get_peer() only because
they want to set 'create' to one.  So add an rt{,6}_get_peer_create()
for their sake.

There were also a few spots open-coding plain rt{,6}_get_peer() and
those are transformed here as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |   17 +++++++++++++----
 include/net/route.h     |   14 ++++++++++++--
 net/ipv4/icmp.c         |    5 ++---
 net/ipv4/route.c        |   35 +++++++++--------------------------
 net/ipv4/tcp_ipv4.c     |    4 +---
 net/ipv6/icmp.c         |    6 +++---
 net/ipv6/ip6_output.c   |   11 ++++-------
 net/ipv6/ndisc.c        |    6 +++---
 net/ipv6/route.c        |    5 +----
 net/ipv6/tcp_ipv6.c     |    4 +---
 10 files changed, 49 insertions(+), 58 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 37c1a1e..73d7502 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -53,18 +53,27 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
 	return (flags >> 3) & 7;
 }
 
-extern void			rt6_bind_peer(struct rt6_info *rt,
-					      int create);
+extern void rt6_bind_peer(struct rt6_info *rt, int create);
 
-static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
+static inline struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
 {
 	if (rt->rt6i_peer)
 		return rt->rt6i_peer;
 
-	rt6_bind_peer(rt, 0);
+	rt6_bind_peer(rt, create);
 	return rt->rt6i_peer;
 }
 
+static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
+{
+	return __rt6_get_peer(rt, 0);
+}
+
+static inline struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
+{
+	return __rt6_get_peer(rt, 1);
+}
+
 extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct net *net,
diff --git a/include/net/route.h b/include/net/route.h
index ed2b78e..433fc6c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -296,15 +296,25 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 
 extern void rt_bind_peer(struct rtable *rt, __be32 daddr, int create);
 
-static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
+static inline struct inet_peer *__rt_get_peer(struct rtable *rt, __be32 daddr, int create)
 {
 	if (rt->peer)
 		return rt->peer;
 
-	rt_bind_peer(rt, daddr, 0);
+	rt_bind_peer(rt, daddr, create);
 	return rt->peer;
 }
 
+static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
+{
+	return __rt_get_peer(rt, daddr, 0);
+}
+
+static inline struct inet_peer *rt_get_peer_create(struct rtable *rt, __be32 daddr)
+{
+	return __rt_get_peer(rt, daddr, 1);
+}
+
 static inline int inet_iif(const struct sk_buff *skb)
 {
 	return skb_rtable(skb)->rt_iif;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c75efbd..0c78ef1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -253,9 +253,8 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 
 	/* Limit if icmp type is enabled in ratemask. */
 	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask) {
-		if (!rt->peer)
-			rt_bind_peer(rt, fl4->daddr, 1);
-		rc = inet_peer_xrlim_allow(rt->peer,
+		struct inet_peer *peer = rt_get_peer_create(rt, fl4->daddr);
+		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
 	}
 out:
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2c9f73f..7a4d724 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -162,10 +162,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	struct inet_peer *peer;
 	u32 *p = NULL;
 
-	if (!rt->peer)
-		rt_bind_peer(rt, rt->rt_dst, 1);
-
-	peer = rt->peer;
+	peer = rt_get_peer_create(rt, rt->rt_dst);
 	if (peer) {
 		u32 *old_p = __DST_METRICS_PTR(old);
 		unsigned long prev, new;
@@ -1364,14 +1361,13 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 	struct rtable *rt = (struct rtable *) dst;
 
 	if (rt && !(rt->dst.flags & DST_NOPEER)) {
-		if (rt->peer == NULL)
-			rt_bind_peer(rt, rt->rt_dst, 1);
+		struct inet_peer *peer = rt_get_peer_create(rt, rt->rt_dst);
 
 		/* If peer is attached to destination, it is never detached,
 		   so that we need not to grab a lock to dereference it.
 		 */
-		if (rt->peer) {
-			iph->id = htons(inet_getid(rt->peer, more));
+		if (peer) {
+			iph->id = htons(inet_getid(peer, more));
 			return;
 		}
 	} else if (!rt)
@@ -1481,10 +1477,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rt->rt_gateway != old_gw)
 					continue;
 
-				if (!rt->peer)
-					rt_bind_peer(rt, rt->rt_dst, 1);
-
-				peer = rt->peer;
+				peer = rt_get_peer_create(rt, rt->rt_dst);
 				if (peer) {
 					if (peer->redirect_learned.a4 != new_gw) {
 						peer->redirect_learned.a4 = new_gw;
@@ -1579,9 +1572,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
 	rcu_read_unlock();
 
-	if (!rt->peer)
-		rt_bind_peer(rt, rt->rt_dst, 1);
-	peer = rt->peer;
+	peer = rt_get_peer_create(rt, rt->rt_dst);
 	if (!peer) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
 		return;
@@ -1646,9 +1637,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	}
 
-	if (!rt->peer)
-		rt_bind_peer(rt, rt->rt_dst, 1);
-	peer = rt->peer;
+	peer = rt_get_peer_create(rt, rt->rt_dst);
 
 	send = true;
 	if (peer) {
@@ -1754,9 +1743,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 	dst_confirm(dst);
 
-	if (!rt->peer)
-		rt_bind_peer(rt, rt->rt_dst, 1);
-	peer = rt->peer;
+	peer = rt_get_peer_create(rt, rt->rt_dst);
 	if (peer) {
 		unsigned long pmtu_expires = ACCESS_ONCE(peer->pmtu_expires);
 
@@ -1782,12 +1769,8 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 static void ipv4_validate_peer(struct rtable *rt)
 {
 	if (rt->rt_peer_genid != rt_peer_genid()) {
-		struct inet_peer *peer;
-
-		if (!rt->peer)
-			rt_bind_peer(rt, rt->rt_dst, 0);
+		struct inet_peer *peer = rt_get_peer(rt, rt->rt_dst);
 
-		peer = rt->peer;
 		if (peer) {
 			check_peer_pmtu(&rt->dst, peer);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f485b45..833e8d9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1832,9 +1832,7 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 		peer = inet_getpeer_v4(net, inet->inet_daddr, 1);
 		*release_it = true;
 	} else {
-		if (!rt->peer)
-			rt_bind_peer(rt, inet->inet_daddr, 1);
-		peer = rt->peer;
+		peer = rt_get_peer_create(rt, inet->inet_daddr);
 		*release_it = false;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 091a297..ed89bba 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -188,14 +188,14 @@ static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		int tmo = net->ipv6.sysctl.icmpv6_time;
+		struct inet_peer *peer;
 
 		/* Give more bandwidth to wider prefixes. */
 		if (rt->rt6i_dst.plen < 128)
 			tmo >>= ((128 - rt->rt6i_dst.plen)>>5);
 
-		if (!rt->rt6i_peer)
-			rt6_bind_peer(rt, 1);
-		res = inet_peer_xrlim_allow(rt->rt6i_peer, tmo);
+		peer = rt6_get_peer_create(rt);
+		res = inet_peer_xrlim_allow(peer, tmo);
 	}
 	dst_release(dst);
 	return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 17b8c67..62fcf3e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -463,6 +463,7 @@ int ip6_forward(struct sk_buff *skb)
 	 */
 	if (skb->dev == dst->dev && opt->srcrt == 0 && !skb_sec_path(skb)) {
 		struct in6_addr *target = NULL;
+		struct inet_peer *peer;
 		struct rt6_info *rt;
 
 		/*
@@ -476,13 +477,12 @@ int ip6_forward(struct sk_buff *skb)
 		else
 			target = &hdr->daddr;
 
-		if (!rt->rt6i_peer)
-			rt6_bind_peer(rt, 1);
+		peer = rt6_get_peer_create(rt);
 
 		/* Limit redirects both by destination (here)
 		   and by source (inside ndisc_send_redirect)
 		 */
-		if (inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
+		if (inet_peer_xrlim_allow(peer, 1*HZ))
 			ndisc_send_redirect(skb, target);
 	} else {
 		int addrtype = ipv6_addr_type(&hdr->saddr);
@@ -602,11 +602,8 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 	int old, new;
 
 	if (rt && !(rt->dst.flags & DST_NOPEER)) {
-		struct inet_peer *peer;
+		struct inet_peer *peer = rt6_get_peer_create(rt);
 
-		if (!rt->rt6i_peer)
-			rt6_bind_peer(rt, 1);
-		peer = rt->rt6i_peer;
 		if (peer) {
 			fhdr->identification = htonl(inet_getid(peer, 0));
 			return;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 54f62d3..69a6330 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1472,6 +1472,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	int len = sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
+	struct inet_peer *peer;
 	struct sk_buff *buff;
 	struct icmp6hdr *icmph;
 	struct in6_addr saddr_buf;
@@ -1518,9 +1519,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			  "Redirect: destination is not a neighbour\n");
 		goto release;
 	}
-	if (!rt->rt6i_peer)
-		rt6_bind_peer(rt, 1);
-	if (!inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
+	peer = rt6_get_peer_create(rt);
+	if (!inet_peer_xrlim_allow(peer, 1*HZ))
 		goto release;
 
 	if (dev->addr_len) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4eca013..8a986be 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -99,10 +99,7 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	if (!(rt->dst.flags & DST_HOST))
 		return NULL;
 
-	if (!rt->rt6i_peer)
-		rt6_bind_peer(rt, 1);
-
-	peer = rt->rt6i_peer;
+	peer = rt6_get_peer_create(rt);
 	if (peer) {
 		u32 *old_p = __DST_METRICS_PTR(old);
 		unsigned long prev, new;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1a9cdd0..218433c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1744,9 +1744,7 @@ static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 		peer = inet_getpeer_v6(net, &np->daddr, 1);
 		*release_it = true;
 	} else {
-		if (!rt->rt6i_peer)
-			rt6_bind_peer(rt, 1);
-		peer = rt->rt6i_peer;
+		peer = rt6_get_peer_create(rt);
 		*release_it = false;
 	}
 
-- 
1.7.10
