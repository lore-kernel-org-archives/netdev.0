From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 10/10] net: ipv6: Support for sockets bound to enslaved device
Date: Mon, 31 Jul 2017 20:13:26 -0700
Message-ID: <1501557206-27503-11-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36534 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751889AbdHADNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so567045pgy.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:50 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for sockets bound to a network interface enslaved to an
L3 Master device (e.g, VRF). Currently for VRF, skb->dev points to the
VRF device meaning socket lookups only consider this device index. The
real ingress device index is saved to IP6CB(skb)->iif and the VRF driver
marks the skb with IP6SKB_L3SLAVE to know that the real ingress device
is an enslaved one without having to lookup the iif.

Use those flags to add the enslaved device index to the socket lookup
and allow sk->sk_bound_dev_if to match either dif (VRF device) or sdif
(enslaved device).

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/ipv6.h           | 8 ++++++++
 include/net/inet6_hashtables.h | 5 +++--
 include/net/tcp.h              | 7 +++++++
 net/ipv6/inet6_hashtables.c    | 9 +++++----
 net/ipv6/raw.c                 | 5 ++++-
 net/ipv6/tcp_ipv6.c            | 3 +++
 net/ipv6/udp.c                 | 8 ++++++--
 7 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e1b442996f81..094357907b45 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -153,6 +153,14 @@ static inline int inet6_iif(const struct sk_buff *skb)
 }
 
 /* can not be used in TCP layer after tcp_v6_fill_cb */
+static inline int inet6_sdif(const struct sk_buff *skb)
+{
+	bool l3_slave = ipv6_l3mdev_skb(IP6CB(skb)->flags);
+
+	return l3_slave ? IP6CB(skb)->iif : 0;
+}
+
+/* can not be used in TCP layer after tcp_v6_fill_cb */
 static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
 {
 #if defined(CONFIG_NET_L3_MASTER_DEV)
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 15db41272ff2..0fc5a2fe4ad3 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -94,13 +94,14 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 int inet6_hash(struct sock *sk);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
-#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
+#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_family == AF_INET6)			&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
+	   ((__sk)->sk_bound_dev_if == (__dif))	||			\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))		&&	\
 	 net_eq(sock_net(__sk), (__net)))
 
 #endif /* _INET6_HASHTABLES_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 19827dd05dcc..8a081cff33f8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -848,6 +848,13 @@ static inline int tcp_v6_iif(const struct sk_buff *skb)
 
 	return l3_slave ? skb->skb_iif : TCP_SKB_CB(skb)->header.h6.iif;
 }
+
+static inline int tcp_v6_sdif(const struct sk_buff *skb)
+{
+	bool l3_slave = ipv6_l3mdev_skb(TCP_SKB_CB(skb)->header.h6.flags);
+
+	return l3_slave ? TCP_SKB_CB(skb)->header.h6.iif : 0;
+}
 #endif
 
 /* TCP_SKB_CB reference means this can not be used from early demux */
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 878c03094f2e..06120efb2036 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -74,13 +74,13 @@ struct sock *__inet6_lookup_established(struct net *net,
 		if (sk->sk_hash != hash)
 			continue;
 		if (!INET6_MATCH(sk, net, saddr, daddr, ports,
-				 params->dif))
+				 params->dif, params->sdif))
 			continue;
 		if (unlikely(!refcount_inc_not_zero(&sk->sk_refcnt)))
 			goto out;
 
 		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports,
-				 params->dif))) {
+				 params->dif, params->sdif))) {
 			sock_gen_put(sk);
 			goto begin;
 		}
@@ -188,8 +188,9 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const struct in6_addr *daddr = &sk->sk_v6_rcv_saddr;
 	const struct in6_addr *saddr = &sk->sk_v6_daddr;
 	const int dif = sk->sk_bound_dev_if;
-	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
+	const int sdif = l3mdev_master_ifindex_by_index(net, dif);
+	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	const unsigned int hash = inet6_ehashfn(net, daddr, lport, saddr,
 						inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
@@ -205,7 +206,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 			continue;
 
 		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports,
-				       dif))) {
+				       dif, sdif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 51e651f18ffb..bab365214d17 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -87,7 +87,8 @@ struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 				continue;
 
 			if (sk->sk_bound_dev_if &&
-			    sk->sk_bound_dev_if != params->dif)
+			    sk->sk_bound_dev_if != params->dif &&
+			    sk->sk_bound_dev_if != params->sdif)
 				continue;
 
 			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
@@ -165,6 +166,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 		.daddr.ipv6 = &ipv6_hdr(skb)->daddr,
 		.hnum = nexthdr,
 		.dif  = inet6_iif(skb),
+		.sdif = inet6_sdif(skb),
 	};
 	struct sock *sk;
 	bool delivered = false;
@@ -375,6 +377,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 		struct sk_lookup params = {
 			.hnum = nexthdr,
 			.dif  = inet6_iif(skb),
+			.sdif = inet6_sdif(skb),
 		};
 		/* Note: ipv6_hdr(skb) != skb->data */
 		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 19fee98e1ae0..67bd95cec4ec 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -917,6 +917,7 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 			.sport = th->source,
 			.hnum = ntohs(th->source),
 			.dif  = tcp_v6_iif(skb),
+			.sdif = tcp_v6_sdif(skb),
 		};
 
 		/*
@@ -1414,6 +1415,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct sk_lookup params = {
 		.dif = inet6_iif(skb),
+		.sdif = inet6_sdif(skb),
 	};
 
 	if (skb->pkt_type != PACKET_HOST)
@@ -1577,6 +1579,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 			.sport = th->source,
 			.hnum = ntohs(th->dest),
 			.dif  = tcp_v6_iif(skb),
+			.sdif = tcp_v6_sdif(skb),
 		};
 		struct sock *sk2;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 00b362a8bd91..8cf7c5cbd02a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -220,6 +220,7 @@ struct sock *__udp6_lib_lookup(struct net *net, struct sk_lookup *params,
 	u32 hash = 0;
 
 	params->hnum = hnum;
+	params->sdif = inet6_sdif(skb);
 	params->exact_dif = udp6_lib_exact_dif_match(net, skb);
 
 	if (hslot->count > 10) {
@@ -673,7 +674,8 @@ static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
 	    (inet->inet_dport && inet->inet_dport != params->sport) ||
 	    (!ipv6_addr_any(&sk->sk_v6_daddr) &&
 		    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr)) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif) ||
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif &&
+	     sk->sk_bound_dev_if != params->sdif) ||
 	    (!ipv6_addr_any(&sk->sk_v6_rcv_saddr) &&
 		    !ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr)))
 		return false;
@@ -715,6 +717,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		.dport = uh->dest,
 		.hnum  = hnum,
 		.dif   = inet6_iif(skb),
+		.sdif  = inet6_sdif(skb),
 	};
 
 	if (use_hash2) {
@@ -893,7 +896,7 @@ static struct sock *__udp6_lib_demux_lookup(struct net *net,
 		if (sk->sk_state == TCP_ESTABLISHED &&
 		    INET6_MATCH(sk, net, params->saddr.ipv6,
 				params->daddr.ipv6, ports,
-				params->dif))
+				params->dif, params->sdif))
 			return sk;
 
 		/* Only check first socket in chain */
@@ -912,6 +915,7 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 		.saddr.ipv6 = &ipv6_hdr(skb)->saddr,
 		.daddr.ipv6 = &ipv6_hdr(skb)->daddr,
 		.dif = skb->dev->ifindex,
+		.sdif = inet6_sdif(skb),
 	};
 
 	if (skb->pkt_type != PACKET_HOST)
-- 
2.1.4
