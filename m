From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/16] inet: Minimize use of cached route inetpeer.
Date: Tue, 10 Jul 2012 08:07:36 -0700 (PDT)
Message-ID: <20120710.080736.1803864903717630279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab2GJPHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:36 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A65E258662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Only use it in the absolutely required cases:

1) COW'ing metrics

2) ipv4 PMTU

3) ipv4 redirects

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c       |    3 ++-
 net/ipv4/route.c      |   32 ++++++++++++++++----------------
 net/ipv6/icmp.c       |    4 +++-
 net/ipv6/ip6_output.c |   10 ++++++++--
 net/ipv6/ndisc.c      |    8 ++++++--
 5 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4bce5a2..4a04944 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -254,9 +254,10 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 
 	/* Limit if icmp type is enabled in ratemask. */
 	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask) {
-		struct inet_peer *peer = rt_get_peer_create(rt, fl4->daddr);
+		struct inet_peer *peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
 		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
+		inet_putpeer(peer);
 	}
 out:
 	return rc;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 78d8154..e376354 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1289,20 +1289,15 @@ static void ip_select_fb_ident(struct iphdr *iph)
 
 void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 {
-	struct rtable *rt = (struct rtable *) dst;
-
-	if (rt && !(rt->dst.flags & DST_NOPEER)) {
-		struct inet_peer *peer = rt_get_peer_create(rt, rt->rt_dst);
+	struct net *net = dev_net(dst->dev);
+	struct inet_peer *peer;
 
-		/* If peer is attached to destination, it is never detached,
-		   so that we need not to grab a lock to dereference it.
-		 */
-		if (peer) {
-			iph->id = htons(inet_getid(peer, more));
-			return;
-		}
-	} else if (!rt)
-		pr_debug("rt_bind_peer(0) @%p\n", __builtin_return_address(0));
+	peer = inet_getpeer_v4(net->ipv4.peers, iph->daddr, 1);
+	if (peer) {
+		iph->id = htons(inet_getid(peer, more));
+		inet_putpeer(peer);
+		return;
+	}
 
 	ip_select_fb_ident(iph);
 }
@@ -1492,6 +1487,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	struct rtable *rt = skb_rtable(skb);
 	struct in_device *in_dev;
 	struct inet_peer *peer;
+	struct net *net;
 	int log_martians;
 
 	rcu_read_lock();
@@ -1503,7 +1499,8 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
 	rcu_read_unlock();
 
-	peer = rt_get_peer_create(rt, rt->rt_dst);
+	net = dev_net(rt->dst.dev);
+	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
 	if (!peer) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
 		return;
@@ -1520,7 +1517,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	 */
 	if (peer->rate_tokens >= ip_rt_redirect_number) {
 		peer->rate_last = jiffies;
-		return;
+		goto out_put_peer;
 	}
 
 	/* Check for load limit; set rate_last to the latest sent
@@ -1541,6 +1538,8 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 					     &rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
+out_put_peer:
+	inet_putpeer(peer);
 }
 
 static int ip_error(struct sk_buff *skb)
@@ -1583,7 +1582,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	}
 
-	peer = rt_get_peer_create(rt, rt->rt_dst);
+	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
 
 	send = true;
 	if (peer) {
@@ -1596,6 +1595,7 @@ static int ip_error(struct sk_buff *skb)
 			peer->rate_tokens -= ip_rt_error_cost;
 		else
 			send = false;
+		inet_putpeer(peer);
 	}
 	if (send)
 		icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index c7da142..a113f7d 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -194,8 +194,10 @@ static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 		if (rt->rt6i_dst.plen < 128)
 			tmo >>= ((128 - rt->rt6i_dst.plen)>>5);
 
-		peer = rt6_get_peer_create(rt);
+		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
 		res = inet_peer_xrlim_allow(peer, tmo);
+		if (peer)
+			inet_putpeer(peer);
 	}
 	dst_release(dst);
 	return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c6af596..5b2d63e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -466,13 +466,15 @@ int ip6_forward(struct sk_buff *skb)
 		else
 			target = &hdr->daddr;
 
-		peer = rt6_get_peer_create(rt);
+		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
 
 		/* Limit redirects both by destination (here)
 		   and by source (inside ndisc_send_redirect)
 		 */
 		if (inet_peer_xrlim_allow(peer, 1*HZ))
 			ndisc_send_redirect(skb, target);
+		if (peer)
+			inet_putpeer(peer);
 	} else {
 		int addrtype = ipv6_addr_type(&hdr->saddr);
 
@@ -592,10 +594,14 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 	int old, new;
 
 	if (rt && !(rt->dst.flags & DST_NOPEER)) {
-		struct inet_peer *peer = rt6_get_peer_create(rt);
+		struct inet_peer *peer;
+		struct net *net;
 
+		net = dev_net(rt->dst.dev);
+		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
 		if (peer) {
 			fhdr->identification = htonl(inet_getid(peer, 0));
+			inet_putpeer(peer);
 			return;
 		}
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69a6330..0fddd57 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1486,6 +1486,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	int rd_len;
 	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
+	bool ret;
 
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK(2, warn, "Redirect: no link-local address on %s\n",
@@ -1519,8 +1520,11 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			  "Redirect: destination is not a neighbour\n");
 		goto release;
 	}
-	peer = rt6_get_peer_create(rt);
-	if (!inet_peer_xrlim_allow(peer, 1*HZ))
+	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
+	ret = inet_peer_xrlim_allow(peer, 1*HZ);
+	if (peer)
+		inet_putpeer(peer);
+	if (!ret)
 		goto release;
 
 	if (dev->addr_len) {
-- 
1.7.10.4
