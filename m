From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 05/10] net: ipv6: Convert udp socket lookups to new struct
Date: Mon, 31 Jul 2017 20:13:21 -0700
Message-ID: <1501557206-27503-6-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37358 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHADNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:44 -0400
Received: by mail-pf0-f196.google.com with SMTP id 72so508626pfl.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:44 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert udp6_lib_lookup and __udp6_lib_lookup to use the new sk_lookup
struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/udp.h                   |  12 +--
 net/ipv4/udp_diag.c                 |  33 ++++---
 net/ipv6/netfilter/nf_socket_ipv6.c |  11 ++-
 net/ipv6/udp.c                      | 177 +++++++++++++++++++-----------------
 net/netfilter/xt_TPROXY.c           |  10 +-
 5 files changed, 135 insertions(+), 108 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 5e0ff095dc6d..c5a75e9422c6 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -288,15 +288,9 @@ struct sock *__udp4_lib_lookup(struct net *net, struct sk_lookup *params,
 			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
-struct sock *udp6_lib_lookup(struct net *net,
-			     const struct in6_addr *saddr, __be16 sport,
-			     const struct in6_addr *daddr, __be16 dport,
-			     int dif);
-struct sock *__udp6_lib_lookup(struct net *net,
-			       const struct in6_addr *saddr, __be16 sport,
-			       const struct in6_addr *daddr, __be16 dport,
-			       int dif, struct udp_table *tbl,
-			       struct sk_buff *skb);
+struct sock *udp6_lib_lookup(struct net *net, struct sk_lookup *params);
+struct sock *__udp6_lib_lookup(struct net *net, struct sk_lookup *params,
+			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index d7f6af42ebcc..10738c10c5ae 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -54,13 +54,17 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		sk = __udp4_lib_lookup(net, &params, tbl, NULL);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
-	else if (req->sdiag_family == AF_INET6)
-		sk = __udp6_lib_lookup(net,
-				(struct in6_addr *)req->id.idiag_src,
-				req->id.idiag_sport,
-				(struct in6_addr *)req->id.idiag_dst,
-				req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
+	else if (req->sdiag_family == AF_INET6) {
+		struct sk_lookup params = {
+			.saddr.ipv6 = (struct in6_addr *)req->id.idiag_src,
+			.daddr.ipv6 = (struct in6_addr *)req->id.idiag_dst,
+			.sport = req->id.idiag_sport,
+			.dport = req->id.idiag_dport,
+			.dif   =  req->id.idiag_if,
+		};
+
+		sk = __udp6_lib_lookup(net, &params, tbl, NULL);
+	}
 #endif
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
@@ -212,12 +216,15 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 
 			sk = __udp4_lib_lookup(net, &params, tbl, NULL);
 		} else {
-			sk = __udp6_lib_lookup(net,
-					(struct in6_addr *)req->id.idiag_dst,
-					req->id.idiag_dport,
-					(struct in6_addr *)req->id.idiag_src,
-					req->id.idiag_sport,
-					req->id.idiag_if, tbl, NULL);
+			struct sk_lookup params = {
+				.saddr.ipv6 = (struct in6_addr *)req->id.idiag_dst,
+				.daddr.ipv6 = (struct in6_addr *)req->id.idiag_src,
+				.sport = req->id.idiag_dport,
+				.dport = req->id.idiag_sport,
+				.dif   = req->id.idiag_if,
+			};
+
+			sk = __udp6_lib_lookup(net, &params, tbl, NULL);
 		}
 	}
 #endif
diff --git a/net/ipv6/netfilter/nf_socket_ipv6.c b/net/ipv6/netfilter/nf_socket_ipv6.c
index ebb2bf84232a..c1c193103063 100644
--- a/net/ipv6/netfilter/nf_socket_ipv6.c
+++ b/net/ipv6/netfilter/nf_socket_ipv6.c
@@ -86,14 +86,21 @@ nf_socket_get_sock_v6(struct net *net, struct sk_buff *skb, int doff,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in)
 {
+	struct sk_lookup params = {
+		.saddr.ipv6 = saddr,
+		.daddr.ipv6 = daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = in->ifindex,
+	};
+
 	switch (protocol) {
 	case IPPROTO_TCP:
 		return inet6_lookup(net, &tcp_hashinfo, skb, doff,
 				    saddr, sport, daddr, dport,
 				    in->ifindex);
 	case IPPROTO_UDP:
-		return udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				       in->ifindex);
+		return udp6_lib_lookup(net, &params);
 	}
 
 	return NULL;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5f8b8d766c63..00b362a8bd91 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -67,13 +67,14 @@ static bool udp6_lib_exact_dif_match(struct net *net, struct sk_buff *skb)
 }
 
 static u32 udp6_ehashfn(const struct net *net,
-			const struct in6_addr *laddr,
-			const u16 lport,
-			const struct in6_addr *faddr,
-			const __be16 fport)
+			const struct sk_lookup *params)
 {
+	const struct in6_addr *laddr = params->daddr.ipv6;
+	const struct in6_addr *faddr = params->saddr.ipv6;
 	static u32 udp6_ehash_secret __read_mostly;
 	static u32 udp_ipv6_hash_secret __read_mostly;
+	const __be16 fport = params->sport;
+	const u16 lport = params->hnum;
 
 	u32 lhash, fhash;
 
@@ -127,15 +128,13 @@ static void udp_v6_rehash(struct sock *sk)
 }
 
 static int compute_score(struct sock *sk, struct net *net,
-			 const struct in6_addr *saddr, __be16 sport,
-			 const struct in6_addr *daddr, unsigned short hnum,
-			 int dif, bool exact_dif)
+			 const struct sk_lookup *params)
 {
-	int score;
 	struct inet_sock *inet;
+	int score, rc;
 
 	if (!net_eq(sock_net(sk), net) ||
-	    udp_sk(sk)->udp_port_hash != hnum ||
+	    udp_sk(sk)->udp_port_hash != params->hnum ||
 	    sk->sk_family != PF_INET6)
 		return -1;
 
@@ -143,28 +142,28 @@ static int compute_score(struct sock *sk, struct net *net,
 	inet = inet_sk(sk);
 
 	if (inet->inet_dport) {
-		if (inet->inet_dport != sport)
+		if (inet->inet_dport != params->sport)
 			return -1;
 		score++;
 	}
 
 	if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-		if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
+		if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, params->daddr.ipv6))
 			return -1;
 		score++;
 	}
 
 	if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
