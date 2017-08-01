From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 09/10] net: ipv4: Support for sockets bound to enslaved device
Date: Mon, 31 Jul 2017 20:13:25 -0700
Message-ID: <1501557206-27503-10-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38279 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdHADNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id e3so506497pfc.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:49 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for sockets bound to a network interface enslaved to an
L3 Master device (e.g, VRF). Currently for VRF, skb->dev points to the
VRF device meaning socket lookups only consider this device index. The
real ingress device index is saved to IPCB(skb)->iif and the VRF driver
marks the skb with IPSKB_L3SLAVE to know that the real ingress device
is an enslaved one without having to lookup the iif.

Use those flags to add the enslaved device index to the socket lookup
and allow sk->sk_bound_dev_if to match either dif (VRF device) or sdif
(enslaved device).

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/igmp.h          |  3 ++-
 include/net/inet_hashtables.h | 10 ++++++----
 include/net/ip.h              | 10 ++++++++++
 include/net/tcp.h             | 10 ++++++++++
 net/ipv4/igmp.c               |  6 ++++--
 net/ipv4/inet_hashtables.c    | 11 +++++++----
 net/ipv4/raw.c                |  7 +++++--
 net/ipv4/tcp_ipv4.c           |  6 ++++--
 net/ipv4/udp.c                | 11 ++++++++---
 9 files changed, 56 insertions(+), 18 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 97caf1821de8..f8231854b5d6 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -118,7 +118,8 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		struct ip_msfilter __user *optval, int __user *optlen);
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
-extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
+extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt,
+			  int dif, int sdif);
 extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index c5f4dc3c06e4..2de3d4bc00ba 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -259,22 +259,24 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 				   (((__force __u64)(__be32)(__daddr)) << 32) | \
 				   ((__force __u64)(__be32)(__saddr)))
 #endif /* __BIG_ENDIAN */
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_addrpair == (__cookie))			&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
+	   ((__sk)->sk_bound_dev_if == (__dif))			||	\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))		&&	\
 	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const int __name __deprecated __attribute__((unused))
 
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))		&&		\
 	 ((__sk)->sk_daddr	== (__saddr))		&&		\
 	 ((__sk)->sk_rcv_saddr	== (__daddr))		&&		\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
+	   ((__sk)->sk_bound_dev_if == (__dif))		||		\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))	&&		\
 	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 821cedcc8e73..e10da8814dba 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -78,6 +78,16 @@ struct ipcm_cookie {
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
 #define PKTINFO_SKB_CB(skb) ((struct in_pktinfo *)((skb)->cb))
 
+/* return enslaved device index if relevant */
+static inline int ip_sdif(struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv4_l3mdev_skb(IPCB(skb)->flags))
+		return IPCB(skb)->iif;
+#endif
+	return 0;
+}
+
 struct ip_ra_chain {
 	struct ip_ra_chain __rcu *next;
 	struct sock		*sk;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 12d68335acd4..19827dd05dcc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -861,6 +861,16 @@ static inline bool inet_exact_dif_match(struct net *net, struct sk_buff *skb)
 	return false;
 }
 
+/* TCP_SKB_CB reference means this can not be used from early demux */
+static inline int tcp_v4_sdif(struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv4_l3mdev_skb(TCP_SKB_CB(skb)->header.h4.flags))
+		return TCP_SKB_CB(skb)->header.h4.iif;
+#endif
+	return 0;
+}
+
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 28f14afd0dd3..5bc8570c2ec3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2549,7 +2549,8 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 /*
  * check if a multicast source filter allows delivery for a given <src,dst,intf>
  */
-int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
+int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr,
+		   int dif, int sdif)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *pmc;
@@ -2564,7 +2565,8 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	rcu_read_lock();
 	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == loc_addr &&
-		    pmc->multi.imr_ifindex == dif)
+		    (pmc->multi.imr_ifindex == dif ||
+		     (sdif && pmc->multi.imr_ifindex == sdif)))
 			break;
 	}
 	ret = inet->mc_all;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 5fe9300795b8..12c387264a65 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -275,6 +275,7 @@ struct sock *__inet_lookup_established(struct net *net,
 	__be32 daddr = params->daddr.ipv4;
 	__be16 sport = params->sport;
 	u16 hnum = params->hnum;
+	int sdif = params->sdif;
 	int dif = params->dif;
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
@@ -292,11 +293,12 @@ struct sock *__inet_lookup_established(struct net *net,
 		if (sk->sk_hash != hash)
 			continue;
 		if (likely(INET_MATCH(sk, net, acookie,
-				      saddr, daddr, ports, dif))) {
+				      saddr, daddr, ports, dif, sdif))) {
 			if (unlikely(!refcount_inc_not_zero(&sk->sk_refcnt)))
 				goto out;
 			if (unlikely(!INET_MATCH(sk, net, acookie,
-						 saddr, daddr, ports, dif))) {
+						 saddr, daddr, ports,
+						 dif, sdif))) {
 				sock_gen_put(sk);
 				goto begin;
 			}
