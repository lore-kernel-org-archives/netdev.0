From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] net: Add support for VRFs to inetpeer cache
Date: Thu, 27 Aug 2015 16:07:03 -0700
Message-ID: <1440716823-19568-6-git-send-email-dsa@cumulusnetworks.com>
References: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33926 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbbH0XHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:07:16 -0400
Received: by pabzx8 with SMTP id zx8so40407693pab.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:07:15 -0700 (PDT)
In-Reply-To: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer caches based on address only, so duplicate IP addresses within
a namespace return the same cached entry. Enhance the ipv4 address key
to contain both the IPv4 address and VRF device index.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inetpeer.h | 17 ++++++++++++-----
 net/ipv4/icmp.c        |  3 ++-
 net/ipv4/ip_fragment.c |  3 ++-
 net/ipv4/route.c       |  7 +++++--
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index e34f98aa93b1..5ec3827b514d 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -15,11 +15,17 @@
 #include <net/ipv6.h>
 #include <linux/atomic.h>
 
+/* IPv4 address key for cache lookups */
+struct ipv4_addr_key {
+	__be32	addr;
+	int	vif;
+};
+
 #define INETPEER_MAXKEYSZ   (sizeof(struct in6_addr) / sizeof(u32))
 
 struct inetpeer_addr {
 	union {
-		__be32			a4;
+		struct ipv4_addr_key	a4;
 		struct in6_addr		a6;
 		u32			key[INETPEER_MAXKEYSZ];
 	};
@@ -71,13 +77,13 @@ void inet_initpeers(void) __init;
 
 static inline void inetpeer_set_addr_v4(struct inetpeer_addr *iaddr, __be32 ip)
 {
-	iaddr->a4 = ip;
+	iaddr->a4.addr = ip;
 	iaddr->family = AF_INET;
 }
 
 static inline __be32 inetpeer_get_addr_v4(struct inetpeer_addr *iaddr)
 {
-	return iaddr->a4;
+	return iaddr->a4.addr;
 }
 
 static inline void inetpeer_set_addr_v6(struct inetpeer_addr *iaddr,
@@ -99,11 +105,12 @@ struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 
 static inline struct inet_peer *inet_getpeer_v4(struct inet_peer_base *base,
 						__be32 v4daddr,
-						int create)
+						int vif, int create)
 {
 	struct inetpeer_addr daddr;
 
-	daddr.a4 = v4daddr;
+	daddr.a4.addr = v4daddr;
+	daddr.a4.vif = vif;
 	daddr.family = AF_INET;
 	return inet_getpeer(base, &daddr, create);
 }
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f16488efa1c8..79fe05befcae 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -309,9 +309,10 @@ static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 
 	rc = false;
 	if (icmp_global_allow()) {
+		int vif = vrf_master_ifindex(dst->dev);
 		struct inet_peer *peer;
 
-		peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
+		peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, vif, 1);
 		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
 		if (peer)
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 15762e758861..fa7f15305f9a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -151,7 +151,8 @@ static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
 	qp->vif = arg->vif;
 	qp->user = arg->user;
 	qp->peer = sysctl_ipfrag_max_dist ?
-		inet_getpeer_v4(net->ipv4.peers, arg->iph->saddr, 1) : NULL;
+		inet_getpeer_v4(net->ipv4.peers, arg->iph->saddr, arg->vif, 1) :
+		NULL;
 }
 
 static void ip4_frag_free(struct inet_frag_queue *q)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f3087aaa6dd8..6b91879e9cbe 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -838,6 +838,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	struct inet_peer *peer;
 	struct net *net;
 	int log_martians;
+	int vif;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(rt->dst.dev);
@@ -846,10 +847,11 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		return;
 	}
 	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
+	vif = vrf_master_ifindex_rcu(rt->dst.dev);
 	rcu_read_unlock();
 
 	net = dev_net(rt->dst.dev);
-	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
+	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, vif, 1);
 	if (!peer) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST,
 			  rt_nexthop(rt, ip_hdr(skb)->daddr));
@@ -938,7 +940,8 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	}
 
-	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
+	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr,
+			       vrf_master_ifindex(skb->dev), 1);
 
 	send = true;
 	if (peer) {
-- 
1.9.1