-		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
+		if (!ipv6_addr_equal(&sk->sk_v6_daddr, params->saddr.ipv6))
 			return -1;
 		score++;
 	}
 
-	if (sk->sk_bound_dev_if || exact_dif) {
-		if (sk->sk_bound_dev_if != dif)
-			return -1;
+	rc = sk_lookup_device_cmp(sk, params);
+	if (rc < 0)
+		return -1;
+	if (rc > 0)
 		score++;
-	}
 
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
@@ -174,10 +173,9 @@ static int compute_score(struct sock *sk, struct net *net,
 
 /* called with rcu_read_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
-		const struct in6_addr *saddr, __be16 sport,
-		const struct in6_addr *daddr, unsigned int hnum, int dif,
-		bool exact_dif, struct udp_hslot *hslot2,
-		struct sk_buff *skb)
+				     const struct sk_lookup *params,
+				     struct udp_hslot *hslot2,
+				     struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -186,13 +184,11 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = -1;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = udp6_ehashfn(net, daddr, hnum,
-						    saddr, sport);
+				hash = udp6_ehashfn(net, params);
 
 				result = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
@@ -213,30 +209,27 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 }
 
 /* rcu_read_lock() must be held */
-struct sock *__udp6_lib_lookup(struct net *net,
-				      const struct in6_addr *saddr, __be16 sport,
-				      const struct in6_addr *daddr, __be16 dport,
-				      int dif, struct udp_table *udptable,
-				      struct sk_buff *skb)
+struct sock *__udp6_lib_lookup(struct net *net, struct sk_lookup *params,
+			       struct udp_table *udptable, struct sk_buff *skb)
 {
 	struct sock *sk, *result;
-	unsigned short hnum = ntohs(dport);
+	unsigned short hnum = ntohs(params->dport);
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
-	bool exact_dif = udp6_lib_exact_dif_match(net, skb);
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
 
+	params->hnum = hnum;
+	params->exact_dif = udp6_lib_exact_dif_match(net, skb);
+
 	if (hslot->count > 10) {
-		hash2 = udp6_portaddr_hash(net, daddr, hnum);
+		hash2 = udp6_portaddr_hash(net, params->daddr.ipv6, hnum);
 		slot2 = hash2 & udptable->mask;
 		hslot2 = &udptable->hash2[slot2];
 		if (hslot->count < hslot2->count)
 			goto begin;
 
-		result = udp6_lib_lookup2(net, saddr, sport,
-					  daddr, hnum, dif, exact_dif,
-					  hslot2, skb);
+		result = udp6_lib_lookup2(net, params, hslot2, skb);
 		if (!result) {
 			unsigned int old_slot2 = slot2;
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
@@ -249,10 +242,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			if (hslot->count < hslot2->count)
 				goto begin;
 
-			result = udp6_lib_lookup2(net, saddr, sport,
-						  daddr, hnum, dif,
-						  exact_dif, hslot2,
-						  skb);
+			result = udp6_lib_lookup2(net, params, hslot2, skb);
 		}
 		return result;
 	}
@@ -260,13 +250,11 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	result = NULL;
 	badness = -1;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, saddr, sport, daddr, hnum, dif,
-				      exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = udp6_ehashfn(net, daddr, hnum,
-						    saddr, sport);
+				hash = udp6_ehashfn(net, params);
 				result = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
 				if (result)
@@ -292,23 +280,34 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct sock *sk;
+	struct sk_lookup params = {
+		.saddr.ipv6 = &iph->saddr,
+		.daddr.ipv6 = &iph->daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = inet6_iif(skb),
+	};
 
 	sk = skb_steal_sock(skb);
 	if (unlikely(sk))
 		return sk;
-	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
-				 &iph->daddr, dport, inet6_iif(skb),
-				 udptable, skb);
+
+	return __udp6_lib_lookup(dev_net(skb->dev), &params, udptable, skb);
 }
 
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-
-	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
-				 &iph->daddr, dport, inet6_iif(skb),
-				 &udp_table, skb);
+	struct sk_lookup params = {
+		.saddr.ipv6 = &iph->saddr,
+		.daddr.ipv6 = &iph->daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = inet6_iif(skb),
+	};
+
+	return __udp6_lib_lookup(dev_net(skb->dev), &params, &udp_table, skb);
 }
 EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
 
