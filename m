From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] inetpeer: Add support for VRFs
Date: Sun, 23 Aug 2015 08:26:04 -0600
Message-ID: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36705 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbbHWO0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 10:26:41 -0400
Received: by iodv127 with SMTP id v127so124120088iod.3
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 07:26:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer caches based on address only, so duplicate IP addresses within
a namespace return the same cached entry. Similar to IP fragments handle
duplicate addresses across VRFs by adding the VRF master device index to
the lookup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inetpeer.h | 11 ++++++++++-
 net/ipv4/icmp.c        |  3 ++-
 net/ipv4/inetpeer.c    |  5 +++++
 net/ipv4/ip_fragment.c |  3 ++-
 net/ipv4/route.c       |  7 +++++--
 5 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 002f0bd27001..a75b648b8545 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -26,6 +26,9 @@ struct inetpeer_addr_base {
 struct inetpeer_addr {
 	struct inetpeer_addr_base	addr;
 	__u16				family;
+#if IS_ENABLED(CONFIG_NET_VRF)
+	int vif;
+#endif
 };
 
 struct inet_peer {
@@ -78,12 +81,15 @@ struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 
 static inline struct inet_peer *inet_getpeer_v4(struct inet_peer_base *base,
 						__be32 v4daddr,
-						int create)
+						int vif, int create)
 {
 	struct inetpeer_addr daddr;
 
 	daddr.addr.a4 = v4daddr;
 	daddr.family = AF_INET;
+#if IS_ENABLED(CONFIG_NET_VRF)
+	daddr.vif = vif;
+#endif
 	return inet_getpeer(base, &daddr, create);
 }
 
@@ -95,6 +101,9 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 
 	daddr.addr.in6 = *v6daddr;
 	daddr.family = AF_INET6;
+#if IS_ENABLED(CONFIG_NET_VRF)
+	daddr.vif = 0;   /* placeholder until VRF suppoort is added to IPv6 */
+#endif
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
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 241afd743d2c..b5f268a3ea6b 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -170,6 +170,11 @@ static int addr_compare(const struct inetpeer_addr *a,
 		return 1;
 	}
 
+#if IS_ENABLED(CONFIG_NET_VRF)
+	if (a->vif != b->vif)
+		return a->vif < b->vif ? -1 : 1;
+#endif
+
 	return 0;
 }
 
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
index 2403e85107f0..6805d57152b9 100644
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
2.3.2 (Apple Git-55)