@@ -327,9 +329,10 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	__be32 daddr = inet->inet_rcv_saddr;
 	__be32 saddr = inet->inet_daddr;
 	int dif = sk->sk_bound_dev_if;
+	struct net *net = sock_net(sk);
+	int sdif = l3mdev_master_ifindex_by_index(net, dif);
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
-	struct net *net = sock_net(sk);
 	unsigned int hash = inet_ehashfn(net, daddr, lport,
 					 saddr, inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
@@ -345,7 +348,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 			continue;
 
 		if (likely(INET_MATCH(sk2, net, acookie,
-					 saddr, daddr, ports, dif))) {
+					 saddr, daddr, ports, dif, sdif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4da5d87a61a5..a94f8f115b6e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -132,7 +132,8 @@ struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 		bool dev_match;
 
 		dev_match = (!sk->sk_bound_dev_if ||
-				sk->sk_bound_dev_if == params->dif);
+				sk->sk_bound_dev_if == params->dif ||
+				sk->sk_bound_dev_if == params->sdif);
 
 		if (net_eq(sock_net(sk), net) &&
 		    inet->inet_num == params->hnum &&
@@ -186,6 +187,7 @@ static int __raw_v4_input(struct sk_buff *skb, const struct iphdr *iph,
 		.daddr.ipv4 = iph->daddr,
 		.hnum = iph->protocol,
 		.dif  = skb->dev->ifindex,
+		.sdif = ip_sdif(skb),
 	};
 	int delivered = 0;
 	struct sock *sk;
@@ -195,7 +197,7 @@ static int __raw_v4_input(struct sk_buff *skb, const struct iphdr *iph,
 		delivered = 1;
 		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
 		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
-				   skb->dev->ifindex)) {
+				   skb->dev->ifindex, params.sdif)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
@@ -316,6 +318,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 		struct sk_lookup params = {
 			.hnum = protocol,
 			.dif = skb->dev->ifindex,
+			.sdif = ip_sdif(skb),
 		};
 
 		iph = (const struct iphdr *)skb->data;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a83d1d437abc..415722007a24 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1664,7 +1664,9 @@ EXPORT_SYMBOL(tcp_filter);
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
-	struct sk_lookup params = { };
+	struct sk_lookup params = {
+		.sdif = ip_sdif(skb),
+	};
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	bool refcounted;
@@ -1846,8 +1848,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 			.daddr.ipv4 = iph->daddr,
 			.sport = th->source,
 			.dport = th->dest,
-			.hnum  = ntohs(th->dest),
 			.dif   = inet_iif(skb),
+			.sdif  = tcp_v4_sdif(skb),
 		};
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo, skb,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 132a8f070d16..5c9fffed9c4a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -485,6 +485,7 @@ struct sock *__udp4_lib_lookup(struct net *net, struct sk_lookup *params,
 	u32 hash = 0;
 
 	params->hnum = hnum;
+	params->sdif = ip_sdif(skb);
 	params->exact_dif = udp_lib_exact_dif_match(net, skb);
 
 	if (hslot->count > 10) {
@@ -597,9 +598,10 @@ static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 	    (inet->inet_dport != params->sport && inet->inet_dport) ||
 	    (inet->inet_rcv_saddr && inet->inet_rcv_saddr != loc_addr) ||
 	    ipv6_only_sock(sk) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif))
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif &&
+	     sk->sk_bound_dev_if != params->sdif))
 		return false;
-	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, params->dif))
+	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, params->dif, params->sdif))
 		return false;
 	return true;
 }
@@ -1970,6 +1972,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		.dport = uh->dest,
 		.hnum = hnum,
 		.dif = skb->dev->ifindex,
+		.sdif = ip_sdif(skb),
 	};
 
 	if (use_hash2) {
@@ -2210,7 +2213,8 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		if (INET_MATCH(sk, net, acookie, params->saddr.ipv4,
-			       params->daddr.ipv4, ports, params->dif))
+			       params->daddr.ipv4, ports, params->dif,
+			       params->sdif))
 			return sk;
 		/* Only check first socket in chain */
 		break;
@@ -2223,6 +2227,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct sk_lookup params = {
 		.dif = skb->dev->ifindex,
+		.sdif = ip_sdif(skb),
 	};
 	const struct iphdr *iph;
 	const struct udphdr *uh;
-- 
2.1.4