@@ -318,13 +317,11 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
     IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
     IS_ENABLED(CONFIG_NF_SOCKET_IPV6)
-struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
-			     const struct in6_addr *daddr, __be16 dport, int dif)
+struct sock *udp6_lib_lookup(struct net *net, struct sk_lookup *params)
 {
 	struct sock *sk;
 
-	sk =  __udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				dif, &udp_table, NULL);
+	sk =  __udp6_lib_lookup(net, params, &udp_table, NULL);
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -487,16 +484,20 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	struct ipv6_pinfo *np;
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
-	const struct in6_addr *saddr = &hdr->saddr;
-	const struct in6_addr *daddr = &hdr->daddr;
 	struct udphdr *uh = (struct udphdr *)(skb->data+offset);
+	struct sk_lookup params = {
+		.saddr.ipv6 = &hdr->daddr,
+		.daddr.ipv6 = &hdr->saddr,
+		.sport = uh->dest,
+		.dport = uh->source,
+		.dif   = inet6_iif(skb),
+	};
 	struct sock *sk;
 	int harderr;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	sk = __udp6_lib_lookup(net, daddr, uh->dest, saddr, uh->source,
-			       inet6_iif(skb), udptable, skb);
+	sk = __udp6_lib_lookup(net, &params, udptable, skb);
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
 				  ICMP6_MIB_INERRORS);
@@ -658,21 +659,21 @@ static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 }
 
 static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
-				   __be16 loc_port, const struct in6_addr *loc_addr,
-				   __be16 rmt_port, const struct in6_addr *rmt_addr,
-				   int dif, unsigned short hnum)
+				   struct sk_lookup *params)
 {
+	const struct in6_addr *loc_addr = params->daddr.ipv6;
+	const struct in6_addr *rmt_addr = params->saddr.ipv6;
 	struct inet_sock *inet = inet_sk(sk);
 
 	if (!net_eq(sock_net(sk), net))
 		return false;
 
-	if (udp_sk(sk)->udp_port_hash != hnum ||
+	if (udp_sk(sk)->udp_port_hash != params->hnum ||
 	    sk->sk_family != PF_INET6 ||
-	    (inet->inet_dport && inet->inet_dport != rmt_port) ||
+	    (inet->inet_dport && inet->inet_dport != params->sport) ||
 	    (!ipv6_addr_any(&sk->sk_v6_daddr) &&
 		    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr)) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif) ||
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif) ||
 	    (!ipv6_addr_any(&sk->sk_v6_rcv_saddr) &&
 		    !ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr)))
 		return false;
@@ -705,9 +706,16 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
 	unsigned int offset = offsetof(typeof(*sk), sk_node);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
-	int dif = inet6_iif(skb);
 	struct hlist_node *node;
 	struct sk_buff *nskb;
+	struct sk_lookup params = {
+		.saddr.ipv6 = saddr,
+		.daddr.ipv6 = daddr,
+		.sport = uh->source,
+		.dport = uh->dest,
+		.hnum  = hnum,
+		.dif   = inet6_iif(skb),
+	};
 
 	if (use_hash2) {
 		hash2_any = udp6_portaddr_hash(net, &in6addr_any, hnum) &
@@ -719,8 +727,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	}
 
 	sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
-		if (!__udp_v6_is_mcast_sock(net, sk, uh->dest, daddr,
-					    uh->source, saddr, dif, hnum))
+		if (!__udp_v6_is_mcast_sock(net, sk, &params))
 			continue;
 		/* If zero checksum and no_check is not on for
 		 * the socket then skip it.
@@ -873,21 +880,22 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 
 static struct sock *__udp6_lib_demux_lookup(struct net *net,
-			__be16 loc_port, const struct in6_addr *loc_addr,
-			__be16 rmt_port, const struct in6_addr *rmt_addr,
-			int dif)
+					    const struct sk_lookup *params)
 {
-	unsigned short hnum = ntohs(loc_port);
-	unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
+	unsigned short hnum = params->hnum;
+	unsigned int hash2 = udp6_portaddr_hash(net, params->daddr.ipv6, hnum);
 	unsigned int slot2 = hash2 & udp_table.mask;
 	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
-	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
+	const __portpair ports = INET_COMBINED_PORTS(params->sport, hnum);
 	struct sock *sk;
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
+		    INET6_MATCH(sk, net, params->saddr.ipv6,
+				params->daddr.ipv6, ports,
+				params->dif))
 			return sk;
+
 		/* Only check first socket in chain */
 		break;
 	}
@@ -900,7 +908,14 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 	const struct udphdr *uh;
 	struct sock *sk;
 	struct dst_entry *dst;
-	int dif = skb->dev->ifindex;
+	struct sk_lookup params = {
+		.saddr.ipv6 = &ipv6_hdr(skb)->saddr,
+		.daddr.ipv6 = &ipv6_hdr(skb)->daddr,
+		.dif = skb->dev->ifindex,
+	};
+
+	if (skb->pkt_type != PACKET_HOST)
+		return;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) +
 	    sizeof(struct udphdr)))
@@ -908,13 +923,11 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 
 	uh = udp_hdr(skb);
 
-	if (skb->pkt_type == PACKET_HOST)
-		sk = __udp6_lib_demux_lookup(net, uh->dest,
-					     &ipv6_hdr(skb)->daddr,
-					     uh->source, &ipv6_hdr(skb)->saddr,
-					     dif);
-	else
-		return;
+	params.dport = uh->dest;
+	params.hnum  = ntohs(uh->dest);
+	params.sport = uh->source;
+
+	sk = __udp6_lib_demux_lookup(net, &params);
 
 	if (!sk || !refcount_inc_not_zero(&sk->sk_refcnt))
 		return;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 5cce7eb7dea2..56bb40544035 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -188,6 +188,13 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 		      const struct net_device *in,
 		      const enum nf_tproxy_lookup_t lookup_type)
 {
+	struct sk_lookup params = {
+		.saddr.ipv6 = saddr,
+		.daddr.ipv6 = daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = in->ifindex,
+	};
 	struct sock *sk;
 	struct tcphdr *tcph;
 
@@ -220,8 +227,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 		}
 		break;
 	case IPPROTO_UDP:
-		sk = udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				     in->ifindex);
+		sk = udp6_lib_lookup(net, &params);
 		if (sk) {
 			int connected = (sk->sk_state == TCP_ESTABLISHED);
 			int wildcard = ipv6_addr_any(&sk->sk_v6_rcv_saddr);
-- 
2.1.4
